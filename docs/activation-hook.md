# Activation hook (Claude Code, Copilot CLI)

Skills load when the model decides to load them. On Claude Code and Copilot CLI, the repo is also a plugin whose `PreToolUse` hook denies the first GitHub write tool call (`create_pull_request`, `gh pr create`, and similar) until the skill has loaded, then gets out of the way. It checks nothing about the body; the mechanical checks in `references/self-check.md` stay the model's job. If the hook itself errors it fails open with a warning.

The gate ships twice with identical logic, and `hooks/hooks.json` picks the right one:

| Host | Runs | Needs |
|---|---|---|
| Claude Code | `hooks/gate.sh` through the `command` field | `bash` (Git for Windows on Windows, which Claude Code already requires by default) |
| Copilot CLI on macOS, Linux | `hooks/gate.sh` through the `bash` field | `bash` |
| Copilot CLI on Windows | `hooks/gate.ps1` through the `powershell` field | nothing extra; it runs on the Windows PowerShell 5.1 that ships with Windows, and on PowerShell 7 |

Neither gate needs `jq`.

Claude Code on Windows without Git for Windows has no `bash` to run `gate.sh`, so the plugin's hook errors without blocking and the gate never runs. Claude Code falls back to PowerShell there, so register the PowerShell gate yourself in `~/.claude/settings.json`, with the path to your checkout, and don't install the plugin hooks alongside it:

```json
{
  "hooks": {
    "PreToolUse": [{ "matcher": "Bash|(.*(__|-))?(create_pull_request|update_pull_request|add_pr_review_comment|edit_pr_review_comment|reply_to_comment|reply_and_resolve_review_thread)", "hooks": [{ "type": "command", "shell": "powershell", "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\path\\to\\lowly-writing-framework\\hooks\\gate.ps1\"" }] }],
    "PostToolUse": [{ "matcher": "Skill|skill", "hooks": [{ "type": "command", "shell": "powershell", "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\path\\to\\lowly-writing-framework\\hooks\\gate.ps1\"" }] }]
  }
}
```

> [!WARNING]
> Copilot CLI [fails closed](https://docs.github.com/en/copilot/reference/hooks-reference) when a `preToolUse` command crashes or exits non-zero, so a missing `bash` there would deny every matching `Bash` call. The gates deny with exit code 2 and also print the `permissionDecision` JSON Copilot reads for the reason. Copilot runs the `powershell` field through `pwsh -c`, which turns any native exit code into 1, so that command ends in `exit $LASTEXITCODE`.

Which OS, harness, and model combinations have been tested: [hook-verification.md](hook-verification.md).

```sh
claude --plugin-dir <path-to-this-checkout>
```