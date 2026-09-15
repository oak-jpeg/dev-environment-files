## Claude Code hooks

[`.claude/hooks/`](.claude/hooks/) — Claude Code hook scripts, stowed to `~/.claude/hooks/`:

- `claude-on-busy.sh` / `claude-on-idle.sh` / `claude-on-waiting.sh` — write the current session's state (busy/idle/waiting) to `~/.claude/run/state/<session_id>.state`
- `claude-statusline.sh` — reads that state file to render Claude Code's own status line
- `claude-pretool-check.sh` — a `PreToolUse` (Bash matcher) hook that blocks starting a dev server (`npm run dev`, `next dev`, etc.) when one for the same project is already listening on its port, instead of letting a duplicate pile up

These originally lived under a tmux package (a couple of them also nudge tmux to refresh its status line via `tmux refresh-client`, guarded by `[ -n "$TMUX" ]`), but none of them actually require tmux — they're plain Claude Code hooks that degrade gracefully without it. Moved here so they survive independently of whatever terminal/multiplexer setup is in use.

`settings.json.reference` is a **reference copy** of the live `~/.claude/settings.json`, not stowed — that file loads at Claude Code startup, so it's kept as a plain reviewed file rather than a symlink to avoid a `git pull` silently changing live startup behavior. Update it by hand after editing the real file.
