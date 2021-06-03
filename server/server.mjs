import express from "express";
import path from "path";
import chalk from "chalk";
import etag from "etag";
import mime from "mime";
import webpack from "webpack";

import config from "../webpack.config.js";

let fs = await import("fs");

let { name } = JSON.parse(
  fs.readFileSync(path.join(process.cwd(), "package.json"), "utf8")
);

let app = express();

app.disable("x-powered-by");

import createRescriptDevserverTools from "rescript-devserver-tools";

let { virtualFs, middleware, getLiveReloadAppendix } =
  createRescriptDevserverTools(webpack(config));

fs = virtualFs;

app.use(middleware);

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
    getLiveReloadAppendix()
  );
});

let port = process.env.PORT || 3000;

app.listen(port);

console.log(`${chalk.white("---")}`);
console.log(`${chalk.green(`${name}`)}`);
console.log(`${chalk.white("---")}`);
console.log(`${chalk.cyan("Development server started")}`);
console.log(``);
console.log(`${chalk.magenta("URL")} -> http://localhost:${port}${publicPath}`);
console.log(``);
