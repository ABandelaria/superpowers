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

## Way 2 — Symlink the plugin into `~/.claude/plugins/`

Fastest iteration — repo edits are reflected instantly with no reinstall.

```
ln -s /home/bandelaria/dev/superpowers ~/.claude/plugins/superpowers-extended-cc
```

- Edits in the repo show up live via the symlink.
- Whether hooks/commands load depends on your Claude Code version reading the plugins directory. Confirm with `/plugin`. If not picked up, fall back to Way 1.

---

## Way 3 — Personal skills directory (skills only, no hooks)

Global across all projects. Quick test of a single skill.

```
cp -r /home/bandelaria/dev/superpowers/skills/* ~/.claude/skills/
```

- `~/.claude/skills/` is global. Per-project would be `.claude/skills/` inside each repo (avoids copying, but must be done per project).
- **Limitation:** skills only — no hooks, so no auto-trigger. Invoke manually via `/<skill-name>` or the Skill tool. Fine for testing one skill, not for full Superpowers behavior.

---

## Recommendation

Use **Way 1** for an accurate, hooks-included install that matches production behavior. Use **Way 2** for fast edit/test loops if your Claude Code version honors symlinked plugins.
