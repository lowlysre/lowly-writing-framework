BeforeAll {
    $script:root = Split-Path $PSScriptRoot -Parent
    $script:stateDir = Join-Path ([IO.Path]::GetTempPath()) 'lowly-writing-framework'
    function script:Invoke-Gate($Name, $Event) {
        $json = $Event | ConvertTo-Json -Depth 5 -Compress
        $path = Join-Path $script:root "hooks/$Name"
        $out = if ($Name -like '*.sh') { $json | & bash $path 2>&1 } else { $json | & pwsh -NoProfile -File $path 2>&1 }
        [pscustomobject]@{ Code = $LASTEXITCODE; Output = ($out -join "`n") }
    }
    function script:New-Event($Name, $Session, $Tool, $ToolInput) {
        @{ hook_event_name = $Name; session_id = $Session; tool_name = $Tool; tool_input = $ToolInput }
    }
}

Describe '<gate>' -ForEach @(@{ gate = 'gate.ps1' }, @{ gate = 'gate.sh' }) {
    BeforeEach { $script:sid = "t-$([guid]::NewGuid())" }
    AfterEach { Remove-Item (Join-Path $script:stateDir "$($script:sid).*") -ErrorAction SilentlyContinue }

    It 'denies a GitHub write tool once, then allows the retry' {
        $e = New-Event PreToolUse $script:sid 'create_pull_request' @{ title = 't' }
        $first = Invoke-Gate $gate $e
        $first.Code | Should -Be 2
        $first.Output | Should -Match 'Load the lowly-writing-framework skill'
        (Invoke-Gate $gate $e).Code | Should -Be 0
    }
    It 'matches MCP-prefixed tool names' {
        (Invoke-Gate $gate (New-Event PreToolUse $script:sid 'mcp__github__add_pr_review_comment' @{ body = 'x' })).Code | Should -Be 2
    }
    It 'denies gh write commands through Bash' {
        (Invoke-Gate $gate (New-Event PreToolUse $script:sid 'Bash' @{ command = 'gh pr create --title t' })).Code | Should -Be 2
    }
    It 'ignores unrelated Bash commands and tools' {
        (Invoke-Gate $gate (New-Event PreToolUse $script:sid 'Bash' @{ command = 'gh pr view 1' })).Code | Should -Be 0
        (Invoke-Gate $gate (New-Event PreToolUse $script:sid 'Edit' @{ file_path = 'a' })).Code | Should -Be 0
    }
    It 'allows the first write once the skill has loaded' {
        (Invoke-Gate $gate (New-Event PostToolUse $script:sid 'Skill' @{ skill = 'lowly-writing-framework' })).Code | Should -Be 0
        (Invoke-Gate $gate (New-Event PreToolUse $script:sid 'create_pull_request' @{ title = 't' })).Code | Should -Be 0
    }
    It 'does not count a different skill as loaded' {
        (Invoke-Gate $gate (New-Event PostToolUse $script:sid 'Skill' @{ skill = 'other' })).Code | Should -Be 0
        (Invoke-Gate $gate (New-Event PreToolUse $script:sid 'create_pull_request' @{ title = 't' })).Code | Should -Be 2
    }
}
