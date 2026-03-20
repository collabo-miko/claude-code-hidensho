#!/usr/bin/env node
// mcp-server-demo.js
// 最小限の MCP サーバー（stdio トランスポート）
//
// Claude Code に MCP サーバーを追加する体験用のデモサーバーです。
// JSON-RPC over stdin/stdout で通信し、2つのツールを提供します:
//
//   - project_stats: プロジェクトのファイル統計を返す
//   - todo_list: ソースコード内の TODO コメントを一覧する
//
// 登録方法:
//   claude mcp add demo-tools -s project -- node mcp-server-demo.js
//
// 依存関係: なし（Node.js 標準ライブラリのみ）

import { createInterface } from 'node:readline';
import { execSync } from 'node:child_process';
import { resolve } from 'node:path';

const SERVER_NAME = 'demo-tools';
const SERVER_VERSION = '1.0.0';

// --- ツール定義 ---
const TOOLS = [
  {
    name: 'project_stats',
    description: 'プロジェクトのファイル統計（ファイル数、行数、言語別内訳）を返します',
    inputSchema: {
      type: 'object',
      properties: {
        directory: {
          type: 'string',
          description: '対象ディレクトリ（デフォルト: カレントディレクトリ）',
        },
      },
    },
  },
  {
    name: 'todo_list',
    description: 'ソースコード内の TODO / FIXME / HACK コメントを一覧します',
    inputSchema: {
      type: 'object',
      properties: {
        pattern: {
          type: 'string',
          description: '検索パターン（デフォルト: TODO|FIXME|HACK）',
        },
      },
    },
  },
];

// --- ツール実装 ---
function projectStats(args) {
  const dir = resolve(args.directory || '.');
  try {
    const files = execSync(
      `find "${dir}" -type f \\( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rb" -o -name "*.sh" \\) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*"`,
      { encoding: 'utf-8', timeout: 5000 }
    ).trim();

    if (!files) {
      return { totalFiles: 0, totalLines: 0, byExtension: {} };
    }

    const fileList = files.split('\n');
    const byExtension = {};
    let totalLines = 0;

    for (const file of fileList) {
      const ext = file.split('.').pop();
      try {
        const lines = execSync(`wc -l < "${file}"`, { encoding: 'utf-8', timeout: 2000 }).trim();
        const lineCount = parseInt(lines, 10) || 0;
        totalLines += lineCount;
        byExtension[ext] = (byExtension[ext] || { files: 0, lines: 0 });
        byExtension[ext].files++;
        byExtension[ext].lines += lineCount;
      } catch {
        // skip unreadable files
      }
    }

    return { totalFiles: fileList.length, totalLines, byExtension };
  } catch (e) {
    return { error: e.message };
  }
}

function todoList(args) {
  const pattern = args.pattern || 'TODO|FIXME|HACK';
  try {
    const result = execSync(
      `grep -rnE "(${pattern})" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" . 2>/dev/null | grep -v node_modules | grep -v .git | head -50`,
      { encoding: 'utf-8', timeout: 5000 }
    ).trim();

    if (!result) {
      return { items: [], message: 'TODO/FIXME/HACK は見つかりませんでした' };
    }

    const items = result.split('\n').map((line) => {
      const match = line.match(/^(.+?):(\d+):(.+)$/);
      if (match) {
        return { file: match[1], line: parseInt(match[2], 10), content: match[3].trim() };
      }
      return { raw: line };
    });

    return { items, total: items.length };
  } catch {
    return { items: [], message: 'TODO/FIXME/HACK は見つかりませんでした' };
  }
}

// --- JSON-RPC ハンドラ ---
function handleRequest(request) {
  const { method, params, id } = request;

  switch (method) {
    case 'initialize':
      return {
        jsonrpc: '2.0',
        id,
        result: {
          protocolVersion: '2024-11-05',
          capabilities: { tools: {} },
          serverInfo: { name: SERVER_NAME, version: SERVER_VERSION },
        },
      };

    case 'notifications/initialized':
      return null; // 通知には応答不要

    case 'tools/list':
      return {
        jsonrpc: '2.0',
        id,
        result: { tools: TOOLS },
      };

    case 'tools/call': {
      const toolName = params?.name;
      const toolArgs = params?.arguments || {};

      let result;
      switch (toolName) {
        case 'project_stats':
          result = projectStats(toolArgs);
          break;
        case 'todo_list':
          result = todoList(toolArgs);
          break;
        default:
          return {
            jsonrpc: '2.0',
            id,
            error: { code: -32601, message: `Unknown tool: ${toolName}` },
          };
      }

      return {
        jsonrpc: '2.0',
        id,
        result: {
          content: [{ type: 'text', text: JSON.stringify(result, null, 2) }],
        },
      };
    }

    case 'ping':
      return { jsonrpc: '2.0', id, result: {} };

    default:
      if (method?.startsWith('notifications/')) {
        return null; // 通知は無視
      }
      return {
        jsonrpc: '2.0',
        id,
        error: { code: -32601, message: `Method not found: ${method}` },
      };
  }
}

// --- stdio トランスポート ---
const rl = createInterface({ input: process.stdin });

rl.on('line', (line) => {
  try {
    const request = JSON.parse(line);
    const response = handleRequest(request);
    if (response) {
      process.stdout.write(JSON.stringify(response) + '\n');
    }
  } catch (e) {
    const errorResponse = {
      jsonrpc: '2.0',
      id: null,
      error: { code: -32700, message: 'Parse error' },
    };
    process.stdout.write(JSON.stringify(errorResponse) + '\n');
  }
});

process.stderr.write(`${SERVER_NAME} v${SERVER_VERSION} started (stdio)\n`);
