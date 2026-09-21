#Requires -Version 5.1
[CmdletBinding()]
param([string]$ProjectRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总')
$ErrorActionPreference = 'Stop'
$PackageRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$Stage = Join-Path $PackageRoot 'structured'
$TempRoot = Join-Path $PackageRoot 'validation\tmp-formal-merge'
if (Test-Path -LiteralPath $TempRoot) { throw "Temporary mirror already exists: $TempRoot" }
New-Item -ItemType Directory -Path $TempRoot | Out-Null
$dataDir = Join-Path $TempRoot '数据'; $refDir = Join-Path $TempRoot '最小参考资料库'
New-Item -ItemType Directory -Path $dataDir | Out-Null
New-Item -ItemType Directory -Path $refDir | Out-Null
Get-ChildItem -LiteralPath (Join-Path $ProjectRoot '数据') -File | Copy-Item -Destination $dataDir -Force
Get-ChildItem -LiteralPath (Join-Path $ProjectRoot '最小参考资料库') -File -Filter '*.csv' | Copy-Item -Destination $refDir -Force
$links = @()
try {
    foreach ($name in @('scripts','论文','审计')) {
        $target = Join-Path $ProjectRoot $name; $link = Join-Path $TempRoot $name
        New-Item -ItemType Junction -Path $link -Target $target | Out-Null
        $links += $link
        if ($name -eq '审计') {
            $mirrorStage = Join-Path $link '子代理交接\m2_staging\M2-W3-AMD-MI350P-CARD'
            if (-not (Test-Path -LiteralPath $mirrorStage)) { throw 'MI350P staging is not reachable through audit junction.' }
        }
    }
    $snapshotRoot = Join-Path $ProjectRoot '最小参考资料库\快照'
    if (Test-Path -LiteralPath $snapshotRoot) {
        $snapshotLink = Join-Path $refDir '快照'
        New-Item -ItemType Junction -Path $snapshotLink -Target $snapshotRoot | Out-Null
        $links += $snapshotLink
    }
    foreach ($file in Get-ChildItem -LiteralPath $Stage -File) {
        $target = if (Test-Path -LiteralPath (Join-Path $dataDir $file.Name)) { Join-Path $dataDir $file.Name } elseif (Test-Path -LiteralPath (Join-Path $refDir $file.Name)) { Join-Path $refDir $file.Name } else { throw "No mirror target for $($file.Name)" }
        $formalHeader = Get-Content -LiteralPath $target -Encoding UTF8 -TotalCount 1
        $stageHeader = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -TotalCount 1
        if ($formalHeader -cne $stageHeader) { throw "Header mismatch: $($file.Name)" }
        $formalRows = @(Import-Csv -LiteralPath $target -Encoding UTF8); $stageRows = @(Import-Csv -LiteralPath $file.FullName -Encoding UTF8)
        $allRows = @($formalRows) + @($stageRows)
        if ($allRows.Count -eq 0) { [System.IO.File]::WriteAllText($target,$formalHeader+"`r`n",[System.Text.UTF8Encoding]::new($false)) }
        else { [System.IO.File]::WriteAllLines($target,@($allRows|ConvertTo-Csv -NoTypeInformation),[System.Text.UTF8Encoding]::new($false)) }
    }
    $validator = Join-Path $TempRoot 'scripts\validation\Validate-ResearchData.ps1'
    $output = & 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $TempRoot -SubjectContractMode gate 2>&1
    $exitCode = $LASTEXITCODE
    $result = [ordered]@{ status = if($exitCode -eq 0){'passed'}else{'failed'}; exit_code=$exitCode; output=@($output); temporary_root=$TempRoot }
    $result | ConvertTo-Json -Depth 5
    if ($exitCode -ne 0) { exit $exitCode }
} finally {
    foreach ($link in $links) {
        if (Test-Path -LiteralPath $link) {
            $item = Get-Item -LiteralPath $link -Force
            if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) { throw "Cleanup target is not a reparse point: $link" }
            [System.IO.Directory]::Delete($link)
        }
    }
    if (Test-Path -LiteralPath $TempRoot) {
        $resolved = (Resolve-Path -LiteralPath $TempRoot).Path
        $expected = [System.IO.Path]::GetFullPath($TempRoot)
        if ($resolved -cne $expected -or -not $resolved.StartsWith($PackageRoot,[System.StringComparison]::OrdinalIgnoreCase)) { throw "Unsafe temp cleanup path: $resolved" }
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}
