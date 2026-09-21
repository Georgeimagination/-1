#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总'
)
$ErrorActionPreference = 'Stop'
$stage = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS'
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
$allowedNonEmpty = @('components.csv','memory-levels.csv','links.csv','precision-paths.csv','condition-sets.csv','facts.csv','field-requirements.csv','card-completeness.csv','source-endpoints.csv','fact-assertions.csv','source-selected-roles.csv','search-log.csv','search-results.csv','conflict-groups.csv','conflict-members.csv','selection-runs.csv','selection-members.csv')
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
Check ($facts.Count -eq 56) "Expected 56 facts, got $($facts.Count)."
Check ($assertions.Count -eq 66) "Expected 66 assertions, got $($assertions.Count)."
Check ($requirements.Count -eq 70) "Expected 70 requirements, got $($requirements.Count)."
foreach ($row in @($facts + $requirements)) {
    $id = if (-not (Is-Blank $row.fact_id)) { $row.fact_id } else { $row.requirement_id }
    $targetCount = @($targets | Where-Object { -not (Is-Blank $row.$_) }).Count
    Check ($targetCount -eq 1) "Seven-target XOR failed: $id ($targetCount targets)."
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

$factMap = @(Import-Csv -LiteralPath (Join-Path $audit 'fact-requirement-map.csv') -Encoding UTF8)
Check ($factMap.Count -eq 56) "Expected 56 fact-requirement mappings, got $($factMap.Count)."
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

$backlog = @(Import-Csv -LiteralPath (Join-Path $audit 'backlog-disposition.csv') -Encoding UTF8)
Check ($backlog.Count -eq 24) "Expected 24 backlog disposition rows, got $($backlog.Count)."
Check (@($backlog | Group-Object deferred_id | Where-Object Count -gt 1).Count -eq 0) 'Backlog deferred_id duplicates found.'
Check (@($backlog | Where-Object disposition -eq 'split_into_candidate_facts').Count -eq 23) 'Expected 23 implementation backlog rows.'
Check (@($backlog | Where-Object deferred_id -eq 'DEF-M2GA-ATRN2-01' | Where-Object disposition -eq 'reused_formal_chain').Count -eq 1) 'Trainium2 formal-chain reuse row missing.'
$backlogFactIds = @($backlog.candidate_fact_ids -join '|' -split '\|' | Where-Object { -not (Is-Blank $_) })
Check ($backlogFactIds.Count -eq 56) "Backlog should enumerate 56 fact IDs, got $($backlogFactIds.Count)."
Check (@($backlogFactIds | Sort-Object -Unique).Count -eq 56) 'Backlog fact IDs are not unique.'
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
Check ($coverage.Count -eq 56) "Expected 56 card coverage rows, got $($coverage.Count)."
Check (@($coverage | Group-Object fact_id | Where-Object Count -ne 1).Count -eq 0) 'Card coverage must map each fact once.'
foreach ($row in $coverage) {
    $cardPath = Join-Path $stage $row.card_path.Replace('/','\')
    Check (Test-Path -LiteralPath $cardPath) "Card file missing: $($row.card_path)."
    if (Test-Path -LiteralPath $cardPath) {
        $text = Get-Content -LiteralPath $cardPath -Raw -Encoding UTF8
        Check ($text.Contains($row.fact_id)) "Card lacks mapped fact: $($row.fact_id)."
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
Check ($selectionRuns.Count -eq 1) 'Expected one package selection run.'
Check ($selectionRuns[0].status -eq 'draft') 'Selection run must await independent review.'
Check ($selectionMembers.Count -eq 9) "Expected nine selected sources, got $($selectionMembers.Count)."
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
Check (@($reverse | Where-Object decision -eq 'retain').Count -eq 9) 'Reverse removal must retain nine source IDs.'
Check (@($reverse | Where-Object source_id -eq 'SRC-M2-GA-A09' | Where-Object decision -eq 'excluded').Count -eq 1) 'A09 package-scope exclusion missing.'

$budgets = [ordered]@{'components.csv'=25;'precision-paths.csv'=18;'memory-levels.csv'=6;'links.csv'=3;'condition-sets.csv'=30;'facts.csv'=60;'fact-assertions.csv'=70;'field-requirements.csv'=75}
foreach ($name in $budgets.Keys) {
    $count = @(Import-Csv -LiteralPath (Join-Path $structured $name) -Encoding UTF8).Count
    Check ($count -le $budgets[$name]) "Budget exceeded: $name $count/$($budgets[$name])."
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    Write-Output "Staging validation failed: $($errors.Count) errors after $checks checks."
    exit 1
}
Write-Output "M2-W2-AWS-PACKAGE-FACTS staging validation passed: $checks checks; 32 headers, schema/enums/FKs, 56 facts, 66 assertions, 70 requirements, 5 conflicts, source gate, backlog, nine-domain completeness, cards and minimum-set audit all passed."
