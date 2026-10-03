# Activation hook verification

What has been tested, by functionality and surface. The [README](../README.md#optional-activation-hook-claude-code-copilot-cli) covers what the hook does and how to install it.

What's verified, by functionality and surface. ✅ runs in CI, 🖐 run by hand, ❌ not tested, — doesn't apply.

| Functionality | Claude Code Linux | Claude Code macOS | Claude Code Windows | Copilot CLI Linux | Copilot CLI macOS | Copilot CLI Windows |
|---|---|---|---|---|---|---|
| Gate denies once, then allows after the skill loads (`gate.sh` and `gate.ps1` fed fixtures) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `hooks.json` structure, matchers, and tool lists agree | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Each `command`, `bash`, and `powershell` string runs with the right exit code | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Plugin manifest is valid or installs | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Live harness loads the hooks, denies `gh pr create` with the reason, and allows the retry | ❌ | ❌ | ❌ | ❌ | ❌ | 🖐 |
| Windows without Git Bash, using the `settings.json` snippet above | — | — | ❌ | — | — | — |

Two limits on that table. The CI rows run the hook commands directly under the OS shell, not through a harness. `claude plugin validate` doesn't inspect hooks, so Claude Code's handling of the extra `bash` and `powershell` fields is untested until someone runs it in a logged-in session.

The live Copilot CLI run used 1.0.91. The gate itself doesn't depend on the model, but whether the model loads the skill after a denial does:

| Model | Claude Code | Copilot CLI |
|---|---|---|
| `gpt-5-mini` | — | 🖐 Windows only: loaded the skill and retried |
| Claude models | ❌ | ❌ |
| Other models | ❌ | ❌ |
