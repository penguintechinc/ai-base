# AI-Base - Claude Code Context

## Project Overview

AI-Base is a comprehensive multi-language AI infrastructure template incorporating best practices and patterns from Penguin Tech Inc. It provides a production-ready foundation for building AI-powered applications with Go, Python, and Node.js components, including CI/CD pipelines, security scanning, and integrated licensing.

**Key Features:**
- Multi-language support (Go 1.23.x, Python 3.12/3.13, Node.js 18+)
- AI inference service integration (separate container)
- Multi-language security scanning (gosec, bandit, npm audit)
- Version detection and automatic release management
- Epoch64 timestamp-based build tracking
- Multi-platform Docker builds (amd64/arm64)
- Enterprise security and licensing integration
- Comprehensive CI/CD pipeline with parallel execution
- Production-ready containerization
- Monitoring and observability
- Version management system
- PenguinTech License Server integration

## Technology Stack

### Languages & Frameworks

**Language Selection Criteria (Case-by-Case Basis):**
- **Python 3.13**: Default choice for most applications
  - Web applications and APIs
  - Business logic and data processing
  - Integration services and connectors
- **Go 1.23.x**: ONLY for high-traffic/performance-critical applications
  - Applications handling >10K requests/second
  - Network-intensive services
  - Low-latency requirements (<10ms)
  - CPU-bound operations requiring maximum throughput

**Python Stack:**
- **Python**: 3.13 for all applications (3.12+ minimum)
- **Web Framework**: Flask + Flask-Security-Too (mandatory)
- **Database**: SQLAlchemy (initialization), PyDAL (day-to-day operations)
- **Performance**: Dataclasses with slots, type hints, async/await required

**Frontend Stack:**
- **React**: ReactJS for all frontend applications
- **Node.js**: 18+ for build tooling and React development
- **JavaScript/TypeScript**: Modern ES2022+ standards

**Go Stack (When Required):**
- **Go**: 1.23.x (latest patch version)
- **Database**: Use DAL with PostgreSQL/MySQL cross-support (e.g., GORM, sqlx)
- Use only for traffic-intensive applications

### Infrastructure & DevOps
- **Containers**: Docker with multi-stage builds, Docker Compose
- **Orchestration**: Kubernetes with Helm charts
- **Configuration Management**: Ansible for infrastructure automation
- **CI/CD**: GitHub Actions with comprehensive pipelines
- **Monitoring**: Prometheus metrics, Grafana dashboards
- **Logging**: Structured logging with configurable levels

### Databases & Storage

**Hybrid Database Architecture**:
- **Initialization Phase**: SQLAlchemy for schema setup, migrations, and initialization
  - Use SQLAlchemy declarative ORM for schema definition
  - Run Alembic migrations for database initialization
  - Benefit: Full SQL DDL control, version management
- **Day-to-Day Operations**: PyDAL for runtime operations and queries
  - All CRUD operations use PyDAL for multi-database compatibility
  - Thread-safe connections with thread-local storage
  - Consistent API across supported databases
  - Connection pooling and retry logic built-in

**Primary Database**: PostgreSQL (default, configurable via `DB_TYPE` environment variable)

**Cache**: Redis/Valkey with optional TLS and authentication

**Database Abstraction Layers (DALs)**:
- **Python**:
  - **SQLAlchemy** (initialization and schema management)
  - **PyDAL** (mandatory for ALL day-to-day operations)
    - Must support ONLY postgres, mysql, sqlite (DB_TYPE restricted to these three)
    - Special support for MariaDB Galera cluster requirements
    - `DB_TYPE` must match PyDAL connection string prefixes exactly
- **Go**: GORM or sqlx (mandatory for cross-database support)
  - Must support PostgreSQL and MySQL/MariaDB
  - Stable, well-maintained library required

**Migrations**: Automated schema management via Alembic (SQLAlchemy)

**Database Support**: Design for postgres, mysql, sqlite from the start

**MariaDB Galera Support**: Handle Galera-specific requirements
  - WSREP consistency (wsrep_sync_wait=1)
  - Auto-increment configuration
  - Transaction isolation
  - Load balancing across cluster nodes
  - Connection-level settings for read-your-writes guarantees

