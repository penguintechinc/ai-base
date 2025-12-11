# AI-Base CI/CD Workflows

## Overview

ai-base implements comprehensive CI/CD pipelines with full .WORKFLOW compliance for multi-language development. All workflows include version detection, epoch64 timestamps, multi-language security scanning, and conditional metadata tags.

## Workflow Compliance Features

All ai-base workflows include:
- **Version Detection**: `.version` file path filtering triggers version-aware builds
- **Epoch64 Timestamps**: Unix epoch timestamps for precise build tracking
- **Version Detection Step**: Automatic .version file parsing with fallback to epoch timestamp
- **Conditional Metadata Tags**: Dynamic Docker tags based on version patterns
- **Multi-Language Security Scanning**:
  - gosec for Go
  - bandit for Python
  - npm audit for Node.js

## Core Services

ai-base is a multi-language template with three primary services:

### Services Structure

1. **Go API Service** (`apps/api/`)
   - RESTful API backend
   - High-performance Go service
   - PostgreSQL/MySQL compatible database access

2. **Python Web Service** (`apps/web/`)
   - Flask + Flask-Security-Too application
   - Business logic and data processing
   - PyDAL database abstraction layer

3. **Node.js Web UI** (`web/`)
   - ReactJS frontend
   - Modern JavaScript/TypeScript
   - npm build pipeline

4. **AI Inference Service** (`apps/ai-inference/`)
   - AI/ML model inference
   - Integration with WaddleAI
   - Separate containerized service

## Workflows

### CI/CD Pipeline (`ci.yml`)

Comprehensive continuous integration covering all languages and components.

