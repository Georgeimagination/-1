param(
    [string]$RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
)

$ErrorActionPreference = 'Stop'
$stagingPath = $PSScriptRoot
$schemaPath = Join-Path $RootPath '数据\schema-columns.csv'
$enumPath = Join-Path $RootPath '数据\enums.csv'
$errors = New-Object System.Collections.Generic.List[string]
$checks = 0

function Add-Check { $script:checks++ }
function Add-Error([string]$message) { $script:errors.Add($message) }
function Is-Blank($value) { return [string]::IsNullOrWhiteSpace([string]$value) }

$schema = Import-Csv -Encoding UTF8 -LiteralPath $schemaPath
$enums = Import-Csv -Encoding UTF8 -LiteralPath $enumPath
$csvFiles = Get-ChildItem -LiteralPath $stagingPath -File -Filter '*.csv'
$tableData = @{}
$tableSchemas = @{}

foreach ($file in $csvFiles) {
    $matchingPaths = @($schema.table_path | Where-Object { (Split-Path $_ -Leaf) -eq $file.Name } | Sort-Object -Unique)
    Add-Check
    if ($matchingPaths.Count -ne 1) {
        Add-Error "Cannot map staging file to exactly one formal table: $($file.Name)"
        continue
    }
    $tablePath = $matchingPaths[0]
    $tableSchema = @($schema | Where-Object table_path -eq $tablePath | Sort-Object { [int]$_.ordinal })
    $rows = @(Import-Csv -Encoding UTF8 -LiteralPath $file.FullName)
    Add-Check
    if ($rows.Count -eq 0) {
        Add-Error "Staging table has no data rows: $($file.Name)"
        continue
    }
    $actualHeaders = @($rows[0].PSObject.Properties.Name)
    $expectedHeaders = @($tableSchema.column_name)
    Add-Check
    if (($actualHeaders -join '|') -ne ($expectedHeaders -join '|')) {
        Add-Error "Header mismatch: $($file.Name)"
    }
    $tableData[$tablePath] = $rows
    $tableSchemas[$tablePath] = $tableSchema
}

