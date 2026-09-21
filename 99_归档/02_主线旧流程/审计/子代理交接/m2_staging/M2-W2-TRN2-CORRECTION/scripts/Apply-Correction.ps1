[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [string]$BackupRoot
)

$ErrorActionPreference = 'Stop'
$stageRoot = Split-Path -Parent $PSScriptRoot
$targetRootResolved = [System.IO.Path]::GetFullPath($TargetRoot)
if (-not (Test-Path -LiteralPath $targetRootResolved -PathType Container)) {
    throw "TargetRoot does not exist: $targetRootResolved"
}

$schemaPath = Join-Path $targetRootResolved '数据\schema-columns.csv'
$schemaRows = Import-Csv -LiteralPath $schemaPath
$primaryKeys = @{}
foreach ($row in $schemaRows) {
    if ($row.is_primary_key -eq 'true') {
        $primaryKeys[$row.table_path] = $row.column_name
    }
}

$backedUp = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$newFiles = [System.Collections.Generic.List[string]]::new()

function Backup-TargetFile {
    param([string]$RelativePath, [string]$AbsolutePath)
    if ([string]::IsNullOrWhiteSpace($BackupRoot)) { return }
    if (-not $backedUp.Add($RelativePath)) { return }
    $backupBase = [System.IO.Path]::GetFullPath($BackupRoot)
    $backupPath = Join-Path $backupBase ($RelativePath.Replace([char]47, [char]92))
    $backupParent = Split-Path -Parent $backupPath
    New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
    if (Test-Path -LiteralPath $AbsolutePath -PathType Leaf) {
        Copy-Item -LiteralPath $AbsolutePath -Destination $backupPath -Force
    } else {
        $newFiles.Add($RelativePath)
    }
}

function Write-CsvUtf8 {
    param([string]$Path, [object[]]$Rows)
    if ($Rows.Count -eq 0) { throw "Refusing to write an empty formal table: $Path" }
    $lines = $Rows | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path, $lines, [System.Text.UTF8Encoding]::new($false))
}

function Apply-OverlayDirectory {
    param(
        [ValidateSet('update','delete','append')]
        [string]$Operation
    )
    $operationRoot = Join-Path $stageRoot ("overlay\{0}" -f $Operation)
    if (-not (Test-Path -LiteralPath $operationRoot -PathType Container)) { return }
    $overlayFiles = Get-ChildItem -LiteralPath $operationRoot -Recurse -File -Filter '*.csv' | Sort-Object FullName
    foreach ($overlayFile in $overlayFiles) {
        $relative = $overlayFile.FullName.Substring($operationRoot.Length).TrimStart([char]92).Replace([char]92, [char]47)
        if (-not $primaryKeys.ContainsKey($relative)) {
            throw "No registered primary key for overlay table: $relative"
        }
        $pk = $primaryKeys[$relative]
        $targetPath = Join-Path $targetRootResolved ($relative.Replace([char]47, [char]92))
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
            throw "Formal table not found: $targetPath"
        }
        $baseRows = @(Import-Csv -LiteralPath $targetPath)
        $overlayRows = @(Import-Csv -LiteralPath $overlayFile.FullName)
        if ($overlayRows.Count -eq 0) { throw "Overlay has no rows: $($overlayFile.FullName)" }
        $overlayIds = @($overlayRows | ForEach-Object { $_.$pk })
        if (($overlayIds | Sort-Object -Unique).Count -ne $overlayIds.Count) {
            throw "Duplicate overlay primary key in $($overlayFile.FullName)"
        }
        $baseIds = @($baseRows | ForEach-Object { $_.$pk })
        Backup-TargetFile -RelativePath $relative -AbsolutePath $targetPath
        if ($Operation -eq 'delete') {
            $missing = @($overlayIds | Where-Object { $_ -notin $baseIds })
            if ($missing.Count -gt 0) { throw "Delete PK missing in ${relative}: $($missing -join ';')" }
            $result = @($baseRows | Where-Object { $_.$pk -notin $overlayIds })
            if ($baseRows.Count - $result.Count -ne $overlayRows.Count) {
                throw "Delete count mismatch in $relative"
            }
        } elseif ($Operation -eq 'update') {
            $missing = @($overlayIds | Where-Object { $_ -notin $baseIds })
            if ($missing.Count -gt 0) { throw "Update PK missing in ${relative}: $($missing -join ';')" }
            $replacement = @{}
            foreach ($row in $overlayRows) { $replacement[$row.$pk] = $row }
            $result = foreach ($row in $baseRows) {
                if ($replacement.ContainsKey($row.$pk)) { $replacement[$row.$pk] } else { $row }
            }
        } else {
            $existing = @($overlayIds | Where-Object { $_ -in $baseIds })
            if ($existing.Count -gt 0) { throw "Append PK already exists in ${relative}: $($existing -join ';')" }
            $result = @($baseRows) + @($overlayRows)
        }
        Write-CsvUtf8 -Path $targetPath -Rows @($result)
    }
}

