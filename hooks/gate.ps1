<#
.SYNOPSIS
Claude Code and Copilot CLI hook dispatcher for lowly-writing-framework (PowerShell twin of gate.sh).
Runs on Windows PowerShell 5.1 and PowerShell 7.
.DESCRIPTION
PostToolUse(Skill): records that the skill loaded this session.
PreToolUse on GitHub write tools and `gh` write commands: denies once if the skill hasn't loaded.
Fails open: any internal error prints a warning to stderr and exits 0.
Keep the matching logic in step with gate.sh.
#>
$ErrorActionPreference = 'Stop'
$stateDir = Join-Path ([IO.Path]::GetTempPath()) 'lowly-writing-framework'

try {
    $in = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $session = $in.session_id -replace '[^\w-]', '_'
    New-Item -ItemType Directory -Force $stateDir | Out-Null
    $loaded = Join-Path $stateDir "$session.loaded"
    $nudged = Join-Path $stateDir "$session.nudged"

    if ($in.hook_event_name -eq 'PostToolUse') {
        if ($in.tool_name -eq 'Skill' -or $in.tool_name -eq 'skill') {
            if ($in.tool_input.skill -match 'lowly-writing-framework') { New-Item -Force $loaded | Out-Null }
        }
        exit 0
    }

    $tool = $in.tool_name -replace '^.*(__|-)', ''
    $isWrite = $false
    switch -Regex ($tool) {
        '^(create_pull_request|update_pull_request|add_pr_review_comment|edit_pr_review_comment|reply_to_comment|reply_and_resolve_review_thread)$' { $isWrite = $true }
        '^Bash$' { $isWrite = [string]$in.tool_input.command -match '\bgh\s+(pr|issue|discussion)\s+(create|edit|comment|review)\b' }
    }
    if (-not $isWrite) { exit 0 }

    if (-not (Test-Path $loaded) -and -not (Test-Path $nudged)) {
        New-Item -Force $nudged | Out-Null
        $msg = 'Load the lowly-writing-framework skill before writing this artifact, then retry. This reminder fires once per session.'
        # Copilot CLI reads the reason from stdout JSON; Claude Code reads stderr on exit 2.
        [Console]::Out.WriteLine((@{ permissionDecision = 'deny'; permissionDecisionReason = $msg } | ConvertTo-Json -Compress))
        [Console]::Error.WriteLine($msg)
        exit 2
    }
    exit 0
}
catch {
    [Console]::Error.WriteLine("lowly-writing-framework hook error (failing open): $_")
    exit 0
}
