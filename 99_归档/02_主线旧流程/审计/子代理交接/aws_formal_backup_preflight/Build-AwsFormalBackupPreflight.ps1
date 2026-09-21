#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RootPath = 'D:\Workspace\2026projects\调研-训练推理芯片调研-资料汇总',
    [string]$OutputRelativePath = '审计\子代理交接\aws_formal_backup_preflight'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$ExpectedAggregate = 'd10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff'
$ExpectedSignoffHash = 'b9fa74876dfa4769df99277359f5c0be7dff268a353964abf1d392eb3708e4e3'
$ExpectedIndependentHash = '5709dccd10be494233dd8ced7a7206e151a2fc6d73e34687a8a7c65658b47797'
$ExpectedPackageManifestHash = '987d37808f9afe59ecfafb3667484b0e5bb6129bebdc10e64700b34585bbce27'
$ExpectedPackageAggregate = 'a71e3370a9d20f520df8df39cd0d5221c507b8c85a94327026acf3145d0b3b54'
$ExpectedFreezeHash = '74fe487790a0d2fbcaf012c1d60b409fd065dad5480a769843c28dab070036c4'
$ExpectedFreezeAggregate = '46fd41d8b19a82dc22c24ddee5c1b4e3534cacfe56bc4258cd1c9756ed67b552'
$ExpectedLifecycleHash = 'f2682bdaf3ee4bee58aa95e20aa60461cc96a1f1fbc20a04b93bdcd2e98bc880'

$Root = (Resolve-Path -LiteralPath $RootPath).Path.TrimEnd('\')
$OutDir = Join-Path $Root $OutputRelativePath
[System.IO.Directory]::CreateDirectory($OutDir) | Out-Null

function Get-Path([string]$RelativePath) {
    $full = [System.IO.Path]::GetFullPath((Join-Path $Root $RelativePath.Replace('/', '\')))
    $prefix = $Root + '\'
    if (-not $full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Path escapes root: $RelativePath" }
    return $full
}
function Get-Sha([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-TextSha([string]$Text) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash(([System.Text.UTF8Encoding]::new($false)).GetBytes($Text))).Replace('-', '').ToLowerInvariant()) }
    finally { $sha.Dispose() }
}
function Write-Text([string]$Path, [string]$Text) {
    $normalized = [regex]::Replace($Text, "(?<!`r)`n", "`r`n")
    [System.IO.File]::WriteAllText($Path, $normalized, [System.Text.UTF8Encoding]::new($false))
}
function Write-Csv([string]$Name, [object[]]$Rows) {
    if ($Rows.Count -eq 0) { throw "Refusing empty CSV: $Name" }
    $lines = @($Rows | ConvertTo-Csv -NoTypeInformation)
    Write-Text (Join-Path $OutDir $Name) (($lines -join "`r`n") + "`r`n")
}
function Get-Format([string]$Path) {
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $bom = if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) { 'utf8_bom' }
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 255 -and $bytes[1] -eq 254) { 'utf16le_bom' }
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 254 -and $bytes[1] -eq 255) { 'utf16be_bom' }
        else { 'none' }
    $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
    $valid = $true
    try { $text = $utf8.GetString($bytes) } catch { $valid = $false; $text = '' }
    [pscustomobject][ordered]@{
        encoding = if ($valid) { 'utf8' } else { 'invalid_utf8' }
        bom = $bom
        crlf_count = if ($valid) { [regex]::Matches($text, "`r`n").Count } else { -1 }
        bare_lf_count = if ($valid) { [regex]::Matches($text, "(?<!`r)`n").Count } else { -1 }
        bare_cr_count = if ($valid) { [regex]::Matches($text, "`r(?!`n)").Count } else { -1 }
        final_crlf = if ($valid) { ([string]$text.EndsWith("`r`n", [System.StringComparison]::Ordinal)).ToLowerInvariant() } else { 'false' }
    }
}
function Join-Values([object[]]$Values) { (@($Values | ForEach-Object { [string]$_ }) -join ';') }

