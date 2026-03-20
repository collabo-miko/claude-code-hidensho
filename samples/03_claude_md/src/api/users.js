import { validateId } from '../utils/helpers.js';

// validateId は演習で追加実装する想定

const users = [
  { id: 1, name: 'Alice', email: 'alice@example.com', role: 'admin' },
  { id: 2, name: 'Bob', email: 'bob@example.com', role: 'user' },
  { id: 3, name: 'Charlie', email: 'charlie@example.com', role: 'user' },
];

/**
 * ユーザー一覧を取得する
 * @param {object} req - リクエスト
 * @param {object} res - レスポンス
 */
export const getUsers = (req, res) => {
  res.json({ data: users, total: users.length });
};

/**
 * IDでユーザーを取得する
 * @param {object} req - リクエスト
 * @param {object} res - レスポンス
 */
export const getUserById = (req, res) => {
  const id = parseInt(req.params.id, 10);
  const user = users.find((u) => u.id === id);

  if (!user) {
    // ここを RFC 7807 形式に修正すべき（演習用）
    res.status(404).json({ error: 'User not found' });
    return;
  }

  res.json({ data: user });
};