**Supported DB_TYPE Values (Production-Only)**:
- `postgres` - PostgreSQL (default, recommended for most use cases)
- `mysql` - MySQL/MariaDB (including Galera clusters)
- `sqlite` - SQLite (development and lightweight deployments only)

### Security & Authentication
- **Flask-Security-Too**: Mandatory for all Flask applications
  - Role-based access control (RBAC)
  - User authentication and session management
  - Password hashing with bcrypt
  - Email confirmation and password reset
  - Two-factor authentication (2FA)
- **TLS**: Enforce TLS 1.2 minimum, prefer TLS 1.3
- **HTTP3/QUIC**: Utilize UDP with TLS for high-performance connections where possible
- **Authentication**: JWT and MFA (standard), mTLS where applicable
- **SSO**: SAML/OAuth2 SSO as enterprise-only features
- **Secrets**: Environment variable management
- **Scanning**: Trivy vulnerability scanning, CodeQL analysis
- **Code Quality**: All code must pass CodeQL security analysis

## PenguinTech License Server Integration

All projects integrate with the centralized PenguinTech License Server at `https://license.penguintech.io` for feature gating and enterprise functionality.

**IMPORTANT: License enforcement is ONLY enabled when project is marked as release-ready**
- Development phase: All features available, no license checks
- Release phase: License validation required, feature gating active

**License Key Format**: `PENG-XXXX-XXXX-XXXX-XXXX-ABCD`

**Core Endpoints**:
- `POST /api/v2/validate` - Validate license
- `POST /api/v2/features` - Check feature entitlements
- `POST /api/v2/keepalive` - Report usage statistics

**Environment Variables**:
```bash
# License configuration
LICENSE_KEY=PENG-XXXX-XXXX-XXXX-XXXX-ABCD
LICENSE_SERVER_URL=https://license.penguintech.io
PRODUCT_NAME=ai-base

# Release mode (enables license enforcement)
RELEASE_MODE=false  # Development (default)
RELEASE_MODE=true   # Production (explicitly set)
```

📚 **Detailed Documentation**: [License Server Integration Guide](docs/licensing/license-server-integration.md)

## WaddleAI Integration (Optional)

For AI-Base, WaddleAI is located at `~/code/WaddleAI` and provides optional AI inference capabilities.

**When to Use WaddleAI:**
- Natural language processing (NLP)
- Machine learning model inference
- AI-powered features and automation
- Intelligent data analysis
- Chatbots and conversational interfaces

**Integration Pattern:**
- WaddleAI runs as separate microservice container
- Communicate via REST API or gRPC
- Environment variable configuration for API endpoints
- License-gate AI features as enterprise functionality

📚 **WaddleAI Documentation**: See WaddleAI project at `~/code/WaddleAI` for integration details

## Project Structure

```
ai-base/
├── .github/             # CI/CD pipelines and templates
│   └── workflows/       # GitHub Actions for each service
├── services/            # Microservices (separate containers by default)
│   ├── api/             # Flask + Flask-Security-Too backend
│   ├── webui/           # Node.js + React frontend shell
│   ├── inference/       # AI inference service (optional)
│   └── connector/       # Integration services (placeholder)
├── shared/              # Shared libraries (py_libs, go_libs, node_libs)
│   ├── py_libs/         # Python shared library (pip installable)
│   ├── go_libs/         # Go shared library (Go module)
│   ├── node_libs/       # TypeScript shared library (npm package)
│   └── README.md        # Shared libraries overview
├── k8s/                 # Kubernetes deployment templates
│   ├── helm/            # Helm v3 charts per service
│   ├── manifests/       # Raw K8s manifests (kubectl apply)
│   └── kustomize/       # Kustomize overlays (dev/staging/prod)
├── infrastructure/      # Infrastructure as code
├── scripts/             # Utility scripts
├── tests/               # Test suites (unit, integration, e2e, performance)
├── docs/                # Documentation
├── config/              # Configuration files
├── docker-compose.yml   # Production environment
├── docker-compose.dev.yml # Local development
├── Makefile             # Build automation
├── .version             # Version tracking
└── CLAUDE.md            # This file
```

