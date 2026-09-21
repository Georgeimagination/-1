#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = ''
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RootPath)) {
    $RootPath = Join-Path $PSScriptRoot '..\..\..'
}
$root = (Resolve-Path -LiteralPath $RootPath).Path
$tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$work = Join-Path $tempRoot ('codex-mlu590-validate-' + [guid]::NewGuid().ToString('N'))
[System.IO.Directory]::CreateDirectory($work) | Out-Null

try {
    Copy-Item -LiteralPath (Join-Path $root '数据') -Destination (Join-Path $work '数据') -Recurse
    Copy-Item -LiteralPath (Join-Path $root '最小参考资料库') -Destination (Join-Path $work '最小参考资料库') -Recurse
    [System.IO.Directory]::CreateDirectory((Join-Path $work 'scripts')) | Out-Null
    Copy-Item -LiteralPath (Join-Path $root 'scripts\validation') -Destination (Join-Path $work 'scripts\validation') -Recurse

    $candidateFiles = @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.csv' -File)
    foreach ($candidateFile in $candidateFiles) {
        $dataTarget = Join-Path (Join-Path $work '数据') $candidateFile.Name
        $sourceTarget = Join-Path (Join-Path $work '最小参考资料库') $candidateFile.Name
        if (Test-Path -LiteralPath $dataTarget) {
            $target = $dataTarget
        } elseif (Test-Path -LiteralPath $sourceTarget) {
            $target = $sourceTarget
        } else {
            throw "No formal table matches staging file $($candidateFile.Name)"
        }

        $baseRows = @(Import-Csv -LiteralPath $target -Encoding UTF8)
        $candidateRows = @(Import-Csv -LiteralPath $candidateFile.FullName -Encoding UTF8)
        $combined = @($baseRows) + @($candidateRows)
        $csvText = ($combined | ConvertTo-Csv -NoTypeInformation) -join "`r`n"
        [System.IO.File]::WriteAllText($target, $csvText + "`r`n", (New-Object System.Text.UTF8Encoding($false)))
    }

    $validator = Join-Path $work 'scripts\validation\Validate-ResearchData.ps1'
    $output = & 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $work
    $exitCode = $LASTEXITCODE
    $output | Write-Output
    if ($exitCode -ne 0) {
        throw "Formal validator failed with exit code $exitCode"
    }
} finally {
    $resolved = [System.IO.Path]::GetFullPath($work)
    if (-not $resolved.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a path outside the temp root: $resolved"
    }
    if (Test-Path -LiteralPath $resolved) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}