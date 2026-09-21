#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RootPath = ''
)

$ErrorActionPreference = 'Stop'
$script:Errors = [System.Collections.Generic.List[string]]::new()
$script:Checks = 0

function Add-Check {
    param(
        [bool]$Condition,
        [string]$Message
    )
    $script:Checks++
    if (-not $Condition) { $script:Errors.Add($Message) }
}

function Get-CompositeKey {
    param(
        [string]$TableName,
        [string]$PrimaryKey
    )
    return $TableName + [char]31 + $PrimaryKey
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($RootPath)) {
    $root = [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..\..'))
} else {
    $root = (Resolve-Path -LiteralPath $RootPath).Path
}
$migrationPath = Join-Path $scriptDir 'migration.csv'
Add-Check (Test-Path -LiteralPath $migrationPath -PathType Leaf) 'migration.csv is missing.'
if (-not (Test-Path -LiteralPath $migrationPath -PathType Leaf)) {
    Write-Output 'FAIL: migration.csv is missing.'
    exit 1
}

$batchStage = [ordered]@{
    GHC = 'M2-GHC-ARCH'
    GA  = 'M2-GA-ARCH'
    NA  = 'M2-NA-ARCH'
}
$batchOrder = @('M1','GHC','GA','NA')
$evidenceBasis = [ordered]@{
    M1  = '审计/M1_试填合并验收.md + 审计/子代理交接/m1_postmerge_audit.md + 审计/子代理交接/data_review_lifecycle_independent_review.md'
    GHC = '审计/M2_GHC_架构包正式合并验收.md + 审计/子代理交接/m2_review_ghc_arch.md + 审计/子代理交接/data_review_lifecycle_independent_review.md'
    GA  = '审计/M2_GA_架构包正式合并验收.md + 审计/子代理交接/m2_review_ga_arch.md + 审计/子代理交接/data_review_lifecycle_independent_review.md'
    NA  = '审计/M2_NA_架构包正式合并验收.md + 审计/子代理交接/m2_review_na_arch.md + 审计/子代理交接/data_review_lifecycle_independent_review.md'
}
$tableSpecs = @(
    [pscustomobject]@{
        table_name = '最小参考资料库/fact-assertions.csv'
        formal_path = '最小参考资料库\fact-assertions.csv'
        staging_name = 'fact-assertions.csv'
        primary_key = 'assertion_id'
        semantic_column = 'extraction_status'
        allowed_statuses = @('source_checked')
    },
    [pscustomobject]@{
        table_name = '数据/facts.csv'
        formal_path = '数据\facts.csv'
        staging_name = 'facts.csv'
        primary_key = 'fact_id'
        semantic_column = 'resolution_state'
        allowed_statuses = @('accepted','provisional','superseded')
    },
    [pscustomobject]@{
        table_name = '数据/field-requirements.csv'
        formal_path = '数据\field-requirements.csv'
        staging_name = 'field-requirements.csv'
        primary_key = 'requirement_id'
        semantic_column = 'requirement_status'
        allowed_statuses = @('value_available','not_found','not_applicable','inaccessible_evidence')
    },
    [pscustomobject]@{
        table_name = '最小参考资料库/source-screening.csv'
        formal_path = '最小参考资料库\source-screening.csv'
        staging_name = 'source-screening.csv'
        primary_key = 'screening_id'
        semantic_column = 'screening_status'
        allowed_statuses = @('selected','redundant_covered','out_of_scope','rejected_unreliable','lead_only')
    }
)
$tableNames = @($tableSpecs | ForEach-Object table_name)
$tableSpecByName = @{}
$formalIndexByTable = @{}
$expectedRows = [System.Collections.Generic.Dictionary[string,object]]::new([System.StringComparer]::Ordinal)

foreach ($spec in $tableSpecs) {
    $tableSpecByName[$spec.table_name] = $spec
    $formalPath = Join-Path $root $spec.formal_path
    Add-Check (Test-Path -LiteralPath $formalPath -PathType Leaf) "Formal table missing: $($spec.table_name)"
    if (-not (Test-Path -LiteralPath $formalPath -PathType Leaf)) { continue }
    $formalRows = @(Import-Csv -LiteralPath $formalPath)
    $formalIndex = [System.Collections.Generic.Dictionary[string,object]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $formalRows) {
        $key = [string]$row.($spec.primary_key)
        Add-Check (-not [string]::IsNullOrWhiteSpace($key)) "Empty formal primary key: $($spec.table_name)"
        if (-not [string]::IsNullOrWhiteSpace($key)) {
            Add-Check (-not $formalIndex.ContainsKey($key)) "Duplicate formal primary key: $($spec.table_name) $key"
            if (-not $formalIndex.ContainsKey($key)) { $formalIndex.Add($key,$row) }
        }
    }
    $formalIndexByTable[$spec.table_name] = $formalIndex

    $stageSets = @{}
    foreach ($shortBatch in @('GHC','GA','NA')) {
        $stageRelative = '审计\子代理交接\m2_staging\' + $batchStage[$shortBatch] + '\structured\' + $spec.staging_name
        $stagePath = Join-Path $root $stageRelative
        Add-Check (Test-Path -LiteralPath $stagePath -PathType Leaf) "Staging table missing: $stageRelative"
        $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        if (Test-Path -LiteralPath $stagePath -PathType Leaf) {
            foreach ($stageRow in @(Import-Csv -LiteralPath $stagePath)) {
                $key = [string]$stageRow.($spec.primary_key)
                Add-Check (-not [string]::IsNullOrWhiteSpace($key)) "Empty staging primary key: $stageRelative"
                if (-not [string]::IsNullOrWhiteSpace($key)) {
                    Add-Check ($set.Add($key)) "Duplicate staging primary key: $stageRelative $key"
                    Add-Check ($formalIndex.ContainsKey($key)) "Staging primary key absent from formal table: $stageRelative $key"
                }
            }
        }
        $stageSets[$shortBatch] = $set
    }

    foreach ($left in @('GHC','GA','NA')) {
        foreach ($right in @('GHC','GA','NA')) {
            if ([array]::IndexOf(@('GHC','GA','NA'),$left) -ge [array]::IndexOf(@('GHC','GA','NA'),$right)) { continue }
            foreach ($key in $stageSets[$left]) {
                Add-Check (-not $stageSets[$right].Contains($key)) "Staging primary key overlaps batches: $($spec.table_name) $key ($left/$right)"
            }
        }
    }

    foreach ($row in $formalRows) {
        if ([string]$row.review_status -ne 'draft') { continue }
        $semanticValue = [string]$row.($spec.semantic_column)
        if ($semanticValue -notin $spec.allowed_statuses) { continue }
        $primaryKey = [string]$row.($spec.primary_key)
        $batch = 'M1'
        foreach ($shortBatch in @('GHC','GA','NA')) {
            if ($stageSets[$shortBatch].Contains($primaryKey)) {
                $batch = $shortBatch
                break
            }
        }
        $compositeKey = Get-CompositeKey -TableName $spec.table_name -PrimaryKey $primaryKey
        $expected = [pscustomobject][ordered]@{
            table_name = $spec.table_name
            primary_key = $primaryKey
            batch = $batch
            old_review_status = 'draft'
            new_review_status = 'reviewed'
            semantic_status_preserved = $spec.semantic_column + '=' + $semanticValue
            evidence_basis = $evidenceBasis[$batch]
        }
        Add-Check (-not $expectedRows.ContainsKey($compositeKey)) "Duplicate expected migration key: $($spec.table_name) $primaryKey"
        if (-not $expectedRows.ContainsKey($compositeKey)) { $expectedRows.Add($compositeKey,$expected) }
    }
}

$migration = @(Import-Csv -LiteralPath $migrationPath)
$requiredColumns = @('table_name','primary_key','batch','old_review_status','new_review_status','semantic_status_preserved','evidence_basis')
if ($migration.Count -gt 0) {
    $actualColumns = @(($migration | Select-Object -First 1).PSObject.Properties.Name)
    Add-Check (($actualColumns -join [char]31) -eq ($requiredColumns -join [char]31)) 'migration.csv header does not match the required seven columns.'
}
Add-Check ($migration.Count -eq 1924) "migration.csv row count must be 1924; actual=$($migration.Count)"
Add-Check ($expectedRows.Count -eq 1924) "Expected candidate row count must be 1924; actual=$($expectedRows.Count)"

$actualRows = [System.Collections.Generic.Dictionary[string,object]]::new([System.StringComparer]::Ordinal)
foreach ($row in $migration) {
    foreach ($column in $requiredColumns) {
        Add-Check (-not [string]::IsNullOrWhiteSpace([string]$row.$column)) "migration.csv required value missing: $column"
    }
    $compositeKey = Get-CompositeKey -TableName ([string]$row.table_name) -PrimaryKey ([string]$row.primary_key)
    Add-Check (-not $actualRows.ContainsKey($compositeKey)) "Duplicate migration primary key: $($row.table_name) $($row.primary_key)"
    if (-not $actualRows.ContainsKey($compositeKey)) { $actualRows.Add($compositeKey,$row) }
    Add-Check ($expectedRows.ContainsKey($compositeKey)) "Migration row is not in the formal/staging-derived whitelist: $($row.table_name) $($row.primary_key)"
    if (-not $expectedRows.ContainsKey($compositeKey)) { continue }
    $expected = $expectedRows[$compositeKey]
    foreach ($column in $requiredColumns) {
        Add-Check ([string]$row.$column -ceq [string]$expected.$column) "Migration value mismatch: $($row.table_name) $($row.primary_key) $column"
    }
    Add-Check ($formalIndexByTable.ContainsKey([string]$row.table_name)) "Unknown formal table in migration: $($row.table_name)"
    if ($formalIndexByTable.ContainsKey([string]$row.table_name)) {
        $formalIndex = $formalIndexByTable[[string]$row.table_name]
        Add-Check ($formalIndex.ContainsKey([string]$row.primary_key)) "Migration primary key not found in formal table: $($row.table_name) $($row.primary_key)"
        if ($formalIndex.ContainsKey([string]$row.primary_key)) {
            $formalRow = $formalIndex[[string]$row.primary_key]
            $spec = $tableSpecByName[[string]$row.table_name]
            Add-Check ([string]$formalRow.review_status -ceq [string]$row.old_review_status) "Formal review_status no longer matches migration old value: $($row.table_name) $($row.primary_key)"
            $semanticPair = $spec.semantic_column + '=' + [string]$formalRow.($spec.semantic_column)
            Add-Check ($semanticPair -ceq [string]$row.semantic_status_preserved) "Semantic status no longer matches formal table: $($row.table_name) $($row.primary_key)"
        }
    }
}
foreach ($key in $expectedRows.Keys) {
    Add-Check ($actualRows.ContainsKey($key)) "Expected whitelist row missing from migration.csv: $key"
}

$expectedTableCounts = [ordered]@{
    '最小参考资料库/fact-assertions.csv' = 598
    '数据/facts.csv' = 554
    '数据/field-requirements.csv' = 698
    '最小参考资料库/source-screening.csv' = 74
}
$expectedBatchCounts = [ordered]@{ M1=646; GHC=158; GA=379; NA=741 }
$expectedMatrix = [ordered]@{
    M1  = [ordered]@{'最小参考资料库/fact-assertions.csv'=237;'数据/facts.csv'=195;'数据/field-requirements.csv'=193;'最小参考资料库/source-screening.csv'=21}
    GHC = [ordered]@{'最小参考资料库/fact-assertions.csv'=35;'数据/facts.csv'=35;'数据/field-requirements.csv'=79;'最小参考资料库/source-screening.csv'=9}
    GA  = [ordered]@{'最小参考资料库/fact-assertions.csv'=141;'数据/facts.csv'=141;'数据/field-requirements.csv'=72;'最小参考资料库/source-screening.csv'=25}
    NA  = [ordered]@{'最小参考资料库/fact-assertions.csv'=185;'数据/facts.csv'=183;'数据/field-requirements.csv'=354;'最小参考资料库/source-screening.csv'=19}
}
foreach ($tableName in $expectedTableCounts.Keys) {
    $count = @($migration | Where-Object table_name -ceq $tableName).Count
    Add-Check ($count -eq $expectedTableCounts[$tableName]) "Table distribution mismatch: $tableName expected=$($expectedTableCounts[$tableName]) actual=$count"
}
foreach ($batch in $expectedBatchCounts.Keys) {
    $count = @($migration | Where-Object batch -ceq $batch).Count
    Add-Check ($count -eq $expectedBatchCounts[$batch]) "Batch distribution mismatch: $batch expected=$($expectedBatchCounts[$batch]) actual=$count"
    foreach ($tableName in $expectedMatrix[$batch].Keys) {
        $cellCount = @($migration | Where-Object { $_.batch -ceq $batch -and $_.table_name -ceq $tableName }).Count
        Add-Check ($cellCount -eq $expectedMatrix[$batch][$tableName]) "Batch/table distribution mismatch: $batch $tableName expected=$($expectedMatrix[$batch][$tableName]) actual=$cellCount"
    }
}
Add-Check (@($migration | Where-Object old_review_status -cne 'draft').Count -eq 0) 'All old_review_status values must be draft.'
Add-Check (@($migration | Where-Object new_review_status -cne 'reviewed').Count -eq 0) 'All new_review_status values must be reviewed.'

$migrationHash = (Get-FileHash -LiteralPath $migrationPath -Algorithm SHA256).Hash
$summaryColumns = @('batch','table_name','candidate_count','old_review_status','new_review_status','semantic_column','evidence_basis','migration_sha256','manifest_check_status','signoff_status','reviewer','review_date','notes')
foreach ($batch in $batchOrder) {
    $summaryPath = Join-Path $scriptDir ('signoff-' + $batch + '.csv')
    Add-Check (Test-Path -LiteralPath $summaryPath -PathType Leaf) "Signoff summary missing: signoff-$batch.csv"
    if (-not (Test-Path -LiteralPath $summaryPath -PathType Leaf)) { continue }
    $summary = @(Import-Csv -LiteralPath $summaryPath)
    Add-Check ($summary.Count -eq 4) "Signoff summary must have four table rows: signoff-$batch.csv"
    if ($summary.Count -gt 0) {
        $columns = @(($summary | Select-Object -First 1).PSObject.Properties.Name)
        Add-Check (($columns -join [char]31) -eq ($summaryColumns -join [char]31)) "Signoff summary header mismatch: signoff-$batch.csv"
    }
    $seenTables = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($row in $summary) {
        Add-Check ([string]$row.batch -ceq $batch) "Signoff batch mismatch: signoff-$batch.csv"
        Add-Check ($tableNames -ccontains [string]$row.table_name) "Unknown table in signoff-$batch.csv: $($row.table_name)"
        Add-Check ($seenTables.Add([string]$row.table_name)) "Duplicate table in signoff-$batch.csv: $($row.table_name)"
        $count = @($migration | Where-Object { $_.batch -ceq $batch -and $_.table_name -ceq [string]$row.table_name }).Count
        $parsedCount = 0
        Add-Check ([int]::TryParse([string]$row.candidate_count,[ref]$parsedCount)) "Invalid candidate_count in signoff-$batch.csv: $($row.table_name)"
        Add-Check ($parsedCount -eq $count) "candidate_count mismatch in signoff-$batch.csv: $($row.table_name)"
        Add-Check ([string]$row.old_review_status -ceq 'draft') "Invalid old_review_status in signoff-$batch.csv: $($row.table_name)"
        Add-Check ([string]$row.new_review_status -ceq 'reviewed') "Invalid new_review_status in signoff-$batch.csv: $($row.table_name)"
        if ($tableSpecByName.ContainsKey([string]$row.table_name)) {
            Add-Check ([string]$row.semantic_column -ceq [string]$tableSpecByName[[string]$row.table_name].semantic_column) "semantic_column mismatch in signoff-$batch.csv: $($row.table_name)"
        }
        Add-Check ([string]$row.evidence_basis -ceq [string]$evidenceBasis[$batch]) "evidence_basis mismatch in signoff-$batch.csv: $($row.table_name)"
        Add-Check ([string]$row.migration_sha256 -ceq $migrationHash) "migration_sha256 mismatch in signoff-$batch.csv: $($row.table_name)"
        Add-Check ([string]$row.manifest_check_status -ceq 'passed') "manifest_check_status must be passed in signoff-$batch.csv: $($row.table_name)"
        Add-Check ([string]$row.signoff_status -ceq 'accept') "signoff_status must be accept in signoff-$batch.csv: $($row.table_name)"
        Add-Check (-not [string]::IsNullOrWhiteSpace([string]$row.reviewer)) "reviewer missing in signoff-$batch.csv: $($row.table_name)"
        Add-Check (-not [string]::IsNullOrWhiteSpace([string]$row.review_date)) "review_date missing in signoff-$batch.csv: $($row.table_name)"
        Add-Check (-not [string]::IsNullOrWhiteSpace([string]$row.notes)) "notes missing in signoff-$batch.csv: $($row.table_name)"
    }
    foreach ($tableName in $tableNames) {
        Add-Check ($seenTables.Contains($tableName)) "Table missing from signoff-$batch.csv: $tableName"
    }
}

if ($script:Errors.Count -gt 0) {
    Write-Output "FAIL: $($script:Errors.Count) migration audit error(s); $($script:Checks) checks executed."
    foreach ($message in $script:Errors) { Write-Output " - $message" }
    Write-Output 'No formal CSV was modified by this verifier.'
    exit 1
}

Write-Output "PASS: migration audit manifest; $($script:Checks) checks executed."
Write-Output "Manifest: 1924 unique rows; SHA-256 $migrationHash"
Write-Output 'By table: fact-assertions=598; facts=554; field-requirements=698; source-screening=74.'
Write-Output 'By batch: M1=646; GHC=158; GA=379; NA=741.'
Write-Output 'All rows match current formal primary keys, staging-derived batch membership, draft->reviewed, and preserved semantic statuses.'
Write-Output 'Four batch signoff summaries match the manifest and are bound to its SHA-256.'
Write-Output 'No migration was executed; the four formal CSV files were read only.'
exit 0