## Version Management System

**Format**: `vMajor.Minor.Patch.build`
- **Major**: Breaking changes, API changes, removed features
- **Minor**: Significant new features and functionality additions
- **Patch**: Minor updates, bug fixes, security patches
- **Build**: Epoch64 timestamp of build time

**Update Commands**:
```bash
./scripts/version/update-version.sh          # Increment build timestamp
./scripts/version/update-version.sh patch    # Increment patch version
./scripts/version/update-version.sh minor    # Increment minor version
./scripts/version/update-version.sh major    # Increment major version
```

## Development Workflow

### Local Development Setup
```bash
git clone <repository-url>
cd project-name
make setup                    # Install dependencies
make dev                      # Start development environment
```

### Essential Commands
```bash
# Development
make dev                      # Start development services
make test                     # Run all tests
make lint                     # Run linting
make build                    # Build all services
make clean                    # Clean build artifacts

# Production
make docker-build             # Build containers
make docker-push              # Push to registry
make deploy-dev               # Deploy to development
make deploy-prod              # Deploy to production

# Testing
make test-unit               # Run unit tests
make test-integration        # Run integration tests
make test-e2e                # Run end-to-end tests

# License Management
make license-validate        # Validate license
make license-check-features  # Check available features
```

## Critical Development Rules

### Development Philosophy: Safe, Stable, and Feature-Complete

**NEVER take shortcuts or the "easy route" - ALWAYS prioritize safety, stability, and feature completeness**

#### Core Principles
- **No Quick Fixes**: Resist quick workarounds or partial solutions
- **Complete Features**: Fully implemented with proper error handling and validation
- **Safety First**: Security, data integrity, and fault tolerance are non-negotiable
- **Stable Foundations**: Build on solid, tested components
- **Future-Proof Design**: Consider long-term maintainability and scalability
- **No Technical Debt**: Address issues properly the first time

#### Red Flags (Never Do These)
- Skipping input validation "just this once"
- Hardcoding credentials or configuration
- Ignoring error returns or exceptions
- Commenting out failing tests to make CI pass
- Deploying without proper testing
- Using deprecated or unmaintained dependencies
- Implementing partial features with "TODO" placeholders
- Bypassing security checks for convenience
- Assuming data is valid without verification
- Leaving debug code or backdoors in production

#### Quality Checklist Before Completion
- All error cases handled properly
- Unit tests cover all code paths
- Integration tests verify component interactions
- Security requirements fully implemented
- Performance meets acceptable standards
- Documentation complete and accurate
- Code review standards met
- No hardcoded secrets or credentials
- Logging and monitoring in place
- Build passes in containerized environment
- No security vulnerabilities in dependencies
- Edge cases and boundary conditions tested

### Git Workflow
- **NEVER commit automatically** unless explicitly requested by the user
- **NEVER push to remote repositories** under any circumstances
- **ONLY commit when explicitly asked** - never assume commit permission
- Always use feature branches for development
- Require pull request reviews for main branch
- Automated testing must pass before merge

### Local State Management (Crash Recovery)
- **ALWAYS maintain local .PLAN and .TODO files** for crash recovery
- **Keep .PLAN file updated** with current implementation plans and progress
- **Keep .TODO file updated** with task lists and completion status
- **Update these files in real-time** as work progresses
- **Add to .gitignore**: Both .PLAN and .TODO files must be in .gitignore
- **File format**: Use simple text format for easy recovery
- **Automatic recovery**: Upon restart, check for existing files to resume work

### Dependency Security Requirements
- **ALWAYS check for Dependabot alerts** before every commit
- **Monitor vulnerabilities via Socket.dev** for all dependencies
- **Mandatory security scanning** before any dependency changes
- **Fix all security alerts immediately** - no commits with outstanding vulnerabilities
- **Regular security audits**: `npm audit`, `go mod audit`, `safety check`

