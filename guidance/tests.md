## Task: Test Suite

JUnit 5 tests: @SpringBootTest for integration, @WebMvcTest for controller, repository tests.

### Requirements

- **FR-004**: Automated test suite
  - FR004-AC01 [Positive] GIVEN the test suite, WHEN mvn test runs, THEN all tests pass

### Pattern Rules (MUST follow)

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

**Frontend:**
- MUST import the design system CSS in main.tsx: import './styles/design-system.css'
- MUST add className='bt-app' to the root element
- MUST use .bt-shell layout for dashboard apps: sidebar + header + main grid
- React Query for server state, local state for UI-only state
- Typed API client with fetch wrapper returning typed responses
- React Router with Layout component wrapping Outlet
- Status badges: use .bt-badge-* classes with .bt-badge-dot for entity states
- Forms: .bt-field > .bt-label + .bt-input + .bt-error-text, validate before submit
- Tables: .bt-table with .bt-table-empty for zero items, never show blank screens
- Every authenticated *Page.tsx component must call at least one API hook and render data conditionally (isLoading/error/empty/populated). Hardcoded empty states with no data fetch are unfinished scaffolds.
- Loading: show .bt-spinner during fetches, .bt-skeleton for content placeholders
- Empty states: .bt-empty with icon + title + description + CTA button
- Modals: .bt-modal-backdrop > .bt-modal with header/body/footer sections
- Toasts: .bt-toast-container fixed top-right, .bt-toast-success/-error for feedback
- Vite dev server proxies /api/* to backend
- Vite config MUST set server.host='0.0.0.0' (or '127.0.0.1') AND server.strictPort=true so the dev server binds to IPv4 and FAILS LOUDLY on port collision instead of silently falling back. Harness hardcoding :5173 depends on this.
- Accessibility: semantic HTML, ARIA labels on interactive elements
- Copy design-system.css to frontend/src/styles/ during project setup
- Icons: install lucide-react (npm i lucide-react), use .bt-icon class for consistent sizing
- Public pages: use .bt-site + .bt-hero + .bt-features + .bt-cta + .bt-footer for marketing/landing pages
- Backgrounds: use .bt-bg-gradient-* or .bt-bg-dots for decorative surfaces, never plain white heroes
- Images: use .bt-screenshot for app previews, .bt-img-placeholder for missing images, .bt-hero-image for hero screenshots

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

**Project setup (design system integration):**
```bash
# In the frontend directory:
# 1. Copy design-system.css to src/styles/
mkdir -p src/styles
# (CAID provides the CSS file)

# 2. In src/main.tsx, import the design system:
# import './styles/design-system.css';

# 3. In index.html, add class to body:
# <body class="bt-app">
```

**App shell with sidebar navigation:**
```tsx
import { Outlet, NavLink } from 'react-router-dom';

export function Layout() {
  return (
    <div className="bt-shell">
      <aside className="bt-sidebar">
        <div className="bt-sidebar-brand">
          AppName
        </div>
        <div className="bt-sidebar-section">
          Main
        </div>
        <nav className="bt-nav">
          <NavLink to="/"
            className={({ isActive }) =>
              `bt-nav-item ${isActive ? 'bt-nav-item-active' : ''}`
            }>
            Dashboard
          </NavLink>
          <NavLink to="/items"
            className={({ isActive }) =>
              `bt-nav-item ${isActive ? 'bt-nav-item-active' : ''}`
            }>
            Items
          </NavLink>
        </nav>
      </aside>
      <header className="bt-header">
        <h1 className="bt-header-title">Dashboard</h1>
        <div className="bt-header-actions">
          <button className="bt-btn bt-btn-primary">
            + New
          </button>
        </div>
      </header>
      <main className="bt-main">
        <Outlet />
      </main>
    </div>
  );
}
```

**API hook pattern:**
```typescript
export function useTasks() {
  return useQuery({
    queryKey: ['tasks'],
    queryFn: tasksApi.list,
  });
}

export function useCreateTask() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: tasksApi.create,
    onSuccess: () => qc.invalidateQueries({
      queryKey: ['tasks'],
    }),
  });
}
```

**Typed API client:**
```typescript
const BASE = '/api';

export async function api<T>(
  path: string,
  options?: RequestInit,
): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.detail || res.statusText);
  }
  if (res.status === 204) return undefined as T;
  return res.json();
}
```

**Dashboard page with KPIs and table:**
```tsx
export function DashboardPage() {
  const { data, isLoading } = useTasks();

  if (isLoading) {
    return (
      <div className="bt-loading-page">
        <div className="bt-spinner bt-spinner-lg" />
        Loading...
      </div>
    );
  }

  return (
    <div className="bt-stack bt-stack-6">
      <div className="bt-page-header">
        <h2 className="bt-h2">Dashboard</h2>
        <button className="bt-btn bt-btn-primary">
          + Create
        </button>
      </div>
      <div className="bt-grid bt-grid-4">
        <KpiCard label="Total" value={data.total} />
        <KpiCard label="Active" value={data.active} />
        <KpiCard label="Pending" value={data.pending} />
        <KpiCard label="Done" value={data.done} />
      </div>
      <div className="bt-card">
        <ItemsTable items={data.items} />
      </div>
    </div>
  );
}
```

**Icon system setup (Lucide React):**
```bash
# Install icon library
npm install lucide-react

# Usage in components:
# import { Calendar, Users, Settings } from 'lucide-react';
# <Calendar className="bt-icon" />
# <Users className="bt-icon bt-icon-muted" />
# <Settings className="bt-icon-sm" />
```

**Sidebar navigation with icons:**
```tsx
import {
  LayoutDashboard, Calendar, Users,
  BarChart3, Settings,
} from 'lucide-react';

const NAV = [
  { to: '/', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/items', icon: Calendar, label: 'Items' },
  { to: '/people', icon: Users, label: 'People' },
  { to: '/reports', icon: BarChart3, label: 'Reports' },
  { to: '/settings', icon: Settings, label: 'Settings' },
];

export function SidebarNav() {
  return (
    <nav className="bt-nav">
      {NAV.map(({ to, icon: Icon, label }) => (
        <NavLink
          key={to}
          to={to}
          className={({ isActive }) =>
            `bt-nav-item ${isActive ? 'bt-nav-item-active' : ''}`
          }
        >
          <Icon className="bt-nav-item-icon" />
          {label}
        </NavLink>
      ))}
    </nav>
  );
}
```

**Landing page with hero:**
```tsx
export function LandingPage() {
  return (
    <div className="bt-site">
      {/* Navigation */}
      <nav className="bt-topbar">
        <a href="/" className="bt-topbar-brand">
          AppName
        </a>
        <div className="bt-topbar-nav">
          <a href="#features" className="bt-topbar-link">
            Features
          </a>
          <a href="#pricing" className="bt-topbar-link">
            Pricing
          </a>
          <a href="/login"
             className="bt-btn bt-btn-primary bt-btn-sm">
            Get Started
          </a>
        </div>
      </nav>

      {/* Hero */}
      <section className="bt-hero bt-bg-gradient-mesh">
        <span className="bt-hero-badge">
          New: v2.0 released
        </span>
        <h1 className="bt-hero-title">
          The fastest way to manage your workflow
        </h1>
        <p className="bt-hero-subtitle">
          Streamline operations with AI-powered automation.
          Built for teams that move fast.
        </p>
        <div className="bt-hero-actions">
          <a href="/signup"
             className="bt-btn bt-btn-primary bt-btn-lg">
            Start Free Trial
          </a>
          <a href="#demo"
             className="bt-btn bt-btn-secondary bt-btn-lg">
            Watch Demo
          </a>
        </div>
        <div className="bt-hero-image">
          <div className="bt-screenshot">
            <div className="bt-screenshot-bar">
              <span className="bt-screenshot-dot" />
              <span className="bt-screenshot-dot" />
              <span className="bt-screenshot-dot" />
            </div>
            <div className="bt-img-placeholder bt-aspect-video">
              App Screenshot
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="bt-features">
        <Feature
          icon={<Zap className="bt-icon" />}
          title="Lightning Fast"
          description="Optimized for speed at every layer."
        />
        <Feature
          icon={<Shield className="bt-icon" />}
          title="Enterprise Security"
          description="SOC 2 compliant with encryption."
        />
        <Feature
          icon={<BarChart3 className="bt-icon" />}
          title="Real-time Analytics"
          description="Dashboards that update in real time."
        />
      </section>

      {/* CTA */}
      <section className="bt-cta bt-bg-gradient-primary">
        <h2 className="bt-cta-title">
          Ready to get started?
        </h2>
        <p className="bt-cta-subtitle">
          Join thousands of teams already using AppName.
        </p>
        <a href="/signup"
           className="bt-btn bt-btn-lg"
           style={{ background: 'white', color: '#1a73e8' }}>
          Start Free Trial
        </a>
      </section>

      {/* Footer */}
      <footer className="bt-footer">
        <div className="bt-footer-grid">
          <div>
            <div className="bt-footer-brand">AppName</div>
            <p className="bt-footer-blurb">
              The modern platform for workflow management.
            </p>
          </div>
          <div>
            <div className="bt-footer-heading">Product</div>
            <ul className="bt-footer-links">
              <li><a href="#features">Features</a></li>
              <li><a href="#pricing">Pricing</a></li>
              <li><a href="/docs">Documentation</a></li>
            </ul>
          </div>
          <div>
            <div className="bt-footer-heading">Company</div>
            <ul className="bt-footer-links">
              <li><a href="/about">About</a></li>
              <li><a href="/blog">Blog</a></li>
              <li><a href="/careers">Careers</a></li>
            </ul>
          </div>
          <div>
            <div className="bt-footer-heading">Legal</div>
            <ul className="bt-footer-links">
              <li><a href="/privacy">Privacy</a></li>
              <li><a href="/terms">Terms</a></li>
            </ul>
          </div>
        </div>
        <div className="bt-footer-bottom">
          <span>&copy; 2026 AppName. All rights reserved.</span>
        </div>
      </footer>
    </div>
  );
}

