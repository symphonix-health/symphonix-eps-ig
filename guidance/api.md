## Task: REST Controllers & DTOs

Build @RestController with CRUD endpoints, DTOs with validation, exception handler.

### Requirements

- **FR-003**: RESTful API endpoints
  - FR003-AC01 [Positive] GIVEN a running server, WHEN GET /actuator/health, THEN 200 OK
- **FR-BA-100a**: User authentication (A)
  - FR-BA-100-AC01 [Positive] GIVEN the app is running and the database is seeded, WHEN A new user can register with username + password, THEN the journey succeeds and the system state reflects the expected outcome
  - FR-BA-100-AC02 [Positive] GIVEN the app is running and the database is seeded, WHEN An existing user can log in and receive a bearer token, THEN the journey succeeds and the system state reflects the expected outcome
  - FR-BA-100-AC03 [Positive] GIVEN the app is running and the database is seeded, WHEN An authenticated user can log out and invalidate the token, THEN the journey succeeds and the system state reflects the expected outcome
- **FR-BA-100b**: User authentication (B)
  - FR-BA-100-AC04 [Positive] GIVEN the app is running and the database is seeded, WHEN An unauthenticated request to a protected route returns 401, THEN the journey succeeds and the system state reflects the expected outcome
- **FR-BA-101a**: Profiled CRUD operations (A)
  - FR-BA-101-AC01 [Positive] GIVEN the app is running and the database is seeded, WHEN An authenticated user can create a profiled with the required fields, THEN the journey succeeds and the system state reflects the expected outcome
  - FR-BA-101-AC02 [Positive] GIVEN the app is running and the database is seeded, WHEN An authenticated user can list their own profileds, THEN the journey succeeds and the system state reflects the expected outcome
  - FR-BA-101-AC03 [Positive] GIVEN the app is running and the database is seeded, WHEN An authenticated user can update a profiled they own, THEN the journey succeeds and the system state reflects the expected outcome
- **FR-BA-101b**: Profiled CRUD operations (B)
  - FR-BA-101-AC04 [Positive] GIVEN the app is running and the database is seeded, WHEN An authenticated user can delete a profiled they own, THEN the journey succeeds and the system state reflects the expected outcome
  - FR-BA-101-AC05 [Positive] GIVEN the app is running and the database is seeded, WHEN A user cannot see or modify profileds owned by others, THEN the journey succeeds and the system state reflects the expected outcome

### Pattern Rules (MUST follow)

**Service:**
- Use FastAPI with async lifespan context manager (not @app.on_event)
- Health check at GET /health returning {status: healthy, service: NAME}
- Service name from config, never hardcoded
- Middleware order: correlation_id -> CORS -> custom
- Auto-seed database on startup if empty (check count, seed if 0)
- Graceful shutdown logging in lifespan __aexit__
- Use [OK], [FAIL], [WARN], [INFO], [ERROR] markers, never emoji
- Port from centralized registry via get_service_port()

**Database:**
- Async SQLAlchemy 2.0+ with aiosqlite (dev) / asyncpg (prod)
- Lazy engine init via _get_engine() - never create engine at import time
- reset_engine() function for test isolation
- Use CAID_DATABASE_URL env var first, fallback to DATABASE_URL, default to SQLite
- Naive datetimes for DB columns: datetime.now(timezone.utc).replace(tzinfo=None)
- DeclarativeBase as Base class with mapped_column() syntax
- UUID primary keys via default=lambda: str(uuid.uuid4())
- created_at and updated_at timestamp columns on every model
- Seed data: >= 10 records, multiple states, multiple creators, mix assigned/unassigned
- Seeder has seed(reset=False) and verify_seed() functions
- Tests run against seeded DB, never empty tables

