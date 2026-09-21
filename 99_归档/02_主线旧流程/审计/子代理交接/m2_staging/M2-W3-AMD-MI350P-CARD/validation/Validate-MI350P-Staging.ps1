#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$ProjectRoot = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$PackageRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$Stage = Join-Path $PackageRoot 'structured'
$script:Errors = [System.Collections.Generic.List[string]]::new()
$Checks = 0
function Check([bool]$Condition,[string]$Message) {
    $script:Checks++
    if (-not $Condition) { $script:Errors.Add($Message) }
}
function Rows([string]$Name) { $items = @(Import-Csv -LiteralPath (Join-Path $Stage $Name) -Encoding UTF8); Write-Output -NoEnumerate $items }
function IdSet([object[]]$InputRows,[string]$Column) {
    $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $InputRows) { if ($row.$Column) { [void]$set.Add([string]$row.$Column) } }
    $set
}
$mapping = @{}
foreach ($file in Get-ChildItem -LiteralPath $Stage -File) {
    $dataPath = Join-Path $ProjectRoot ('数据\' + $file.Name)
    $refPath = Join-Path $ProjectRoot ('最小参考资料库\' + $file.Name)
    $formal = if (Test-Path -LiteralPath $dataPath) { $dataPath } elseif (Test-Path -LiteralPath $refPath) { $refPath } else { '' }
    Check ([bool]$formal) "No formal counterpart for $($file.Name)"
    if ($formal) {
        $mapping[$file.Name] = $formal
        $stageHeader = Get-Content -LiteralPath $file.FullName -Encoding UTF8 -TotalCount 1
        $formalHeader = Get-Content -LiteralPath $formal -Encoding UTF8 -TotalCount 1
        Check ($stageHeader -ceq $formalHeader) "Header mismatch for $($file.Name)"
    }
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    Check (-not ($bytes -contains 0 -or $bytes -contains 9 -or $bytes -contains 12)) "Control byte found in $($file.Name)"
}
$expectedFiles = @('card-completeness.csv','components.csv','condition-sets.csv','conflict-groups.csv','conflict-members.csv','derived-inputs.csv','derived-metrics.csv','fact-assertions.csv','facts.csv','field-requirements.csv','links.csv','memory-levels.csv','precision-paths.csv','requirement-evidence.csv','search-log.csv','search-results.csv','selection-members.csv','selection-runs.csv','source-coverage.csv','source-endpoints.csv','source-families.csv','sources.csv','source-screening.csv','source-selected-roles.csv','special-capabilities.csv','topologies.csv')
Check (@(Get-ChildItem -LiteralPath $Stage -File).Count -eq $expectedFiles.Count) 'Structured file count is not 26.'
foreach ($name in $expectedFiles) { Check (Test-Path -LiteralPath (Join-Path $Stage $name)) "Missing structured file $name" }

$facts = Rows 'facts.csv'; $assertions = Rows 'fact-assertions.csv'; $requirements = Rows 'field-requirements.csv'
$components = Rows 'components.csv'; $conditions = Rows 'condition-sets.csv'; $links = Rows 'links.csv'; $memory = Rows 'memory-levels.csv'; $paths = Rows 'precision-paths.csv'
$completeness = Rows 'card-completeness.csv'; $searchLogs = Rows 'search-log.csv'; $searchResults = Rows 'search-results.csv'
$sources = Rows 'sources.csv'; $endpoints = Rows 'source-endpoints.csv'; $families = Rows 'source-families.csv'; $selectionRuns = Rows 'selection-runs.csv'; $selectionMembers = Rows 'selection-members.csv'
Check ($facts.Count -eq 40 -and $facts.Count -le 40) 'Fact count must be 40 and within budget.'
Check ($assertions.Count -eq 49 -and $assertions.Count -le 50) 'Assertion count must be 49 and within budget.'
Check ($requirements.Count -eq 46 -and $requirements.Count -le 50) 'Requirement count must be 46 and within budget.'
Check ($components.Count -eq 5 -and $components.Count -le 10) 'Component count mismatch.'
Check ($memory.Count -eq 2 -and $memory.Count -le 5) 'Memory-level count mismatch.'
Check ($links.Count -eq 1 -and $links.Count -le 4) 'Link count mismatch.'
Check ($paths.Count -eq 12 -and $paths.Count -le 12) 'Precision-path count mismatch.'
Check ($conditions.Count -eq 10 -and $conditions.Count -le 18) 'Condition count mismatch.'
Check ($completeness.Count -eq 9) 'Completeness must have exactly 9 rows.'
Check ($sources.Count -eq 3 -and $sources.Count -le 3) 'New source-version count mismatch.'
Check ($endpoints.Count -eq 6 -and $endpoints.Count -le 6) 'New endpoint count mismatch.'
Check ($selectionRuns.Count -eq 1) 'Selection-run count must be 1.'
Check ($selectionMembers.Count -eq 3) 'Selection member count must be 3.'
foreach ($empty in @('derived-inputs.csv','derived-metrics.csv','special-capabilities.csv','topologies.csv','conflict-groups.csv','conflict-members.csv','requirement-evidence.csv')) { Check ((Rows $empty).Count -eq 0) "$empty must remain header-only." }
$roles = Rows 'source-selected-roles.csv'; $coverage = Rows 'source-coverage.csv'; $screening = Rows 'source-screening.csv'
Check ($roles.Count -eq 4) 'Selected-role count must be 4.'
Check ($coverage.Count -eq 3) 'Source-coverage count must be 3.'
Check (@($selectionMembers | Where-Object { $_.source_id -match 'CDNA4' }).Count -eq 0) 'CDNA4 source remains in object selection members.'
Check (@($roles | Where-Object { $_.source_id -match 'CDNA4' }).Count -eq 0) 'CDNA4 source remains in object selected roles.'
Check (@($coverage | Where-Object { $_.covered_source_id -match 'CDNA4' -or $_.covering_source_id -match 'CDNA4' }).Count -eq 0) 'CDNA4 source remains in object source coverage.'
$cdnaScreen = @($screening | Where-Object { $_.source_id -match 'CDNA4' })
Check ($cdnaScreen.Count -eq 2 -and @($cdnaScreen | Where-Object { $_.screening_status -ne 'lead_only' }).Count -eq 0) 'Both CDNA4 screening rows must be lead_only.'
$transistorFact = @($facts | Where-Object { $_.fact_id -eq 'FACT-M2W3-AMD-MI350P-TRANSISTORS' })
Check ($transistorFact.Count -eq 1) 'Transistor fact must exist exactly once.'
if ($transistorFact.Count -eq 1) { Check ($transistorFact[0].object_id -eq 'OBJ-AMD-MI350P' -and $transistorFact[0].field_id -eq 'FIELD-PHY-TRANSISTORS' -and $transistorFact[0].normalized_value_number -eq '73000000000' -and $transistorFact[0].normalized_unit -eq 'count') 'Transistor fact payload mismatch.' }
$transistorAssertion = @($assertions | Where-Object { $_.assertion_id -eq 'ASSERT-M2W3-AMD-MI350P-TRANSISTORS-PRODUCT' })
Check ($transistorAssertion.Count -eq 1) 'Transistor product-page assertion must exist exactly once.'
if ($transistorAssertion.Count -eq 1) { Check ($transistorAssertion[0].source_id -eq 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' -and $transistorAssertion[0].raw_value_text -eq '73 Billion' -and $transistorAssertion[0].quoted_context -eq 'Transistor Count: 73 Billion') 'Transistor assertion payload mismatch.' }
Check (@($requirements | Where-Object { $_.requirement_id -eq 'REQ-M2W3-AMD-MI350P-TRANSISTORS' -and $_.field_id -eq 'FIELD-PHY-TRANSISTORS' -and $_.requirement_status -eq 'value_available' }).Count -eq 1) 'Transistor requirement must exist exactly once.'
Check (@($assertions | Where-Object { $_.assertion_id -like '*VECTOR-PEAK-PRODUCT' }).Count -eq 0) 'Legacy product-page vector assertions must be absent.'
$vectorAssertions = @($assertions | Where-Object { $_.assertion_id -like 'ASSERT-M2W3-AMD-MI350P-*-VECTOR-PEAK-BROCHURE' })
Check ($vectorAssertions.Count -eq 3) 'Exactly three brochure vector assertions are required.'
foreach ($assertion in $vectorAssertions) {
    Check ($assertion.source_id -eq 'SRC-M2W3-AMD-MI350P-BROCHURE-202605') "Vector assertion has wrong source: $($assertion.assertion_id)"
    Check ($assertion.source_locator -eq 'p. 1, HPC Peak Performance (Estimated)') "Vector assertion locator mismatch: $($assertion.assertion_id)"
    Check ($assertion.quoted_context -match '^FP(16|32|64) VECTOR \(TFLOPS\): (72|36)$') "Vector assertion quote mismatch: $($assertion.assertion_id)"
}

$fields = @(Import-Csv -LiteralPath (Join-Path $ProjectRoot '数据\fields.csv') -Encoding UTF8)
$fieldHeader = (Get-Content -LiteralPath (Join-Path $ProjectRoot '数据\fields.csv') -Encoding UTF8 -TotalCount 1).Split(',')
Check ($fieldHeader.Count -eq 13) 'Current fields.csv contract is not 13 columns.'
$fieldById = @{}; foreach ($field in $fields) { $fieldById[$field.field_id] = $field }
function TargetKinds($row) {
    $result = @()
    if ($row.object_id) { $result += 'object' }
    if ($row.component_id) { $result += 'component' }
    if ($row.link_id) { $result += 'link' }
    if ($row.object_relation_id) { $result += 'relation' }
    if ($row.precision_path_id) { $result += 'precision_path' }
    if ($row.capability_id) { $result += 'capability' }
    if ($row.topology_id) { $result += 'topology' }
    @($result)
}
foreach ($fact in $facts) {
    $targets = @(TargetKinds $fact)
    Check ($targets.Count -eq 1) "Fact $($fact.fact_id) does not have exactly one target."
    Check ($fieldById.ContainsKey($fact.field_id)) "Unknown field $($fact.field_id) in $($fact.fact_id)."
    if ($targets.Count -eq 1 -and $fieldById.ContainsKey($fact.field_id)) {
        $allowed = @($fieldById[$fact.field_id].allowed_subject_kinds -split ';')
        Check ($allowed -contains $targets[0]) "Fact subject contract mismatch $($fact.fact_id): $($targets[0]) not in $($allowed -join ';')."
    }
    Check ($fact.fact_kind -eq 'direct_statement') "Non-direct fact staged: $($fact.fact_id)"
    Check ($fact.resolution_state -eq 'provisional' -and $fact.review_status -eq 'draft') "Lifecycle mismatch for $($fact.fact_id)"
    Check ($fact.object_id -in @('','OBJ-AMD-MI350P')) "Foreign object fact staged: $($fact.fact_id)"
    Check ($fact.normalized_value_text -notmatch 'MI350X|MI355X|OAM|8-OAM|eight card|8 card') "Out-of-scope normalized payload in $($fact.fact_id)"
}
foreach ($req in $requirements) {
    $targets = @(TargetKinds $req)
    Check ($targets.Count -eq 1) "Requirement $($req.requirement_id) does not have exactly one target."
    Check ($fieldById.ContainsKey($req.field_id)) "Unknown field $($req.field_id) in $($req.requirement_id)."
    if ($targets.Count -eq 1 -and $fieldById.ContainsKey($req.field_id)) {
        $allowed = @($fieldById[$req.field_id].allowed_requirement_target_kinds -split ';')
        Check ($allowed -contains $targets[0]) "Requirement target contract mismatch $($req.requirement_id): $($targets[0]) not in $($allowed -join ';')."
    }
    Check ($req.review_status -eq 'draft') "Requirement lifecycle mismatch for $($req.requirement_id)"
}

$tableIdColumns = @{
    'card-completeness.csv'='card_completeness_id'; 'components.csv'='component_id'; 'condition-sets.csv'='condition_set_id'; 'facts.csv'='fact_id'; 'field-requirements.csv'='requirement_id'; 'links.csv'='link_id'; 'memory-levels.csv'='memory_level_id'; 'precision-paths.csv'='precision_path_id'; 'fact-assertions.csv'='assertion_id'; 'search-log.csv'='search_id'; 'search-results.csv'='search_result_id'; 'selection-members.csv'='selection_member_id'; 'selection-runs.csv'='selection_run_id'; 'source-coverage.csv'='coverage_id'; 'source-endpoints.csv'='endpoint_id'; 'source-families.csv'='source_family_id'; 'sources.csv'='source_id'; 'source-screening.csv'='screening_id'; 'source-selected-roles.csv'='source_selected_role_id'
}
foreach ($entry in $tableIdColumns.GetEnumerator()) {
    $rows = Rows $entry.Key
    $ids = @($rows | ForEach-Object { $_.($entry.Value) })
    Check (@($ids | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -eq 0) "Blank IDs in $($entry.Key)"
    Check (@($ids | Sort-Object -Unique).Count -eq $ids.Count) "Duplicate staging IDs in $($entry.Key)"
    $formalIds = @((Import-Csv -LiteralPath $mapping[$entry.Key] -Encoding UTF8) | ForEach-Object { $_.($entry.Value) })
    $collisions = @($ids | Where-Object { $formalIds -ccontains $_ })
    Check ($collisions.Count -eq 0) "Formal ID collision in $($entry.Key): $($collisions -join ';')"
}

$allFactIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($factRow in $facts) { [void]$allFactIds.Add([string]$factRow.fact_id) }
$allSourceIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($sourceRow in $sources) { [void]$allSourceIds.Add([string]$sourceRow.source_id) }
foreach ($formalSource in Import-Csv -LiteralPath (Join-Path $ProjectRoot '最小参考资料库\sources.csv') -Encoding UTF8) { [void]$allSourceIds.Add([string]$formalSource.source_id) }
foreach ($assertion in $assertions) {
    Check ($allFactIds.Contains($assertion.fact_id)) "Assertion has unknown fact $($assertion.assertion_id)"
    Check ($allSourceIds.Contains($assertion.source_id)) "Assertion has unknown source $($assertion.assertion_id)"
    Check ($assertion.extraction_status -eq 'source_checked') "Assertion is not source_checked: $($assertion.assertion_id)"
    Check ($assertion.source_id -notmatch 'CDNA4') "Architecture source directly asserts a MI350P fact: $($assertion.assertion_id)"
}
foreach ($fact in $facts) {
    $support = @($assertions | Where-Object { $_.fact_id -eq $fact.fact_id })
    $sourceCount = @($support.source_id | Sort-Object -Unique).Count
    Check ($sourceCount -ge 1) "Fact lacks an assertion: $($fact.fact_id)"
    if ($fact.evidence_state -eq 'corroborated') { Check ($sourceCount -ge 2) "Corroborated fact has fewer than 2 sources: $($fact.fact_id)" }
    if ($fact.evidence_state -eq 'single_source' -or $fact.evidence_state -eq 'source_with_caveat') { Check ($sourceCount -eq 1) "Single/caveat fact has source count ${sourceCount}: $($fact.fact_id)" }
}
$gapReqs = @($requirements | Where-Object { $_.requirement_status -ne 'value_available' })
Check ($gapReqs.Count -eq 12) 'Gap requirement count must be 12.'
foreach ($req in $gapReqs) {
    $logs = @($searchLogs | Where-Object { $_.requirement_id -eq $req.requirement_id })
    Check ($logs.Count -eq 1) "Gap requirement must have exactly one search log: $($req.requirement_id)"
    if ($logs.Count -eq 1) { Check (@($searchResults | Where-Object { $_.search_id -eq $logs[0].search_id }).Count -ge 3) "Search lacks source results: $($logs[0].search_id)" }
}
$domains = @('identity','physical','compute','numerics','memory','interconnect','special_engines','software','evidence')
Check (@($completeness.domain | Sort-Object -Unique).Count -eq 9) 'Completeness domains are not unique.'
foreach ($domain in $domains) { Check ($completeness.domain -contains $domain) "Missing completeness domain $domain" }

foreach ($endpoint in $endpoints | Where-Object { $_.local_path }) {
    $local = Join-Path $ProjectRoot ($endpoint.local_path -replace '/','\')
    Check (Test-Path -LiteralPath $local) "Missing local endpoint $($endpoint.endpoint_id)"
    if (Test-Path -LiteralPath $local) {
        $hash = (Get-FileHash -LiteralPath $local -Algorithm SHA256).Hash.ToLowerInvariant()
        Check ($hash -ceq $endpoint.sha256) "Local endpoint hash mismatch $($endpoint.endpoint_id)"
    }
}
$baseline = @(Import-Csv -LiteralPath (Join-Path $PackageRoot 'validation\formal-32-csv-baseline.csv') -Encoding UTF8)
foreach ($row in $baseline) {
    $formalPath = Join-Path $ProjectRoot ($row.table_path -replace '/','\')
    Check (Test-Path -LiteralPath $formalPath) "Baseline formal file missing $($row.table_path)"
    if (Test-Path -LiteralPath $formalPath) {
        $item = Get-Item -LiteralPath $formalPath
        $hash = (Get-FileHash -LiteralPath $formalPath -Algorithm SHA256).Hash.ToLowerInvariant()
        Check ($item.Length -eq [int64]$row.byte_size) "Formal byte size changed $($row.table_path)"
        Check ($hash -ceq $row.sha256) "Formal hash changed $($row.table_path)"
    }
}
$result = [ordered]@{
    status = if ($Errors.Count -eq 0) { 'passed' } else { 'failed' }
    checks = $Checks
    errors = @($Errors)
    facts = $facts.Count
    assertions = $assertions.Count
    requirements = $requirements.Count
    fact_subject_contract_mismatches = @($Errors | Where-Object { $_ -like 'Fact subject contract mismatch*' }).Count
    requirement_target_contract_mismatches = @($Errors | Where-Object { $_ -like 'Requirement target contract mismatch*' }).Count
    completeness_rows = $completeness.Count
    formal_baseline_files = $baseline.Count
}
$result | ConvertTo-Json -Depth 6
if ($Errors.Count -gt 0) { exit 1 }
