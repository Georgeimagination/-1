#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = '.',
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [switch]$AllowNonEmptyTarget
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RootPath).Path
$outDir = Join-Path $root '审计\子代理交接\field_subject_contract_remediation'
if (Test-Path -LiteralPath (Join-Path $outDir 'manifest.csv') -PathType Leaf) { throw 'Refusing to regenerate a frozen remediation package; use a fresh output directory.' }
$targetFull = [System.IO.Path]::GetFullPath($TargetRoot)
$outFull = (Resolve-Path -LiteralPath $outDir).Path
if ($targetFull.StartsWith($root + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase) -and -not $targetFull.StartsWith($outFull + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to write a target inside the project outside remediation output: $targetFull"
}
if (-not (Test-Path -LiteralPath $targetFull -PathType Container)) { [void](New-Item -ItemType Directory -Path $targetFull -Force) }
if (-not $AllowNonEmptyTarget -and @(Get-ChildItem -LiteralPath $targetFull -Force).Count -gt 0) { throw "TargetRoot is not empty: $targetFull" }

function Require([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Resolve-Relative([string]$Base, [string]$Relative) {
    $p = $Base
    foreach ($part in ($Relative -split '/')) { $p = Join-Path $p $part }
    return $p
}
function Write-CsvUtf8NoBom([object[]]$Rows, [string[]]$Headers, [string]$Path) {
    $ordered = foreach ($row in $Rows) { $row | Select-Object -Property $Headers }
    $text = (@($ordered | ConvertTo-Csv -NoTypeInformation) -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($Path, $text, [System.Text.UTF8Encoding]::new($false))
}
function Get-LowerHash([string]$Path) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-CellMap([object[]]$Rows, [string]$Pk, [string[]]$Headers) {
    $map = @{}
    foreach ($row in $Rows) {
        $pkv = [string]$row.$Pk
        foreach ($h in $Headers) { $map["$pkv|$h"] = [string]$row.$h }
    }
    return $map
}

$formalFiles = @(
    '数据/fields.csv',
    '数据/schema-columns.csv',
    '数据/field-requirements.csv',
    '数据/facts.csv',
    '数据/enums.csv',
    '数据/objects.csv',
    '数据/components.csv',
    '数据/links.csv',
    '数据/object-relations.csv',
    '数据/precision-paths.csv',
    '数据/special-capabilities.csv',
    '数据/topologies.csv',
    '数据/card-completeness.csv',
    '数据/condition-sets.csv',
    '数据/derived-inputs.csv',
    '数据/derived-metrics.csv',
    '数据/memory-levels.csv',
    '数据/vendors.csv',
    '最小参考资料库/conflict-groups.csv',
    '最小参考资料库/conflict-members.csv',
    '最小参考资料库/fact-assertions.csv',
    '最小参考资料库/requirement-evidence.csv',
    '最小参考资料库/search-log.csv',
    '最小参考资料库/search-results.csv',
    '最小参考资料库/selection-members.csv',
    '最小参考资料库/selection-runs.csv',
    '最小参考资料库/source-coverage.csv',
    '最小参考资料库/source-endpoints.csv',
    '最小参考资料库/source-families.csv',
    '最小参考资料库/source-screening.csv',
    '最小参考资料库/source-selected-roles.csv',
    '最小参考资料库/sources.csv'
)
foreach ($rel in $formalFiles) {
    $src = Resolve-Relative $root $rel
    $dst = Resolve-Relative $targetFull $rel
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
    Copy-Item -LiteralPath $src -Destination $dst -Force
}
$endpointRows = @(Import-Csv -LiteralPath (Resolve-Relative $root '最小参考资料库/source-endpoints.csv'))
foreach ($rel in @($endpointRows | Where-Object { -not [string]::IsNullOrWhiteSpace($_.local_path) } | Select-Object -ExpandProperty local_path -Unique)) {
    $src = Resolve-Relative $root $rel
    $dst = Resolve-Relative $targetFull $rel
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
    Copy-Item -LiteralPath $src -Destination $dst -Force
}
$validatorDst = Resolve-Relative $targetFull 'scripts/validation/Validate-ResearchData.ps1'
[void](New-Item -ItemType Directory -Path (Split-Path -Parent $validatorDst) -Force)
Copy-Item -LiteralPath (Join-Path $outDir 'Validate-ResearchData.ps1') -Destination $validatorDst -Force

$proposals = @(Import-Csv -LiteralPath (Join-Path $outDir 'field-contract-proposals.csv'))
$overlay = @(Import-Csv -LiteralPath (Join-Path $outDir 'row-overlay-proposals.csv'))
Require ($proposals.Count -eq 26) 'Expected 26 field proposals.'
Require ($overlay.Count -eq 12) 'Expected 12 row overlays.'

$fieldsPath = Resolve-Relative $targetFull '数据/fields.csv'
$fieldsBefore = @(Import-Csv -LiteralPath $fieldsPath)
$fieldHeadersBefore = @($fieldsBefore[0].PSObject.Properties.Name)
Require ($fieldHeadersBefore -notcontains 'allowed_requirement_target_kinds') 'Requirement contract column already exists in target.'
$proposalById = @{}; foreach ($p in $proposals) { $proposalById[$p.field_id] = $p }
$fieldHeadersAfter = @($fieldHeadersBefore) + @('allowed_requirement_target_kinds')
$fieldsAfter = foreach ($row in $fieldsBefore) {
    $props = [ordered]@{}
    foreach ($h in $fieldHeadersAfter) {
        if ($h -eq 'allowed_requirement_target_kinds') {
            $props[$h] = if ($proposalById.ContainsKey($row.field_id)) { [string]$proposalById[$row.field_id].proposed_requirement_target_kinds } else { [string]$row.allowed_subject_kinds }
        } elseif ($h -eq 'allowed_subject_kinds' -and $proposalById.ContainsKey($row.field_id)) {
            $props[$h] = [string]$proposalById[$row.field_id].proposed_fact_allowed_subject_kinds
        } else { $props[$h] = [string]$row.$h }
    }
    [pscustomobject]$props
}
Write-CsvUtf8NoBom -Rows @($fieldsAfter) -Headers $fieldHeadersAfter -Path $fieldsPath

$schemaPath = Resolve-Relative $targetFull '数据/schema-columns.csv'
$schemaBefore = @(Import-Csv -LiteralPath $schemaPath)
$schemaHeaders = @($schemaBefore[0].PSObject.Properties.Name)
Require (@($schemaBefore | Where-Object schema_column_id -eq 'SCOL-FIELDS-CSV-013').Count -eq 0) 'SCOL-FIELDS-CSV-013 already exists.'
$schemaNew = [pscustomobject][ordered]@{
    schema_column_id='SCOL-FIELDS-CSV-013'
    table_path='数据/fields.csv'
    column_name='allowed_requirement_target_kinds'
    ordinal='13'
    data_type='text'
    is_nullable='false'
    is_primary_key='false'
    foreign_table_path=''
    foreign_column_name=''
    enum_name=''
    semicolon_forbidden='false'
    definition='字段要求允许覆盖的目标类型；使用规范顺序的分号多值集合，与事实主体合同分离。'
    review_status='approved'
    notes='字段主体合同修正版新增。'
}
$schemaAfter = @($schemaBefore) + @($schemaNew)
Write-CsvUtf8NoBom -Rows @($schemaAfter) -Headers $schemaHeaders -Path $schemaPath

$reqPath = Resolve-Relative $targetFull '数据/field-requirements.csv'
$requirementsBefore = @(Import-Csv -LiteralPath $reqPath)
$reqHeaders = @($requirementsBefore[0].PSObject.Properties.Name)
$reqById = @{}; foreach ($r in $requirementsBefore) { $reqById[$r.requirement_id] = $r }
$targetColumns = [ordered]@{object='object_id';component='component_id';link='link_id';object_relation='object_relation_id';precision_path='precision_path_id';capability='capability_id';topology='topology_id'}
foreach ($o in $overlay) {
    Require ($reqById.ContainsKey($o.pk)) "Overlay requirement missing: $($o.pk)"
    $row = $reqById[$o.pk]
    $currentKind = @($targetColumns.GetEnumerator() | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$row.($_.Value)) })
    Require ($currentKind.Count -eq 1 -and $currentKind[0].Key -eq $o.current_target_kind -and [string]$row.($currentKind[0].Value) -eq $o.current_target_id) "Overlay current target mismatch: $($o.pk)"
    foreach ($column in $targetColumns.Values) { $row.$column = '' }
    $row.($targetColumns[$o.proposed_target_kind]) = [string]$o.proposed_target_id
    $row.requirement_fingerprint = [string]$o.proposed_requirement_fingerprint
}
Write-CsvUtf8NoBom -Rows @($requirementsBefore) -Headers $reqHeaders -Path $reqPath
foreach ($csvPath in @($fieldsPath,$schemaPath,$reqPath)) {
    $bytes = [System.IO.File]::ReadAllBytes($csvPath)
    Require (-not ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191)) "Formal CSV candidate has UTF-8 BOM: $csvPath"
    $csvText = [System.Text.UTF8Encoding]::new($false,$true).GetString($bytes)
    Require ($csvText.EndsWith("`r`n", [System.StringComparison]::Ordinal)) "Formal CSV candidate lacks final CRLF: $csvPath"
    Require (-not ($csvText.Replace("`r`n",'').Contains("`n"))) "Formal CSV candidate has bare LF: $csvPath"
}

# Exact difference manifest.
$manifest = [System.Collections.Generic.List[object]]::new()
function Add-Diffs([string]$Rel, [object[]]$Before, [object[]]$After, [string]$Pk, [string[]]$HeadersBefore, [string[]]$HeadersAfter) {
    $beforeMap = Get-CellMap $Before $Pk $HeadersBefore
    $afterMap = Get-CellMap $After $Pk $HeadersAfter
    foreach ($key in @($beforeMap.Keys + $afterMap.Keys | Sort-Object -Unique)) {
        $old = if ($beforeMap.ContainsKey($key)) { $beforeMap[$key] } else { '' }
        $new = if ($afterMap.ContainsKey($key)) { $afterMap[$key] } else { '' }
        if ($old -cne $new) {
            $sep = $key.IndexOf('|')
            $manifest.Add([pscustomobject][ordered]@{target_path=$Rel;pk_column=$Pk;pk_value=$key.Substring(0,$sep);column_name=$key.Substring($sep+1);old_value=$old;new_value=$new;change_kind=if($beforeMap.ContainsKey($key)){'update_cell'}else{'add_cell'}})
        }
    }
}
Add-Diffs '数据/fields.csv' $fieldsBefore $fieldsAfter 'field_id' $fieldHeadersBefore $fieldHeadersAfter
Add-Diffs '数据/schema-columns.csv' $schemaBefore $schemaAfter 'schema_column_id' $schemaHeaders $schemaHeaders
Add-Diffs '数据/field-requirements.csv' (@(Import-Csv -LiteralPath (Resolve-Relative $root '数据/field-requirements.csv'))) $requirementsBefore 'requirement_id' $reqHeaders $reqHeaders

$validatorSource = Join-Path $root 'scripts\validation\Validate-ResearchData.ps1'
$manifest.Add([pscustomobject][ordered]@{target_path='scripts/validation/Validate-ResearchData.ps1';pk_column='file';pk_value='Validate-ResearchData.ps1';column_name='file_bytes';old_value=(Get-Item -LiteralPath $validatorSource).Length;new_value=(Get-Item -LiteralPath $validatorDst).Length;change_kind='replace_file'})
$manifestPath = Join-Path $outDir 'formal-migration-manifest.csv'
$manifestHeaders = @('target_path','pk_column','pk_value','column_name','old_value','new_value','change_kind')
Write-CsvUtf8NoBom -Rows @($manifest) -Headers $manifestHeaders -Path $manifestPath

$fileHashes = foreach ($rel in @('数据/fields.csv','数据/schema-columns.csv','数据/field-requirements.csv','数据/facts.csv','数据/enums.csv','scripts/validation/Validate-ResearchData.ps1')) {
    $old = Resolve-Relative $root $rel
    $new = Resolve-Relative $targetFull $rel
    [pscustomobject][ordered]@{target_path=$rel;formal_premerge_sha256=Get-LowerHash $old;candidate_postmerge_sha256=Get-LowerHash $new;formal_premerge_bytes=(Get-Item -LiteralPath $old).Length;candidate_postmerge_bytes=(Get-Item -LiteralPath $new).Length}
}
Write-CsvUtf8NoBom -Rows @($fileHashes) -Headers @('target_path','formal_premerge_sha256','candidate_postmerge_sha256','formal_premerge_bytes','candidate_postmerge_bytes') -Path (Join-Path $outDir 'formal-file-hashes.csv')

$result = [ordered]@{
    target_root=$targetFull
    field_rows=$fieldsAfter.Count
    schema_rows_before=$schemaBefore.Count
    schema_rows_after=$schemaAfter.Count
    requirement_rows=$requirementsBefore.Count
    overlay_rows=$overlay.Count
    manifest_rows=$manifest.Count
    field_manifest_rows=@($manifest | Where-Object target_path -eq '数据/fields.csv').Count
    schema_manifest_rows=@($manifest | Where-Object target_path -eq '数据/schema-columns.csv').Count
    requirement_manifest_rows=@($manifest | Where-Object target_path -eq '数据/field-requirements.csv').Count
    validator_manifest_rows=@($manifest | Where-Object target_path -eq 'scripts/validation/Validate-ResearchData.ps1').Count
}
[System.IO.File]::WriteAllText((Join-Path $outDir 'migration-build-result.json'), (($result | ConvertTo-Json -Depth 6)+[Environment]::NewLine), [System.Text.UTF8Encoding]::new($true))
$result | ConvertTo-Json -Depth 6
