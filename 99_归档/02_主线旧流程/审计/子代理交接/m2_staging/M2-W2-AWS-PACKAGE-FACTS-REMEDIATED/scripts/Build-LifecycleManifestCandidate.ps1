#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$StagePath = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS-REMEDIATED'
$StructuredPath = Join-Path $StagePath 'structured'
$AuditPath = Join-Path $StagePath 'audit'
$Schema = @(Import-Csv -LiteralPath (Join-Path $RootPath '数据\schema-columns.csv') -Encoding UTF8)
$BatchId = 'M2-W2-AWS-PACKAGE-FACTS-REMEDIATED'
$semanticColumns = @(
    'source_status','endpoint_validation_status','screening_status','completeness_status',
    'resolution_state','evidence_state','extraction_status','requirement_status','search_status',
    'result_status','resolution_status','equivalence_status','status','selected_role'
)

function Get-SemanticStatus([object]$Row) {
    $parts = [System.Collections.Generic.List[string]]::new()
    foreach ($column in $semanticColumns) {
        if (($Row.PSObject.Properties.Name -contains $column) -and (-not [string]::IsNullOrWhiteSpace([string]$Row.$column))) {
            $parts.Add("$column=$($Row.$column)")
        }
    }
    return ($parts -join ';')
}

$records = [System.Collections.Generic.List[object]]::new()
$sequence = 0
foreach ($tablePath in @($Schema.table_path | Sort-Object -Unique)) {
    $name = Split-Path $tablePath -Leaf
    $candidatePath = Join-Path $StructuredPath $name
    $rows = @(Import-Csv -LiteralPath $candidatePath -Encoding UTF8)
    if ($rows.Count -eq 0) { continue }
    $group = @($Schema | Where-Object table_path -eq $tablePath)
    $pkColumns = @($group | Where-Object is_primary_key -eq 'true' | Select-Object -ExpandProperty column_name)
    if ($pkColumns.Count -ne 1) { throw "Expected one primary key for $tablePath." }
    $pk = $pkColumns[0]
    $formalRows = @(Import-Csv -LiteralPath (Join-Path $RootPath $tablePath.Replace('/','\')) -Encoding UTF8)
    foreach ($row in $rows) {
        if (@($formalRows | Where-Object { $_.$pk -eq $row.$pk }).Count -gt 0) { throw "Append candidate already exists in formal table: $tablePath $($row.$pk)." }
        $sequence++
        $oldStatus = [string]$row.review_status
        $included = $oldStatus -eq 'draft'
        $newStatus = if ($included) { 'reviewed' } else { $oldStatus }
        $reason = ''
        if ($oldStatus -eq 'needs_resolution') {
            $reason = '未决冲突链不进入本次 reviewed 晋级；正式追加时保持 needs_resolution，且不改变 resolution/evidence 等语义状态。'
        } elseif (-not $included) {
            $reason = "候选行当前 review_status=$oldStatus，不需要 draft→reviewed 迁移。"
        }
        $records.Add([pscustomobject][ordered]@{
            manifest_row_id=('LCM-M2W2-AWS-PKG-{0:D4}' -f $sequence)
            table_path=$tablePath
            pk_column=$pk
            pk_value=$row.$pk
            batch_id=$BatchId
            write_action=($(if ($included) { 'append_then_promote_review_status' } else { 'append_without_review_promotion' }))
            formal_premerge_presence='absent'
            old_review_status=$oldStatus
            new_review_status=$newStatus
            review_promotion_included=([string]$included).ToLowerInvariant()
            semantic_status_after=(Get-SemanticStatus $row)
            semantic_status_preserved='true'
            exclusion_reason=$reason
            package_review='pending_independent_review'
            independent_signoff='pending'
            freeze_binding_status='pending_after_final_freeze'
            evidence_basis='DEC-025 candidate generated from the actual nonempty structured rows in the remediated package.'
        })
    }
}

$overlays = @(
    [pscustomobject]@{ table_path='最小参考资料库/sources.csv'; file='source-updates.csv' },
    [pscustomobject]@{ table_path='最小参考资料库/source-endpoints.csv'; file='source-endpoint-updates.csv' },
    [pscustomobject]@{ table_path='最小参考资料库/source-screening.csv'; file='source-screening-updates.csv' }
)
foreach ($overlay in $overlays) {
    $group = @($Schema | Where-Object table_path -eq $overlay.table_path)
    $pkColumns = @($group | Where-Object is_primary_key -eq 'true' | Select-Object -ExpandProperty column_name)
    if ($pkColumns.Count -ne 1) { throw "Expected one primary key for overlay $($overlay.table_path)." }
    $pk = $pkColumns[0]
    $formalRows = @(Import-Csv -LiteralPath (Join-Path $RootPath $overlay.table_path.Replace('/','\')) -Encoding UTF8)
    $updates = @(Import-Csv -LiteralPath (Join-Path $AuditPath $overlay.file) -Encoding UTF8)
    foreach ($row in $updates) {
        $formal = @($formalRows | Where-Object { $_.$pk -eq $row.$pk })
        if ($formal.Count -ne 1) { throw "Overlay target count for $($overlay.table_path) $($row.$pk): $($formal.Count)." }
        $sequence++
        $oldStatus = [string]$formal[0].review_status
        $candidateStatus = [string]$row.review_status
        $included = ($oldStatus -eq 'draft') -and ($candidateStatus -eq 'draft')
        $newStatus = if ($included) { 'reviewed' } else { $candidateStatus }
        $reason = ''
        if (($oldStatus -eq 'reviewed') -and ($candidateStatus -eq 'reviewed')) {
            $reason = 'update_existing 只更新筛选语义，review_status 保持 reviewed；不发生生命周期倒退，也不需要晋级。'
        } elseif (-not $included) {
            $reason = "update_existing 不满足 draft→reviewed 候选条件：formal=$oldStatus,candidate=$candidateStatus。"
        }
        $records.Add([pscustomobject][ordered]@{
            manifest_row_id=('LCM-M2W2-AWS-PKG-{0:D4}' -f $sequence)
            table_path=$overlay.table_path
            pk_column=$pk
            pk_value=$row.$pk
            batch_id=$BatchId
            write_action=($(if ($included) { 'update_existing_then_promote_review_status' } else { 'update_existing_preserve_review_status' }))
            formal_premerge_presence='present'
            old_review_status=$oldStatus
            new_review_status=$newStatus
            review_promotion_included=([string]$included).ToLowerInvariant()
            semantic_status_after=(Get-SemanticStatus $row)
            semantic_status_preserved='true'
            exclusion_reason=$reason
            package_review='pending_independent_review'
            independent_signoff='pending'
            freeze_binding_status='pending_after_final_freeze'
            evidence_basis='DEC-025 candidate generated from the actual audit overlay row and its current formal primary-key target.'
        })
    }
}

$outPath = Join-Path $AuditPath 'lifecycle-manifest-candidate.csv'
$records | Export-Csv -LiteralPath $outPath -NoTypeInformation -Encoding UTF8
$hash = (Get-FileHash -LiteralPath $outPath -Algorithm SHA256).Hash.ToLowerInvariant()
[System.IO.File]::WriteAllText((Join-Path $AuditPath 'lifecycle-manifest-candidate.sha256'),$hash + [Environment]::NewLine,(New-Object System.Text.UTF8Encoding($false)))

$duplicate = @($records | Group-Object table_path,pk_value | Where-Object Count -gt 1)
if ($duplicate.Count -gt 0) { throw "Lifecycle manifest duplicate table/PK pairs: $($duplicate.Count)." }
$includedCount = @($records | Where-Object review_promotion_included -eq 'true').Count
$excludedCount = $records.Count - $includedCount
Write-Output "Lifecycle manifest candidate: $($records.Count) actual write rows; $includedCount review promotions; $excludedCount non-promotions; sha256=$hash."