**Auth:**
- AuthContext dataclass with sub, roles, tenant_id, persona fields
- require_auth dependency extracts auth from request (dev mode returns admin)
- require_role(*roles) dependency for route-level RBAC enforcement
- X-Test-Role header support for test persona simulation
- AUTH_MODE env var: 'dev' (permissive), 'oidc' (production)
- Every mutating endpoint requires auth at minimum
- Delete operations require admin role
- Approval/review operations require admin or reviewer role
- Never expose role check logic in business code - use Depends() on routes
- Use the `bcrypt` library DIRECTLY - never passlib.CryptContext. passlib is brittle against bcrypt>=4.1 (version probe fails, 72-byte guard misfires, every password raises ValueError).
- hash_password(pw) -> bcrypt.hashpw(pw.encode(), bcrypt.gensalt()).decode()
- verify_password(pw, hash) -> bcrypt.checkpw(pw.encode(), hash.encode()) wrapped in try/except ValueError for malformed hashes
- Never log or return password_hash in API responses

**Api:**
- Pydantic v2 schemas: str | None (not Optional[str]), Field() for constraints
- Separate Create, Update, Response schemas per entity
- model_config = {'from_attributes': True} on response schemas
- APIRouter with prefix and tags
- Return Pydantic models, not raw dicts
- 404 for missing resources, 422 for validation, 403 for RBAC denial
- emit_audit() on every create, update, delete
- Correlation ID propagated on every response via middleware
- Dropdowns / reference data: expose as GET /api/<reference_set> (e.g. /api/insurers, /api/specialties, /api/trial-sites). Frontend MUST fetch via hook — NEVER hardcode the same list in frontend/src. Seed data MUST use the canonical list the endpoint returns. Add a seed-integrity test asserting every value used in seeded records appears in the reference endpoint response.

**Testing:**
- Tests run against seeded database, NEVER empty tables
- Default test DB is sqlite+aiosqlite:///:memory: — no files, no Windows file locks, no cleanup
- No unittest.mock - real HTTP via httpx.AsyncClient with ASGITransport
- reset_engine() MUST be async and MUST await engine.dispose() before discarding references — otherwise async connections hold file locks
- conftest.py autouse fixture: await reset_engine() -> await init_db() -> yield -> await reset_engine()
- Test acceptance criteria from requirements - derived, not hand-written
- 14-column JSON matrix for parametric scenario testing
- Playwright E2E tests use accessibility selectors (getByRole, getByLabel)
- Playwright auth setup saves state to .auth/user.json for reuse
- Test names describe the scenario, not the implementation
- If the app has a UI (fullstack, web, mobile), ship tests/test_visual_inspection.py (Playwright + axe-core) and run it against live backend+frontend before Phase 6 sign-off. GATE_VISUAL_INSPECTION requires TWO independent evidence streams: (a) automated headless pytest run emitting tests/screenshots/axe_report.json (structural / axe / responsive — DOM-measurable assertions), AND (b) vision-capable review of screenshots (human or vision-model agent attesting visual correctness per spec — catches theme mis-activation, cross-page contradictions, misaligned layouts, wrong banners). Running the same pytest headed gives ZERO additional signal (L-149) because the assertions are DOM-measurable; what adds signal is the reviewer's attestation. attest_visual_inspection(..., axe_report_path=X, headed_artefacts=[paths reviewed by vision]) rejects the gate if either input is missing. See L-137, L-147, L-149.
- If the app has a UI, GATE_LIVE_LIFECYCLE MUST be signed via SignOffReport.attest_live_lifecycle(has_ui=True, computer_use_artefacts=[paths to screenshots / Playwright traces / browser session logs]). curl-only evidence is INSUFFICIENT for a UI-bearing build — the sign-off requires proof a real browser or computer-use session walked the workflow end-to-end per persona. See lesson L-138.

