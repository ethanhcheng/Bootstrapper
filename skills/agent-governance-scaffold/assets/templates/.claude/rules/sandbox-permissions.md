# Sandbox And Safety

- Prefer non-destructive exploration commands.
- Never print or persist secrets from env or config files.
- Scope searches to source directories. Exclude dependency, build, version-control, and worktree directories (`node_modules`, `dist`, `.git`, `.claude/worktrees`, virtualenvs).
