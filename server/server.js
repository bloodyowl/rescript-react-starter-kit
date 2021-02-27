let express = require("express");
let fs = require("fs");
let path = require("path");
let chalk = require("chalk");
let etag = require("etag");
let mime = require("mime");

let app = express();

app.disable("x-powered-by");

let pendingBuild = null;
let webpack = require("webpack");
let config = require("../webpack.config.js");
let { createFsFromVolume, Volume } = require("memfs");
let WebSocket = require("ws");
let volume = new Volume();
let outputFileSystem = createFsFromVolume(volume);
let shouldRebuild = false;
outputFileSystem.join = path.join.bind(path);

let compilers = [webpack(config)];
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

app.use((req, res, next) => {
  let url = req.path;
  let filePath = url.startsWith("/") ? url.slice(1) : url;
  let normalizedFilePath = path.join(__dirname, "../build", filePath);
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

function readFileIfExists(filePath, req, res, replace = true) {
  fs.stat(filePath, (err, data) => {
    if (err) {
      res.status(404).end("");
    } else {
      fs.readFile(filePath, (err, data) => {
        if (err) {
          res.status(404).end("");
        } else {
          setMime(filePath, res);
          res.status(200).set("Etag", etag(data)).end(data);
        }
      });
    }
  });
}

app.get("*", (req, res) => {
  res.set("Cache-control", `public, max-age=0`);
  readFileIfExists(path.join(__dirname, "../build/index.html"), req, res);
});

let port = process.env.PORT || 3000;

app.listen(port);

console.log(`${chalk.white("---")}`);
console.log(`${chalk.green("ReScript React")}`);
console.log(`${chalk.white("---")}`);
console.log(`${chalk.cyan("Development server started")}`);
console.log(``);
console.log(`${chalk.magenta("URL")} -> http://localhost:3000`);
console.log(``);