function Feature({
  icon, title, description
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
}) {
  return (
    <div className="bt-feature">
      <div className="bt-feature-icon">{icon}</div>
      <h3 className="bt-feature-title">{title}</h3>
      <p className="bt-feature-description">
        {description}
      </p>
    </div>
  );
}
```

**Pricing section:**
```tsx
export function PricingSection() {
  return (
    <section id="pricing" className="bt-site-section">
      <h2 className="bt-h2"
          style={{ textAlign: 'center', marginBottom: '3rem' }}>
        Simple, transparent pricing
      </h2>
      <div className="bt-pricing-grid">
        <div className="bt-pricing-card">
          <div className="bt-pricing-name">Starter</div>
          <div className="bt-pricing-price">
            $0<span>/month</span>
          </div>
          <p className="bt-pricing-description">
            Perfect for trying things out.
          </p>
          <ul className="bt-pricing-features">
            <li>Up to 3 projects</li>
            <li>Basic analytics</li>
            <li>Community support</li>
          </ul>
          <button className="bt-btn bt-btn-secondary"
                  style={{ marginTop: 'auto' }}>
            Get Started
          </button>
        </div>
        <div className="bt-pricing-card bt-pricing-card-featured">
          <div className="bt-pricing-name">Pro</div>
          <div className="bt-pricing-price">
            $29<span>/month</span>
          </div>
          <p className="bt-pricing-description">
            For growing teams.
          </p>
          <ul className="bt-pricing-features">
            <li>Unlimited projects</li>
            <li>Advanced analytics</li>
            <li>Priority support</li>
            <li>Custom integrations</li>
          </ul>
          <button className="bt-btn bt-btn-primary"
                  style={{ marginTop: 'auto' }}>
            Start Free Trial
          </button>
        </div>
      </div>
    </section>
  );
}
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