**Observability:**
- Structured JSON logging (never print statements). Every log entry includes: ISO timestamp, service name, log level, correlation ID, and message. Use [OK], [FAIL], [WARN], [INFO], [ERROR] ASCII markers (never emoji)
- Correlation ID middleware: generate X-Correlation-ID on ingress if absent, propagate to all downstream calls via header, bind to every log entry and span
- Distributed tracing via OpenTelemetry: instrument FastAPI routes, httpx calls, SQLAlchemy queries. Use TraceIdRatioBased sampler at 10% normal, 100% errors
- Metrics: expose /metrics endpoint for Prometheus scraping. Track the Four Golden Signals — Latency (histogram), Traffic (counter), Errors (counter by status), Saturation (gauge for resource utilisation)
- Alerts must be actionable, precise, and low-noise. Default thresholds: error rate > 1%, p99 latency > 2s, health check failure. Avoid alert fatigue — every alert should have a documented runbook link
- Health check endpoints: GET /health (liveness — always 200 if process is up), GET /ready (readiness — checks DB, cache, and critical dependencies before returning 200)
- Audit log: emit_audit(action, subject, resource, details) on every state mutation. Audit entries include: ISO timestamp, action (CRUD+Execute), actor identity, resource type, resource ID, outcome, and correlation ID
- In regulated domains (healthcare, finance), audit logs must be append-only with hash chaining for tamper detection. Retention: 6 years minimum for HIPAA. Map to FHIR AuditEvent resource for healthcare systems
- For AI/ML services: track model performance metrics (accuracy, precision, recall, F1, latency, throughput) continuously in production. Alert when metrics degrade beyond agreed thresholds
- Monitor for data drift (input distribution shift), model drift (prediction quality decline), and feature validity (completeness, range, consistency). Most AI failures are caused by data changes, not code bugs
- Log all AI predictions with confidence scores, input features (redacted if PII), and model version. Track prediction distribution shifts over time
- Guardrail monitoring: log and block unsafe AI responses, policy violations, and prohibited actions. Every guardrail trigger becomes an audit event
- When reading Prometheus counters with labels for dashboard display, never access _value directly. Use counter.collect() and sum sample.value across all label combinations
- Hash-chained audit trails: the content used for hash computation must exclude the hash_chain field itself. Extract a shared _content_for_hash() method used by both record() and verify_chain() to avoid content mismatch
- AI prediction diversity check: if >95% of predictions in a rolling window fall into a single class, alert. A degenerate model that always outputs one class will pass bias monitoring (perfect parity) and drift detection (stable distribution) — both false negatives. Synthetic monitoring with known-good probes is the first line of defence against model miscalibration
- Observability verification: do not just configure the stack — verify it produces correct output. After setup: (1) /metrics must return non-zero request count after a probe, (2) /health must return 200, (3) logs must contain at least one entry with a correlation ID, (4) for AI services, a synthetic probe with known-good input must return the expected prediction

**Fsm:**
- Data-driven transition table: dict of (from, to) -> required_roles
- Two validation layers: FSM table (valid transition?) + RBAC (user allowed?)
- Both layers must pass or transition is denied with reason
- TransitionResult dataclass: success, from_state, to_state, reason
- History list records every transition with timestamp
- get_available_transitions(roles) returns valid next states for current user
- State enum inherits from str, Enum for JSON serialization
- Transition endpoint returns available_transitions in response for UI
- Publish SSE event on successful transition for real-time updates

**Security:**
- NEVER commit .env files — generate .env.example with placeholder values instead
- Add comprehensive .gitignore with secret patterns: .env, *.key, *.pem, credentials.json, .secrets
- Use environment variables for ALL secrets: DB URLs, API keys, JWT secrets — never hardcode
- Enable Bandit (Python) or ESLint security plugin (JS/TS) in linter config
- Add pip-audit / npm audit to CI pipeline
- Parameterize ALL database queries — never string concatenation (SQL injection)
- Escape ALL user-rendered content in templates (XSS prevention)
- Add CSRF protection middleware for form submissions
- Set secure HTTP headers: X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security
- Hash passwords with bcrypt (cost >= 12), never store plaintext
- Validate and sanitize ALL user input at API boundaries
- Add Content-Security-Policy headers for frontend
- Use HTTPS-only cookies with SameSite=Lax minimum

