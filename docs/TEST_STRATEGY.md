# Test Strategy & V-Model Verification

**Project:** symphonix-eps-ig
**Date:** 2026-04-24
**Standard:** IEEE 29119:2022 / IEEE 829
**Status:** Draft

---

## 1. Test Objectives

- Verify all functional requirements (FR-XXX) via automated tests
- Validate non-functional requirements (NFR-P/S/R/M) via specialized checks
- Ensure requirement traceability: every FR has >= 1 linked test case
- Achieve code coverage targets: Unit > 80%, Integration > 70%

---

## 2. V-Model Mapping

```
  Requirements Analysis    <----->    System/Acceptance Tests
        |                                      |
  System Design            <----->    Integration Tests
        |                                      |
  Component Design         <----->    Unit Tests
        |                                      |
  Implementation           <----->    Code Review + Self-Verification
```

### Level 4: Unit Tests (Component)

- _Generated during implementation by engineer agents_

**Tool:** pytest
**Coverage target:** > 80%
**Run:** `pytest tests/unit -v --cov=src`

### Level 3: Integration Tests (Service)

- _Generated during implementation by engineer agents_

**Tool:** pytest + httpx.AsyncClient
**Coverage target:** > 70%
**Run:** `pytest tests/integration -v`

### Level 2: System Tests (End-to-End)

- _Generated from use case scenarios_

**Tool:** Playwright / Computer Use
**Run:** `pytest tests/e2e -v` or `/caid-verify`

### Level 1: Acceptance Tests (User Validation)

- _Generated from use case scenarios via browser verification_

**Tool:** Computer Use (SignalBox/GHARRA browser runtime)
**Run:** `/caid-verify`

---

## 3. Test Matrix Format (BulletTrain 14-Column Canonical)

Test scenarios are stored in JSON files under `tests/harness/json_matrices/`.
Each entry follows the 14-column canonical format:

```json
{
  "UseCaseID": "TC-API-001",
  "Component": "API Core",
  "Scenario": "Create resource with valid payload",
  "TestType": "Positive",
  "Priority": "P0",
  "SyntheticDataSummary": {
    "Preconditions": ["Service running", "DB connected"],
    "Input": {"name": "test", "type": "document"}
  },
  "ExpectedOutcome": {
    "status_code": 201,
    "body_fields": ["id", "name", "created_at"]
  },
  "FaultProfile": {},
  "SecurityContext": {},
  "VerificationMethod": "HTTP status + JSON schema",
  "Tags": ["api", "crud", "positive"],
  "EstimatedDuration": "< 5s",
  "AutomationStatus": "Automated",
  "AdditionalNotes": ""
}
```

Distribution: 85% Positive, 10% Negative, 5% Edge cases.

---

## 4. Requirements Traceability Matrix

| Test ID | Req ID | Component | Scenario | Type | Priority |
|---------|--------|-----------|----------|------|----------|
| TC-FR001-AC01 | FR-001 | Foundation | GIVEN a new project directory, WHEN mvn compile ru | Positive | CRITICAL |
| TC-FR002-AC01 | FR-002 | Database | GIVEN JPA entity definitions, WHEN application sta | Positive | CRITICAL |
| TC-FR003-AC01 | FR-003 | API | GIVEN a running server, WHEN GET /actuator/health, | Positive | HIGH |
| TC-FR-BA-100-AC01 | FR-BA-100a |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-100-AC02 | FR-BA-100a |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-100-AC03 | FR-BA-100a |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-100-AC04 | FR-BA-100b |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-101-AC01 | FR-BA-101a |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-101-AC02 | FR-BA-101a |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-101-AC03 | FR-BA-101a |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-101-AC04 | FR-BA-101b |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR-BA-101-AC05 | FR-BA-101b |  | GIVEN the app is running and the database is seede | Positive | HIGH |
| TC-FR004-AC01 | FR-004 | Tests | GIVEN the test suite, WHEN mvn test runs, THEN all | Positive | HIGH |

---

## 5. Test Execution Schedule

| Phase | When | Scope | Duration |
|-------|------|-------|----------|
| Self-Verification | During implementation | Unit tests per task | < 30s |
| Post-Merge | After each engineer merge | Integration tests | < 2 min |
| Pre-Release | After all tasks merged | Full suite + E2E | < 10 min |
| Computer-Use | After build complete | Visual + interaction | < 5 min |

---

## 6. Coverage Targets

| Level | Target | Measurement |
|-------|--------|-------------|
| Unit | > 80% | `pytest --cov` |
| Integration | > 70% | `pytest --cov` |
| Requirements | 100% | RTM completeness |
| Use Cases | 100% critical paths | E2E scenario coverage |

---

## 7. Tools

| Tool | Purpose |
|------|---------|
| pytest | Unit, integration, system testing |
| pytest-cov | Code coverage measurement |
| httpx | Async HTTP client for API testing |
| Playwright | E2E browser automation |
| SignalBox/GHARRA | Computer-use visual verification |
| ruff | Python linting |
