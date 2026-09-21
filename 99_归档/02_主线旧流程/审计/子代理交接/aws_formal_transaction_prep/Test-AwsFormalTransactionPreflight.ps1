#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$script:Checks = 0

$ExpectedSignoffSha256 = 'b9fa74876dfa4769df99277359f5c0be7dff268a353964abf1d392eb3708e4e3'
$ExpectedIndependentReviewSha256 = '5709dccd10be494233dd8ced7a7206e151a2fc6d73e34687a8a7c65658b47797'
$ExpectedFormalAggregate = 'd10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff'
$ExpectedFreezeAggregate = '46fd41d8b19a82dc22c24ddee5c1b4e3534cacfe56bc4258cd1c9756ed67b552'
$ExpectedFreezeManifestSha256 = '74fe487790a0d2fbcaf012c1d60b409fd065dad5480a769843c28dab070036c4'
$ExpectedLifecycleSha256 = 'f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880'
$ExpectedReplayEngineSha256 = 'ac622536f2f5214bf81a008e1556b8e008acff93429580c56eef2371dc31ff35'
$ExpectedBackupListSha256 = '196e177d6f9206d6eb059a19442ec118bb33bb04389f75cae4d52c38a6ad0533'
$ExpectedGuardListSha256 = '77c886d688411a51ad1421326e19fc133576b77ae1e7641d85b7973479639042'
$ExpectedNewFileListSha256 = '26d5ad2db57df1ac51b18a7a8f1d3dbb7332b8a7272a7be96004f033712e48e7'

function Assert-Check {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    $script:Checks++
}

function Get-ExistingRoot {
    param([string]$Path, [string]$Label)
    Assert-Check (-not [string]::IsNullOrWhiteSpace($Path)) "$Label is empty."
    Assert-Check (Test-Path -LiteralPath $Path -PathType Container) "$Label does not exist: $Path"
    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
}

