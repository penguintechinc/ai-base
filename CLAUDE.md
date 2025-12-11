# Project Template - Claude Code Context

## Project Overview

This is a comprehensive project template incorporating best practices and patterns from Penguin Tech Inc projects. It provides a standardized foundation for multi-language projects with enterprise-grade infrastructure and integrated licensing.

**Template Features:**
- Multi-language support (Go 1.23.x, Python 3.12/3.13, Node.js 18+)
- Enterprise security and licensing integration
- Comprehensive CI/CD pipeline
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
- **Database ORM**: PyDAL (mandatory for all Python applications)
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
- **Primary**: PostgreSQL (default, configurable via `DB_TYPE` environment variable)
- **Cache**: Redis/Valkey with optional TLS and authentication
- **Database Abstraction Layers (DALs)**:
  - **Python**: PyDAL (mandatory for ALL Python applications)
    - Must support ALL PyDAL-supported databases by default
    - Special support for MariaDB Galera cluster requirements
    - `DB_TYPE` must match PyDAL connection string prefixes exactly
  - **Go**: GORM or sqlx (mandatory for cross-database support)
    - Must support PostgreSQL and MySQL/MariaDB
    - Stable, well-maintained library required
- **Migrations**: Automated schema management
- **Database Support**: Design for ALL PyDAL-supported databases from the start
- **MariaDB Galera Support**: Handle Galera-specific requirements (WSREP, auto-increment, transactions)

**Supported DB_TYPE Values (PyDAL prefixes)**:
- `postgres` / `postgresql` - PostgreSQL (default)
- `mysql` - MySQL/MariaDB
- `sqlite` - SQLite
- `mssql` - Microsoft SQL Server
- `oracle` - Oracle Database
- `db2` - IBM DB2
- `firebird` - Firebird
- `informix` - IBM Informix
- `ingres` - Ingres
- `cubrid` - CUBRID
- `sapdb` - SAP DB/MaxDB

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
PRODUCT_NAME=your-product-identifier

# Release mode (enables license enforcement)
RELEASE_MODE=false  # Development (default)
RELEASE_MODE=true   # Production (explicitly set)
```

## WaddleAI Integration (Optional)

For projects requiring AI capabilities, integrate with WaddleAI located at `~/code/WaddleAI`.

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

## Project Structure

```
project-name/
├── .github/             # CI/CD pipelines and templates
├── apps/                # Application code
├── services/            # Microservices (separate containers by default)
│   ├── api/            # Flask + Flask-Security-Too backend (separate container)
│   ├── webui/          # ReactJS frontend (separate container)
│   └── connector/      # Integration services (separate container)
├── shared/              # Shared components
├── web/                 # Marketing/docs websites
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

## Application Architecture

**ALWAYS use microservices architecture** - decompose into specialized, independently deployable containers:

1. **Web UI Container**: ReactJS frontend (separate container, served via nginx)
2. **Application API Container**: Flask + Flask-Security-Too backend (separate container)
3. **Connector Container**: External system integration (separate container)

**Default Container Separation**: Web UI and API are ALWAYS separate containers by default. This provides:
- Independent scaling of frontend and backend
- Different resource allocation per service
- Separate deployment lifecycles
- Technology-specific optimization

**Benefits**:
- Independent scaling
- Technology diversity
- Team autonomy
- Resilience
- Continuous deployment

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

### Database Integration (PyDAL with Multi-Database Support)
```python
from pydal import DAL, Field
from dataclasses import dataclass
import os

# Valid PyDAL DB_TYPE values for input validation
VALID_DB_TYPES = {
    'postgres', 'postgresql', 'mysql', 'sqlite', 'mssql',
    'oracle', 'db2', 'firebird', 'informix', 'ingres',
    'cubrid', 'sapdb'
}

@dataclass(slots=True, frozen=True)
class UserModel:
    """User model with slots for memory efficiency"""
    id: int
    email: str
    name: str
    active: bool

def get_db_connection() -> DAL:
    """Initialize PyDAL with environment variables and multi-DB support"""
    db_type = os.getenv('DB_TYPE', 'postgres')

    # Input validation - ensure DB_TYPE matches PyDAL expectations
    if db_type not in VALID_DB_TYPES:
        raise ValueError(f"Invalid DB_TYPE: {db_type}. Must be one of: {VALID_DB_TYPES}")

    # Build connection URI
    db_uri = f"{db_type}://" \
             f"{os.getenv('DB_USER')}:{os.getenv('DB_PASS')}@" \
             f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/" \
             f"{os.getenv('DB_NAME')}"

    # MariaDB Galera specific settings
    galera_mode = os.getenv('GALERA_MODE', 'false').lower() == 'true'

    dal_kwargs = {
        'pool_size': int(os.getenv('DB_POOL_SIZE', '10')),
        'migrate_enabled': True,
        'check_reserved': ['all'],
        'lazy_tables': True
    }

    # Galera-specific: handle wsrep_sync_wait for read-your-writes consistency
    if galera_mode and db_type == 'mysql':
        dal_kwargs['driver_args'] = {'init_command': 'SET wsrep_sync_wait=1'}

    return DAL(db_uri, **dal_kwargs)
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
2. **Database Connections**: Verify connection strings and permissions
3. **License Validation Failures**: Check license key format and network connectivity
4. **Build Failures**: Check dependency versions and compatibility
5. **Test Failures**: Review test environment setup

### Debug Commands
```bash
# Container debugging
docker-compose logs -f service-name
docker exec -it container-name /bin/bash

