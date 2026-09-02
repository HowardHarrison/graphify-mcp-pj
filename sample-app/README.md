# Sample Application

Small TypeScript app used to exercise Graphify code-graph generation.

## Architecture

```text
HTTP Request
 ↓
AuthController / PaymentController
 ↓
AuthService / PaymentService
 ↓
AuthRepository / PaymentGateway + PaymentRepository
 ↓
Database (in-memory stub)
```

## Modules

- `src/auth/` — registration and login
- `src/payment/` — payment processing via a gateway stub
- `src/database/` — in-memory persistence boundary

This is **not** an application database product. It exists so Graphify can map repository → database relationships.
