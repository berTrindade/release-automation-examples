# Testing Guide: Verify Release Workflows

This guide explains how to test both release workflows to ensure they work correctly.

## Prerequisites

- Repository cloned locally
- npm installed
- GitHub repository access
- Git configured with your credentials

## Test 1: Local Development & Quality Gates

Test that the basic tooling works on both branches.

### For Both Branches

```bash
# Clone and navigate
git clone https://github.com/berTrindade/node-release-poc.git
cd node-release-poc

# Test manual-release branch
git checkout manual-release
npm install
npm run lint          # Should pass with no errors
npm test              # Should pass all tests
npm run build         # Should create tarball in dist/

# Test auto-release branch
git checkout auto-release
npm install
npm run lint          # Should pass with no errors
npm test              # Should pass all tests
npm run build         # Should create tarball in dist/
```

**Expected Results:**
- ✅ All commands run without errors
- ✅ Tests pass (2 test suites)
- ✅ Lint reports no issues
- ✅ Build creates `.tgz` file in `dist/` directory

## Test 2: Commit Hooks (Husky + Commitlint)

Test that commit message validation works.

### For Both Branches

```bash
# Make Husky hooks executable (if not already)
chmod +x .husky/pre-commit .husky/commit-msg

# Install hooks
npm run prepare

# Try a bad commit message (should FAIL)
git commit --allow-empty -m "bad commit message"
# Expected: ❌ Error from commitlint

# Try a good commit message (should SUCCEED)
git commit --allow-empty -m "test: verify commitlint works"
# Expected: ✅ Commit succeeds
```

## Test 3: Manual-Release Branch (standard-version)

Test the manual release workflow end-to-end.

### Step 1: Create a Test Feature

```bash
git checkout manual-release
git checkout -b test/manual-release-demo

# Make a small change
echo "console.log('Test feature');" >> src/app.js
git add .
git commit -m "feat: add test feature for manual release demo"

# Push and create PR
git push origin test/manual-release-demo
```

### Step 2: Merge PR

- Go to GitHub and create a Pull Request
- Watch CI workflow run (lint, test, build)
- Merge the PR when CI passes

### Step 3: Create Manual Release

```bash
# Pull the merged changes
git checkout manual-release
git pull origin manual-release

# Run standard-version to create release
npm run release

# This will:
# - Bump version in package.json
# - Update CHANGELOG.md
# - Create git tag (e.g., v1.0.0)
# - Commit the changes

# Push the release
git push --follow-tags origin manual-release
```

### Step 4: Verify Release

1. Go to GitHub Actions tab
2. Watch "Release on tag" workflow run
3. Check that GitHub Release is created
4. Verify tarball is attached to release

**Expected Results:**
- ✅ Version bumped from 0.0.0-development to 1.0.0
- ✅ CHANGELOG.md updated with feature description
- ✅ Git tag created (v1.0.0)
- ✅ GitHub Release created with tarball artifact

## Test 4: Auto-Release Branch (semantic-release)

Test the automated release workflow end-to-end.

### Step 1: Create a Test Feature

```bash
git checkout auto-release
git checkout -b test/auto-release-demo

# Make a small change
echo "console.log('Test automated feature');" >> src/app.js
git add .
git commit -m "feat: add test feature for automated release demo"

# Push and create PR
git push origin test/auto-release-demo
```

### Step 2: Merge PR and Watch Automation

- Go to GitHub and create a Pull Request
- Watch CI workflow run (build-and-test job)
- Merge the PR

**IMPORTANT**: The merge to auto-release (or main) branch will **automatically trigger the release**!

### Step 3: Watch Automated Release

1. Go to GitHub Actions tab
2. Watch "CI and Auto-Release" workflow
3. Observe the "release" job running after tests pass
4. semantic-release will automatically:
   - Analyze commits
   - Determine version (1.0.0)
   - Update CHANGELOG.md
   - Commit changes with `[skip ci]`
   - Create git tag
   - Create GitHub Release

