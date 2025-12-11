# AI-Base Development Standards

## Table of Contents
1. [Multi-Language Code Standards](#multi-language-code-standards)
2. [CI/CD Standards](#cicd-standards)
3. [Version Management](#version-management)
4. [Security Requirements](#security-requirements)
5. [Performance Optimization](#performance-optimization)

## Multi-Language Code Standards

### Go Code Standards

**Code Formatting:**
- Use `gofmt` for consistent formatting (mandatory)
- Run `go fmt ./...` before commits
- All code must pass `gofmt` check in CI

**Code Quality:**
- `go vet ./...` must pass with zero issues
- `staticcheck` for advanced static analysis
- No deprecated functions or patterns
- Type assertions must include ok checks

**Testing:**
- Minimum 70% code coverage
- Table-driven tests for edge cases
- Benchmarks for performance-critical code
- Mock external dependencies

**Security:**
- gosec scanning mandatory
- Address high/medium severity issues
- Use `crypto/rand` for randomness
- Validate all external inputs
- No hardcoded credentials

**API Design:**
- RESTful conventions
- Semantic HTTP status codes
- Request validation at handler level
- Consistent error response format

### Python Code Standards

**Code Formatting:**
- **black**: Code formatter (mandatory)
- **isort**: Import sorting
- `python -m black .` before commits
- All code must pass black/isort in CI

**Code Quality:**
- **flake8**: PEP 8 compliance
- **mypy**: Type checking (continue-on-error)
- No wildcard imports
- All functions have docstrings
- Type hints for function signatures

**Testing:**
- Minimum 70% code coverage
- pytest for unit tests
- Fixtures for test setup
- Mock external services
- Async tests with pytest-asyncio

**Security:**
- bandit scanning mandatory
- Address high/medium severity issues
- No hardcoded credentials or secrets
- Validate all user input
- Secure password hashing (bcrypt via Flask-Security-Too)

**Database Access:**
- PyDAL mandatory for all database operations
- Use ORM methods, never raw SQL
- Connection pooling required
- Proper transaction handling
- Support for multiple database backends

**Web Framework:**
- Flask + Flask-Security-Too for all APIs
- RESTful route structure
- Proper HTTP status codes
- Request validation
- Consistent error responses

### JavaScript/TypeScript Code Standards

**Code Formatting:**
- **ESLint**: Linting rules (mandatory)
- **Prettier**: Code formatter
- `npm run lint` and `npm run format` before commits
- TypeScript for type safety

**Code Quality:**
- No any types without justification
- Strict mode enabled
- Type checking at build time
- Proper error handling

**Testing:**
- Minimum 60% code coverage
- Jest for unit tests
- React Testing Library for components
- Mock external APIs

**Security:**
- npm audit for dependency vulnerabilities
- No hardcoded credentials
- Input sanitization
- HTTPS-only in production
- CORS properly configured

**React Best Practices:**
- Functional components with hooks
- Proper dependency arrays
- Memoization for expensive computations
- Proper error boundaries
- Code splitting for performance

## CI/CD Standards

### Workflow Compliance

All workflows must include:

1. **.version Path Filter**
   - Trigger version-aware builds
   - Detects version file changes
   - Enables automatic versioning

2. **Version Detection Step**
   - Reads `.version` file
   - Falls back to `0.0.0.{epoch64}`
   - Exports version and epoch64

3. **Epoch64 Timestamp Generation**
   - Unix epoch (seconds since 1970)
   - Precise build tracking
   - Reproducible version tags

4. **Multi-Language Security Scanning**
   - gosec for Go
   - bandit for Python
   - npm audit for Node.js

5. **Conditional Metadata Tags**
   - `[prerelease]` for alpha/beta
   - `[release-candidate]` for rc
   - `[stable]` for releases

### Build Process

**Trigger Strategy:**
```yaml
- Push to main/develop with .version or code changes
- Pull requests with code changes
- Manual dispatch for special builds
- Schedule daily tests
```

**Job Dependencies:**
- Test jobs run first (parallel)
- Build jobs depend on test success
- Docker push only on main branch
- Release jobs require all checks pass

**Parallelization:**
- Language tests: Independent parallel execution
- Security scans: Parallel by language
- Docker builds: Multi-platform parallel builds
- Reduces total pipeline time to <15 minutes

### Security Scanning

**Language-Specific Scanners:**

**Go (gosec):**
- JSON output: `gosec-results.json`
- Checks: Hardcoded secrets, SQL injection, weak crypto
- Non-blocking (warning-only)
- High/medium issues require review

**Python (bandit):**
- JSON output: `bandit-results.json`
- Checks: Hardcoded credentials, dangerous functions
- Non-blocking (continue-on-error)
- Review all high severity findings

**Node.js (npm audit):**
- Command: `npm audit --production --audit-level=moderate`
- Checks: Known vulnerabilities in dependencies
- Non-blocking
- Address critical issues before merge

**Unified Approach:**
- All scanning is non-blocking
- Results logged in artifacts
- Security issues reviewed in PRs
- High severity items must be addressed before release

### Release Management

**Version File Updates:**
1. Edit `.version` file
2. Commit to feature branch
3. Create PR with change
4. Merge to main branch
5. `version-release.yml` auto-triggers
6. Pre-release created with metadata

**Release Tags:**
- Pattern-based: `[prerelease]`, `[release-candidate]`, `[stable]`
- Automatic detection from version string
- Included in GitHub release notes

## Version Management

### .version File Format

**Location**: `.version` at project root

**Format**: `Major.Minor.Patch[.build]`

**Examples:**
- `1.0.0` - Stable release
- `1.0.0.1737727200` - With epoch64 timestamp
- `2.0.0rc1` - Release candidate
- `1.5.0beta.2` - Beta pre-release
- `1.0.0alpha` - Alpha pre-release

### Versioning Strategy

**Semantic Versioning:**
- **Major**: Breaking changes, API changes, removed features
- **Minor**: New features, functionality additions
- **Patch**: Bug fixes, security patches, minor updates

**Build Component:**
- Optional 4th component: epoch64 timestamp
- Auto-appended by CI/CD systems
- Enables precise build identification
- Useful for nightly and CI builds

### Release Workflow

**Stable Release:**
1. Update `.version` to `X.Y.Z`
2. Create release branch
3. Build and test
4. Merge to main
5. Tag created: `vX.Y.Z`
6. Release published

**Pre-Release:**
1. Update `.version` to `X.Y.ZrcN` (or alpha/beta)
2. Commit to develop
3. Build automatically
4. Pre-release published
5. Continues development until stable

## Security Requirements

### Input Validation

**Mandatory Validation:**
- All user input validated server-side
- Framework-native validators used
- Type checking enabled
- Length and range limits enforced

**SQL Injection Prevention:**
- PyDAL only (no raw SQL)
- Go: Use parameterized queries
- Never concatenate user input into queries

**XSS Prevention:**
- React/JSX escapes by default
- HTML encoding for dynamic content
- Content Security Policy headers

### Authentication & Authorization

**Required Features:**
- User authentication
- Session management
- Role-based access control (RBAC)
- Multi-factor authentication support

**Flask-Security-Too Integration:**
- Mandatory for Python APIs
- Bcrypt password hashing
- JWT token support
- User role management

**Password Requirements:**
- Minimum 8 characters
- Complexity requirements
- Secure hashing (bcrypt)
- Rotation policies for service accounts

### Secrets Management

**Never Hardcode:**
- Database credentials
- API keys
- OAuth secrets
- Encryption keys
- Certificates/private keys

**Proper Handling:**
- Environment variables
- GitHub Secrets
- Secrets Manager (production)
- Rotation schedules

### Dependency Security

**Regular Audits:**
- `npm audit` for JavaScript
- `safety check` for Python
- `go mod audit` for Go
- Weekly dependency scanning

**Vulnerability Response:**
- Critical: Fix immediately
- High: Fix within 1 week
- Medium: Fix within 1 month
- Low: Review and assess

## Performance Optimization

### Go Optimization

**Binary Size:**
```bash
go build -ldflags="-s -w"  # Strip symbols
upx binary                 # Ultra Packer
```

**Runtime:**
- Goroutines for concurrent I/O
- sync.Pool for object reuse
- Buffer pooling for I/O
- Avoid allocations in hot paths

**Profiling:**
- Use pprof for analysis
- CPU and memory profiling
- Goroutine leak detection
- Benchmark tests

### Python Optimization

**Dataclasses with Slots:**
```python
from dataclasses import dataclass

@dataclass(slots=True)
class User:
    id: int
    name: str
```

**Async I/O:**
- asyncio for network operations
- async/await syntax
- Connection pooling

**Type Hints:**
- Required for all functions
- Enables faster execution
- Better IDE support
- Catches type errors early

### JavaScript Optimization

**Bundle Size:**
- Code splitting at route level
- Tree-shaking unused exports
- Lazy load heavy components
- Minification enabled

**Runtime Performance:**
- React.memo for component memoization
- useMemo for expensive calculations
- useCallback for callback memoization
- Proper key props in lists

### Docker Image Optimization

**Size Reduction:**
- Multi-stage builds
- Alpine runtime images
- Remove build artifacts
- Compress binaries

**Build Speed:**
- Layer caching
- Order instructions by change frequency
- Share base images
- Use BuildKit for parallelization

**Startup Performance:**
- Fast health checks
- Pre-warm connections
- Proper readiness probes

## Code Quality Metrics

### Coverage Targets

- **Go**: ≥ 70% code coverage
- **Python**: ≥ 70% code coverage
- **JavaScript**: ≥ 60% code coverage
- **Critical paths**: ≥ 90% coverage

### Complexity Limits

- **Cyclomatic complexity**: < 10 per function
- **Function length**: < 50 lines (guidelines)
- **Nesting depth**: < 4 levels
- **Lines per file**: < 300 (target)

### Performance Benchmarks

**API Response Times:**
- 99th percentile: < 500ms
- Median: < 100ms
- No endpoint > 2 seconds

**Build Times:**
- Go tests: < 60 seconds
- Python tests: < 60 seconds
- Node tests: < 120 seconds
- Total pipeline: < 15 minutes

## Code Review Standards

**Review Checklist:**
- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] Security requirements met
- [ ] Performance acceptable
- [ ] Documentation updated
- [ ] No hardcoded credentials
- [ ] Coverage maintained or improved
- [ ] Breaking changes documented

**Approval Requirements:**
- Minimum 1 approval
- All CI checks passing
- All conversations resolved
- No outstanding security issues

## Release Process

**Pre-Release Checklist:**
- [ ] All tests passing
- [ ] Security scans cleared
- [ ] Version number updated in .version
- [ ] Release notes drafted
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Performance benchmarks acceptable
- [ ] Breaking changes documented
- [ ] All PRs for release merged
- [ ] GitHub release notes generated

**Post-Release:**
- Announce release in changelog
- Update documentation
- Monitor for issues
- Prepare next development version

---

**Document Version**: 1.0
**Last Updated**: 2025-12-11
**Services**: Go API, Python Web, Node.js Web, AI Inference
**Maintained by**: Penguin Tech Inc

For questions or updates to these standards, please contact the development team or submit an issue on GitHub.
