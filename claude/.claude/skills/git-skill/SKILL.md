---
name: git-skill
description: Git operations with conventional commits.
TRIGGER: git commit, git push, git status, commit changes
---

# Git Operations

Handle git operations using
[Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | Description                | SemVer |
| ---------- | -------------------------- | ------ |
| `feat`     | New feature                | MINOR  |
| `fix`      | Bug fix                    | PATCH  |
| `docs`     | Documentation only         |        |
| `style`    | Formatting, no code change |        |
| `refactor` | Neither fix nor feature    |        |
| `perf`     | Performance improvement    |        |
| `test`     | Adding/correcting tests    |        |
| `build`    | Build system, dependencies |        |
| `ci`       | CI configuration           |        |
| `chore`    | Other non-src/test changes |        |
| `revert`   | Reverts a previous commit  |        |

### Rules

1. Description: imperative mood, lowercase, no period, ≤72 chars
2. Scope: noun in parentheses describing affected area, e.g., `feat(parser):`
3. Body: explain _what_ and _why_, not _how_ (blank line after description)
4. Footer: use for breaking changes, issue refs, co-authors

### Examples

```
feat: add user authentication

fix: resolve memory leak in data processor

docs: correct spelling of CHANGELOG

feat(lang): add Polish language

fix: prevent racing of requests

Introduce a request id and a reference to latest request.
Dismiss incoming responses other than from latest request.

Refs: #123

revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

## Commit Workflow

1. `git status` — review all changes
2. `git diff [--staged]` — understand what changed
3. **Analyze grouping** — split if changes are logically independent:
   - Different types (`feat` + `fix` → 2 commits)
   - Unrelated areas (frontend + backend for different features → 2 commits)
   - Keep related changes together (one feature across multiple files → 1
     commit)
4. **For each logical group:**
   - Stage specific files: `git add <files>` (never blind `git add .`)
   - Commit: `git commit -m "<message>"`
5. `git status` — verify completion

## Rules

### No Attribution

Never include:

- `Co-authored-by: Claude`
- `Generated with Claude Code`
- Any AI attribution

### Pre-commit Checks

Before committing, consider:

- Exclude `.env`, credentials, secrets
- Run tests/linting if project has them
- Check for unintended files with `git status`

### Amending

```
git commit --amend           # edit message and content
git commit --amend --no-edit # keep message, add staged changes
```

⚠️ Warn user if commit was already pushed (requires `--force`).

### Push

```
git push                        # existing upstream
git push -u origin <branch>     # new branch
```
