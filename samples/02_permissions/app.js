// 権限テスト用のサンプルファイル
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ message: "Permission test app" });
});

module.exports = app;