# Application debugging
make debug                    # Start with debug flags
make logs                     # View application logs
make health                   # Check service health

# License debugging
make license-debug            # Test license server connectivity
make license-validate         # Validate current license
```

### Support Resources
- **Integration Support**: support@penguintech.io
- **Sales Inquiries**: sales@penguintech.io
- **License Server Status**: https://status.penguintech.io

## CI/CD Pipeline & Workflows

ai-base implements comprehensive CI/CD with full .WORKFLOW compliance for multi-language development. All workflows include version detection, epoch64 timestamps, multi-language security scanning, and conditional metadata tags.

### .WORKFLOW Compliance Standard

All workflows include:
1. **.version path filters**: Detect version file changes for automatic versioning
2. **Version detection step**: Parse `.version` file with epoch64 fallback
3. **Epoch64 timestamp generation**: Unix epoch (seconds since 1970) for precise build tracking
4. **Multi-language security scanning**: gosec (Go), bandit (Python), npm audit (Node.js)
5. **Conditional metadata tags**: Dynamic Docker tags based on version patterns

### Core Workflows

**CI/CD Pipeline** (`ci.yml`):
- Version detection from `.version` file
- Multi-language testing: Go, Python, Node.js
- Security scanning: gosec, bandit, npm audit
- Integration testing across services
- Codecov coverage reporting
- Conditional job execution based on changes
- Parallel test execution for speed

**Docker Builds** (`ai-base-build.yml`, `ai-base-latest.yml`, `ai-base-nvidia.yml`, `ai-base-rocm.yml`, `ai-base-vulkan.yml`):
- Multi-platform builds (amd64/arm64)
- `.version` path filtering
- Layer caching for performance
- Multi-registry push (GHCR, Docker Hub)
- Variant builds for GPU support

**Release Management** (`version-release.yml`):
- Triggered on `.version` file changes
- Automatic pre-release creation
- Epoch64 timestamp generation
- Conditional metadata tags: [prerelease], [release-candidate], [stable]
- Prevents duplicate releases
- Auto-generated release notes

### Version Management

**File**: `.version` (1.0.0.1737727200)

**Format**: `Major.Minor.Patch[.build]`
- Major: Breaking changes, API changes
- Minor: New features and functionality
- Patch: Bug fixes and security patches
- Build: Optional epoch64 timestamp (auto-appended by CI/CD)

**Detection Strategy**:
```bash
if [ -f .version ]; then
  VERSION=$(cat .version)
else
  VERSION="0.0.0.$(date +%s)"
