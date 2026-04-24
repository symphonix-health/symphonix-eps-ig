## Task: Spring Boot Project Foundation

Set up Spring Boot: pom.xml/build.gradle, application.yml, main class, directory structure.

### Requirements

- **FR-001**: Spring Boot project skeleton
  - FR001-AC01 [Positive] GIVEN a new project directory, WHEN mvn compile runs, THEN project compiles

### Pattern Rules (MUST follow)

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
