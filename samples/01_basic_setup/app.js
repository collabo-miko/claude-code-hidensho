// サンプルアプリケーション — Claude Code の基本操作練習用
// 意図的にいくつかの問題を含んでいます

const http = require("http");

function parseQueryString(url) {
  const params = {};
  const queryString = url.split("?")[1];
  if (queryString) {
    queryString.split("&").forEach((pair) => {
      const [key, value] = pair.split("=");
      params[key] = value;
    });
  }
  return params;
}

function calculateDiscount(price, discountPercent) {
  // バグ: 割引率の範囲チェックがない
  return price * (1 - discountPercent / 100);
}

function formatCurrency(amount) {
  return "$" + amount.toFixed(2);
}

const users = [
  { id: 1, name: "Alice", email: "alice@example.com" },
  { id: 2, name: "Bob", email: "bob@example.com" },
  { id: 3, name: "Charlie", email: "charlie@example.com" },
];

function findUser(id) {
  // バグ: 型の不一致（文字列と数値の比較）
  return users.find((u) => u.id == id);
}

const server = http.createServer((req, res) => {
  const params = parseQueryString(req.url);

  if (req.url.startsWith("/user")) {
    const user = findUser(params.id);
    if (user) {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify(user));
    } else {
      res.writeHead(404);
      res.end("Not found");
    }
  } else if (req.url.startsWith("/discount")) {
    const price = parseFloat(params.price);
    const discount = parseFloat(params.discount);
    const result = calculateDiscount(price, discount);
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ original: price, discounted: formatCurrency(result) }));
  } else {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("Hello from Claude Code sample app!");
  }
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
