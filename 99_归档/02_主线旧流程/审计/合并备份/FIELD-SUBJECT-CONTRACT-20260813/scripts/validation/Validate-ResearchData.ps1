#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RootPath = '.'
)

$ErrorActionPreference = 'Stop'
$script:Errors = [System.Collections.Generic.List[string]]::new()
$script:Checks = 0

function Add-ValidationError {
    param([string]$Message)
    $script:Errors.Add($Message)
}

function Test-Empty {
    param($Value)
    return [string]::IsNullOrWhiteSpace([string]$Value)
}

function Resolve-TablePath {
    param([string]$Root, [string]$TablePath)
    $parts = $TablePath -split '/'
    $resolved = $Root
    foreach ($part in $parts) { $resolved = Join-Path $resolved $part }
    return $resolved
}

$root = (Resolve-Path -LiteralPath $RootPath).Path
$schemaPath = Join-Path (Join-Path $root '数据') 'schema-columns.csv'
$enumPath = Join-Path (Join-Path $root '数据') 'enums.csv'
if (-not (Test-Path -LiteralPath $schemaPath)) { throw "Missing schema registry: $schemaPath" }
if (-not (Test-Path -LiteralPath $enumPath)) { throw "Missing enum registry: $enumPath" }

$schema = @(Import-Csv -LiteralPath $schemaPath)
$enumRows = @(Import-Csv -LiteralPath $enumPath)
$enumSets = @{}
foreach ($group in ($enumRows | Group-Object enum_name)) {
    $set = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($row in $group.Group) { [void]$set.Add($row.enum_value) }
    $enumSets[$group.Name] = $set
}

$tableData = @{}
$tableHeaders = @{}
foreach ($tableGroup in ($schema | Group-Object table_path)) {
    $tablePath = $tableGroup.Name
    $fullPath = Resolve-TablePath -Root $root -TablePath $tablePath
    $script:Checks++
    if (-not (Test-Path -LiteralPath $fullPath)) {
        Add-ValidationError "Missing required table: $tablePath"
        continue
    }
    $expectedColumns = @($tableGroup.Group | Sort-Object {[int]$_.ordinal} | ForEach-Object column_name)
    $headerLine = Get-Content -LiteralPath $fullPath -Encoding UTF8 -TotalCount 1
    if ([string]::IsNullOrWhiteSpace($headerLine)) {
        Add-ValidationError "Empty table file: $tablePath"
        continue
    }
    $actualColumns = @((Import-Csv -LiteralPath $fullPath | Select-Object -First 1).PSObject.Properties.Name)
    if ($actualColumns.Count -eq 0 -or ($actualColumns.Count -eq 1 -and [string]::IsNullOrWhiteSpace([string]$actualColumns[0]))) {
        $emptyValues = for ($i = 0; $i -lt $expectedColumns.Count; $i++) { '' }
        $tempRow = $headerLine + [Environment]::NewLine + ($emptyValues -join ',')
        $actualColumns = @(($tempRow | ConvertFrom-Csv | Select-Object -First 1).PSObject.Properties.Name)
    }
    $script:Checks++
    if (($expectedColumns -join [char]31) -ne ($actualColumns -join [char]31)) {
        Add-ValidationError "Header mismatch: $tablePath"
    }
    $rows = @(Import-Csv -LiteralPath $fullPath)
    $tableData[$tablePath] = $rows
    $tableHeaders[$tablePath] = $actualColumns

    foreach ($column in $tableGroup.Group) {
        if ($column.is_nullable -eq 'false') {
            foreach ($row in $rows) {
                $script:Checks++
                if (Test-Empty $row.($column.column_name)) {
                    Add-ValidationError "Required value missing: $tablePath.$($column.column_name)"
                }
            }
        }
        if ($column.semicolon_forbidden -eq 'true') {
            foreach ($row in $rows) {
                $script:Checks++
                if (([string]$row.($column.column_name)).Contains(';')) {
                    Add-ValidationError "Semicolon multi-value forbidden: $tablePath.$($column.column_name)"
                }
            }
        }
        if (-not (Test-Empty $column.enum_name)) {
            if (-not $enumSets.ContainsKey($column.enum_name)) {
                Add-ValidationError "Unknown enum registry name: $($column.enum_name)"
            } else {
                foreach ($row in $rows) {
                    $value = [string]$row.($column.column_name)
                    if (-not (Test-Empty $value)) {
                        $script:Checks++
                        if (-not $enumSets[$column.enum_name].Contains($value)) {
                            Add-ValidationError "Invalid enum value '$value': $tablePath.$($column.column_name)"
                        }
                    }
                }
            }
        }
    }

    $pkColumns = @($tableGroup.Group | Where-Object is_primary_key -eq 'true' | Sort-Object {[int]$_.ordinal})
    if ($pkColumns.Count -gt 0) {
        $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($row in $rows) {
            $keyParts = @($pkColumns | ForEach-Object {[string]$row.($_.column_name)})
            $key = $keyParts -join [char]31
            $script:Checks++
            if ($keyParts | Where-Object { Test-Empty $_ }) {
                Add-ValidationError "Primary key empty: $tablePath"
            } elseif (-not $seen.Add($key)) {
                Add-ValidationError "Duplicate primary key '$key': $tablePath"
            }
        }
    }
}

