#Requires -Version 5.1
[CmdletBinding()]
param([string]$RootPath = '.')

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$root = (Resolve-Path -LiteralPath $RootPath).Path.TrimEnd('\')
$outDir = Join-Path $root '审计\子代理交接\aws_post_field_rebase'
$priorSignoffPath = Join-Path $root '审计\子代理交接\aws_signoff_rebase\aws-signoff-rebase.csv'
$originalSignoffPath = Join-Path $root '审计\子代理交接\m2_final_review_aws_package_merge_signoff.csv'
$fieldSignoffPath = Join-Path $root '审计\子代理交接\field_subject_contract_remediation_independent_review\formal-migration-accept-signoff.csv'
$fieldPackageManifestPath = Join-Path $root '审计\子代理交接\field_subject_contract_remediation\manifest.csv'
$bindingId = 'AWS-SIGNOFF-POST-FIELD-CONTRACT-20260813'
$expectedPriorSignoffHash = '9429d80f0ba649724ed1276523df8ecfcf269e6e748b15a6cbe4dd11013b42c0'
$expectedOriginalSignoffHash = '58f2368764e4fb132fe63a5acc427f22cdace7c38538270a7457e566d19bbd05'
$expectedPriorAggregate = '97ebb17a2518e3a43b18a382dcfc879c1f5e2b08118a6149c8fa984e65017453'
$expectedCurrentAggregate = 'd10ad305a820f0fc1db7f2bf7030ca149ea7b556ceacd0a32d593f08a7cc01ff'
$expectedFieldSignoffHash = '10a1e1f177f41ed2845ea7a6a1c28bbc375de2deb053a25a2610d6dac3fb0d02'
$expectedFieldPackageManifestHash = '16d721dde2c39154d40d6c3cef6f6525ac8fd24ef5e3c7ad29c2daef94fa0239'

function Assert-Check { param([bool]$Condition,[string]$Message) if(-not $Condition){throw $Message} }
function Get-Sha256 { param([string]$Path) (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-TextSha256 {
    param([string]$Text)
    $sha=[Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash([Text.UTF8Encoding]::new($false).GetBytes($Text)))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}
function Get-ChildPath {
    param([string]$Base,[string]$RelativePath)
    $full=[IO.Path]::GetFullPath((Join-Path $Base $RelativePath.Replace('/','\')))
    $prefix=[IO.Path]::GetFullPath($Base).TrimEnd('\')+'\'
    Assert-Check ($full.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) "Path escapes root: $RelativePath"
    $full
}
function Write-CsvNoBom {
    param([string]$Path,[object[]]$Rows)
    Assert-Check ($Rows.Count -gt 0) "Refusing empty CSV: $Path"
    $text=(@($Rows|ConvertTo-Csv -NoTypeInformation)-join "`r`n")+"`r`n"
    [IO.File]::WriteAllText($Path,$text,[Text.UTF8Encoding]::new($false))
}
function Write-JsonNoBom {
    param([string]$Path,$Value)
    [IO.File]::WriteAllText($Path,(($Value|ConvertTo-Json -Depth 14)+"`r`n"),[Text.UTF8Encoding]::new($false))
}
function Get-Baseline {
    param([string]$BaseRoot)
    $schema=@(Import-Csv -LiteralPath (Join-Path $BaseRoot '数据\schema-columns.csv') -Encoding UTF8)
    $paths=@($schema.table_path|Sort-Object -Unique)
    Assert-Check ($paths.Count -eq 32) "Formal table count is $($paths.Count), expected 32"
    $rows=foreach($rel in $paths){
        $p=Get-ChildPath -Base $BaseRoot -RelativePath $rel
        $data=@(Import-Csv -LiteralPath $p -Encoding UTF8)
        $headers=if($data.Count -gt 0){@($data[0].PSObject.Properties.Name)}else{@()}
        [pscustomobject][ordered]@{table_path=$rel;sha256=Get-Sha256 $p;bytes=(Get-Item -LiteralPath $p).Length;rows=$data.Count;columns=$headers.Count}
    }
    $payload=(@($rows|Sort-Object table_path|ForEach-Object{"$($_.table_path)|$($_.sha256)"})-join "`n")
    [pscustomobject]@{Aggregate=Get-TextSha256 $payload;Rows=@($rows);SchemaRows=$schema.Count}
}

Assert-Check (Test-Path -LiteralPath $outDir -PathType Container) "Missing output directory: $outDir"
$newSignoffPath=Join-Path $outDir 'aws-signoff-post-field-rebase.csv'
Assert-Check (-not (Test-Path -LiteralPath $newSignoffPath)) 'Refusing to overwrite an existing post-field signoff.'
Assert-Check ((Get-Sha256 $priorSignoffPath) -ceq $expectedPriorSignoffHash) 'Prior rebase signoff hash mismatch.'
Assert-Check ((Get-Sha256 $originalSignoffPath) -ceq $expectedOriginalSignoffHash) 'Original signoff hash mismatch.'
Assert-Check ((Get-Sha256 $fieldSignoffPath) -ceq $expectedFieldSignoffHash) 'Field migration signoff hash mismatch.'
Assert-Check ((Get-Sha256 $fieldPackageManifestPath) -ceq $expectedFieldPackageManifestHash) 'Field remediation manifest hash mismatch.'

$baseline=Get-Baseline -BaseRoot $root
Assert-Check ($baseline.Aggregate -ceq $expectedCurrentAggregate) "Current aggregate mismatch: $($baseline.Aggregate)"
Assert-Check ($baseline.SchemaRows -eq 324) "Schema row count is $($baseline.SchemaRows), expected 324"
$hashByTable=@{}
foreach($row in $baseline.Rows){$hashByTable[$row.table_path]=$row.sha256}
Assert-Check ($hashByTable['数据/fields.csv'] -ceq '1723cd5ef441ea12c53e785a4d2e2101f81ecdc5ce10872a02152cfb6539e2ee') 'Current fields hash mismatch.'
Assert-Check ($hashByTable['数据/field-requirements.csv'] -ceq '93c27127b6124331368e24ccec97c48620d2e85f08057d14d049d87edb91d347') 'Current field-requirements hash mismatch.'

$currentFields=@(Import-Csv -LiteralPath (Join-Path $root '数据\fields.csv') -Encoding UTF8)
$fieldHeaders=@($currentFields[0].PSObject.Properties.Name)
Assert-Check ($fieldHeaders.Count -eq 13) "Current fields.csv has $($fieldHeaders.Count) columns, expected 13"
Assert-Check ($fieldHeaders -ccontains 'allowed_requirement_target_kinds') 'Current fields.csv lacks allowed_requirement_target_kinds.'
$clock=@($currentFields|Where-Object field_id -ceq 'FIELD-PHY-CLOCK')
Assert-Check ($clock.Count -eq 1) 'FIELD-PHY-CLOCK missing or duplicate.'
Assert-Check ($clock[0].allowed_subject_kinds -ceq 'object;component') 'FIELD-PHY-CLOCK fact contract is not already satisfied.'
Assert-Check ($clock[0].allowed_requirement_target_kinds -ceq 'object;component;precision_path') 'FIELD-PHY-CLOCK requirement contract differs.'
$stagedFieldsPath=Join-Path $root '审计\子代理交接\m2_staging\M2-W2-AWS-PACKAGE-FACTS-REMEDIATED\structured\fields.csv'
$stagedHeaderLine=Get-Content -LiteralPath $stagedFieldsPath -Encoding UTF8 -TotalCount 1
$stagedHeaders=@($stagedHeaderLine -split ',' | ForEach-Object { $_.Trim('"') })
Assert-Check ($stagedHeaders.Count -eq 12) "Frozen staged fields.csv has $($stagedHeaders.Count) columns, expected historical 12"
Assert-Check ($stagedHeaders -cnotcontains 'allowed_requirement_target_kinds') 'Frozen staged fields unexpectedly has the migrated requirement contract column.'

$prior=@(Import-Csv -LiteralPath $priorSignoffPath -Encoding UTF8)
Assert-Check ($prior.Count -eq 486) "Prior signoff rows: $($prior.Count)"
Assert-Check (@($prior.signoff_row_id|Sort-Object -Unique).Count -eq 486) 'Prior signoff IDs are not unique.'
Assert-Check (@($prior|Where-Object formal_baseline_aggregate_sha256 -cne $expectedPriorAggregate).Count -eq 0) 'Prior signoff aggregate binding differs.'
$priorField=@($prior|Where-Object signoff_row_id -ceq 'AWS-SIGN-0458')
Assert-Check ($priorField.Count -eq 1) 'Prior FIELD-PHY-CLOCK signoff row missing.'
Assert-Check ($priorField[0].authorization_scope -ceq 'exact_cell_write') 'Prior FIELD-PHY-CLOCK row is not exact_cell_write.'

$sourcePaths=@($prior.source_path|Where-Object{-not [string]::IsNullOrWhiteSpace($_)}|Sort-Object -Unique)
foreach($rel in $sourcePaths){
    $p=Get-ChildPath -Base $root -RelativePath $rel
    Assert-Check (Test-Path -LiteralPath $p -PathType Leaf) "Signed source missing: $rel"
    $expected=@($prior|Where-Object source_path -ceq $rel|Select-Object -ExpandProperty source_sha256 -Unique)
    Assert-Check ($expected.Count -eq 1) "Signed source has multiple hashes: $rel"
    Assert-Check ((Get-Sha256 $p) -ceq $expected[0]) "Signed source hash mismatch: $rel"
}

$new=[Collections.Generic.List[object]]::new()
foreach($old in $prior){
    $props=[ordered]@{}
    foreach($p in $old.PSObject.Properties){$props[$p.Name]=[string]$p.Value}
    if(-not [string]::IsNullOrWhiteSpace($old.formal_target_premerge_sha256)){
        Assert-Check ($hashByTable.ContainsKey($old.target_path)) "Bound target is not a formal table: $($old.signoff_row_id)"
        $props.formal_target_premerge_sha256=[string]$hashByTable[$old.target_path]
    }
    $props.formal_baseline_aggregate_sha256=$baseline.Aggregate
    if($old.signoff_row_id -ceq 'AWS-SIGN-0458'){
        $props.authorization_scope='no_write_guard'
        $props.action_type='preserve_existing_no_write'
        $props.semantic_status_preserved='true_already_satisfied_full_row_guard'
        $props.binding_id='FIELD-CONTRACT-AWS-ALREADY-SATISFIED-GUARD'
        $props.reviewer='aws_post_field_rebase'
        $props.notes='字段主体合同正式迁移已先行把 allowed_subject_kinds 写成 object;component，并新增 allowed_requirement_target_kinds。本行撤销旧 exact_cell_write，改为当前 13 列 fields.csv 的整行 no_write_guard；禁止用 frozen staging 的 12 列 fields.csv 覆盖。rebase_binding=AWS-SIGNOFF-REBASE-GOOGLE-SOURCE-GATE-20260813;post_field_rebase_binding='+$bindingId
    } else {
        $props.notes=([string]$old.notes).TrimEnd()+';post_field_rebase_binding='+$bindingId
    }
    $new.Add([pscustomobject]$props)
}
Write-CsvNoBom -Path $newSignoffPath -Rows @($new)
$newHash=Get-Sha256 $newSignoffPath
$newRows=@(Import-Csv -LiteralPath $newSignoffPath -Encoding UTF8)
Assert-Check ($newRows.Count -eq 486) 'New signoff row count differs.'
Assert-Check (@($newRows|Where-Object authorization_scope -cne 'no_write_guard').Count -eq 477) 'New write count is not 477.'
Assert-Check (@($newRows|Where-Object authorization_scope -ceq 'no_write_guard').Count -eq 9) 'New guard count is not 9.'
Assert-Check (@($newRows|Where-Object authorization_scope -ceq 'exact_cell_write').Count -eq 0) 'Exact-cell write remains after overlap adjudication.'
Assert-Check (@($newRows|Where-Object { $_.target_path -ceq '数据/fields.csv' -and $_.authorization_scope -cne 'no_write_guard' }).Count -eq 0) 'New signoff still authorizes a fields.csv write.'

$diffs=[Collections.Generic.List[object]]::new()
$headers=@($prior[0].PSObject.Properties.Name)
for($i=0;$i -lt $prior.Count;$i++){
    foreach($column in $headers){
        $a=[string]$prior[$i].$column; $b=[string]$newRows[$i].$column
        if($a -cne $b){
            $allowed=($column -in @('formal_target_premerge_sha256','formal_baseline_aggregate_sha256','notes')) -or ($prior[$i].signoff_row_id -ceq 'AWS-SIGN-0458' -and $column -in @('authorization_scope','action_type','semantic_status_preserved','binding_id','reviewer'))
            $diffs.Add([pscustomobject][ordered]@{signoff_row_id=$prior[$i].signoff_row_id;column_name=$column;old_value=$a;new_value=$b;allowed_change=$allowed.ToString().ToLowerInvariant()})
        }
    }
}
Assert-Check (@($diffs|Where-Object allowed_change -cne 'true').Count -eq 0) 'Forbidden signoff cell change detected.'
$targetDiffs=@($diffs|Where-Object column_name -ceq 'formal_target_premerge_sha256')
Assert-Check ($targetDiffs.Count -eq 72) "Target-hash diff count is $($targetDiffs.Count), expected 72"
$expectedRequirementRebindIds=@($prior|Where-Object { $_.target_path -ceq '数据/field-requirements.csv' }|Select-Object -ExpandProperty signoff_row_id)
Assert-Check (@($targetDiffs|Where-Object { $_.signoff_row_id -ne 'AWS-SIGN-0458' -and $_.signoff_row_id -notin $expectedRequirementRebindIds }).Count -eq 0) 'Unexpected target-hash rebind row.'
Assert-Check (@($diffs|Where-Object column_name -ceq 'formal_baseline_aggregate_sha256').Count -eq 486) 'Aggregate diff count is not 486.'
Assert-Check (@($diffs|Where-Object column_name -ceq 'notes').Count -eq 486) 'Notes diff count is not 486.'
Write-CsvNoBom -Path (Join-Path $outDir 'prior-to-new-cell-diff.csv') -Rows @($diffs)
Write-CsvNoBom -Path (Join-Path $outDir 'formal-baseline-hashes.csv') -Rows @($baseline.Rows)

$overlap=[pscustomobject][ordered]@{
    signoff_row_id='AWS-SIGN-0458';field_id='FIELD-PHY-CLOCK';prior_scope='exact_cell_write';prior_action='update_existing_cell';prior_expected_old_value='object';package_proposed_value='object;component';current_allowed_subject_kinds=$clock[0].allowed_subject_kinds;current_allowed_requirement_target_kinds=$clock[0].allowed_requirement_target_kinds;current_fields_columns=$fieldHeaders.Count;frozen_staged_fields_columns=$stagedHeaders.Count;new_scope='no_write_guard';new_action='preserve_existing_no_write';authorized_write_count=0;adjudication='already_satisfied_by_field_subject_contract_migration';verdict='accept'
}
Write-CsvNoBom -Path (Join-Path $outDir 'field-contract-overlap-adjudication.csv') -Rows @($overlap)

$inputRoots=@(
 '审计/子代理交接/m2_staging/M2-W2-AWS-PACKAGE-FACTS-REMEDIATED',
 '审计/子代理交接/m2_final_review_aws_package.md',
 '审计/子代理交接/m2_final_review_aws_package_merge_signoff.csv',
 '审计/子代理交接/m2_final_review_aws_package_cards',
 '审计/子代理交接/aws_signoff_rebase',
 '审计/子代理交接/aws_merge_rehearsal',
 '审计/子代理交接/field_subject_contract_remediation',
 '审计/子代理交接/field_subject_contract_remediation_independent_review'
)
$inputFiles=[Collections.Generic.List[string]]::new()
foreach($rel in $inputRoots){
    $p=Get-ChildPath -Base $root -RelativePath $rel
    if(Test-Path -LiteralPath $p -PathType Leaf){$inputFiles.Add($p)}else{foreach($f in Get-ChildItem -LiteralPath $p -Recurse -File){$inputFiles.Add($f.FullName)}}
}
$inputAudit=foreach($p in @($inputFiles|Sort-Object -Unique)){
    $bytes=[IO.File]::ReadAllBytes($p)
    $relative=$p.Substring($root.Length+1).Replace('\','/')
    $ext=[IO.Path]::GetExtension($p).ToLowerInvariant()
    $parsedRows='';$parsedColumns='';$readMode='bytes'
    if($ext -ceq '.csv'){$d=@(Import-Csv -LiteralPath $p -Encoding UTF8);$parsedRows=$d.Count;$parsedColumns=if($d.Count -gt 0){@($d[0].PSObject.Properties.Name).Count}else{0};$readMode='bytes_and_csv_parse'}
    elseif($ext -in @('.md','.ps1','.json','.txt','.html')){[void][IO.File]::ReadAllText($p,[Text.Encoding]::UTF8);$readMode='bytes_and_utf8_text'}
    [pscustomobject][ordered]@{relative_path=$relative;bytes=$bytes.Length;sha256=Get-Sha256 $p;read_mode=$readMode;parsed_rows=$parsedRows;parsed_columns=$parsedColumns}
}
Write-CsvNoBom -Path (Join-Path $outDir 'input-read-audit.csv') -Rows @($inputAudit)

$binding=[ordered]@{
 binding_id=$bindingId;verdict='pending_strict_rehearsal';reviewer='aws_post_field_rebase';date='2026-08-13';
 prior_rebase_signoff=[ordered]@{path='审计/子代理交接/aws_signoff_rebase/aws-signoff-rebase.csv';sha256=$expectedPriorSignoffHash;rows=486;writes=478;guards=8;aggregate=$expectedPriorAggregate};
 field_contract_migration=[ordered]@{independent_signoff_sha256=$expectedFieldSignoffHash;remediation_manifest_sha256=$expectedFieldPackageManifestHash;current_fields_columns=13;frozen_staged_fields_columns=12;field_clock_already_satisfied=$true};
 current_baseline=[ordered]@{aggregate=$baseline.Aggregate;formal_tables=32;schema_rows=$baseline.SchemaRows;fields_sha256=$hashByTable['数据/fields.csv'];field_requirements_sha256=$hashByTable['数据/field-requirements.csv']};
 post_field_signoff=[ordered]@{path='审计/子代理交接/aws_post_field_rebase/aws-signoff-post-field-rebase.csv';sha256=$newHash;rows=486;writes=477;guards=9;exact_cell_writes=0;target_hash_cells_changed=72;aggregate_cells_changed=486;overlap_row='AWS-SIGN-0458'};
 input_read_audit=[ordered]@{files=$inputAudit.Count;path='审计/子代理交接/aws_post_field_rebase/input-read-audit.csv'}
}
Write-JsonNoBom -Path (Join-Path $outDir 'rebase-binding.json') -Value $binding
$summary=[ordered]@{status='PASS';current_aggregate=$baseline.Aggregate;prior_signoff_sha256=$expectedPriorSignoffHash;new_signoff_sha256=$newHash;signoff_rows=486;authorized_writes=477;no_write_guards=9;exact_cell_writes=0;target_hash_cell_diffs=72;aggregate_cell_diffs=486;input_files_read=$inputAudit.Count;field_overlap='already_satisfied_no_write_guard'}
Write-JsonNoBom -Path (Join-Path $outDir 'build-summary.json') -Value $summary
$summary|ConvertTo-Json -Compress