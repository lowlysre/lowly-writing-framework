#requires -Version 7
<#
.SYNOPSIS
Runs the mechanical self-check from references/self-check.md against a draft.
.DESCRIPTION
Prints one finding per line as "ERROR|WARN <line>: <message>". Exits 1 when any ERROR is found, 0 otherwise.
Judgment checks (paragraph count, altitude, stale claims) are not covered; see references/self-check.md.
.PARAMETER Kind
pr, issue, review, doc, or comment (a code comment; pass the comment text).
.PARAMETER Path
File to check. Omit to read stdin.
#>
param(
    [Parameter(Mandatory)][ValidateSet('pr', 'issue', 'review', 'doc', 'comment')][string]$Kind,
    [string]$Path,
    [string]$CommentToken = '#'
)

$ErrorActionPreference = 'Stop'
$text = if ($Path) { Get-Content -Raw -LiteralPath $Path } else { [Console]::In.ReadToEnd() }
$lines = $text -split '\r?\n'
$findings = [System.Collections.Generic.List[string]]::new()

function Add-Finding($Level, $Line, $Message) { $findings.Add("$Level $Line`: $Message") }

# Per-line scan that skips fenced blocks, so a regex hit in a code sample isn't a finding.
$inFence = $false
$prose = for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s*```') { $inFence = -not $inFence; continue }
    if (-not $inFence) { [pscustomobject]@{ N = $i + 1; Text = $lines[$i] } }
}
# Same, with inline code spans blanked, for checks that must ignore `code`.
$bare = $prose | ForEach-Object { [pscustomobject]@{ N = $_.N; Text = [regex]::Replace($_.Text, '`[^`]*`', '``') } }

function Scan($Rows, $Pattern, $Level, $Message) {
    foreach ($r in $Rows) { if ($r.Text -match $Pattern) { Add-Finding $Level $r.N $Message } }
}

if ($Kind -in 'pr', 'issue', 'review') {
    Scan $prose 'pull/\d+#issue-' ERROR 'hand-built issue URL; get the real one with `gh issue view N --json url`'
    Scan $bare '(^|[^a-zA-Z0-9_./#-])#\d+' ERROR 'bare #N reference; use owner/repo#N'
    Scan $bare '(?<![/\w.-])[a-zA-Z][a-zA-Z0-9_.-]*#\d+' ERROR 'owner-less repo#N reference; use owner/repo#N'
    Scan $prose '`[^`\s]*#\d+`|`#\d+|#\d+`' ERROR 'backticked issue reference disables autolinking'
    Scan $bare '(?<!\]\()(?<![<"''=])https?://\S+' WARN 'bare URL; use a named link unless it is an issue/PR URL or line-anchored permalink'
    Scan $prose '(`[^`]+`,\s*){3,}`[^`]+`' WARN 'four or more backticked identifiers in a row'
}

if ($Kind -eq 'pr') {
    Scan $bare '(?i)\b(part of|relates? to|related to)\b.*#\d+' WARN 'non-closing issue phrasing; use Fixes/Closes/Resolves owner/repo#N where it applies'
    if ($text -notmatch '(?i)\b(fixes|closes|resolves)\b') { Add-Finding WARN 0 'no closing keyword (Fixes/Closes/Resolves); add one or confirm there is no issue to close' }
}

if ($Kind -in 'pr', 'review') {
    $last = ($lines | Where-Object { $_.Trim() } | Select-Object -Last 1)
    if ($last -ne '<!--:robot:-->') { Add-Finding ERROR 0 'last line must be <!--:robot:--> (AI watermark)' }
}

if ($Kind -eq 'review') {
    $first = ($lines | Where-Object { $_.Trim() } | Select-Object -First 1)
    if ($first -match '^\s*(\*\*|`)(praise|nitpick|suggestion|issue|question|thought|chore|note)') { Add-Finding ERROR 1 'decorated review label; use plain `label:` with no bold or backticks' }
    elseif ($first -notmatch '^\s*(praise|nitpick|suggestion|issue|question|thought|chore|note)(\s*\([^)]*\))?:') { Add-Finding ERROR 1 'review comment must open with a conventional-comments label' }
}

if ($Kind -in 'pr', 'issue') {
    $noDiagram = [regex]::Replace($text, '(?s)```mermaid.*?```', '')
    if ($noDiagram.Length -gt 3000) { Add-Finding WARN 0 "body is $($noDiagram.Length) chars outside mermaid; ceiling is ~3000 (references/body-writing.md)" }
    if ($text -match '(?ms)^>.*\?[ \t]*\r?\n>[ \t]*\r?\n>') { Add-Finding WARN 0 'quoted reviewer question followed by quoted answer; quote only the question' }
}

if ($Kind -in 'pr', 'issue', 'doc') {
    $short = $prose | Where-Object { $_.Text -notmatch '^\s*([#>*-]|\d+\.|\||<!--)' -and $_.Text.Trim() -and $_.Text.Length -lt 90 }
    foreach ($r in $short) { Add-Finding WARN $r.N 'short prose line; hard-wrapped paragraph?' }
}

if ($Kind -in 'doc', 'comment') {
    Scan $bare '(?i)\b(removed|used to|previously|no longer|was updated|a scan found|as of #)\b' ERROR 'narrative/historical wording; describe the system as it is now'
}

if ($Kind -eq 'comment') {
    $run = 0
    for ($i = 0; $i -le $lines.Count; $i++) {
        if ($i -lt $lines.Count -and $lines[$i].TrimStart().StartsWith($CommentToken)) { $run++; continue }
        if ($run -gt 4) { Add-Finding WARN ($i - $run + 1) "comment block of $run lines; cap is 4 (references/docs-and-comments.md)" }
        $run = 0
    }
}

# Warn only: identifiers and quoted error strings are false positives.
# The list lives in references/banned-phrases.md: bold terms on bullets shaped `- **a** / **b**: ...`.
# Bullets with a qualifier after the term (`**key** (as in ...)`) are skipped as too context-dependent.
$bannedFile = Join-Path $PSScriptRoot '../references/banned-phrases.md'
if (Test-Path $bannedFile) {
    $terms = foreach ($l in Get-Content $bannedFile) {
        if ($l -match '^- ((?:\*\*[^*]+\*\*(?: / )?)+):') {
            [regex]::Matches($Matches[1], '\*\*([^*]+)\*\*') | ForEach-Object { [regex]::Escape($_.Groups[1].Value.Trim()) }
        }
    }
    if ($terms) {
        Scan $bare "(?i)\b($($terms -join '|'))(?!\w)" WARN 'banned phrase (references/banned-phrases.md); say the concrete thing or cut it'
    }
}

$findings | Sort-Object { [int](($_ -split ' ')[1].TrimEnd(':')) }
exit (@($findings | Where-Object { $_ -like 'ERROR*' }).Count -gt 0 ? 1 : 0)