$signoffRel = '审计/子代理交接/aws_post_field_rebase/aws-signoff-post-field-rebase.csv'
$independentRel = '审计/子代理交接/aws_post_field_rebase_independent_review/formal-merge-accept-signoff.csv'
$packageManifestRel = '审计/子代理交接/aws_post_field_rebase/manifest.csv'
$baselineRel = '审计/子代理交接/aws_post_field_rebase/formal-baseline-hashes.csv'
$freezeRel = '审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/audit/freeze-manifest.csv'
$lifecycleRel = '审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED/audit/lifecycle-manifest-candidate.csv'

$signoffPath = Get-Path $signoffRel
$independentPath = Get-Path $independentRel
$packageManifestPath = Get-Path $packageManifestRel
$freezePath = Get-Path $freezeRel
$lifecyclePath = Get-Path $lifecycleRel
if ((Get-Sha $signoffPath) -cne $ExpectedSignoffHash) { throw 'AWS signoff hash mismatch.' }
if ((Get-Sha $independentPath) -cne $ExpectedIndependentHash) { throw 'Independent signoff hash mismatch.' }
if ((Get-Sha $packageManifestPath) -cne $ExpectedPackageManifestHash) { throw 'Package manifest hash mismatch.' }
if ((Get-Sha $freezePath) -cne $ExpectedFreezeHash) { throw 'Freeze manifest hash mismatch.' }
if ((Get-Sha $lifecyclePath) -cne $ExpectedLifecycleHash) { throw 'Lifecycle manifest hash mismatch.' }

$signoff = @(Import-Csv -LiteralPath $signoffPath -Encoding UTF8)
$independent = @(Import-Csv -LiteralPath $independentPath -Encoding UTF8)
$packageManifest = @(Import-Csv -LiteralPath $packageManifestPath -Encoding UTF8)
$freeze = @(Import-Csv -LiteralPath $freezePath -Encoding UTF8)
$lifecycle = @(Import-Csv -LiteralPath $lifecyclePath -Encoding UTF8)
if ($signoff.Count -ne 486 -or $independent.Count -ne 23 -or $packageManifest.Count -ne 21 -or $freeze.Count -ne 76 -or $lifecycle.Count -ne 457) { throw 'Bound row counts differ.' }

$packageDir = Split-Path -Parent $packageManifestPath
$packageChecks = foreach ($row in $packageManifest) {
    $file = Join-Path $packageDir $row.name
    [pscustomobject][ordered]@{ name=$row.name; expected_sha256=$row.sha256; actual_sha256=(Get-Sha $file); expected_bytes=$row.bytes; actual_bytes=(Get-Item -LiteralPath $file).Length; match=([string](((Get-Sha $file) -ceq $row.sha256) -and ((Get-Item -LiteralPath $file).Length -eq [int64]$row.bytes))).ToLowerInvariant() }
}
$packageAggregate = Get-TextSha ((@($packageManifest | ForEach-Object { $_.name + '|' + $_.sha256 + '|' + $_.bytes })) -join "`n")
if ($packageAggregate -cne $ExpectedPackageAggregate -or @($packageChecks | Where-Object match -cne 'true').Count -ne 0) { throw 'Reviewed package manifest integrity failed.' }
Write-Csv 'reviewed-package-integrity.csv' @($packageChecks)

