#Requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$RootPath)
$ErrorActionPreference = 'Stop'
$stage = Join-Path $RootPath '审计\子代理交接\m2_staging\M2-GHC-ARCH\structured'
$errors = [System.Collections.Generic.List[string]]::new()
$pairs = [ordered]@{
'components.csv'='数据\components.csv';'precision-paths.csv'='数据\precision-paths.csv';'memory-levels.csv'='数据\memory-levels.csv';'links.csv'='数据\links.csv';'topologies.csv'='数据\topologies.csv';'special-capabilities.csv'='数据\special-capabilities.csv';'condition-sets.csv'='数据\condition-sets.csv';'facts.csv'='数据\facts.csv';'field-requirements.csv'='数据\field-requirements.csv';'derived-metrics.csv'='数据\derived-metrics.csv';'derived-inputs.csv'='数据\derived-inputs.csv';'card-completeness.csv'='数据\card-completeness.csv';'source-families.csv'='最小参考资料库\source-families.csv';'sources.csv'='最小参考资料库\sources.csv';'source-endpoints.csv'='最小参考资料库\source-endpoints.csv';'fact-assertions.csv'='最小参考资料库\fact-assertions.csv';'requirement-evidence.csv'='最小参考资料库\requirement-evidence.csv';'source-screening.csv'='最小参考资料库\source-screening.csv';'source-selected-roles.csv'='最小参考资料库\source-selected-roles.csv';'source-coverage.csv'='最小参考资料库\source-coverage.csv';'search-log.csv'='最小参考资料库\search-log.csv';'search-results.csv'='最小参考资料库\search-results.csv';'conflict-groups.csv'='最小参考资料库\conflict-groups.csv';'conflict-members.csv'='最小参考资料库\conflict-members.csv'
}
foreach($name in $pairs.Keys){
  $stagePath=Join-Path $stage $name; $formalPath=Join-Path $RootPath $pairs[$name]
  if(-not(Test-Path -LiteralPath $stagePath)){ $errors.Add("Missing staged table: $name"); continue }
  $a=Get-Content -LiteralPath $stagePath -Encoding UTF8 -TotalCount 1
  $b=Get-Content -LiteralPath $formalPath -Encoding UTF8 -TotalCount 1
  if($a -cne $b){ $errors.Add("Header mismatch: $name") }
}
$pk=[ordered]@{'components.csv'='component_id';'precision-paths.csv'='precision_path_id';'memory-levels.csv'='memory_level_id';'links.csv'='link_id';'topologies.csv'='topology_id';'special-capabilities.csv'='capability_id';'condition-sets.csv'='condition_set_id';'facts.csv'='fact_id';'field-requirements.csv'='requirement_id';'card-completeness.csv'='card_completeness_id';'source-families.csv'='source_family_id';'sources.csv'='source_id';'source-endpoints.csv'='endpoint_id';'fact-assertions.csv'='assertion_id';'requirement-evidence.csv'='requirement_evidence_id';'source-screening.csv'='screening_id';'source-selected-roles.csv'='source_selected_role_id';'source-coverage.csv'='coverage_id';'search-log.csv'='search_id';'search-results.csv'='search_result_id'}
foreach($name in $pk.Keys){
  $rows=@(Import-Csv -LiteralPath (Join-Path $stage $name) -Encoding UTF8); $col=$pk[$name]
  if(@($rows|Where-Object { [string]::IsNullOrWhiteSpace([string]$_.$col) }).Count){$errors.Add("Empty PK: $name")}
  if(@($rows|Group-Object $col|Where-Object Count -gt 1).Count){$errors.Add("Duplicate PK: $name")}
  $formalIds=@((Import-Csv -LiteralPath (Join-Path $RootPath $pairs[$name]) -Encoding UTF8).$col)
  foreach($row in $rows){if($row.$col -in $formalIds){$errors.Add("Temporary merge PK collision: $name $($row.$col)")}}
}
$targets=@('object_id','component_id','link_id','object_relation_id','precision_path_id','capability_id','topology_id')
foreach($row in @((Import-Csv -LiteralPath (Join-Path $stage 'facts.csv') -Encoding UTF8))+@((Import-Csv -LiteralPath (Join-Path $stage 'field-requirements.csv') -Encoding UTF8))){
  if(@($targets|Where-Object {$row.$_}).Count -ne 1){$id=if($row.fact_id){$row.fact_id}else{$row.requirement_id};$errors.Add("Seven-target XOR: $id")}
}
foreach($row in Import-Csv -LiteralPath (Join-Path $stage 'facts.csv') -Encoding UTF8){
  if((@($row.normalized_value_text,$row.normalized_value_number)|Where-Object {$_}).Count -ne 1){$errors.Add("Fact value XOR: $($row.fact_id)")}
}
$schemaRows=@(Import-Csv -LiteralPath (Join-Path $RootPath '数据\schema-columns.csv') -Encoding UTF8)
$enumRows=@(Import-Csv -LiteralPath (Join-Path $RootPath '数据\enums.csv') -Encoding UTF8)
$enumMap=@{}
foreach($group in $enumRows|Group-Object enum_name){$enumMap[$group.Name]=@($group.Group.enum_value)}
foreach($group in $schemaRows|Group-Object table_path){
  $name=Split-Path $group.Name -Leaf; $stagePath=Join-Path $stage $name
  if(-not(Test-Path -LiteralPath $stagePath)){continue}
  $rows=@(Import-Csv -LiteralPath $stagePath -Encoding UTF8)
  foreach($column in $group.Group){
    foreach($row in $rows){
      $value=[string]$row.($column.column_name)
      if($column.is_nullable -eq 'false' -and [string]::IsNullOrWhiteSpace($value)){$errors.Add("Required value missing: $name.$($column.column_name)")}
      if($column.semicolon_forbidden -eq 'true' -and $value.Contains(';')){$errors.Add("Semicolon forbidden: $name.$($column.column_name)")}
      if($column.enum_name -and $value -and $value -notin $enumMap[$column.enum_name]){$errors.Add("Invalid enum ${value}: $name.$($column.column_name)")}
      if($column.foreign_table_path -and $value){
        $foreignFormal=Join-Path $RootPath ($column.foreign_table_path.Replace('/','\'))
        $refs=@((Import-Csv -LiteralPath $foreignFormal -Encoding UTF8).($column.foreign_column_name))
        $foreignStage=Join-Path $stage (Split-Path $column.foreign_table_path -Leaf)
        if(Test-Path -LiteralPath $foreignStage){$refs+=@((Import-Csv -LiteralPath $foreignStage -Encoding UTF8).($column.foreign_column_name))}
        if($value -notin $refs){$errors.Add("Broken FK ${value}: $name.$($column.column_name)")}
      }
    }
  }
}$notFound=@(Import-Csv -LiteralPath (Join-Path $stage 'field-requirements.csv') -Encoding UTF8|Where-Object requirement_status -eq 'not_found')
$searched=@((Import-Csv -LiteralPath (Join-Path $stage 'search-log.csv') -Encoding UTF8).requirement_id)
foreach($row in $notFound){if($row.requirement_id -notin $searched){$errors.Add("not_found lacks search log: $($row.requirement_id)")}}
if($errors.Count){$errors|ForEach-Object {Write-Error $_};exit 1}
Write-Output 'M2-GHC-ARCH staging validation passed: headers, required values, PK, temporary-merge collision, FK, enums, semicolon rules, seven-target XOR, fact-value XOR, and not_found search-log checks.'
