param(
    [string]$Orig = '',
    [string]$Trans = (Join-Path $PSScriptRoot '..\src\th')
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$trans = [System.IO.Path]::GetFullPath($Trans)

if ([string]::IsNullOrWhiteSpace($Orig)) {
    $candidates = @(
        (Join-Path $PSScriptRoot '..\..\rust-guide\src\en'),
        (Join-Path $PSScriptRoot '..\rust-guide\src\en'),
        (Join-Path (Get-Location) 'rust-guide\src\en')
    )
    foreach ($cand in $candidates) {
        if (Test-Path -LiteralPath $cand) {
            $Orig = $cand
            break
        }
    }
}

if ([string]::IsNullOrWhiteSpace($Orig) -or (-not (Test-Path -LiteralPath $Orig))) {
    Write-Error "Cannot find upstream rust-guide src/en directory.`nPlease provide the path using: ./scripts/verify-translation.ps1 -Orig <path-to-rust-guide/src/en>"
    exit 1
}

$orig = [System.IO.Path]::GetFullPath($Orig)
Write-Output "Comparing translation against upstream:"
Write-Output "  Upstream:    $orig"
Write-Output "  Translation: $trans"

$script:problems = New-Object System.Collections.Generic.List[string]

function Add-Problem($message) {
    $script:problems.Add($message)
}

function Read-Normalized($path) {
    return ([System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)).Replace("`r`n", "`n")
}

function Get-CodeBlocks($path) {
    $content = Read-Normalized $path
    $rx = [regex]'```(?s:.*?)```'
    return @($rx.Matches($content) | ForEach-Object { $_.Value })
}

function Get-Includes($path) {
    $content = Read-Normalized $path
    $rx = [regex]'(?m)^\s*\{\{#include [^}]*\}\}\s*$'
    return @($rx.Matches($content) | ForEach-Object { $_.Value.Trim() })
}

function Get-Headings($path) {
    $content = Read-Normalized $path
    $rx = [regex]'(?m)^#{1,6} .*$'
    return @($rx.Matches($content) | ForEach-Object { $_.Value })
}

function Get-Anchors($path) {
    $content = Read-Normalized $path
    $rx = [regex]'\{#([^}]+)\}'
    return @($rx.Matches($content) | ForEach-Object { $_.Groups[1].Value })
}

function Get-RefLinks($path) {
    $content = Read-Normalized $path
    # Footnote definitions ([^name]: ...) are prose, not link targets; skip them.
    $rx = [regex]'(?m)^\[(?!\^)[^\]]+\]:\s+\S+.*$'
    return @($rx.Matches($content) | ForEach-Object { $_.Value -replace '\s+$','' })
}

function Get-InlineLinkTargets($path) {
    $content = Read-Normalized $path
    $rx = [regex]'\[[^\]]*\]\(([^)]+)\)'
    return @($rx.Matches($content) | ForEach-Object { $_.Groups[1].Value -replace '\s+$','' })
}

function Get-Autolinks($path) {
    $content = Read-Normalized $path
    $rx = [regex]'<(https?://[^>\s]+)>'
    return @($rx.Matches($content) | ForEach-Object { $_.Groups[1].Value })
}

function Get-RecoIds($path) {
    $content = Read-Normalized $path
    $rx = [regex]'<div class="(?:reco|examplereco)"[^>]*\bid="([^"]+)"'
    return @($rx.Matches($content) | ForEach-Object { $_.Groups[1].Value })
}

function Get-RecoTypes($path) {
    $content = Read-Normalized $path
    $rx = [regex]'<div class="(?:reco|examplereco)"[^>]*\btype="([^"]+)"'
    return @($rx.Matches($content) | ForEach-Object { $_.Groups[1].Value })
}

function Get-Citations($path) {
    $content = Read-Normalized $path
    $rx = [regex]'\[[^\]]*@([a-zA-Z0-9\-_]*)\]'
    return @($rx.Matches($content) | ForEach-Object { $_.Groups[1].Value })
}

function Get-Footnotes($path) {
    $content = Read-Normalized $path
    $rx = [regex]'\[\^([^\]]+)\]'
    return @($rx.Matches($content) | ForEach-Object { $_.Groups[1].Value })
}

function Get-Frontmatter($path) {
    $content = Read-Normalized $path
    if ($content.StartsWith("---`n")) {
        $end = $content.IndexOf("`n---", 4)
        if ($end -ge 0) { return $content.Substring(0, $end + 4) }
    }
    return ''
}

function Normalize-LinkTarget($url) {
    if ([string]::IsNullOrWhiteSpace($url)) {
        return ''
    }
    $trimmed = $url.Trim()
    # In-page anchor link (anchors are translated to Thai slugs and checked by check-links.ps1)
    if ($trimmed.StartsWith('#')) {
        return '#anchor'
    }
    # Relative file link with in-page anchor: the file part must match, the Thai anchor is
    # verified separately by check-links.ps1.
    if ($trimmed -notmatch '^[a-z][a-z0-9+.-]*:' -and $trimmed -match '^([^#]+)#(.+)$') {
        return $Matches[1]
    }
    return $trimmed
}

function Resolve-LinkTarget($url, $rel) {
    $target = Normalize-LinkTarget $url
    if ($target -eq '' -or $target.StartsWith('#') -or $target -match '^[a-z][a-z0-9+.-]*:') {
        return $target
    }
    $dir = Split-Path ($rel -replace '\\','/') -Parent
    if ($target.StartsWith('/')) {
        $combined = $target.Substring(1)
    } elseif ([string]::IsNullOrEmpty($dir)) {
        $combined = $target
    } else {
        $combined = "$dir/$target"
    }
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($seg in $combined -split '/') {
        if ($seg -eq '' -or $seg -eq '.') { continue }
        if ($seg -eq '..') {
            if ($parts.Count -gt 0) { $parts.RemoveAt($parts.Count - 1) }
            continue
        }
        $parts.Add($seg)
    }
    return ($parts -join '/')
}

function Compare-List($rel, $label, $origList, $transList) {
    if ($origList.Count -ne $transList.Count) {
        Add-Problem "[FAIL] $rel : $label count differs (orig=$($origList.Count) trans=$($transList.Count))"
        return
    }
    for ($i = 0; $i -lt $origList.Count; $i++) {
        if ($origList[$i] -cne $transList[$i]) {
            Add-Problem "[FAIL] $rel : $label #$($i+1) differs (orig='$($origList[$i])' trans='$($transList[$i])')"
        }
    }
}

$origFiles = Get-ChildItem -Recurse -File $orig -Filter *.md
$total = 0
$blockCount = 0
$linkCount = 0
$idCount = 0

foreach ($f in $origFiles) {
    $rel = $f.FullName.Substring($orig.Length + 1)
    $tPath = Join-Path $trans $rel
    $total++
    if (-not (Test-Path -LiteralPath $tPath)) {
        Add-Problem "[FAIL] $rel : missing translated file"
        continue
    }

    if ((Get-Frontmatter $f.FullName) -cne (Get-Frontmatter $tPath)) {
        Add-Problem "[FAIL] $rel : frontmatter differs"
    }

    $oc = @(Get-CodeBlocks $f.FullName)
    $tc = @(Get-CodeBlocks $tPath)
    $blockCount += $oc.Count
    Compare-List $rel 'code block' $oc $tc
    Compare-List $rel 'include' @(Get-Includes $f.FullName) @(Get-Includes $tPath)

    $oh = @(Get-Headings $f.FullName)
    $th = @(Get-Headings $tPath)
    if ($oh.Count -ne $th.Count) {
        Add-Problem "[FAIL] $rel : heading count differs (orig=$($oh.Count) trans=$($th.Count))"
    } else {
        for ($i = 0; $i -lt $oh.Count; $i++) {
            $ol = ($oh[$i] -split ' ')[0]
            $tl = ($th[$i] -split ' ')[0]
            if ($ol -cne $tl) {
                Add-Problem "[FAIL] $rel : heading #$($i+1) level differs (orig='$($oh[$i])' trans='$($th[$i])')"
            }
        }
    }

    Compare-List $rel 'anchor' @(Get-Anchors $f.FullName) @(Get-Anchors $tPath)

    $oids = @(Get-RecoIds $f.FullName)
    $tids = @(Get-RecoIds $tPath)
    $idCount += $oids.Count
    Compare-List $rel 'reco id' $oids $tids

    $mapped = @(Get-RecoTypes $f.FullName | ForEach-Object {
        switch ($_) {
            'Rule' { 'กฎ' }
            'Recommendation' { 'ข้อเสนอแนะ' }
            default { $_ }
        }
    })
    Compare-List $rel 'reco type' $mapped @(Get-RecoTypes $tPath)

    Compare-List $rel 'citation' @(Get-Citations $f.FullName) @(Get-Citations $tPath)
    Compare-List $rel 'footnote' @(Get-Footnotes $f.FullName) @(Get-Footnotes $tPath)

    $or = @(Get-RefLinks $f.FullName)
    $tr = @(Get-RefLinks $tPath)
    $linkCount += $or.Count
    if ($or.Count -ne $tr.Count) {
        Add-Problem "[FAIL] $rel : ref-link count differs (orig=$($or.Count) trans=$($tr.Count))"
    } else {
        for ($i = 0; $i -lt $or.Count; $i++) {
            $ourl = Resolve-LinkTarget (($or[$i] -split ':\s*',2)[1]) $rel
            $turl = Resolve-LinkTarget (($tr[$i] -split ':\s*',2)[1]) $rel
            if ($ourl -cne $turl) {
                Add-Problem "[FAIL] $rel : ref-link #$($i+1) url differs (orig='$ourl' trans='$turl')"
            }
        }
    }

    $oi = @(Get-InlineLinkTargets $f.FullName | ForEach-Object { Resolve-LinkTarget $_ $rel })
    $ti = @(Get-InlineLinkTargets $tPath | ForEach-Object { Resolve-LinkTarget $_ $rel })
    $linkCount += $oi.Count
    if ($oi.Count -ne $ti.Count) {
        Add-Problem "[FAIL] $rel : inline link count differs (orig=$($oi.Count) trans=$($ti.Count))"
    } else {
        for ($i = 0; $i -lt $oi.Count; $i++) {
            if ($oi[$i] -cne $ti[$i]) {
                Add-Problem "[FAIL] $rel : inline link #$($i+1) target differs (orig='$($oi[$i])' trans='$($ti[$i])')"
            }
        }
    }

    $oa = @(Get-Autolinks $f.FullName)
    $ta = @(Get-Autolinks $tPath)
    $linkCount += $oa.Count
    Compare-List $rel 'autolink' $oa $ta
}

$script:problems | ForEach-Object { Write-Output $_ }
Write-Output "---"
Write-Output "Checked $total files, $blockCount code blocks, $idCount reco ids, $linkCount links, $($script:problems.Count) problem(s)"
if ($script:problems.Count -eq 0) { Write-Output "ALL OK: code blocks, headings, anchors, ids, citations, footnotes, links match 100%" }
exit ($script:problems.Count -gt 0)