### Step 4: Verify Release

1. Check GitHub Releases page
2. Verify version 1.0.0 release is created
3. Check CHANGELOG.md was updated (new commit by semantic-release)
4. Verify git tag exists

**Expected Results:**
- ✅ Version automatically bumped to 1.0.0
- ✅ CHANGELOG.md updated automatically
- ✅ Git tag created automatically (v1.0.0)
- ✅ GitHub Release created automatically
- ✅ Commit made by semantic-release with `[skip ci]`

## Test 5: Version Bumping Logic

Test that different commit types create correct version bumps.

### Patch Release (1.0.1)

```bash
git commit --allow-empty -m "fix: resolve authentication bug"
```

### Minor Release (1.1.0)

```bash
git commit --allow-empty -m "feat: add new user endpoint"
```

### Major Release (2.0.0)

```bash
git commit --allow-empty -m "feat!: change API response format

BREAKING CHANGE: Response format is now JSON-API compliant"
```

### No Release

```bash
git commit --allow-empty -m "docs: update README"
git commit --allow-empty -m "chore: update dependencies"
```

## Test 6: CI Workflow on PRs

Test that CI runs on pull requests without triggering releases.

```bash
# Create feature branch
git checkout -b test/ci-only

# Make changes
echo "// CI test" >> src/app.js
git add .
git commit -m "test: verify CI runs on PRs"

# Push and create PR
git push origin test/ci-only
```

**Expected Results:**
- ✅ CI workflow runs (build-and-test job)
- ✅ Lint and tests execute
- ❌ Release job does NOT run (only runs on branch push, not PRs)

## Test 7: Failed Tests Block Release

Test that failing tests prevent releases.

### Create Failing Test

```bash
# Add a failing test
cat >> tests/app.test.js << 'EOF'

test('This test will fail', () => {
  expect(1).toBe(2);
});
EOF

git add .
git commit -m "test: add intentionally failing test"
git push
```

**Expected Results:**
- ✅ CI workflow runs
- ❌ Tests fail
- ❌ Release does NOT happen (blocked by failed tests)

Then fix it:

```bash
git revert HEAD
git push
```

## Common Issues & Troubleshooting

### Issue: Husky hooks not running

**Solution:**
```bash
chmod +x .husky/pre-commit .husky/commit-msg
npm run prepare
```

### Issue: GitHub Actions not triggering

**Solution:**
- Check repository Settings → Actions → General
- Ensure "Allow all actions and reusable workflows" is enabled
- Ensure Actions have "Read and write permissions"

### Issue: semantic-release fails with permission error

**Solution:**
- Go to Settings → Actions → General → Workflow permissions
- Select "Read and write permissions"
- Check "Allow GitHub Actions to create and approve pull requests"

### Issue: No release created despite commits

**Solution:**
- Ensure commits follow Conventional Commits format
- Only `feat:` and `fix:` trigger releases
- Check that commit is on the correct branch (auto-release or manual-release)

## Quick Verification Checklist

### manual-release branch:
- [ ] npm install works
- [ ] npm test passes
- [ ] npm run lint passes
- [ ] Commitlint validates commit messages
- [ ] npm run release creates tag locally
- [ ] Pushing tag triggers GitHub Actions
- [ ] GitHub Release is created with artifact

### auto-release branch:
- [ ] npm install works
- [ ] npm test passes
- [ ] npm run lint passes
- [ ] Commitlint validates commit messages
- [ ] Merge to branch triggers CI + release job
- [ ] semantic-release creates version automatically
- [ ] GitHub Release is created automatically

## Best Practice: Test in Order

1. Start with local tests (lint, test, build)
2. Test commit hooks
3. Test CI workflow on PR (no release)
4. Test full release workflow
5. Test version bumping logic
6. Test failure scenarios

This ensures each layer works before testing the next!