## Design System Component Reference

### How to Use
1. Add `import './styles/design-system.css'` in your `main.tsx`
2. Add `class="bt-app"` to your `<body>` tag
3. Use `.bt-*` classes below for all UI components

### Dashboard Shell
- `.bt-shell` — Grid layout: sidebar + header + main
- `.bt-header` — Top bar with `.bt-header-title` + `.bt-header-actions`
- `.bt-sidebar` — Left nav with `.bt-sidebar-brand` + `.bt-sidebar-section`
- `.bt-main` — Content area (auto-scrolling, max-width constrained)
- `.bt-page-header` — Page title row with action buttons

### Navigation
- `.bt-nav` — Vertical nav container
- `.bt-nav-item` — Nav link (add `.bt-nav-item-active` for current page)
- `.bt-nav-item-icon` — Icon inside nav item
- `.bt-nav-badge` — Notification count badge in nav
- `.bt-breadcrumb` — Breadcrumb trail with `.bt-breadcrumb-item` + `.bt-breadcrumb-sep` + `.bt-breadcrumb-current`

### Cards
- `.bt-card` — Standard card (hover shadow)
- `.bt-card-flat` — No shadow
- `.bt-card-elevated` — Prominent shadow
- `.bt-card-subtle` — Muted background
- `.bt-card-inset` — Inset shadow
- `.bt-card-info / -success / -warning / -error` — State-tinted
- `.bt-card-header / -title / -description / -footer` — Card structure
- `.bt-kpi` — KPI stat card with `.bt-kpi-label` + `.bt-kpi-value` + `.bt-kpi-change`

