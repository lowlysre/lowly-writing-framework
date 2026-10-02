# Defined twice on purpose: Pester evaluates -ForEach data at discovery, before BeforeAll runs.
$script:Long = ' with enough words to clear the short-line warning threshold of ninety characters easily.'
$script:Wm = "`n`n<!--:robot:-->"

BeforeAll {
    $script:Long = ' with enough words to clear the short-line warning threshold of ninety characters easily.'
    $script:Wm = "`n`n<!--:robot:-->"
    $script:root = Split-Path $PSScriptRoot -Parent
    function script:Invoke-Gate($Event) {
        $json = $Event | ConvertTo-Json -Depth 5 -Compress
        $err = $json | & pwsh -NoProfile -File (Join-Path $script:root 'hooks/gate.ps1') 2>&1
        [pscustomobject]@{ Code = $LASTEXITCODE; Output = ($err -join "`n") }
    }
    function script:Invoke-Checker($Kind, $Text) {
        $out = $Text | & pwsh -NoProfile -File (Join-Path $script:root 'scripts/check-artifact.ps1') -Kind $Kind
        [pscustomobject]@{ Code = $LASTEXITCODE; Output = ($out -join "`n") }
    }
    function script:New-Pre($Session, $Tool, $ToolInput) {
        @{ hook_event_name = 'PreToolUse'; session_id = $Session; tool_name = $Tool; tool_input = $ToolInput }
    }
}

# One bad and one clean input per self-check.md check, so a rule changed in prose but not here fails CI.
Describe 'check-artifact.ps1' {
    It 'flags <name> and passes the clean form' -ForEach @(
        @{ name = 'hand-built issue URL'; kind = 'issue'; bad = 'See https://github.com/o/r/pull/4#issue-99'; good = 'See https://github.com/o/r/issues/4' }
        @{ name = 'bare #N'; kind = 'issue'; bad = 'Tracks #12'; good = 'Tracks o/r#12' }
        @{ name = 'owner-less reference'; kind = 'issue'; bad = 'Tracks r#12'; good = 'Tracks o/r#12' }
        @{ name = 'backticked reference'; kind = 'issue'; bad = 'Tracks `o/r#12`'; good = 'Tracks o/r#12' }
        @{ name = 'narrative wording'; kind = 'doc'; bad = 'This was previously a thing'; good = 'This is a thing' }
    ) {
        (Invoke-Checker $kind ($bad + $script:Long)).Code | Should -Be 1
        (Invoke-Checker $kind ($good + $script:Long)).Code | Should -Be 0
    }
    It 'flags a decorated review label' {
        (Invoke-Checker review ("**nitpick:** x" + $script:Wm)).Code | Should -Be 1
        (Invoke-Checker review ("nitpick: x" + $script:Wm)).Code | Should -Be 0
    }
    It 'flags a missing watermark' {
        (Invoke-Checker pr ('Fixes o/r#1' + $script:Long)).Output | Should -Match 'AI watermark'
        (Invoke-Checker pr ('Fixes o/r#1' + $script:Long + $script:Wm)).Code | Should -Be 0
    }
    It 'requires a review comment to open with a label' {
        (Invoke-Checker review ('Looks off.' + $script:Wm)).Output | Should -Match 'conventional-comments label'
    }
    It 'ignores matches inside fenced blocks and inline code' {
        (Invoke-Checker issue ("``````n#12 and previously`n``````n`n" + 'Run `#12` here' + $script:Long)).Output | Should -Not -Match 'bare #N'
    }
    It 'warns without failing on <name>' -ForEach @(
        @{ name = 'a missing closing keyword'; kind = 'pr'; text = "Just a change.$($script:Long)$($script:Wm)"; match = 'closing keyword' }
        @{ name = 'non-closing phrasing'; kind = 'pr'; text = "Part of o/r#4.$($script:Long)$($script:Wm)"; match = 'non-closing' }
        @{ name = 'a bare URL'; kind = 'issue'; text = "See https://example.com/x$($script:Long)"; match = 'bare URL' }
        @{ name = 'a backtick pileup'; kind = 'issue'; text = "Uses ``a``, ``b``, ``c``, ``d``$($script:Long)"; match = 'backticked identifiers' }
        @{ name = 'a hard-wrapped line'; kind = 'doc'; text = "short line`nanother short line"; match = 'hard-wrapped' }
        @{ name = 'a banned phrase'; kind = 'doc'; text = "This is a seamless change$($script:Long)"; match = 'banned phrase' }
        @{ name = 'an over-long body'; kind = 'issue'; text = ('x' * 3100); match = 'ceiling' }
    ) {
        $r = Invoke-Checker $kind $text
        $r.Output | Should -Match $match
        $r.Code | Should -Be 0
    }
    It 'excludes mermaid blocks from the length ceiling' {
        (Invoke-Checker issue ("``````mermaid`n" + ('x' * 3100) + "`n``````")).Output | Should -Not -Match 'ceiling'
    }
    It 'flags a comment block over four lines' {
        (Invoke-Checker comment ((1..5 | ForEach-Object { "# line $_" }) -join "`n")).Output | Should -Match 'comment block of 5'
    }
}