**Go:**
- Standard Go project layout: cmd/, internal/, pkg/
- Use Gin or Echo router with middleware chain
- GORM for ORM with AutoMigrate on startup
- Structured logging with slog (stdlib, Go 1.21+)
- Context propagation on all handler signatures
- go test with table-driven tests and testify
- Graceful shutdown via signal.NotifyContext
- Health check at GET /health returning JSON
- go.mod with module path matching repository
- Error handling: never ignore errors, wrap with fmt.Errorf("%w", err)
- Use interfaces for dependency injection
- Config from environment variables via os.Getenv

**Monitoring:**
- Add Sentry SDK initialisation in app startup for automatic error capture with stack traces. Use traces_sample_rate=0.1, profiles_sample_rate=0.1
- Expose /metrics endpoint for Prometheus scraping. Use prometheus-fastapi-instrumentator for automatic route-level latency and request-count metrics
- Track key business metrics: request count, latency percentiles (p50, p95, p99), error rate, active users
- Structured JSON logging (not print statements) with correlation IDs per request. Use structlog or stdlib with a JSON formatter
- React Error Boundary wrapping the app root to catch and report frontend crashes to Sentry
- Health check endpoints: /health (liveness), /ready (readiness with DB + dependency checks)
- Log all unhandled exceptions with full context including correlation ID, request path, and user ID
- Configure alerting thresholds: error rate > 1%, p99 latency > 2s, health check failure. Every alert must link to a runbook
- Use OpenTelemetry auto-instrumentation for FastAPI, httpx, and SQLAlchemy. Export via OTLP to your collector (Tempo for traces, Prometheus for metrics, Loki for logs)
- For healthcare systems: monitor FHIR API latency (alert if > 2s), HL7 message throughput per minute, failed patient registration transactions, and terminology service response times
- Track clinical workflow metrics: appointment booking completion rate, prescription fulfilment latency, lab result delivery time, audit log volume
- For AI services: track inference latency, request rate, failure rate, token usage, and model version. Alert when accuracy drops below agreed threshold. Monitor for data drift using statistical tests (KS test, PSI) on feature distributions
- Define SLIs (Service Level Indicators) for each critical user journey. Set SLOs (Service Level Objectives) with error budgets. Track burn rate and alert when error budget consumption exceeds the threshold

**Environment:**
- Generate .env.example with every config variable and placeholder values — NEVER generate .env directly
- Config module validates all required env vars at startup and fails fast with clear error messages
- Use pydantic-settings BaseSettings with SettingsConfigDict(env_prefix='SYMPHONIX_EPS_IG_', env_file='.env', extra='ignore') — the env_prefix is MANDATORY to prevent host env vars from leaking into the project
- Separate config classes per environment: dev uses SQLite, prod uses PostgreSQL
- Database URL from SYMPHONIX_EPS_IG_DATABASE_URL only — never read unprefixed DATABASE_URL (host pollution risk)
- Default to safe values: DEBUG=false, LOG_LEVEL=info
- CORS origins configurable via SYMPHONIX_EPS_IG_ALLOWED_ORIGINS env var
- Secrets (JWT_SECRET, API keys) MUST have no production default — fail startup if unset in non-dev environments

**Code_Quality:**
- Generate ruff.toml (Python) with select rules: E, F, W, I, N, UP, B, SIM, S (security)
- Generate .eslintrc.json (TS) with recommended + security plugin
- Generate .prettierrc with consistent formatting
- TypeScript strict mode: strict: true in tsconfig.json
- Pre-commit hooks via husky + lint-staged: format + lint on every commit
- CI blocks merge on lint/type errors — no bypassing
- Max function complexity: 15 (cyclomatic), max file length: 300 lines

### Reference Examples