**Triggers:**
- Push to main, develop, feature/* branches (with .version or code changes)
- Pull requests to main, develop branches
- Daily schedule at 2 AM UTC
- Code changes monitored: Go, Python, JavaScript/TypeScript, Markdown

**Jobs:**

1. **version-detect**: Detects version from `.version` file
   - Reads `.version` file content
   - Falls back to `0.0.0.{epoch64}` if missing
   - Exports version and epoch64 for all downstream jobs

2. **changes**: Detects which components changed
   - Go code changes
   - Python code changes
   - Node.js/Web changes
   - Documentation changes
   - Skips unnecessary jobs when specific components unchanged

3. **go-test**: Go testing and security scanning
   - Matrix: Go 1.23.5, 1.24.0
   - Modules download and verification
   - `go vet` analysis
   - **staticcheck** for static analysis
   - **gosec** security scanning (JSON output)
   - Unit tests with race condition detection
   - Code coverage reporting

4. **python-test**: Python testing and security scanning
   - Matrix: Python 3.12, 3.13
   - Dependencies: requirements.txt
   - Code formatting: **black**
   - Import sorting: **isort**
   - Linting: **flake8**
   - Type checking: **mypy**
   - Security scanning: **bandit** (JSON output)
   - Pytest with coverage reporting

5. **node-test**: Node.js testing and security scanning
   - Matrix: Node.js 18, 20, 22
   - NPM dependency installation
   - Security: **npm audit** (production dependencies)
   - Linting: **ESLint**
   - Code formatting: **Prettier**
   - Type checking via TypeScript
   - Unit tests
   - Web application build

6. **integration-test**: Cross-service integration testing
   - All services: Go, Python, Node.js
   - Database services: PostgreSQL, Redis
   - Health check endpoints
   - API endpoint validation
   - E2E tests with Playwright (if available)

7. **security**: Comprehensive security scanning
   - Trivy filesystem scan
   - CodeQL analysis (Go, Python, JavaScript)
   - Semgrep static analysis

8. **license-check**: License integration validation
   - Verifies license client integration
   - Checks license files across services

9. **test-summary**: Aggregates test results
   - Summarizes all job results
   - Comments on PRs with results
   - Fails if required jobs failed

**Conditional Execution:**
- Go tests only run if Go code changed
- Python tests only run if Python code changed
- Node tests only run if JavaScript/TypeScript code changed
- Integration tests require all individual tests to pass

### Docker Builds

**ai-base-build.yml**: Standard multi-platform Docker builds
**ai-base-latest.yml**: Builds tagged as latest
**ai-base-nvidia.yml**: GPU-enabled images (NVIDIA CUDA)
**ai-base-rocm.yml**: GPU-enabled images (AMD ROCm)
**ai-base-vulkan.yml**: Vulkan compute support

All Docker workflows include:
- `.version` path filtering
- Multi-platform builds (amd64/arm64)
- Container registry push (GHCR, Docker Hub)
- Layer caching for performance

### Deployment

**deploy.yml**: Deployment pipeline (when applicable)
**cron.yml**: Scheduled maintenance and testing

### Version Management

**release.yml**: Publish Docker images on release events
**version-release.yml**: Automatic pre-release creation

## Version Management

### .version File Format

Location: `/home/penguin/code/ai-base/.version`

Current version: `1.0.0.1737727200` (semantic version + epoch64)

**Format**:
```
Major.Minor.Patch[.build]
```

**Examples:**
- `1.0.0` - Semantic version
- `1.0.0.1737727200` - With epoch64 timestamp
- `2.0.0rc1` - Release candidate
- `1.5.0beta.2` - Beta pre-release

### Version Detection

All workflows include version detection:

```bash
if [ -f .version ]; then
  VERSION=$(cat .version | tr -d '[:space:]')
else
  VERSION="0.0.0.$(date +%s)"  # Falls back to epoch64
fi
EPOCH64=$(date +%s)
```

This provides:
- Consistent version tracking
- Automatic fallback on missing file
- Precise epoch64 timestamps
- Reproducible builds

## Security Scanning

### Multi-Language Security

**Go (gosec):**
- Installation: `go install github.com/securego/gosec/v2/cmd/gosec@latest`
- Execution: `gosec -fmt json -out gosec-results.json ./...`
- Checks: Hardcoded credentials, SQL injection, weak crypto, etc.

**Python (bandit):**
- Installation: `pip install bandit`
- Execution: `bandit -r . -f json -o bandit-results.json`
- Checks: Hardcoded secrets, insecure functions, SQL injection, etc.

**Node.js (npm audit):**
- Execution: `npm audit --production --audit-level=moderate`
- Checks: Known vulnerabilities in dependencies
- Focuses on production dependencies

**All Scanning:**
- Warning-only (non-blocking)
- JSON output for analysis
- High/medium severity issues require review
- Logged in CI artifacts

### Integration with CodeQL

GitHub CodeQL provides:
- Language analysis: Go, Python, JavaScript
- Pattern-based detection
- SARIF report generation
- Security dashboard integration

## Docker Image Tagging

**Multi-Service Tags:**
```
Base:        ghcr.io/penguintechinc/ai-base:v1.0.0
Services:    ghcr.io/penguintechinc/ai-base-api:v1.0.0
             ghcr.io/penguintechinc/ai-base-web:v1.0.0
             ghcr.io/penguintechinc/ai-base-inference:v1.0.0
```

**Tag Patterns:**
- Semantic: `v1.0.0`, `v1.0`, `v1`
- Branch: `main-a1b2c3d4`
- Release: `latest`, `stable`
- Version file: `v1.0.0.1737727200`

## Release Management

### Automatic Pre-Release Creation

**Workflow**: `version-release.yml`

Triggered on `.version` file changes to main branch.

**Features:**
1. Version detection from `.version` file
2. Epoch64 timestamp generation
3. Release tag detection (alpha, beta, rc, stable)
4. Conditional metadata: `[prerelease]`, `[release-candidate]`, `[stable]`
5. Prevents duplicate releases
6. Auto-generated release notes with:
   - Version metadata
   - Epoch64 timestamp
   - Commit information
   - Service list

**Release Process:**
1. Update `.version` file
2. Commit and create PR
3. Merge to main
4. `version-release.yml` auto-triggers
5. Pre-release created with metadata

## Performance Optimization

### Build Parallelization

**Parallel Execution:**
- Go tests (multiple versions)
- Python tests (multiple versions)
- Node.js tests (multiple versions)
- Security scans (independent)
- Docker builds (multi-platform)

**Conditional Execution:**
- Skip language-specific jobs if code unchanged
- Skip integration tests if unit tests fail
- Skip Docker push on PR events

### Caching Strategy

**Go Caching:**
```yaml
path: |
  ~/.cache/go-build
  ~/go/pkg/mod
key: ${{ runner.os }}-go-${{ matrix.go-version }}-${{ hashFiles('**/go.sum') }}
```

**Python Caching:**
```yaml
path: ~/.cache/pip
key: ${{ runner.os }}-pip-${{ matrix.python-version }}-${{ hashFiles('**/requirements.txt') }}
```

**NPM Caching:**
- Built-in via `actions/setup-node` with `cache: 'npm'`

**Docker Layer Caching:**
```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```

### Build Time Targets

- Go tests: < 60 seconds (multiple versions)
- Python tests: < 60 seconds (multiple versions)
- Node tests: < 120 seconds (multiple versions)
- Docker build: < 2 minutes per platform
- Total CI pipeline: < 15 minutes

## Monitoring and Troubleshooting

### Build Artifacts

Uploaded and retained:
- Test reports (JUnit XML)
- Coverage reports (HTML, XML)
- Security scan results (JSON)
- Build artifacts (7-30 day retention)

### Debugging Failed Workflows

**View Logs:**
- GitHub Actions workflow logs
- Click on failed job for details
- Export logs for analysis

**Common Issues:**

**Version Detection Fails:**
- Verify `.version` file exists
- Check for UTF-8 encoding
- Ensure no leading/trailing whitespace

**Dependency Installation Fails:**
- Clear pip/npm cache
- Update requirements/package.json
- Check network connectivity

**Security Scan Warnings:**
- Review JSON output in artifacts
- Address high/medium severity issues
- Suppress false positives with rules files

**Docker Build Fails:**
- Check base image availability
- Verify build context files
- Review Dockerfile syntax
- Check for hardcoded credentials

## Documentation

See comprehensive documentation:
- **[docs/STANDARDS.md](STANDARDS.md)**: Development standards and CI/CD practices
- **GitHub Actions Docs**: [docs.github.com/en/actions](https://docs.github.com/en/actions)
- **Security Scanners**:
  - [gosec](https://github.com/securego/gosec)
  - [bandit](https://bandit.readthedocs.io/)
  - [npm audit](https://docs.npmjs.com/cli/v10/commands/npm-audit)
  - [CodeQL](https://codeql.github.com/docs/)

## Key Metrics

**Coverage Targets:**
- Go: ≥ 70% code coverage
- Python: ≥ 70% code coverage
- JavaScript: ≥ 60% code coverage

**Test Execution Times:**
- Go unit tests: < 60 seconds
- Python unit tests: < 60 seconds
- Node tests: < 120 seconds

**Build Success Rate:**
- Target: ≥ 99% success rate
- All failures get immediate attention

---

**Document Version**: 1.0
**Last Updated**: 2025-12-11
**Services**: Go API, Python Web, Node.js Web, AI Inference
**Maintained by**: Penguin Tech Inc
