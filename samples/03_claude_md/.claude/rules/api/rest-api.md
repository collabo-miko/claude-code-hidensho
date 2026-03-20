---
paths:
  - "src/api/**/*.js"
---

# REST API Rules

IMPORTANT: All API endpoints must follow these rules:

- Error responses must use RFC 7807 format (Problem Details)
- All endpoints must validate input with express-validator
- Use HTTP status codes correctly (201 for creation, 204 for deletion)
- Paginate list endpoints (default: 20 items, max: 100)
- Include `X-Request-Id` header in all responses
- Rate limit: 100 requests per minute per IP
