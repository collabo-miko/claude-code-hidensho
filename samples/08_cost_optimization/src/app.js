// src/app.js - シンプルなユーザー管理API（デモ用）
import { validateEmail, hashPassword } from "./utils.js";

const users = new Map();

export function createUser(name, email, password) {
  if (!validateEmail(email)) {
    throw new Error("Invalid email format");
  }
  const id = crypto.randomUUID();
  const hashedPassword = hashPassword(password);
  const user = { id, name, email, hashedPassword, createdAt: new Date() };
  users.set(id, user);
  return { id, name, email };
}

export function getUser(id) {
  const user = users.get(id);
  if (!user) return null;
  const { hashedPassword, ...publicUser } = user;
  return publicUser;
}

export function listUsers() {
  return Array.from(users.values()).map(({ hashedPassword, ...u }) => u);
}

export function deleteUser(id) {
  return users.delete(id);
}
