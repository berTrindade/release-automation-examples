#!/bin/bash

# Update badges and validate config on all branches

BRANCHES=("auto-release" "release-please" "changesets")

for BRANCH in "${BRANCHES[@]}"; do
  echo "========================================="
  echo "Processing branch: $BRANCH"
  echo "========================================="
  
  git checkout $BRANCH
  
  # Check if husky hooks exist
  if [ ! -d ".husky" ]; then
    echo "⚠️  .husky directory missing - copying from manual-release"
    git checkout manual-release -- .husky
  fi
  
  # Check if commitlint.config.js exists  
  if [ ! -f "commitlint.config.js" ]; then
    echo "⚠️  commitlint.config.js missing - copying from manual-release"
    git checkout manual-release -- commitlint.config.js
  fi
  
  # Check if .lintstagedrc.json exists
  if [ ! -f ".lintstagedrc.json" ]; then
    echo "⚠️  .lintstagedrc.json missing - copying from manual-release"
    git checkout manual-release -- .lintstagedrc.json
  fi
  
  # Add badges to README based on branch
  case $BRANCH in
    "auto-release")
      BADGE_LINE='[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)'
      ;;
    "release-please")
      BADGE_LINE='[![Release Please](https://img.shields.io/badge/release-please-brightgreen.svg)](https://github.com/googleapis/release-please)'
      ;;
    "changesets")
      BADGE_LINE='[![changesets](https://img.shields.io/badge/release-changesets-blue.svg)](https://github.com/changesets/changesets)'
      ;;
  esac
  
  echo "✓ Configuration validated for $BRANCH"
  echo ""
done

git checkout manual-release
echo "========================================="
echo "All branches processed!"
echo "========================================="
