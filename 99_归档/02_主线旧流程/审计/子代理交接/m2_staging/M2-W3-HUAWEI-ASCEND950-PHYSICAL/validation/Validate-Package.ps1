param(
  [string]$Root = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$pkg = Join-Path $Root '审计\子代理交接\m2_staging\M2-W3-HUAWEI-ASCEND950-PHYSICAL'
$structured = Join-Path $pkg 'structured'
$failures = [Collections.Generic.List[string]]::new()
$checks = 0
function Assert-True([bool]$condition,[string]$message) {
  $script:checks++
  if (-not $condition) { $script:failures.Add($message) }
}
function Rows([string]$name) { return @(Import-Csv -LiteralPath (Join-Path $structured $name)) }
function NonEmptySubject([object]$row) {
  $map = [ordered]@{object='object_id';component='component_id';link='link_id';object_relation='object_relation_id';precision_path='precision_path_id';capability='capability_id';topology='topology_id'}
  $out = @()
  foreach ($kind in $map.Keys) { $col=$map[$kind]; if (-not [string]::IsNullOrWhiteSpace([string]$row.$col)) { $out += $kind } }
  return @($out)
}
$expectedNames = @(
  'card-completeness.csv','components.csv','condition-sets.csv','derived-inputs.csv','derived-metrics.csv',
  'fact-assertions.csv','facts.csv','field-requirements.csv','links.csv','memory-levels.csv','precision-paths.csv',
  'requirement-evidence.csv','search-log.csv','search-results.csv','selection-members.csv','selection-runs.csv',
  'source-coverage.csv','source-endpoints.csv','source-families.csv','source-screening.csv','source-selected-roles.csv',
  'sources.csv','special-capabilities.csv','topologies.csv'
)
$actualNames = @(Get-ChildItem -LiteralPath $structured -File | Sort-Object Name | ForEach-Object {$_.Name})
Assert-True (($actualNames -join '|') -eq (($expectedNames | Sort-Object) -join '|')) 'Structured file set is not exactly the expected 24 files.'
$schema = @(Import-Csv -LiteralPath (Join-Path $Root '数据\schema-columns.csv'))
foreach ($name in $expectedNames) {
  $formalRelative = if (Test-Path -LiteralPath (Join-Path $Root "数据\$name")) { "数据/$name" } else { "最小参考资料库/$name" }
  $formalPath = Join-Path $Root ($formalRelative -replace '/','\')
  Assert-True (Test-Path -LiteralPath $formalPath) "No formal table for $name."
  $expectedHeader = @($schema | Where-Object {$_.table_path -eq $formalRelative} | Sort-Object {[int]$_.ordinal} | ForEach-Object {$_.column_name})
  $actualHeader = @(((Get-Content -LiteralPath (Join-Path $structured $name) -TotalCount 1 -Encoding UTF8).Trim([char]0xFEFF).Trim('"') -split '","'))
  Assert-True (($actualHeader -join '|') -eq ($expectedHeader -join '|')) "Header mismatch for $name."
}
$facts = @(Rows 'facts.csv'); $assertions = @(Rows 'fact-assertions.csv'); $requirements = @(Rows 'field-requirements.csv')
$components = @(Rows 'components.csv'); $links = @(Rows 'links.csv'); $precisions = @(Rows 'precision-paths.csv'); $conditions = @(Rows 'condition-sets.csv')
$completeness = @(Rows 'card-completeness.csv'); $sources = @(Rows 'sources.csv'); $families = @(Rows 'source-families.csv'); $endpoints = @(Rows 'source-endpoints.csv')
$screening = @(Rows 'source-screening.csv'); $roles = @(Rows 'source-selected-roles.csv'); $coverage = @(Rows 'source-coverage.csv')
$runs = @(Rows 'selection-runs.csv'); $members = @(Rows 'selection-members.csv'); $logs = @(Rows 'search-log.csv'); $results = @(Rows 'search-results.csv')
$requirementEvidence = @(Rows 'requirement-evidence.csv')
$expectedInferredAssertionIds = @(
  'ASSERT-M2W3-HUAWEI-DIE-FP8-H2',
  'ASSERT-M2W3-HUAWEI-DIE-MXFP8-H2',
  'ASSERT-M2W3-HUAWEI-DIE-HIF8-H2',
  'ASSERT-M2W3-HUAWEI-DIE-MXFP4-H2',
  'ASSERT-M2W3-HUAWEI-DIE-VECTOR-H2',
  'ASSERT-M2W3-HUAWEI-DIE-GRAN-H2',
  'ASSERT-M2W3-HUAWEI-DIE-LINK-H2',
  'ASSERT-M2W3-HUAWEI-PR-STATUS-H12'
)
$expectedH2InferredAssertionIds = @($expectedInferredAssertionIds | Where-Object {$_ -ne 'ASSERT-M2W3-HUAWEI-PR-STATUS-H12'})
$actualInferredAssertionIds = @($assertions | Where-Object {$_.assertion_mode -eq 'inferred'} | ForEach-Object {$_.assertion_id} | Sort-Object)
Assert-True (($actualInferredAssertionIds -join '|') -eq (($expectedInferredAssertionIds | Sort-Object) -join '|')) 'The inferred assertion set must be exactly the seven H-2 shared-die normalizations plus PR status H12.'
Assert-True (@($assertions | Where-Object {$_.assertion_mode -eq 'direct_statement'}).Count -eq 42) 'Exactly 42 assertions must remain direct_statement.'
Assert-True (@($assertions | Where-Object {$_.assertion_mode -notin @('direct_statement','inferred')}).Count -eq 0) 'No assertion mode other than direct_statement or inferred is allowed.'
$h2InferenceRows = @($assertions | Where-Object {$_.assertion_id -in $expectedH2InferredAssertionIds})
Assert-True ($h2InferenceRows.Count -eq 7 -and @($h2InferenceRows | Where-Object {$_.source_id -ne 'SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918' -or $_.assertion_relation -ne 'qualifies'}).Count -eq 0) 'Seven H-2 inferred assertions must keep the H-2 source and qualifies relation.'
$statusH12 = @($assertions | Where-Object {$_.assertion_id -eq 'ASSERT-M2W3-HUAWEI-PR-STATUS-H12'})
Assert-True ($statusH12.Count -eq 1 -and $statusH12[0].assertion_mode -eq 'inferred' -and $statusH12[0].assertion_relation -eq 'supports') 'PR status H12 must be inferred and keep supports relation.'
$deploymentH12 = @($assertions | Where-Object {$_.assertion_id -eq 'ASSERT-M2W3-HUAWEI-PR-DEPLOY-H12'})
Assert-True ($deploymentH12.Count -eq 1 -and $deploymentH12[0].assertion_mode -eq 'direct_statement') 'PR deployment H12 must remain direct_statement.'
$h2InferenceFactIds = @($h2InferenceRows.fact_id | Sort-Object -Unique)
Assert-True ($h2InferenceFactIds.Count -eq 7 -and @($facts | Where-Object {$_.fact_id -in $h2InferenceFactIds -and ($_.fact_kind -ne 'direct_statement' -or $_.evidence_state -ne 'source_with_caveat')}).Count -eq 0) 'Seven shared-die facts must keep direct fact kind and source_with_caveat evidence.'
$badH2SourceCounts = @($h2InferenceFactIds | Where-Object { $factId = $_; @($assertions | Where-Object {$_.fact_id -eq $factId} | ForEach-Object {$_.source_id} | Sort-Object -Unique).Count -ne 1 })
Assert-True ($badH2SourceCounts.Count -eq 0) 'Each inferred H-2 shared-die fact must still have exactly one distinct source.'
$prStatusFact = @($facts | Where-Object {$_.fact_id -eq 'FACT-M2W3-HUAWEI-ASC950PR-STATUS'})
$prStatusSourceCount = @($assertions | Where-Object {$_.fact_id -eq 'FACT-M2W3-HUAWEI-ASC950PR-STATUS'} | ForEach-Object {$_.source_id} | Sort-Object -Unique).Count
Assert-True ($prStatusFact.Count -eq 1 -and $prStatusFact[0].fact_kind -eq 'direct_statement' -and $prStatusFact[0].evidence_state -eq 'source_with_caveat' -and $prStatusSourceCount -eq 2) 'PR status fact must keep direct fact kind, source_with_caveat evidence and two distinct sources.'
Assert-True ($facts.Count -eq 41) 'Expected exactly 41 facts.'
Assert-True ($assertions.Count -eq 50) 'Expected exactly 50 assertions.'
Assert-True ($requirements.Count -eq 106) 'Expected exactly 106 requirements.'
Assert-True (@($requirements | Where-Object {$_.requirement_status -eq 'value_available'}).Count -eq 41) 'Expected 41 value_available requirements.'
Assert-True (@($requirements | Where-Object {$_.requirement_status -eq 'not_found'}).Count -eq 53) 'Expected 53 not_found requirements.'
Assert-True (@($requirements | Where-Object {$_.requirement_status -eq 'not_applicable'}).Count -eq 11) 'Expected 11 not_applicable requirements.'
Assert-True (@($requirements | Where-Object {$_.requirement_status -eq 'pending_verification'}).Count -eq 1) 'Expected one pending_verification requirement.'
Assert-True ($facts.Count -le 70) 'Fact budget exceeded.'
Assert-True ($requirements.Count -le 120) 'Requirement budget exceeded.'
Assert-True ($completeness.Count -eq 27) 'Expected 27 completeness rows.'
Assert-True ((Rows 'special-capabilities.csv').Count -eq 0) 'No special-capability placeholder rows are allowed.'
Assert-True ((Rows 'topologies.csv').Count -eq 0) 'No topology placeholder rows are allowed.'
Assert-True ((Rows 'derived-inputs.csv').Count -eq 0) 'No derived inputs are expected.'
Assert-True ((Rows 'derived-metrics.csv').Count -eq 0) 'No derived metrics are expected.'
$fields = @{}
Import-Csv -LiteralPath (Join-Path $Root '数据\fields.csv') | ForEach-Object {$fields[$_.field_id]=$_}
foreach ($fact in $facts) {
  $kinds = @(NonEmptySubject $fact)
  Assert-True ($kinds.Count -eq 1) "Fact $($fact.fact_id) must have exactly one subject."
  Assert-True ($fields.ContainsKey($fact.field_id)) "Fact $($fact.fact_id) has unknown field $($fact.field_id)."
  if ($kinds.Count -eq 1 -and $fields.ContainsKey($fact.field_id)) {
    $allowed = @([string]$fields[$fact.field_id].allowed_subject_kinds -split ';')
    Assert-True ($kinds[0] -in $allowed) "Fact subject contract mismatch: $($fact.fact_id)."
  }
}
foreach ($reqRow in $requirements) {
  $kinds = @(NonEmptySubject $reqRow)
  Assert-True ($kinds.Count -eq 1) "Requirement $($reqRow.requirement_id) must have exactly one target."
  Assert-True ($fields.ContainsKey($reqRow.field_id)) "Requirement $($reqRow.requirement_id) has unknown field $($reqRow.field_id)."
  if ($kinds.Count -eq 1 -and $fields.ContainsKey($reqRow.field_id)) {
    $allowed = @([string]$fields[$reqRow.field_id].allowed_requirement_target_kinds -split ';')
    Assert-True ($kinds[0] -in $allowed) "Requirement target contract mismatch: $($reqRow.requirement_id)."
  }
}
$factIds = @($facts.fact_id)
$sourceIds = @($sources.source_id)
foreach ($a in $assertions) {
  Assert-True ($a.fact_id -in $factIds) "Assertion $($a.assertion_id) references a non-package fact."
  Assert-True ($a.source_id -in $sourceIds) "Assertion $($a.assertion_id) references a non-package source."
  Assert-True ($a.extraction_status -eq 'source_checked') "Assertion $($a.assertion_id) is not source_checked."
}
foreach ($fact in $facts) {
  $factAssertions = @($assertions | Where-Object {$_.fact_id -eq $fact.fact_id})
  $distinctSources = @($factAssertions.source_id | Sort-Object -Unique)
  Assert-True ($distinctSources.Count -ge 1) "Fact $($fact.fact_id) has no source assertion."
  if ($fact.evidence_state -eq 'single_source') { Assert-True ($distinctSources.Count -eq 1) "single_source count mismatch for $($fact.fact_id)." }
  elseif ($fact.evidence_state -eq 'corroborated') { Assert-True ($distinctSources.Count -ge 2) "corroborated count mismatch for $($fact.fact_id)." }
  elseif ($fact.evidence_state -eq 'source_with_caveat') { Assert-True ($distinctSources.Count -ge 1) "source_with_caveat has no source for $($fact.fact_id)." }
  else { Assert-True $false "Unexpected evidence_state $($fact.evidence_state) for $($fact.fact_id)." }
  $reqId = $fact.fact_id -replace '^FACT-','REQ-'
  $matching = @($requirements | Where-Object {$_.requirement_id -eq $reqId -and $_.requirement_status -eq 'value_available'})
  Assert-True ($matching.Count -eq 1) "Fact $($fact.fact_id) does not have one matching value_available requirement."
}
$notFound = @($requirements | Where-Object {$_.requirement_status -eq 'not_found'})
Assert-True ($logs.Count -eq $notFound.Count) 'Search-log count must equal not_found requirement count.'
Assert-True (@($logs.query_or_path | Sort-Object -Unique).Count -eq $logs.Count) 'Each not_found requirement must have a distinct requirement-specific query description.'
$expectedSearchSources = @(
 'SRC-M2W3-HUAWEI-H2-ASC950-KEYNOTE-20250918',
 'SRC-M2W3-HUAWEI-H6-PROCESSOR-20260813',
 'SRC-M2W3-HUAWEI-H7-ACCELERATOR-CARD-20260813',
 'SRC-M2W3-HUAWEI-H12-ATLAS350-LAUNCH-20260320'
)
foreach ($r in $notFound) {
  $matchingLogs = @($logs | Where-Object {$_.requirement_id -eq $r.requirement_id})
  Assert-True ($matchingLogs.Count -eq 1) "Requirement $($r.requirement_id) does not have exactly one search log."
  if ($matchingLogs.Count -eq 1) {
    $matchingResults = @($results | Where-Object {$_.search_id -eq $matchingLogs[0].search_id})
    Assert-True ($matchingResults.Count -eq 4) "Search $($matchingLogs[0].search_id) does not have four results."
    Assert-True ((@($matchingResults.source_id | Sort-Object -Unique) -join '|') -eq (($expectedSearchSources | Sort-Object) -join '|')) "Search source set mismatch for $($matchingLogs[0].search_id)."
  }
}
$objects = @('OBJ-HUAWEI-ASCEND-950-DIE','OBJ-HUAWEI-ASCEND-950PR','OBJ-HUAWEI-ASCEND-950DT')
$domains = @('identity','physical','compute','numerics','memory','interconnect','special_engines','software','evidence')
foreach ($obj in $objects) {
  $rows = @($completeness | Where-Object {$_.object_id -eq $obj})
  Assert-True ($rows.Count -eq 9) "$obj does not have nine completeness rows."
  Assert-True ((@($rows.domain | Sort-Object -Unique) -join '|') -eq (($domains | Sort-Object) -join '|')) "$obj completeness domains mismatch."
}
Assert-True ($sources.Count -eq 4) 'Expected exactly four source versions.'
Assert-True ($families.Count -eq 4) 'Expected exactly four source families.'
Assert-True ($endpoints.Count -eq 5) 'Expected exactly five endpoints.'
Assert-True (@($sources | Where-Object {$_.source_authority -ne 'first_party'}).Count -eq 0) 'Third-party sources are not allowed.'
foreach ($src in $sources) {
  $srcEnds = @($endpoints | Where-Object {$_.source_id -eq $src.source_id})
  Assert-True ($srcEnds.Count -ge 1) "Source $($src.source_id) has no endpoint."
  Assert-True (@($srcEnds | Where-Object {$_.is_preferred_endpoint -eq 'true'}).Count -eq 1) "Source $($src.source_id) must have exactly one preferred endpoint."
}
foreach ($ep in $endpoints) {
  $local = Join-Path $Root $ep.local_path
  Assert-True (Test-Path -LiteralPath $local) "Endpoint file missing: $($ep.endpoint_id)."
  if (Test-Path -LiteralPath $local) {
    $hash=(Get-FileHash -LiteralPath $local -Algorithm SHA256).Hash.ToLower()
    Assert-True ($hash -eq $ep.sha256.ToLower()) "Endpoint hash mismatch: $($ep.endpoint_id)."
  }
}
$h6Ends = @($endpoints | Where-Object {$_.source_id -eq 'SRC-M2W3-HUAWEI-H6-PROCESSOR-20260813'})
Assert-True ($h6Ends.Count -eq 2) 'H-6 must have PR and DT-route endpoints.'
Assert-True (@($h6Ends.access_date | Sort-Object -Unique).Count -eq 1 -and $h6Ends[0].access_date -eq '2026-08-13') 'H-6 endpoints must use the same 2026-08-13 access date.'
$dtRoute = @($h6Ends | Where-Object {$_.url -like '*tag=950dt*'})
Assert-True ($dtRoute.Count -eq 1 -and $dtRoute[0].is_preferred_endpoint -eq 'false' -and $dtRoute[0].notes -match 'PR server body') 'H-6 DT renderer mismatch is not preserved.'
Assert-True ($screening.Count -eq 4) 'Expected four screening decisions.'
Assert-True (@($screening | Where-Object {$_.source_id -eq 'SRC-M2W3-HUAWEI-H7-ACCELERATOR-CARD-20260813' -and $_.screening_status -eq 'redundant_covered'}).Count -eq 1) 'H-7 must be screened as redundant_covered.'
Assert-True ($coverage.Count -eq 1 -and $coverage[0].covered_source_id -eq 'SRC-M2W3-HUAWEI-H7-ACCELERATOR-CARD-20260813' -and $coverage[0].covering_source_id -eq 'SRC-M2W3-HUAWEI-H12-ATLAS350-LAUNCH-20260320') 'H-7 reverse-removal coverage record mismatch.'
Assert-True ($runs.Count -eq 1 -and $runs[0].status -eq 'draft' -and $runs[0].review_status -eq 'draft') 'Selection run must remain draft for independent review.'
Assert-True ($members.Count -eq 3) 'Minimum set must contain H-2, H-6 and H-12 only.'
Assert-True ((@($members.source_id | Sort-Object -Unique) -join '|') -eq ((@($expectedSearchSources[0],$expectedSearchSources[1],$expectedSearchSources[3]) | Sort-Object) -join '|')) 'Minimum-set member IDs mismatch.'
$componentOwner=@{}; foreach($c in $components){$componentOwner[$c.component_id]=$c.owner_object_id}
$linkOwner=@{}; foreach($l in $links){$linkOwner[$l.link_id]=$l.owner_object_id}
$precisionOwner=@{}; foreach($p in $precisions){$precisionOwner[$p.precision_path_id]=$componentOwner[$p.component_id]}
function FactOwner([object]$fact) {
  if ($fact.object_id) { return $fact.object_id }
  if ($fact.component_id) { return $componentOwner[$fact.component_id] }
  if ($fact.link_id) { return $linkOwner[$fact.link_id] }
  if ($fact.precision_path_id) { return $precisionOwner[$fact.precision_path_id] }
  return ''
}
$ownerCounts=@{}; foreach($o in $objects){$ownerCounts[$o]=@($facts | Where-Object {(FactOwner $_) -eq $o}).Count}
Assert-True ($ownerCounts['OBJ-HUAWEI-ASCEND-950-DIE'] -eq 12) 'Shared-die fact count must be 12.'
Assert-True ($ownerCounts['OBJ-HUAWEI-ASCEND-950PR'] -eq 16) '950PR fact count must be 16.'
Assert-True ($ownerCounts['OBJ-HUAWEI-ASCEND-950DT'] -eq 13) '950DT fact count must be 13.'
$sharedThroughput = @($facts | Where-Object {$_.fact_id -match '^FACT-M2W3-HUAWEI-ASC950-DIE-(FP8|MXFP8|HIF8|MXFP4)-THROUGHPUT$'})
Assert-True ($sharedThroughput.Count -eq 4) 'Four common low-precision labels must exist only on the shared die.'
foreach($f in $sharedThroughput){Assert-True ((FactOwner $f) -eq 'OBJ-HUAWEI-ASCEND-950-DIE' -and $f.condition_set_id -match 'ROADMAP') "Shared throughput layer/condition mismatch: $($f.fact_id)."}
Assert-True (@($facts | Where-Object {$_.fact_id -match 'ASC950(PR|DT)-(FP8|MXFP8|HIF8|MXFP4)-THROUGHPUT'}).Count -eq 0) 'Shared low-precision facts were duplicated onto PR/DT.'
Assert-True (@($assertions | Where-Object {$_.source_id -eq 'SRC-M2W3-HUAWEI-H7-ACCELERATOR-CARD-20260813'}).Count -eq 0) 'H-7 card values must not support die/package facts.'
$h12Facts=@($assertions | Where-Object {$_.source_id -eq 'SRC-M2W3-HUAWEI-H12-ATLAS350-LAUNCH-20260320'} | ForEach-Object {$_.fact_id} | Sort-Object -Unique)
Assert-True (($h12Facts -join '|') -eq ((@('FACT-M2W3-HUAWEI-ASC950PR-NAME','FACT-M2W3-HUAWEI-ASC950PR-SKU','FACT-M2W3-HUAWEI-ASC950PR-DEPLOYMENT','FACT-M2W3-HUAWEI-ASC950PR-STATUS') | Sort-Object) -join '|')) 'H-12 may support only PR identity and embedded deployment/status facts.'
$h6DtFacts=@($assertions | Where-Object {$_.source_id -eq 'SRC-M2W3-HUAWEI-H6-PROCESSOR-20260813' -and $_.fact_id -like '*ASC950DT*'} | ForEach-Object {$_.fact_id} | Sort-Object -Unique)
Assert-True (($h6DtFacts -join '|') -eq ((@('FACT-M2W3-HUAWEI-ASC950DT-NAME','FACT-M2W3-HUAWEI-ASC950DT-SKU') | Sort-Object) -join '|')) 'H-6 DT route may support identity only, not DT specifications.'
Assert-True (@($facts | Where-Object {$_.object_relation_id}).Count -eq 0) 'No new relation-scoped facts are allowed.'
Assert-True (@($facts | Where-Object {$_.fact_id -match 'DAVINCI|DA-VINCI'}).Count -eq 0) 'No old Da Vinci implementation facts may migrate.'
$dieStatusFact=@($facts | Where-Object {$_.object_id -eq 'OBJ-HUAWEI-ASCEND-950-DIE' -and $_.field_id -eq 'FIELD-ID-STATUS'})
Assert-True ($dieStatusFact.Count -eq 0) 'Shared die must have no standalone status fact.'
Assert-True (@($requirements | Where-Object {$_.requirement_id -eq 'REQ-M2W3-HUAWEI-ASC950-DIE-STATUS' -and $_.requirement_status -eq 'not_applicable'}).Count -eq 1) 'Shared die status requirement must be not_applicable.'
Assert-True (@($facts | Where-Object {$_.fact_id -eq 'FACT-M2W3-HUAWEI-ASC950PR-STATUS' -and $_.normalized_value_text -eq 'available' -and $_.condition_set_id -eq 'COND-M2W3-HUAWEI-ASC950PR-EMBEDDED-STATUS-20260320'}).Count -eq 1) 'PR embedded-availability status fact mismatch.'
Assert-True (@($requirements | Where-Object {$_.requirement_id -eq 'REQ-M2W3-HUAWEI-ASC950PR-AVAILABILITY' -and $_.requirement_status -eq 'not_found'}).Count -eq 1) 'PR standalone availability must remain not_found.'
Assert-True (@($facts | Where-Object {$_.fact_id -eq 'FACT-M2W3-HUAWEI-ASC950DT-STATUS' -and $_.normalized_value_text -eq 'announced'}).Count -eq 1) 'DT status must remain announced.'
Assert-True (@($requirements | Where-Object {$_.requirement_id -eq 'REQ-M2W3-HUAWEI-ASC950DT-AVAILABILITY' -and $_.requirement_status -eq 'pending_verification'}).Count -eq 1) 'DT availability must remain pending_verification.'
Assert-True ($requirementEvidence.Count -eq 1 -and $requirementEvidence[0].requirement_id -eq 'REQ-M2W3-HUAWEI-ASC950DT-AVAILABILITY') 'Pending evidence must be only the DT roadmap availability record.'
$cardText = (Get-ChildItem -LiteralPath (Join-Path $pkg 'card-draft') -File | ForEach-Object {Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8}) -join "`n"
Assert-True (@(Get-ChildItem -LiteralPath (Join-Path $pkg 'card-draft') -File).Count -eq 3) 'Exactly three cards are required.'
foreach($fact in $facts){Assert-True ($cardText -match [regex]::Escape($fact.fact_id)) "Card drafts do not cite fact $($fact.fact_id)."}
foreach($name in $expectedNames){
  $formalRelative = if (Test-Path -LiteralPath (Join-Path $Root "数据\$name")) { "数据/$name" } else { "最小参考资料库/$name" }
  $pk = @($schema | Where-Object {$_.table_path -eq $formalRelative} | Sort-Object {[int]$_.ordinal} | Select-Object -First 1 -ExpandProperty column_name)
  $stageRows = @(Rows $name)
  if ($stageRows.Count -gt 0) {
    $formalRows = @(Import-Csv -LiteralPath (Join-Path $Root ($formalRelative -replace '/','\')))
    $formalIds=@($formalRows | ForEach-Object {$_.$pk})
    $stageIds=@($stageRows | ForEach-Object {$_.$pk})
    Assert-True (@($stageIds | Group-Object | Where-Object {$_.Count -gt 1}).Count -eq 0) "Duplicate package primary key in $name."
    Assert-True (@($stageIds | Where-Object {$_ -in $formalIds}).Count -eq 0) "Package primary-key collision with formal $name."
  }
}
$status = if($failures.Count -eq 0){'pass'}else{'fail'}
$result=[ordered]@{
  status=$status
  checked_at='2026-08-13'
  checks=$checks
  counts=[ordered]@{facts=$facts.Count;assertions=$assertions.Count;requirements=$requirements.Count;completeness=$completeness.Count;sources=$sources.Count;endpoints=$endpoints.Count;search_logs=$logs.Count;search_results=$results.Count}
  object_fact_counts=[ordered]@{die=$ownerCounts['OBJ-HUAWEI-ASCEND-950-DIE'];ascend950pr=$ownerCounts['OBJ-HUAWEI-ASCEND-950PR'];ascend950dt=$ownerCounts['OBJ-HUAWEI-ASCEND-950DT']}
  failures=@($failures)
}
$outPath=Join-Path $pkg 'validation\package-validation-results.json'
[IO.File]::WriteAllText($outPath,($result|ConvertTo-Json -Depth 6),(New-Object Text.UTF8Encoding($false)))
$result | ConvertTo-Json -Depth 6
if($failures.Count -gt 0){exit 1}