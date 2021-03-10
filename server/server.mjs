import express from "express";
import path from "path";
import chalk from "chalk";
import etag from "etag";
import mime from "mime";
import getPort from "get-port";

let fs = await import("fs");

let app = express();

app.disable("x-powered-by");

let pendingBuild = null;
import webpack from "webpack";
import config from "../webpack.config.js";
import { createFsFromVolume, Volume } from "memfs";
import WebSocket from "ws";
let volume = new Volume();
let outputFileSystem = createFsFromVolume(volume);
let shouldRebuild = false;
outputFileSystem.join = path.join.bind(path);

async function createWebsocketServer(port) {
  let server = new WebSocket.Server({
    port: port,
  });
  let openedConnections = [];
  server.on("connection", (ws) => {
    openedConnections.push(ws);
    ws.on("close", () => {
      openedConnections = openedConnections.filter((item) => item != ws);
    });
  });
  return {
    send: (message) => {
      openedConnections.forEach((ws) => ws.send(message));
    },
  };
}

let reloadWsPort = await getPort();
let reloadWs = await createWebsocketServer(reloadWsPort);

let suffix = `<script>new WebSocket("ws://localhost:${reloadWsPort}").onmessage = function() {location.reload(true)}</script>`;

let compilers = [webpack(config)];

let isFirstRun = true;

function build() {
  console.log(
    chalk.white(new Date().toJSON()) + " " + chalk.blue("Webpack") + " start"
  );
  return (pendingBuild = Promise.all(
    compilers.map((compiler) => {
      return new Promise((resolve, reject) => {
        compiler.outputFileSystem = outputFileSystem;
        compiler.run((error, stats) => {
          if (error) {
            reject(error);
          } else {
            if (stats.hasErrors()) {
              console.log(stats.toJson().errors);
              let errors = stats.toJson().errors.join("\n");
              reject(errors);
            } else {
              if (!isFirstRun) {
                reloadWs.send("change");
              }
              isFirstRun = false;
              resolve();
            }
          }
        });
      });
    })
  )
    .then(() => {
      if (shouldRebuild) {
        shouldRebuild = false;
        return build();
      } else {
        console.log(
          chalk.white(new Date().toJSON()) +
            " " +
            chalk.blue("Webpack") +
            " done"
        );
        pendingBuild = null;
      }
    })
    .catch((error) => {
      console.log(
        chalk.white(new Date().toJSON()) +
          " " +
          chalk.blue("Webpack") +
          " errored"
      );
      console.error(error);
    }));
}

process.nextTick(() => {
  build();
});

let ws = new WebSocket("ws://localhost:9999");
let LAST_SEEN_SUCCESS_BUILD_STAMP = Date.now();

ws.on("open", () => {
  console.log(
    chalk.white(new Date().toJSON()) +
      " " +
      chalk.red("BuckleScript") +
      " connected"
  );
});

ws.on("error", () => {
  console.log(
    chalk.white(new Date().toJSON()) +
      " " +
      chalk.red("BuckleScript") +
      " failed to connect"
  );
});

ws.on("message", (data) => {
  let LAST_SUCCESS_BUILD_STAMP = JSON.parse(data).LAST_SUCCESS_BUILD_STAMP;
  if (LAST_SUCCESS_BUILD_STAMP > LAST_SEEN_SUCCESS_BUILD_STAMP) {
    console.log(
      chalk.white(new Date().toJSON()) +
        " " +
        chalk.red("BuckleScript") +
        " change"
    );
    LAST_SEEN_SUCCESS_BUILD_STAMP = LAST_SUCCESS_BUILD_STAMP;
    if (pendingBuild == null) {
      build();
    } else {
      shouldRebuild = true;
    }
  }
});

fs = outputFileSystem;

// Delay requests until webpack has finished building
app.use((req, res, next) => {
  if (pendingBuild != null) {
    pendingBuild.then(
      () => {
        process.nextTick(() => {
          next();
        }, 0);
      },
      () => {
        res.status(500).end("Build error");
      }
    );
  } else {
    next();
  }
});

let publicPath = process.env.PUBLIC_PATH || "/";

app.use(publicPath, (req, res, next) => {
  let url = req.path;
  let filePath = url.startsWith("/") ? url.slice(1) : url;
  let normalizedFilePath = path.join(process.cwd(), "build", filePath);
  fs.stat(normalizedFilePath, (err, stat) => {
    if (err) {
      next();
    } else {
      if (stat.isFile()) {
        fs.readFile(normalizedFilePath, (err, data) => {
          if (err) {
            next();
          } else {
            setMime(filePath, res);
            res.status(200).set("Etag", etag(data)).end(data);
          }
        });
      } else {
        next();
      }
    }
  });
});

function setMime(path, res) {
  if (res.getHeader("Content-Type")) {
    return;
  }
  let type = mime.getType(path);
  if (!type) {
    return;
  }
  res.setHeader("Content-Type", type);
}

function readFileIfExists(filePath, req, res, appendix) {
  fs.stat(filePath, (err, data) => {
    if (err) {
      res.status(404).end("");
    } else {
      fs.readFile(filePath, (err, data) => {
        if (err) {
          res.status(404).end("");
        } else {
          setMime(filePath, res);
          res
            .status(200)
            .set("Etag", etag(data))
            .end(appendix ? data + appendix : data);
        }
      });
    }
  });
}

app.get(`${publicPath}*`, (req, res) => {
  res.set("Cache-control", `public, max-age=0`);
  readFileIfExists(
    path.join(process.cwd(), "build/index.html"),
    req,
    res,
    suffix
  );
});

let port = process.env.PORT || 3000;

app.listen(port);

console.log(`${chalk.white("---")}`);
console.log(`${chalk.green("ReScript React")}`);
console.log(`${chalk.white("---")}`);
console.log(`${chalk.cyan("Development server started")}`);
console.log(``);
console.log(`${chalk.magenta("URL")} -> http://localhost:3000${publicPath}`);
console.log(``);
