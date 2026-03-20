/**
 * IDが有効な正の整数かを検証する
 * @param {*} id - 検証対象のID
 * @returns {boolean} 有効なIDならtrue
 */
export const validateId = (id) => {
  const num = Number(id);
  return Number.isInteger(num) && num > 0;
};

/**
 * オブジェクトから指定キーのみを抽出する
 * @param {object} obj - 元のオブジェクト
 * @param {string[]} keys - 抽出するキー
 * @returns {object} 抽出されたオブジェクト
 */
export const pick = (obj, keys) => {
  return keys.reduce((acc, key) => {
    if (key in obj) {
      acc[key] = obj[key];
    }
    return acc;
  }, {});
};
