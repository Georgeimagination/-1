#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [string]$SignoffRelativePath = '审计/子代理交接/aws_post_field_rebase/aws-signoff-post-field-rebase.csv'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$script:Checks = 0

# POST-FIELD REPLAY ONLY: the target must be a separately marked isolated root. The formal SourceRoot is always rejected as TargetRoot.
$ExpectedSignoffSha256 = 'b9fa74876dfa4769df99277359f5c0be7dff268a353964abf1d392eb3708e4e3'
$ExpectedFreezeAggregate = '46fd41d8b19a82dc22c24ddee5c1b4e3534cacfe56bc4258cd1c9756ed67b552'
$ExpectedFreezeManifestSha256 = '74fe487790a0d2fbcaf012c1d60b409fd065dad5480a769843c28dab070036c4'
$ExpectedLifecycleSha256 = 'f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880'
$ExpectedFormalBaselineAggregate = 'd10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff'
$StageRelativePath = '审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED'

function Assert-Check {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    $script:Checks++
}

function Get-ExistingRoot {
    param([string]$Path, [string]$Label)
    Assert-Check (-not [string]::IsNullOrWhiteSpace($Path)) "$Label is empty."
    Assert-Check (Test-Path -LiteralPath $Path -PathType Container) "$Label does not exist: $Path"
    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
}

function Get-ChildPath {
    param([string]$Root, [string]$RelativePath, [bool]$MustExist = $false)
    Assert-Check (-not [string]::IsNullOrWhiteSpace($RelativePath)) 'Relative path is empty.'
    $normalized = $RelativePath.Replace('/', '\')
    Assert-Check (-not [System.IO.Path]::IsPathRooted($normalized)) "Rooted relative path is forbidden: $RelativePath"
    $rootPrefix = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $full = [System.IO.Path]::GetFullPath((Join-Path $Root $normalized))
    Assert-Check ($full.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) "Path escapes root: $RelativePath"
    if ($MustExist) { Assert-Check (Test-Path -LiteralPath $full -PathType Leaf) "Required file is missing: $full" }
    return $full
}

function Get-Sha256 {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-TextSha256 {
    param([string]$Text)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($sha.ComputeHash($encoding.GetBytes($Text))).Replace('-', '').ToLowerInvariant())
    }
    finally { $sha.Dispose() }
}

function Write-CsvUtf8NoBomCrlf {
    param([string]$Path, [object[]]$Rows)
    Assert-Check ($Rows.Count -gt 0) "Refusing to write an empty CSV: $Path"
    $lines = @($Rows | ConvertTo-Csv -NoTypeInformation)
    $text = ($lines -join "`r`n") + "`r`n"
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $text, $encoding)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    Assert-Check (-not ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191)) "CSV has a UTF-8 BOM: $Path"
    $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
    Assert-Check (-not [regex]::IsMatch($decoded, "(?<!`r)`n")) "CSV contains a bare LF: $Path"
    Assert-Check ($decoded.EndsWith("`r`n", [System.StringComparison]::Ordinal)) "CSV lacks a final CRLF: $Path"
}

function Get-FormalAggregate {
    param([string]$Root, [string[]]$TablePaths)
    $pairs = foreach ($tablePath in ($TablePaths | Sort-Object)) {
        $path = Get-ChildPath -Root $Root -RelativePath $tablePath -MustExist $true
        $tablePath + '|' + (Get-Sha256 $path)
    }
    return Get-TextSha256 ($pairs -join "`n")
}

function Get-Headers {
    param([object]$Row)
    return @($Row.PSObject.Properties.Name)
}

function Copy-RowToHeaders {
    param([object]$SourceRow, [string[]]$Headers)
    $sourceHeaders = @(Get-Headers $SourceRow)
    Assert-Check (($sourceHeaders -join [char]31) -ceq ($Headers -join [char]31)) 'Candidate and target headers differ.'
    $values = [ordered]@{}
    foreach ($header in $Headers) { $values[$header] = [string]$SourceRow.$header }
    return [pscustomobject]$values
}

function Get-ExactRowIndexes {
    param([object[]]$Rows, [string]$PkColumn, [string]$PkValue)
    $indexes = [System.Collections.Generic.List[int]]::new()
    for ($i = 0; $i -lt $Rows.Count; $i++) {
        if ([string]$Rows[$i].$PkColumn -ceq $PkValue) { $indexes.Add($i) }
    }
    return @($indexes)
}