### Badges
- `.bt-badge` — Base badge (pill shape)
- `.bt-badge-success / -error / -warning / -info / -default / -primary / -outline`
- `.bt-badge-dot` — Color dot indicator inside badge

### Buttons
- `.bt-btn` — Base button
- `.bt-btn-primary / -secondary / -danger / -success / -ghost / -link`
- `.bt-btn-xs / -sm / -lg` — Sizes
- `.bt-btn-icon` — Square icon button
- `.bt-btn-group` — Grouped buttons (shared borders)

### Forms
- `.bt-field` — Field wrapper (label + input + hint)
- `.bt-label` — Label (add `.bt-label-required` for asterisk)
- `.bt-input` — Text input (add `.bt-input-error` for error state)
- `.bt-input-sm` — Small input
- `.bt-textarea` — Multi-line input
- `.bt-select` — Dropdown select
- `.bt-checkbox / .bt-radio` — Checkbox/radio with label
- `.bt-toggle` — Toggle switch
- `.bt-hint` — Help text below field
- `.bt-error-text` — Error message below field
- `.bt-form-row` — Responsive grid row for form fields
- `.bt-form-actions` — Right-aligned button row

### Tables
- `.bt-table` — Full-width table with header/body/hover
- `.bt-table-compact` — Denser padding
- `.bt-table-sortable` — Sortable column header
- `.bt-table-empty` — Empty state placeholder

### Tabs
- `.bt-tabs` — Tab bar container
- `.bt-tab` — Individual tab (add `.bt-tab-active`)
- `.bt-tab-panel` — Content panel below tabs

### Modal / Dialog
- `.bt-modal-backdrop` — Overlay + centering
- `.bt-modal` — Modal container (add `.bt-modal-lg` or `.bt-modal-xl`)
- `.bt-modal-header / -title / -body / -footer`

### Dropdown
- `.bt-dropdown` — Wrapper (position: relative)
- `.bt-dropdown-menu` — Menu panel (add `.bt-dropdown-menu-right`)
- `.bt-dropdown-item` — Menu item (add `.bt-dropdown-item-danger`)
- `.bt-dropdown-divider` — Separator line

### Toast / Notification
- `.bt-toast-container` — Fixed position container (top-right)
- `.bt-toast` — Toast item (add `.bt-toast-success / -error / -warning / -info`)
- `.bt-toast-title / -message`

### Loading States
- `.bt-spinner` — Rotating spinner (`.bt-spinner-sm / -lg`)
- `.bt-skeleton` — Shimmer placeholder
- `.bt-skeleton-text / -heading / -avatar / -card`
- `.bt-loading-page` — Full-page loading state

### Alerts
- `.bt-alert` — Alert banner
- `.bt-alert-info / -success / -warning / -error`

### Avatar
- `.bt-avatar` — Circle avatar (`.bt-avatar-sm / -lg`)
- `.bt-avatar-group` — Overlapping avatar stack

