#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$stage = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS'
$structured = Join-Path $stage 'structured'
$audit = Join-Path $stage 'audit'
$tempRoot = Join-Path $stage '.tmp-formal-merge'
$validator = Join-Path $RootPath 'scripts\validation\Validate-ResearchData.ps1'
$schema = @(Import-Csv -LiteralPath (Join-Path $RootPath '数据\schema-columns.csv') -Encoding UTF8)
$tablePaths = @($schema.table_path | Sort-Object -Unique)
$overlayFiles = @{
    'sources.csv' = (Join-Path $audit 'source-updates.csv')
    'source-endpoints.csv' = (Join-Path $audit 'source-endpoint-updates.csv')
    'source-screening.csv' = (Join-Path $audit 'source-screening-updates.csv')
}

function Get-FormalHashes {
    $rows = foreach ($rel in $tablePaths) {
        $path = Join-Path $RootPath $rel.Replace('/','\')
        [pscustomobject][ordered]@{ table_path=$rel; sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() }
    }
    return @($rows)
}
function Assert-SafeTemp([string]$Path) {
    $stageFull = [System.IO.Path]::GetFullPath($stage).TrimEnd('\') + '\'
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    if (-not $pathFull.StartsWith($stageFull,[System.StringComparison]::OrdinalIgnoreCase)) { throw "Unsafe temporary path: $pathFull" }
}
function Remove-SafeTemp([string]$Path,[System.Collections.Generic.List[string]]$Junctions) {
    Assert-SafeTemp $Path
    foreach ($junction in @($Junctions | Sort-Object Length -Descending)) {
        if (Test-Path -LiteralPath $junction) {
            $item = Get-Item -LiteralPath $junction -Force
            if (-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { throw "Refusing to remove non-junction as junction: $junction" }
            [System.IO.Directory]::Delete($junction)
        }
    }
    if (Test-Path -LiteralPath $Path) { Remove-Item -LiteralPath $Path -Recurse -Force }
}

Assert-SafeTemp $tempRoot
$junctions = [System.Collections.Generic.List[string]]::new()
if (Test-Path -LiteralPath $tempRoot) {
    $existingJunctions = [System.Collections.Generic.List[string]]::new()
    Get-ChildItem -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint } | ForEach-Object { $existingJunctions.Add($_.FullName) }
    Remove-SafeTemp $tempRoot $existingJunctions
}
$beforeHashes = Get-FormalHashes
$validatorOutput = @()
$validatorExit = 1
try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    foreach ($rel in $tablePaths) {
        $name = Split-Path $rel -Leaf
        $formalPath = Join-Path $RootPath $rel.Replace('/','\')
        $tempPath = Join-Path $tempRoot $rel.Replace('/','\')
        $tempDir = Split-Path -Parent $tempPath
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        $group = @($schema | Where-Object table_path -eq $rel)
        $pkCols = @($group | Where-Object is_primary_key -eq 'true' | Select-Object -ExpandProperty column_name)
        if ($pkCols.Count -ne 1) { throw "Expected one PK column for $rel" }
        $pk = $pkCols[0]
        $merged = @(Import-Csv -LiteralPath $formalPath -Encoding UTF8)
        if ($overlayFiles.ContainsKey($name)) {
            $updates = @(Import-Csv -LiteralPath $overlayFiles[$name] -Encoding UTF8)
            foreach ($u in $updates) {
                $matches = @($merged | Where-Object { $_.$pk -eq $u.$pk })
                if ($matches.Count -ne 1) { throw "Overlay target count for $name $($u.$pk): $($matches.Count)" }
                $merged = @($merged | Where-Object { $_.$pk -ne $u.$pk })
                $merged += $u
            }
        }
        $candidatePath = Join-Path $structured $name
        $candidates = @(Import-Csv -LiteralPath $candidatePath -Encoding UTF8)
        foreach ($c in $candidates) {
            if (@($merged | Where-Object { $_.$pk -eq $c.$pk }).Count -gt 0) { throw "Append candidate collides in ${name}: $($c.$pk)" }
            $merged += $c
        }
        $merged | Export-Csv -LiteralPath $tempPath -NoTypeInformation -Encoding UTF8
    }

    $pdfJunction = Join-Path $tempRoot '论文'
    New-Item -ItemType Junction -Path $pdfJunction -Target (Join-Path $RootPath '论文') | Out-Null
    $junctions.Add($pdfJunction)
    $snapBase = Join-Path $tempRoot '最小参考资料库\快照'
    New-Item -ItemType Directory -Path $snapBase -Force | Out-Null
    foreach ($vendor in @('AMD','NVIDIA','寒武纪')) {
        $junction = Join-Path $snapBase $vendor
        New-Item -ItemType Junction -Path $junction -Target (Join-Path $RootPath ('最小参考资料库\快照\' + $vendor)) | Out-Null
        $junctions.Add($junction)
    }
    $tempAws = Join-Path $snapBase 'AWS'
    New-Item -ItemType Directory -Path $tempAws -Force | Out-Null
    $trn2Junction = Join-Path $tempAws 'Trainium2'
    New-Item -ItemType Junction -Path $trn2Junction -Target (Join-Path $RootPath '最小参考资料库\快照\AWS\Trainium2') | Out-Null
    $junctions.Add($trn2Junction)

    $freeze = @(Import-Csv -LiteralPath (Join-Path $stage 'source-gate\source-freeze-register.csv') -Encoding UTF8)
    foreach ($row in $freeze) {
        $src = Join-Path $RootPath $row.staging_local_path.Replace('/','\')
        $dst = Join-Path $tempRoot $row.local_path.Replace('/','\')
        New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
        Copy-Item -LiteralPath $src -Destination $dst -Force
        $actual = (Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -cne $row.sha256) { throw "Temporary snapshot hash mismatch: $($row.endpoint_id)" }
    }

    $validatorOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $tempRoot 2>&1)
    $validatorExit = $LASTEXITCODE
    $validatorOutput | Set-Content -LiteralPath (Join-Path $audit 'temporary-formal-merge-validation.txt') -Encoding UTF8
    if ($validatorExit -ne 0) { throw "Official validator failed for temporary merge with exit code $validatorExit." }
}
finally {
    Remove-SafeTemp $tempRoot $junctions
}
$afterHashes = Get-FormalHashes
$integrity = foreach ($before in $beforeHashes) {
    $after = $afterHashes | Where-Object table_path -eq $before.table_path | Select-Object -First 1
    [pscustomobject][ordered]@{ table_path=$before.table_path; before_sha256=$before.sha256; after_sha256=$after.sha256; unchanged=([string]($before.sha256 -ceq $after.sha256)).ToLowerInvariant() }
}
$integrity | Export-Csv -LiteralPath (Join-Path $audit 'formal-hash-integrity.csv') -NoTypeInformation -Encoding UTF8
$changed = @($integrity | Where-Object unchanged -ne 'true')
if ($changed.Count -gt 0) { throw "Formal table hashes changed: $($changed.table_path -join ', ')" }
if (Test-Path -LiteralPath $tempRoot) { throw 'Temporary merge directory was not removed.' }
Write-Output ($validatorOutput -join [Environment]::NewLine)
Write-Output "Temporary formal merge passed; official validator exit=$validatorExit; $($integrity.Count) formal table hashes unchanged; temporary directory removed."