function Parse-SemanticAssignments {
    param([string]$Text)
    $result = [ordered]@{}
    foreach ($part in ($Text -split ';')) {
        $position = $part.IndexOf('=')
        Assert-Check ($position -gt 0) "Invalid semantic assignment: $part"
        $key = $part.Substring(0, $position)
        $value = $part.Substring($position + 1)
        Assert-Check (-not $result.Contains($key)) "Duplicate semantic assignment: $key"
        $result[$key] = $value
    }
    return $result
}

$SourceRoot = Get-ExistingRoot -Path $SourceRoot -Label 'SourceRoot'
$TargetRoot = Get-ExistingRoot -Path $TargetRoot -Label 'TargetRoot'
Assert-Check (-not $SourceRoot.Equals($TargetRoot, [System.StringComparison]::OrdinalIgnoreCase)) 'SourceRoot and TargetRoot must be different.'
$markerPath = Join-Path $TargetRoot '.aws-merge-isolated-target'
Assert-Check (Test-Path -LiteralPath $markerPath -PathType Leaf) 'TargetRoot lacks the isolated-target marker.'
$markerText = [System.IO.File]::ReadAllText($markerPath, [System.Text.Encoding]::UTF8).Trim()
Assert-Check ($markerText -ceq 'M2-W2-AWS-PACKAGE-FACTS-ISOLATED-REHEARSAL') 'TargetRoot marker content differs.'

$signoffPath = Get-ChildPath -Root $SourceRoot -RelativePath $SignoffRelativePath -MustExist $true
Assert-Check ((Get-Sha256 $signoffPath) -ceq $ExpectedSignoffSha256) 'Signoff SHA-256 does not match the accepted review.'
$signoff = @(Import-Csv -LiteralPath $signoffPath -Encoding UTF8)
Assert-Check ($signoff.Count -eq 486) "Expected 486 signoff rows; found $($signoff.Count)."
Assert-Check (@($signoff.signoff_row_id | Sort-Object -Unique).Count -eq 486) 'Signoff row IDs are not unique.'
for ($i = 1; $i -le 486; $i++) {
    Assert-Check ($signoff[$i - 1].signoff_row_id -ceq ('AWS-SIGN-{0:D4}' -f $i)) "Unexpected signoff row sequence at $i."
}
$scopeCounts = @{}
foreach ($group in ($signoff | Group-Object authorization_scope)) { $scopeCounts[$group.Name] = $group.Count }
Assert-Check ($scopeCounts['lifecycle_pk_write'] -eq 457) 'Lifecycle authorization count is not 457.'
Assert-Check (-not $scopeCounts.ContainsKey('exact_cell_write')) 'Post-field signoff must not contain an exact-cell authorization.'
Assert-Check ($scopeCounts['semantic_signoff'] -eq 5) 'Semantic-signoff count is not 5.'
Assert-Check ($scopeCounts['exact_file_copy'] -eq 11) 'Snapshot-copy authorization count is not 11.'
Assert-Check ($scopeCounts['exact_finalized_card_write'] -eq 4) 'Final-card authorization count is not 4.'
Assert-Check ($scopeCounts['no_write_guard'] -eq 9) 'No-write guard count is not 9.'
foreach ($row in $signoff) {
    Assert-Check ($row.freeze_aggregate_sha256 -ceq $ExpectedFreezeAggregate) "Freeze aggregate binding differs: $($row.signoff_row_id)"
    Assert-Check ($row.freeze_manifest_sha256 -ceq $ExpectedFreezeManifestSha256) "Freeze manifest binding differs: $($row.signoff_row_id)"
    Assert-Check ($row.lifecycle_candidate_sha256 -ceq $ExpectedLifecycleSha256) "Lifecycle binding differs: $($row.signoff_row_id)"
    Assert-Check ($row.formal_baseline_aggregate_sha256 -ceq $ExpectedFormalBaselineAggregate) "Formal baseline binding differs: $($row.signoff_row_id)"
    if ($row.signoff_row_id -ceq 'AWS-SIGN-0458') { Assert-Check ($row.reviewer -ceq 'aws_post_field_rebase') 'FIELD-PHY-CLOCK guard reviewer differs.' }
    else { Assert-Check ($row.reviewer -ceq 'm2_final_review_aws_package') "Unexpected reviewer: $($row.signoff_row_id)" }
    Assert-Check ($row.verdict -ceq 'accept') "Unexpected verdict: $($row.signoff_row_id)"
}

