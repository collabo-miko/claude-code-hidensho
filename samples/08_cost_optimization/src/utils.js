// src/utils.js - ユーティリティ関数（デモ用）
import { createHash } from "node:crypto";

export function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

export function hashPassword(password) {
  return createHash("sha256").update(password).digest("hex");
}

export function formatDate(date) {
  return new Intl.DateTimeFormat("ja-JP", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}
