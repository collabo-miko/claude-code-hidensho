# Project Rules

## Code style
- Use ES modules (import/export), not CommonJS
- Use const by default, let only when reassignment is needed
- Destructure imports when possible
- Use template literals instead of string concatenation

## Naming
- Functions: camelCase
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case.js

## Workflow
- Run `npm test` after making code changes
- Prefer running single tests, not the full suite
- Always add JSDoc comments to exported functions

## Error handling
- Use custom error classes extending Error
- Always include error codes in API responses
- Log errors with structured JSON format

Detailed rules: @.claude/rules/code-style.md
