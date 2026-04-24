# API Reference

**Project:** symphonix-eps-ig
**Date:** 2026-04-24
**Version:** 1.0.0

---

## Base URL

```
http://localhost:8000
```

## Authentication

All mutating endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <token>
```

---

## Endpoints

### Health Check

```
GET /health
```

**Response:** `200 OK`
```json
{"status": "healthy", "service": "symphonix-eps-ig"}
```

---

### RESTful API endpoints — GET /actuator/health

```
GET /actuator/health
```

**Expected:** `200`
**AC:** FR003-AC01 — 200 OK

---

### Authentication — POST /auth/register

```
POST /auth/register
```

**Description:** Register a new user (username + password)
**Expected:** `201`

---

### Authentication — POST /auth/login

```
POST /auth/login
```

**Description:** Authenticate and receive a bearer token
**Expected:** `200`

---


---

## Error Format

All errors follow a consistent format:

```json
{
  "detail": "Human-readable error message",
  "error_code": "MACHINE_READABLE_CODE",
  "timestamp": "2026-03-31T12:00:00Z"
}
```

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized |
| 404 | Not Found |
| 409 | Conflict |
| 500 | Internal Server Error |