Describe 'banned-phrases.md parsing' {
    It 'still yields the bold terms the checker depends on' {
        # Canary: a reformatted bullet would silently drop terms from the checker.
        $text = Get-Content (Join-Path $script:root 'references/banned-phrases.md') -Raw
        $count = ([regex]::Matches($text, '(?m)^- (?:\*\*[^*]+\*\*(?: / )?)+:')).Count
        $count | Should -BeGreaterThan 40
        foreach ($t in 'seamless', 'Additionally,', 'in order to') {
            (Invoke-Checker doc ("This has $t in it$($script:Long)")).Output | Should -Match 'banned phrase'
        }
    }
}

Describe 'plugin wiring' {
    BeforeAll {
        $script:hooks = Get-Content -Raw (Join-Path $script:root 'hooks/hooks.json') | ConvertFrom-Json
        $script:matcher = $script:hooks.hooks.PreToolUse[0].matcher
    }
    It 'matcher covers every GitHub write tool, bare and MCP-prefixed, and Bash' -ForEach @(
        'Bash', 'create_pull_request', 'mcp__github__update_pull_request', 'add_pr_review_comment',
        'edit_pr_review_comment', 'reply_to_comment', 'reply_and_resolve_review_thread'
    ) {
        $_ | Should -Match "^($script:matcher)$"
    }
    It 'matcher ignores unrelated tools' -ForEach @('Read', 'Edit', 'mcp__github__get_file_contents') {
        $_ | Should -Not -Match "^($script:matcher)$"
    }
    It 'registers the Skill marker under PostToolUse' {
        $script:hooks.hooks.PostToolUse[0].matcher | Should -Be 'Skill|skill'
    }
    It 'points every command at an existing script' {
        $cmds = @($script:hooks.hooks.PreToolUse.hooks.command) + @($script:hooks.hooks.PostToolUse.hooks.command)
        foreach ($c in $cmds) {
            $c | Should -Match 'gate\.ps1'
            Test-Path (Join-Path $script:root 'hooks/gate.ps1') | Should -BeTrue
        }
    }
}