**Lifespan pattern:**
```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    configure_logging(SERVICE_NAME)
    logger.info("[OK] %s starting", SERVICE_NAME)
    await init_db()
    result = await verify_seed()
    if result["total"] == 0:
        await seed()
    yield
    logger.info("[INFO] %s shutting down", SERVICE_NAME)
```

**Middleware stack:**
```python
app.middleware("http")(correlation_id_middleware)
app.add_middleware(CORSMiddleware, allow_origins=["*"],
                   allow_methods=["*"], allow_headers=["*"])
```

**Lazy engine:**
```python
_engine = None
def _get_engine():
    global _engine
    if _engine is None:
        url = os.getenv("CAID_DATABASE_URL",
                        os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./data/app.db"))
        if "postgresql" in url and not os.getenv("CAID_DATABASE_URL"):
            url = "sqlite+aiosqlite:///./data/app.db"
        _engine = create_async_engine(url, echo=False)
    return _engine
```

**Model with timestamps:**
```python
def _utcnow():
    return datetime.now(timezone.utc).replace(tzinfo=None)

class Task(Base):
    __tablename__ = "tasks"
    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=_new_id)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=_utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=_utcnow, onupdate=_utcnow)
```

**RBAC on routes:**
```python
@router.delete("/{id}", status_code=204)
async def delete_item(id: str,
    auth: AuthContext = Depends(require_role("admin"))):
    # Only admins reach here - RBAC enforced by dependency
    ...

@router.post("/{id}/approve")
async def approve(id: str,
    auth: AuthContext = Depends(require_role("admin", "reviewer"))):
    # Admin or reviewer can approve
    ...
```

**Password hashing (bcrypt direct - NOT passlib):**
```python
import bcrypt

def hash_password(password: str) -> str:
    return bcrypt.hashpw(
        password.encode("utf-8"), bcrypt.gensalt()
    ).decode("utf-8")

def verify_password(password: str, password_hash: str) -> bool:
    try:
        return bcrypt.checkpw(
            password.encode("utf-8"),
            password_hash.encode("utf-8"),
        )
    except ValueError:
        return False
```

**Schema pattern:**
```python
class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str = ""

class TaskResponse(BaseModel):
    id: str
    title: str
    state: str
    created_at: datetime
    model_config = {"from_attributes": True}
```

**Route with audit:**
```python
@router.post("", status_code=201, response_model=TaskResponse)
async def create_task(payload: TaskCreate,
    session: AsyncSession = Depends(get_session),
    auth: AuthContext = Depends(require_auth)):
    task = Task(**payload.model_dump(), created_by=auth.sub)
    session.add(task)
    await session.commit()
    await session.refresh(task)
    emit_audit(action="task.create", subject=auth.sub, resource=task.id)
    return task
```

**Async reset_engine that disposes connections:**
```python
# src/database.py
async def reset_engine() -> None:
    global _engine, _sessionmaker
    if _engine is not None:
        await _engine.dispose()   # REQUIRED on Windows
    _engine = None
    _sessionmaker = None
```

**conftest.py — in-memory, Windows-safe:**
```python
import pytest_asyncio
from httpx import ASGITransport, AsyncClient

from src import database
from src.config import settings

# In-memory SQLite: no files, no locks, no cleanup races
settings.database_url = "sqlite+aiosqlite:///:memory:"


@pytest_asyncio.fixture(autouse=True)
async def _fresh_db():
    await database.reset_engine()
    await database.init_db()
    yield
    await database.reset_engine()


@pytest_asyncio.fixture
async def client():
    from src.main import app
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac
```

**Correlation ID middleware (FastAPI):**
```python
import uuid
from contextvars import ContextVar
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

_correlation_id: ContextVar[str] = ContextVar("correlation_id", default="")

class CorrelationIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        cid = request.headers.get(
            "X-Correlation-ID", str(uuid.uuid4())
        )
        _correlation_id.set(cid)
        response = await call_next(request)
        response.headers["X-Correlation-ID"] = cid
        return response
```