function Get-ChildPath {
    param([string]$Root, [string]$RelativePath, [bool]$MustExist = $false)
    Assert-Check (-not [string]::IsNullOrWhiteSpace($RelativePath)) 'Relative path is empty.'
    $normalized = $RelativePath.Replace('/', '\')
    Assert-Check (-not [IO.Path]::IsPathRooted($normalized)) "Rooted relative path is forbidden: $RelativePath"
    $prefix = [IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    $full = [IO.Path]::GetFullPath((Join-Path $Root $normalized))
    Assert-Check ($full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) "Path escapes root: $RelativePath"
    if ($MustExist) { Assert-Check (Test-Path -LiteralPath $full -PathType Leaf) "Required file is missing: $full" }
    return $full
}

function Get-Sha256 {
    param([string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-TextSha256 {
    param([string]$Text)
    $encoding = New-Object Text.UTF8Encoding($false)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($encoding.GetBytes($Text))).Replace('-', '').ToLowerInvariant())
    }
    finally { $sha.Dispose() }
}

function Get-CanonicalRowSha256 {
    param([object]$Row)
    $serialized = @($Row | ConvertTo-Csv -NoTypeInformation) -join [char]10
    return Get-TextSha256 $serialized
}

function Get-ExactRows {
    param([object[]]$Rows, [string]$PkColumn, [string]$PkValue)
    return @($Rows | Where-Object { [string]$_.$PkColumn -ceq $PkValue })
}

function Get-FormalAggregate {
    param([string]$Root, [string[]]$TablePaths)
    $pairs = foreach ($relative in ($TablePaths | Sort-Object)) {
        $path = Get-ChildPath -Root $Root -RelativePath $relative -MustExist $true
        $relative + '|' + (Get-Sha256 $path)
    }
    return Get-TextSha256 ($pairs -join [char]10)
}

function Get-FileFormat {
    param([string]$Path)
    $bytes = [IO.File]::ReadAllBytes($Path)
    $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191
    $utf8Valid = $true
    try {
        $strict = New-Object Text.UTF8Encoding($false, $true)
        [void]$strict.GetString($bytes)
    }
    catch { $utf8Valid = $false }
    $text = [Text.Encoding]::UTF8.GetString($bytes)
    return [pscustomobject]@{
        bytes = $bytes.Length
        utf8_valid = ([string]$utf8Valid).ToLowerInvariant()
        utf8_bom = ([string]$bom).ToLowerInvariant()
        crlf_count = [regex]::Matches($text, [char]13 + [char]10).Count
        bare_lf_count = [regex]::Matches($text, '(?<!' + [char]13 + ')' + [char]10).Count
        bare_cr_count = [regex]::Matches($text, [char]13 + '(?!' + [char]10 + ')').Count
        final_crlf = ([string]$text.EndsWith([char]13 + [char]10, [StringComparison]::Ordinal)).ToLowerInvariant()
    }
}

$SourceRoot = Get-ExistingRoot -Path $SourceRoot -Label 'SourceRoot'
$TargetRoot = Get-ExistingRoot -Path $TargetRoot -Label 'TargetRoot'
$WorkRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$signoffPath = Get-ChildPath -Root $SourceRoot -RelativePath '审计/子代理交接/aws_post_field_rebase/aws-signoff-post-field-rebase.csv' -MustExist $true
$reviewPath = Get-ChildPath -Root $SourceRoot -RelativePath '审计/子代理交接/aws_post_field_rebase_independent_review/formal-merge-accept-signoff.csv' -MustExist $true
$enginePath = Get-ChildPath -Root $SourceRoot -RelativePath '审计/子代理交接/aws_post_field_rebase/Invoke-AwsPackageMerge.ps1' -MustExist $true
$freezeManifestPath = Get-ChildPath -Root $SourceRoot -RelativePath '审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/audit/freeze-manifest.csv' -MustExist $true
$lifecyclePath = Get-ChildPath -Root $SourceRoot -RelativePath '审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/audit/lifecycle-manifest-candidate.csv' -MustExist $true
$backupListPath = Join-Path $WorkRoot 'formal-csv-backup-candidates.csv'
$guardListPath = Join-Path $WorkRoot 'no-write-guards.csv'
$newFileListPath = Join-Path $WorkRoot 'new-file-targets.csv'

Assert-Check ((Get-Sha256 $signoffPath) -ceq $ExpectedSignoffSha256) 'AWS signoff SHA-256 differs.'
Assert-Check ((Get-Sha256 $reviewPath) -ceq $ExpectedIndependentReviewSha256) 'Independent-review signoff SHA-256 differs.'
Assert-Check ((Get-Sha256 $enginePath) -ceq $ExpectedReplayEngineSha256) 'Accepted replay-engine SHA-256 differs.'
Assert-Check ((Get-Sha256 $freezeManifestPath) -ceq $ExpectedFreezeManifestSha256) 'Freeze-manifest SHA-256 differs.'
Assert-Check ((Get-Sha256 $lifecyclePath) -ceq $ExpectedLifecycleSha256) 'Lifecycle-manifest SHA-256 differs.'
Assert-Check ((Get-Sha256 $backupListPath) -ceq $ExpectedBackupListSha256) '20-table backup-candidate list SHA-256 differs.'
Assert-Check ((Get-Sha256 $guardListPath) -ceq $ExpectedGuardListSha256) 'Nine-guard list SHA-256 differs.'
Assert-Check ((Get-Sha256 $newFileListPath) -ceq $ExpectedNewFileListSha256) '15-target list SHA-256 differs.'

$review = @(Import-Csv -LiteralPath $reviewPath -Encoding UTF8)
Assert-Check ($review.Count -eq 23) "Independent-review signoff row count differs: $($review.Count)."
Assert-Check (@($review | Where-Object { $_.verdict -cne 'accept' }).Count -eq 0) 'Independent review contains a non-accept verdict.'
Assert-Check (@($review | Where-Object { $_.ready_for_formal_merge -cne 'true' }).Count -eq 0) 'Independent review is not ready for formal merge.'

$signoff = @(Import-Csv -LiteralPath $signoffPath -Encoding UTF8)
Assert-Check ($signoff.Count -eq 486) "AWS signoff row count differs: $($signoff.Count)."
Assert-Check (@($signoff.signoff_row_id | Sort-Object -Unique).Count -eq 486) 'AWS signoff IDs are not unique.'
for ($index = 1; $index -le 486; $index++) {
    Assert-Check ($signoff[$index - 1].signoff_row_id -ceq ('AWS-SIGN-{0:D4}' -f $index)) "AWS signoff sequence differs at row $index."
}
$scopeCounts = @{}
foreach ($group in ($signoff | Group-Object authorization_scope)) { $scopeCounts[$group.Name] = $group.Count }
Assert-Check ($scopeCounts['lifecycle_pk_write'] -eq 457) 'Lifecycle-write scope count is not 457.'
Assert-Check ($scopeCounts['semantic_signoff'] -eq 5) 'Semantic-write scope count is not 5.'
Assert-Check ($scopeCounts['exact_file_copy'] -eq 11) 'Snapshot-copy scope count is not 11.'
Assert-Check ($scopeCounts['exact_finalized_card_write'] -eq 4) 'Card-copy scope count is not 4.'
Assert-Check ($scopeCounts['no_write_guard'] -eq 9) 'No-write guard count is not 9.'
Assert-Check (-not $scopeCounts.ContainsKey('exact_cell_write')) 'Exact-cell write is forbidden after field-contract migration.'
foreach ($row in $signoff) {
    Assert-Check ($row.formal_baseline_aggregate_sha256 -ceq $ExpectedFormalAggregate) "Baseline binding differs: $($row.signoff_row_id)"
    Assert-Check ($row.freeze_aggregate_sha256 -ceq $ExpectedFreezeAggregate) "Freeze aggregate differs: $($row.signoff_row_id)"
    Assert-Check ($row.freeze_manifest_sha256 -ceq $ExpectedFreezeManifestSha256) "Freeze manifest binding differs: $($row.signoff_row_id)"
    Assert-Check ($row.lifecycle_candidate_sha256 -ceq $ExpectedLifecycleSha256) "Lifecycle binding differs: $($row.signoff_row_id)"
    Assert-Check ($row.verdict -ceq 'accept') "Signoff verdict differs: $($row.signoff_row_id)"
    switch ($row.authorization_scope) {
        'lifecycle_pk_write' {
            Assert-Check ($row.action_type -in @('append_then_promote_review_status','append_without_review_promotion','update_existing_then_promote_review_status','update_existing_preserve_review_status')) "Lifecycle action is unsupported: $($row.signoff_row_id)"
        }
        'semantic_signoff' {
            Assert-Check ($row.action_type -ceq 'post_lifecycle_exact_semantic_update') "Semantic action is unsupported: $($row.signoff_row_id)"
        }
        'exact_file_copy' {
            Assert-Check ($row.action_type -ceq 'copy_bytes_if_target_absent') "Snapshot action is unsupported: $($row.signoff_row_id)"
        }
        'exact_finalized_card_write' {
            Assert-Check ($row.action_type -ceq 'copy_bytes_if_target_absent') "Card action is unsupported: $($row.signoff_row_id)"
        }
        'no_write_guard' {
            Assert-Check ($row.action_type -ceq 'preserve_existing_no_write') "Guard action is unsupported: $($row.signoff_row_id)"
        }
        default { throw "Unsupported authorization scope: $($row.authorization_scope)" }
    }
}

$schemaPath = Get-ChildPath -Root $TargetRoot -RelativePath '数据/schema-columns.csv' -MustExist $true
$schema = @(Import-Csv -LiteralPath $schemaPath -Encoding UTF8)
$tablePaths = @($schema.table_path | Sort-Object -Unique)
Assert-Check ($tablePaths.Count -eq 32) "TargetRoot does not contain 32 formal tables: $($tablePaths.Count)."
$targetAggregate = Get-FormalAggregate -Root $TargetRoot -TablePaths $tablePaths
Assert-Check ($targetAggregate -ceq $ExpectedFormalAggregate) "TargetRoot formal aggregate differs: $targetAggregate"
$sourceSchema = @(Import-Csv -LiteralPath (Get-ChildPath -Root $SourceRoot -RelativePath '数据/schema-columns.csv' -MustExist $true) -Encoding UTF8)
$sourcePaths = @($sourceSchema.table_path | Sort-Object -Unique)
Assert-Check ($sourcePaths.Count -eq 32) 'SourceRoot does not contain 32 formal tables.'
$sourceAggregate = Get-FormalAggregate -Root $SourceRoot -TablePaths $sourcePaths
Assert-Check ($sourceAggregate -ceq $ExpectedFormalAggregate) "SourceRoot formal aggregate differs: $sourceAggregate"

$backupList = @(Import-Csv -LiteralPath $backupListPath -Encoding UTF8)
Assert-Check ($backupList.Count -eq 20) "Backup-candidate list row count differs: $($backupList.Count)."
Assert-Check (@($backupList.target_path | Sort-Object -Unique).Count -eq 20) 'Backup-candidate target paths are not unique.'
$authorizedTableWrites = @($signoff | Where-Object { $_.authorization_scope -in @('lifecycle_pk_write','semantic_signoff') })
$authorizedTablePaths = @($authorizedTableWrites.target_path | Sort-Object -Unique)
Assert-Check ($authorizedTablePaths.Count -eq 20) 'AWS signoff does not target exactly 20 CSV tables.'
Assert-Check (($authorizedTablePaths -join [char]31) -ceq (@($backupList.target_path | Sort-Object) -join [char]31)) '20-table list and signoff table set differ.'
foreach ($item in $backupList) {
    $path = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
    Assert-Check ((Get-Sha256 $path) -ceq $item.premerge_sha256) "Backup-candidate file hash differs: $($item.target_path)"
    $format = Get-FileFormat $path
    Assert-Check ($format.bytes -eq [int64]$item.bytes) "Backup-candidate byte count differs: $($item.target_path)"
    Assert-Check ($format.utf8_valid -ceq $item.utf8_valid) "Backup-candidate UTF-8 status differs: $($item.target_path)"
    Assert-Check ($format.utf8_bom -ceq $item.utf8_bom) "Backup-candidate BOM status differs: $($item.target_path)"
    Assert-Check ($format.crlf_count -eq [int]$item.crlf_count) "Backup-candidate CRLF count differs: $($item.target_path)"
    Assert-Check ($format.bare_lf_count -eq [int]$item.bare_lf_count) "Backup-candidate bare-LF count differs: $($item.target_path)"
    Assert-Check ($format.bare_cr_count -eq [int]$item.bare_cr_count) "Backup-candidate bare-CR count differs: $($item.target_path)"
    Assert-Check ($format.final_crlf -ceq $item.final_crlf) "Backup-candidate final-CRLF status differs: $($item.target_path)"
    $signedCount = @($authorizedTableWrites | Where-Object target_path -ceq $item.target_path).Count
    Assert-Check ($signedCount -eq [int]$item.authorized_row_writes) "Authorized row-write count differs: $($item.target_path)"
}
Assert-Check (($authorizedTableWrites.Count) -eq 462) 'CSV row-write authorization count is not 462.'

$guardList = @(Import-Csv -LiteralPath $guardListPath -Encoding UTF8)
$guardSignoff = @($signoff | Where-Object authorization_scope -ceq 'no_write_guard')
Assert-Check ($guardList.Count -eq 9) "Guard-list row count differs: $($guardList.Count)."
Assert-Check (@($guardList.signoff_row_id | Sort-Object -Unique).Count -eq 9) 'Guard-list IDs are not unique.'
foreach ($item in $guardList) {
    $signed = @($guardSignoff | Where-Object signoff_row_id -ceq $item.signoff_row_id)
    Assert-Check ($signed.Count -eq 1) "Guard signoff row is missing: $($item.signoff_row_id)"
    Assert-Check ($signed[0].target_path -ceq $item.target_path) "Guard target path differs: $($item.signoff_row_id)"
    Assert-Check ($signed[0].pk_column -ceq $item.pk_column) "Guard PK column differs: $($item.signoff_row_id)"
    Assert-Check ($signed[0].pk_value -ceq $item.pk_value) "Guard PK value differs: $($item.signoff_row_id)"
    $path = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
    Assert-Check ((Get-Sha256 $path) -ceq $item.formal_file_sha256) "Guard file hash differs: $($item.signoff_row_id)"
    $rows = @(Import-Csv -LiteralPath $path -Encoding UTF8)
    $matches = @(Get-ExactRows -Rows $rows -PkColumn $item.pk_column -PkValue $item.pk_value)
    Assert-Check ($matches.Count -eq 1) "Guard row count differs: $($item.signoff_row_id)"
    Assert-Check ((Get-CanonicalRowSha256 $matches[0]) -ceq $item.canonical_row_sha256) "Guard row hash differs: $($item.signoff_row_id)"
    Assert-Check (($matches[0] | ConvertTo-Json -Compress -Depth 5) -ceq $item.canonical_row_json) "Guard row values differ: $($item.signoff_row_id)"
}
$fieldGuard = @($guardList | Where-Object signoff_row_id -ceq 'AWS-SIGN-0458')
Assert-Check ($fieldGuard.Count -eq 1) 'FIELD-PHY-CLOCK guard is missing.'
Assert-Check ($fieldGuard[0].allowed_subject_kinds -ceq 'object;component') 'FIELD-PHY-CLOCK fact subject contract differs.'
Assert-Check ($fieldGuard[0].allowed_requirement_target_kinds -ceq 'object;component;precision_path') 'FIELD-PHY-CLOCK requirement target contract differs.'
$fields = @(Import-Csv -LiteralPath (Get-ChildPath -Root $TargetRoot -RelativePath '数据/fields.csv' -MustExist $true) -Encoding UTF8)
Assert-Check (@($fields[0].PSObject.Properties.Name).Count -eq 13) 'TargetRoot fields.csv does not retain 13 columns.'
Assert-Check (@($authorizedTableWrites | Where-Object target_path -ceq '数据/fields.csv').Count -eq 0) 'AWS CSV write set must not include fields.csv.'

$newFileList = @(Import-Csv -LiteralPath $newFileListPath -Encoding UTF8)
$copySignoff = @($signoff | Where-Object { $_.authorization_scope -in @('exact_file_copy','exact_finalized_card_write') })
Assert-Check ($newFileList.Count -eq 15) "New-file list row count differs: $($newFileList.Count)."
Assert-Check (@($newFileList.target_path | Sort-Object -Unique).Count -eq 15) 'New-file target paths are not unique.'
foreach ($item in $newFileList) {
    $signed = @($copySignoff | Where-Object signoff_row_id -ceq $item.signoff_row_id)
    Assert-Check ($signed.Count -eq 1) "Copy signoff row is missing: $($item.signoff_row_id)"
    Assert-Check ($signed[0].target_path -ceq $item.target_path) "Copy target path differs: $($item.signoff_row_id)"
    Assert-Check ($signed[0].source_path -ceq $item.source_path) "Copy source path differs: $($item.signoff_row_id)"
    $source = Get-ChildPath -Root $SourceRoot -RelativePath $item.source_path -MustExist $true
    Assert-Check ((Get-Sha256 $source) -ceq $item.source_sha256) "Copy source hash differs: $($item.signoff_row_id)"
    Assert-Check ((Get-Item -LiteralPath $source).Length -eq [int64]$item.source_bytes) "Copy source bytes differ: $($item.signoff_row_id)"
    Assert-Check ($item.source_sha256 -ceq $item.expected_output_sha256) "Copy source and output hashes differ: $($item.signoff_row_id)"
    Assert-Check ([int64]$item.source_bytes -eq [int64]$item.expected_output_bytes) "Copy source and output bytes differ: $($item.signoff_row_id)"
    $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $false
    Assert-Check (-not (Test-Path -LiteralPath $target)) "Authorized new-file target already exists: $($item.target_path)"
}

$result = [pscustomobject][ordered]@{
    status = 'PASS'
    checks = $script:Checks
    source_root = $SourceRoot
    target_root = $TargetRoot
    formal_baseline_aggregate = $targetAggregate
    signoff_rows = $signoff.Count
    csv_row_writes = $authorizedTableWrites.Count
    formal_csv_targets = $backupList.Count
    file_payloads = $newFileList.Count
    no_write_guards = $guardList.Count
    authorized_writes = 477
    fields_columns = 13
}
$result | ConvertTo-Json -Compress