### Linting & Code Quality Requirements
- **ALL code must pass linting** before commit - no exceptions
- **Python**: flake8, black, isort, mypy (type checking), bandit (security)
- **JavaScript/TypeScript**: ESLint, Prettier
- **Go**: golangci-lint (includes staticcheck, gosec, etc.)
- **Ansible**: ansible-lint
- **Docker**: hadolint
- **YAML**: yamllint
- **Markdown**: markdownlint
- **Shell**: shellcheck
- **CodeQL**: All code must pass CodeQL security analysis
- **PEP Compliance**: Python code must follow PEP 8, PEP 257 (docstrings), PEP 484 (type hints)

### Pre-Commit Checklist (Complete)
Before submitting ANY code for commit:
- [ ] All tests pass locally (`make test`)
- [ ] All linting checks pass (`make lint`)
- [ ] No security vulnerabilities in dependencies (Dependabot, Socket.dev)
- [ ] Security scanning complete (gosec, bandit, npm audit, CodeQL)
- [ ] Code coverage maintained or improved
- [ ] Documentation updated (inline comments, docstrings, README/CLAUDE.md)
- [ ] No hardcoded secrets, credentials, or API keys
- [ ] No debug code, print statements, or console.log entries
- [ ] Database migrations tested (if applicable)
- [ ] Build succeeds in containerized environment (`docker-compose build`)
- [ ] All type hints present (Python: mypy passes, TypeScript: strict mode)
- [ ] Edge cases and error handling verified
- [ ] License requirements addressed (feature gating if applicable)
- [ ] Performance impact assessed (profiling for critical paths)
- [ ] Backwards compatibility maintained (if modifying public APIs)
- [ ] CHANGELOG/RELEASE_NOTES updated (if applicable)

### Build & Deployment Requirements
- **NEVER mark tasks as completed until successful build verification**
- All Go and Python builds MUST be executed within Docker containers
- Use containerized builds for local development and CI/CD pipelines
- Build failures must be resolved before task completion

### Documentation Standards
- **README.md**: Keep as overview and pointer to comprehensive docs/ folder
- **docs/ folder**: Create comprehensive documentation for all aspects
- **RELEASE_NOTES.md**: Maintain in docs/ folder, prepend new version releases to top
- Update CLAUDE.md when adding significant context
- **Build status badges**: Always include in README.md
- **ASCII art**: Include catchy, project-appropriate ASCII art in README
- **Company homepage**: Point to www.penguintech.io
- **License**: All projects use Limited AGPL3 with preamble for fair use

### File Size Limits
- **Maximum file size**: 25,000 characters for ALL code and markdown files
- **Split large files**: Decompose into modules, libraries, or separate documents
- **CLAUDE.md exception**: Maximum 39,000 characters (only exception to 25K rule)
- **High-level approach**: CLAUDE.md contains high-level context and references detailed docs
- **Documentation strategy**: Create detailed documentation in `docs/` folder and link to them from CLAUDE.md
- **Keep focused**: Critical context, architectural decisions, and workflow instructions only
- **User approval required**: ALWAYS ask user permission before splitting CLAUDE.md files
- **Use Task Agents**: Utilize task agents (subagents) to be more expedient and efficient when making changes to large files, updating or reviewing multiple files, or performing complex multi-step operations
- **Avoid sed/cat**: Use sed and cat commands only when necessary; prefer dedicated Read/Edit/Write tools for file operations

## Development Standards

### Quick Reference

**Database Standards**:
- PyDAL mandatory for ALL Python applications
- Thread-safe usage with thread-local connections
- Environment variable configuration for all database settings
- Connection pooling and retry logic required

**Protocol Support**:
- REST API, gRPC, HTTP/1.1, HTTP/2, HTTP/3 support
- Environment variables for protocol configuration
- Multi-protocol implementation required

**Performance Optimization (Python):**
- Dataclasses with slots mandatory (30-50% memory reduction)
- Type hints required for all Python code
- asyncio for I/O-bound operations
- threading for blocking I/O
- multiprocessing for CPU-bound operations
- Avoid premature optimization - profile first