foreach ($column in $schema | Where-Object { -not (Test-Empty $_.foreign_table_path) }) {
    if (-not $tableData.ContainsKey($column.table_path) -or -not $tableData.ContainsKey($column.foreign_table_path)) { continue }
    $targetSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($targetRow in $tableData[$column.foreign_table_path]) {
        [void]$targetSet.Add([string]$targetRow.($column.foreign_column_name))
    }
    foreach ($row in $tableData[$column.table_path]) {
        $value = [string]$row.($column.column_name)
        if (-not (Test-Empty $value)) {
            $script:Checks++
            if (-not $targetSet.Contains($value)) {
                Add-ValidationError "Broken foreign key '$value': $($column.table_path).$($column.column_name)"
            }
        }
    }
}

$targetColumns = @('object_id','component_id','link_id','object_relation_id','precision_path_id','capability_id','topology_id')
foreach ($tablePath in @('数据/facts.csv','数据/field-requirements.csv')) {
    if (-not $tableData.ContainsKey($tablePath)) { continue }
    foreach ($row in $tableData[$tablePath]) {
        $count = @($targetColumns | Where-Object { -not (Test-Empty $row.$_) }).Count
        $script:Checks++
        if ($count -ne 1) { Add-ValidationError "Exactly one target is required: $tablePath" }
    }
}

if ($tableData.ContainsKey('数据/facts.csv')) {
    foreach ($row in $tableData['数据/facts.csv']) {
        $hasText = -not (Test-Empty $row.normalized_value_text)
        $hasNumber = -not (Test-Empty $row.normalized_value_number)
        $script:Checks++
        if ($hasText -eq $hasNumber) { Add-ValidationError "Fact value XOR failed: $($row.fact_id)" }
        if ($hasNumber) {
            $parsed = 0.0
            if (-not [double]::TryParse($row.normalized_value_number,[Globalization.NumberStyles]::Float,[Globalization.CultureInfo]::InvariantCulture,[ref]$parsed)) {
                Add-ValidationError "Fact numeric value is not invariant numeric: $($row.fact_id)"
            }
        }
    }
}

if ($tableData.ContainsKey('最小参考资料库/fact-assertions.csv')) {
    foreach ($row in $tableData['最小参考资料库/fact-assertions.csv']) {
        $hasText = -not (Test-Empty $row.raw_value_text)
        $hasNumber = -not (Test-Empty $row.raw_value_number)
        $script:Checks++
        if ($hasText -eq $hasNumber) { Add-ValidationError "Assertion raw value XOR failed: $($row.assertion_id)" }
        if (Test-Empty $row.source_locator) { Add-ValidationError "Assertion locator missing: $($row.assertion_id)" }
    }
}

