/**
 * 四則演算の計算機モジュール
 * レビューとテスト生成の対象コード
 */

/**
 * 2つの数値を加算する
 * @param {number} a
 * @param {number} b
 * @returns {number}
 */
export function add(a, b) {
  return a + b;
}

/**
 * 2つの数値を減算する
 * @param {number} a
 * @param {number} b
 * @returns {number}
 */
export function subtract(a, b) {
  return a - b;
}

/**
 * 2つの数値を乗算する
 * @param {number} a
 * @param {number} b
 * @returns {number}
 */
export function multiply(a, b) {
  return a * b;
}

/**
 * 2つの数値を除算する
 * @param {number} a - 被除数
 * @param {number} b - 除数
 * @returns {number}
 */
export function divide(a, b) {
  // 意図的なバグ: ゼロ除算のチェックがない
  return a / b;
}

/**
 * べき乗を計算する
 * @param {number} base - 底
 * @param {number} exponent - 指数
 * @returns {number}
 */
export function power(base, exponent) {
  return Math.pow(base, exponent);
}

/**
 * 配列の平均値を計算する
 * @param {number[]} numbers - 数値の配列
 * @returns {number}
 */
export function average(numbers) {
  // 意図的なバグ: 空配列のチェックがない
  const sum = numbers.reduce((acc, n) => acc + n, 0);
  return sum / numbers.length;
}
