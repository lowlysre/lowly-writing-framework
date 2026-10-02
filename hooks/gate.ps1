#requires -Version 7
<#
.SYNOPSIS
Claude Code hook dispatcher for lowly-writing-framework.
.DESCRIPTION
PostToolUse(Skill): records that the skill loaded this session.
PreToolUse on GitHub write tools and `gh` write commands: denies once if the skill hasn't loaded,
then runs scripts/check-artifact.ps1 on the body and denies on ERROR findings.
Fails open: any internal error prints a warning to stderr and exits 0.
#>
$ErrorActionPreference = 'Stop'
$checker = Join-Path $PSScriptRoot '..\scripts\check-artifact.ps1'
$stateDir = Join-Path ([IO.Path]::GetTempPath()) 'lowly-writing-framework'

try {
    $in = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $session = $in.session_id -replace '[^\w-]', '_'
    New-Item -ItemType Directory -Force $stateDir | Out-Null
    $loaded = Join-Path $stateDir "$session.loaded"
    $nudged = Join-Path $stateDir "$session.nudged"

    if ($in.hook_event_name -eq 'PostToolUse') {
        if ($in.tool_name -eq 'Skill' -and $in.tool_input.skill -match 'lowly-writing-framework') { New-Item -Force $loaded | Out-Null }
        exit 0
    }

    $tool = $in.tool_name -replace '^.*__', ''
    $kind = $null; $body = $null
    switch -Regex ($tool) {
        '^(create|update)_pull_request$' { $kind = 'pr'; $body = $in.tool_input.body; break }
        '^(add_pr_review_comment|edit_pr_review_comment)$' { $kind = 'review'; $body = $in.tool_input.body; break }
        '^(reply_to_comment|reply_and_resolve_review_thread)$' { $kind = 'review'; $body = $in.tool_input.response ?? $in.tool_input.body; break }
        '^Bash$' {
            $cmd = [string]$in.tool_input.command
            if ($cmd -notmatch '\bgh\s+(pr|issue|discussion)\s+(create|edit|comment|review)\b') { exit 0 }
            $kind = if ($cmd -match '\bgh\s+pr\s+(comment|review)\b') { 'review' } elseif ($cmd -match '\bgh\s+pr\b') { 'pr' } else { 'issue' }
            # Only `--body-file`/`-F` paths are inspectable; inline bodies get the skill-loaded check alone.
            if ($cmd -match '(?:--body-file|-F)\s+"?([^"\s]+)"?' -and (Test-Path -LiteralPath $Matches[1])) { $body = Get-Content -Raw -LiteralPath $Matches[1] }
            break
        }
        default { exit 0 }
    }

    if (-not (Test-Path $loaded) -and -not (Test-Path $nudged)) {
        New-Item -Force $nudged | Out-Null
        [Console]::Error.WriteLine('Load the lowly-writing-framework skill before writing this artifact, then retry. This reminder fires once per session.')
        exit 2
    }

    if ($body) {
        $out = $body | & pwsh -NoProfile -File $checker -Kind $kind
        $errors = @($out | Where-Object { $_ -like 'ERROR*' })
        if ($LASTEXITCODE -ne 0 -and $errors) {
            [Console]::Error.WriteLine("lowly-writing-framework checks failed for this $kind body. Fix and retry:`n" + ($out -join "`n"))
            exit 2
        }
    }
    exit 0
}
catch {
    [Console]::Error.WriteLine("lowly-writing-framework hook error (failing open): $_")
    exit 0
}
