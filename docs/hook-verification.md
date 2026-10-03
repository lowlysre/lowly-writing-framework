# Activation hook verification

What has been tested, by functionality and surface. The [README](../README.md) and [activation-hook.md](activation-hook.md) cover what the hook does and how to install it.

✅ runs in CI, 🖐 run by hand, ❌ not tested, — doesn't apply.

Rows: gate logic is deny-once-then-allow in both gates; config consistency is hooks.json structure, matchers, and tool lists; hook commands is each command, ash, and powershell string run with the right exit code; live deny, then allow is a real harness blocking gh pr create and accepting the retry after the skill loads.

| Functionality | Claude Code Linux | Claude Code macOS | Claude Code Windows | Copilot CLI Linux | Copilot CLI macOS | Copilot CLI Windows |
|---|---|---|---|---|---|---|
| Gate logic | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Config consistency | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Hook commands | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Live deny, then allow | ❌ | ❌ | ❌ | ❌ | ❌ | 🖐 |
| No-Git-Bash override | — | — | ❌ | — | — | — |

Two limits on that table. The CI rows run the hook commands directly under the OS shell, not through a harness. Claude Code isn't covered at all beyond that, because it needs a logged-in session; the Claude snippets in [activation-hook.md](activation-hook.md) are untested. The live Copilot run loaded the Copilot snippet from a user-level hooks file on Windows.

The live Copilot CLI run used 1.0.91. The gate itself doesn't depend on the model, but whether the model loads the skill after a denial does:

| Model | Claude Code | Copilot CLI |
|---|---|---|
| `gpt-5-mini` | — | 🖐 Windows only: loaded the skill and retried |
| Claude models | ❌ | ❌ |
| Other models | ❌ | ❌ |
