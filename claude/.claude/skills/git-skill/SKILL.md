---
name: git-skill
description:
  Handles git operations like commit and push. Use when the user requests git
  commands such as "git commit", "git push", or other git operations. Creates
  conventional commit messages following conventionalcommits.org format.
---

# Git Operations

## Instructions

When the user requests git operations (commit, push, pull, status, etc.), handle
them according to these guidelines:

### Conventional Commits Format

All commit messages MUST follow the Conventional Commits specification
(https://www.conventionalcommits.org/en/v1.0.0/):

**Structure:**

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (white-space, formatting,
  etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes affecting build system or external dependencies
- `ci`: Changes to CI configuration files and scripts
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

**Rules:**

1. Keep the description concise (50 characters or less preferred, 72 max)
2. Use imperative mood ("add feature" not "added feature")
3. Don't capitalize first letter of description
4. No period at the end of description
5. Body should explain what and why, not how (if needed)

**Examples:**

```
feat: add user authentication
fix: resolve memory leak in data processor
docs: update API documentation
refactor: simplify validation logic
```

### No Attribution

NEVER include attribution in commit messages:

- No "Co-authored-by: Claude"
- No "Generated with Claude Code"
- No similar attribution or signatures

### Grouping Changes into Commits

When there are multiple changes, analyze whether they should be grouped into
separate commits:

**Consider both commit type AND file/area:**

- **By type:** Separate different conventional commit types (`feat`, `fix`,
  `docs`, `refactor`, etc.)
- **By area:** Separate unrelated functionality (frontend vs backend, different
  features, different components)

**Guidelines:**

- Create separate commits when changes are logically independent
- Keep related changes together even if they span multiple files
- A single feature touching multiple files = one commit
- Multiple unrelated fixes = separate commits
- Code changes vs documentation = separate commits

**Examples of splitting:**

- `feat: add user profile` + `fix: login bug` → 2 commits
- `feat: dashboard` + `feat: settings page` → 2 commits
- `refactor: auth logic` + `docs: update README` → 2 commits
- Frontend component + backend API for same feature → 1 commit

### Git Commit Process

When creating commits:

1. Run `git status` to see all changes
2. Run `git diff` to review the changes
3. **Analyze if changes should be split into multiple commits** (see "Grouping
   Changes into Commits" above)
4. **For each logical group:**
   - Determine the appropriate conventional commit type
   - Draft a concise commit message following the format above
   - Add relevant files with `git add <files>`
   - Create the commit with `git commit -m "<message>"`
5. Verify all changes are committed with `git status`

### Git Push Process

When pushing:

1. Verify there are commits to push with `git status`
2. Push using `git push` or `git push -u origin <branch>` for new branches
3. Report the result to the user

### Other Git Operations

Handle other git commands (pull, status, log, branch, etc.) as requested by the
user with appropriate bash commands.