**Structured JSON logger with correlation ID:**
```python
import json
import logging
from datetime import datetime, timezone

class StructuredFormatter(logging.Formatter):
    def format(self, record):
        entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "service": getattr(record, "service", "app"),
            "correlation_id": _correlation_id.get(""),
            "message": record.getMessage(),
        }
        if record.exc_info:
            entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(entry)

handler = logging.StreamHandler()
handler.setFormatter(StructuredFormatter())
logger = logging.getLogger("app")
logger.addHandler(handler)
logger.setLevel(logging.INFO)
```

**OpenTelemetry FastAPI setup:**
```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

resource = Resource.create({
    "service.name": "my-service",
    "service.version": "1.0.0",
})
provider = TracerProvider(resource=resource)
provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
trace.set_tracer_provider(provider)

# Auto-instrument all routes
FastAPIInstrumentor.instrument_app(app)
```

**Prometheus metrics (Four Golden Signals):**
```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from starlette.responses import Response

# Latency
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "Request latency in seconds",
    ["method", "endpoint"],
    buckets=[0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.0, 5.0],
)
# Traffic
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)
# Errors
ERROR_COUNT = Counter(
    "http_errors_total",
    "Total HTTP errors (4xx + 5xx)",
    ["method", "endpoint", "status"],
)
# Saturation
ACTIVE_REQUESTS = Gauge(
    "http_active_requests",
    "Currently active requests",
)

@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type="text/plain")
```

**Health check endpoints:**
```python
from sqlalchemy.ext.asyncio import AsyncSession

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/ready")
async def ready(session: AsyncSession = Depends(get_session)):
    try:
        await session.execute(text("SELECT 1"))
        return {"status": "ready", "database": "ok"}
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={"status": "not_ready", "database": str(e)},
        )
```

**Healthcare audit entry (FHIR AuditEvent aligned):**
```python
import hashlib, json, uuid
from datetime import datetime, timezone

def emit_audit(
    action: str,       # C, R, U, D, E
    actor: str,        # Who performed the action
    resource_type: str, # What type of resource
    resource_id: str,  # Which specific resource
    outcome: str,      # success or failure
    detail: str = "",  # Additional context
    patient_ref: str = "",  # Patient link (if applicable)
) -> dict:
    entry = {
        "id": str(uuid.uuid4()),
        "recorded": datetime.now(timezone.utc).isoformat(timespec="milliseconds"),
        "action": action,
        "agent_who": actor,
        "source_observer": "my-service",
        "resource_type": resource_type,
        "resource_id": resource_id,
        "outcome": outcome,
        "outcome_detail": detail,
        "patient_ref": patient_ref,
        "correlation_id": _correlation_id.get(""),
    }
    # Append to immutable store
    logger.info(json.dumps({"audit": entry}))
    return entry
```

**Transition table:**
```python
TRANSITIONS: dict[tuple[State, State], frozenset[str]] = {
    (State.DRAFT, State.SUBMITTED): frozenset({"user", "admin"}),
    (State.SUBMITTED, State.APPROVED): frozenset({"admin", "reviewer"}),
    (State.SUBMITTED, State.REJECTED): frozenset({"admin", "reviewer"}),
    (State.APPROVED, State.IN_PROGRESS): frozenset({"user", "admin"}),
    (State.IN_PROGRESS, State.COMPLETED): frozenset({"user", "admin"}),
    (State.REJECTED, State.DRAFT): frozenset({"user", "admin"}),
}
```

**.env.example (never .env):**
```bash
# .env.example - Copy to .env and fill in values
# NEVER commit .env to git

DATABASE_URL=postgresql://user:password@localhost:5432/mydb
SECRET_KEY=change-me-to-random-string
JWT_SECRET=change-me-to-random-string
REDIS_URL=redis://localhost:6379/0

# Third-party API keys
# STRIPE_SECRET_KEY=sk_test_...
# SENDGRID_API_KEY=SG....
```

