#Requires -Version 5.1
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$SourceRoot,
  [Parameter(Mandatory=$true)][string]$TargetRoot,
  [string]$WorkRoot='',
  [string]$UpstreamBindingsPath=''
)
Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$Utf8NoBom=New-Object Text.UTF8Encoding($false)
$ExpectedFormalAggregate='f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedCandidateAggregate='5f62191bfc737535802cd6e0524b1fdf7a742ca36300db11b5a9233d4540052a'
$ExpectedValidatorChecks=125619
$ExpectedFormalManifestSha='c8c424fa21838248cca020b6c5feefd9c05287adec8c077474f0f36cff834f5f'
$ExpectedWriteSetSha='0e1ad812779656e1e9f325317f87f0bb7de8edaa161475a421aa251b4058feb1'
$ExpectedNewFilesSha='0adc897a424712c254979c0cca9f2fef2624ca3779d1a1fa82e9436a9981cc0d'
$ExpectedGuardsSha='327b884efc6e0c3bc43539d03e0e27a269c3c8d16696967a3635e906cf9ce604'
$ExpectedBackupsSha='c2aa9ed5d15c591d60bbd39f5457a4a69c2cb7f7871680ebcf8c7d2ec0703b91'
$ExpectedPosthashManifestSha='78956df9394146d39ded5e6e0740157e4ccd9cc50e44699ec6f8b8eca0ea1394'
$ExpectedUpstream=@{
  'MI455X'=[ordered]@{package_order=1;data_signoff_sha256='196863031761221d825309387c563553187b0ee23630002aeaeed57bbbd6084c';data_signoff_rows=245;prep_manifest_sha256='c679151bd00a1bc02ffe05c4a011c2e0532df095648eab2e40b9336c5aac783f';prep_aggregate_sha256='dc0a476e4d155df21bcb9a2f9c3bbec43060f027da129ef235b58150b802b23c';write_set_sha256='c011bd0b95cbd23a2bfe240d1a31a5011ad806c84db273d74561e9859c39d588';new_files_sha256='02a05ad2f26dcd744d359ddb02c5953f8836532aea60a47a91b79fd2a2716e7e';guards_sha256='31072225a6ed2355e3933634c34134c05a0de205307544ec40e04c5c1707f17d';transaction_signoff_sha256='f4b27f7c64dde754431872720f270dbccbc975ee39db9487f3403e8c229049ea';write_rows=242;payloads=3;guards=3}
  'MI350P'=[ordered]@{package_order=2;data_signoff_sha256='74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1';data_signoff_rows=274;prep_manifest_sha256='c21612350bae17288e365d26f95b5f669426ba99fd33cefce746644986cb3c98';prep_aggregate_sha256='e7138b42baee6b2d138cb5d8f31593c4f6c62319fa16688e866b840d2e419949';write_set_sha256='f2f92876b801d5bc98f0e7540010c595070a8f1103039d763d32672f3bdcb801';new_files_sha256='483f458ad8f65602c9ac8acc191d743b8bad65790488e3a0db6dbce05da4a0fd';guards_sha256='1a979d0ce56346c456e1e4f372ffe92b4800c15dba724944de57242a7522e28c';transaction_signoff_sha256='788beb80ca67c6dbf84a4ef949247bbe161240a028206151fbf0d7189104eaf3';write_rows=270;payloads=4;guards=3}
  'ASCEND950'=[ordered]@{package_order=3;data_signoff_sha256='0f59aa2fd893473eb1002d44816e16ace6b204259ac94e802b5f00774ea0cbd5';data_signoff_rows=553;prep_manifest_sha256='91af02c00a0e75854473503628ba49c4c3b062ffaca25199486cdb01fcb7c316';prep_aggregate_sha256='a83dc6f86c06dc44daa70a76525f2ea2dc3e4047eca1e3b15bea09245f42d418';write_set_sha256='2c9486c5090f9cb36a27bdf796143571ce3ab9937f5d41d6e6e134ad6937b455';new_files_sha256='e5c03bcabb8d6d352a2c5329339de1a04ba7456789bfcd660b623abb16e5339a';guards_sha256='8d4baa773a958e9df13e93c9e8b52c12f85c721b4da750098629241bd0ceb445';transaction_signoff_sha256='b40f064127a7ac2c5e8de9b4728501381974b661373e9cf5c2dd46954dde2394';write_rows=545;payloads=8;guards=5}
}
$Checks=0
function Fail([string]$Message){throw $Message}
function Assert-Check([bool]$Condition,[string]$Message){$script:Checks++;if(-not$Condition){Fail $Message}}
function Get-Sha256([string]$Path){return(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-TextSha256([string]$Text){$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($Utf8NoBom.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$a.Dispose()}}
function Get-ChildPath([string]$Root,[string]$RelativePath,[bool]$MustExist=$true){$r=[IO.Path]::GetFullPath($Root).TrimEnd('\');$p=[IO.Path]::GetFullPath((Join-Path $r ($RelativePath.Replace('/','\'))));if(-not$p.StartsWith($r+'\',[StringComparison]::OrdinalIgnoreCase)){Fail "Path escapes root: $RelativePath"};if($MustExist-and-not (Test-Path -LiteralPath $p -PathType Leaf)){Fail "Missing file: $p"};return $p}
function Get-CanonicalRowSha256([object]$Row){return Get-TextSha256 (@($Row|ConvertTo-Csv -NoTypeInformation)-join[char]10)}
function Get-FormalAggregate([string]$Root,[object[]]$Manifest){$parts=foreach($e in($Manifest|Sort-Object relative_path)){[string]$e.relative_path+'|'+(Get-Sha256(Get-ChildPath $Root ([string]$e.relative_path)))};return Get-TextSha256($parts-join[char]10)}
function Get-PackageAggregate([string]$PrepRoot,[object[]]$Manifest){$parts=[Collections.Generic.List[string]]::new();foreach($e in($Manifest|Sort-Object relative_path)){Assert-Check ($e.in_aggregate -in @('true','false')) "Invalid manifest aggregate flag: $($e.relative_path)";$p=Get-ChildPath $PrepRoot ([string]$e.relative_path);Assert-Check((Get-Sha256 $p) -ceq [string]$e.sha256) "Upstream prep member hash differs: $($e.relative_path)";Assert-Check((Get-Item -LiteralPath $p).Length -eq [int64]$e.bytes) "Upstream prep member bytes differ: $($e.relative_path)";if($e.in_aggregate -ceq 'true'){$parts.Add([string]$e.relative_path+'|'+[string]$e.sha256+'|'+[string]$e.bytes)}};return Get-TextSha256($parts.ToArray()-join[char]10)}
$SourceRoot=(Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
$TargetRoot=(Resolve-Path -LiteralPath $TargetRoot).Path.TrimEnd('\')
if([string]::IsNullOrWhiteSpace($WorkRoot)){$WorkRoot=Split-Path -Parent $PSScriptRoot}
$WorkRoot=(Resolve-Path -LiteralPath $WorkRoot).Path.TrimEnd('\')
if([string]::IsNullOrWhiteSpace($UpstreamBindingsPath)){$UpstreamBindingsPath=Join-Path $WorkRoot 'upstream-bindings.csv'}
$UpstreamBindingsPath=(Resolve-Path -LiteralPath $UpstreamBindingsPath).Path
$formalManifest=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'formal-32-baseline.csv') -Encoding UTF8)
$writeSet=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'authorized-write-set.csv') -Encoding UTF8)
$newFiles=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'new-file-targets.csv') -Encoding UTF8)
$guards=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'no-write-guards.csv') -Encoding UTF8)
$backups=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'formal-csv-backup-candidates.csv') -Encoding UTF8)
$posthash=@(Import-Csv -LiteralPath (Join-Path $WorkRoot 'expected-candidate-20-table-posthashes.csv') -Encoding UTF8)
$bindings=@(Import-Csv -LiteralPath $UpstreamBindingsPath -Encoding UTF8)
Assert-Check((Get-Sha256 (Join-Path $WorkRoot 'formal-32-baseline.csv')) -ceq $ExpectedFormalManifestSha)'Formal baseline manifest hash differs.'
Assert-Check((Get-Sha256 (Join-Path $WorkRoot 'authorized-write-set.csv')) -ceq $ExpectedWriteSetSha)'Bundle write-set hash differs.'
Assert-Check((Get-Sha256 (Join-Path $WorkRoot 'new-file-targets.csv')) -ceq $ExpectedNewFilesSha)'Bundle payload manifest hash differs.'
Assert-Check((Get-Sha256 (Join-Path $WorkRoot 'no-write-guards.csv')) -ceq $ExpectedGuardsSha)'Bundle guard manifest hash differs.'
Assert-Check((Get-Sha256 (Join-Path $WorkRoot 'formal-csv-backup-candidates.csv')) -ceq $ExpectedBackupsSha)'Bundle backup manifest hash differs.'
Assert-Check((Get-Sha256 (Join-Path $WorkRoot 'expected-candidate-20-table-posthashes.csv')) -ceq $ExpectedPosthashManifestSha)'Expected candidate posthash manifest hash differs.'
Assert-Check($formalManifest.Count -eq 32)'Formal manifest must contain 32 tables.'
Assert-Check($writeSet.Count -eq 1057)'Bundle write set must contain 1057 rows.'
Assert-Check($newFiles.Count -eq 15)'Bundle payload set must contain 15 rows.'
Assert-Check($guards.Count -eq 11)'Bundle guard set must contain 11 rows.'
Assert-Check($backups.Count -eq 20)'Bundle backup list must contain 20 write tables.'
Assert-Check($posthash.Count -eq 20)'Bundle posthash list must contain 20 write tables.'
Assert-Check($bindings.Count -eq 3)'Upstream bindings must contain three packages.'
Assert-Check(@($bindings.package|Sort-Object -Unique).Count -eq 3)'Upstream package names must be unique.'
$orderedBindings=@($bindings|Sort-Object {[int]$_.package_order})
$expectedPackageOrder=@('MI455X','MI350P','ASCEND950')
for($i=0;$i -lt $expectedPackageOrder.Count;$i++){
  Assert-Check([string]$orderedBindings[$i].package -ceq $expectedPackageOrder[$i]) "Upstream package identity/order differs at position $($i+1)."
  Assert-Check([int]$orderedBindings[$i].package_order -eq ($i+1)) "Upstream package_order differs: $($orderedBindings[$i].package)"
}
Assert-Check(@($writeSet|ForEach-Object{[string]$_.target_path+'|'+[string]$_.pk_column+'|'+[string]$_.pk_value}|Sort-Object -Unique).Count -eq 1057)'Bundle lifecycle keys must be unique.'
Assert-Check(@($newFiles.target_path|Sort-Object -Unique).Count -eq 15)'Bundle payload targets must be unique.'
Assert-Check(@($guards|ForEach-Object{[string]$_.target_path+'|'+[string]$_.pk_column+'|'+[string]$_.pk_value}|Sort-Object -Unique).Count -eq 11)'Bundle guard keys must be unique.'
Assert-Check(@($writeSet.target_path|Sort-Object -Unique).Count -eq 20)'Bundle write tables must be unique and total 20.'
$backupByTarget=@{}
foreach($b in $backups){
  Assert-Check(-not $backupByTarget.ContainsKey([string]$b.target_path)) "Duplicate backup target: $($b.target_path)"
  $backupByTarget[[string]$b.target_path]=$b
}
$posthashByTarget=@{}
foreach($p in $posthash){
  Assert-Check(-not $posthashByTarget.ContainsKey([string]$p.target_path)) "Duplicate posthash target: $($p.target_path)"
  $posthashByTarget[[string]$p.target_path]=$p
}
$writeTargetSet=@($writeSet.target_path|Sort-Object -Unique)
$backupTargetSet=@($backups.target_path|Sort-Object -Unique)
$posthashTargetSet=@($posthash.target_path|Sort-Object -Unique)
Assert-Check(($writeTargetSet -join [char]10) -ceq ($backupTargetSet -join [char]10))'Write-set and backup target sets differ.'
Assert-Check(($writeTargetSet -join [char]10) -ceq ($posthashTargetSet -join [char]10))'Write-set and posthash target sets differ.'
foreach($package in $expectedPackageOrder){
  $contract=$ExpectedUpstream[$package]
  Assert-Check(@($writeSet|Where-Object {[string]$_.package -ceq $package}).Count -eq [int]$contract.write_rows) "Bundle write count differs for $package."
  Assert-Check(@($newFiles|Where-Object {[string]$_.package -ceq $package}).Count -eq [int]$contract.payloads) "Bundle payload count differs for $package."
  Assert-Check(@($guards|Where-Object {[string]$_.package -ceq $package}).Count -eq [int]$contract.guards) "Bundle guard count differs for $package."
}
for($i=0;$i -lt $expectedPackageOrder.Count;$i++){
  for($j=$i+1;$j -lt $expectedPackageOrder.Count;$j++){
    $leftPackage=$expectedPackageOrder[$i]
    $rightPackage=$expectedPackageOrder[$j]
    $rightWriteKeys=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach($r in($writeSet|Where-Object {[string]$_.package -ceq $rightPackage})){[void]$rightWriteKeys.Add([string]$r.target_path+'|'+[string]$r.pk_column+'|'+[string]$r.pk_value)}
    $writeIntersection=@($writeSet|Where-Object {[string]$_.package -ceq $leftPackage}|ForEach-Object {[string]$_.target_path+'|'+[string]$_.pk_column+'|'+[string]$_.pk_value}|Where-Object {$rightWriteKeys.Contains($_)})
    Assert-Check($writeIntersection.Count -eq 0) "Cross-package lifecycle PK intersection is nonzero: $leftPackage / $rightPackage."
    $rightPayloadPaths=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach($r in($newFiles|Where-Object {[string]$_.package -ceq $rightPackage})){[void]$rightPayloadPaths.Add([string]$r.target_path)}
    $payloadIntersection=@($newFiles|Where-Object {[string]$_.package -ceq $leftPackage}|ForEach-Object {[string]$_.target_path}|Where-Object {$rightPayloadPaths.Contains($_)})
    Assert-Check($payloadIntersection.Count -eq 0) "Cross-package payload path intersection is nonzero: $leftPackage / $rightPackage."
    $rightGuardKeys=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach($r in($guards|Where-Object {[string]$_.package -ceq $rightPackage})){[void]$rightGuardKeys.Add([string]$r.target_path+'|'+[string]$r.pk_column+'|'+[string]$r.pk_value)}
    $guardIntersection=@($guards|Where-Object {[string]$_.package -ceq $leftPackage}|ForEach-Object {[string]$_.target_path+'|'+[string]$_.pk_column+'|'+[string]$_.pk_value}|Where-Object {$rightGuardKeys.Contains($_)})
    Assert-Check($guardIntersection.Count -eq 0) "Cross-package guard PK intersection is nonzero: $leftPackage / $rightPackage."
  }
}
Assert-Check((Get-FormalAggregate $SourceRoot $formalManifest) -ceq $ExpectedFormalAggregate)'SourceRoot formal aggregate differs.'
Assert-Check((Get-FormalAggregate $TargetRoot $formalManifest) -ceq $ExpectedFormalAggregate)'TargetRoot formal aggregate differs.'
foreach($entry in $formalManifest){$source=Get-ChildPath $SourceRoot ([string]$entry.relative_path);$target=Get-ChildPath $TargetRoot ([string]$entry.relative_path);Assert-Check((Get-Sha256 $source) -ceq [string]$entry.sha256) "Source formal hash differs: $($entry.relative_path)";Assert-Check((Get-Sha256 $target) -ceq [string]$entry.sha256) "Target formal hash differs: $($entry.relative_path)";Assert-Check((Get-Item -LiteralPath $target).Length -eq [int64]$entry.bytes) "Target formal bytes differ: $($entry.relative_path)"}
$upstreamWriteKeys=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$upstreamPayloadKeys=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$upstreamGuardKeys=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$signoffFieldByPackage=@{MI455X='mi455x_signoff_sha256';MI350P='mi350p_signoff_sha256';ASCEND950='ascend950_signoff_sha256'}
foreach($binding in($bindings|Sort-Object{[int]$_.package_order})){
  Assert-Check($ExpectedUpstream.ContainsKey([string]$binding.package)) "Unexpected upstream package: $($binding.package)"
  $contract=$ExpectedUpstream[[string]$binding.package]
  Assert-Check([int]$binding.package_order -eq [int]$contract.package_order) "Upstream package order binding differs: $($binding.package)"
  Assert-Check([string]$binding.data_signoff_sha256 -ceq [string]$contract.data_signoff_sha256) "Data signoff expected hash binding differs: $($binding.package)"
  Assert-Check([int]$binding.data_signoff_rows -eq [int]$contract.data_signoff_rows) "Data signoff expected row binding differs: $($binding.package)"
  Assert-Check([string]$binding.upstream_prep_manifest_sha256 -ceq [string]$contract.prep_manifest_sha256) "Prep manifest expected hash binding differs: $($binding.package)"
  Assert-Check([string]$binding.upstream_prep_aggregate_sha256 -ceq [string]$contract.prep_aggregate_sha256) "Prep aggregate expected binding differs: $($binding.package)"
  Assert-Check([string]$binding.upstream_write_set_sha256 -ceq [string]$contract.write_set_sha256) "Upstream write-set expected hash binding differs: $($binding.package)"
  Assert-Check([string]$binding.upstream_new_files_sha256 -ceq [string]$contract.new_files_sha256) "Upstream payload expected hash binding differs: $($binding.package)"
  Assert-Check([string]$binding.upstream_guards_sha256 -ceq [string]$contract.guards_sha256) "Upstream guards expected hash binding differs: $($binding.package)"
  Assert-Check([string]$binding.transaction_signoff_sha256 -ceq [string]$contract.transaction_signoff_sha256) "Transaction signoff expected hash binding differs: $($binding.package)"
  Assert-Check([string]$binding.transaction_signoff_state -ceq 'accept_true_verified') "Upstream transaction signoff dependency is not satisfied: $($binding.package)"
  Assert-Check([string]$binding.formal_baseline_aggregate -ceq $ExpectedFormalAggregate) "Upstream baseline binding differs: $($binding.package)"
  $dataSignoff=Get-ChildPath $SourceRoot ([string]$binding.data_signoff_path)
  Assert-Check((Get-Sha256 $dataSignoff) -ceq [string]$binding.data_signoff_sha256) "Data signoff hash differs: $($binding.package)"
  Assert-Check(@(Import-Csv -LiteralPath $dataSignoff -Encoding UTF8).Count -eq [int]$binding.data_signoff_rows) "Data signoff row count differs: $($binding.package)"
  $prepRoot=Get-ChildPath $SourceRoot (([string]$binding.upstream_prep_path).TrimEnd('/')+'/manifest.csv')
  $prepRoot=Split-Path -Parent $prepRoot
  $prepManifestPath=Join-Path $prepRoot 'manifest.csv'
  Assert-Check((Get-Sha256 $prepManifestPath) -ceq [string]$binding.upstream_prep_manifest_sha256) "Prep manifest hash differs: $($binding.package)"
  $prepManifest=@(Import-Csv -LiteralPath $prepManifestPath -Encoding UTF8)
  Assert-Check((Get-PackageAggregate $prepRoot $prepManifest) -ceq [string]$binding.upstream_prep_aggregate_sha256) "Prep package aggregate differs: $($binding.package)"
  $upWrite=Join-Path $prepRoot 'authorized-write-set.csv';$upPayload=Join-Path $prepRoot 'new-file-targets.csv';$upGuard=Join-Path $prepRoot 'no-write-guards.csv'
  Assert-Check((Get-Sha256 $upWrite) -ceq [string]$binding.upstream_write_set_sha256) "Upstream write-set hash differs: $($binding.package)"
  Assert-Check((Get-Sha256 $upPayload) -ceq [string]$binding.upstream_new_files_sha256) "Upstream payload hash differs: $($binding.package)"
  Assert-Check((Get-Sha256 $upGuard) -ceq [string]$binding.upstream_guards_sha256) "Upstream guards hash differs: $($binding.package)"
  foreach($r in(Import-Csv -LiteralPath $upWrite -Encoding UTF8)){[void]$upstreamWriteKeys.Add([string]$binding.package+'|'+[string]$r.signoff_row_id+'|'+[string]$r.target_path+'|'+[string]$r.pk_column+'|'+[string]$r.pk_value)}
  foreach($r in(Import-Csv -LiteralPath $upPayload -Encoding UTF8)){[void]$upstreamPayloadKeys.Add([string]$binding.package+'|'+[string]$r.signoff_row_id+'|'+[string]$r.target_path)}
  foreach($r in(Import-Csv -LiteralPath $upGuard -Encoding UTF8)){[void]$upstreamGuardKeys.Add([string]$binding.package+'|'+[string]$r.guard_id+'|'+[string]$r.target_path+'|'+[string]$r.pk_column+'|'+[string]$r.pk_value)}
  $txSignoff=Get-ChildPath $SourceRoot ([string]$binding.transaction_signoff_path)
  Assert-Check((Get-Sha256 $txSignoff) -ceq [string]$binding.transaction_signoff_sha256) "Transaction signoff hash differs: $($binding.package)"
  $tx=@(Import-Csv -LiteralPath $txSignoff -Encoding UTF8)
  Assert-Check($tx.Count -eq 1) "Transaction signoff must have one row: $($binding.package)"
  Assert-Check([string]$tx[0].verdict -ceq 'accept') "Transaction signoff verdict differs: $($binding.package)"
  Assert-Check([string]$tx[0].ready_for_formal_execution -ceq 'true') "Transaction signoff readiness differs: $($binding.package)"
  Assert-Check([string]$tx[0].package_manifest_sha256 -ceq [string]$binding.upstream_prep_manifest_sha256) "Transaction signoff manifest binding differs: $($binding.package)"
  Assert-Check([string]$tx[0].package_aggregate_sha256 -ceq [string]$binding.upstream_prep_aggregate_sha256) "Transaction signoff aggregate binding differs: $($binding.package)"
  Assert-Check([string]$tx[0].formal_baseline_aggregate_sha256 -ceq $ExpectedFormalAggregate) "Transaction signoff baseline differs: $($binding.package)"
  $field=$signoffFieldByPackage[[string]$binding.package]
  Assert-Check([string]$tx[0].$field -ceq [string]$binding.data_signoff_sha256) "Transaction signoff data binding differs: $($binding.package)"
}
Assert-Check($upstreamWriteKeys.Count -eq 1057)'Upstream write-set union count differs.'
Assert-Check($upstreamPayloadKeys.Count -eq 15)'Upstream payload union count differs.'
Assert-Check($upstreamGuardKeys.Count -eq 11)'Upstream guard union count differs.'
foreach($r in $writeSet){
  $key=[string]$r.package+'|'+[string]$r.signoff_row_id+'|'+[string]$r.target_path+'|'+[string]$r.pk_column+'|'+[string]$r.pk_value
  Assert-Check($upstreamWriteKeys.Contains($key)) "Bundle write row is not in upstream union: $($r.bundle_row_id)"
  Assert-Check($backupByTarget.ContainsKey([string]$r.target_path)) "Bundle write target is not in backup manifest: $($r.bundle_row_id)"
  $backup=$backupByTarget[[string]$r.target_path]
  Assert-Check([string]$r.formal_premerge_sha256 -ceq [string]$backup.premerge_sha256) "Bundle row premerge hash differs: $($r.bundle_row_id)"
  Assert-Check([int64]$r.formal_premerge_bytes -eq [int64]$backup.premerge_bytes) "Bundle row premerge bytes differ: $($r.bundle_row_id)"
  $source=Get-ChildPath $SourceRoot ([string]$r.source_path)
  Assert-Check((Get-Sha256 $source) -ceq [string]$r.source_sha256) "Bundle source hash differs: $($r.bundle_row_id)"
  Assert-Check((Get-Item -LiteralPath $source).Length -eq [int64]$r.source_bytes) "Bundle source bytes differ: $($r.bundle_row_id)"
  $sourceRows=@(Import-Csv -LiteralPath $source -Encoding UTF8)
  Assert-Check(@($sourceRows|Where-Object{[string]$_.$([string]$r.pk_column) -ceq [string]$r.pk_value}).Count -eq 1) "Bundle source PK count differs: $($r.bundle_row_id)"
  $target=Get-ChildPath $TargetRoot ([string]$r.target_path)
  Assert-Check(@(Import-Csv -LiteralPath $target -Encoding UTF8|Where-Object{[string]$_.$([string]$r.pk_column) -ceq [string]$r.pk_value}).Count -eq 0) "Bundle target PK already exists: $($r.bundle_row_id)"
}
foreach($r in $newFiles){$key=[string]$r.package+'|'+[string]$r.bundle_payload_id.Substring(('BUNDLE-'+[string]$r.package+'-').Length)+'|'+[string]$r.target_path;Assert-Check($upstreamPayloadKeys.Contains($key)) "Bundle payload is not in upstream union: $($r.bundle_payload_id)";$source=Get-ChildPath $SourceRoot ([string]$r.source_path);Assert-Check((Get-Sha256 $source) -ceq [string]$r.source_sha256) "Payload source hash differs: $($r.bundle_payload_id)";Assert-Check((Get-Item -LiteralPath $source).Length -eq [int64]$r.source_bytes) "Payload source bytes differ: $($r.bundle_payload_id)";$target=Get-ChildPath $TargetRoot ([string]$r.target_path) $false;Assert-Check(-not (Test-Path -LiteralPath $target)) "Payload target exists: $($r.target_path)"}
foreach($r in $guards){$key=[string]$r.package+'|'+[string]$r.guard_id+'|'+[string]$r.target_path+'|'+[string]$r.pk_column+'|'+[string]$r.pk_value;Assert-Check($upstreamGuardKeys.Contains($key)) "Bundle guard is not in upstream union: $($r.bundle_guard_id)";$target=Get-ChildPath $TargetRoot ([string]$r.target_path);$rows=@(Import-Csv -LiteralPath $target -Encoding UTF8);$hit=@($rows|Where-Object{[string]$_.$([string]$r.pk_column) -ceq [string]$r.pk_value});Assert-Check($hit.Count -eq 1) "Guard PK count differs: $($r.bundle_guard_id)";Assert-Check((Get-CanonicalRowSha256 $hit[0]) -ceq [string]$r.canonical_row_sha256) "Guard canonical row differs: $($r.bundle_guard_id)"}
foreach($b in $backups){$target=Get-ChildPath $TargetRoot ([string]$b.target_path);Assert-Check((Get-Sha256 $target) -ceq [string]$b.premerge_sha256) "Backup target hash differs: $($b.target_path)";Assert-Check((Get-Item -LiteralPath $target).Length -eq [int64]$b.premerge_bytes) "Backup target bytes differ: $($b.target_path)"}
foreach($p in $posthash){
  Assert-Check($backupByTarget.ContainsKey([string]$p.target_path)) "Posthash target is not in backup manifest: $($p.target_path)"
  $backup=$backupByTarget[[string]$p.target_path]
  Assert-Check([string]$p.premerge_sha256 -ceq [string]$backup.premerge_sha256) "Posthash premerge hash differs: $($p.target_path)"
  Assert-Check([string]$p.candidate_postmerge_sha256 -cmatch '^[0-9a-f]{64}$') "Candidate postmerge hash is invalid: $($p.target_path)"
  Assert-Check([int64]$p.candidate_bytes -gt 0) "Candidate postmerge bytes are invalid: $($p.target_path)"
  Assert-Check([string]$p.formal_baseline_aggregate -ceq $ExpectedFormalAggregate) "Posthash baseline differs: $($p.target_path)"
  Assert-Check([string]$p.candidate_aggregate -ceq $ExpectedCandidateAggregate) "Posthash candidate aggregate differs: $($p.target_path)"
  Assert-Check([int]$p.validator_checks -eq $ExpectedValidatorChecks) "Posthash validator checks differ: $($p.target_path)"
  Assert-Check([string]$p.authorized_write_set_sha256 -ceq $ExpectedWriteSetSha) "Posthash write-set binding differs: $($p.target_path)"
  Assert-Check([string]$p.new_file_targets_sha256 -ceq $ExpectedNewFilesSha) "Posthash payload binding differs: $($p.target_path)"
  Assert-Check([string]$p.no_write_guards_sha256 -ceq $ExpectedGuardsSha) "Posthash guard binding differs: $($p.target_path)"
}
$candidateParts=foreach($entry in($formalManifest|Sort-Object relative_path)){
  $candidateHash=[string]$entry.sha256
  if($posthashByTarget.ContainsKey([string]$entry.relative_path)){$candidateHash=[string]$posthashByTarget[[string]$entry.relative_path].candidate_postmerge_sha256}
  [string]$entry.relative_path+'|'+$candidateHash
}
Assert-Check((Get-TextSha256 ($candidateParts -join [char]10)) -ceq $ExpectedCandidateAggregate)'Expected candidate posthashes do not reconstruct the candidate aggregate.'
[pscustomobject][ordered]@{status='passed';checks=$Checks;formal_baseline_aggregate=$ExpectedFormalAggregate;candidate_aggregate=$ExpectedCandidateAggregate;candidate_validator_checks=$ExpectedValidatorChecks;write_rows=$writeSet.Count;write_tables=$backups.Count;payloads=$newFiles.Count;guards=$guards.Count;cross_package_write_pk_intersections=0;cross_package_payload_path_intersections=0;cross_package_guard_pk_intersections=0;upstream_transaction_signoffs=3;formal_writes_performed=0}|ConvertTo-Json -Compress
Write-Output "PASS: bundle formal transaction preflight; $Checks checks; formal root unchanged."