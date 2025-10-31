# Release Process: Automated Release (Semantic-Release)

This document describes the **automated release process** using semantic-release for fully automated CI/CD releases.

## Automated Release Flow Diagram

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐
│ Developer Work  │    │ Pull Request    │    │ Automated CI/CD Release │
└─────────────────┘    └─────────────────┘    └─────────────────────────┘
         │                       │                         │
         │ 1. feat: add feature  │                         │
         ├──────────────────────▶│                         │
         │ 2. fix: resolve bug   │                         │
         ├──────────────────────▶│ 3. PR Review & Merge   │
         │ 3. docs: update guide │ ┌─────────────────────┐ │
         ├──────────────────────▶│ │ • Code review       │ │
         │                       │ │ • CI tests pass     │ │
         │                       │ │ • Merge to main     │ │
         │                       │ └─────────────────────┘ │
         │                       │           │             │
         │                       │           ▼             │
         │                       │ 4. Trigger on push     │
         │                       │    to main branch      │
         │                       ├────────────────────────▶│
         │                       │                         │ 5. Automated Release
         │                       │                         ├───────────────────┐
         │                       │                         │ • Analyze commits │
         │                       │                         │ • Determine version│
         │                       │                         │ • Update CHANGELOG│
         │                       │                         │ • Commit & tag    │
         │                       │                         │ • GitHub Release  │
         │                       │                         │ • Publish to npm  │
         │                       │                         │   (optional)      │
         │                       │                         └───────────────────┘
```

## 8 Core Release Process Concepts

### 1. **Versioning**

- **Tool**: `semantic-release` package
- **Strategy**: Fully automated SemVer based on Conventional Commits
- **Implementation**:
  - `semantic-release` analyzes commit history since last release
  - Automatically determines next version (patch/minor/major)
  - Updates `package.json` and creates git tag
  - No manual intervention required

### 2. **Branching Strategy**

- **Strategy**: GitHub Flow with protected main branch
- **Implementation**:
  - Feature branches → PR → automated merge checks → merge to `main`
  - Releases triggered automatically on every push to `main`
  - No manual release branches needed

### 3. **Testing & Quality Gates**

- **Pre-merge**: All tests must pass before merge to `main`
- **Release**: Only successful builds trigger releases
- **Implementation**:
  - `npm test` (Jest + Supertest) runs on every PR
  - `npm run lint` (ESLint) enforces code quality
  - Failed tests block merge and prevent releases

### 4. **Tagging & Artifacts**

- **Tagging**: Fully automated via `semantic-release`
- **Artifacts**: npm package + GitHub Release assets
- **Implementation**:
  - `semantic-release` creates annotated git tags
  - Automatically builds and uploads tarball to GitHub Release
  - Optional npm registry publishing

### 5. **Automation (CI/CD)**

- **CI**: Runs on every push/PR (lint, test, build)
- **Release**: Fully automated on merge to `main`
- **Implementation**:
  - Single GitHub Actions workflow handles CI and CD
  - Zero manual steps required for releases
  - Conditional release job runs only on `main` branch

### 6. **Documentation & Changelogs**

- **Changelog**: Auto-generated and committed by `semantic-release`
- **Release Notes**: Auto-generated for GitHub Releases
- **Implementation**:
  - `CHANGELOG.md` updated automatically
  - Release descriptions generated from commit messages
  - Documentation stays in sync with releases

### 7. **Deployment & Rollback**

- **Deployment**: Triggered by successful release
- **Rollback**: Git tag-based or npm version-based
- **Implementation**:
  - Each release creates immutable artifacts
  - Tagged Docker images enable precise rollbacks
  - npm version pinning for dependency rollbacks

### 8. **Monitoring & Feedback**

- **Release Tracking**: Automated notifications and metrics
- **Health Monitoring**: Version-aware health checks
- **Implementation**:
  - GitHub Release notifications
  - Version information in `/health` endpoint
  - Integration with monitoring systems via release webhooks

## Automated Release Configuration

### Required GitHub Secrets

Set these in your repository's Settings → Secrets and variables → Actions:

1. **GITHUB_TOKEN** (automatically available)

   - Used for creating releases and pushing commits
   - Default token usually has sufficient permissions

2. **NPM_TOKEN** (optional)
   - Required only if publishing to npm registry
   - Create at npmjs.com → Access Tokens
   - Set as repository secret

### Semantic-Release Configuration

File: `.releaserc.json`

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer", // Analyze commits for version
    "@semantic-release/release-notes-generator", // Generate release notes
    "@semantic-release/changelog", // Update CHANGELOG.md
    "@semantic-release/npm", // Publish to npm (optional)
    "@semantic-release/git", // Commit version changes
    "@semantic-release/github" // Create GitHub Release
  ]
}
```

