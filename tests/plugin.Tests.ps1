BeforeDiscovery {
    $script:isWin = $IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop'
    $script:hasBash = [bool](Get-Command bash -ErrorAction SilentlyContinue)
}

BeforeAll {
    $script:root = Split-Path $PSScriptRoot -Parent
    $script:stateDir = Join-Path ([IO.Path]::GetTempPath()) 'lowly-writing-framework'
    $script:hooks = (Get-Content (Join-Path $script:root 'hooks/hooks.json') -Raw | ConvertFrom-Json).hooks
    $script:pre = $script:hooks.PreToolUse[0]
    $script:post = $script:hooks.PostToolUse[0]
    $script:writeTools = 'create_pull_request', 'update_pull_request', 'add_pr_review_comment', 'edit_pr_review_comment', 'reply_to_comment', 'reply_and_resolve_review_thread'

    # Both harnesses substitute the plugin-root placeholders in the command text before running it.
    function script:Expand($Command) {
        $Command.Replace('${PLUGIN_ROOT}', $script:root).Replace('${CLAUDE_PLUGIN_ROOT}', $script:root)
    }
    function script:Invoke-Hook($Shell, $Command, $Payload) {
        $json = $Payload | ConvertTo-Json -Depth 5 -Compress
        $text = Expand $Command
        $out = if ($Shell -eq 'powershell') { $json | & pwsh -NoProfile -c $text 2>&1 } else { $json | & bash -c $text 2>&1 }
        [pscustomobject]@{ Code = $LASTEXITCODE; Output = ($out -join "`n") }
    }
    function script:New-Pre($Session, $Tool, $ToolInput) {
        @{ hook_event_name = 'PreToolUse'; session_id = $Session; tool_name = $Tool; tool_input = $ToolInput }
    }
}

Describe 'hooks.json structure' {
    It 'declares a command hook with command, bash, and powershell for <event>' -ForEach @(@{ event = 'PreToolUse' }, @{ event = 'PostToolUse' }) {
        $entry = $script:hooks.$event[0]
        $entry.matcher | Should -Not -BeNullOrEmpty
        $h = $entry.hooks[0]
        $h.type | Should -Be 'command'
        $h.command | Should -Match 'gate\.sh'
        $h.bash | Should -Match 'gate\.sh'
        $h.powershell | Should -Match 'gate\.ps1'
    }
    It 'references scripts that exist' {
        foreach ($rel in 'hooks/gate.sh', 'hooks/gate.ps1', '.claude-plugin/plugin.json') {
            Test-Path (Join-Path $script:root $rel) | Should -BeTrue -Because $rel
        }
    }
    It 'keeps the placeholder names each harness substitutes' {
        $h = $script:pre.hooks[0]
        $h.command | Should -Match '\$\{CLAUDE_PLUGIN_ROOT\}'
        $h.bash | Should -Match '\$\{PLUGIN_ROOT\}'
        $h.powershell | Should -Match '\$\{PLUGIN_ROOT\}'
    }
    It 'forwards the gate exit code from the powershell command' {
        # Copilot runs this through `pwsh -c`, which reports 1 for any failed native command and would lose exit code 2.
        $script:pre.hooks[0].powershell | Should -Match 'exit \$LASTEXITCODE\s*$'
    }
    It 'marks gate.sh executable in git' -Skip:(-not (Get-Command git -ErrorAction SilentlyContinue)) {
        (git -C $script:root ls-files -s hooks/gate.sh) | Should -Match '^100755'
    }
}

Describe 'matchers' {
    # Copilot anchors a non-literal matcher as ^(?:PATTERN)$ against the tool name.
    It 'PreToolUse matches <tool>' -ForEach @(
        @{ tool = 'Bash' }, @{ tool = 'create_pull_request' }, @{ tool = 'mcp__github__add_pr_review_comment' },
        @{ tool = 'github-mcp-server-reply_to_comment' }, @{ tool = 'reply_and_resolve_review_thread' }
    ) {
        $tool | Should -Match "^(?:$($script:pre.matcher))`$"
    }
    It 'PreToolUse ignores <tool>' -ForEach @(
        @{ tool = 'Edit' }, @{ tool = 'Read' }, @{ tool = 'create_pull_request_extra' }, @{ tool = 'create_issue' }
    ) {
        $tool | Should -Not -Match "^(?:$($script:pre.matcher))`$"
    }
    It 'PostToolUse matches the skill tool in both harnesses' {
        'Skill' | Should -Match "^(?:$($script:post.matcher))`$"
        'skill' | Should -Match "^(?:$($script:post.matcher))`$"
        'Bash' | Should -Not -Match "^(?:$($script:post.matcher))`$"
    }
    It 'lists the same write tools as both gates' {
        $inMatcher = ([regex]::Match($script:pre.matcher, '\((create_pull_request[^)]*)\)').Groups[1].Value -split '\|') | Sort-Object
        $inSh = ([regex]::Match((Get-Content (Join-Path $script:root 'hooks/gate.sh') -Raw), '(create_pull_request[^)]*)\)').Groups[1].Value -split '\|') | Sort-Object
        $inPs = ([regex]::Match((Get-Content (Join-Path $script:root 'hooks/gate.ps1') -Raw), '\^\((create_pull_request[^)]*)\)\$').Groups[1].Value -split '\|') | Sort-Object
        $inMatcher | Should -Be ($script:writeTools | Sort-Object)
        $inSh | Should -Be $inMatcher
        $inPs | Should -Be $inMatcher
    }
}

Describe 'hook commands as the harness runs them' {
    BeforeEach { $script:sid = "p-$([guid]::NewGuid())" }
    AfterEach { Remove-Item (Join-Path $script:stateDir "$($script:sid).*") -ErrorAction SilentlyContinue }

    It 'runs the <field> command: deny, then allow after the skill loads' -ForEach @(
        @{ field = 'command'; shell = 'bash' }
        @{ field = 'bash'; shell = 'bash' }
    ) -Skip:(-not $script:hasBash) {
        $cmd = $script:pre.hooks[0].$field
        $deny = Invoke-Hook $shell $cmd (New-Pre $script:sid 'Bash' @{ command = 'gh pr create --title t' })
        $deny.Code | Should -Be 2
        $deny.Output | Should -Match 'Load the lowly-writing-framework skill'
        $load = @{ hook_event_name = 'PostToolUse'; session_id = $script:sid; tool_name = 'skill'; tool_input = @{ skill = 'lowly-writing-framework' } }
        (Invoke-Hook $shell $script:post.hooks[0].$field $load).Code | Should -Be 0
        (Invoke-Hook $shell $cmd (New-Pre $script:sid 'Bash' @{ command = 'gh pr create --title t' })).Code | Should -Be 0
    }
    It 'runs the powershell command under Windows PowerShell and keeps exit code 2' -Skip:(-not $script:isWin) {
        $cmd = $script:pre.hooks[0].powershell
        $deny = Invoke-Hook 'powershell' $cmd (New-Pre $script:sid 'Bash' @{ command = 'gh pr create --title t' })
        $deny.Code | Should -Be 2
        $deny.Output | Should -Match 'permissionDecision'
        (Invoke-Hook 'powershell' $cmd (New-Pre $script:sid 'Bash' @{ command = 'gh pr view 1' })).Code | Should -Be 0
    }
}
