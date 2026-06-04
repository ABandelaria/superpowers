# Testing Skills Locally (No Marketplace Upload)

Three ways to run these skills against your local Claude Code without publishing to a remote marketplace.

This repo is already a complete plugin — it ships `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`, `hooks/`, `commands/`, and `skills/`. The hooks are what make skills **auto-trigger**; skills copied without them are dead weight (see `CLAUDE.md`).

---

## Way 1 — Local marketplace (recommended)

Loads the full plugin: skills **+ hooks + commands**. Mirrors real usage.

```
/plugin marketplace add /home/bandelaria/dev/superpowers
/plugin install superpowers-extended-cc@superpowers-extended-cc-marketplace
```

- `marketplace add` accepts a local path to any directory containing `.claude-plugin/marketplace.json`. No git remote required.
- After install, restart the session (or open `/plugin`) to confirm it is enabled.
- To pick up edits: re-run install, or `/plugin marketplace update`.

**Why recommended:** it loads `hooks/`, so the Superpowers bootstrap runs and skills auto-trigger at the right moments.

---

## Way 2 — ~~Symlink the plugin into `~/.claude/plugins/`~~ (does not work)

Symlinking a directory into `~/.claude/plugins/` does **not** load a plugin. That directory is registry-managed: Claude Code only loads plugins listed in `~/.claude/plugins/installed_plugins.json`, each pointing at a versioned copy under `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>`. It never scans for loose directories or symlinks.

**Iteration loop instead:** use Way 1, then after each round of edits:

```
/plugin marketplace update superpowers-extended-cc-marketplace
/plugin install superpowers-extended-cc@superpowers-extended-cc-marketplace
```

Because the install is cached by version (`5.5.1-dev`), re-running update + install refreshes the cached copy from the local repo.

---

## Way 3 — Personal skills directory (skills only, no hooks)

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

Use **Way 1** for an accurate, hooks-included install that matches production behavior. For edit/test loops, re-run `marketplace update` + `install` after each round of edits (see Way 2 section).
