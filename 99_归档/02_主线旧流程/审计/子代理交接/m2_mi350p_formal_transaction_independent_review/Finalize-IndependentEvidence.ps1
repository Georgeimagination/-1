param(
    [Parameter(Mandatory=$true)][string]$ProjectRoot,
    [Parameter(Mandatory=$true)][string]$ReviewRoot,
    [Parameter(Mandatory=$true)][string]$PrepRoot
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$Utf8 = New-Object System.Text.UTF8Encoding($false)
$script:Checks = 0
function Assert-Check([bool]$Condition,[string]$Message) {
    if (-not $Condition) { throw $Message }
    $script:Checks++
}
function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Get-TextSha256([string]$Text) {
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($algorithm.ComputeHash($Utf8.GetBytes($Text))).Replace('-','').ToLowerInvariant())
    }
    finally {
        $algorithm.Dispose()
    }
}
function Get-Sequence([object[]]$Rows,[string]$Phase,[string]$Kind) {
    return @($Rows | Where-Object { $_.phase -ceq $Phase -and $_.kind -ceq $Kind } | ForEach-Object { [string]$_.relative_path })
}
function Is-Reverse([string[]]$Forward,[string[]]$Reverse) {
    if ($Forward.Count -ne $Reverse.Count) { return $false }
    for ($i=0; $i -lt $Forward.Count; $i++) {
        if ($Forward[$i] -cne $Reverse[$Forward.Count - 1 - $i]) { return $false }
    }
    return $true
}

$ExpectedManifest = 'c21612350bae17288e365d26f95b5f669426ba99fd33cefce746644986cb3c98'
$ExpectedPackageAggregate = 'e7138b42baee6b2d138cb5d8f31593c4f6c62319fa16688e866b840d2e419949'
$ExpectedFormal = 'f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedCandidate = '28923f7aa9dea488152f699e6879319d1fb96222fe72745754cf8ffd7b46518e'
$ExpectedSignoff = '74ac69c299f5ce817c03236ef97df4e13f08f2d6724bb1c0178376661be5dad1'
$ExpectedFinalReview = '470d381d66e5cb7ccd7b3fc9aa88ede12ed1a995a6a1af6e03844630d9b43461'
$ExpectedFreeze = '1cb279b56f4fbfc688ed2f798646a93baed02ffbd34a647ffecf4cb6672f0e01'
$ExpectedPosthash = '49e57afa591d265717ca1bc08bb59d4efd86c81f6a571b4715f22226907b0074'

