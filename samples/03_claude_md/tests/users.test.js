import { validateId, pick } from '../src/utils/helpers.js';

describe('validateId', () => {
  it('正の整数を有効と判定すること', () => {
    expect(validateId(1)).toBe(true);
    expect(validateId(100)).toBe(true);
  });

  it('0や負の数を無効と判定すること', () => {
    expect(validateId(0)).toBe(false);
    expect(validateId(-1)).toBe(false);
  });

  it('文字列を無効と判定すること', () => {
    expect(validateId('abc')).toBe(false);
  });
});

describe('pick', () => {
  it('指定キーのみを抽出すること', () => {
    const obj = { a: 1, b: 2, c: 3 };
    expect(pick(obj, ['a', 'c'])).toEqual({ a: 1, c: 3 });
  });
});