$stagePath = Get-ChildPath -Root $SourceRoot -RelativePath $StageRelativePath -MustExist $false
Assert-Check (Test-Path -LiteralPath $stagePath -PathType Container) "Frozen package directory is missing: $stagePath"
$freezeManifestPath = Join-Path $stagePath 'audit\freeze-manifest.csv'
$lifecyclePath = Join-Path $stagePath 'audit\lifecycle-manifest-candidate.csv'
Assert-Check (Test-Path -LiteralPath $freezeManifestPath -PathType Leaf) 'Freeze manifest is missing.'
Assert-Check (Test-Path -LiteralPath $lifecyclePath -PathType Leaf) 'Lifecycle manifest is missing.'
Assert-Check ((Get-Sha256 $freezeManifestPath) -ceq $ExpectedFreezeManifestSha256) 'Freeze manifest SHA-256 mismatch.'
Assert-Check ((Get-Sha256 $lifecyclePath) -ceq $ExpectedLifecycleSha256) 'Lifecycle manifest SHA-256 mismatch.'
$freeze = @(Import-Csv -LiteralPath $freezeManifestPath -Encoding UTF8)
Assert-Check ($freeze.Count -eq 76) "Expected 76 freeze-manifest records; found $($freeze.Count)."
Assert-Check (@($freeze.relative_path | Sort-Object -Unique).Count -eq 76) 'Freeze-manifest paths are not unique.'
$freezeAggregateLines = [System.Collections.Generic.List[string]]::new()
$freezeByPath = @{}
foreach ($row in $freeze) {
    $frozenFile = Get-ChildPath -Root $stagePath -RelativePath $row.relative_path -MustExist $true
    Assert-Check ((Get-Sha256 $frozenFile) -ceq $row.sha256) "Frozen file hash mismatch: $($row.relative_path)"
    Assert-Check ((Get-Item -LiteralPath $frozenFile).Length -eq [int64]$row.bytes) "Frozen file byte count mismatch: $($row.relative_path)"
    $freezeAggregateLines.Add($row.relative_path + '|' + $row.sha256 + '|' + $row.bytes)
    $freezeByPath[$row.relative_path.Replace('\', '/')] = $row
}
Assert-Check ((Get-TextSha256 ($freezeAggregateLines -join "`n")) -ceq $ExpectedFreezeAggregate) 'Frozen-package aggregate mismatch.'

$lifecycle = @(Import-Csv -LiteralPath $lifecyclePath -Encoding UTF8)
Assert-Check ($lifecycle.Count -eq 457) "Expected 457 lifecycle rows; found $($lifecycle.Count)."
$lifecycleKeys = @($lifecycle | ForEach-Object { $_.table_path + [char]31 + $_.pk_value })
Assert-Check (@($lifecycleKeys | Sort-Object -Unique).Count -eq 457) 'Lifecycle table-path and primary-key pairs are not unique.'
$lifecycleByBinding = @{}
foreach ($row in $lifecycle) { $lifecycleByBinding[$row.manifest_row_id] = $row }
$lifecycleSignoff = @($signoff | Where-Object authorization_scope -ceq 'lifecycle_pk_write')
foreach ($row in $lifecycleSignoff) {
    Assert-Check ($lifecycleByBinding.ContainsKey($row.binding_id)) "Lifecycle binding is missing: $($row.binding_id)"
    $candidate = $lifecycleByBinding[$row.binding_id]
    Assert-Check ($row.target_path -ceq $candidate.table_path) "Lifecycle target differs: $($row.signoff_row_id)"
    Assert-Check ($row.pk_column -ceq $candidate.pk_column) "Lifecycle PK column differs: $($row.signoff_row_id)"
    Assert-Check ($row.pk_value -ceq $candidate.pk_value) "Lifecycle PK value differs: $($row.signoff_row_id)"
    Assert-Check ($row.action_type -ceq $candidate.write_action) "Lifecycle action differs: $($row.signoff_row_id)"
    Assert-Check ($row.formal_premerge_presence -ceq $candidate.formal_premerge_presence) "Lifecycle presence differs: $($row.signoff_row_id)"
    Assert-Check ($row.candidate_pre_review_status -ceq $candidate.old_review_status) "Lifecycle old status differs: $($row.signoff_row_id)"
    Assert-Check ($row.authorized_review_status -ceq $candidate.new_review_status) "Lifecycle new status differs: $($row.signoff_row_id)"
    Assert-Check ($row.semantic_status_after -ceq $candidate.semantic_status_after) "Lifecycle semantic state differs: $($row.signoff_row_id)"
    Assert-Check ($row.semantic_status_preserved -ceq $candidate.semantic_status_preserved) "Lifecycle semantic flag differs: $($row.signoff_row_id)"
}
Assert-Check (@($lifecycleSignoff.binding_id | Sort-Object -Unique).Count -eq 457) 'Lifecycle bindings in the signoff are not unique.'

$schemaPath = Get-ChildPath -Root $TargetRoot -RelativePath '数据/schema-columns.csv' -MustExist $true
$schema = @(Import-Csv -LiteralPath $schemaPath -Encoding UTF8)
$tablePaths = @($schema.table_path | Sort-Object -Unique)
Assert-Check ($tablePaths.Count -eq 32) "Expected 32 formal tables; found $($tablePaths.Count)."
$formalAggregate = Get-FormalAggregate -Root $TargetRoot -TablePaths $tablePaths
Assert-Check ($formalAggregate -ceq $ExpectedFormalBaselineAggregate) "Formal baseline aggregate mismatch: expected $ExpectedFormalBaselineAggregate, found $formalAggregate. No writes were performed."

$targetHashes = @{}
foreach ($row in ($signoff | Where-Object { -not [string]::IsNullOrWhiteSpace($_.formal_target_premerge_sha256) })) {
    if (-not $targetHashes.ContainsKey($row.target_path)) {
        $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $row.target_path -MustExist $true
        $targetHashes[$row.target_path] = Get-Sha256 $targetFile
    }
    Assert-Check ($targetHashes[$row.target_path] -ceq $row.formal_target_premerge_sha256) "Premerge target hash mismatch: $($row.signoff_row_id)"
}

$sourceCache = @{}
function Get-SignedSourceRows {
    param([object]$SignoffRow)
    $relative = $SignoffRow.source_path.Replace('\', '/')
    $sourceFile = Get-ChildPath -Root $SourceRoot -RelativePath $relative -MustExist $true
    Assert-Check ((Get-Sha256 $sourceFile) -ceq $SignoffRow.source_sha256) "Signed source hash mismatch: $($SignoffRow.signoff_row_id)"
    $stagePrefix = $StageRelativePath.TrimEnd('/') + '/'
    if ($relative.StartsWith($stagePrefix, [System.StringComparison]::Ordinal)) {
        $withinStage = $relative.Substring($stagePrefix.Length)
        Assert-Check ($freezeByPath.ContainsKey($withinStage)) "Signed staging source is absent from freeze manifest: $relative"
        Assert-Check ($freezeByPath[$withinStage].sha256 -ceq $SignoffRow.source_sha256) "Signoff and freeze source hashes differ: $relative"
    }
    if (-not $sourceCache.ContainsKey($relative)) {
        $sourceCache[$relative] = @(Import-Csv -LiteralPath $sourceFile -Encoding UTF8)
    }
    return @($sourceCache[$relative])
}

$guardSnapshots = @{}
$guards = @($signoff | Where-Object authorization_scope -ceq 'no_write_guard')
foreach ($guard in $guards) {
    Assert-Check ($guard.action_type -ceq 'preserve_existing_no_write') "Unexpected guard action: $($guard.signoff_row_id)"
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $guard.target_path -MustExist $true
    $rows = @(Import-Csv -LiteralPath $targetFile -Encoding UTF8)
    $indexes = @(Get-ExactRowIndexes -Rows $rows -PkColumn $guard.pk_column -PkValue $guard.pk_value)
    Assert-Check ($indexes.Count -eq 1) "No-write guard target count is not one: $($guard.signoff_row_id)"
    $guardRow = $rows[$indexes[0]]
    Assert-Check ($guardRow.review_status -ceq $guard.formal_existing_review_status) "No-write guard review status differs: $($guard.signoff_row_id)"
    Assert-Check ($guard.authorized_review_status -ceq $guard.formal_existing_review_status) "No-write guard authorization is inconsistent: $($guard.signoff_row_id)"
    $serialized = @($guardRow | ConvertTo-Csv -NoTypeInformation) -join "`n"
    $guardSnapshots[$guard.signoff_row_id] = [pscustomobject]@{
        file_hash = Get-Sha256 $targetFile
        row_hash = Get-TextSha256 $serialized
    }
}

$fieldGuards = @($guards | Where-Object { $_.target_path -ceq '数据/fields.csv' -and $_.pk_column -ceq 'field_id' -and $_.pk_value -ceq 'FIELD-PHY-CLOCK' })
Assert-Check ($fieldGuards.Count -eq 1) 'FIELD-PHY-CLOCK already-satisfied guard count is not one.'
$fieldGuard = $fieldGuards[0]
Assert-Check ($fieldGuard.action_type -ceq 'preserve_existing_no_write') 'FIELD-PHY-CLOCK guard action differs.'
Assert-Check ($fieldGuard.semantic_status_preserved -ceq 'true_already_satisfied_full_row_guard') 'FIELD-PHY-CLOCK guard semantic flag differs.'
Assert-Check ($fieldGuard.binding_id -ceq 'FIELD-CONTRACT-AWS-ALREADY-SATISFIED-GUARD') 'FIELD-PHY-CLOCK guard binding differs.'
$fieldCandidateRows = @(Get-SignedSourceRows -SignoffRow $fieldGuard)
Assert-Check ($fieldCandidateRows.Count -eq 1) 'Historical AWS field candidate must contain one row.'
Assert-Check ($fieldCandidateRows[0].current_allowed_subject_kinds -ceq 'object') 'Historical AWS field candidate old value differs.'
Assert-Check ($fieldCandidateRows[0].proposed_allowed_subject_kinds -ceq 'object;component') 'Historical AWS field candidate proposed value differs.'
$fieldTargetFile = Get-ChildPath -Root $TargetRoot -RelativePath '数据/fields.csv' -MustExist $true
$fieldTargetRows = @(Import-Csv -LiteralPath $fieldTargetFile -Encoding UTF8)
$fieldTargetHeaders = @(Get-Headers $fieldTargetRows[0])
Assert-Check ($fieldTargetHeaders.Count -eq 13) 'Current fields.csv must retain 13 columns.'
Assert-Check ($fieldTargetHeaders -ccontains 'allowed_requirement_target_kinds') 'Current fields.csv lacks allowed_requirement_target_kinds.'
$fieldTargetIndexes = @(Get-ExactRowIndexes -Rows $fieldTargetRows -PkColumn 'field_id' -PkValue 'FIELD-PHY-CLOCK')
Assert-Check ($fieldTargetIndexes.Count -eq 1) 'FIELD-PHY-CLOCK current target count is not one.'
Assert-Check ($fieldTargetRows[$fieldTargetIndexes[0]].allowed_subject_kinds -ceq 'object;component') 'FIELD-PHY-CLOCK is not already satisfied on the current baseline.'
Assert-Check ($fieldTargetRows[$fieldTargetIndexes[0]].allowed_requirement_target_kinds -ceq 'object;component;precision_path') 'FIELD-PHY-CLOCK requirement contract differs on the current baseline.'
Assert-Check (@($lifecycleSignoff | Where-Object { $_.target_path -ceq '数据/fields.csv' }).Count -eq 0) 'Frozen 12-column fields staging must not enter lifecycle writes.'
$copyAuthorizations = @($signoff | Where-Object { $_.authorization_scope -in @('exact_file_copy', 'exact_finalized_card_write') })
foreach ($copyRow in $copyAuthorizations) {
    Assert-Check ($copyRow.action_type -ceq 'copy_bytes_if_target_absent') "Unexpected file-copy action: $($copyRow.signoff_row_id)"
    $sourceFile = Get-ChildPath -Root $SourceRoot -RelativePath $copyRow.source_path -MustExist $true
    Assert-Check ((Get-Sha256 $sourceFile) -ceq $copyRow.source_sha256) "File-copy source hash mismatch: $($copyRow.signoff_row_id)"
    Assert-Check ($copyRow.source_sha256 -ceq $copyRow.expected_output_sha256) "File-copy source and output hashes differ: $($copyRow.signoff_row_id)"
    Assert-Check ((Get-Item -LiteralPath $sourceFile).Length -eq [int64]$copyRow.expected_output_bytes) "File-copy source byte count mismatch: $($copyRow.signoff_row_id)"
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $copyRow.target_path -MustExist $false
    Assert-Check (-not (Test-Path -LiteralPath $targetFile)) "Authorized copy target already exists; refusing to overwrite: $targetFile"
}

foreach ($row in $lifecycleSignoff) {
    $sourceRows = @(Get-SignedSourceRows -SignoffRow $row)
    $sourceIndexes = @(Get-ExactRowIndexes -Rows $sourceRows -PkColumn $row.pk_column -PkValue $row.pk_value)
    Assert-Check ($sourceIndexes.Count -eq 1) "Signed source PK count is not one: $($row.signoff_row_id)"
    $sourceRow = $sourceRows[$sourceIndexes[0]]
    Assert-Check ($sourceRow.review_status -ceq $row.candidate_pre_review_status) "Candidate review status differs: $($row.signoff_row_id)"
    if (-not [string]::IsNullOrWhiteSpace($row.semantic_status_after)) {
        $semanticAssignments = Parse-SemanticAssignments $row.semantic_status_after
        foreach ($key in $semanticAssignments.Keys) {
            Assert-Check ($sourceRow.PSObject.Properties.Name -ccontains $key) "Semantic field is absent from source row: $($row.signoff_row_id) $key"
            Assert-Check ([string]$sourceRow.$key -ceq [string]$semanticAssignments[$key]) "Candidate semantic state differs: $($row.signoff_row_id) $key"
        }
    }
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $row.target_path -MustExist $true
    $targetRows = @(Import-Csv -LiteralPath $targetFile -Encoding UTF8)
    $targetIndexes = @(Get-ExactRowIndexes -Rows $targetRows -PkColumn $row.pk_column -PkValue $row.pk_value)
    if ($row.formal_premerge_presence -ceq 'absent') {
        Assert-Check ($targetIndexes.Count -eq 0) "Append target already exists: $($row.signoff_row_id)"
    }
    elseif ($row.formal_premerge_presence -ceq 'present') {
        Assert-Check ($targetIndexes.Count -eq 1) "Update target count is not one: $($row.signoff_row_id)"
        Assert-Check ($targetRows[$targetIndexes[0]].review_status -ceq $row.formal_existing_review_status) "Existing review status differs: $($row.signoff_row_id)"
    }
    else { throw "Unsupported formal_premerge_presence: $($row.formal_premerge_presence)" }
}

$writesPerformed = 0
foreach ($tableGroup in ($lifecycleSignoff | Group-Object target_path)) {
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $tableGroup.Name -MustExist $true
    $mergedRows = [System.Collections.ArrayList]::new()
    foreach ($existing in @(Import-Csv -LiteralPath $targetFile -Encoding UTF8)) { [void]$mergedRows.Add($existing) }
    Assert-Check ($mergedRows.Count -gt 0) "Formal table is empty: $($tableGroup.Name)"
    $headers = @(Get-Headers $mergedRows[0])
    foreach ($write in $tableGroup.Group) {
        $sourceRows = @(Get-SignedSourceRows -SignoffRow $write)
        $sourceIndex = @(Get-ExactRowIndexes -Rows $sourceRows -PkColumn $write.pk_column -PkValue $write.pk_value)[0]
        $newRow = Copy-RowToHeaders -SourceRow $sourceRows[$sourceIndex] -Headers $headers
        Assert-Check ($newRow.PSObject.Properties.Name -ccontains 'review_status') "Lifecycle target lacks review_status: $($write.signoff_row_id)"
        $newRow.review_status = $write.authorized_review_status
        $existingIndexes = @(Get-ExactRowIndexes -Rows @($mergedRows) -PkColumn $write.pk_column -PkValue $write.pk_value)
        switch ($write.action_type) {
            'append_then_promote_review_status' {
                Assert-Check ($existingIndexes.Count -eq 0) "Append collision during write: $($write.signoff_row_id)"
                [void]$mergedRows.Add($newRow)
            }
            'append_without_review_promotion' {
                Assert-Check ($existingIndexes.Count -eq 0) "Append collision during write: $($write.signoff_row_id)"
                Assert-Check ($write.authorized_review_status -ceq $write.candidate_pre_review_status) "Non-promotion action changes review status: $($write.signoff_row_id)"
                [void]$mergedRows.Add($newRow)
            }
            'update_existing_then_promote_review_status' {
                Assert-Check ($existingIndexes.Count -eq 1) "Update target count changed during write: $($write.signoff_row_id)"
                $mergedRows[$existingIndexes[0]] = $newRow
            }
            'update_existing_preserve_review_status' {
                Assert-Check ($existingIndexes.Count -eq 1) "Update target count changed during write: $($write.signoff_row_id)"
                Assert-Check ($write.authorized_review_status -ceq $write.formal_existing_review_status) "Preserve action changes review status: $($write.signoff_row_id)"
                $mergedRows[$existingIndexes[0]] = $newRow
            }
            default { throw "Unsupported lifecycle action: $($write.action_type)" }
        }
        $writesPerformed++
    }
    Write-CsvUtf8NoBomCrlf -Path $targetFile -Rows @($mergedRows)
}
Assert-Check ($writesPerformed -eq 457) "Lifecycle writes executed: $writesPerformed; expected 457."

Assert-Check (@($lifecycleSignoff | Where-Object { $_.target_path -ceq '数据/fields.csv' }).Count -eq 0) 'Lifecycle writes must not target fields.csv.'

$semanticSignoffs = @($signoff | Where-Object authorization_scope -ceq 'semantic_signoff')
foreach ($semanticGroup in ($semanticSignoffs | Group-Object target_path)) {
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $semanticGroup.Name -MustExist $true
    $rows = [System.Collections.ArrayList]::new()
    foreach ($item in @(Import-Csv -LiteralPath $targetFile -Encoding UTF8)) { [void]$rows.Add($item) }
    foreach ($semanticWrite in $semanticGroup.Group) {
        [void](Get-SignedSourceRows -SignoffRow $semanticWrite)
        $indexes = @(Get-ExactRowIndexes -Rows @($rows) -PkColumn $semanticWrite.pk_column -PkValue $semanticWrite.pk_value)
        Assert-Check ($indexes.Count -eq 1) "Semantic target count is not one: $($semanticWrite.signoff_row_id)"
        $targetRow = $rows[$indexes[0]]
        Assert-Check ($targetRow.review_status -ceq 'reviewed') "Semantic target lifecycle status is not reviewed: $($semanticWrite.signoff_row_id)"
        $assignments = Parse-SemanticAssignments $semanticWrite.semantic_status_after
        if ($semanticWrite.pk_value -ceq 'SELRUN-M2W2-AWS-PKG-20260813') {
            Assert-Check (($assignments.Keys -join [char]31) -ceq ('status' + [char]31 + 'reviewer' + [char]31 + 'notes')) 'Selection-run semantic fields differ from authorization.'
            Assert-Check ($targetRow.status -ceq 'draft') 'Selection-run old business status differs.'
            Assert-Check ($targetRow.reviewer -ceq 'pending_independent_reviewer') 'Selection-run old reviewer differs.'
            $selectionNotes = [string]$targetRow.notes
            Assert-Check ($selectionNotes.EndsWith('等待独立复核。')) 'Selection-run old notes differ.'
        }
        else {
            Assert-Check (($assignments.Keys -join [char]31) -ceq ('completeness_status' + [char]31 + 'assessor' + [char]31 + 'notes')) "Evidence semantic fields differ: $($semanticWrite.signoff_row_id)"
            Assert-Check ($targetRow.completeness_status -ceq 'needs_review') "Evidence old completeness differs: $($semanticWrite.signoff_row_id)"
            Assert-Check ($targetRow.assessor -ceq 'm2_w2_aws_package_facts') "Evidence old assessor differs: $($semanticWrite.signoff_row_id)"
        }
        foreach ($key in $assignments.Keys) {
            Assert-Check ($targetRow.PSObject.Properties.Name -ccontains $key) "Semantic field is absent: $($semanticWrite.signoff_row_id) $key"
            $targetRow.$key = [string]$assignments[$key]
        }
        $rows[$indexes[0]] = $targetRow
        $writesPerformed++
    }
    Write-CsvUtf8NoBomCrlf -Path $targetFile -Rows @($rows)
}

foreach ($copyRow in $copyAuthorizations) {
    $sourceFile = Get-ChildPath -Root $SourceRoot -RelativePath $copyRow.source_path -MustExist $true
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $copyRow.target_path -MustExist $false
    Assert-Check (-not (Test-Path -LiteralPath $targetFile)) "Copy target appeared after preflight; refusing to overwrite: $targetFile"
    $targetDirectory = Split-Path -Parent $targetFile
    [System.IO.Directory]::CreateDirectory($targetDirectory) | Out-Null
    Assert-Check (Test-Path -LiteralPath $targetDirectory -PathType Container) "Copy target parent was not created: $targetDirectory"
    [System.IO.File]::Copy($sourceFile, $targetFile, $false)
    Assert-Check ((Get-Sha256 $targetFile) -ceq $copyRow.expected_output_sha256) "Copied file hash mismatch: $($copyRow.signoff_row_id)"
    Assert-Check ((Get-Item -LiteralPath $targetFile).Length -eq [int64]$copyRow.expected_output_bytes) "Copied file byte count mismatch: $($copyRow.signoff_row_id)"
    $writesPerformed++
}
Assert-Check ($writesPerformed -eq 477) "Authorized writes executed: $writesPerformed; expected 477."

foreach ($guard in $guards) {
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $guard.target_path -MustExist $true
    Assert-Check ((Get-Sha256 $targetFile) -ceq $guardSnapshots[$guard.signoff_row_id].file_hash) "No-write guard table changed: $($guard.signoff_row_id)"
    $rows = @(Import-Csv -LiteralPath $targetFile -Encoding UTF8)
    $indexes = @(Get-ExactRowIndexes -Rows $rows -PkColumn $guard.pk_column -PkValue $guard.pk_value)
    Assert-Check ($indexes.Count -eq 1) "No-write guard target count changed: $($guard.signoff_row_id)"
    $serialized = @($rows[$indexes[0]] | ConvertTo-Csv -NoTypeInformation) -join "`n"
    Assert-Check ((Get-TextSha256 $serialized) -ceq $guardSnapshots[$guard.signoff_row_id].row_hash) "No-write guard row changed: $($guard.signoff_row_id)"
}

foreach ($row in $lifecycleSignoff) {
    $targetFile = Get-ChildPath -Root $TargetRoot -RelativePath $row.target_path -MustExist $true
    $targetRows = @(Import-Csv -LiteralPath $targetFile -Encoding UTF8)
    $indexes = @(Get-ExactRowIndexes -Rows $targetRows -PkColumn $row.pk_column -PkValue $row.pk_value)
    Assert-Check ($indexes.Count -eq 1) "Final lifecycle PK count is not one: $($row.signoff_row_id)"
    Assert-Check ($targetRows[$indexes[0]].review_status -ceq $row.authorized_review_status) "Final lifecycle status differs: $($row.signoff_row_id)"
}

function Get-RowCount {
    param([string]$RelativePath)
    $path = Get-ChildPath -Root $TargetRoot -RelativePath $RelativePath -MustExist $true
    return @(Import-Csv -LiteralPath $path -Encoding UTF8).Count
}
Assert-Check ((Get-RowCount '数据/objects.csv') -eq 78) 'Object count is not 78.'
Assert-Check ((Get-RowCount '数据/object-relations.csv') -eq 27) 'Object-relation count is not 27.'
Assert-Check ((Get-RowCount '数据/facts.csv') -eq 678) 'Fact count is not 678.'
Assert-Check ((Get-RowCount '最小参考资料库/fact-assertions.csv') -eq 680) 'Fact-assertion count is not 680.'
Assert-Check ((Get-RowCount '数据/field-requirements.csv') -eq 863) 'Field-requirement count is not 863.'
Assert-Check ((Get-RowCount '最小参考资料库/selection-runs.csv') -eq 8) 'Selection-run count is not 8.'
Assert-Check ((Get-RowCount '最小参考资料库/selection-members.csv') -eq 96) 'Selection-member count is not 96.'
$cardRoot = Get-ChildPath -Root $TargetRoot -RelativePath '资料卡' -MustExist $false
Assert-Check (Test-Path -LiteralPath $cardRoot -PathType Container) 'Card root is missing.'
$cardFiles = @(Get-ChildItem -LiteralPath $cardRoot -Recurse -File -Filter '*.md' | Where-Object { $_.DirectoryName -cne $cardRoot })
Assert-Check ($cardFiles.Count -eq 40) "Accepted/nested card-file count is not 40; found $($cardFiles.Count)."

$result = [pscustomobject][ordered]@{
    status = 'PASS'
    checks = $script:Checks
    authorized_writes = $writesPerformed
    no_write_guards = $guards.Count
    signed_baseline_aggregate = $formalAggregate
    objects = 78
    object_relations = 27
    facts = 678
    fact_assertions = 680
    field_requirements = 863
    cards = 40
    selection_runs = 8
    selection_members = 96
}
$result | ConvertTo-Json -Compress
