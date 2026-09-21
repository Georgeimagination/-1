#Requires -Version 5.1
[CmdletBinding()]
param([string]$RootPath)
Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
if ([string]::IsNullOrWhiteSpace($RootPath)) {
  $RootPath=Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}
$root=(Resolve-Path -LiteralPath $RootPath).Path
function Read-Table([string]$Relative){ @(Import-Csv -LiteralPath (Join-Path $root $Relative) -Encoding UTF8) }
function Fail([string]$Message){ throw $Message }
$objects=Read-Table '数据/objects.csv'
$scope=Read-Table '审计/训练推理芯片主线对象范围.csv'
if($scope.Count -ne $objects.Count){ Fail "Scope registry/object count differs: $($scope.Count)/$($objects.Count)" }
if(@($scope.object_id|Sort-Object -Unique).Count -ne $scope.Count){ Fail 'Scope registry contains duplicate object_id.' }
$objectById=@{}; foreach($o in $objects){$objectById[$o.object_id]=$o}
$scopeById=@{}; foreach($s in $scope){$scopeById[$s.object_id]=$s}
foreach($o in $objects){
  if(-not $scopeById.ContainsKey($o.object_id)){Fail "Object missing from scope registry: $($o.object_id)"}
  $s=$scopeById[$o.object_id]
  if($s.object_type -cne $o.object_type){Fail "Object type differs in scope registry: $($o.object_id)"}
  $expected=if($o.object_type -in @('die','package')){'chip_primary'}elseif($o.object_type -ceq 'architecture_generation'){'architecture_evidence'}else{'out_of_scope_nonchip'}
  if($s.scope_class -cne $expected){Fail "Scope class differs from DEC-031: $($o.object_id)"}
  $expectedCoverage=if($expected -ceq 'chip_primary'){'true'}else{'false'}
  if($s.counts_toward_chip_coverage -cne $expectedCoverage){Fail "Coverage flag differs: $($o.object_id)"}
  if($s.decision_id -cne 'DEC-031'){Fail "Decision binding differs: $($o.object_id)"}
}
foreach($s in $scope){if(-not $objectById.ContainsKey($s.object_id)){Fail "Unknown object in scope registry: $($s.object_id)"}}
$components=Read-Table '数据/components.csv'; $componentOwner=@{}; foreach($x in $components){$componentOwner[$x.component_id]=$x.owner_object_id}
$links=Read-Table '数据/links.csv'; $linkOwner=@{}; foreach($x in $links){$linkOwner[$x.link_id]=$x.owner_object_id}
$relations=Read-Table '数据/object-relations.csv'; $relationOwner=@{}; foreach($x in $relations){$relationOwner[$x.object_relation_id]=$x.subject_object_id}
$paths=Read-Table '数据/precision-paths.csv'; $pathOwner=@{}; foreach($x in $paths){if(-not $componentOwner.ContainsKey($x.component_id)){Fail "Precision path component missing: $($x.precision_path_id)"};$pathOwner[$x.precision_path_id]=$componentOwner[$x.component_id]}
$caps=Read-Table '数据/special-capabilities.csv'; $capOwner=@{}; foreach($x in $caps){$capOwner[$x.capability_id]=$x.owner_object_id}
$topos=Read-Table '数据/topologies.csv'; $topoOwner=@{}; foreach($x in $topos){$topoOwner[$x.topology_id]=$x.owner_object_id}
function Resolve-Owner($row){
  if(-not [string]::IsNullOrWhiteSpace($row.object_id)){return $row.object_id}
  if(-not [string]::IsNullOrWhiteSpace($row.component_id)){return $componentOwner[$row.component_id]}
  if(-not [string]::IsNullOrWhiteSpace($row.link_id)){return $linkOwner[$row.link_id]}
  if(-not [string]::IsNullOrWhiteSpace($row.object_relation_id)){return $relationOwner[$row.object_relation_id]}
  if(-not [string]::IsNullOrWhiteSpace($row.precision_path_id)){return $pathOwner[$row.precision_path_id]}
  if(-not [string]::IsNullOrWhiteSpace($row.capability_id)){return $capOwner[$row.capability_id]}
  if(-not [string]::IsNullOrWhiteSpace($row.topology_id)){return $topoOwner[$row.topology_id]}
  return ''
}
function Count-By-Scope([object[]]$Rows,[string]$Label){
  $counts=@{chip_primary=0;architecture_evidence=0;out_of_scope_nonchip=0}
  foreach($row in $Rows){$owner=Resolve-Owner $row;if([string]::IsNullOrWhiteSpace($owner)){Fail "$Label row has no resolvable owner."};if(-not $scopeById.ContainsKey($owner)){Fail "$Label owner absent from scope registry: $owner"};$counts[$scopeById[$owner].scope_class]++}
  return $counts
}
$facts=Read-Table '数据/facts.csv'; $requirements=Read-Table '数据/field-requirements.csv'
$factCounts=Count-By-Scope $facts 'Fact'; $requirementCounts=Count-By-Scope $requirements 'Requirement'
$selectionRuns=Read-Table '最小参考资料库/selection-runs.csv'; $selectionScope=Read-Table '审计/训练推理芯片主线选择运行范围.csv'
if($selectionRuns.Count -ne $selectionScope.Count){Fail "Selection scope/run count differs: $($selectionScope.Count)/$($selectionRuns.Count)"}
if(@($selectionScope.selection_run_id|Sort-Object -Unique).Count -ne $selectionScope.Count){Fail 'Selection scope registry contains duplicate selection_run_id.'}
$selectionIds=@($selectionRuns.selection_run_id|Sort-Object); $selectionScopeIds=@($selectionScope.selection_run_id|Sort-Object)
if(($selectionIds -join [char]31) -cne ($selectionScopeIds -join [char]31)){Fail 'Selection scope registry does not match formal selection runs.'}
foreach($s in $selectionScope){if($s.decision_id -cne 'DEC-031'){Fail "Selection decision binding differs: $($s.selection_run_id)"};if($s.scope_class -notin @('chip_primary','architecture_evidence','mixed_needs_split','out_of_scope_nonchip','historical_superseded')){Fail "Invalid selection scope class: $($s.selection_run_id)"}}
$result=[ordered]@{
 status='passed'; decision_id='DEC-031'; objects=$objects.Count
 chip_primary_objects=@($scope|Where-Object scope_class -ceq 'chip_primary').Count
 architecture_evidence_objects=@($scope|Where-Object scope_class -ceq 'architecture_evidence').Count
 out_of_scope_objects=@($scope|Where-Object scope_class -ceq 'out_of_scope_nonchip').Count
 selection_runs=[ordered]@{chip_primary=@($selectionScope|Where-Object scope_class -ceq 'chip_primary').Count;architecture_evidence=@($selectionScope|Where-Object scope_class -ceq 'architecture_evidence').Count;mixed_needs_split=@($selectionScope|Where-Object scope_class -ceq 'mixed_needs_split').Count;out_of_scope_nonchip=@($selectionScope|Where-Object scope_class -ceq 'out_of_scope_nonchip').Count;historical_superseded=@($selectionScope|Where-Object scope_class -ceq 'historical_superseded').Count}
 facts=[ordered]@{chip_primary=$factCounts.chip_primary;architecture_evidence=$factCounts.architecture_evidence;out_of_scope_nonchip=$factCounts.out_of_scope_nonchip}
 requirements=[ordered]@{chip_primary=$requirementCounts.chip_primary;architecture_evidence=$requirementCounts.architecture_evidence;out_of_scope_nonchip=$requirementCounts.out_of_scope_nonchip}
}
$result|ConvertTo-Json -Depth 4
Write-Host 'PASS: chip-only research scope registry is complete and internally consistent.'