**High-Performance Networking (Case-by-Case):**
- XDP (eXpress Data Path): Kernel-level packet processing
- AF_XDP: Zero-copy socket for user-space packet processing
- Use only for network-intensive applications requiring >100K packets/sec
- Evaluate Python vs Go based on traffic requirements

**Microservices Architecture**:
- Web UI, API, and Connector as **separate containers by default**
- Single responsibility per service
- API-first design
- Independent deployment and scaling
- Each service has its own Dockerfile and dependencies

**Docker Standards**:
- Multi-arch builds (amd64/arm64)
- Debian-slim base images
- Docker Compose for local development
- Minimal host port exposure

**Testing**:
- Unit tests: Network isolated, mocked dependencies
- Integration tests: Component interactions
- E2E tests: Critical workflows
- Performance tests: Scalability validation

**Security**:
- TLS 1.2+ required
- Input validation mandatory
- JWT, MFA, mTLS standard
- SSO as enterprise feature

## Container Architecture

**ALWAYS use microservices architecture** - decompose into specialized, independently deployable containers:

1. **Web UI Container**: ReactJS frontend (separate container, served via nginx)
2. **Application API Container**: Flask + Flask-Security-Too backend (separate container)
3. **Connector Container**: External system integration (separate container)

**Default Container Separation**: Web UI and API are ALWAYS separate containers by default. This provides:
- Independent scaling of frontend and backend
- Different resource allocation per service
- Separate deployment lifecycles
- Technology-specific optimization

**Container Responsibilities**:
- **API/Backend Container**:
  - Flask application with Flask-Security-Too
  - PyDAL database access and queries
  - Business logic and data processing
  - REST/gRPC endpoints
  - Health checks and metrics
  - License enforcement
  - Exposed ports: Internal only (reverse-proxy via WebUI)

- **WebUI Container**:
  - ReactJS single-page application
  - Nginx reverse proxy for API routing
  - Static asset serving
  - TLS termination
  - CORS header management
  - Exposed ports: 443 (HTTPS), 80 (HTTP redirect)

- **Connector Container** (if required):
  - Third-party integrations
  - External system synchronization
  - Data transformation
  - Retry logic and queuing
  - Separate resource constraints

**Network Architecture**:
- Internal Docker network bridges all containers
- Only WebUI port exposed to external traffic
- API communicates with WebUI via internal DNS
- Database access from API container only
- Connector services communicate via message queues or gRPC

**Benefits**:
- Independent scaling
- Technology diversity
- Team autonomy
- Resilience
- Continuous deployment
- Security isolation

## Application Architecture

**ALWAYS use microservices architecture** - decompose into specialized, independently deployable components using the container architecture defined above.

## Common Integration Patterns

### Flask + Flask-Security-Too + PyDAL
```python
from flask import Flask
from flask_security import Security, SQLAlchemyUserDatastore, auth_required, hash_password
from pydal import DAL, Field
from dataclasses import dataclass
from typing import Optional

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
app.config['SECURITY_PASSWORD_SALT'] = os.getenv('SECURITY_PASSWORD_SALT')

# PyDAL database connection
db = DAL(
    f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}@"
    f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}",
    pool_size=10
)

# Define tables with PyDAL
db.define_table('users',
    Field('email', 'string', requires=IS_EMAIL(), unique=True),
    Field('password', 'string'),
    Field('active', 'boolean', default=True),
    Field('fs_uniquifier', 'string', unique=True),
    migrate=True)

db.define_table('roles',
    Field('name', 'string', unique=True),
    Field('description', 'text'),
    migrate=True)

# Flask-Security-Too setup
from flask_security import Security, PyDALUserDatastore
user_datastore = PyDALUserDatastore(db, db.users, db.roles)
security = Security(app, user_datastore)

@app.route('/api/protected')
@auth_required()
def protected_resource():
    return {'message': 'This is a protected endpoint'}

@app.route('/healthz')
def health():
    return {'status': 'healthy'}, 200
```