## Development Workflow

### 1. Create Feature Branch

```bash
git checkout -b feature/new-feature
```

### 2. Make Changes with Conventional Commits

```bash
git commit -m "feat: add user authentication endpoint"
git commit -m "fix: resolve CORS issue in middleware"
git commit -m "docs: update API documentation"
```

### 3. Create Pull Request

- CI automatically runs lint + tests
- Code review process
- Merge when approved and tests pass

### 4. Automatic Release (No Manual Steps!)

- Merge to `main` triggers release workflow
- `semantic-release` analyzes commits
- Version bump, changelog, tag, and GitHub Release created automatically
- Optional npm package publication

## Commit Message Impact on Versioning

| Commit Type                                       | Version Bump  | Example                             |
| ------------------------------------------------- | ------------- | ----------------------------------- |
| `fix:`                                            | PATCH (1.0.1) | `fix: resolve authentication bug`   |
| `feat:`                                           | MINOR (1.1.0) | `feat: add user profile endpoint`   |
| `feat!:` or `BREAKING CHANGE:`                    | MAJOR (2.0.0) | `feat!: change API response format` |
| `docs:`, `style:`, `refactor:`, `test:`, `chore:` | No release    | Documentation and maintenance       |

## Automated Release Benefits

- **Zero Human Error**: No manual version bumping or tagging
- **Consistent Process**: Same release process every time
- **Fast Feedback**: Releases happen immediately after merge
- **Audit Trail**: Complete release history in git and GitHub
- **Parallel Development**: Multiple features can be merged and released quickly

## Production Extensions

### Enhanced Security

- Use fine-grained personal access tokens instead of GITHUB_TOKEN
- Implement signed commits and releases
- Add dependency scanning and vulnerability checks

### Advanced Deployment

- Add deployment steps after successful release
- Implement canary deployments with automated rollback
- Integrate with Kubernetes for zero-downtime deployments

### Monitoring and Observability

- Add release metrics to monitoring dashboards
- Implement automated health checks after deployment
- Set up alerts for failed releases or deployments

### Release Management

- Add release approval workflows for production
- Implement release schedules (e.g., release trains)
- Add integration with project management tools

## Repository Components

### Package.json Scripts

- `npm test`: Run test suite (blocks release if failing)
- `npm run lint`: Run ESLint (blocks release if failing)
- `npm run build`: Create distribution tarball
- `npm run semantic-release`: Manual trigger for semantic-release (development)

### GitHub Actions Workflow

- **ci.yml**: Combined CI and release workflow
  - **build-and-test job**: Runs on all pushes/PRs
  - **release job**: Runs only on push to `main` after tests pass

### Configuration Files

- `.releaserc.json`: Semantic-release configuration
- `commitlint.config.js`: Conventional Commits validation
- `.lintstagedrc.json`: Pre-commit linting rules
- `jest.config.js`: Test configuration
- `.eslintrc.json`: Code linting rules

## Troubleshooting

### Release Not Triggered

- Check that commits follow Conventional Commits format
- Ensure at least one commit has `feat:` or `fix:` since last release
- Verify CI tests are passing

### Permission Errors

- Check GITHUB_TOKEN permissions in repository settings
- Ensure Actions have write permissions to repository
- For npm publishing, verify NPM_TOKEN is valid

### Failed Release

- Check GitHub Actions logs for specific error messages
- Common issues: test failures, linting errors, network timeouts
- Semantic-release will retry on next push to `main`