# Each overlay row is validated against the target primary key before its table is written.
# The operation is intended for an isolated copy first; cross-table integrity is checked by the official validator after all deletes, updates and appends complete.
Apply-OverlayDirectory -Operation 'delete'
Apply-OverlayDirectory -Operation 'update'
Apply-OverlayDirectory -Operation 'append'

$fileCopies = @(
    @{ Source = 'fixed-candidates\S07_ec2_trn2_product_2026-08-13.html'; Target = '最小参考资料库/快照/AWS/Trainium2/2026-08-13/S07_ec2_trn2_product_2026-08-13.html' },
    @{ Source = 'cards\AWS_EC2_trn2.3xlarge_实例卡.md'; Target = '资料卡/AWS/实例/AWS_EC2_trn2.3xlarge_实例卡.md' },
    @{ Source = 'cards\AWS_EC2_trn2.48xlarge_实例卡.md'; Target = '资料卡/AWS/实例/AWS_EC2_trn2.48xlarge_实例卡.md' },
    @{ Source = 'cards\AWS_EC2_trn2u.48xlarge_实例卡.md'; Target = '资料卡/AWS/实例/AWS_EC2_trn2u.48xlarge_实例卡.md' },
    @{ Source = 'cards\AWS_Trainium2_试填资料卡_修复候选.md'; Target = '资料卡/AWS/Trainium2_试填草稿.md' },
    @{ Source = 'cards\AWS_Trainium2_架构卡_修复候选.md'; Target = '资料卡/AWS/架构/AWS_Trainium2_架构卡.md' },
    @{ Source = 'sources\card-fact-map.csv'; Target = '资料卡/AWS/实例/sources/card-fact-map.csv' },
    @{ Source = 'sources\trainium2_existing_reuse_map_corrected.csv'; Target = '资料卡/AWS/架构/sources/trainium2_existing_reuse_map.csv' }
)
foreach ($copy in $fileCopies) {
    $sourcePath = Join-Path $stageRoot $copy.Source
    $targetPath = Join-Path $targetRootResolved ($copy.Target.Replace([char]47, [char]92))
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Copy source missing: $sourcePath" }
    Backup-TargetFile -RelativePath $copy.Target -AbsolutePath $targetPath
    $targetParent = Split-Path -Parent $targetPath
    New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
}

if (-not [string]::IsNullOrWhiteSpace($BackupRoot)) {
    $backupBase = [System.IO.Path]::GetFullPath($BackupRoot)
    New-Item -ItemType Directory -Path $backupBase -Force | Out-Null
    $newFilePath = Join-Path $backupBase 'new-files.txt'
    [System.IO.File]::WriteAllLines($newFilePath, @($newFiles), [System.Text.UTF8Encoding]::new($false))
}

Write-Output "Applied Trainium2 correction to: $targetRootResolved"