### Database Integration (Hybrid SQLAlchemy + PyDAL with Multi-Database Support)
```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from pydal import DAL, Field
from dataclasses import dataclass
import os

# Valid DB_TYPE values - restricted to production databases
VALID_DB_TYPES = {
    'postgres',   # PostgreSQL (recommended)
    'mysql',      # MySQL/MariaDB (including Galera clusters)
    'sqlite'      # SQLite (development/lightweight only)
}

@dataclass(slots=True, frozen=True)
class UserModel:
    """User model with slots for memory efficiency"""
    id: int
    email: str
    name: str
    active: bool

# ============================================================================
# INITIALIZATION PHASE: SQLAlchemy for schema setup and migrations
# ============================================================================
Base = declarative_base()

def init_database():
    """Initialize database using SQLAlchemy (schema creation via Alembic)"""
    db_type = os.getenv('DB_TYPE', 'postgres')

    if db_type not in VALID_DB_TYPES:
        raise ValueError(f"Invalid DB_TYPE: {db_type}. Must be one of: {VALID_DB_TYPES}")

    # Construct SQLAlchemy connection URL
    if db_type == 'postgres':
        db_url = f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}@" \
                 f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    elif db_type == 'mysql':
        db_url = f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}@" \
                 f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    else:  # sqlite
        db_url = f"sqlite:///{os.getenv('DB_PATH', 'app.db')}"

    engine = create_engine(db_url, echo=False, pool_size=10, max_overflow=20)

    # Run Alembic migrations for production-ready schema management
    # alembic upgrade head

    return engine

# ============================================================================
# DAY-TO-DAY OPERATIONS: PyDAL for runtime queries and CRUD operations
# ============================================================================
def get_pydal_connection() -> DAL:
    """Initialize PyDAL for all day-to-day database operations"""
    db_type = os.getenv('DB_TYPE', 'postgres')

    # Input validation - ensure DB_TYPE matches production requirements
    if db_type not in VALID_DB_TYPES:
        raise ValueError(f"Invalid DB_TYPE: {db_type}. Must be one of: {VALID_DB_TYPES}")

    # Build PyDAL connection URI (use PyDAL prefixes)
    db_uri = f"{db_type}://" \
             f"{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}@" \
             f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/" \
             f"{os.getenv('DB_NAME')}"

    # MariaDB Galera specific settings
    galera_mode = os.getenv('GALERA_MODE', 'false').lower() == 'true'

    dal_kwargs = {
        'pool_size': int(os.getenv('DB_POOL_SIZE', '10')),
        'migrate_enabled': False,  # Use Alembic for migrations
        'check_reserved': ['all'],
        'lazy_tables': True
    }

    # Galera-specific: handle wsrep_sync_wait for read-your-writes consistency
    if galera_mode and db_type == 'mysql':
        dal_kwargs['driver_args'] = {'init_command': 'SET wsrep_sync_wait=1'}

    return DAL(db_uri, **dal_kwargs)

# ============================================================================
# Application startup
# ============================================================================
# During app initialization:
# 1. init_database()  # Runs Alembic migrations
# 2. db = get_pydal_connection()  # Get PyDAL instance for operations
```

### ReactJS Frontend Integration
```javascript
// API client for Flask backend
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Protected component example
import React, { useEffect, useState } from 'react';

function ProtectedComponent() {
  const [data, setData] = useState(null);

  useEffect(() => {
    apiClient.get('/api/protected')
      .then(response => setData(response.data))
      .catch(error => console.error('Error:', error));
  }, []);

  return <div>{data?.message}</div>;
}
```

### License-Gated Features (Python)
```python
from shared.licensing import license_client, requires_feature
from flask_security import auth_required

@app.route('/api/advanced/analytics')
@auth_required()
@requires_feature("advanced_analytics")
def generate_advanced_report():
    """Requires authentication AND professional+ license"""
    return {'report': analytics.generate_report()}
```

### Monitoring Integration
```python
from prometheus_client import Counter, Histogram, generate_latest

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

@app.route('/metrics')
def metrics():
    return generate_latest(), {'Content-Type': 'text/plain'}
```

## Security Requirements

