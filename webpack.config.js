let webpack = require("webpack");
let path = require("path");
let HtmlWebpackPlugin = require("html-webpack-plugin");
let TerserPlugin = require("terser-webpack-plugin");
let CopyWebpackPlugin = require("copy-webpack-plugin");
let packageJson = require("./package.json");

let publicPath = process.env.PUBLIC_PATH || "/";

module.exports = {
  mode: process.env.NODE_ENV == "production" ? "production" : "development",
  devtool: false,
  entry: {
    index: "./src/App.mjs",
  },
  optimization: {
    minimize: process.env.NODE_ENV == "production",
    minimizer: [
      new TerserPlugin({
        parallel: false,
      }),
    ],
  },
  output: {
    path: path.join(__dirname, "build"),
    publicPath,
    filename: `public/${packageJson.version}/[name].[contenthash].js`,
    chunkFilename: `public/chunks/[contenthash].js`,
    globalObject: "this",
  },
  plugins: [
    new CopyWebpackPlugin({
      patterns: [{ from: "**/*", to: ``, context: "./statics" }],
    }),
    new HtmlWebpackPlugin({
      filename: `index.html`,
      template: "./src/index.html",
      chunks: ["index"],
    }),
    // Used to simulate SPA on GitHub
    new HtmlWebpackPlugin({
      filename: `404.html`,
      template: "./src/index.html",
      chunks: ["index"],
    }),
    new webpack.DefinePlugin({
      "process.env.PUBLIC_PATH": JSON.stringify(publicPath),
    }),
  ],
};
