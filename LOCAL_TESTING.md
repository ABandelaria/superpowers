# Testing Skills Locally (No Marketplace Upload)

Two ways to run these skills against your local Claude Code without publishing to a remote marketplace.

This repo is already a complete plugin — it ships `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`, `hooks/`, `commands/`, and `skills/`. The hooks are what make skills **auto-trigger**; skills copied without them are dead weight (see `CLAUDE.md`).

---

## Way 1 — Local marketplace (recommended)

Loads the full plugin: skills **+ hooks + commands**. Mirrors real usage.

```
/plugin marketplace add /home/bandelaria/dev/superpowers
/plugin install superpowers-extended-cc@superpowers-extended-cc-marketplace
```

Or from the shell (no session needed):

```bash
claude plugin marketplace add /home/bandelaria/dev/superpowers
claude plugin install superpowers-extended-cc@superpowers-extended-cc-marketplace
```

- `marketplace add` accepts a local path to any directory containing `.claude-plugin/marketplace.json`. No git remote required.
- After install, restart the session (or open `/plugin`) to confirm it is enabled.
- To pick up edits, see [Refreshing after edits](#refreshing-after-edits) below.

**Why recommended:** it loads `hooks/`, so the Superpowers bootstrap runs and skills auto-trigger at the right moments.

> Symlinking the repo into `~/.claude/plugins/` does **not** work. That directory is registry-managed: Claude Code only loads plugins listed in `~/.claude/plugins/installed_plugins.json`, each pointing at a versioned copy under `~/.claude/plugins/cache/`. It never scans for loose directories or symlinks.

---

## Refreshing after edits

The install is cached by version (`5.5.1-dev`), so edits to the repo do not appear until the cached copy is refreshed. Running `install` while the plugin is already installed is a no-op ("already installed") and leaves the cache stale — you must uninstall first. After each round of edits, run:

```bash
claude plugin marketplace update superpowers-extended-cc-marketplace
claude plugin uninstall superpowers-extended-cc@superpowers-extended-cc-marketplace
claude plugin install superpowers-extended-cc@superpowers-extended-cc-marketplace
```

(Or the in-session equivalents: `/plugin marketplace update ...`, `/plugin uninstall ...`, and `/plugin install ...`.)

Hooks load at session start — restart the session to pick up hook changes.

---

## Way 2 — Personal skills directory (skills only, no hooks)

Global across all projects. Quick test of a single skill.

```
mkdir -p ~/.claude/skills
cp -r /home/bandelaria/dev/superpowers/skills/* ~/.claude/skills/
rm -rf ~/.claude/skills/shared   # not a skill — see below
```

- `~/.claude/skills/` is global. Per-project would be `.claude/skills/` inside each repo (avoids copying, but must be done per project).
- **Limitation:** skills only — no hooks, so no auto-trigger. Invoke manually via `/<skill-name>` or the Skill tool. Fine for testing one skill, not for full Superpowers behavior.
- **`skills/shared/` is not a skill** — it has no SKILL.md (just `task-format-reference.md`). Don't copy it as a skill dir.
- **Cross-file references break.** Several skills reference sibling files by plugin-relative path (e.g. `skills/shared/task-format-reference.md`, brainstorming's `spec-document-reviewer-prompt.md`). Copied standalone into `~/.claude/skills/`, those paths no longer resolve. Expect degraded behavior for skills that lean on them (writing-plans, brainstorming, subagent-driven-development).

---

## Recommendation

Use **Way 1** for an accurate, hooks-included install that matches production behavior. For edit/test loops, run the commands in [Refreshing after edits](#refreshing-after-edits) after each round of edits.
