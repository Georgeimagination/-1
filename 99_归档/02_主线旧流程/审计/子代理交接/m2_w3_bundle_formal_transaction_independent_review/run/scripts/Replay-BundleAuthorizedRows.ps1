#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourceRoot,
    [Parameter(Mandatory=$true)][string]$TargetRoot,
    [Parameter(Mandatory=$true)][string]$PackageRoot
)
Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$Utf8NoBom=New-Object Text.UTF8Encoding($false)
function Fail([string]$Message){throw $Message}
function Get-Sha256([string]$Path){return(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-TextSha256([string]$Text){$a=[Security.Cryptography.SHA256]::Create();try{return([BitConverter]::ToString($a.ComputeHash($Utf8NoBom.GetBytes($Text))).Replace('-','').ToLowerInvariant())}finally{$a.Dispose()}}
function Get-ChildPath([string]$Root,[string]$RelativePath,[bool]$MustExist=$true){$rootFull=[IO.Path]::GetFullPath($Root).TrimEnd('\');$full=[IO.Path]::GetFullPath((Join-Path $rootFull ($RelativePath.Replace('/','\'))));if(-not$full.StartsWith($rootFull+'\',[StringComparison]::OrdinalIgnoreCase)){Fail "Path escapes root: $RelativePath"};if($MustExist-and-not(Test-Path -LiteralPath $full -PathType Leaf)){Fail "Missing file: $full"};return $full}
function Get-CanonicalRowSha256([object]$Row){return Get-TextSha256 (@($Row|ConvertTo-Csv -NoTypeInformation)-join[char]10)}
function Write-Csv([string]$Path,[object[]]$Rows){[IO.File]::WriteAllLines($Path,($Rows|ConvertTo-Csv -NoTypeInformation),$Utf8NoBom)}
$SourceRoot=(Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\')
$TargetRoot=(Resolve-Path -LiteralPath $TargetRoot).Path.TrimEnd('\')
$PackageRoot=(Resolve-Path -LiteralPath $PackageRoot).Path.TrimEnd('\')
$marker=Join-Path $TargetRoot '.m2w3-bundle-isolated-target'
if(-not(Test-Path -LiteralPath $marker -PathType Leaf)){Fail 'Replay target lacks .m2w3-bundle-isolated-target.'}
if([IO.File]::ReadAllText($marker,[Text.Encoding]::UTF8).Trim()-cne'M2-W3-BUNDLE-ISOLATED-TRANSACTION'){Fail 'Replay target marker differs.'}
$writeSet=@(Import-Csv -LiteralPath (Join-Path $PackageRoot 'authorized-write-set.csv') -Encoding UTF8)
$newFiles=@(Import-Csv -LiteralPath (Join-Path $PackageRoot 'new-file-targets.csv') -Encoding UTF8)
if($writeSet.Count-ne1057-or$newFiles.Count-ne15){Fail 'Frozen bundle replay shape differs.'}
$keys=@($writeSet|ForEach-Object{[string]$_.target_path+'|'+[string]$_.pk_column+'|'+[string]$_.pk_value})
if(@($keys|Sort-Object -Unique).Count-ne1057){Fail 'Bundle lifecycle PKs are not unique.'}
if(@($newFiles.target_path|Sort-Object -Unique).Count-ne15){Fail 'Bundle payload targets are not unique.'}
$sourceCache=@{}
$written=0
foreach($group in($writeSet|Group-Object target_path|Sort-Object Name)){
    $target=Get-ChildPath $TargetRoot ([string]$group.Name)
    $formalRows=@(Import-Csv -LiteralPath $target -Encoding UTF8)
    if($formalRows.Count-eq0){Fail "Target table has no data rows: $($group.Name)"}
    $header=@($formalRows[0].PSObject.Properties.Name)
    $append=[Collections.Generic.List[object]]::new()
    foreach($binding in($group.Group|Sort-Object {[int]$_.package_order},signoff_row_id)){
        $source=Get-ChildPath $SourceRoot ([string]$binding.source_path)
        if((Get-Sha256 $source)-cne[string]$binding.source_sha256){Fail "Source hash differs: $($binding.bundle_row_id)"}
        if((Get-Item -LiteralPath $source).Length-ne[int64]$binding.source_bytes){Fail "Source bytes differ: $($binding.bundle_row_id)"}
        if(-not$sourceCache.ContainsKey($source)){$sourceCache[$source]=@(Import-Csv -LiteralPath $source -Encoding UTF8)}
        $matches=@($sourceCache[$source]|Where-Object{[string]$_.$([string]$binding.pk_column)-ceq[string]$binding.pk_value})
        if($matches.Count-ne1){Fail "Source PK count differs: $($binding.bundle_row_id)"}
        if(@($formalRows|Where-Object{[string]$_.$([string]$binding.pk_column)-ceq[string]$binding.pk_value}).Count-ne0){Fail "Target PK exists: $($binding.pk_value)"}
        if(@($append|Where-Object{[string]$_.$([string]$binding.pk_column)-ceq[string]$binding.pk_value}).Count-ne0){Fail "Candidate PK repeated: $($binding.pk_value)"}
        $values=[ordered]@{}
        foreach($column in $header){$values[$column]=[string]$matches[0].$column}
        $row=[pscustomobject]$values
        if((Get-CanonicalRowSha256 $row)-cne[string]$binding.canonical_source_row_sha256){Fail "Canonical source row differs: $($binding.bundle_row_id)"}
        $row.review_status=[string]$binding.authorized_review_status
        if(-not[string]::IsNullOrEmpty([string]$binding.semantic_status_column)){
            $column=[string]$binding.semantic_status_column
            if([string]$row.$column-cne[string]$binding.semantic_status_before){Fail "Semantic before-value differs: $($binding.bundle_row_id)"}
            $row.$column=[string]$binding.semantic_status_after
        }
        if((Get-CanonicalRowSha256 $row)-cne[string]$binding.canonical_authorized_row_sha256){Fail "Canonical authorized row differs: $($binding.bundle_row_id)"}
        $append.Add($row)
        $written++
    }
    Write-Csv $target (@($formalRows)+@($append.ToArray()))
}
$payloads=0
foreach($item in($newFiles|Sort-Object {[int]$_.package_order}, {[int]$_.package_commit_order})){
    $source=Get-ChildPath $SourceRoot ([string]$item.source_path)
    if((Get-Sha256 $source)-cne[string]$item.source_sha256){Fail "Payload source differs: $($item.bundle_payload_id)"}
    if((Get-Item -LiteralPath $source).Length-ne[int64]$item.source_bytes){Fail "Payload bytes differ: $($item.bundle_payload_id)"}
    $target=Get-ChildPath $TargetRoot ([string]$item.target_path) $false
    if(Test-Path -LiteralPath $target){Fail "Payload target exists: $($item.target_path)"}
    [IO.Directory]::CreateDirectory((Split-Path -Parent $target))|Out-Null
    [IO.File]::Copy($source,$target,$false)
    if((Get-Sha256 $target)-cne[string]$item.source_sha256){Fail "Payload copy differs: $($item.target_path)"}
    $payloads++
}
$endpointTablePath=@($writeSet.target_path|Where-Object{[IO.Path]::GetFileName(([string]$_).Replace('/','\'))-ceq'source-endpoints.csv'}|Sort-Object -Unique);if($endpointTablePath.Count-ne1){Fail 'source-endpoints.csv target path count differs.'};$endpoints=@(Import-Csv -LiteralPath (Get-ChildPath $TargetRoot ([string]$endpointTablePath[0])) -Encoding UTF8)
$endpointCopies=0
foreach($endpoint in $endpoints){
    $relative=[string]$endpoint.local_path
    if([string]::IsNullOrWhiteSpace($relative)){continue}
    $destination=Get-ChildPath $TargetRoot $relative $false
    if(Test-Path -LiteralPath $destination -PathType Leaf){continue}
    $source=Get-ChildPath $SourceRoot $relative $false
    if(-not(Test-Path -LiteralPath $source -PathType Leaf)){Fail "Endpoint file unavailable: $relative"}
    [IO.Directory]::CreateDirectory((Split-Path -Parent $destination))|Out-Null
    [IO.File]::Copy($source,$destination,$false)
    $endpointCopies++
}
[pscustomobject][ordered]@{status='PASS';authorized_writes=$written;files_created=$payloads;endpoint_files_copied=$endpointCopies}|ConvertTo-Json -Compress