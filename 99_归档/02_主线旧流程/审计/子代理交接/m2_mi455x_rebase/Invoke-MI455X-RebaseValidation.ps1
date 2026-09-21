[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$RootPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..')).Path
$StagePath = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-W3-AMD-MI455X-MODULE'
$OldSignoffPath = Join-Path $RootPath '审计\子代理交接\m2_final_review_mi455x_signoff.csv'
$TempRoot = Join-Path $PSScriptRoot '.temporary-merge'
$AuditPath = Join-Path $PSScriptRoot 'temporary-merge-audit.json'
$ValidatorOutputPath = Join-Path $PSScriptRoot 'temporary-validator-output.txt'
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-Sha256File {
    param([Parameter(Mandatory=$true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-FormalManifest {
    param([Parameter(Mandatory=$true)][string]$BasePath)
    $files = @()
    $files += Get-ChildItem -LiteralPath (Join-Path $BasePath '数据') -Filter '*.csv' -File
    $files += Get-ChildItem -LiteralPath (Join-Path $BasePath '最小参考资料库') -Filter '*.csv' -File
    $rows = foreach ($file in $files) {
        $relative = $file.FullName.Substring($BasePath.Length + 1).Replace('\','/')
        [pscustomobject]@{
            relative_path = $relative
            sha256 = Get-Sha256File -Path $file.FullName
            bytes = $file.Length
        }
    }
    return @($rows | Sort-Object relative_path)
}

function Get-ManifestAggregate {
    param([Parameter(Mandatory=$true)][object[]]$Rows)
    $parts = $Rows | Sort-Object relative_path | ForEach-Object { $_.relative_path + '|' + $_.sha256 }
    $text = $parts -join "`n"
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    return [System.BitConverter]::ToString($algorithm.ComputeHash($bytes)).Replace('-','').ToLowerInvariant()
}

$result = [ordered]@{
    checked_at = '2026-08-13'
    status = 'in_progress'
    root_path = $RootPath
    temporary_root = $TempRoot
    current_baseline_table_count = 0
    current_baseline_aggregate_before = ''
    signed_structured_rows = 0
    source_file_binding_failures = 0
    source_pk_failures = 0
    current_formal_pk_conflicts = 0
    copied_artifacts = 0
    local_endpoint_files_copied = 0
    temporary_table_count = 0
    temporary_postmerge_aggregate = ''
    validator_exit_code = -1
    validator_checks = 0
    validator_status = 'not_run'
    current_baseline_aggregate_after = ''
    formal_static_after = $false
    temporary_root_removed = $false
    errors = @()
}

$failure = $null
try {
    $expectedTemp = [System.IO.Path]::GetFullPath($TempRoot)
    $expectedParent = [System.IO.Path]::GetFullPath($PSScriptRoot)
    if (-not $expectedTemp.StartsWith($expectedParent + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Temporary path is outside the rebase audit directory.'
    }
    if ([System.IO.Path]::GetFileName($expectedTemp) -ne '.temporary-merge') {
        throw 'Unexpected temporary directory leaf name.'
    }
    if (Test-Path -LiteralPath $TempRoot) {
        throw 'Temporary merge directory already exists; refusing to overwrite it.'
    }

    $formalBefore = Get-FormalManifest -BasePath $RootPath
    $aggregateBefore = Get-ManifestAggregate -Rows $formalBefore
    $result.current_baseline_table_count = $formalBefore.Count
    $result.current_baseline_aggregate_before = $aggregateBefore
    if ($formalBefore.Count -ne 32) {
        throw "Current formal table count is $($formalBefore.Count), expected 32."
    }
    if ($aggregateBefore -ne 'f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10') {
        throw "Current formal aggregate is $aggregateBefore, expected the AWS-postmerge baseline."
    }

    New-Item -ItemType Directory -Path $TempRoot | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $TempRoot '数据') | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $TempRoot '最小参考资料库') | Out-Null

    foreach ($entry in $formalBefore) {
        $source = Join-Path $RootPath ($entry.relative_path.Replace('/','\'))
        $target = Join-Path $TempRoot ($entry.relative_path.Replace('/','\'))
        Copy-Item -LiteralPath $source -Destination $target
    }

    $signoff = Import-Csv -LiteralPath $OldSignoffPath -Encoding UTF8
    $writes = @($signoff | Where-Object { $_.binding_kind -eq 'lifecycle_pk_write' })
    $artifacts = @($signoff | Where-Object { $_.binding_kind -ne 'lifecycle_pk_write' })
    $result.signed_structured_rows = $writes.Count
    if ($writes.Count -ne 242 -or $artifacts.Count -ne 3) {
        throw "Unexpected old signoff shape: $($writes.Count) structured rows and $($artifacts.Count) artifacts."
    }

    $sourceCache = @{}
    $groups = $writes | Group-Object target_path
    foreach ($group in $groups) {
        $targetRelative = [string]$group.Name
        $targetTemp = Join-Path $TempRoot ($targetRelative.Replace('/','\'))
        $formalRows = @(Import-Csv -LiteralPath $targetTemp -Encoding UTF8)
        $header = @($formalRows[0].PSObject.Properties.Name)
        $pendingKeys = New-Object System.Collections.Generic.HashSet[string]
        $appendRows = New-Object System.Collections.Generic.List[object]

        foreach ($binding in $group.Group) {
            $sourceFull = Join-Path $RootPath ($binding.source_path.Replace('/','\'))
            if ((Get-Sha256File -Path $sourceFull) -ne $binding.source_sha256) {
                $result.source_file_binding_failures++
                throw "Source file hash mismatch: $($binding.source_path)"
            }
            if ([string](Get-Item -LiteralPath $sourceFull).Length -ne [string]$binding.source_bytes) {
                $result.source_file_binding_failures++
                throw "Source file size mismatch: $($binding.source_path)"
            }
            if (-not $sourceCache.ContainsKey($sourceFull)) {
                $sourceCache[$sourceFull] = @(Import-Csv -LiteralPath $sourceFull -Encoding UTF8)
            }
            $matches = @($sourceCache[$sourceFull] | Where-Object { [string]$_.($binding.pk_column) -eq [string]$binding.pk_value })
            if ($matches.Count -ne 1) {
                $result.source_pk_failures++
                throw "Source primary key count is $($matches.Count): $($binding.pk_value)"
            }
            $formalMatches = @($formalRows | Where-Object { [string]$_.($binding.pk_column) -eq [string]$binding.pk_value })
            if ($formalMatches.Count -ne 0) {
                $result.current_formal_pk_conflicts++
                throw "Formal primary key already exists: $($binding.pk_value)"
            }
            $key = [string]$binding.pk_value
            if (-not $pendingKeys.Add($key)) {
                throw "Duplicate signed primary key in pending rows: $key"
            }

            $values = [ordered]@{}
            foreach ($column in $header) {
                $values[$column] = [string]$matches[0].$column
            }
            $row = [pscustomobject]$values
            if ([string]$row.review_status -ne [string]$binding.source_review_status) {
                throw "Unexpected source review_status for $key"
            }
            $row.review_status = [string]$binding.authorized_review_status
            if ([string]$binding.semantic_status_column -ne '') {
                $columnName = [string]$binding.semantic_status_column
                if ([string]$row.$columnName -ne [string]$binding.semantic_status_before) {
                    throw "Unexpected semantic value before update for $key"
                }
                $row.$columnName = [string]$binding.semantic_status_after
            }
            $appendRows.Add($row)
        }

        $combined = @($formalRows) + @($appendRows.ToArray())
        $csv = $combined | ConvertTo-Csv -NoTypeInformation
        [System.IO.File]::WriteAllLines($targetTemp, $csv, $Utf8)
    }

    foreach ($artifact in $artifacts) {
        $sourceFull = Join-Path $RootPath ($artifact.source_path.Replace('/','\'))
        if ((Get-Sha256File -Path $sourceFull) -ne $artifact.source_sha256) {
            throw "Artifact source hash mismatch: $($artifact.source_path)"
        }
        if ([string](Get-Item -LiteralPath $sourceFull).Length -ne [string]$artifact.source_bytes) {
            throw "Artifact source size mismatch: $($artifact.source_path)"
        }
        $targetFull = Join-Path $TempRoot ($artifact.target_path.Replace('/','\'))
        if (Test-Path -LiteralPath $targetFull) {
            throw "Temporary artifact target already exists: $($artifact.target_path)"
        }
        $targetParent = Split-Path -Parent $targetFull
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        Copy-Item -LiteralPath $sourceFull -Destination $targetFull
        $result.copied_artifacts++
    }

    $endpointPath = Join-Path $TempRoot '最小参考资料库\source-endpoints.csv'
    $endpoints = @(Import-Csv -LiteralPath $endpointPath -Encoding UTF8)
    foreach ($endpoint in $endpoints) {
        if ([string]$endpoint.local_path -eq '') {
            continue
        }
        $relativeLocal = [string]$endpoint.local_path
        $temporaryLocal = Join-Path $TempRoot ($relativeLocal.Replace('/','\'))
        if (Test-Path -LiteralPath $temporaryLocal -PathType Leaf) {
            continue
        }
        $formalLocal = Join-Path $RootPath ($relativeLocal.Replace('/','\'))
        if (-not (Test-Path -LiteralPath $formalLocal -PathType Leaf)) {
            throw "Local endpoint file is unavailable in both formal and temporary roots: $relativeLocal"
        }
        $temporaryParent = Split-Path -Parent $temporaryLocal
        New-Item -ItemType Directory -Path $temporaryParent -Force | Out-Null
        Copy-Item -LiteralPath $formalLocal -Destination $temporaryLocal
        $result.local_endpoint_files_copied++
    }

    $temporaryManifest = Get-FormalManifest -BasePath $TempRoot
    $result.temporary_table_count = $temporaryManifest.Count
    $result.temporary_postmerge_aggregate = Get-ManifestAggregate -Rows $temporaryManifest

    $validator = Join-Path $RootPath 'scripts\validation\Validate-ResearchData.ps1'
    $powershell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
    $validatorLines = @(& $powershell -NoProfile -ExecutionPolicy Bypass -File $validator -RootPath $TempRoot 2>&1)
    $validatorExit = $LASTEXITCODE
    [System.IO.File]::WriteAllLines($ValidatorOutputPath, @($validatorLines | ForEach-Object { [string]$_ }), $Utf8)
    $result.validator_exit_code = $validatorExit
    $validatorText = $validatorLines -join "`n"
    if ($validatorText -match 'PASS: 32-table research data model; ([0-9]+) checks executed; subject_contract_mode=gate\.') {
        $result.validator_checks = [int]$Matches[1]
    }
    if ($validatorExit -eq 0 -and $result.validator_checks -gt 0) {
        $result.validator_status = 'passed'
    } else {
        $result.validator_status = 'failed'
        throw "Temporary merged validator failed with exit code $validatorExit."
    }

    $formalAfter = Get-FormalManifest -BasePath $RootPath
    $aggregateAfter = Get-ManifestAggregate -Rows $formalAfter
    $result.current_baseline_aggregate_after = $aggregateAfter
    $result.formal_static_after = ($aggregateAfter -eq $aggregateBefore)
    if (-not $result.formal_static_after) {
        throw 'Formal 32-table aggregate changed during isolated validation.'
    }

    $result.status = 'passed'
}
catch {
    $failure = $_
    $result.status = 'failed'
    $result.errors = @([string]$_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $TempRoot) {
        $resolvedTemp = (Resolve-Path -LiteralPath $TempRoot).Path
        $expectedTemp = [System.IO.Path]::GetFullPath($TempRoot)
        if ($resolvedTemp -ne $expectedTemp) {
            $result.errors += 'Temporary cleanup path resolution mismatch; directory retained.'
        } else {
            Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
        }
    }
    $result.temporary_root_removed = -not (Test-Path -LiteralPath $TempRoot)
    $json = $result | ConvertTo-Json -Depth 6
    [System.IO.File]::WriteAllText($AuditPath, $json + "`n", $Utf8)
}

if ($null -ne $failure) {
    throw $failure
}

Write-Output "PASS: MI455X rebase isolated merge; $($result.validator_checks) validator checks; formal aggregate unchanged."