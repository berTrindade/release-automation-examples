# Workflow Configuration Fixes

## Issues Identified

### Problem 1: CI Workflow Not Triggering

**Branches Affected**: Both `manual-release` and `auto-release`

**Root Cause**: The CI workflow (`.github/workflows/ci.yml`) was configured to only trigger on `main` and `master` branches:

```yaml
on:
  push:
    branches: [main, master]  # ❌ Missing manual-release and auto-release
  pull_request:
    branches: [main, master]  # ❌ Missing manual-release and auto-release
```

**Impact**:

- Pull requests to `manual-release` or `auto-release` branches didn't trigger CI
- Direct pushes to these branches didn't run tests/linting
- No quality gates enforced

### Problem 2: Semantic-Release Not Running on Auto-Release Branch

**Branch Affected**: `auto-release`

**Root Cause**: The release job condition was hardcoded to only run on `main` branch:

```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'  # ❌ Missing auto-release
```

**Impact**:

- Merges to `auto-release` branch didn't trigger semantic-release
- No automatic version bumping
- No automatic changelog generation
- No automatic GitHub releases

### Problem 3: Missing GitHub Token Permissions

**Branches Affected**: Both `manual-release` and `auto-release`

**Root Cause**: Workflows lacked explicit `permissions` blocks for GITHUB_TOKEN:

- `release.yml` (manual-release) had no permissions block
- `ci.yml` (auto-release) needed write permissions for semantic-release
- Without these, GitHub Actions couldn't create releases or push changes

**Impact**:

- Release workflow failed to create GitHub Releases
- semantic-release couldn't push version tags
- semantic-release couldn't update CHANGELOG.md
- No automated release artifacts

## Fixes Applied

### Fix 1: Update CI Workflow Triggers (Both Branches)

**File**: `.github/workflows/ci.yml`

**manual-release branch**:

```yaml
on:
  push:
    branches: [main, master, manual-release, auto-release]  # ✅ Added both branches
  pull_request:
    branches: [main, master, manual-release, auto-release]  # ✅ Added both branches

permissions:
  contents: read  # ✅ Added read permissions
```

**auto-release branch**:

```yaml
on:
  push:
    branches: [main, master, auto-release]  # ✅ Added auto-release
  pull_request:
    branches: [main, master, auto-release]  # ✅ Added auto-release

permissions:
  contents: write        # ✅ Added write permissions for releases
  issues: write          # ✅ For semantic-release comments
  pull-requests: write   # ✅ For semantic-release PR updates
```

### Fix 2: Update Release Job Condition (Auto-Release Branch Only)

**File**: `.github/workflows/ci.yml` on auto-release branch

```yaml
release:
  needs: build-and-test
  runs-on: ubuntu-latest
  if: (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/auto-release') && github.event_name == 'push'  # ✅ Added auto-release condition
```

### Fix 3: Add GitHub Token Permissions (Manual-Release Branch)

**File**: `.github/workflows/release.yml` on manual-release branch

```yaml
name: Release on tag

on:
  push:
    tags:
      - "v*"

permissions:
  contents: write  # ✅ Added write permissions for creating releases

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      # ... steps ...
      - name: Create GitHub Release and upload tarball
        uses: softprops/action-gh-release@v1
        with:
          files: dist/*.tgz
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}  # ✅ Added explicit token
```

## What Now Works

### ✅ Manual-Release Branch
1. **CI on Pull Requests**: PRs to `manual-release` now trigger CI workflow
2. **CI on Push**: Direct pushes to `manual-release` trigger CI workflow
3. **Release on Tag**: Pushing a tag (e.g., `v1.0.0`) triggers release workflow
4. **Quality Gates**: Tests and linting run automatically

### ✅ Auto-Release Branch
1. **CI on Pull Requests**: PRs to `auto-release` now trigger CI workflow
2. **CI on Push**: Direct pushes trigger both build-and-test AND release jobs
3. **Semantic-Release**: Automatically runs on push to `auto-release`
4. **Automated Versioning**: semantic-release determines version from commits
5. **Automated Changelog**: CHANGELOG.md updated automatically
6. **Automated GitHub Releases**: Releases created automatically

## Testing the Fixes

### Test Manual-Release Workflow

1. **Create a test PR**:
```bash
git checkout manual-release
git checkout -b test/workflow-fix
echo "// test" >> src/app.js
git add .
git commit -m "test: verify CI workflow runs"
git push origin test/workflow-fix
gh pr create --base manual-release --title "test: verify CI workflow"
```

2. **Verify CI runs**: Check GitHub Actions tab

3. **Merge and create release**:
```bash
gh pr merge --squash
git checkout manual-release
git pull
npm run release
git push --follow-tags origin manual-release
```

4. **Verify release workflow**: Check GitHub Actions and Releases tabs

### Test Auto-Release Workflow

1. **Create a test PR**:
```bash
git checkout auto-release
git checkout -b test/auto-workflow-fix
echo "// test auto" >> src/app.js
git add .
git commit -m "feat: verify automatic release workflow"
git push origin test/auto-workflow-fix
gh pr create --base auto-release --title "feat: verify automatic release"
```

2. **Verify CI runs**: Check GitHub Actions tab

3. **Merge PR**:
```bash
gh pr merge --squash
```

4. **Watch automatic release**: 
   - GitHub Actions should show both `build-and-test` and `release` jobs
   - semantic-release should automatically create a new version
   - GitHub Release should be created automatically

## Summary of Changes

| File | Branch | Change |
|------|--------|--------|
| `.github/workflows/ci.yml` | manual-release | Added `manual-release` and `auto-release` to branch triggers + `contents: read` permission |
| `.github/workflows/ci.yml` | auto-release | Added `auto-release` to branch triggers + release job condition + `contents: write`, `issues: write`, `pull-requests: write` permissions |
| `.github/workflows/release.yml` | manual-release | Added `permissions: contents: write` + explicit `GITHUB_TOKEN` env var |

## Commits Made

1. **manual-release**: 
   - `fix: update CI workflow to run on manual-release and auto-release branches`
   - `fix: add permissions to workflows for GitHub token access`

2. **auto-release**: 
   - `fix: update CI workflow to run on auto-release branch`
   - `fix: add write permissions for semantic-release workflow`

All fixes have been pushed to GitHub. The workflows should now:

- ✅ Trigger on the correct branches
- ✅ Have proper permissions to create releases
- ✅ Be able to push tags and update files (semantic-release)
- ✅ Create GitHub Releases with artifacts
