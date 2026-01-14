# Contributing to PouchPal

## Git Workflow

This repository is configured to **automatically push to GitHub after every commit**.

### How it works

A Git post-commit hook is installed that automatically runs `git push` after each successful commit. You don't need to remember to push - it happens automatically!

### Quick Commit Options

#### Option 1: Use the commit script (Recommended)
```bash
./commit.sh "Your commit message describing the change"
```

#### Option 2: Standard git commands (auto-push enabled)
```bash
git add -A
git commit -m "Your commit message"
# Push happens automatically!
```

#### Option 3: Manual push (if needed)
```bash
git push origin main
```

### Commit Message Guidelines

Use clear, descriptive commit messages:

- `feat: Add new feature description`
- `fix: Fix bug description`  
- `docs: Update documentation`
- `style: Code formatting changes`
- `refactor: Code restructuring`
- `test: Add or update tests`
- `chore: Maintenance tasks`

### Examples

```bash
./commit.sh "feat: Add dark mode support"
./commit.sh "fix: Resolve widget update timing issue"
./commit.sh "docs: Update README with setup instructions"
```

## Disabling Auto-Push

If you ever need to disable auto-push temporarily:

```bash
# Disable
chmod -x .git/hooks/post-commit

# Re-enable
chmod +x .git/hooks/post-commit
```

## Repository

🔗 **GitHub**: https://github.com/LeeAaron702/PouchPal