$facts = if ($tableData.ContainsKey('数据/facts.csv')) { @($tableData['数据/facts.csv']) } else { @() }
$assertions = if ($tableData.ContainsKey('最小参考资料库/fact-assertions.csv')) { @($tableData['最小参考资料库/fact-assertions.csv']) } else { @() }
# Evidence state must agree with the number of distinct content-version sources.
foreach ($fact in $facts | Where-Object { $_.fact_kind -ne 'derived' }) {
    $sourceCount = @($assertions | Where-Object fact_id -eq $fact.fact_id | Select-Object -ExpandProperty source_id -Unique).Count
    $script:Checks++
    if ($fact.evidence_state -eq 'single_source' -and $sourceCount -ne 1) {
        Add-ValidationError "single_source fact must have exactly one source: $($fact.fact_id)"
    }
    $script:Checks++
    if ($fact.evidence_state -eq 'corroborated' -and $sourceCount -lt 2) {
        Add-ValidationError "corroborated fact must have at least two sources: $($fact.fact_id)"
    }
}
foreach ($fact in $facts | Where-Object { $_.fact_kind -ne 'derived' -and $_.review_status -in @('reviewed','approved') }) {
    $accepted = @($assertions | Where-Object { $_.fact_id -eq $fact.fact_id -and $_.extraction_status -in @('source_checked','independently_reviewed') -and $_.review_status -in @('reviewed','approved') })
    $script:Checks++
    if ($accepted.Count -eq 0) { Add-ValidationError "Accepted non-derived fact lacks reviewed assertion: $($fact.fact_id)" }
}

if ($tableData.ContainsKey('最小参考资料库/source-endpoints.csv')) {
    $endpoints = @($tableData['最小参考资料库/source-endpoints.csv'])
    $rootFull = [System.IO.Path]::GetFullPath($root).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $rootPrefix = $rootFull + [System.IO.Path]::DirectorySeparatorChar

    foreach ($group in ($endpoints | Group-Object source_id)) {
        $preferredCount = @($group.Group | Where-Object is_preferred_endpoint -eq 'true').Count
        $script:Checks++
        if ($preferredCount -ne 1) {
            Add-ValidationError "Source must have exactly one preferred endpoint: $($group.Name)"
        }
    }

    foreach ($row in $endpoints | Where-Object { -not (Test-Empty $_.local_path) }) {
        $script:Checks++
        if ([System.IO.Path]::IsPathRooted([string]$row.local_path)) {
            Add-ValidationError "Endpoint local_path must be project-relative: $($row.endpoint_id)"
            continue
        }
        try {
            $relativePath = ([string]$row.local_path).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
            $fullLocalPath = [System.IO.Path]::GetFullPath((Join-Path $root $relativePath))
        } catch {
            Add-ValidationError "Endpoint local_path is invalid: $($row.endpoint_id)"
            continue
        }
        $script:Checks++
        if (-not $fullLocalPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            Add-ValidationError "Endpoint local_path escapes project root: $($row.endpoint_id)"
            continue
        }
        $script:Checks++
        if (-not (Test-Path -LiteralPath $fullLocalPath -PathType Leaf)) {
            Add-ValidationError "Endpoint local file missing: $($row.endpoint_id)"
            continue
        }
        $script:Checks++
        if (([string]$row.sha256) -notmatch '^[0-9A-Fa-f]{64}$') {
            Add-ValidationError "Endpoint local file lacks valid SHA-256: $($row.endpoint_id)"
            continue
        }
        $actualHash = (Get-FileHash -LiteralPath $fullLocalPath -Algorithm SHA256).Hash
        $script:Checks++
        if (-not $actualHash.Equals([string]$row.sha256, [System.StringComparison]::OrdinalIgnoreCase)) {
            Add-ValidationError "Endpoint local file SHA-256 mismatch: $($row.endpoint_id)"
        }
        if ($row.endpoint_type -eq 'local_pdf') {
            $pageCount = 0
            $script:Checks++
            if (-not [int]::TryParse([string]$row.page_count, [ref]$pageCount) -or $pageCount -le 0) {
                Add-ValidationError "Local PDF endpoint lacks positive page_count: $($row.endpoint_id)"
            }
        }
    }
}
if ($tableData.ContainsKey('最小参考资料库/source-screening.csv')) {
    $coverage = if ($tableData.ContainsKey('最小参考资料库/source-coverage.csv')) { @($tableData['最小参考资料库/source-coverage.csv']) } else { @() }
    foreach ($row in $tableData['最小参考资料库/source-screening.csv'] | Where-Object screening_status -eq 'redundant_covered') {
        $match = @($coverage | Where-Object { $_.covered_source_id -eq $row.source_id -and $_.equivalence_status -eq 'fully_covered' })
        $script:Checks++
        if ($match.Count -eq 0) { Add-ValidationError "Redundant source lacks full coverage: $($row.source_id)" }
    }
}

