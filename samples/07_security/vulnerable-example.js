/**
 * 脆弱なコードの例（セキュリティ修正演習用）
 *
 * このファイルには意図的に複数のセキュリティ脆弱性が含まれています。
 * Claude Code に「このファイルのセキュリティ問題を修正して」と依頼して、
 * どのように修正されるかを確認してください。
 */

const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();

// 脆弱性1: SQL インジェクション
app.get('/user', (req, res) => {
  const userId = req.query.id;
  // 危険: ユーザー入力を直接 SQL に結合
  const query = `SELECT * FROM users WHERE id = '${userId}'`;
  // db.query(query) ...
  res.json({ query }); // デモ用に返す
});

// 脆弱性2: XSS（クロスサイトスクリプティング）
app.get('/greet', (req, res) => {
  const name = req.query.name;
  // 危険: ユーザー入力をエスケープせずに HTML に埋め込み
  res.send(`<h1>こんにちは、${name}さん！</h1>`);
});

// 脆弱性3: パストラバーサル
app.get('/file', (req, res) => {
  const filename = req.query.name;
  // 危険: ユーザー入力をそのままファイルパスに使用
  const filepath = path.join('/data/uploads', filename);
  const content = fs.readFileSync(filepath, 'utf-8');
  res.send(content);
});

// 脆弱性4: 機密情報の漏洩
app.get('/error', (req, res) => {
  try {
    throw new Error('Something went wrong');
  } catch (err) {
    // 危険: スタックトレースをクライアントに返す
    res.status(500).json({
      error: err.message,
      stack: err.stack,
      env: process.env.NODE_ENV,
      dbHost: process.env.DATABASE_URL,
    });
  }
});

// 脆弱性5: 認証トークンがクエリパラメータに
app.get('/api/data', (req, res) => {
  // 危険: トークンがURL（アクセスログ）に記録される
  const token = req.query.token;
  if (token === 'secret-token') {
    res.json({ data: 'sensitive information' });
  } else {
    res.status(401).json({ error: 'Unauthorized' });
  }
});

module.exports = app;
