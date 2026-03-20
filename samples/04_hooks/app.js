// フック動作確認用のサンプルコード
// Claude に「このファイルを改善して」と依頼すると、PostToolUse フックが動作します

function greet(name) {
  return "Hello, " + name + "!"
}

function add(a, b) {
  return a + b
}

console.log(greet("Claude Code"))
console.log(add(2, 3))