if ($tableData.ContainsKey('最小参考资料库/selection-runs.csv') -and $tableData.ContainsKey('最小参考资料库/selection-members.csv')) {
    $selectionRuns = @($tableData['最小参考资料库/selection-runs.csv'])
    $selectionMembers = @($tableData['最小参考资料库/selection-members.csv'])
    $screeningRows = if ($tableData.ContainsKey('最小参考资料库/source-screening.csv')) { @($tableData['最小参考资料库/source-screening.csv']) } else { @() }
    foreach ($run in $selectionRuns | Where-Object status -in @('reviewed','approved')) {
        $runMembers = @($selectionMembers | Where-Object selection_run_id -eq $run.selection_run_id)
        $script:Checks++
        if ($runMembers.Count -eq 0) { Add-ValidationError "Reviewed selection run has no members: $($run.selection_run_id)" }
        foreach ($member in $runMembers) {
            $script:Checks++
            if (Test-Empty $member.mandatory_reason) { Add-ValidationError "Selection member lacks mandatory reason: $($member.selection_member_id)" }
            $script:Checks++
            if (@($screeningRows | Where-Object { $_.source_id -eq $member.source_id -and $_.screening_status -eq 'selected' }).Count -eq 0) {
                Add-ValidationError "Selection member is not screened selected: $($member.selection_member_id)"
            }
        }
    }
}
if ($tableData.ContainsKey('数据/field-requirements.csv')) {
    $searchLog = if ($tableData.ContainsKey('最小参考资料库/search-log.csv')) { @($tableData['最小参考资料库/search-log.csv']) } else { @() }
    foreach ($row in $tableData['数据/field-requirements.csv']) {
        if ($row.requirement_status -eq 'not_found') {
            $script:Checks++
            if (@($searchLog | Where-Object requirement_id -eq $row.requirement_id).Count -eq 0) {
                Add-ValidationError "not_found requirement lacks search log: $($row.requirement_id)"
            }
        }
        if ($row.requirement_status -eq 'not_applicable') {
            $script:Checks++
            if (Test-Empty $row.applicability_reason) { Add-ValidationError "not_applicable lacks reason: $($row.requirement_id)" }
        }
    }
}

if ($tableData.ContainsKey('数据/derived-metrics.csv')) {
    $inputs = if ($tableData.ContainsKey('数据/derived-inputs.csv')) { @($tableData['数据/derived-inputs.csv']) } else { @() }
    foreach ($row in $tableData['数据/derived-metrics.csv']) {
        $script:Checks++
        if (@($inputs | Where-Object derived_fact_id -eq $row.derived_fact_id).Count -eq 0) {
            Add-ValidationError "Derived metric lacks input facts: $($row.derived_metric_id)"
        }
        foreach ($checkColumn in @('scope_check_status','precision_check_status','direction_check_status')) {
            if ($row.$checkColumn -ne 'passed') { Add-ValidationError "Derived metric check not passed: $($row.derived_metric_id).$checkColumn" }
        }
    }
}

if ($script:Errors.Count -gt 0) {
    Write-Output "FAIL: $($script:Errors.Count) validation error(s); $($script:Checks) checks executed."
    foreach ($message in $script:Errors) { Write-Output " - $message" }
    exit 1
}
Write-Output "PASS: 32-table research data model; $($script:Checks) checks executed."
Write-Output "Registry: $($schema.Count) columns, $($enumRows.Count) enum values."
exit 0