### Pagination
- `.bt-pagination` — Pagination container
- `.bt-page-btn` — Page button (add `.bt-page-btn-active`)

### Empty State
- `.bt-empty` — Centered empty state
- `.bt-empty-icon / -title / -description`

### Typography
- `.bt-h1 / .bt-h2 / .bt-h3 / .bt-h4` — Headings
- `.bt-text / .bt-text-secondary / .bt-text-muted / .bt-text-xs`
- `.bt-code` — Inline code
- `.bt-link` — Styled link

### Layout Utilities
- `.bt-stack` + `.bt-stack-2 / -4 / -6 / -8` — Vertical flex with gap
- `.bt-row` + `.bt-row-between / .bt-row-2 / -3 / -4` — Horizontal flex
- `.bt-grid` + `.bt-grid-2 / -3 / -4` — Responsive grid
- `.bt-divider` — Horizontal rule (`.bt-divider-strong`)

### Icons (Lucide React)
Install: `npm i lucide-react`
- `.bt-icon` — Standard icon size (20px)
- `.bt-icon-sm / -lg / -xl` — Size variants
- `.bt-icon-muted / -primary / -success / -error / -warning` — Color variants
- Usage: `import { Calendar } from 'lucide-react'; <Calendar className="bt-icon" />`

### Backgrounds & Decorative Surfaces
- `.bt-bg-gradient-primary` — Brand gradient (great for CTAs)
- `.bt-bg-gradient-dark` — Dark gradient (hero sections)
- `.bt-bg-gradient-warm / -cool` — Subtle tinted gradients
- `.bt-bg-gradient-mesh` — Multi-point radial gradient
- `.bt-bg-dots` — Dot pattern overlay
- `.bt-bg-grid` — Grid pattern overlay
- `.bt-bg-noise` — Subtle noise texture
- `.bt-section-muted / -surface / -dark` — Section backgrounds

### Public Website / Landing Page
- `.bt-site` — Public page container
- `.bt-site-section` — Max-width centered section
- `.bt-topbar` — Public navigation bar
- `.bt-topbar-brand / -nav / -link` — Topbar elements
- `.bt-hero` — Centered hero section
- `.bt-hero-badge / -title / -subtitle / -actions / -image`
- `.bt-features` — Auto-fit features grid
- `.bt-feature / -icon / -title / -description`
- `.bt-testimonial / -quote / -author` — Testimonial block
- `.bt-logos` — Grayscale logo cloud
- `.bt-cta / -title / -subtitle` — Call-to-action banner
- `.bt-pricing-grid / .bt-pricing-card / -featured` — Pricing cards
- `.bt-pricing-name / -price / -description / -features`
- `.bt-footer / -grid / -brand / -blurb / -heading / -links / -bottom`

### Imagery
- `.bt-img-placeholder` — Dashed border placeholder for missing images
- `.bt-img-cover / -contain` — Object-fit utilities
- `.bt-aspect-video / -square / -4-3` — Aspect ratio locks
- `.bt-figure / .bt-figure-caption` — Image with caption
- `.bt-screenshot` — App preview frame with browser dots
- `.bt-screenshot-bar / -dot` — Browser chrome decoration
- `.bt-hero-image` — Rounded + shadowed hero screenshot

### Dark Mode
Automatic via `prefers-color-scheme: dark`. All CSS variables swap.
No code changes needed — just use the design system classes.


### Design System CSS

The design system CSS file will be placed at `src/styles/design-system.css` during project setup. Import it in your `main.tsx`:

```typescript
import './styles/design-system.css';
```


## Domain-Matched Visual Design

Auto-detected domain: **healthcare**

### Design Theme: Healthcare
Clinical, accessible, HIPAA-aware. Calm blue palette with clear status indicators. Prioritizes readability and error prevention over visual flair.

**Base theme:** clinical

