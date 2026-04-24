# ADR-0004: JWT Bearer Authentication

## Status
Accepted

## Date
2026-04-24

## Context
The user prompt specifies "user auth" for symphonix-eps-ig. Two
authentication mechanisms exist in the CAID pattern library:
1. **Persona-RBAC** — dev-mode header-based (`X-Test-Role`), no
   real credentials, no registration flow.
2. **JWT + bcrypt** — production-ready email/username+password
   registration, login endpoint, bearer token on every request.

The engineer agent must implement exactly one. Choosing both (the
bifurcation that caused lesson #23 in v5.2.0) produces an app where
`/api/items` accepts `X-Test-Role: admin` unauthenticated — a
security defect.

## Decision
Adopt JWT + bcrypt as the sole authentication mechanism:
- `POST /auth/register` — create user with bcrypt-hashed password
- `POST /auth/login` — verify credentials, return signed JWT
- Every route (including GET) requires a valid Bearer token
- Persona-RBAC (`X-Test-Role`) is disabled in production

## Rationale
- bcrypt is the CAID v5.1.0 hardened default (passlib.CryptContext
  is broken against bcrypt>=4.1 — pyca/bcrypt #684)
- JWT is stateless, horizontally scalable, and the industry default
  for SPA + API architectures
- NFR-S-001 mandates "ALL endpoints MUST require authentication"
- NFR-DP-001 mandates per-user data isolation (`owner_id` scoping)

## Consequences

### Positive
- Single auth mechanism eliminates the bifurcation defect
- Every route is protected; no accidental unauthenticated GETs
- Registration + login flows are testable via the standard AC chain

### Negative
- No dev-mode bypass — engineers must register a test user in
  conftest.py rather than passing `X-Test-Role: admin`
- JWT expiry management adds complexity (refresh tokens deferred)
