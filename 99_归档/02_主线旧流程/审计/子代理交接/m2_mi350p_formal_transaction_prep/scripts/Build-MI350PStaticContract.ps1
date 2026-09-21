param(
    [Parameter(Mandatory=$false)][string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总',
    [Parameter(Mandatory=$false)][string]$OutputRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总\审计\子代理交接\m2_mi350p_formal_transaction_prep'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Checks = 0

$ExpectedFormalAggregate = 'f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedFinalReportSha256 = '470d381d66e5cb7ccd7b3fc9aa88ede12ed1a995a6a1af6e03844630d9b43461'
$ExpectedSignoffSha256 = '74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1'
$ExpectedFreezeSha256 = '1cb279b56f4fbfc688ed2f798646a93baed02ffbd34a647ffecf4cb6672f0e01'
$ExpectedFreezeAggregate = '152df43e8b64c2b78c54a41c6cf9bd7acfa4d3315fcf33d6128399b22f2f8825'
$ExpectedFormalManifestSha256 = '68773358da2fe590aaaecdcccdaf0e68d61176df35d4b759dad14b4ae1174e5c'
$ExpectedValidatorChecks = 111343
function Assert-Check {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    $script:Checks++
}

function Get-Sha256 {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-TextSha256 {
    param([string]$Text)
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $Utf8NoBom.GetBytes($Text)
        return (($algorithm.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') }) -join '')
    }
    finally { $algorithm.Dispose() }
}

function Get-ChildPath {
    param([string]$Root, [string]$RelativePath, [bool]$MustExist = $true)
    Assert-Check (-not [string]::IsNullOrWhiteSpace($RelativePath)) 'Relative path is empty.'
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $rootFull ($RelativePath.Replace('/','\'))))
    Assert-Check ($candidate.StartsWith($rootFull + '\',[System.StringComparison]::OrdinalIgnoreCase)) "Path escapes root: $RelativePath"
    if ($MustExist) { Assert-Check (Test-Path -LiteralPath $candidate -PathType Leaf) "Missing file: $RelativePath" }
    return $candidate
}

function Get-CanonicalRowSha256 {
    param([object]$Row)
    $serialized = @($Row | ConvertTo-Csv -NoTypeInformation) -join [char]10
    return Get-TextSha256 $serialized
}

function Get-CanonicalRowJson {
    param([object]$Row)
    return ($Row | ConvertTo-Json -Compress -Depth 10)
}

function Write-CsvNoBom {
    param([string]$Path, [object[]]$Rows)
    Assert-Check ($Rows.Count -gt 0) "Refusing to write empty CSV: $Path"
    $lines = $Rows | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path,$lines,$Utf8NoBom)
    Assert-Check (Test-Path -LiteralPath $Path -PathType Leaf) "CSV write failed: $Path"
}

function Get-FileFormat {
    param([string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191
    $text = [System.IO.File]::ReadAllText($Path,[System.Text.Encoding]::UTF8)
    $crlf = ([regex]::Matches($text,"`r`n")).Count
    $lfOnly = ([regex]::Matches(($text -replace "`r`n",''),"`n")).Count
    $newline = if ($crlf -gt 0 -and $lfOnly -eq 0) { 'CRLF' } elseif ($crlf -eq 0 -and $lfOnly -gt 0) { 'LF' } elseif ($crlf -gt 0 -and $lfOnly -gt 0) { 'mixed' } else { 'none' }
    return [pscustomobject]@{ encoding = if ($hasBom) { 'UTF-8-BOM' } else { 'UTF-8-no-BOM' }; newline = $newline }
}

function Get-ManifestAggregate {
    param([object[]]$Rows, [bool]$IncludeBytes)
    $parts = foreach ($row in ($Rows | Sort-Object relative_path)) {
        if ($IncludeBytes) {
            $sizeValue = if ($row.PSObject.Properties.Name -ccontains 'bytes') { [string]$row.bytes } else { [string]$row.byte_size }
            [string]$row.relative_path + '|' + [string]$row.sha256 + '|' + $sizeValue
        }
        else { [string]$row.relative_path + '|' + [string]$row.sha256 }
    }
    return Get-TextSha256 ($parts -join [char]10)
}

$rootFull = [System.IO.Path]::GetFullPath($RootPath).TrimEnd('\')
$outputFull = [System.IO.Path]::GetFullPath($OutputRoot).TrimEnd('\')
$expectedOutput = [System.IO.Path]::GetFullPath((Join-Path $rootFull '审计\子代理交接\m2_mi350p_formal_transaction_prep')).TrimEnd('\')
Assert-Check ($outputFull -ceq $expectedOutput) "OutputRoot is outside the authorized directory: $outputFull"
Assert-Check (Test-Path -LiteralPath $outputFull -PathType Container) 'OutputRoot is missing.'

$schemaPath = Get-ChildPath $rootFull '数据/schema-columns.csv'
$schemaRows = @(Import-Csv -LiteralPath $schemaPath -Encoding UTF8)
$tablePaths = @($schemaRows.table_path | Sort-Object -Unique)
Assert-Check ($tablePaths.Count -eq 32) "Formal table count is $($tablePaths.Count), expected 32."

$formalManifest = New-Object System.Collections.Generic.List[object]
$ordinal = 0
foreach ($relative in $tablePaths) {
    $ordinal++
    $full = Get-ChildPath $rootFull $relative
    $rows = @(Import-Csv -LiteralPath $full -Encoding UTF8)
    $format = Get-FileFormat $full
    $columnCount = @($schemaRows | Where-Object { $_.table_path -ceq $relative }).Count
    $formalManifest.Add([pscustomobject][ordered]@{
        ordinal = $ordinal
        relative_path = $relative
        sha256 = Get-Sha256 $full
        bytes = (Get-Item -LiteralPath $full).Length
        data_rows = $rows.Count
        column_count = $columnCount
        encoding = $format.encoding
        newline = $format.newline
    })
}
$formalAggregate = Get-ManifestAggregate -Rows $formalManifest.ToArray() -IncludeBytes $false
Assert-Check ($formalAggregate -ceq $ExpectedFormalAggregate) "Formal aggregate differs: $formalAggregate"
Write-CsvNoBom (Join-Path $outputFull 'formal-32-baseline.csv') $formalManifest.ToArray()

$stagingRelative = '审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD'
$stagingBase = [System.IO.Path]::GetFullPath((Join-Path $rootFull ($stagingRelative.Replace('/','\')))).TrimEnd('\')
$signoffPath = Get-ChildPath $rootFull '审计/子代理交接/m2_final_review_mi350p_signoff.csv'
$finalReportPath = Get-ChildPath $rootFull '审计/子代理交接/m2_final_review_mi350p.md'
$freezePath = Get-ChildPath $stagingBase 'validation/staging-file-manifest.csv'
$signedFormalManifestPath = Get-ChildPath $stagingBase 'validation/formal-32-csv-baseline.csv'
Assert-Check ((Get-Sha256 $finalReportPath) -ceq $ExpectedFinalReportSha256) 'Final independent review report SHA-256 differs.'
Assert-Check ((Get-Sha256 $signoffPath) -ceq $ExpectedSignoffSha256) 'Final signoff SHA-256 differs.'
Assert-Check ((Get-Sha256 $freezePath) -ceq $ExpectedFreezeSha256) 'Staging freeze-manifest SHA-256 differs.'
Assert-Check ((Get-Sha256 $signedFormalManifestPath) -ceq $ExpectedFormalManifestSha256) 'Signed formal baseline manifest SHA-256 differs.'

$freeze = @(Import-Csv -LiteralPath $freezePath -Encoding UTF8)
Assert-Check ($freeze.Count -eq 50) "Freeze row count differs: $($freeze.Count)."
Assert-Check (@($freeze.relative_path | Group-Object | Where-Object Count -gt 1).Count -eq 0) 'Freeze manifest contains duplicate paths.'
foreach ($entry in $freeze) {
    $member = Get-ChildPath $stagingBase ([string]$entry.relative_path)
    Assert-Check ((Get-Sha256 $member) -ceq [string]$entry.sha256) "Freeze member hash differs: $($entry.relative_path)"
    Assert-Check ([string](Get-Item -LiteralPath $member).Length -ceq [string]$entry.byte_size) "Freeze member size differs: $($entry.relative_path)"
}
$actualFreezeMembers = @(Get-ChildItem -LiteralPath $stagingBase -Recurse -File | Where-Object { $_.FullName -cne $freezePath })
Assert-Check ($actualFreezeMembers.Count -eq 50) "Staging member count excluding manifest differs: $($actualFreezeMembers.Count)."
foreach ($member in $actualFreezeMembers) {
    $relative = $member.FullName.Substring($stagingBase.Length + 1).Replace('\','/')
    Assert-Check (@($freeze | Where-Object { [string]$_.relative_path -ceq $relative }).Count -eq 1) "Unlisted staging member: $relative"
}
$freezeAggregate = Get-ManifestAggregate -Rows $freeze -IncludeBytes $true
Assert-Check ($freezeAggregate -ceq $ExpectedFreezeAggregate) "Freeze aggregate differs: $freezeAggregate"

$signedFormalManifest = @(Import-Csv -LiteralPath $signedFormalManifestPath -Encoding UTF8)
Assert-Check ($signedFormalManifest.Count -eq 32) "Signed formal baseline row count differs: $($signedFormalManifest.Count)."
Assert-Check (@($signedFormalManifest.table_path | Group-Object | Where-Object Count -gt 1).Count -eq 0) 'Signed formal baseline contains duplicate table paths.'
Assert-Check ((@($signedFormalManifest.table_path | Sort-Object) -join [char]31) -ceq (@($tablePaths | Sort-Object) -join [char]31)) 'Signed formal baseline table set differs from schema registry.'
foreach ($entry in $signedFormalManifest) {
    $formalFile = Get-ChildPath $rootFull ([string]$entry.table_path)
    Assert-Check ((Get-Sha256 $formalFile) -ceq [string]$entry.sha256) "Signed formal table hash differs: $($entry.table_path)"
    Assert-Check ([string](Get-Item -LiteralPath $formalFile).Length -ceq [string]$entry.byte_size) "Signed formal table size differs: $($entry.table_path)"
}

$signoff = @(Import-Csv -LiteralPath $signoffPath -Encoding UTF8)
Assert-Check ($signoff.Count -eq 274) "Signoff row count differs: $($signoff.Count)."
Assert-Check (@($signoff.signoff_row_id | Group-Object | Where-Object Count -gt 1).Count -eq 0) 'Signoff IDs are not unique.'
$writes = @($signoff | Where-Object { $_.binding_kind -ceq 'lifecycle_pk_write' })
$artifacts = @($signoff | Where-Object { $_.binding_kind -cne 'lifecycle_pk_write' })
Assert-Check ($writes.Count -eq 270) "Structured signoff count differs: $($writes.Count)."
Assert-Check ($artifacts.Count -eq 4) "Artifact signoff count differs: $($artifacts.Count)."
foreach ($binding in $signoff) {
    Assert-Check ([string]$binding.freeze_manifest_sha256 -ceq $ExpectedFreezeSha256) "Freeze binding differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.freeze_manifest_bytes -ceq [string](Get-Item -LiteralPath $freezePath).Length) "Freeze size binding differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.freeze_aggregate_sha256 -ceq $ExpectedFreezeAggregate) "Freeze aggregate binding differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.formal_baseline_manifest_sha256 -ceq $ExpectedFormalManifestSha256) "Formal manifest binding differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.formal_baseline_manifest_bytes -ceq [string](Get-Item -LiteralPath $signedFormalManifestPath).Length) "Formal manifest size binding differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.formal_baseline_aggregate_sha256 -ceq $ExpectedFormalAggregate) "Formal aggregate binding differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.temporary_merge_validator_checks -ceq [string]$ExpectedValidatorChecks) "Validator-count binding differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.verdict -ceq 'accept') "Signoff verdict differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.reviewer -ceq 'm2_final_review_mi350p') "Signoff reviewer differs: $($binding.signoff_row_id)"
    Assert-Check ([string]$binding.review_date -ceq '2026-08-13') "Signoff review date differs: $($binding.signoff_row_id)"
}
$sourceCache = @{}
$formalCache = @{}
$writeSet = New-Object System.Collections.Generic.List[object]
foreach ($binding in ($writes | Sort-Object signoff_row_id)) {
    $sourceFull = Get-ChildPath $rootFull ([string]$binding.source_path)
    Assert-Check ($sourceFull.StartsWith($stagingBase + '\',[System.StringComparison]::OrdinalIgnoreCase)) "Source path is outside frozen staging: $($binding.signoff_row_id)"
    $sourceRelative = $sourceFull.Substring($stagingBase.Length + 1).Replace('\','/')
    Assert-Check (@($freeze | Where-Object { [string]$_.relative_path -ceq $sourceRelative }).Count -eq 1) "Source path is absent from freeze manifest: $($binding.signoff_row_id)"
    Assert-Check ((Get-Sha256 $sourceFull) -ceq [string]$binding.source_sha256) "Source file hash differs: $($binding.signoff_row_id)"
    Assert-Check ([string](Get-Item -LiteralPath $sourceFull).Length -ceq [string]$binding.source_bytes) "Source file size differs: $($binding.signoff_row_id)"
    if (-not $sourceCache.ContainsKey($sourceFull)) { $sourceCache[$sourceFull] = @(Import-Csv -LiteralPath $sourceFull -Encoding UTF8) }

    $targetFull = Get-ChildPath $rootFull ([string]$binding.target_path)
    if (-not $formalCache.ContainsKey($targetFull)) { $formalCache[$targetFull] = @(Import-Csv -LiteralPath $targetFull -Encoding UTF8) }
    $formalRows = @($formalCache[$targetFull])
    Assert-Check ($formalRows.Count -gt 0) "Formal target has no row to expose schema: $($binding.target_path)"
    $header = @($formalRows[0].PSObject.Properties.Name)
    $sourceRows = @($sourceCache[$sourceFull])
    Assert-Check ($sourceRows.Count -gt 0) "Source CSV has no rows: $($binding.source_path)"
    $sourceHeader = @($sourceRows[0].PSObject.Properties.Name)
    Assert-Check (($sourceHeader -join [char]31) -ceq ($header -join [char]31)) "Source/formal header differs: $($binding.source_path)"

    $sourceMatches = @($sourceRows | Where-Object { [string]$_.$([string]$binding.pk_column) -ceq [string]$binding.pk_value })
    Assert-Check ($sourceMatches.Count -eq 1) "Source PK count differs: $($binding.pk_value)"
    $formalMatches = @($formalRows | Where-Object { [string]$_.$([string]$binding.pk_column) -ceq [string]$binding.pk_value })
    Assert-Check ($formalMatches.Count -eq 0) "Formal target already contains PK: $($binding.pk_value)"

    $sourceValues = [ordered]@{}
    foreach ($column in $header) { $sourceValues[$column] = [string]$sourceMatches[0].$column }
    $sourceRow = [pscustomobject]$sourceValues
    $canonicalSourceSha256 = Get-CanonicalRowSha256 $sourceRow
    Assert-Check ($canonicalSourceSha256 -ceq [string]$binding.source_line_sha256) "Signed source-line hash differs: $($binding.pk_value)"
    Assert-Check ([string]$sourceRow.review_status -ceq [string]$binding.source_review_status) "Source review_status differs: $($binding.pk_value)"
    Assert-Check ([string]$binding.source_review_status -ceq 'draft') "Source lifecycle is not draft: $($binding.pk_value)"
    Assert-Check ([string]$binding.authorized_review_status -ceq 'reviewed') "Authorized lifecycle is not reviewed: $($binding.pk_value)"

    $authorizedValues = [ordered]@{}
    foreach ($column in $header) { $authorizedValues[$column] = [string]$sourceRow.$column }
    $authorizedRow = [pscustomobject]$authorizedValues
    $authorizedRow.review_status = [string]$binding.authorized_review_status
    if (-not [string]::IsNullOrEmpty([string]$binding.semantic_status_column)) {
        $semanticColumn = [string]$binding.semantic_status_column
        Assert-Check ($header -ccontains $semanticColumn) "Semantic status column is absent: $semanticColumn"
        Assert-Check ([string]$authorizedRow.$semanticColumn -ceq [string]$binding.semantic_status_before) "Semantic before-value differs: $($binding.pk_value)"
        $authorizedRow.$semanticColumn = [string]$binding.semantic_status_after
    }

    $formalEntry = @($formalManifest | Where-Object { $_.relative_path -ceq [string]$binding.target_path })
    Assert-Check ($formalEntry.Count -eq 1) "Formal manifest lookup failed: $($binding.target_path)"
    $writeSet.Add([pscustomobject][ordered]@{
        signoff_row_id = [string]$binding.signoff_row_id
        target_path = [string]$binding.target_path
        pk_column = [string]$binding.pk_column
        pk_value = [string]$binding.pk_value
        source_path = [string]$binding.source_path
        source_sha256 = [string]$binding.source_sha256
        source_bytes = [string]$binding.source_bytes
        source_review_status = [string]$binding.source_review_status
        authorized_review_status = [string]$binding.authorized_review_status
        semantic_status_column = [string]$binding.semantic_status_column
        semantic_status_before = [string]$binding.semantic_status_before
        semantic_status_after = [string]$binding.semantic_status_after
        signed_source_line_sha256 = [string]$binding.source_line_sha256
        canonical_source_row_sha256 = $canonicalSourceSha256
        canonical_authorized_row_sha256 = Get-CanonicalRowSha256 $authorizedRow
        formal_premerge_sha256 = [string]$formalEntry[0].sha256
        formal_premerge_bytes = [string]$formalEntry[0].bytes
    })
}
Assert-Check (@($writeSet | Group-Object { $_.target_path + '|' + $_.pk_value } | Where-Object Count -gt 1).Count -eq 0) 'Authorized target keys are not unique.'
Write-CsvNoBom (Join-Path $outputFull 'authorized-write-set.csv') $writeSet.ToArray()

$backupRows = New-Object System.Collections.Generic.List[object]
$commitOrder = 0
foreach ($group in ($writeSet | Group-Object target_path | Sort-Object Name)) {
    $commitOrder++
    $entry = @($formalManifest | Where-Object { $_.relative_path -ceq [string]$group.Name })[0]
    $backupRows.Add([pscustomobject][ordered]@{
        commit_order = $commitOrder
        target_path = [string]$group.Name
        authorized_row_writes = $group.Count
        premerge_sha256 = [string]$entry.sha256
        premerge_bytes = [string]$entry.bytes
        premerge_data_rows = [string]$entry.data_rows
        column_count = [string]$entry.column_count
        encoding = [string]$entry.encoding
        newline = [string]$entry.newline
        backup_required = 'true'
        rollback_action = 'restore_exact_backup_in_reverse_commit_order'
    })
}
Assert-Check ($backupRows.Count -eq 19) "Write-table count differs: $($backupRows.Count)."
Write-CsvNoBom (Join-Path $outputFull 'formal-csv-backup-candidates.csv') $backupRows.ToArray()

$guardSpecs = @(
    [pscustomobject]@{ guard_id='GUARD-MI350P-OBJECT'; target_path='数据/objects.csv'; pk_column='object_id'; pk_value='OBJ-AMD-MI350P'; reason='MI350P object already exists and is outside the 270-row append write-set.' },
    [pscustomobject]@{ guard_id='GUARD-CDNA4-OBJECT'; target_path='数据/objects.csv'; pk_column='object_id'; pk_value='OBJ-AMD-CDNA4-ARCH'; reason='CDNA 4 architecture object must remain unchanged while implementation facts are appended.' },
    [pscustomobject]@{ guard_id='GUARD-MI350P-CDNA4-RELATION'; target_path='数据/object-relations.csv'; pk_column='object_relation_id'; pk_value='OREL-AMD-MI350P-IMPLEMENTS-CDNA4'; reason='The pre-existing implements_architecture relation is not part of the write-set.' }
)
$guards = New-Object System.Collections.Generic.List[object]
foreach ($spec in $guardSpecs) {
    $targetFull = Get-ChildPath $rootFull $spec.target_path
    $rows = @(Import-Csv -LiteralPath $targetFull -Encoding UTF8)
    $matches = @($rows | Where-Object { [string]$_.$($spec.pk_column) -ceq [string]$spec.pk_value })
    Assert-Check ($matches.Count -eq 1) "Guard row count differs: $($spec.guard_id)"
    $guards.Add([pscustomobject][ordered]@{
        guard_id = $spec.guard_id
        target_path = $spec.target_path
        pk_column = $spec.pk_column
        pk_value = $spec.pk_value
        formal_file_sha256 = Get-Sha256 $targetFull
        formal_file_bytes = (Get-Item -LiteralPath $targetFull).Length
        canonical_row_sha256 = Get-CanonicalRowSha256 $matches[0]
        canonical_row_json = Get-CanonicalRowJson $matches[0]
        review_status = [string]$matches[0].review_status
        reason = $spec.reason
    })
}
Write-CsvNoBom (Join-Path $outputFull 'no-write-guards.csv') $guards.ToArray()

$artifactRows = New-Object System.Collections.Generic.List[object]
$artifactOrder = 0
foreach ($binding in ($artifacts | Sort-Object signoff_row_id)) {
    $artifactOrder++
    Assert-Check ([string]$binding.binding_kind -in @('card_copy','source_copy')) "Unknown artifact binding kind: $($binding.binding_kind)"
    $sourceFull = Get-ChildPath $rootFull ([string]$binding.source_path)
    Assert-Check ($sourceFull.StartsWith($stagingBase + '\',[System.StringComparison]::OrdinalIgnoreCase)) "Artifact source is outside frozen staging: $($binding.signoff_row_id)"
    $artifactSourceRelative = $sourceFull.Substring($stagingBase.Length + 1).Replace('\','/')
    Assert-Check (@($freeze | Where-Object { [string]$_.relative_path -ceq $artifactSourceRelative }).Count -eq 1) "Artifact source is absent from freeze manifest: $($binding.signoff_row_id)"
    Assert-Check ((Get-Sha256 $sourceFull) -ceq [string]$binding.source_sha256) "Artifact hash differs: $($binding.signoff_row_id)"
    Assert-Check ([string](Get-Item -LiteralPath $sourceFull).Length -ceq [string]$binding.source_bytes) "Artifact size differs: $($binding.signoff_row_id)"
    $targetFull = Get-ChildPath $rootFull ([string]$binding.target_path) $false
    Assert-Check (-not (Test-Path -LiteralPath $targetFull)) "Artifact target already exists: $($binding.target_path)"
    $artifactRows.Add([pscustomobject][ordered]@{
        commit_order = $artifactOrder
        signoff_row_id = [string]$binding.signoff_row_id
        binding_kind = [string]$binding.binding_kind
        source_path = [string]$binding.source_path
        source_sha256 = [string]$binding.source_sha256
        source_bytes = [string]$binding.source_bytes
        target_path = [string]$binding.target_path
        target_must_be_absent = 'true'
        rollback_action = 'delete_only_if_committed_hash_matches_source'
    })
}
Assert-Check ($artifactRows.Count -eq 4) 'New-file target count is not four.'
Write-CsvNoBom (Join-Path $outputFull 'new-file-targets.csv') $artifactRows.ToArray()

$rollbackRows = New-Object System.Collections.Generic.List[object]
foreach ($row in $backupRows) {
    $rollbackRows.Add([pscustomobject][ordered]@{
        inventory_role='csv_replacement'; commit_order=[string]$row.commit_order; rollback_order=[string](20-[int]$row.commit_order); target_path=[string]$row.target_path; precondition='exact_premerge_hash_and_size'; backup_content='exact_target_bytes'; rollback_action='restore_exact_backup'; irreversible='false'
    })
}
foreach ($row in $artifactRows) {
    $rollbackRows.Add([pscustomobject][ordered]@{
        inventory_role='new_file'; commit_order=[string](19+[int]$row.commit_order); rollback_order=[string](5-[int]$row.commit_order); target_path=[string]$row.target_path; precondition='target_absent'; backup_content='absence_sentinel'; rollback_action='delete_only_if_exact_committed_hash'; irreversible='false'
    })
}
foreach ($path in @('数据/objects.csv','数据/object-relations.csv')) {
    $entry = @($formalManifest | Where-Object { $_.relative_path -ceq $path })[0]
    $rollbackRows.Add([pscustomobject][ordered]@{
        inventory_role='no_write_guard_table'; commit_order='0'; rollback_order='0'; target_path=$path; precondition=('exact_full_table_hash:'+ [string]$entry.sha256); backup_content='exact_guard_table_bytes'; rollback_action='restore_only_after_unexpected_guard_mutation'; irreversible='false'
    })
}
Write-CsvNoBom (Join-Path $outputFull 'backup-rollback-inventory.csv') $rollbackRows.ToArray()

$contractFiles = @('formal-32-baseline.csv','authorized-write-set.csv','formal-csv-backup-candidates.csv','no-write-guards.csv','new-file-targets.csv','backup-rollback-inventory.csv')
$contractHashes = foreach ($name in $contractFiles) {
    $path = Join-Path $outputFull $name
    [pscustomobject][ordered]@{ relative_path=$name; sha256=Get-Sha256 $path; bytes=(Get-Item -LiteralPath $path).Length; data_rows=@(Import-Csv -LiteralPath $path -Encoding UTF8).Count }
}
Write-CsvNoBom (Join-Path $outputFull 'static-contract-file-hashes.csv') @($contractHashes)

$inputAudit = [ordered]@{
    status = 'passed'
    generated_at = '2026-08-13'
    checks = $Checks
    formal_table_count = 32
    formal_baseline_aggregate = $formalAggregate
    final_review_report_sha256 = Get-Sha256 $finalReportPath
    signoff_sha256 = Get-Sha256 $signoffPath
    signoff_rows = $signoff.Count
    structured_write_rows = $writeSet.Count
    write_table_count = $backupRows.Count
    artifact_targets = $artifactRows.Count
    target_absence_passed = $true
    no_write_guards = $guards.Count
    freeze_manifest_sha256 = Get-Sha256 $freezePath
    freeze_manifest_rows = $freeze.Count
    freeze_aggregate = $freezeAggregate
    signed_formal_manifest_sha256 = Get-Sha256 $signedFormalManifestPath
    signed_formal_manifest_rows = $signedFormalManifest.Count
    signed_source_line_failures = 0
    canonical_source_rows_frozen = $writeSet.Count
    canonical_authorized_rows_frozen = $writeSet.Count
    expected_temporary_merge_validator_checks = $ExpectedValidatorChecks
    formal_writes_performed = 0
}
$inputJson = $inputAudit | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText((Join-Path $outputFull 'input-audit.json'),$inputJson+"`r`n",$Utf8NoBom)

$staticSummary = [ordered]@{
    status = 'passed'
    generated_at = '2026-08-13'
    checks = $Checks
    authorized_write_set = [ordered]@{ rows=$writeSet.Count; tables=$backupRows.Count; sha256=Get-Sha256 (Join-Path $outputFull 'authorized-write-set.csv') }
    formal_baseline = [ordered]@{ tables=32; aggregate=$formalAggregate; manifest_sha256=Get-Sha256 (Join-Path $outputFull 'formal-32-baseline.csv') }
    no_write_guards = [ordered]@{ rows=$guards.Count; tables=@($guards.target_path | Sort-Object -Unique).Count; sha256=Get-Sha256 (Join-Path $outputFull 'no-write-guards.csv') }
    new_file_targets = [ordered]@{ rows=$artifactRows.Count; all_absent=$true; sha256=Get-Sha256 (Join-Path $outputFull 'new-file-targets.csv') }
    backup_rollback_inventory = [ordered]@{ rows=$rollbackRows.Count; sha256=Get-Sha256 (Join-Path $outputFull 'backup-rollback-inventory.csv') }
    formal_mode = 'hard_deny_pending_independent_signoff'
}
$staticJson = $staticSummary | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText((Join-Path $outputFull 'static-contract-checks.json'),$staticJson+"`r`n",$Utf8NoBom)

Write-Output "PASS: MI350P static transaction contract; $Checks checks; 270 rows across 19 tables; 4 absent file targets; formal aggregate unchanged."