$stageRoot = Split-Path -Parent (Split-Path -Parent $freezePath)
$freezeChecks = foreach ($row in $freeze) {
    $file = Join-Path $stageRoot $row.relative_path.Replace('/', '\')
    $actualSha = Get-Sha $file
    $actualBytes = (Get-Item -LiteralPath $file).Length
    [pscustomobject][ordered]@{ relative_path=$row.relative_path; expected_sha256=$row.sha256; actual_sha256=$actualSha; expected_bytes=$row.bytes; actual_bytes=$actualBytes; match=([string](($actualSha -ceq $row.sha256) -and ($actualBytes -eq [int64]$row.bytes))).ToLowerInvariant() }
}
$freezeAggregate = Get-TextSha ((@($freeze | ForEach-Object { $_.relative_path + '|' + $_.sha256 + '|' + $_.bytes })) -join "`n")
if ($freezeAggregate -cne $ExpectedFreezeAggregate -or @($freezeChecks | Where-Object match -cne 'true').Count -ne 0) { throw 'Freeze integrity failed.' }
Write-Csv 'staging-freeze-integrity.csv' @($freezeChecks)

if (@($signoff.signoff_row_id | Sort-Object -Unique).Count -ne 486) { throw 'Signoff IDs are not unique.' }
for ($i=1; $i -le 486; $i++) { if ($signoff[$i-1].signoff_row_id -cne ('AWS-SIGN-{0:D4}' -f $i)) { throw "Signoff sequence differs at $i." } }
$scopeCount = @{}
foreach ($g in ($signoff | Group-Object authorization_scope)) { $scopeCount[$g.Name] = $g.Count }
if ($scopeCount.lifecycle_pk_write -ne 457 -or $scopeCount.semantic_signoff -ne 5 -or $scopeCount.exact_file_copy -ne 11 -or $scopeCount.exact_finalized_card_write -ne 4 -or $scopeCount.no_write_guard -ne 9) { throw 'Signoff scope counts differ.' }

$schemaPath = Get-Path '数据/schema-columns.csv'
$schema = @(Import-Csv -LiteralPath $schemaPath -Encoding UTF8)
$tablePaths = @($schema.table_path | Sort-Object -Unique)
if ($tablePaths.Count -ne 32) { throw 'Formal table count is not 32.' }
$signedBaseline = @(Import-Csv -LiteralPath (Get-Path $baselineRel) -Encoding UTF8)
$signedByTable = @{}
foreach ($row in $signedBaseline) { $signedByTable[$row.table_path] = $row }
$writeRows = @($signoff | Where-Object { $_.authorization_scope -in @('lifecycle_pk_write','semantic_signoff') })
$writeTables = @($writeRows.target_path | Sort-Object -Unique)
$guards = @($signoff | Where-Object authorization_scope -ceq 'no_write_guard')
$guardTables = @($guards.target_path | Sort-Object -Unique)

$formalInventory = foreach ($table in $tablePaths) {
    $file = Get-Path $table
    $rows = @(Import-Csv -LiteralPath $file -Encoding UTF8)
    $headers = @($rows[0].PSObject.Properties.Name)
    $pkRows = @($schema | Where-Object { $_.table_path -ceq $table -and $_.is_primary_key -ceq 'true' })
    $pk = if ($pkRows.Count -eq 1) { $pkRows[0].column_name } else { '' }
    $pkValues = if ($pk) { @($rows | ForEach-Object { [string]$_.$pk }) } else { @() }
    $sha = Get-Sha $file
    $fmt = Get-Format $file
    $signed = $signedByTable[$table]
    [pscustomobject][ordered]@{
        table_path=$table; sha256=$sha; bytes=(Get-Item -LiteralPath $file).Length; rows=$rows.Count; columns=$headers.Count; primary_key=$pk; primary_key_unique=([string]($pk -and (@($pkValues | Sort-Object -Unique).Count -eq $rows.Count))).ToLowerInvariant(); schema_columns=@($schema | Where-Object table_path -ceq $table).Count; encoding=$fmt.encoding; bom=$fmt.bom; crlf_count=$fmt.crlf_count; bare_lf_count=$fmt.bare_lf_count; bare_cr_count=$fmt.bare_cr_count; final_crlf=$fmt.final_crlf; signed_premerge_sha256=$signed.sha256; signed_match=([string]($sha -ceq $signed.sha256)).ToLowerInvariant(); write_target=([string]($writeTables -ccontains $table)).ToLowerInvariant(); guard_table=([string]($guardTables -ccontains $table)).ToLowerInvariant()
    }
}
$aggregateLines = @($formalInventory | Sort-Object table_path | ForEach-Object { $_.table_path + '|' + $_.sha256 })
$formalAggregate = Get-TextSha ($aggregateLines -join "`n")
if ($formalAggregate -cne $ExpectedAggregate -or @($formalInventory | Where-Object signed_match -cne 'true').Count -ne 0) { throw 'Formal baseline differs.' }
Write-Csv 'formal-baseline-before.csv' @($formalInventory)

$order = [ordered]@{
    '最小参考资料库/sources.csv'=1; '数据/components.csv'=2; '数据/links.csv'=3; '数据/precision-paths.csv'=4; '数据/memory-levels.csv'=5; '数据/condition-sets.csv'=6; '数据/field-requirements.csv'=7; '数据/facts.csv'=8; '数据/card-completeness.csv'=9; '最小参考资料库/source-endpoints.csv'=10; '最小参考资料库/source-screening.csv'=11; '最小参考资料库/source-selected-roles.csv'=12; '最小参考资料库/source-coverage.csv'=13; '最小参考资料库/fact-assertions.csv'=14; '最小参考资料库/conflict-groups.csv'=15; '最小参考资料库/conflict-members.csv'=16; '最小参考资料库/search-log.csv'=17; '最小参考资料库/search-results.csv'=18; '最小参考资料库/selection-runs.csv'=19; '最小参考资料库/selection-members.csv'=20
}
if ($writeTables.Count -ne 20 -or @($writeTables | Where-Object { -not $order.Contains($_) }).Count -ne 0) { throw 'Actual write-table set differs from the 20-table order.' }
$writeInventory = foreach ($table in ($writeTables | Sort-Object { $order[$_] })) {
    $base = $formalInventory | Where-Object table_path -ceq $table
    $rows = @($writeRows | Where-Object target_path -ceq $table)
    $lifecycleRows = @($rows | Where-Object authorization_scope -ceq 'lifecycle_pk_write')
    $semanticRows = @($rows | Where-Object authorization_scope -ceq 'semantic_signoff')
    $appends = @($lifecycleRows | Where-Object formal_premerge_presence -ceq 'absent').Count
    $updates = @($lifecycleRows | Where-Object formal_premerge_presence -ceq 'present').Count
    $preHashes = @($rows.formal_target_premerge_sha256 | Where-Object { $_ } | Sort-Object -Unique)
    [pscustomobject][ordered]@{
        commit_order=$order[$table]; rollback_order=(21-$order[$table]); table_path=$table; primary_key=$base.primary_key; current_sha256=$base.sha256; current_bytes=$base.bytes; current_rows=$base.rows; current_columns=$base.columns; encoding=$base.encoding; bom=$base.bom; newline='CRLF'; final_crlf=$base.final_crlf; lifecycle_writes=$lifecycleRows.Count; semantic_writes=$semanticRows.Count; authorized_csv_writes=$rows.Count; append_rows=$appends; update_rows=$updates; expected_post_rows=([int]$base.rows+$appends); signed_premerge_hash=Join-Values $preHashes; premerge_hash_match=([string]($preHashes.Count -eq 1 -and $preHashes[0] -ceq $base.sha256)).ToLowerInvariant(); signed_expected_post_sha256=''; posthash_status='not_present_in_486_row_or_23_row_signoff'; byte_reconstruction_requires='premerge_table+signed_sources+action_order+ConvertTo-Csv_CRLF_no_BOM'
    }
}
if (($writeRows.Count -ne 462) -or (($writeInventory | Measure-Object authorized_csv_writes -Sum).Sum -ne 462)) { throw 'CSV write count is not 462.' }
Write-Csv 'write-table-inventory.csv' @($writeInventory)

$guardFreeze = foreach ($guard in $guards) {
    $file = Get-Path $guard.target_path
    $rows = @(Import-Csv -LiteralPath $file -Encoding UTF8)
    $matches = @($rows | Where-Object { [string]$_.$($guard.pk_column) -ceq $guard.pk_value })
    if ($matches.Count -ne 1) { throw "Guard row count differs: $($guard.signoff_row_id)" }
    $row = $matches[0]
    $canonical = @($row | ConvertTo-Csv -NoTypeInformation) -join "`n"
    $canonicalBytes = ([System.Text.UTF8Encoding]::new($false)).GetBytes($canonical)
    [pscustomobject][ordered]@{
        signoff_row_id=$guard.signoff_row_id; table_path=$guard.target_path; table_sha256=(Get-Sha $file); table_bytes=(Get-Item -LiteralPath $file).Length; table_rows=$rows.Count; table_columns=@($row.PSObject.Properties.Name).Count; pk_column=$guard.pk_column; pk_value=$guard.pk_value; review_status=[string]$row.review_status; formal_premerge_sha256=$guard.formal_target_premerge_sha256; table_hash_match=([string]((Get-Sha $file) -ceq $guard.formal_target_premerge_sha256)).ToLowerInvariant(); canonical_row_sha256=(Get-TextSha $canonical); canonical_row_csv_base64=[Convert]::ToBase64String($canonicalBytes); full_row_json=($row | ConvertTo-Json -Compress -Depth 5); guard_semantic=$guard.semantic_status_preserved; binding_id=$guard.binding_id
    }
}
Write-Csv 'guard-freeze.csv' @($guardFreeze)
$guardTableInventory = foreach ($table in $guardTables) {
    $base = $formalInventory | Where-Object table_path -ceq $table
    [pscustomobject][ordered]@{ table_path=$table; guards=@($guards | Where-Object target_path -ceq $table).Count; sha256=$base.sha256; bytes=$base.bytes; rows=$base.rows; columns=$base.columns; primary_key=$base.primary_key; format=($base.encoding+';bom='+$base.bom+';CRLF;final_crlf='+$base.final_crlf); authorized_writes=0; defensive_full_table_backup='recommended' }
}
Write-Csv 'guard-table-inventory.csv' @($guardTableInventory)

$copyRows = @($signoff | Where-Object { $_.authorization_scope -in @('exact_file_copy','exact_finalized_card_write') })
$irPayload = @($independent | Where-Object { $_.binding_kind -in @('snapshot_target','final_card_target') })
$payloadInventory = foreach ($row in $copyRows) {
    $source = Get-Path $row.source_path
    $target = Get-Path $row.target_path
    $ir = @($irPayload | Where-Object target_path -ceq $row.target_path)
    if ($ir.Count -ne 1) { throw "Independent payload binding missing: $($row.signoff_row_id)" }
    $actualSha = Get-Sha $source
    $actualBytes = (Get-Item -LiteralPath $source).Length
    [pscustomobject][ordered]@{
        signoff_row_id=$row.signoff_row_id; independent_signoff_row_id=$ir[0].independent_signoff_row_id; payload_kind=$ir[0].binding_kind; source_path=$row.source_path; source_sha256=$actualSha; source_bytes=$actualBytes; signed_source_match=([string]($actualSha -ceq $row.source_sha256 -and $actualBytes -eq [int64]$row.expected_output_bytes)).ToLowerInvariant(); target_path=$row.target_path; target_exists=([string](Test-Path -LiteralPath $target)).ToLowerInvariant(); expected_output_sha256=$row.expected_output_sha256; expected_output_bytes=$row.expected_output_bytes; independent_hash_match=([string]($ir[0].expected_output_sha256 -ceq $row.expected_output_sha256 -and [int64]$ir[0].expected_output_bytes -eq [int64]$row.expected_output_bytes)).ToLowerInvariant(); failure_delete_condition='journal_created=true AND current_hash=expected_output_sha256'; recursive_delete_forbidden='true'
    }
}
if ($payloadInventory.Count -ne 15 -or @($payloadInventory | Where-Object { $_.signed_source_match -cne 'true' -or $_.target_exists -cne 'false' -or $_.independent_hash_match -cne 'true' }).Count -ne 0) { throw 'Payload preconditions differ.' }
Write-Csv 'payload-target-inventory.csv' @($payloadInventory)
$deleteList = foreach ($row in $payloadInventory) { [pscustomobject][ordered]@{ delete_order=1; target_path=$row.target_path; expected_transaction_hash=$row.expected_output_sha256; premerge_presence='absent'; delete_only_if=$row.failure_delete_condition; use_literal_path='true'; recursive_delete='false' } }
Write-Csv 'failure-delete-list.csv' @($deleteList)

$sourceInventory = foreach ($group in ($signoff | Group-Object source_path | Sort-Object Name)) {
    $relative = $group.Name
    $file = Get-Path $relative
    $expected = @($group.Group.source_sha256 | Sort-Object -Unique)
    $actual = Get-Sha $file
    $format = Get-Format $file
    $parsedRows = ''
    $parsedColumns = ''
    if ([System.IO.Path]::GetExtension($file) -ieq '.csv') {
        $parsed = @(Import-Csv -LiteralPath $file -Encoding UTF8)
        $parsedRows = $parsed.Count
        $parsedColumns = if ($parsed.Count) { @($parsed[0].PSObject.Properties.Name).Count } else { 0 }
    }
    [pscustomobject][ordered]@{ source_path=$relative; signoff_references=$group.Count; expected_sha256=Join-Values $expected; actual_sha256=$actual; bytes=(Get-Item -LiteralPath $file).Length; hash_match=([string]($expected.Count -eq 1 -and $expected[0] -ceq $actual)).ToLowerInvariant(); extension=[System.IO.Path]::GetExtension($file).ToLowerInvariant(); encoding=$format.encoding; bom=$format.bom; rows_if_csv=$parsedRows; columns_if_csv=$parsedColumns }
}
if (@($sourceInventory | Where-Object hash_match -cne 'true').Count -ne 0) { throw 'Signed source integrity failed.' }
Write-Csv 'signed-source-inventory.csv' @($sourceInventory)

$bindingRows = @(
    [pscustomobject][ordered]@{binding='formal_32_table_aggregate';path='正式32表';expected=$ExpectedAggregate;actual=$formalAggregate;match=([string]($formalAggregate -ceq $ExpectedAggregate)).ToLowerInvariant();rows='32'},
    [pscustomobject][ordered]@{binding='aws_486_row_signoff';path=$signoffRel;expected=$ExpectedSignoffHash;actual=(Get-Sha $signoffPath);match=([string]((Get-Sha $signoffPath) -ceq $ExpectedSignoffHash)).ToLowerInvariant();rows=$signoff.Count},
    [pscustomobject][ordered]@{binding='independent_23_row_signoff';path=$independentRel;expected=$ExpectedIndependentHash;actual=(Get-Sha $independentPath);match=([string]((Get-Sha $independentPath) -ceq $ExpectedIndependentHash)).ToLowerInvariant();rows=$independent.Count},
    [pscustomobject][ordered]@{binding='reviewed_package_manifest';path=$packageManifestRel;expected=$ExpectedPackageManifestHash;actual=(Get-Sha $packageManifestPath);match=([string]((Get-Sha $packageManifestPath) -ceq $ExpectedPackageManifestHash)).ToLowerInvariant();rows=$packageManifest.Count},
    [pscustomobject][ordered]@{binding='reviewed_package_manifest_aggregate';path=$packageManifestRel;expected=$ExpectedPackageAggregate;actual=$packageAggregate;match=([string]($packageAggregate -ceq $ExpectedPackageAggregate)).ToLowerInvariant();rows=$packageManifest.Count},
    [pscustomobject][ordered]@{binding='staging_freeze_manifest';path=$freezeRel;expected=$ExpectedFreezeHash;actual=(Get-Sha $freezePath);match=([string]((Get-Sha $freezePath) -ceq $ExpectedFreezeHash)).ToLowerInvariant();rows=$freeze.Count},
    [pscustomobject][ordered]@{binding='staging_freeze_aggregate';path=$freezeRel;expected=$ExpectedFreezeAggregate;actual=$freezeAggregate;match=([string]($freezeAggregate -ceq $ExpectedFreezeAggregate)).ToLowerInvariant();rows=$freeze.Count},
    [pscustomobject][ordered]@{binding='lifecycle_manifest';path=$lifecycleRel;expected=$ExpectedLifecycleHash;actual=(Get-Sha $lifecyclePath);match=([string]((Get-Sha $lifecyclePath) -ceq $ExpectedLifecycleHash)).ToLowerInvariant();rows=$lifecycle.Count}
)
Write-Csv 'binding-integrity.csv' $bindingRows

$backupRows = foreach ($row in ($writeInventory | Sort-Object commit_order)) {
    [pscustomobject][ordered]@{backup_class='authorized_write_table';required='true';source_path=$row.table_path;backup_relative_path=('formal-premerge/write-tables/'+$row.table_path);sha256=$row.current_sha256;bytes=$row.current_bytes;restore_action='byte_exact_replace';restore_order=$row.rollback_order;reason='462 CSV write authorizations touch this table'}
}
$backupRows += foreach ($row in $guardTableInventory) {
    [pscustomobject][ordered]@{backup_class='guard_only_table';required='defensive';source_path=$row.table_path;backup_relative_path=('formal-premerge/guard-only/'+$row.table_path);sha256=$row.sha256;bytes=$row.bytes;restore_action='byte_exact_replace_if_unauthorized_change';restore_order='after_authorized_table_restore';reason='9 no-write guards; full-table copy protects against executor defects'}
}
Write-Csv 'recommended-backup-set.csv' @($backupRows)

$transactionRows = [System.Collections.Generic.List[object]]::new()
$transactionRows.Add([pscustomobject][ordered]@{phase_order=10;operation='preflight_all';target='32 tables + bindings + 9 guards + 15 absent targets';success_condition='all signed hashes, rows and absence gates match';failure_action='stop_before_write'})
$transactionRows.Add([pscustomobject][ordered]@{phase_order=20;operation='generate_isolated_result';target='controlled same-volume temporary root';success_condition='reviewed 486-row semantics replayed; record 20 posthashes';failure_action='discard temporary result'})
$transactionRows.Add([pscustomobject][ordered]@{phase_order=30;operation='validate_isolated_result';target='32 tables + 15 files';success_condition='gate validator PASS 106160; 477 writes and 9 guards verified';failure_action='discard temporary result'})
$transactionRows.Add([pscustomobject][ordered]@{phase_order=40;operation='copy_new_payloads';target='15 absent targets';success_condition='all byte hashes and sizes match; journal each created file';failure_action='delete only journaled matching files'})
foreach ($row in ($writeInventory | Sort-Object commit_order)) {
    $transactionRows.Add([pscustomobject][ordered]@{phase_order=(100+[int]$row.commit_order);operation='atomic_single_file_replace';target=$row.table_path;success_condition='replacement hash equals isolated posthash; journal committed';failure_action=('restore backups in reverse order starting '+$row.rollback_order)})
}
$transactionRows.Add([pscustomobject][ordered]@{phase_order=200;operation='postwrite_acceptance';target='formal root';success_condition='gate PASS 106160; 20 posthashes; 15 payload hashes; 9 guards; no unauthorized changes';failure_action='restore 20 tables in reverse commit order, then delete 15 journaled files'})
Write-Csv 'transaction-order.csv' @($transactionRows)

$acceptance = @(
 [pscustomobject][ordered]@{check_order=1;stage='before';check='exclusive transaction lock';expected='no concurrent formal writers'},
 [pscustomobject][ordered]@{check_order=2;stage='before';check='32-table aggregate';expected=$ExpectedAggregate},
 [pscustomobject][ordered]@{check_order=3;stage='before';check='20 table prehashes';expected='all match write-table-inventory.csv'},
 [pscustomobject][ordered]@{check_order=4;stage='before';check='signed artifacts';expected='8/8 binding-integrity rows match'},
 [pscustomobject][ordered]@{check_order=5;stage='before';check='9 full-row guards';expected='all table and canonical-row hashes match'},
 [pscustomobject][ordered]@{check_order=6;stage='before';check='15 payload targets';expected='all absent; all source hashes and sizes match'},
 [pscustomobject][ordered]@{check_order=7;stage='before';check='backup verification';expected='20 mandatory + 3 defensive copies byte-exact; backup manifest durable'},
 [pscustomobject][ordered]@{check_order=8;stage='isolated';check='replay authorization';expected='477 writes; 9 guards; no extra table, PK or column'},
 [pscustomobject][ordered]@{check_order=9;stage='isolated';check='posthash manifest';expected='20 generated table hashes recorded before commit'},
 [pscustomobject][ordered]@{check_order=10;stage='isolated';check='gate validator';expected='PASS 106160 checks'},
 [pscustomobject][ordered]@{check_order=11;stage='after';check='row counts';expected='objects=78;relations=27;facts=678;assertions=680;requirements=863;runs=8;members=96'},
 [pscustomobject][ordered]@{check_order=12;stage='after';check='card count';expected='40 accepted nested card files'},
 [pscustomobject][ordered]@{check_order=13;stage='after';check='20 table posthashes';expected='all equal isolated result'},
 [pscustomobject][ordered]@{check_order=14;stage='after';check='15 payload files';expected='all expected hashes and sizes'},
 [pscustomobject][ordered]@{check_order=15;stage='after';check='9 guards';expected='table and row hashes unchanged'},
 [pscustomobject][ordered]@{check_order=16;stage='after';check='12 untouched formal tables';expected='all prehashes unchanged'},
 [pscustomobject][ordered]@{check_order=17;stage='after';check='gate validator';expected='PASS 106160 checks'},
 [pscustomobject][ordered]@{check_order=18;stage='after';check='transaction journal';expected='35 committed targets and acceptance hashes recorded; lock released only after PASS'}
)
Write-Csv 'postmerge-acceptance-checklist.csv' $acceptance

$summary = [ordered]@{
    status='STATIC_PREFLIGHT_PASS'
    date='2026-08-13'
    formal_tables=32
    formal_aggregate=$formalAggregate
    signoff_rows=486
    authorized_writes=477
    csv_writes=462
    copied_files=15
    no_write_guards=9
    write_tables=$writeTables.Count
    guard_only_tables=$guardTables.Count
    signed_source_files=$sourceInventory.Count
    payload_targets_absent=@($payloadInventory | Where-Object target_exists -ceq 'false').Count
    signed_table_posthashes=0
    posthash_note='486-row and 23-row signoffs do not carry expected postmerge hashes for the 20 CSV tables.'
    reconstructible_from_signoff_alone=$false
    reconstructible_with_bound_premerge_tables_sources_and_serialization=$true
}
Write-Text (Join-Path $OutDir 'static-preflight-summary.json') (($summary | ConvertTo-Json -Depth 5) + "`r`n")
"PASS: static AWS backup preflight; 32 formal tables; 20 write tables; 462 CSV writes; 15 file copies; 9 guards."