**Security-aware .gitignore entries:**
```gitignore
# Secrets - NEVER commit these
.env
.env.local
.env.production
*.key
*.pem
*.p12
credentials.json
service-account.json
.secrets/
secrets.yaml
```

**Secure headers middleware (FastAPI):**
```python
from starlette.middleware.base import (
    BaseHTTPMiddleware,
)

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = (
            "nosniff"
        )
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = (
            "strict-origin-when-cross-origin"
        )
        response.headers["Permissions-Policy"] = (
            "camera=(), microphone=(), geolocation=()"
        )
        return response
```

**Input validation (Pydantic):**
```python
from pydantic import BaseModel, Field, validator
import re

class CreateUserRequest(BaseModel):
    email: str = Field(max_length=255)
    name: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=8, max_length=128)

    @validator("email")
    def validate_email(cls, v):
        if not re.match(
            r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
            v,
        ):
            raise ValueError("Invalid email format")
        return v.lower()

    @validator("name")
    def sanitize_name(cls, v):
        # Strip HTML tags
        return re.sub(r"<[^>]+>", "", v).strip()
```

**Gin router with middleware:**
```go
package main

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"status": "healthy"})
    })
    api := r.Group("/api")
    {
        api.GET("/items", listItems)
        api.POST("/items", createItem)
        api.GET("/items/:id", getItem)
    }
    r.Run(":8080")
}
```

**GORM model and repository:**
```go
package models

import "gorm.io/gorm"

type Item struct {
    gorm.Model
    Title       string `json:"title" gorm:"not null"`
    Description string `json:"description"`
    Status      string `json:"status" gorm:"default:draft"`
}

func AutoMigrate(db *gorm.DB) error {
    return db.AutoMigrate(&Item{})
}
```

**Table-driven test with testify:**
```go
package handler_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestCreateItem(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        wantCode int
    }{
        {"valid", `{"title":"Test"}`, 201},
        {"empty title", `{"title":""}`, 422},
        {"no body", `{}`, 422},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            resp := postJSON("/api/items", tt.input)
            assert.Equal(t, tt.wantCode, resp.Code)
        })
    }
}
```

**Sentry initialisation (FastAPI):**
```python
import os
import sentry_sdk

if dsn := os.environ.get("SENTRY_DSN"):
    sentry_sdk.init(
        dsn=dsn,
        traces_sample_rate=0.1,
        profiles_sample_rate=0.1,
        environment=os.environ.get("ENV", "dev"),
    )
```

**Prometheus auto-instrumentation (FastAPI):**
```python
from prometheus_fastapi_instrumentator import (
    Instrumentator,
)

# Auto-instruments all routes with latency + count
instrumentator = Instrumentator(
    should_group_status_codes=True,
    should_ignore_untemplated=True,
    excluded_handlers=["/health", "/ready", "/metrics"],
)
instrumentator.instrument(app).expose(app, endpoint="/metrics")
```

**OpenTelemetry auto-instrumentation:**
```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
)
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.fastapi import (
    FastAPIInstrumentor,
)
from opentelemetry.instrumentation.httpx import (
    HTTPXClientInstrumentor,
)

resource = Resource.create({
    "service.name": "my-service",
    "service.version": "1.0.0",
})
provider = TracerProvider(resource=resource)
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter())
)
trace.set_tracer_provider(provider)

FastAPIInstrumentor.instrument_app(app)
HTTPXClientInstrumentor().instrument()
```

**React Error Boundary:**
```tsx
import { Component, type ReactNode } from 'react';

interface Props { children: ReactNode; }
interface State { error: Error | null; }

export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error) {
    return { error };
  }

  componentDidCatch(error: Error) {
    console.error('[ErrorBoundary]', error);
  }

  render() {
    if (this.state.error) {
      return (
        <div className="bt-empty">
          <h2 className="bt-empty-title">
            Something went wrong
          </h2>
          <p className="bt-empty-description">
            {this.state.error.message}
          </p>
          <button
            className="bt-btn bt-btn-primary"
            onClick={() => this.setState({ error: null })}
          >
            Try Again
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
```

