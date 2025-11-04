# Complete Branch Comparison

This POC now demonstrates **FOUR** different release approaches:

## 📊 Branch Overview

| Branch | Tool | Philosophy | Automation | Human Gate |
|--------|------|------------|------------|------------|
| `manual-release` | standard-version | Manual control | Low | When to release |
| `auto-release` | semantic-release | Fully automated | Highest | None |
| `release-please` | Release Please | PR-based | Medium | Merge Release PR |
| `changesets` | Changesets | Explicit declaration | Low | Create changeset + Merge PR |

## 1️⃣ manual-release (Custom/Legacy Approach)

**Tool:** `standard-version`  
**Workflow:** Manual trigger → Tag creation → GitHub Release

### How It Works:
```bash
# 1. Merge features to manual-release
# 2. Manually trigger release
npm run release

# 3. Push tag
git push --follow-tags

# 4. GitHub Release created automatically
```

### Pros:
- ✅ Full control over when releases happen
- ✅ Simple to understand
- ✅ Works with any workflow

### Cons:
- ❌ Manual trigger required
- ❌ Can forget to release
- ❌ Older tooling (standard-version)

---

## 2️⃣ auto-release (Semantic Release - Article Approach #1)

**Tool:** `semantic-release`  
**Workflow:** Push → Analyze commits → Auto release

### How It Works:
```bash
# 1. Push commits with conventional format
git push origin auto-release

# 2. semantic-release automatically:
#    - Analyzes commits
#    - Determines version bump
#    - Updates CHANGELOG
#    - Creates GitHub Release
#    - Done! (no manual intervention)
```

### Pros:
- ✅ Zero manual intervention
- ✅ Consistent releases
- ✅ Modern industry standard
- ✅ Multi-branch support (beta, alpha)

### Cons:
- ❌ No human oversight
- ❌ Releases on every push (if commits trigger it)
- ❌ Requires strict commit discipline

---

## 3️⃣ release-please (Release Please - Article Approach #2)

**Tool:** `Release Please` (Google)  
**Workflow:** Push → Bot creates PR → Review → Merge → Release

### How It Works:
```bash
# 1. Push commits to release-please
git push origin release-please

# 2. Release Please bot creates/updates "Release vX.X.X" PR
#    - Analyzes commits since last release
#    - Determines version bump
#    - Generates CHANGELOG
#    - Updates package.json

# 3. Review the PR (check version, changelog)

# 4. Merge the PR
gh pr merge --squash

# 5. Release created automatically!
```

### Pros:
- ✅ Human oversight before every release
- ✅ Clear audit trail through PRs
- ✅ GitHub-native workflow
- ✅ Battle-tested by Google
- ✅ Balance of automation and control

### Cons:
- ❌ Requires PR merge for release
- ❌ Can accumulate changes in one PR
- ❌ Extra step compared to semantic-release

---

## 4️⃣ changesets (Changesets - Article Approach #3)

**Tool:** `Changesets`  
**Workflow:** Create changeset → Bot creates PR → Merge → Release

### How It Works:
```bash
# 1. Make code changes

# 2. Create a changeset (explicit declaration)
npm run changeset
# CLI prompts:
# - Select change type (patch/minor/major)
# - Write description

# 3. Commit changeset file with code
git add .
git commit -m "feat: add feature with changeset"
git push origin changesets

# 4. Changesets bot creates "Version Packages" PR

# 5. Review and merge PR → Release created!
```

### Pros:
- ✅ Maximum control over releases
- ✅ Collaborative changelog creation
- ✅ Explicit change declaration
- ✅ Great for complex coordination
- ✅ Changeset files provide context

### Cons:
- ❌ Extra step (creating changesets)
- ❌ More manual work
- ❌ Developers can forget to create changesets
- ❌ Most complex workflow

---

## 🎯 Which Approach to Use?

### Choose **manual-release** if:
- You want simple, full control
- Working solo or small team
- Don't mind manual triggers
- Learning release automation

### Choose **auto-release** (semantic-release) if:
- Want maximum automation
- Team follows conventional commits strictly
- Comfortable with automatic releases
- Need multi-branch support (beta, alpha)

### Choose **release-please** if:
- Want automation WITH oversight
- Prefer GitHub-native workflows
- Need approval gates for releases
- Want best of both worlds

### Choose **changesets** if:
- Need maximum control and documentation
- Want collaborative changelogs
- Complex multi-package coordination
- Don't mind extra changeset step

---

## 📚 Implementation Details

### All Branches Include:
- ✅ Conventional commits enforcement
- ✅ CHANGELOG auto-generation
- ✅ GitHub Actions CI/CD
- ✅ Linting + Testing
- ✅ Git hooks (Husky + commitlint)
- ✅ GitHub Releases (no NPM publishing)

### Key Differences:

| Feature | manual | auto | release-please | changesets |
|---------|--------|------|----------------|-----------|
| **Trigger** | Manual command | Auto on push | Merge Release PR | Merge Version PR |
| **Version bump** | Manual trigger | Automatic | In Release PR | In Version PR |
| **CHANGELOG** | Auto-generated | Auto-generated | Auto-generated | From changesets |
| **Review gate** | Optional | None | Required (PR) | Required (PR + changeset) |
| **Complexity** | Low | Low | Medium | High |

---

## 🔗 Resources

- [Semantic Release Docs](https://semantic-release.gitbook.io/)
- [Release Please Docs](https://github.com/googleapis/release-please)
- [Changesets Docs](https://github.com/changesets/changesets)
- [Article: NPM Release Automation](https://oleksiipopov.com/blog/npm-release-automation/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## 🚀 Quick Start for Each Branch

```bash
# Try manual-release
git checkout manual-release
# Make changes, commit, then:
npm run release
git push --follow-tags

# Try auto-release
git checkout auto-release
# Make changes, commit, push - automatic release!
git push origin auto-release

# Try release-please
git checkout release-please
# Make changes, commit, push
git push origin release-please
# Review the Release PR created by bot, then merge

# Try changesets
git checkout changesets
# Make changes
npm run changeset  # Declare your changes
git commit -m "feat: feature with changeset"
git push origin changesets
# Review Version PR created by bot, then merge
```

**Explore all four approaches to find what works best for your workflow!** 🎉