Describe 'gate.ps1' {
    It 'denies the first write call until the skill loads, then only once' {
        $s = "t$(Get-Random)"
        $body = @{ body = "Fixes lowlysre/x#3$($script:Wm)" }
        (Invoke-Gate (New-Pre $s 'create_pull_request' $body)).Code | Should -Be 2
        (Invoke-Gate (New-Pre $s 'create_pull_request' $body)).Code | Should -Be 0
    }
    It 'denies a bad body after the skill loads' {
        $s = "t$(Get-Random)"
        Invoke-Gate @{ hook_event_name = 'PostToolUse'; session_id = $s; tool_name = 'Skill'; tool_input = @{ skill = 'lowly-writing-framework' } } | Out-Null
        $r = Invoke-Gate (New-Pre $s 'mcp__github__update_pull_request' @{ body = 'x #1' })
        $r.Code | Should -Be 2
        $r.Output | Should -Match 'ERROR'
    }
    It 'allows a clean body after the skill loads' {
        $s = "t$(Get-Random)"
        Invoke-Gate @{ hook_event_name = 'PostToolUse'; session_id = $s; tool_name = 'Skill'; tool_input = @{ skill = 'lowly-writing-framework' } } | Out-Null
        (Invoke-Gate (New-Pre $s 'update_pull_request' @{ body = "Fixes lowlysre/x#3$($script:Wm)" })).Code | Should -Be 0
    }
    It 'passes through unrelated Bash commands' {
        (Invoke-Gate (New-Pre "t$(Get-Random)" 'Bash' @{ command = 'ls' })).Code | Should -Be 0
    }
    It 'fails open on malformed input' {
        'not json' | & pwsh -NoProfile -File (Join-Path $script:root 'hooks/gate.ps1') 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
    }
    It 'does not count another skill as loaded' {
        $s = "t$(Get-Random)"
        Invoke-Gate @{ hook_event_name = 'PostToolUse'; session_id = $s; tool_name = 'Skill'; tool_input = @{ skill = 'other-skill' } } | Out-Null
        (Invoke-Gate (New-Pre $s 'create_pull_request' @{ body = 'x' })).Code | Should -Be 2
    }
    It 'keeps sessions isolated' {
        $a = "t$(Get-Random)"; $b = "t$(Get-Random)"
        Invoke-Gate @{ hook_event_name = 'PostToolUse'; session_id = $a; tool_name = 'Skill'; tool_input = @{ skill = 'lowly-writing-framework' } } | Out-Null
        (Invoke-Gate (New-Pre $b 'create_pull_request' @{ body = 'x' })).Code | Should -Be 2
    }
    It 'checks the response field of reply_to_comment as a review comment' {
        $s = "t$(Get-Random)"
        Invoke-Gate @{ hook_event_name = 'PostToolUse'; session_id = $s; tool_name = 'Skill'; tool_input = @{ skill = 'lowly-writing-framework' } } | Out-Null
        $r = Invoke-Gate (New-Pre $s 'reply_to_comment' @{ response = 'no label here' })
        $r.Code | Should -Be 2
        $r.Output | Should -Match 'label'
    }
    Context 'gh commands' {
        BeforeAll {
            $script:dir = Join-Path ([IO.Path]::GetTempPath()) "lwf$(Get-Random)"
            New-Item -ItemType Directory $script:dir | Out-Null
            Set-Content (Join-Path $script:dir 'bad.md') 'x #1' -NoNewline
            Set-Content (Join-Path $script:dir 'good.md') "Fixes o/r#1$($script:Wm)" -NoNewline
            $script:loaded = { $s = "t$(Get-Random)"; Invoke-Gate @{ hook_event_name = 'PostToolUse'; session_id = $s; tool_name = 'Skill'; tool_input = @{ skill = 'lowly-writing-framework' } } | Out-Null; $s }
        }
        AfterAll { Remove-Item -Recurse -Force $script:dir }
        It 'denies a bad --body-file and allows a clean one' {
            $s = & $script:loaded
            (Invoke-Gate (New-Pre $s 'Bash' @{ command = "gh pr create --title t --body-file $(Join-Path $script:dir 'bad.md')" })).Code | Should -Be 2
            (Invoke-Gate (New-Pre $s 'Bash' @{ command = "gh pr create --title t --body-file $(Join-Path $script:dir 'good.md')" })).Code | Should -Be 0
        }
        It 'treats gh pr comment as a review comment' {
            $s = & $script:loaded
            (Invoke-Gate (New-Pre $s 'Bash' @{ command = "gh pr comment 1 --body-file $(Join-Path $script:dir 'good.md')" })).Output | Should -Match 'review body'
        }
        It 'passes inline bodies and read-only gh commands through once the skill has loaded' {
            $s = & $script:loaded
            (Invoke-Gate (New-Pre $s 'Bash' @{ command = 'gh pr create --title t --body "x #1"' })).Code | Should -Be 0
            (Invoke-Gate (New-Pre $s 'Bash' @{ command = 'gh pr view 1' })).Code | Should -Be 0
        }
    }
}
