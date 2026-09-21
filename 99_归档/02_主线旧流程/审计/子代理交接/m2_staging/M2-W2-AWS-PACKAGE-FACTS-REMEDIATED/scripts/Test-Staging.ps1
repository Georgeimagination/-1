#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$RootPath = (Resolve-Path -LiteralPath $RootPath).Path
$stage = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS-REMEDIATED'
$structured = Join-Path $stage 'structured'
$audit = Join-Path $stage 'audit'
$errors = [System.Collections.Generic.List[string]]::new()
$checks = 0
function Check([bool]$Condition,[string]$Message) {
    $script:checks++
    if (-not $Condition) { $script:errors.Add($Message) }
}
function Is-Blank($Value) { return [string]::IsNullOrWhiteSpace([string]$Value) }

$schemaPath = Join-Path $RootPath '数据\schema-columns.csv'
$schemaRows = @(Import-Csv -LiteralPath $schemaPath -Encoding UTF8)
$enumRows = @(Import-Csv -LiteralPath (Join-Path $RootPath '数据\enums.csv') -Encoding UTF8)
$enumMap = @{}
foreach ($g in ($enumRows | Group-Object enum_name)) { $enumMap[$g.Name] = @($g.Group.enum_value) }
$pairs = @{}
foreach ($g in ($schemaRows | Group-Object table_path)) { $pairs[(Split-Path $g.Name -Leaf)] = $g.Name.Replace('/','\') }
Check ($pairs.Count -eq 32) "Schema map expected 32 tables, got $($pairs.Count)."
$allowedNonEmpty = @('components.csv','memory-levels.csv','links.csv','precision-paths.csv','condition-sets.csv','facts.csv','field-requirements.csv','card-completeness.csv','source-endpoints.csv','fact-assertions.csv','source-selected-roles.csv','source-coverage.csv','search-log.csv','search-results.csv','conflict-groups.csv','conflict-members.csv','selection-runs.csv','selection-members.csv')
foreach ($name in $pairs.Keys) {
    $candidateCount = @(Import-Csv -LiteralPath (Join-Path $structured $name) -Encoding UTF8).Count
    if ($name -notin $allowedNonEmpty) { Check ($candidateCount -eq 0) "Update-only or unused table must be header-only in structured: $name ($candidateCount rows)." }
}
Check (@(Import-Csv -LiteralPath (Join-Path $structured 'sources.csv') -Encoding UTF8).Count -eq 0) 'Existing source PK updates must not be staged as append rows.'
Check (@(Import-Csv -LiteralPath (Join-Path $structured 'source-screening.csv') -Encoding UTF8).Count -eq 0) 'Existing screening PK updates must not be staged as append rows.'

foreach ($name in ($pairs.Keys | Sort-Object)) {
    $stagePath = Join-Path $structured $name
    $formalPath = Join-Path $RootPath $pairs[$name]
    Check (Test-Path -LiteralPath $stagePath) "Missing staged table: $name"
    Check (Test-Path -LiteralPath $formalPath) "Missing formal table: $($pairs[$name])"
    if ((Test-Path -LiteralPath $stagePath) -and (Test-Path -LiteralPath $formalPath)) {
        $a = Get-Content -LiteralPath $stagePath -Encoding UTF8 -TotalCount 1
        $b = Get-Content -LiteralPath $formalPath -Encoding UTF8 -TotalCount 1
        Check ($a -ceq $b) "Header mismatch: $name"
    }
}

foreach ($g in ($schemaRows | Group-Object table_path)) {
    $name = Split-Path $g.Name -Leaf
    $stagePath = Join-Path $structured $name
    if (-not (Test-Path -LiteralPath $stagePath)) { continue }
    $rows = @(Import-Csv -LiteralPath $stagePath -Encoding UTF8)
    $pkCols = @($g.Group | Where-Object is_primary_key -eq 'true' | Select-Object -ExpandProperty column_name)
    if ($pkCols.Count -eq 1 -and $rows.Count -gt 0) {
        $pk = $pkCols[0]
        Check (@($rows | Where-Object { Is-Blank $_.$pk }).Count -eq 0) "Empty PK in $name.$pk"
        Check (@($rows | Group-Object $pk | Where-Object Count -gt 1).Count -eq 0) "Duplicate PK in $name.$pk"
        $formalIds = @((Import-Csv -LiteralPath (Join-Path $RootPath $pairs[$name]) -Encoding UTF8).$pk)
        foreach ($row in $rows) { Check ($row.$pk -notin $formalIds) "Temporary merge PK collision: $name $($row.$pk)" }
    }
    foreach ($col in $g.Group) {
        foreach ($row in $rows) {
            $value = [string]$row.($col.column_name)
            if ($col.is_nullable -eq 'false') { Check (-not (Is-Blank $value)) "Required value missing: $name.$($col.column_name)" }
            if ($col.semicolon_forbidden -eq 'true') { Check (-not $value.Contains(';')) "Semicolon forbidden: $name.$($col.column_name)" }
            if ((-not (Is-Blank $col.enum_name)) -and (-not (Is-Blank $value))) { Check ($value -in $enumMap[$col.enum_name]) "Invalid enum '$value': $name.$($col.column_name)" }
            if ((-not (Is-Blank $col.foreign_table_path)) -and (-not (Is-Blank $value))) {
                $foreignFormal = Join-Path $RootPath $col.foreign_table_path.Replace('/','\')
                $refs = @((Import-Csv -LiteralPath $foreignFormal -Encoding UTF8).($col.foreign_column_name))
                $foreignStage = Join-Path $structured (Split-Path $col.foreign_table_path -Leaf)
                if (Test-Path -LiteralPath $foreignStage) { $refs += @((Import-Csv -LiteralPath $foreignStage -Encoding UTF8).($col.foreign_column_name)) }
                Check ($value -in $refs) "Broken FK '$value': $name.$($col.column_name)"
            }
        }
    }
}

$facts = @(Import-Csv -LiteralPath (Join-Path $structured 'facts.csv') -Encoding UTF8)
$assertions = @(Import-Csv -LiteralPath (Join-Path $structured 'fact-assertions.csv') -Encoding UTF8)
$requirements = @(Import-Csv -LiteralPath (Join-Path $structured 'field-requirements.csv') -Encoding UTF8)
$targets = @('object_id','component_id','link_id','object_relation_id','precision_path_id','capability_id','topology_id')
Check ($facts.Count -eq 57) "Expected 57 facts, got $($facts.Count)."
Check ($assertions.Count -eq 69) "Expected 69 assertions, got $($assertions.Count)."
Check ($requirements.Count -eq 71) "Expected 71 requirements, got $($requirements.Count)."
foreach ($row in @($facts + $requirements)) {
    $id = if (-not (Is-Blank $row.fact_id)) { $row.fact_id } else { $row.requirement_id }
    $targetCount = @($targets | Where-Object { -not (Is-Blank $row.$_) }).Count
    Check ($targetCount -eq 1) "Seven-target XOR failed: $id ($targetCount targets)."
}
$fieldRows = @(Import-Csv -LiteralPath (Join-Path $RootPath '数据\fields.csv') -Encoding UTF8)
$fieldContractCandidates = @(Import-Csv -LiteralPath (Join-Path $audit 'field-contract-change-candidate.csv') -Encoding UTF8)
Check ($fieldContractCandidates.Count -eq 1) "Expected one field contract candidate, got $($fieldContractCandidates.Count)."
$fieldClock = @($fieldRows | Where-Object field_id -eq 'FIELD-PHY-CLOCK')
$fieldClockCandidate = @($fieldContractCandidates | Where-Object field_id -eq 'FIELD-PHY-CLOCK')
Check ($fieldClock.Count -eq 1) 'Formal FIELD-PHY-CLOCK row missing or duplicated.'
Check ($fieldClockCandidate.Count -eq 1) 'FIELD-PHY-CLOCK contract candidate missing or duplicated.'
if (($fieldClock.Count -eq 1) -and ($fieldClockCandidate.Count -eq 1)) {
    Check ($fieldClockCandidate[0].current_allowed_subject_kinds -ceq $fieldClock[0].allowed_subject_kinds) 'FIELD-PHY-CLOCK candidate current contract differs from formal registry.'
    Check ($fieldClockCandidate[0].proposed_allowed_subject_kinds -ceq 'object;component') 'FIELD-PHY-CLOCK proposal must be the minimal object;component expansion.'
    Check ($fieldClockCandidate[0].decision_status -eq 'pending_independent_review') 'Field contract proposal must remain pending independent review.'
}
$targetKindByColumn = @{
    object_id='object'
    component_id='component'
    link_id='link'
    object_relation_id='object_relation'
    precision_path_id='precision_path'
    capability_id='special_capability'
    topology_id='topology'
}
foreach ($row in @($facts + $requirements)) {
    $id = if (-not (Is-Blank $row.fact_id)) { $row.fact_id } else { $row.requirement_id }
    $targetColumn = @($targets | Where-Object { -not (Is-Blank $row.$_) })
    if ($targetColumn.Count -ne 1) { continue }
    $kind = $targetKindByColumn[$targetColumn[0]]
    $field = @($fieldRows | Where-Object field_id -eq $row.field_id)
    Check ($field.Count -eq 1) "Field contract row missing or duplicated for ${id}: $($row.field_id)."
    if ($field.Count -eq 1) {
        $allowedText = $field[0].allowed_subject_kinds
        if (($row.field_id -eq 'FIELD-PHY-CLOCK') -and ($fieldClockCandidate.Count -eq 1)) {
            $allowedText = $fieldClockCandidate[0].proposed_allowed_subject_kinds
        }
        $allowedKinds = @($allowedText -split ';')
        Check ($kind -in $allowedKinds) "Field subject kind mismatch: $id uses $kind for $($row.field_id), allowed=$allowedText."
    }
}
$formalFacts = @(Import-Csv -LiteralPath (Join-Path $RootPath '数据\facts.csv') -Encoding UTF8)
$formalRequirements = @(Import-Csv -LiteralPath (Join-Path $RootPath '数据\field-requirements.csv') -Encoding UTF8)
if ($fieldClockCandidate.Count -eq 1) {
    foreach ($fid in @($fieldClockCandidate[0].formal_precedent_fact_ids -split '\|')) {
        $precedent = @($formalFacts | Where-Object fact_id -eq $fid)
        Check ($precedent.Count -eq 1) "Trainium2 FIELD-PHY-CLOCK fact precedent missing: $fid."
        if ($precedent.Count -eq 1) {
            Check ((-not (Is-Blank $precedent[0].component_id)) -and $precedent[0].field_id -eq 'FIELD-PHY-CLOCK') "Trainium2 fact precedent is not a component clock: $fid."
            Check ($precedent[0].review_status -eq 'reviewed') "Trainium2 fact precedent is not reviewed: $fid."
        }
    }
    foreach ($rid in @($fieldClockCandidate[0].formal_precedent_requirement_ids -split '\|')) {
        $precedent = @($formalRequirements | Where-Object requirement_id -eq $rid)
        Check ($precedent.Count -eq 1) "Trainium2 FIELD-PHY-CLOCK requirement precedent missing: $rid."
        if ($precedent.Count -eq 1) {
            Check ((-not (Is-Blank $precedent[0].component_id)) -and $precedent[0].field_id -eq 'FIELD-PHY-CLOCK') "Trainium2 requirement precedent is not a component clock: $rid."
            Check ($precedent[0].review_status -eq 'reviewed') "Trainium2 requirement precedent is not reviewed: $rid."
        }
    }
}
foreach ($f in $facts) {
    $valueCount = @($f.normalized_value_text,$f.normalized_value_number | Where-Object { -not (Is-Blank $_) }).Count
    Check ($valueCount -eq 1) "Fact value XOR failed: $($f.fact_id)."
    $fa = @($assertions | Where-Object fact_id -eq $f.fact_id)
    Check ($fa.Count -ge 1) "Fact lacks assertion: $($f.fact_id)."
    $distinctSources = @($fa.source_id | Sort-Object -Unique).Count
    if ($f.evidence_state -eq 'single_source') { Check ($distinctSources -eq 1) "single_source count mismatch: $($f.fact_id)." }
    if ($f.evidence_state -eq 'corroborated') { Check ($distinctSources -ge 2) "corroborated count mismatch: $($f.fact_id)." }
}
foreach ($a in $assertions) {
    $rawCount = @($a.raw_value_text,$a.raw_value_number | Where-Object { -not (Is-Blank $_) }).Count
    Check ($rawCount -eq 1) "Assertion raw value XOR failed: $($a.assertion_id)."
    Check (-not (Is-Blank $a.source_locator)) "Missing stable locator: $($a.assertion_id)."
    Check (-not (Is-Blank $a.quoted_context)) "Missing quoted context: $($a.assertion_id)."
    Check ($a.extraction_status -eq 'source_checked') "Assertion not source_checked: $($a.assertion_id)."
}

# B02/B03 regression: A07 corroborates both NCv4 FP32 paths; A08 generic FP8 remains a separate fact chain.
foreach ($fid in @('FACT-M2W2-AWS-TRN3-NCV4-VECTOR-FP32','FACT-M2W2-AWS-TRN3-NCV4-SCALAR-FP32')) {
    $fact = @($facts | Where-Object fact_id -eq $fid)
    Check ($fact.Count -eq 1) "NCv4 corroborated fact missing: $fid."
    if ($fact.Count -eq 1) { Check ($fact[0].evidence_state -eq 'corroborated') "NCv4 A07/A10 fact is not corroborated: $fid." }
    $factAssertions = @($assertions | Where-Object fact_id -eq $fid)
    Check (@($factAssertions.source_id | Sort-Object -Unique).Count -eq 2) "NCv4 fact must have exactly A07 and A10 sources: $fid."
    Check (@($factAssertions | Where-Object source_id -eq 'SRC-M2-GA-A07').Count -eq 1) "A07 assertion missing for $fid."
    Check (@($factAssertions | Where-Object source_id -eq 'SRC-M2-GA-A10').Count -eq 1) "A10 assertion missing for $fid."
}
$fp8Fact = @($facts | Where-Object fact_id -eq 'FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC')
$fp8Assertion = @($assertions | Where-Object assertion_id -eq 'ASRT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC-A08-1')
$fp8Requirement = @($requirements | Where-Object requirement_id -eq 'REQ-M2W2-AWS-PKG-071')
Check ($fp8Fact.Count -eq 1) 'A08 generic FP8 fact missing.'
Check ($fp8Assertion.Count -eq 1) 'A08 generic FP8 assertion missing.'
Check ($fp8Requirement.Count -eq 1) 'A08 generic FP8 requirement missing.'
if ($fp8Fact.Count -eq 1) {
    Check ($fp8Fact[0].normalized_value_number -eq '2520000000000000') 'A08 generic FP8 normalized value mismatch.'
    Check ($fp8Fact[0].precision_path_id -eq 'PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC') 'A08 generic FP8 target mismatch.'
}
$genericFp8Path = @(Import-Csv -LiteralPath (Join-Path $structured 'precision-paths.csv') -Encoding UTF8 | Where-Object precision_path_id -eq 'PP-M2W2-AWS-TRN3-CHIP-FP8-GENERIC')
$genericFp8Condition = @(Import-Csv -LiteralPath (Join-Path $structured 'condition-sets.csv') -Encoding UTF8 | Where-Object condition_set_id -eq 'COND-M2W2-AWS-TRN3-CHIP-FP8-GENERIC')
Check ($genericFp8Path.Count -eq 1 -and $genericFp8Path[0].operation_class -eq 'other') 'A08 generic FP8 path must not invent a matrix/vector/scalar operation class.'
Check ($genericFp8Condition.Count -eq 1 -and (Is-Blank $genericFp8Condition[0].operation_type) -and $genericFp8Condition[0].performance_basis -eq 'vendor_label_unresolved') 'A08 generic FP8 condition must preserve unspecified operation and peak basis.'
$mxFact = @($facts | Where-Object fact_id -eq 'FACT-M2W2-AWS-TRN3-CHIP-MX-PEAK')
Check ($mxFact.Count -eq 1) 'A06 MXFP8/MXFP4 fact missing.'
if (($fp8Fact.Count -eq 1) -and ($mxFact.Count -eq 1)) {
    Check ($mxFact[0].precision_path_id -ne $fp8Fact[0].precision_path_id) 'A06 MXFP8/MXFP4 and A08 generic FP8 must use distinct precision paths.'
    Check ($mxFact[0].normalized_value_number -eq '2517000000000000') 'A06 MXFP8/MXFP4 display-precision value changed.'
}
foreach ($pair in @(
    @('FACT-M2W2-AWS-INF1-NCV1-VECTOR-OPS-CYCLE','PP-M2W2-AWS-INF1-NCV1-VECTOR-GENERIC-FLOAT'),
    @('FACT-M2W2-AWS-INF1-NCV1-SCALAR-OPS-CYCLE','PP-M2W2-AWS-INF1-NCV1-SCALAR-GENERIC-FLOAT'),
    @('FACT-M2W2-AWS-TRN1-CC-COUNT','CMP-M2W2-AWS-TRN1-CC'),
    @('FACT-M2W2-AWS-INF2-CC-COUNT','CMP-M2W2-AWS-INF2-CC')
)) {
    $row = @($facts | Where-Object fact_id -eq $pair[0])
    Check ($row.Count -eq 1) "Retargeted fact missing: $($pair[0])."
    if ($row.Count -eq 1) {
        Check (($row[0].precision_path_id -eq $pair[1]) -or ($row[0].component_id -eq $pair[1])) "Retargeted fact points to wrong subject: $($pair[0])."
    }
}
$factMap = @(Import-Csv -LiteralPath (Join-Path $audit 'fact-requirement-map.csv') -Encoding UTF8)
Check ($factMap.Count -eq 57) "Expected 57 fact-requirement mappings, got $($factMap.Count)."
Check (@($factMap | Group-Object fact_id | Where-Object Count -ne 1).Count -eq 0) 'Each fact must map to exactly one requirement.'
Check (@($facts.fact_id | Where-Object { $_ -notin $factMap.fact_id }).Count -eq 0) 'Fact-requirement map does not cover all facts.'
$notFound = @($requirements | Where-Object requirement_status -eq 'not_found')
$conflicting = @($requirements | Where-Object requirement_status -eq 'conflicting_unresolved')
Check ($notFound.Count -eq 20) "Expected 20 not_found requirements, got $($notFound.Count)."
Check ($conflicting.Count -eq 5) "Expected 5 conflicting requirements, got $($conflicting.Count)."
$searchLog = @(Import-Csv -LiteralPath (Join-Path $structured 'search-log.csv') -Encoding UTF8)
$searchResults = @(Import-Csv -LiteralPath (Join-Path $structured 'search-results.csv') -Encoding UTF8)
Check ($searchLog.Count -eq 20) "Expected 20 search-log rows, got $($searchLog.Count)."
Check ($searchResults.Count -eq 50) "Expected 50 search-result rows, got $($searchResults.Count)."
foreach ($r in $notFound) { Check (@($searchLog | Where-Object requirement_id -eq $r.requirement_id).Count -eq 1) "not_found requirement lacks one search log: $($r.requirement_id)." }
foreach ($s in $searchLog) { Check (@($searchResults | Where-Object search_id -eq $s.search_id).Count -ge 1) "Search lacks checked sources: $($s.search_id)." }

$trn3Search = @($searchLog | Where-Object search_id -like 'SEARCH-M2W2-AWS-TRN3-*')
$otherSearch = @($searchLog | Where-Object search_id -notlike 'SEARCH-M2W2-AWS-TRN3-*')
Check ($trn3Search.Count -eq 5) "Expected five Trainium3 search rows, got $($trn3Search.Count)."
Check ($otherSearch.Count -eq 15) "Expected fifteen pre-Trainium3 search rows, got $($otherSearch.Count)."
foreach ($s in $otherSearch) {
    Check ($s.source_types_checked -ceq 'developer_documentation') "Search source types overclaim frozen corpus: $($s.search_id)."
    Check ($s.notes -match '固定.*开发文档') "Search note does not state frozen developer-document scope: $($s.search_id)."
}
foreach ($s in $trn3Search) {
    Check ($s.source_types_checked -ceq 'developer_documentation;press_release') "Trainium3 search source types mismatch frozen corpus: $($s.search_id)."
    Check ($s.notes -match '固定.*开发文档.*A08 新闻稿') "Trainium3 search note does not state frozen developer-document/news-release scope: $($s.search_id)."
}
Check (@($searchLog | Where-Object source_types_checked -match 'cloud_service_documentation').Count -eq 0) 'No search-log row may claim unchecked cloud_service_documentation.'
$conflictGroups = @(Import-Csv -LiteralPath (Join-Path $structured 'conflict-groups.csv') -Encoding UTF8)
$conflictMembers = @(Import-Csv -LiteralPath (Join-Path $structured 'conflict-members.csv') -Encoding UTF8)
Check ($conflictGroups.Count -eq 5) "Expected 5 conflict groups, got $($conflictGroups.Count)."
Check ($conflictMembers.Count -eq 10) "Expected 10 conflict members, got $($conflictMembers.Count)."
foreach ($cg in $conflictGroups) {
    $cm = @($conflictMembers | Where-Object conflict_group_id -eq $cg.conflict_group_id)
    Check ($cm.Count -eq 2) "Conflict group must have two members: $($cg.conflict_group_id)."
    Check (@($cm.fact_id | Sort-Object -Unique).Count -eq 2) "Conflict members must be distinct: $($cg.conflict_group_id)."
    Check ($cg.resolution_status -eq 'unreviewed') "Conflict must remain unreviewed: $($cg.conflict_group_id)."
    Check (Is-Blank $cg.preferred_fact_id) "Conflict must not silently choose a preferred fact: $($cg.conflict_group_id)."
    foreach ($cmRow in $cm) { Check ($cmRow.fact_id -in $facts.fact_id) "Conflict member missing fact: $($cmRow.fact_id)." }
}
Check (@($conflictMembers | Where-Object fact_id -eq 'FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GIB').Count -eq 1) 'Trainium3 144 GiB conflict member missing.'
Check (@($conflictMembers | Where-Object fact_id -eq 'FACT-M2W2-AWS-TRN3-HBM-CAPACITY-GB').Count -eq 1) 'Trainium3 144 GB conflict member missing.'

$sourceUpdates = @(Import-Csv -LiteralPath (Join-Path $audit 'source-updates.csv') -Encoding UTF8)
$singleSnapshotIds = @('SRC-M2-GA-A02','SRC-M2-GA-A03','SRC-M2-GA-A04','SRC-M2-GA-A05','SRC-M2-GA-A06','SRC-M2-GA-A08','SRC-M2-GA-A10')
foreach ($sid in $singleSnapshotIds) {
    $row = @($sourceUpdates | Where-Object source_id -eq $sid)
    Check ($row.Count -eq 1) "Single-snapshot source overlay missing: $sid."
    if ($row.Count -eq 1) {
        Check ($row[0].notes -match '单一固定 web_snapshot') "Source overlay does not state a single fixed snapshot: $sid."
        Check ($row[0].notes -notmatch 'latest.*(相同|等价)|版本化.*(相同|等价)') "Source overlay falsely claims endpoint equivalence: $sid."
    }
}
$screeningUpdates = @(Import-Csv -LiteralPath (Join-Path $audit 'source-screening-updates.csv') -Encoding UTF8)
$screenA01 = @($screeningUpdates | Where-Object screening_id -eq 'SCREEN-M2-GA-A01')
Check ($screenA01.Count -eq 1) 'SCREEN-M2-GA-A01 overlay missing.'
if ($screenA01.Count -eq 1) {
    Check ($screenA01[0].screening_status -eq 'selected') 'SCREEN-M2-GA-A01 must become selected for package facts.'
    Check ($screenA01[0].review_status -eq 'reviewed') 'SCREEN-M2-GA-A01 lifecycle must remain reviewed.'
}
$freeze = @(Import-Csv -LiteralPath (Join-Path $stage 'source-gate\source-freeze-register.csv') -Encoding UTF8)
$endpoints = @(Import-Csv -LiteralPath (Join-Path $structured 'source-endpoints.csv') -Encoding UTF8)
$endpointUpdates = @(Import-Csv -LiteralPath (Join-Path $audit 'source-endpoint-updates.csv') -Encoding UTF8)
Check ($freeze.Count -eq 11) "Expected 11 source-gate rows, got $($freeze.Count)."
Check ($endpoints.Count -eq 11) "Expected 11 endpoint candidates, got $($endpoints.Count)."
Check ($endpointUpdates.Count -eq 9) "Expected 9 endpoint overlays, got $($endpointUpdates.Count)."
foreach ($e in $endpoints) {
    Check ($e.endpoint_type -eq 'web_snapshot') "Endpoint is not web_snapshot: $($e.endpoint_id)."
    Check ($e.access_date -eq '2026-08-13') "Endpoint access date mismatch: $($e.endpoint_id)."
    Check ($e.snapshot_date -eq '2026-08-13') "Endpoint snapshot date mismatch: $($e.endpoint_id)."
    Check (-not (Is-Blank $e.local_path)) "Endpoint lacks proposed formal local_path: $($e.endpoint_id)."
    Check ($e.local_path -like '最小参考资料库/快照/AWS/PackageImplementations/2026-08-13/*') "Endpoint local_path is not the proposed formal snapshot path: $($e.endpoint_id)."
    $freezeRow = $freeze | Where-Object endpoint_id -eq $e.endpoint_id | Select-Object -First 1
    Check ($e.local_path -ceq $freezeRow.local_path) "Endpoint local_path differs from source-gate register: $($e.endpoint_id)."
    $local = Join-Path $RootPath $freezeRow.staging_local_path.Replace('/','\')
    Check (Test-Path -LiteralPath $local) "Staging snapshot missing: $($e.endpoint_id)."
    if (Test-Path -LiteralPath $local) {
        $actual = (Get-FileHash -LiteralPath $local -Algorithm SHA256).Hash.ToLowerInvariant()
        Check ($actual -ceq $e.sha256) "Endpoint staging hash mismatch: $($e.endpoint_id)."
    }
}
$formalEndpoints = @(Import-Csv -LiteralPath (Join-Path $RootPath '最小参考资料库\source-endpoints.csv') -Encoding UTF8)
$overlay = @{}
foreach ($e in $formalEndpoints) { $overlay[$e.endpoint_id] = $e }
foreach ($e in $endpointUpdates) { $overlay[$e.endpoint_id] = $e }
foreach ($e in $endpoints) { $overlay[$e.endpoint_id] = $e }
foreach ($sid in @($endpoints.source_id | Sort-Object -Unique)) {
    $group = @($overlay.Values | Where-Object source_id -eq $sid)
    Check (@($group | Where-Object is_preferred_endpoint -eq 'true').Count -eq 1) "Merged endpoint group must have one preferred endpoint: $sid."
    $preferred = @($group | Where-Object is_preferred_endpoint -eq 'true')
    Check ($preferred[0].endpoint_type -eq 'web_snapshot') "Preferred endpoint is not the new fixed snapshot: $sid."
}
foreach ($id in @('END-M2W2-AWS-PKG-A01-LATEST-SNAP-20260813','END-M2W2-AWS-PKG-A07-LATEST-SNAP-20260813')) {
    $row = $endpoints | Where-Object endpoint_id -eq $id | Select-Object -First 1
    Check ($row.is_preferred_endpoint -eq 'false') "Latest endpoint must be audit-only: $id."
}
$equiv = @(Import-Csv -LiteralPath (Join-Path $stage 'source-gate\endpoint-equivalence.csv') -Encoding UTF8)
Check ($equiv.Count -eq 2) "Expected two endpoint equivalence rows, got $($equiv.Count)."
foreach ($eq in $equiv) {
    $pref = $endpoints | Where-Object endpoint_id -eq $eq.preferred_endpoint_id | Select-Object -First 1
    $auditOnly = $endpoints | Where-Object endpoint_id -eq $eq.audit_only_endpoint_id | Select-Object -First 1
    $prefFreeze = $freeze | Where-Object endpoint_id -eq $pref.endpoint_id | Select-Object -First 1
    $auditFreeze = $freeze | Where-Object endpoint_id -eq $auditOnly.endpoint_id | Select-Object -First 1
    $prefText = Get-Content -LiteralPath (Join-Path $RootPath $prefFreeze.staging_local_path.Replace('/','\')) -Raw -Encoding UTF8
    $auditText = Get-Content -LiteralPath (Join-Path $RootPath $auditFreeze.staging_local_path.Replace('/','\')) -Raw -Encoding UTF8
    $pattern = '(?s)<article class="bd-article" role="main">(.*?)</article>'
    $prefMatch = [regex]::Match($prefText,$pattern)
    $auditMatch = [regex]::Match($auditText,$pattern)
    $prefBody = $prefMatch.Groups[1].Value
    $auditBody = $auditMatch.Groups[1].Value
    Check ($prefBody.Length -gt 0) "Could not extract article body: $($eq.preferred_endpoint_id)."
    Check ($prefBody -ceq $auditBody) "Latest/versioned article bodies differ: $($eq.equivalence_group)."
    Check ($prefMatch.Value.Length -eq [int]$eq.body_length) "Recorded article length mismatch: $($eq.equivalence_group)."
    Check ($eq.independent_source_count -eq '1') "Equivalent endpoints must count as one source: $($eq.equivalence_group)."
}

$equivalentSourceIds = @()
foreach ($eq in $equiv) {
    $eqEndpoint = @($endpoints | Where-Object endpoint_id -eq $eq.preferred_endpoint_id)
    if ($eqEndpoint.Count -eq 1) { $equivalentSourceIds += $eqEndpoint[0].source_id }
}
Check (($equivalentSourceIds | Sort-Object -Unique) -join '|' -ceq 'SRC-M2-GA-A01|SRC-M2-GA-A07') 'Only A01 and A07 may have endpoint-equivalence rows.'

$sourcePlainText = @{}
foreach ($sid in @($assertions.source_id | Sort-Object -Unique)) {
    $preferred = @($endpoints | Where-Object { $_.source_id -eq $sid -and $_.is_preferred_endpoint -eq 'true' })
    Check ($preferred.Count -eq 1) "Staged preferred fixed endpoint missing or duplicated for quote audit: $sid."
    if ($preferred.Count -ne 1) { continue }
    $freezeRow = @($freeze | Where-Object endpoint_id -eq $preferred[0].endpoint_id)
    Check ($freezeRow.Count -eq 1) "Freeze row missing for quote audit: $sid."
    if ($freezeRow.Count -ne 1) { continue }
    $htmlPath = Join-Path $RootPath $freezeRow[0].staging_local_path.Replace('/','\')
    $html = [System.IO.File]::ReadAllText($htmlPath,[System.Text.Encoding]::UTF8)
    $html = [regex]::Replace($html,'(?is)<script\b.*?</script>|<style\b.*?</style>',' ')
    $plain = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($html,'(?s)<[^>]+>',' '))
    $plain = [regex]::Replace($plain,'\s+',' ').Trim()
    $sourcePlainText[$sid] = $plain
}
foreach ($a in $assertions) {
    $quote = [System.Net.WebUtility]::HtmlDecode([string]$a.quoted_context)
    $quote = [regex]::Replace($quote,'\s+',' ').Trim()
    Check ($sourcePlainText.ContainsKey($a.source_id)) "No normalized fixed source text for assertion: $($a.assertion_id)."
    if ($sourcePlainText.ContainsKey($a.source_id)) {
        Check ($sourcePlainText[$a.source_id].Contains($quote)) "quoted_context is not verbatim fixed-source text: $($a.assertion_id)."
    }
}
$backlog = @(Import-Csv -LiteralPath (Join-Path $audit 'backlog-disposition.csv') -Encoding UTF8)
Check ($backlog.Count -eq 24) "Expected 24 backlog disposition rows, got $($backlog.Count)."
Check (@($backlog | Group-Object deferred_id | Where-Object Count -gt 1).Count -eq 0) 'Backlog deferred_id duplicates found.'
Check (@($backlog | Where-Object disposition -eq 'split_into_candidate_facts').Count -eq 23) 'Expected 23 implementation backlog rows.'
Check (@($backlog | Where-Object deferred_id -eq 'DEF-M2GA-ATRN2-01' | Where-Object disposition -eq 'reused_formal_chain').Count -eq 1) 'Trainium2 formal-chain reuse row missing.'
foreach ($row in @($backlog | Where-Object disposition -eq 'split_into_candidate_facts')) {
    $listed = @($row.candidate_fact_ids -split '\|' | Where-Object { -not (Is-Blank $_) })
    Check ([int]$row.candidate_fact_count -eq $listed.Count) "Backlog candidate_fact_count/list mismatch: $($row.deferred_id)."
}
$trn3ComputeBacklog = @($backlog | Where-Object deferred_id -eq 'DEF-M2GA-ATRN3-02')
Check ($trn3ComputeBacklog.Count -eq 1) 'Trainium3 compute backlog disposition missing.'
if ($trn3ComputeBacklog.Count -eq 1) {
    Check ($trn3ComputeBacklog[0].candidate_fact_count -eq '5') 'Trainium3 compute backlog must map to five facts.'
    Check ($trn3ComputeBacklog[0].candidate_fact_ids -match 'FACT-M2W2-AWS-TRN3-CHIP-FP8-GENERIC') 'Trainium3 compute backlog omits A08 generic FP8.'
}
$backlogFactIds = @($backlog.candidate_fact_ids -join '|' -split '\|' | Where-Object { -not (Is-Blank $_) })
Check ($backlogFactIds.Count -eq 57) "Backlog should enumerate 57 fact IDs, got $($backlogFactIds.Count)."
Check (@($backlogFactIds | Sort-Object -Unique).Count -eq 57) 'Backlog fact IDs are not unique.'
Check (@($facts.fact_id | Where-Object { $_ -notin $backlogFactIds }).Count -eq 0) 'Backlog does not cover all staged facts.'

$completeness = @(Import-Csv -LiteralPath (Join-Path $structured 'card-completeness.csv') -Encoding UTF8)
$expectedDomains = @('identity','physical','compute','numerics','memory','interconnect','special_engines','software','evidence')
$objectIds = @('OBJ-AWS-INFERENTIA1-CHIP','OBJ-AWS-TRAINIUM1-CHIP','OBJ-AWS-INFERENTIA2-CHIP','OBJ-AWS-TRAINIUM3-CHIP')
Check ($completeness.Count -eq 36) "Expected 36 completeness rows, got $($completeness.Count)."
foreach ($oid in $objectIds) {
    $rows = @($completeness | Where-Object object_id -eq $oid)
    Check ($rows.Count -eq 9) "Object must have nine completeness rows: $oid."
    Check (@($expectedDomains | Where-Object { $_ -notin $rows.domain }).Count -eq 0) "Object lacks completeness domain: $oid."
}

$coverage = @(Import-Csv -LiteralPath (Join-Path $audit 'card-fact-coverage.csv') -Encoding UTF8)
Check ($coverage.Count -eq 57) "Expected 57 card coverage rows, got $($coverage.Count)."
Check (@($coverage | Group-Object fact_id | Where-Object Count -ne 1).Count -eq 0) 'Card coverage must map each fact once.'
foreach ($row in $coverage) {
    $cardPath = Join-Path $stage $row.card_path.Replace('/','\')
    Check (Test-Path -LiteralPath $cardPath) "Card file missing: $($row.card_path)."
    if (Test-Path -LiteralPath $cardPath) {
        $text = Get-Content -LiteralPath $cardPath -Raw -Encoding UTF8
        Check ($text.Contains($row.fact_id)) "Card lacks mapped fact: $($row.fact_id)."
    }
}
foreach ($a in $assertions) {
    $factCard = @($coverage | Where-Object fact_id -eq $a.fact_id)
    Check ($factCard.Count -eq 1) "Assertion fact must map to one card: $($a.assertion_id)."
    if ($factCard.Count -eq 1) {
        $cardPath = Join-Path $stage $factCard[0].card_path.Replace('/','\')
        $cardText = Get-Content -LiteralPath $cardPath -Raw -Encoding UTF8
        Check ($cardText.Contains($a.quoted_context)) "Card does not repeat the exact assertion quoted_context: $($a.assertion_id)."
    }
}
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $stage 'card-draft') -Filter '*.md') {
    $text = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $ids = @([regex]::Matches($text,'FACT-M2W2-AWS-[A-Z0-9-]+') | ForEach-Object Value | Sort-Object -Unique)
    $mapped = @($coverage | Where-Object { (Join-Path $stage $_.card_path.Replace('/','\')) -eq $file.FullName } | Select-Object -ExpandProperty fact_id)
    Check (@($ids | Where-Object { $_ -notin $mapped }).Count -eq 0) "Card contains foreign fact IDs: $($file.Name)."
    Check (@($mapped | Where-Object { $_ -notin $ids }).Count -eq 0) "Card misses mapped fact IDs: $($file.Name)."
}

$selectionRuns = @(Import-Csv -LiteralPath (Join-Path $structured 'selection-runs.csv') -Encoding UTF8)
$selectionMembers = @(Import-Csv -LiteralPath (Join-Path $structured 'selection-members.csv') -Encoding UTF8)
$reverse = @(Import-Csv -LiteralPath (Join-Path $audit 'reverse-removal.csv') -Encoding UTF8)
foreach ($rr in $reverse) {
    $supportedFacts = @($assertions | Where-Object source_id -eq $rr.source_id | Select-Object -ExpandProperty fact_id -Unique)
    $uniqueFacts = @($supportedFacts | Where-Object {
        $candidateFactId = $_
        @($assertions | Where-Object fact_id -eq $candidateFactId | Select-Object -ExpandProperty source_id -Unique).Count -eq 1
    })
    Check ([int]$rr.supported_fact_count -eq $supportedFacts.Count) "Reverse-removal supported_fact_count does not recompute: $($rr.source_id)."
    Check ([int]$rr.unique_fact_count -eq $uniqueFacts.Count) "Reverse-removal unique_fact_count does not recompute: $($rr.source_id)."
    $declaredLost = @($rr.lost_fact_ids -split '\|' | Where-Object { -not (Is-Blank $_) })
    Check (@($declaredLost | Where-Object { $_ -notin $uniqueFacts }).Count -eq 0) "Reverse-removal lost_fact_ids includes a non-unique fact: $($rr.source_id)."
    Check (@($uniqueFacts | Where-Object { $_ -notin $declaredLost }).Count -eq 0) "Reverse-removal lost_fact_ids omits a recomputed unique fact: $($rr.source_id)."
}
Check ($selectionRuns.Count -eq 1) 'Expected one package selection run.'
Check ($selectionRuns[0].status -eq 'draft') 'Selection run must await independent review.'
Check ($selectionMembers.Count -eq 8) "Expected eight selected sources, got $($selectionMembers.Count)."
Check (@($selectionMembers | Where-Object { [int]([regex]::Match($_.mandatory_reason,'使 (\d+) 条').Groups[1].Value) -lt 1 }).Count -eq 0) 'Every selected source must have at least one unique fact.'
foreach ($member in $selectionMembers) {
    $reverseRow = $reverse | Where-Object source_id -eq $member.source_id | Select-Object -First 1
    $declared = [int]([regex]::Match($member.mandatory_reason,'使 (\d+) 条').Groups[1].Value)
    $listed = @([regex]::Matches($member.mandatory_reason,'FACT-M2W2-AWS-[A-Z0-9-]+') | ForEach-Object Value)
    Check ($declared -eq $listed.Count) "selection-member count/list mismatch: $($member.source_id)."
    Check ($declared -eq [int]$reverseRow.unique_fact_count) "selection-member/reverse audit count mismatch: $($member.source_id)."
    Check (($listed -join '|') -ceq $reverseRow.lost_fact_ids) "selection-member/reverse audit fact list mismatch: $($member.source_id)."
}
Check ($reverse.Count -eq 10) "Expected ten reverse-removal rows including A09 out of scope, got $($reverse.Count)."
Check (@($reverse | Where-Object decision -eq 'retain').Count -eq 8) 'Reverse removal must retain eight source IDs.'
Check (@($reverse | Where-Object source_id -eq 'SRC-M2-GA-A09' | Where-Object decision -eq 'excluded').Count -eq 1) 'A09 package-scope exclusion missing.'

Check ($selectionRuns[0].notes -match '57 条' -and $selectionRuns[0].notes -match '八个 source_id') 'Selection run notes do not describe the 57-fact, eight-source rerun.'
Check (@($selectionMembers | Where-Object source_id -eq 'SRC-M2-GA-A10').Count -eq 0) 'A10 must not remain a package selection member.'
$selectedRoles = @(Import-Csv -LiteralPath (Join-Path $structured 'source-selected-roles.csv') -Encoding UTF8)
Check (@($selectedRoles | Where-Object source_selected_role_id -eq 'SROLE-M2W2-AWS-PKG-A10-CORE').Count -eq 0) 'A10 package core selected role must be removed.'
$sourceCoverage = @(Import-Csv -LiteralPath (Join-Path $structured 'source-coverage.csv') -Encoding UTF8)
$a10Coverage = @($sourceCoverage | Where-Object { $_.covered_source_id -eq 'SRC-M2-GA-A10' -and $_.covering_source_id -eq 'SRC-M2-GA-A07' })
Check ($a10Coverage.Count -eq 1) 'A10-by-A07 selected-fact-set coverage row missing.'
if ($a10Coverage.Count -eq 1) {
    Check ($a10Coverage[0].coverage_scope -eq 'selected_fact_set' -and $a10Coverage[0].equivalence_status -eq 'fully_covered') 'A10-by-A07 coverage semantics mismatch.'
}
$a07Reverse = @($reverse | Where-Object source_id -eq 'SRC-M2-GA-A07')
$a08Reverse = @($reverse | Where-Object source_id -eq 'SRC-M2-GA-A08')
$a09Reverse = @($reverse | Where-Object source_id -eq 'SRC-M2-GA-A09')
$a10Reverse = @($reverse | Where-Object source_id -eq 'SRC-M2-GA-A10')
Check ($a07Reverse.Count -eq 1 -and $a07Reverse[0].supported_fact_count -eq '15' -and $a07Reverse[0].unique_fact_count -eq '8') 'A07 reverse-removal counts mismatch.'
Check ($a08Reverse.Count -eq 1 -and $a08Reverse[0].supported_fact_count -eq '5' -and $a08Reverse[0].unique_fact_count -eq '4') 'A08 reverse-removal counts mismatch.'
Check ($a10Reverse.Count -eq 1 -and $a10Reverse[0].reverse_removal_result -eq 'no_fact_loss' -and $a10Reverse[0].unique_fact_count -eq '0' -and $a10Reverse[0].decision -eq 'excluded') 'A10 reverse-removal result must be no fact loss and excluded from the package minimum set.'
Check ($a09Reverse.Count -eq 1 -and $a09Reverse[0].rationale -match 'Trainium4' -and $a09Reverse[0].rationale -match '6×、4×、2×' -and $a09Reverse[0].rationale -match '既有架构 selection run 不删除') 'A09 reverse-removal rationale does not preserve the Trainium4 scope reason.'
$lifecyclePath = Join-Path $audit 'lifecycle-manifest-candidate.csv'
$lifecycleHashPath = Join-Path $audit 'lifecycle-manifest-candidate.sha256'
Check (Test-Path -LiteralPath $lifecyclePath) 'DEC-025 lifecycle manifest candidate is missing.'
Check (Test-Path -LiteralPath $lifecycleHashPath) 'DEC-025 lifecycle manifest SHA-256 file is missing.'
$lifecycle = @(Import-Csv -LiteralPath $lifecyclePath -Encoding UTF8)
Check ($lifecycle.Count -eq 457) "Expected 457 actual-write lifecycle rows, got $($lifecycle.Count)."
Check (@($lifecycle | Group-Object table_path,pk_value | Where-Object Count -gt 1).Count -eq 0) 'Lifecycle manifest contains duplicate table/PK pairs.'
Check (@($lifecycle | Where-Object review_promotion_included -eq 'true').Count -eq 407) 'Lifecycle manifest must propose exactly 407 review promotions.'
Check (@($lifecycle | Where-Object review_promotion_included -eq 'false').Count -eq 50) 'Lifecycle manifest must retain exactly 50 non-promotions.'
Check (@($lifecycle | Where-Object { $_.old_review_status -eq 'needs_resolution' -and $_.new_review_status -eq 'needs_resolution' }).Count -eq 49) 'Lifecycle manifest must exclude all 49 unresolved rows from reviewed promotion.'
$screenLifecycle = @($lifecycle | Where-Object { $_.table_path -eq '最小参考资料库/source-screening.csv' -and $_.pk_value -eq 'SCREEN-M2-GA-A01' })
Check ($screenLifecycle.Count -eq 1) 'SCREEN-M2-GA-A01 lifecycle row missing.'
if ($screenLifecycle.Count -eq 1) {
    Check ($screenLifecycle[0].write_action -eq 'update_existing_preserve_review_status') 'SCREEN-M2-GA-A01 lifecycle action mismatch.'
    Check ($screenLifecycle[0].old_review_status -eq 'reviewed' -and $screenLifecycle[0].new_review_status -eq 'reviewed') 'SCREEN-M2-GA-A01 lifecycle old/new status must both be reviewed.'
}
$expectedLifecycleKeys = [System.Collections.Generic.List[string]]::new()
foreach ($g in ($schemaRows | Group-Object table_path)) {
    $name = Split-Path $g.Name -Leaf
    $rows = @(Import-Csv -LiteralPath (Join-Path $structured $name) -Encoding UTF8)
    if ($rows.Count -eq 0) { continue }
    $pkColumns = @($g.Group | Where-Object is_primary_key -eq 'true' | Select-Object -ExpandProperty column_name)
    if ($pkColumns.Count -ne 1) { continue }
    foreach ($row in $rows) { $expectedLifecycleKeys.Add("$($g.Name)|$($row.($pkColumns[0]))") }
}
foreach ($overlaySpec in @(
    @('最小参考资料库/sources.csv','source-updates.csv'),
    @('最小参考资料库/source-endpoints.csv','source-endpoint-updates.csv'),
    @('最小参考资料库/source-screening.csv','source-screening-updates.csv')
)) {
    $group = @($schemaRows | Where-Object table_path -eq $overlaySpec[0])
    $pk = @($group | Where-Object is_primary_key -eq 'true' | Select-Object -ExpandProperty column_name)
    foreach ($row in @(Import-Csv -LiteralPath (Join-Path $audit $overlaySpec[1]) -Encoding UTF8)) {
        $expectedLifecycleKeys.Add("$($overlaySpec[0])|$($row.($pk[0]))")
    }
}
$actualLifecycleKeys = @($lifecycle | ForEach-Object { "$($_.table_path)|$($_.pk_value)" })
Check ($expectedLifecycleKeys.Count -eq 457) "Actual-write reconstruction expected 457 rows, got $($expectedLifecycleKeys.Count)."
Check (@($expectedLifecycleKeys | Where-Object { $_ -notin $actualLifecycleKeys }).Count -eq 0) 'Lifecycle manifest misses actual staged or overlay writes.'
Check (@($actualLifecycleKeys | Where-Object { $_ -notin $expectedLifecycleKeys }).Count -eq 0) 'Lifecycle manifest contains a row outside actual staged or overlay writes.'
if ((Test-Path -LiteralPath $lifecyclePath) -and (Test-Path -LiteralPath $lifecycleHashPath)) {
    $actualLifecycleHash = (Get-FileHash -LiteralPath $lifecyclePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $recordedLifecycleHash = (Get-Content -LiteralPath $lifecycleHashPath -Raw -Encoding UTF8).Trim()
    Check ($actualLifecycleHash -ceq $recordedLifecycleHash) 'Lifecycle manifest SHA-256 does not match the candidate file.'
}
$budgets = [ordered]@{'components.csv'=30;'precision-paths.csv'=22;'memory-levels.csv'=6;'links.csv'=3;'condition-sets.csv'=30;'facts.csv'=60;'fact-assertions.csv'=70;'field-requirements.csv'=75}
foreach ($name in $budgets.Keys) {
    $count = @(Import-Csv -LiteralPath (Join-Path $structured $name) -Encoding UTF8).Count
    Check ($count -le $budgets[$name]) "Budget exceeded: $name $count/$($budgets[$name])."
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    Write-Output "Staging validation failed: $($errors.Count) errors after $checks checks."
    exit 1
}
Write-Output "M2-W2-AWS-PACKAGE-FACTS staging validation passed: $checks checks; 32 headers, schema/enums/FKs, 57 facts, 69 assertions, 71 requirements, 5 conflicts, source gate, backlog, nine-domain completeness, cards and minimum-set audit all passed."
