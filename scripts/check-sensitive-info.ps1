param(
    [switch]$Staged
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = (git rev-parse --show-toplevel).Trim()
Set-Location -LiteralPath $repoRoot

$placeholderPattern = '(?i)(your-|your_|example|demo|fake|test|sample|placeholder|changeme|replace[-_ ]?me|xxxx|xxxxx|sk-\.\.\.|token-here|password-here|\$\{[A-Za-z0-9_]+\}|<[^>]+>|\{\{[^}]+\}\})'

$rules = @(
    @{
        Name = "Private key block"
        Pattern = '^\s*-----BEGIN (?:RSA |DSA |EC |OPENSSH )?PRIVATE KEY-----\s*$'
        AllowPattern = $null
    },
    @{
        Name = "Real-looking sk key"
        Pattern = '\bsk-(?:proj-|live-|test-)?[A-Za-z0-9_-]{16,}\b'
        AllowPattern = $placeholderPattern
    },
    @{
        Name = "Bearer token"
        Pattern = 'Bearer\s+[A-Za-z0-9._-]{16,}\b'
        AllowPattern = $placeholderPattern
    },
    @{
        Name = "Token assignment"
        Pattern = '(?i)\b(?:api[_-]?key|access[_-]?token|auth[_-]?token|refresh[_-]?token|client[_-]?secret|secret)\b\s*[:=]\s*["''][A-Za-z0-9._/+:-]{16,}["'']'
        AllowPattern = $placeholderPattern
    },
    @{
        Name = "Password assignment"
        Pattern = '(?i)\b(?:password|passwd|pwd)\b\s*[:=]\s*["''][^\s"'']{8,}["'']'
        AllowPattern = $placeholderPattern
    },
    @{
        Name = "Credential URI"
        Pattern = '\b(?:mysql|mongodb(?:\+srv)?)://[^/\s:@]+:[^@\s/]{8,}@'
        AllowPattern = $placeholderPattern
    }
)

function Get-TargetFiles {
    param([bool]$UseStaged)

    if ($UseStaged) {
        return @(& git -c core.quotepath=false diff --cached --name-only --diff-filter=ACMR --)
    }

    return @(& git -c core.quotepath=false ls-files)
}

function Get-FileLines {
    param(
        [string]$Path,
        [bool]$UseStaged
    )

    if ($UseStaged) {
        return @(& git show --textconv ":$Path" 2>$null)
    }

    $fullPath = Join-Path $repoRoot $Path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        return @()
    }

    return @(Get-Content -LiteralPath $fullPath -Encoding UTF8)
}

$findings = New-Object System.Collections.Generic.List[object]
$targetFiles = Get-TargetFiles -UseStaged:$Staged

foreach ($path in $targetFiles) {
    if ([string]::IsNullOrWhiteSpace($path)) {
        continue
    }

    $lines = @(Get-FileLines -Path $path -UseStaged:$Staged)
    if ($lines.Count -eq 0) {
        continue
    }

    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = [string]$lines[$index]

        foreach ($rule in $rules) {
            if ($line -notmatch $rule.Pattern) {
                continue
            }

            if ($rule.AllowPattern -and $line -match $rule.AllowPattern) {
                continue
            }

            $snippet = $line.Trim()
            if ($snippet.Length -gt 140) {
                $snippet = $snippet.Substring(0, 140) + "..."
            }

            $findings.Add([pscustomobject]@{
                Path = $path
                Line = $index + 1
                Rule = $rule.Name
                Snippet = $snippet
            })
            break
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Host ""
    Write-Host "Sensitive information check failed. Mask or remove these values before committing." -ForegroundColor Red
    Write-Host ""

    foreach ($finding in $findings | Sort-Object Path, Line) {
        Write-Host ("[{0}] {1}:{2}" -f $finding.Rule, $finding.Path, $finding.Line) -ForegroundColor Yellow
        Write-Host ("  {0}" -f $finding.Snippet)
    }

    exit 1
}

if ($Staged) {
    Write-Host "Sensitive information check passed for staged files." -ForegroundColor Green
} else {
    Write-Host "Sensitive information check passed for tracked files." -ForegroundColor Green
}