$manifestPath = Join-Path $PrepRoot 'manifest.csv'
Assert-Check ((Get-Sha256 $manifestPath) -ceq $ExpectedManifest) 'Original prep manifest hash differs.'
$manifest = @(Import-Csv -LiteralPath $manifestPath -Encoding UTF8)
Assert-Check ($manifest.Count -eq 67) 'Original prep manifest row count differs.'
foreach ($row in $manifest) {
    $path = Join-Path $PrepRoot ($row.relative_path.Replace('/','\'))
    Assert-Check (Test-Path -LiteralPath $path -PathType Leaf) ('Missing prep member: ' + $row.relative_path)
    Assert-Check ((Get-Sha256 $path) -ceq [string]$row.sha256) ('Prep member hash differs: ' + $row.relative_path)
    Assert-Check ([string](Get-Item -LiteralPath $path).Length -ceq [string]$row.bytes) ('Prep member bytes differ: ' + $row.relative_path)
}
$aggregateLines = @($manifest | Where-Object in_aggregate -ceq 'true' | Sort-Object relative_path | ForEach-Object { $_.relative_path + '|' + $_.sha256 + '|' + $_.bytes })
$packageAggregate = Get-TextSha256 ($aggregateLines -join [char]10)
Assert-Check ($packageAggregate -ceq $ExpectedPackageAggregate) 'Prep aggregate differs.'

$checkpointPath = Join-Path $ReviewRoot 'review-checkpoint.json'
$checkpoint = Get-Content -LiteralPath $checkpointPath -Raw -Encoding UTF8 | ConvertFrom-Json
Assert-Check ([string]$checkpoint.prep.manifest_sha256 -ceq $ExpectedManifest) 'Checkpoint prep manifest differs.'
Assert-Check ([string]$checkpoint.prep.aggregate -ceq $ExpectedPackageAggregate) 'Checkpoint prep aggregate differs.'
Assert-Check ([int]$checkpoint.prep.manifest_member_failures -eq 0) 'Checkpoint prep member failures are nonzero.'
Assert-Check ([int]$checkpoint.formal.member_failures -eq 0) 'Checkpoint formal member failures are nonzero.'
Assert-Check ([string]$checkpoint.formal.aggregate -ceq $ExpectedFormal) 'Checkpoint formal aggregate differs.'
Assert-Check ([int]$checkpoint.signed_data.signoff_rows -eq 274) 'Signoff row count differs.'
Assert-Check ([int]$checkpoint.signed_data.lifecycle_pk_writes -eq 270) 'Lifecycle write count differs.'
Assert-Check ([int]$checkpoint.signed_data.file_payloads -eq 4) 'Payload count differs.'
Assert-Check ([int]$checkpoint.signed_data.write_tables -eq 19) 'Write table count differs.'
Assert-Check ([int]$checkpoint.signed_data.guards -eq 3) 'Guard count differs.'
Assert-Check ([int]$checkpoint.signed_data.absent_targets -eq 4) 'Absent target count differs.'

$scriptBindings = [ordered]@{
    transaction_script_sha256 = Get-Sha256 (Join-Path $PrepRoot 'scripts\Invoke-MI350PFormalTransaction.ps1')
    preflight_script_sha256 = Get-Sha256 (Join-Path $PrepRoot 'scripts\Test-MI350PFormalTransactionPreflight.ps1')
    rehearsal_script_sha256 = Get-Sha256 (Join-Path $PrepRoot 'scripts\Test-MI350PFormalTransactionRehearsal.ps1')
}
Assert-Check ($scriptBindings.transaction_script_sha256 -ceq '2967a9d0a023268438ddb3bcc139910ce1404faceb3fae63f1a42a27eda2e6a9') 'Transaction script hash differs.'
Assert-Check ($scriptBindings.preflight_script_sha256 -ceq '6547bda349d55585ffd55fbd538fe910b9a950b67902febf876476ebd4a45dc4') 'Preflight script hash differs.'
Assert-Check ($scriptBindings.rehearsal_script_sha256 -ceq '2e4e2662d16867472aa517914ba758db75cda9f288638a262039a5008b71a470') 'Rehearsal script hash differs.'
Assert-Check ((Get-Sha256 (Join-Path $ProjectRoot '审计\子代理交接\m2_final_review_mi350p_signoff.csv')) -ceq $ExpectedSignoff) 'MI350P data signoff hash differs.'
Assert-Check ((Get-Sha256 (Join-Path $ProjectRoot '审计\子代理交接\m2_final_review_mi350p.md')) -ceq $ExpectedFinalReview) 'MI350P final review hash differs.'
Assert-Check ((Get-Sha256 (Join-Path $ProjectRoot '审计\子代理交接\m2_staging\M2-W3-AMD-MI350P-CARD\validation\staging-file-manifest.csv')) -ceq $ExpectedFreeze) 'MI350P staging freeze hash differs.'
Assert-Check ((Get-Sha256 (Join-Path $PrepRoot 'expected-candidate-19-table-posthashes.csv')) -ceq $ExpectedPosthash) 'Candidate posthash manifest differs.'

$evidence = Join-Path $ReviewRoot 'evidence'
$preflightText = Get-Content -LiteralPath (Join-Path $evidence 'preflight-output.txt') -Raw -Encoding UTF8
$validatorText = Get-Content -LiteralPath (Join-Path $evidence 'formal-baseline-validator-output.txt') -Raw -Encoding UTF8
$hardDenyText = Get-Content -LiteralPath (Join-Path $evidence 'formal-hard-deny-output.txt') -Raw -Encoding UTF8
Assert-Check ($preflightText -match '"checks":11290') 'Preflight evidence lacks 11290 checks.'
Assert-Check ($preflightText -match $ExpectedFormal) 'Preflight evidence lacks the formal aggregate.'
Assert-Check ($validatorText -match '106160 checks executed') 'Formal baseline validator evidence lacks 106160 checks.'
Assert-Check ($hardDenyText -match 'denied by default') 'Formal hard-deny evidence is missing.'

$positive = Get-Content -LiteralPath (Join-Path $evidence 'positive-transaction-outcome.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$positiveJournal = @(Import-Csv -LiteralPath (Join-Path $evidence 'positive-journal.csv') -Encoding UTF8)
Assert-Check ([string]$positive.status -ceq 'PASS') 'Positive outcome differs.'
Assert-Check ([int]$positive.candidate_validator_checks -eq 111390) 'Positive candidate validator count differs.'
Assert-Check ([int]$positive.post_commit_validator_checks -eq 111390) 'Positive post-commit validator count differs.'
Assert-Check ([string]$positive.candidate_32_table_aggregate -ceq $ExpectedCandidate) 'Positive candidate aggregate differs.'
Assert-Check ([string]$positive.post_commit_32_table_aggregate -ceq $ExpectedCandidate) 'Positive commit aggregate differs.'
Assert-Check ($positiveJournal.Count -eq 48) 'Positive journal row count differs.'
Assert-Check ((Get-Sequence $positiveJournal 'commit_complete' 'csv_replace').Count -eq 19) 'Positive table commit count differs.'
Assert-Check ((Get-Sequence $positiveJournal 'commit_complete' 'payload_copy').Count -eq 4) 'Positive payload commit count differs.'

$three = Get-Content -LiteralPath (Join-Path $evidence 'rollback-after-3-tables-outcome.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$threeJournal = @(Import-Csv -LiteralPath (Join-Path $evidence 'rollback-after-3-tables-journal.csv') -Encoding UTF8)
$threeCommit = Get-Sequence $threeJournal 'commit_complete' 'csv_replace'
$threeRollback = Get-Sequence $threeJournal 'rollback_complete' 'csv_restore'
Assert-Check ([string]$three.status -ceq 'FAIL_ROLLED_BACK') 'Three-table outcome differs.'
Assert-Check ([bool]$three.rollback_succeeded) 'Three-table rollback did not succeed.'
Assert-Check ([string]$three.error -ceq 'INJECTED_TEST_FAILURE_AFTER_3_REPLACEMENTS') 'Three-table injection point differs.'
Assert-Check ($threeJournal.Count -eq 14) 'Three-table journal row count differs.'
Assert-Check ($threeCommit.Count -eq 3 -and $threeRollback.Count -eq 3) 'Three-table commit or rollback count differs.'
Assert-Check (Is-Reverse $threeCommit $threeRollback) 'Three-table rollback is not reverse order.'
Assert-Check ([string]$three.formal_baseline_aggregate -ceq $ExpectedFormal) 'Three-table rollback aggregate differs.'

$two = Get-Content -LiteralPath (Join-Path $evidence 'rollback-after-2-payloads-outcome.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$twoJournal = @(Import-Csv -LiteralPath (Join-Path $evidence 'rollback-after-2-payloads-journal.csv') -Encoding UTF8)
$twoTableCommit = Get-Sequence $twoJournal 'commit_complete' 'csv_replace'
$twoTableRollback = Get-Sequence $twoJournal 'rollback_complete' 'csv_restore'
$twoPayloadCommit = Get-Sequence $twoJournal 'commit_complete' 'payload_copy'
$twoPayloadRollback = Get-Sequence $twoJournal 'rollback_complete' 'payload_delete'
Assert-Check ([string]$two.status -ceq 'FAIL_ROLLED_BACK') 'Two-payload outcome differs.'
Assert-Check ([bool]$two.rollback_succeeded) 'Two-payload rollback did not succeed.'
Assert-Check ([string]$two.error -ceq 'INJECTED_TEST_FAILURE_AFTER_2_PAYLOADS') 'Two-payload injection point differs.'
Assert-Check ($twoJournal.Count -eq 86) 'Two-payload journal row count differs.'
Assert-Check ($twoTableCommit.Count -eq 19 -and $twoTableRollback.Count -eq 19) 'Two-payload table count differs.'
Assert-Check (Is-Reverse $twoTableCommit $twoTableRollback) 'Two-payload table rollback is not reverse order.'
Assert-Check ($twoPayloadCommit.Count -eq 2 -and $twoPayloadRollback.Count -eq 2) 'Two-payload count differs.'
Assert-Check (Is-Reverse $twoPayloadCommit $twoPayloadRollback) 'Two-payload rollback is not reverse order.'
Assert-Check ([string]$two.formal_baseline_aggregate -ceq $ExpectedFormal) 'Two-payload rollback aggregate differs.'

$negative = @(Import-Csv -LiteralPath (Join-Path $evidence 'negative-gates.csv') -Encoding UTF8)
Assert-Check ($negative.Count -eq 6) 'Negative gate count differs.'
Assert-Check (@($negative | Where-Object status -cne 'passed').Count -eq 0) 'A negative gate failed.'
Assert-Check (@($negative | Where-Object pattern_match -cne 'True').Count -eq 0) 'A negative gate pattern did not match.'
Assert-Check (@($negative | Where-Object formal_aggregate_after -cne $ExpectedFormal).Count -eq 0) 'A negative gate changed the source aggregate.'
Assert-Check (@($negative | Where-Object formal_targets_absent -cne 'True').Count -eq 0) 'A negative gate left a target.'

$packageRoot = Join-Path $ReviewRoot 'p'
$sourceRoot = Join-Path $ReviewRoot 'r'
$newFiles = @(Import-Csv -LiteralPath (Join-Path $PrepRoot 'new-file-targets.csv') -Encoding UTF8)
$sourceTargetsPresent = 0
$formalTargetsPresent = 0
foreach ($item in $newFiles) {
    if (Test-Path -LiteralPath (Join-Path $sourceRoot ($item.target_path.Replace('/','\')))) { $sourceTargetsPresent++ }
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot ($item.target_path.Replace('/','\')))) { $formalTargetsPresent++ }
}
Assert-Check ($sourceTargetsPresent -eq 0) 'The isolated source root has a payload target.'
Assert-Check ($formalTargetsPresent -eq 0) 'The formal root has a payload target.'
Assert-Check (@(Get-ChildItem -LiteralPath $packageRoot -Force -Directory -Filter '.tmp-mi350p-formal-*').Count -eq 0) 'Transaction temp directories remain.'
Assert-Check (@(Get-ChildItem -LiteralPath (Join-Path $packageRoot 'scripts') -Force -File -Filter 'MI350P-FORMAL-TRANSACTION-LOCK-*.lock').Count -eq 0) 'Transaction lock files remain.'
Assert-Check (-not (Test-Path -LiteralPath 'Q:\')) 'Mapped drive Q remains.'

$errors = @(Import-Csv -LiteralPath (Join-Path $ReviewRoot 'operator-error-log.csv') -Encoding UTF8)
Assert-Check (@($errors | Where-Object formal_impact -cne '0').Count -eq 0) 'An operator error has formal impact.'

$summary = [ordered]@{
    status = 'passed'
    verdict = 'accept'
    ready_for_formal_execution = $true
    reviewer = 'm2_mi350p_formal_transaction_independent_review'
    review_date = '2026-08-13'
    checks = $Checks
    package = [ordered]@{
        manifest_sha256 = $ExpectedManifest
        manifest_rows = $manifest.Count
        aggregate_sha256 = $packageAggregate
        member_failures = 0
    }
    signed_scope = [ordered]@{
        signoff_rows = 274
        lifecycle_pk_writes = 270
        payloads = 4
        write_tables = 19
        no_write_guards = 3
        absent_file_targets = 4
    }
    baseline = [ordered]@{
        formal_32_table_aggregate = $ExpectedFormal
        validator_checks = 106160
        preflight_checks = 11290
        formal_hard_deny = 'passed'
    }
    rehearsals = [ordered]@{
        positive = [ordered]@{status='passed';journal_rows=48;tables=19;payloads=4;candidate_validator_checks=111390;candidate_aggregate=$ExpectedCandidate}
        rollback_after_3_tables = [ordered]@{status='passed';journal_rows=14;tables_committed=3;tables_rolled_back=3;reverse_order=$true;aggregate_after=$ExpectedFormal}
        rollback_after_2_payloads = [ordered]@{status='passed';journal_rows=86;tables_committed=19;tables_rolled_back=19;payloads_committed=2;payloads_rolled_back=2;reverse_order=$true;aggregate_after=$ExpectedFormal}
    }
    negative_gates = [ordered]@{status='passed';count=6;formal_writes=0}
    cleanup = [ordered]@{formal_targets_present=0;isolated_targets_present=0;temp_directories=0;lock_files=0;mapped_drive_present=$false}
    input_bindings = [ordered]@{
        final_review_report_sha256 = $ExpectedFinalReview
        mi350p_signoff_sha256 = $ExpectedSignoff
        freeze_manifest_sha256 = $ExpectedFreeze
        candidate_posthash_manifest_sha256 = $ExpectedPosthash
        transaction_script_sha256 = $scriptBindings.transaction_script_sha256
        preflight_script_sha256 = $scriptBindings.preflight_script_sha256
        rehearsal_script_sha256 = $scriptBindings.rehearsal_script_sha256
    }
    operator_errors = [ordered]@{count=$errors.Count;formal_impact=0;approval_or_sandbox_failures=0}
    formal_writes_performed = 0
}
$out = Join-Path $ReviewRoot 'independent-validation-summary.json'
[IO.File]::WriteAllText($out,(($summary | ConvertTo-Json -Depth 10) + [Environment]::NewLine),$Utf8)
Write-Output ('PASS independent evidence; ' + $Checks + ' checks; summary=' + (Get-Sha256 $out))