**Healthcare FHIR transaction monitoring:**
```python
from prometheus_client import (
    Counter, Histogram, Gauge,
)

FHIR_LATENCY = Histogram(
    "fhir_request_duration_seconds",
    "FHIR API request latency",
    ["operation", "resource_type"],
    buckets=[0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 10.0],
)
FHIR_ERRORS = Counter(
    "fhir_errors_total",
    "Failed FHIR transactions",
    ["operation", "resource_type", "error_type"],
)
HL7_THROUGHPUT = Counter(
    "hl7_messages_total",
    "HL7 messages processed",
    ["message_type", "status"],
)
PATIENT_REG_FAILURES = Counter(
    "patient_registration_failures_total",
    "Failed patient registration transactions",
    ["failure_reason"],
)
```

**AI inference monitoring:**
```python
from prometheus_client import (
    Counter, Histogram, Gauge, Info,
)

MODEL_INFO = Info(
    "ai_model",
    "Current model metadata",
)
MODEL_INFO.info({
    "version": "v3.2",
    "framework": "pytorch",
    "training_date": "2025-12-01",
})

INFERENCE_LATENCY = Histogram(
    "ai_inference_duration_seconds",
    "Model inference latency",
    ["model_name", "model_version"],
)
INFERENCE_TOKENS = Counter(
    "ai_tokens_total",
    "Total tokens consumed",
    ["model_name", "direction"],  # input/output
)
PREDICTION_CONFIDENCE = Histogram(
    "ai_prediction_confidence",
    "Distribution of prediction confidence scores",
    ["model_name"],
    buckets=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
)
```

**Typed config with env_prefix (pydantic-settings):**
```python
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # env_prefix isolates this app from any host-level
    # DATABASE_URL / SECRET_KEY that would otherwise leak in
    model_config = SettingsConfigDict(
        env_prefix="SYMPHONIX_EPS_IG_",
        env_file=".env",
        extra="ignore",
    )

    database_url: str = "sqlite+aiosqlite:///./data/app.db"
    jwt_secret: str = "dev-only-change-me"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60 * 24
    debug: bool = False
    log_level: str = "info"
    allowed_origins: list[str] = ["http://localhost:5173"]


settings = Settings()

```

**.env.example:**
```bash
# Copy to .env and fill in.
# All vars are prefixed with SYMPHONIX_EPS_IG_ to avoid host-env collisions.
SYMPHONIX_EPS_IG_DATABASE_URL=sqlite+aiosqlite:///./data/app.db
SYMPHONIX_EPS_IG_JWT_SECRET=change-me-in-prod
SYMPHONIX_EPS_IG_DEBUG=false
SYMPHONIX_EPS_IG_LOG_LEVEL=info
SYMPHONIX_EPS_IG_ALLOWED_ORIGINS=http://localhost:5173

```

**ruff.toml (Python linter):**
```toml
[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = [
  "E",    # pycodestyle errors
  "F",    # pyflakes
  "W",    # pycodestyle warnings
  "I",    # isort
  "N",    # pep8-naming
  "UP",   # pyupgrade
  "B",    # bugbear
  "SIM",  # simplify
  "S",    # bandit (security)
]
```

**tsconfig.json (strict mode):**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
```

**Pre-commit hooks (package.json):**
```json
{
  "scripts": {
    "prepare": "husky",
    "lint": "eslint src/ --fix",
    "format": "prettier --write src/"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,css,md}": ["prettier --write"]
  }
}
```

### Infrastructure Available

- **redis**: Caching frequently accessed data or distributed session/rate limiting
- **kafka**: Durable event streaming across services
- **file_storage**: Object storage for user uploads and generated files
- **websocket**: Two-way real-time communication
