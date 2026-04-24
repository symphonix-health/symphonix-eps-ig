# Developer Guide

**Project:** symphonix-eps-ig
**Type:** spring-service
**Date:** 2026-04-24

---

## 1. Quick Start

```bash
# Clone and setup
git clone <repository-url>
cd symphonix-eps-ig

# Python projects
python -m venv .venv
source .venv/bin/activate  # or .venv/Scripts/activate on Windows
pip install -e ".[dev]"

# Run tests
pytest tests/ -v

# Start service
uvicorn src.main:app --reload --port 8000
```

---

## 2. Architecture

This project was built using CAID (Centralized Asynchronous Isolated
Delegation) multi-agent coordination. Tasks were decomposed into
dependency-aware groups and implemented in parallel by engineer agents.

### Task Decomposition

  1. **Spring Boot Project Foundation** (`foundation`)
  2. **JPA Entities & Repositories** (`domain`) -- depends on: foundation
  3. **REST Controllers & DTOs** (`api`) -- depends on: domain
  4. **Test Suite** (`tests`) -- depends on: api

### File Map

  - `pom.xml` -- Maven project config
  - `src/main/java/com/app/Application.java` -- Spring Boot main class
  - `src/main/resources/application.yml` -- Application configuration
  - `CLAUDE.md` -- Development conventions
  - `src/main/java/com/app/model/Item.java` -- JPA entity
  - `src/main/java/com/app/repository/ItemRepository.java` -- Spring Data repository
  - `src/main/java/com/app/DataSeeder.java` -- Seed data on startup
  - `src/main/java/com/app/controller/ItemController.java` -- REST controller
  - `src/main/java/com/app/dto/ItemDto.java` -- Request/response DTOs
  - `src/main/java/com/app/exception/GlobalExceptionHandler.java` -- Error handling
  - `src/test/java/com/app/controller/ItemControllerTest.java` -- Controller tests
  - `src/test/java/com/app/repository/ItemRepositoryTest.java` -- Repository tests

---

## 3. Development Workflow

1. Read CLAUDE.md for project conventions
2. Check REQUIREMENTS.md for what needs to be built
3. Read DESIGN-*.md for component specifications
4. Implement changes following existing patterns
5. Run tests: `pytest tests/ -v`
6. Lint: `ruff check .`
7. Commit with conventional message: `feat: add X` / `fix: resolve Y`

---

## 4. Testing

See TEST_STRATEGY.md for the complete V-model testing approach.

- **Unit:** `pytest tests/unit -v --cov=src`
- **Integration:** `pytest tests/integration -v`
- **E2E:** `pytest tests/e2e -v` or `/caid-verify`

Test matrices are in `tests/harness/json_matrices/` (14-column canonical format).

---

## 5. Documentation Index

| Document | Purpose |
|----------|---------|
| CLAUDE.md | Development conventions and rules |
| docs/REQUIREMENTS.md | Software requirements (IEEE 29148) |
| docs/design/DESIGN-*.md | Component design specs (IEEE 1016) |
| docs/adr/ADR-*.md | Architecture decision records |
| docs/TEST_STRATEGY.md | V-model test strategy (IEEE 29119) |
| docs/DEPLOYMENT.md | Release and deployment plan |
| docs/OPERATIONS.md | Operational handbook and runbooks |
| docs/DEVELOPER_GUIDE.md | This document |
