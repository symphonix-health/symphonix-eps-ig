# Use Case Scenarios

**Project:** symphonix-eps-ig
**Date:** 2026-04-24
**Standard:** IEEE 29148 Section 9.5

---

## UC-001: User authentication

**Actor:** Authenticated user
**Derived from:** BA extraction (entities=['profiled'], verbs=['create', 'read', 'delete', 'login', 'schedule', 'notify', 'import', 'update'])

### Preconditions
- The system is running and the database is seeded
- The actor is authenticated (unless testing the registration journey)

### Main Flow
1. A new user can register with username + password
2. An existing user can log in and receive a bearer token
3. An authenticated user can log out and invalidate the token
4. An unauthenticated request to a protected route returns 401

### Postconditions
- System state reflects the completed journey
- Audit log contains a record of the action

---

## UC-002: Profiled CRUD operations

**Actor:** Authenticated user
**Derived from:** BA extraction (entities=['profiled'], verbs=['create', 'read', 'delete', 'login', 'schedule', 'notify', 'import', 'update'])

### Preconditions
- The system is running and the database is seeded
- The actor is authenticated (unless testing the registration journey)

### Main Flow
1. An authenticated user can create a profiled with the required fields
2. An authenticated user can list their own profileds
3. An authenticated user can update a profiled they own
4. An authenticated user can delete a profiled they own
5. A user cannot see or modify profileds owned by others

### Postconditions
- System state reflects the completed journey
- Audit log contains a record of the action

---