fi
EPOCH64=$(date +%s)
```

**Release Process**:
1. Update `.version` file in feature branch
2. Commit and create PR
3. Merge to main branch
4. GitHub Actions auto-triggers `version-release.yml`
5. Pre-release created with metadata tags

### Multi-Language Security Scanning

**Go (gosec):**
- Installation: `go install github.com/securego/gosec/v2/cmd/gosec@latest`
- Execution: `gosec -fmt json -out gosec-results.json ./...`
- Checks: Hardcoded credentials, SQL injection, weak crypto
- Output: JSON for analysis
- Behavior: Warning-only (non-blocking)

**Python (bandit):**
- Installation: `pip install bandit`
- Execution: `bandit -r . -f json -o bandit-results.json`
- Checks: Hardcoded secrets, insecure functions, SQL injection
- Output: JSON for analysis
- Behavior: Continue-on-error (non-blocking)

**Node.js (npm audit):**
- Execution: `npm audit --production --audit-level=moderate`
- Checks: Known vulnerabilities in dependencies
- Scope: Production dependencies only
- Behavior: Continue-on-error (non-blocking)

**All Security Scanning:**
- Non-blocking (warnings only)
- JSON output for programmatic analysis
- High/medium severity issues require review
- Logged in CI artifacts
- Part of security dashboard

### Docker Image Tagging

**Service Tagging:**
```
API Service:       ghcr.io/penguintechinc/ai-base-api:v1.0.0
Web Service:       ghcr.io/penguintechinc/ai-base-web:v1.0.0
Inference Service: ghcr.io/penguintechinc/ai-base-inference:v1.0.0
```

**Tag Patterns:**
- Semantic: `v1.0.0`, `v1.0`, `v1`
- Branch: `main-a1b2c3d4`
- Release: `latest`, `stable`
- Version file: `v1.0.0.1737727200`

**Registries:**
- GitHub Container Registry: `ghcr.io/penguintechinc/`
- Docker Hub: `docker.io/penguincloud/`

### Performance Optimization

**Build Parallelization:**
- Language-specific tests in parallel
- Multi-platform Docker builds (6x parallel: 3 languages × 2 architectures)
- Independent security scanning
- Conditional execution: skip unchanged language tests

**Caching Strategy:**
- Go module cache: `~/.cache/go-build`, `~/go/pkg/mod`
- Python pip cache: `~/.cache/pip`
- NPM cache: Built-in via `actions/setup-node`
- Docker layer cache: GitHub Actions BuildKit cache

**Build Time Targets:**
- Go tests: < 60 seconds (multiple versions)
- Python tests: < 60 seconds (multiple versions)
- Node tests: < 120 seconds (multiple versions)
- Docker builds: < 2 minutes per platform
- Total CI pipeline: < 15 minutes

### Monitoring and Troubleshooting

**Build Artifacts:**
- Test reports (JUnit XML)
- Coverage reports (HTML, XML)
- Security scan results (JSON)
- Build logs with retention policies

**Common Issues:**

**Version Detection Fails:**
- Verify `.version` file exists and is readable
- Check for UTF-8 encoding
- Ensure no leading/trailing whitespace

**Dependency Installation Fails:**
- Clear pip/npm cache
- Update requirements.txt/package.json
- Check network connectivity

**Security Scan Warnings:**
- Review JSON output in artifacts
- Address high/medium severity issues
- Document suppression of false positives

**Docker Build Fails:**
- Check base image availability
- Verify Dockerfile syntax
- Review build context
- Ensure no hardcoded credentials

### Documentation

See comprehensive documentation:
- **[docs/WORKFLOWS.md](docs/WORKFLOWS.md)**: Complete workflow reference
- **[docs/STANDARDS.md](docs/STANDARDS.md)**: Development standards and practices
- **Security Scanners**:
  - [gosec](https://github.com/securego/gosec)
  - [bandit](https://bandit.readthedocs.io/)
  - [npm audit](https://docs.npmjs.com/cli/v10/commands/npm-audit)

## Template Customization

### Adding New Languages
1. Create language-specific directory structure
2. Add Dockerfile and build scripts
3. Update CI/CD pipeline configuration
4. Add language-specific linting and testing
5. Update documentation and examples

### Adding New Services
1. Use service template in `services/` directory
2. Configure service discovery and networking
3. Add monitoring and logging integration
4. Integrate license checking for service features
5. Create service-specific tests
6. Update deployment configurations

### Enterprise Integration
- Configure license server integration
- Set up multi-tenant data isolation
- Implement usage tracking and reporting
- Add compliance audit logging
- Configure enterprise monitoring

---

**Template Version**: 1.2.0
**Last Updated**: 2025-11-23
**Maintained by**: Penguin Tech Inc
**License Server**: https://license.penguintech.io

**Key Updates in v1.2.0:**
- Web UI and API as separate containers by default
- Mandatory linting for all languages (flake8, ansible-lint, eslint, etc.)
- CodeQL inspection compliance required
- Multi-database support by design (all PyDAL databases + MariaDB Galera)
- DB_TYPE environment variable with input validation
- Flask as sole web framework (PyDAL for database abstraction)

*This template provides a production-ready foundation for enterprise software development with comprehensive tooling, security, operational capabilities, and integrated licensing management.*