**Entity State Colors:**
Use these badge classes for entity states:
```typescript
export const STATE_COLORS: Record<string, { bg: string; text: string; badge: string; label: string }> = {
  scheduled: { bg: '#dbeafe', text: '#1d4ed8', badge: 'bt-badge-info', label: 'Scheduled' },
  checked_in: { bg: '#fef9c3', text: '#a16207', badge: 'bt-badge-warning', label: 'Checked In' },
  in_progress: { bg: '#dbeafe', text: '#2563eb', badge: 'bt-badge-info', label: 'In Progress' },
  completed: { bg: '#dcfce7', text: '#16a34a', badge: 'bt-badge-success', label: 'Completed' },
  cancelled: { bg: '#f1f5f9', text: '#64748b', badge: 'bt-badge-default', label: 'Cancelled' },
  no_show: { bg: '#fee2e2', text: '#dc2626', badge: 'bt-badge-error', label: 'No Show' },
};
```

**Recommended Navigation:**
```typescript
export const NAV_ITEMS = [
  { label: 'Dashboard', icon: 'layout-dashboard', route: '/' },
  { label: 'Appointments', icon: 'calendar', route: '/appointments' },
  { label: 'Patients', icon: 'users', route: '/patients' },
  { label: 'Providers', icon: 'stethoscope', route: '/providers' },
  { label: 'Schedule', icon: 'clock', route: '/schedule' },
  { label: 'Reports', icon: 'bar-chart-3', route: '/reports' },
  { label: 'Settings', icon: 'settings', route: '/settings' },
];
```

**Dashboard Sections:**
- KPI row: Today's appointments, Checked-in, Waiting, Completed
- Upcoming appointments table with status badges
- Provider availability sidebar
- Recent activity feed

**KPI Cards (top of dashboard):**
- **Today's Appointments**: Total scheduled for today
- **Checked In**: Patients currently checked in
- **Avg Wait Time**: Minutes from check-in to seen
- **Completion Rate**: Completed vs scheduled today

**Terminology:**
- user -> patient
- item -> appointment
- status -> appointment status
- admin -> provider
- create -> book appointment
- delete -> cancel appointment
- list -> schedule view

**CSS Overrides (add to design-system.css):**
```css
:root {
  --sg-primary: #0369a1;
  --sg-primary-hover: #075985;
  --sg-primary-subtle: #e0f2fe;
}
```

## Background Recipe

```css
/* Healthcare background recipe */
body.bt-app {
  background: linear-gradient(160deg, #f0f4f5 0%, #e8edf0 100%);
}
@media (prefers-color-scheme: dark) {
  body.bt-app {
    background: linear-gradient(160deg, #0f1a20 0%, #162028 100%);
  }
}
[data-theme='dark'] body.bt-app,
body.bt-app[data-theme='dark'] {
  background: linear-gradient(160deg, #0f1a20 0%, #162028 100%);
}
:root { --sg-surface: #ffffff; }
@media (prefers-color-scheme: dark) {
  :root { --sg-surface: #1a2632; }
}
```


## MANDATORY: Theme Application (lesson #76)

You MUST create a `src/styles/app.css` file that:
1. Overrides `--sg-primary` with the domain colour (#0369a1)
2. Overrides `--sg-primary-hover` (#075985)
3. Overrides `--sg-primary-subtle` (#e0f2fe)
4. Imports AFTER design-system.css in main.tsx
5. Includes responsive breakpoints for 1280/768/375px
6. Includes auth page, kanban grid, toast animation styles

The design-system.css provides the clinical base. YOUR app.css
applies the domain theme on top. Without app.css the app will
have plain backgrounds and wrong colours (lesson #76).

7. NEVER hardcode hex colours (#ffffff, #f8f9fa etc) in component CSS.
   Always use var(--sg-surface), var(--sg-bg), var(--sg-text) etc.
   Hardcoded colours break dark mode and high-contrast mode (L-087).
8. The API client fetch wrapper MUST intercept 401 responses,
   call localStorage.removeItem('access_token'), and redirect
   to /login. Stale JWTs from previous server instances cause
   'invalid token' errors forever otherwise (L-084).
9. React Query hooks MUST set enabled: !!token (disabled when
   unauthenticated) so the dashboard doesn't fire API calls
   before auth is confirmed. Without this, unauthenticated
   users see 'failed to load' errors (L-082).