$allIds = [System.Collections.Generic.Dictionary[string,string]]::new()
foreach ($tablePath in $tableData.Keys) {
    $tableSchema = $tableSchemas[$tablePath]
    $pk = @($tableSchema | Where-Object is_primary_key -eq 'true')
    Add-Check
    if ($pk.Count -ne 1) {
        Add-Error "Expected one primary key in $tablePath"
        continue
    }
    $pkName = $pk[0].column_name
    $globalPath = Join-Path $RootPath ($tablePath -replace '/', '\')
    $globalRows = if (Test-Path -LiteralPath $globalPath) { @(Import-Csv -Encoding UTF8 -LiteralPath $globalPath) } else { @() }
    $globalValues = @($globalRows | ForEach-Object { $_.$pkName })
    $seen = @{}
    foreach ($row in $tableData[$tablePath]) {
        $id = [string]$row.$pkName
        Add-Check
        if (Is-Blank $id) { Add-Error "Blank primary key: $tablePath"; continue }
        Add-Check
        if ($id -notmatch '^[A-Z0-9-]+$') { Add-Error "Non-ASCII or noncanonical ID: $id" }
        Add-Check
        if ($seen.ContainsKey($id)) { Add-Error "Duplicate staging primary key: $id" } else { $seen[$id] = $true }
        Add-Check
        if ($globalValues -contains $id) { Add-Error "Staging ID already exists in global table: $id" }
        Add-Check
        $intentionalMemoryAlias = ($allIds.ContainsKey($id) -and (($tablePath -eq '数据/memory-levels.csv' -and $allIds[$id] -eq '数据/components.csv') -or ($tablePath -eq '数据/components.csv' -and $allIds[$id] -eq '数据/memory-levels.csv')))
        if ($allIds.ContainsKey($id) -and -not $intentionalMemoryAlias) { Add-Error "ID reused across staging tables: $id" } elseif (-not $allIds.ContainsKey($id)) { $allIds[$id] = $tablePath }
    }
}

function Get-CombinedValues([string]$foreignPath,[string]$columnName) {
    $values = New-Object System.Collections.Generic.List[string]
    $globalPath = Join-Path $RootPath ($foreignPath -replace '/', '\')
    if (Test-Path -LiteralPath $globalPath) {
        foreach ($row in @(Import-Csv -Encoding UTF8 -LiteralPath $globalPath)) {
            if (-not (Is-Blank $row.$columnName)) { $values.Add([string]$row.$columnName) }
        }
    }
    if ($tableData.ContainsKey($foreignPath)) {
        foreach ($row in $tableData[$foreignPath]) {
            if (-not (Is-Blank $row.$columnName)) { $values.Add([string]$row.$columnName) }
        }
    }
    return @($values)
}

foreach ($tablePath in $tableData.Keys) {
    foreach ($column in $tableSchemas[$tablePath]) {
        if (-not (Is-Blank $column.enum_name)) {
            $allowed = @($enums | Where-Object enum_name -eq $column.enum_name | ForEach-Object enum_value)
            foreach ($row in $tableData[$tablePath]) {
                $value = [string]$row.($column.column_name)
                if (Is-Blank $value) { continue }
                Add-Check
                if ($allowed -notcontains $value) { Add-Error "Invalid enum $tablePath.$($column.column_name): $value" }
            }
        }
        if (-not (Is-Blank $column.foreign_table_path)) {
            $allowedFk = @(Get-CombinedValues $column.foreign_table_path $column.foreign_column_name)
            foreach ($row in $tableData[$tablePath]) {
                $value = [string]$row.($column.column_name)
                if (Is-Blank $value) { continue }
                Add-Check
                if ($allowedFk -notcontains $value) { Add-Error "Broken FK $tablePath.$($column.column_name): $value" }
            }
        }
        if ($column.semicolon_forbidden -eq 'true') {
            foreach ($row in $tableData[$tablePath]) {
                Add-Check
                if ([string]$row.($column.column_name) -match ';') { Add-Error "Semicolon-forbidden FK contains semicolon: $tablePath.$($column.column_name)" }
            }
        }
        foreach ($row in $tableData[$tablePath]) {
            if ($column.is_nullable -eq 'false') {
                Add-Check
                if (Is-Blank $row.($column.column_name)) { Add-Error "Required value missing: $tablePath.$($column.column_name)" }
            }
            $value = [string]$row.($column.column_name)
            if (Is-Blank $value) { continue }
            if ($column.data_type -eq 'number') {
                $parsed = 0.0
                Add-Check
                if (-not [double]::TryParse($value,[Globalization.NumberStyles]::Float,[Globalization.CultureInfo]::InvariantCulture,[ref]$parsed)) { Add-Error "Invalid number: $tablePath.$($column.column_name)=$value" }
            }
            if ($column.data_type -eq 'integer') {
                $parsedInt = 0
                Add-Check
                if (-not [int]::TryParse($value,[ref]$parsedInt)) { Add-Error "Invalid integer: $tablePath.$($column.column_name)=$value" }
            }
            if ($column.data_type -eq 'date') {
                Add-Check
                if ($value -notmatch '^\d{4}-\d{2}-\d{2}$') { Add-Error "Date is not ISO YYYY-MM-DD: $tablePath.$($column.column_name)=$value" }
            }
        }
    }
}

$targetColumns = @('object_id','component_id','link_id','object_relation_id','precision_path_id','capability_id','topology_id')
foreach ($tablePath in @('数据/facts.csv','数据/field-requirements.csv')) {
    if (-not $tableData.ContainsKey($tablePath)) { continue }
    foreach ($row in $tableData[$tablePath]) {
        $count = @($targetColumns | Where-Object { -not (Is-Blank $row.$_) }).Count
        Add-Check
        if ($count -ne 1) { Add-Error "Exactly one target required: $tablePath $($row.PSObject.Properties[0].Value)" }
    }
}

if ($tableData.ContainsKey('数据/facts.csv')) {
    foreach ($row in $tableData['数据/facts.csv']) {
        $hasText = -not (Is-Blank $row.normalized_value_text)
        $hasNumber = -not (Is-Blank $row.normalized_value_number)
        Add-Check
        if ($hasText -eq $hasNumber) { Add-Error "Fact value XOR failed: $($row.fact_id)" }
    }
}
if ($tableData.ContainsKey('最小参考资料库/fact-assertions.csv')) {
    foreach ($row in $tableData['最小参考资料库/fact-assertions.csv']) {
        $hasText = -not (Is-Blank $row.raw_value_text)
        $hasNumber = -not (Is-Blank $row.raw_value_number)
        Add-Check
        if ($hasText -eq $hasNumber) { Add-Error "Assertion value XOR failed: $($row.assertion_id)" }
        Add-Check
        if (Is-Blank $row.source_locator) { Add-Error "Assertion locator missing: $($row.assertion_id)" }
    }
}
if ($tableData.ContainsKey('数据/field-requirements.csv')) {
    $searchRows = if ($tableData.ContainsKey('最小参考资料库/search-log.csv')) { @($tableData['最小参考资料库/search-log.csv']) } else { @() }
    foreach ($row in $tableData['数据/field-requirements.csv'] | Where-Object requirement_status -eq 'not_found') {
        Add-Check
        if (@($searchRows | Where-Object requirement_id -eq $row.requirement_id).Count -eq 0) { Add-Error "not_found requirement lacks search log: $($row.requirement_id)" }
    }
}
if ($tableData.ContainsKey('最小参考资料库/source-screening.csv')) {
    $coverageRows = if ($tableData.ContainsKey('最小参考资料库/source-coverage.csv')) { @($tableData['最小参考资料库/source-coverage.csv']) } else { @() }
    foreach ($row in $tableData['最小参考资料库/source-screening.csv'] | Where-Object screening_status -eq 'redundant_covered') {
        Add-Check
        if (@($coverageRows | Where-Object covered_source_id -eq $row.source_id).Count -eq 0) { Add-Error "redundant_covered source lacks coverage row: $($row.source_id)" }
    }
}
if ($tableData.ContainsKey('数据/derived-metrics.csv')) {
    $inputRows = @($tableData['数据/derived-inputs.csv'])
    foreach ($row in $tableData['数据/derived-metrics.csv']) {
        Add-Check
        if (@($inputRows | Where-Object derived_fact_id -eq $row.derived_fact_id).Count -lt 2) { Add-Error "Derived metric lacks two inputs: $($row.derived_metric_id)" }
        foreach ($column in @('scope_check_status','precision_check_status','direction_check_status')) {
            Add-Check
            if ($row.$column -ne 'passed') { Add-Error "Derived metric check is not passed: $($row.derived_metric_id).$column" }
        }
    }
}
if ($tableData.ContainsKey('数据/facts.csv')) {
    $assertionRows = @($tableData['最小参考资料库/fact-assertions.csv'])
    foreach ($row in $tableData['数据/facts.csv'] | Where-Object fact_kind -ne 'derived') {
        Add-Check
        if (@($assertionRows | Where-Object fact_id -eq $row.fact_id).Count -eq 0) { Add-Error "Direct fact lacks assertion: $($row.fact_id)" }
    }
}

foreach ($file in Get-ChildItem -LiteralPath $stagingPath -File) {
    if ($file.Extension -notin @('.csv','.md','.ps1')) { continue }
    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName
    Add-Check
    if ($content.Contains([char]0xFFFD)) { Add-Error "UTF-8 replacement character found: $($file.Name)" }
}

if ($errors.Count -gt 0) {
    Write-Host "FAIL: $($errors.Count) errors after $checks checks" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host " - $_" }
    exit 1
}
Write-Host "PASS: $checks checks across $($csvFiles.Count) staging tables" -ForegroundColor Green
exit 0