### Input Validation
- ALL inputs MUST have appropriate validators
- Use framework-native validation (pydal validators, Go validation libraries)
- Implement XSS and SQL injection prevention
- Server-side validation for all client input
- CSRF protection using framework native features

### Authentication & Authorization
- Multi-factor authentication support
- Role-based access control (RBAC)
- API key management with rotation
- JWT token validation with proper expiration
- Session management with secure cookies

### Security Scanning
- Automated dependency vulnerability scanning
- Container image security scanning
- Static code analysis for security issues
- Regular security audit logging
- Secrets scanning in CI/CD pipeline

## Enterprise Features

### Licensing Integration
- PenguinTech License Server integration
- Feature gating based on license tiers
- Usage tracking and reporting
- Compliance audit logging
- Enterprise support escalation

### Multi-Tenant Architecture
- Customer isolation and data segregation
- Per-tenant configuration management
- Usage-based billing integration
- White-label capabilities
- Compliance reporting (SOC2, ISO27001)

### Monitoring & Observability
- Prometheus metrics collection
- Grafana dashboards for visualization
- Structured logging with correlation IDs
- Distributed tracing support
- Real-time alerting and notifications

## CI/CD Pipeline Features

### Testing Pipeline
- Multi-language testing (Go, Python, Node.js)
- Parallel test execution for performance
- Code coverage reporting
- Security scanning integration
- Performance regression testing

### Build Pipeline
- **Multi-architecture Docker builds** (amd64/arm64)
- **Debian-slim base images** for all container builds
- **Parallel workflow execution** to minimize total build time
- Dependency caching for faster builds
- Artifact management and versioning
- Container registry integration

### Deployment Pipeline
- Environment-specific deployment configs
- Blue-green deployment support
- Rollback capabilities
- Health check validation
- Automated database migrations

### Quality Gates
- Required code review process
- Automated testing requirements
- Security scan pass requirements
- Performance benchmark validation
- Documentation update verification

## Website Integration Requirements

**Each project MUST have two dedicated websites**:
- Marketing/Sales website (Node.js based)
- Documentation website (Markdown based)

**Website Design Preferences**:
- Multi-page design preferred
- Modern aesthetic with clean appearance
- Subtle, sophisticated color schemes
- Gradient usage encouraged
- Responsive design
- Performance focused

**Repository Integration**:
- Add `github.com/penguintechinc/website` as sparse checkout submodule
- Only include project-specific folders
- Folder naming: `{app_name}/` and `{app_name}-docs/`

## Troubleshooting & Support

### Common Issues
1. **Port Conflicts**: Check docker-compose port mappings
2. **Database Connections**: Verify connection strings and credentials
3. **Module Registration**: Ensure services register on startup
4. **License Validation**: Check license key format and network connectivity
5. **Build Failures**: Check dependency versions and Docker build output

### Debug Commands
```bash
# Container debugging
docker logs <container-name>
docker exec -it <container-name> /bin/bash

# Application debugging
make test-debug              # Debug tests
make logs                    # View application logs
make health                  # Check service health

# License debugging
curl http://localhost:5000/api/health
curl http://localhost:5000/api/license/status
```

### Support Resources
- **Technical Documentation**: [README.md](README.md)
- **Development Standards**: [docs/STANDARDS.md](docs/STANDARDS.md)
- **CI/CD Workflows**: [docs/WORKFLOWS.md](docs/WORKFLOWS.md)
- **GitHub Organization**: https://github.com/penguintechinc
- **Integration Support**: support@penguintech.io
- **License Server Status**: https://status.penguintech.io

## License & Legal

**License File**: `LICENSE.md` (located at project root)

**License Type**: Limited AGPL-3.0 with commercial use restrictions and Contributor Employer Exception

The `LICENSE.md` file is located at the project root following industry standards. This project uses a modified AGPL-3.0 license with additional exceptions for commercial use and special provisions for companies employing contributors.

---

**Template Version**: 1.5.0
**Last Updated**: 2025-12-18
**Maintained by**: Penguin Tech Inc
**License Server**: https://license.penguintech.io

*This context helps Claude understand the project goals, technical constraints, and development standards when working on AI-Base.*
