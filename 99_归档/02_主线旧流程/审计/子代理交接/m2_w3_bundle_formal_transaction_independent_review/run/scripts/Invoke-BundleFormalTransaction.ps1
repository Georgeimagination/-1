#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [string]$BackupRoot = '',
    [switch]$AllowFormalRoot,
    [string]$FormalAuthorizationToken = '',
    [string]$AuthorizationSignoffSha256 = '',
    [string]$TransactionReviewSignoffPath = '',
    [string]$ResultRoot = ''
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$script:Checks = 0

$ExpectedUpstreamBindingsSha256 = 'ac52660a807e67da48479f14bf90e65d596c5727b8c9c49cdbce3baa4e819bdb'
$ExpectedAuthorizedWriteSetSha256 = '0e1ad812779656e1e9f325317f87f0bb7de8edaa161475a421aa251b4058feb1'
$ExpectedNewFileTargetsSha256 = '0adc897a424712c254979c0cca9f2fef2624ca3779d1a1fa82e9436a9981cc0d'
$ExpectedNoWriteGuardsSha256 = '327b884efc6e0c3bc43539d03e0e27a269c3c8d16696967a3635e906cf9ce604'
$ExpectedBackupListSha256 = 'c2aa9ed5d15c591d60bbd39f5457a4a69c2cb7f7871680ebcf8c7d2ec0703b91'
$ExpectedFormalBaselineManifestSha256 = 'c8c424fa21838248cca020b6c5feefd9c05287adec8c077474f0f36cff834f5f'
$ExpectedFormalAggregate = 'f1520907d54e406e7d82f591e3799f07f569218aff0c321ac3b836b6c649da10'
$ExpectedValidatorChecks = 125619
$ExpectedCandidateAggregate = '5f62191bfc737535802cd6e0524b1fdf7a742ca36300db11b5a9233d4540052a'
$ExpectedCandidatePosthashSha256 = '78956df9394146d39ded5e6e0740157e4ccd9cc50e44699ec6f8b8eca0ea1394'
$ExpectedToken = 'M2W3-BUNDLE-FORMAL-MERGE-20260813-F1520907-5F62191B'
$IsolatedMarkerText = 'M2-W3-BUNDLE-ISOLATED-TRANSACTION'

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
    try { return ([BitConverter]::ToString($sha.ComputeHash($encoding.GetBytes($Text))).Replace('-', '').ToLowerInvariant()) }
    finally { $sha.Dispose() }
}

function Get-FormalAggregate {
    param([string]$Root, [string[]]$TablePaths)
    $pairs = foreach ($relative in ($TablePaths | Sort-Object)) {
        $path = Get-ChildPath -Root $Root -RelativePath $relative -MustExist $true
        $relative + '|' + (Get-Sha256 $path)
    }
    return Get-TextSha256 ($pairs -join [char]10)
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Text)
    $encoding = New-Object Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Write-CsvUtf8NoBomCrlf {
    param([string]$Path, [object[]]$Rows)
    Assert-Check ($Rows.Count -gt 0) "Refusing to persist empty CSV: $Path"
    $text = (@($Rows | ConvertTo-Csv -NoTypeInformation) -join ([char]13 + [char]10)) + [char]13 + [char]10
    Write-Utf8NoBom -Path $Path -Text $text
}

$SourceRoot = Get-ExistingRoot -Path $SourceRoot -Label 'SourceRoot'
$TargetRoot = Get-ExistingRoot -Path $TargetRoot -Label 'TargetRoot'
$WorkRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Split-Path -Parent $WorkRoot
$Preflight = Join-Path $WorkRoot 'Test-BundleFormalTransactionPreflight.ps1'
$ReplayEngine = Join-Path $WorkRoot 'Replay-BundleAuthorizedRows.ps1'
$Validator = Get-ChildPath -Root $SourceRoot -RelativePath 'scripts/validation/Validate-ResearchData.ps1' -MustExist $true
$WriteSetPath = Join-Path $PackageRoot 'authorized-write-set.csv'
$BackupListPath = Join-Path $PackageRoot 'formal-csv-backup-candidates.csv'
$GuardListPath = Join-Path $PackageRoot 'no-write-guards.csv'
$NewFileListPath = Join-Path $PackageRoot 'new-file-targets.csv'
$FormalBaselineManifestPath = Join-Path $PackageRoot 'formal-32-baseline.csv'
$UpstreamBindingsPath = Join-Path $PackageRoot 'upstream-bindings.csv'
$ExpectedCandidatePosthashPath = Join-Path $PackageRoot 'expected-candidate-20-table-posthashes.csv'

Assert-Check (Test-Path -LiteralPath $Preflight -PathType Leaf) 'Transaction preflight is missing.'
Assert-Check (Test-Path -LiteralPath $ReplayEngine -PathType Leaf) 'Transaction replay engine is missing.'
Assert-Check ((Get-Sha256 $WriteSetPath) -ceq $ExpectedAuthorizedWriteSetSha256) 'Authorized write-set SHA-256 differs.'
Assert-Check ((Get-Sha256 $BackupListPath) -ceq $ExpectedBackupListSha256) 'Backup-candidate list SHA-256 differs.'
Assert-Check ((Get-Sha256 $GuardListPath) -ceq $ExpectedNoWriteGuardsSha256) 'No-write guard list SHA-256 differs.'
Assert-Check ((Get-Sha256 $NewFileListPath) -ceq $ExpectedNewFileTargetsSha256) 'New-file target list SHA-256 differs.'
Assert-Check ((Get-Sha256 $FormalBaselineManifestPath) -ceq $ExpectedFormalBaselineManifestSha256) 'Formal baseline manifest SHA-256 differs.'
Assert-Check ((Get-Sha256 $UpstreamBindingsPath) -ceq $ExpectedUpstreamBindingsSha256) 'Upstream-bindings SHA-256 differs.'
Assert-Check ((Get-Sha256 $ExpectedCandidatePosthashPath) -ceq $ExpectedCandidatePosthashSha256) 'Expected candidate posthash manifest SHA-256 differs.'

$canonicalSource = [IO.Path]::GetFullPath($SourceRoot).TrimEnd('\')
$canonicalTarget = [IO.Path]::GetFullPath($TargetRoot).TrimEnd('\')
$isFormalRoot = $canonicalSource.Equals($canonicalTarget, [StringComparison]::OrdinalIgnoreCase)

$writeSet = @(Import-Csv -LiteralPath $WriteSetPath -Encoding UTF8)
$backupList = @(Import-Csv -LiteralPath $BackupListPath -Encoding UTF8)
$guardList = @(Import-Csv -LiteralPath $GuardListPath -Encoding UTF8)
$newFileList = @(Import-Csv -LiteralPath $NewFileListPath -Encoding UTF8)
$formalManifest = @(Import-Csv -LiteralPath $FormalBaselineManifestPath -Encoding UTF8)
$expectedCandidatePosthash = @(Import-Csv -LiteralPath $ExpectedCandidatePosthashPath -Encoding UTF8)
Assert-Check ($writeSet.Count -eq 1057) 'Authorized write set is not 1057 rows.'
Assert-Check ($backupList.Count -eq 20) 'Backup-candidate list is not 20 rows.'
Assert-Check ($guardList.Count -eq 11) 'Guard list is not 11 rows.'
Assert-Check ($newFileList.Count -eq 15) 'New-file target list is not 15 rows.'
Assert-Check ($formalManifest.Count -eq 32) 'Formal baseline manifest is not 32 rows.'
Assert-Check ($expectedCandidatePosthash.Count -eq 20) 'Expected candidate posthash manifest is not 20 rows.'
Assert-Check (@($writeSet.target_path | Sort-Object -Unique).Count -eq 20) 'Authorized write set does not cover exactly 20 tables.'
Assert-Check (@($backupList.target_path | Sort-Object -Unique).Count -eq 20) 'Backup-candidate paths are not unique.'
Assert-Check (@($newFileList.target_path | Sort-Object -Unique).Count -eq 15) 'New-file target paths are not unique.'
Assert-Check (@($guardList.target_path | Sort-Object -Unique).Count -eq 2) 'No-write guards do not cover exactly two guard tables.'
Assert-Check (@($formalManifest.relative_path | Sort-Object -Unique).Count -eq 32) 'Formal baseline manifest paths are not unique.'
Assert-Check (@($expectedCandidatePosthash.target_path | Sort-Object -Unique).Count -eq 20) 'Expected candidate posthash paths are not unique.'
Assert-Check ((@($writeSet.target_path | Sort-Object -Unique) -join [char]31) -ceq (@($backupList.target_path | Sort-Object -Unique) -join [char]31)) 'Write-set and backup-candidate table sets differ.'
Assert-Check ((@($backupList.target_path | Sort-Object) -join [char]31) -ceq (@($expectedCandidatePosthash.target_path | Sort-Object) -join [char]31)) 'Backup-candidate and expected-posthash table sets differ.'
if ($isFormalRoot) {
    Assert-Check ($AllowFormalRoot.IsPresent) 'Current formal root is denied by default. Supply -AllowFormalRoot only after the frozen bundle review, external backup, and authorization marker are complete.'
    Assert-Check ($FormalAuthorizationToken -ceq $ExpectedToken) 'Formal authorization token differs.'
    Assert-Check (-not [string]::IsNullOrWhiteSpace($BackupRoot)) 'BackupRoot is required for a formal-root transaction.'
    Assert-Check (-not [string]::IsNullOrWhiteSpace($TransactionReviewSignoffPath)) 'TransactionReviewSignoffPath is required for a formal-root transaction.'
    Assert-Check (Test-Path -LiteralPath $TransactionReviewSignoffPath -PathType Leaf) 'Bundle transaction-review signoff file is missing.'
    $TransactionReviewSignoffPath = (Resolve-Path -LiteralPath $TransactionReviewSignoffPath).Path
    $transactionReviewActualSha = Get-Sha256 $TransactionReviewSignoffPath
    Assert-Check (-not [string]::IsNullOrWhiteSpace($AuthorizationSignoffSha256)) 'AuthorizationSignoffSha256 is required for a formal-root transaction.'
    Assert-Check ($AuthorizationSignoffSha256.ToLowerInvariant() -ceq $transactionReviewActualSha) 'AuthorizationSignoffSha256 does not match the bundle transaction-review signoff file.'
    $transactionReview = @(Import-Csv -LiteralPath $TransactionReviewSignoffPath -Encoding UTF8)
    Assert-Check ($transactionReview.Count -eq 1) 'Bundle transaction-review signoff must contain exactly one row.'
    $transactionReviewRow = $transactionReview[0]
    $expectedReviewHeaders = @(
        'transaction_review_id','package_id','reviewer','review_date','authorization_scope','verdict',
        'ready_for_formal_execution','transaction_script_sha256','preflight_script_sha256',
        'rehearsal_script_sha256','package_manifest_sha256','package_aggregate_sha256',
        'upstream_bindings_sha256','formal_baseline_aggregate_sha256',
        'candidate_posthash_manifest_sha256','candidate_aggregate_sha256',
        'candidate_validator_checks','authorization_token_sha256','notes'
    )
    $actualReviewHeaders = @($transactionReviewRow.PSObject.Properties.Name)
    Assert-Check (($actualReviewHeaders -join [char]31) -ceq ($expectedReviewHeaders -join [char]31)) 'Bundle transaction-review signoff header differs.'
    Assert-Check ($transactionReviewRow.transaction_review_id -ceq 'M2W3-BUNDLE-FORMAL-TRANSACTION-REVIEW-20260813') 'Bundle transaction-review ID differs.'
    Assert-Check ($transactionReviewRow.package_id -ceq 'M2-W3-BUNDLE-FORMAL-TRANSACTION-V1') 'Bundle transaction-review package ID differs.'
    Assert-Check (-not [string]::IsNullOrWhiteSpace($transactionReviewRow.reviewer)) 'Bundle transaction-review reviewer is empty.'
    Assert-Check ($transactionReviewRow.reviewer -cne 'm2_w3_bundle_formal_transaction_prep') 'Bundle transaction-prep author cannot independently authorize formal execution.'
    Assert-Check ($transactionReviewRow.reviewer -cne 'm2_w3_bundle_transaction_audit') 'Bundle transaction-audit author cannot self-authorize formal execution.'
    Assert-Check ($transactionReviewRow.review_date -ceq '2026-08-13') 'Bundle transaction-review date differs.'
    Assert-Check ($transactionReviewRow.authorization_scope -ceq 'formal_execution_of_exact_1057_rows_15_payloads_via_bundle_transaction_v1') 'Bundle transaction-review authorization scope differs.'
    Assert-Check ($transactionReviewRow.verdict -ceq 'accept') 'Bundle transaction-review verdict is not accept.'
    Assert-Check ($transactionReviewRow.ready_for_formal_execution -ceq 'true') 'Bundle transaction review does not authorize formal execution.'
    Assert-Check ($transactionReviewRow.transaction_script_sha256 -ceq (Get-Sha256 $MyInvocation.MyCommand.Path)) 'Bundle transaction-review script binding differs.'
    Assert-Check ($transactionReviewRow.preflight_script_sha256 -ceq (Get-Sha256 $Preflight)) 'Bundle transaction-review preflight binding differs.'
    $rehearsalScript = Join-Path $WorkRoot 'Test-BundleFormalTransactionRehearsal.ps1'
    Assert-Check (Test-Path -LiteralPath $rehearsalScript -PathType Leaf) 'Bundle transaction rehearsal script is missing.'
    Assert-Check ($transactionReviewRow.rehearsal_script_sha256 -ceq (Get-Sha256 $rehearsalScript)) 'Bundle transaction-review rehearsal binding differs.'

    $packageManifest = Join-Path $PackageRoot 'manifest.csv'
    Assert-Check (Test-Path -LiteralPath $packageManifest -PathType Leaf) 'Frozen bundle transaction package manifest is missing.'
    Assert-Check ($transactionReviewRow.package_manifest_sha256 -ceq (Get-Sha256 $packageManifest)) 'Bundle transaction-review package-manifest binding differs.'
    $manifestRows = @(Import-Csv -LiteralPath $packageManifest -Encoding UTF8)
    Assert-Check ($manifestRows.Count -gt 0) 'Frozen bundle transaction package manifest is empty.'
    $expectedManifestHeaders = @('relative_path','sha256','bytes','role','in_aggregate')
    $actualManifestHeaders = @($manifestRows[0].PSObject.Properties.Name)
    Assert-Check (($actualManifestHeaders -join [char]31) -ceq ($expectedManifestHeaders -join [char]31)) 'Frozen bundle transaction package manifest header differs.'
    Assert-Check (@($manifestRows.relative_path | Sort-Object -Unique).Count -eq $manifestRows.Count) 'Frozen bundle transaction package manifest paths are not unique.'
    Assert-Check (@($manifestRows | Where-Object relative_path -ceq 'manifest.csv').Count -eq 0) 'Frozen bundle transaction package manifest must exclude itself.'
    foreach ($manifestRow in $manifestRows) {
        Assert-Check ($manifestRow.in_aggregate -in @('true','false')) "Manifest in_aggregate is invalid: $($manifestRow.relative_path)"
        $manifestFile = Get-ChildPath -Root $PackageRoot -RelativePath $manifestRow.relative_path -MustExist $true
        Assert-Check ((Get-Sha256 $manifestFile) -ceq $manifestRow.sha256) "Frozen bundle package file hash differs: $($manifestRow.relative_path)"
        Assert-Check ((Get-Item -LiteralPath $manifestFile).Length -eq [int64]$manifestRow.bytes) "Frozen bundle package file bytes differ: $($manifestRow.relative_path)"
    }
    $aggregateLines = @(
        $manifestRows |
            Where-Object in_aggregate -ceq 'true' |
            Sort-Object relative_path |
            ForEach-Object { $_.relative_path + '|' + $_.sha256 + '|' + $_.bytes }
    )
    Assert-Check ($aggregateLines.Count -gt 0) 'Frozen bundle transaction package aggregate set is empty.'
    $packageAggregateActual = Get-TextSha256 ($aggregateLines -join [char]10)
    Assert-Check ($transactionReviewRow.package_aggregate_sha256 -ceq $packageAggregateActual) 'Bundle transaction-review package aggregate binding differs.'
    Assert-Check ($transactionReviewRow.upstream_bindings_sha256 -ceq $ExpectedUpstreamBindingsSha256) 'Bundle transaction-review upstream-bindings binding differs.'
    Assert-Check ($transactionReviewRow.formal_baseline_aggregate_sha256 -ceq $ExpectedFormalAggregate) 'Bundle transaction-review baseline binding differs.'
    Assert-Check ($transactionReviewRow.candidate_posthash_manifest_sha256 -ceq $ExpectedCandidatePosthashSha256) 'Bundle transaction-review candidate-posthash binding differs.'
    Assert-Check ($transactionReviewRow.candidate_aggregate_sha256 -ceq $ExpectedCandidateAggregate) 'Bundle transaction-review candidate aggregate binding differs.'
    Assert-Check ([int]$transactionReviewRow.candidate_validator_checks -eq $ExpectedValidatorChecks) 'Bundle transaction-review candidate validator-check binding differs.'
    Assert-Check ($transactionReviewRow.authorization_token_sha256 -ceq (Get-TextSha256 $FormalAuthorizationToken)) 'Bundle transaction-review token binding differs.'

    $BackupRoot = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
    Assert-Check (Test-Path -LiteralPath $BackupRoot -PathType Container) "Formal BackupRoot does not exist: $BackupRoot"
    $backupCanonical = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
    Assert-Check (-not $backupCanonical.Equals($canonicalTarget, [StringComparison]::OrdinalIgnoreCase)) 'BackupRoot must differ from TargetRoot.'
    Assert-Check (-not $backupCanonical.StartsWith($canonicalTarget + '\', [StringComparison]::OrdinalIgnoreCase)) 'BackupRoot must be outside TargetRoot.'
    Assert-Check (-not $canonicalTarget.StartsWith($backupCanonical + '\', [StringComparison]::OrdinalIgnoreCase)) 'TargetRoot must not be inside BackupRoot.'
    $backupManifestPath = Join-Path $BackupRoot 'M2W3-BUNDLE-FORMAL-BACKUP-MANIFEST.csv'
    Assert-Check (Test-Path -LiteralPath $backupManifestPath -PathType Leaf) 'Bundle formal backup manifest is missing.'
    $backupManifest = @(Import-Csv -LiteralPath $backupManifestPath -Encoding UTF8)
    Assert-Check ($backupManifest.Count -eq 24) "Bundle formal backup manifest row count differs: $($backupManifest.Count)."
    Assert-Check (@($backupManifest.relative_path | Sort-Object -Unique).Count -eq 24) 'Bundle formal backup manifest paths are not unique.'
    $expectedBackupPaths = @($backupList.target_path) + @($guardList.target_path | Sort-Object -Unique) + @(
        'M2W3-BUNDLE-NEW-FILE-TARGETS-ABSENT.csv',
        'M2W3-BUNDLE-CANDIDATE-20-TABLE-POSTHASHES.csv'
    )
    Assert-Check ((@($backupManifest.relative_path | Sort-Object) -join [char]31) -ceq (@($expectedBackupPaths | Sort-Object) -join [char]31)) 'Bundle formal backup manifest path set differs.'
    foreach ($backupEntry in $backupManifest) {
        $backupFile = Get-ChildPath -Root $BackupRoot -RelativePath $backupEntry.relative_path -MustExist $true
        Assert-Check ((Get-Sha256 $backupFile) -ceq $backupEntry.sha256) "Bundle formal backup manifest hash differs: $($backupEntry.relative_path)"
        Assert-Check ((Get-Item -LiteralPath $backupFile).Length -eq [int64]$backupEntry.bytes) "Bundle formal backup manifest byte count differs: $($backupEntry.relative_path)"
    }
    foreach ($item in $backupList) {
        $formalBackup = Get-ChildPath -Root $BackupRoot -RelativePath $item.target_path -MustExist $true
        Assert-Check ((Get-Sha256 $formalBackup) -ceq $item.premerge_sha256) "Bundle formal backup hash differs: $($item.target_path)"
    }
    foreach ($guardPath in @($guardList.target_path | Sort-Object -Unique)) {
        $signedGuard = @($guardList | Where-Object target_path -ceq $guardPath | Select-Object -First 1)
        $formalBackup = Get-ChildPath -Root $BackupRoot -RelativePath $guardPath -MustExist $true
        Assert-Check ((Get-Sha256 $formalBackup) -ceq $signedGuard[0].formal_file_sha256) "Bundle formal defensive guard backup hash differs: $guardPath"
    }
    $absenceBackup = Get-ChildPath -Root $BackupRoot -RelativePath 'M2W3-BUNDLE-NEW-FILE-TARGETS-ABSENT.csv' -MustExist $true
    Assert-Check ((Get-Sha256 $absenceBackup) -ceq $ExpectedNewFileTargetsSha256) 'Bundle formal backup absent-target list differs.'
    $posthashBackup = Get-ChildPath -Root $BackupRoot -RelativePath 'M2W3-BUNDLE-CANDIDATE-20-TABLE-POSTHASHES.csv' -MustExist $true
    Assert-Check ((Get-Sha256 $posthashBackup) -ceq $ExpectedCandidatePosthashSha256) 'Bundle formal backup expected candidate-posthash manifest differs.'
    foreach ($item in $newFileList) {
        $formalPayloadTarget = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $false
        Assert-Check (-not (Test-Path -LiteralPath $formalPayloadTarget)) "Bundle formal payload target already exists before authorization: $($item.target_path)"
    }
    $authorizationMarker = Join-Path $BackupRoot 'M2W3-BUNDLE-FORMAL-TRANSACTION-AUTHORIZATION.txt'
    Assert-Check (Test-Path -LiteralPath $authorizationMarker -PathType Leaf) 'Formal BackupRoot lacks M2W3-BUNDLE-FORMAL-TRANSACTION-AUTHORIZATION.txt.'
    $marker = [IO.File]::ReadAllText($authorizationMarker, [Text.Encoding]::UTF8).Trim()
    $expectedMarker = $ExpectedToken + '|' + $transactionReviewActualSha + '|' + $ExpectedUpstreamBindingsSha256 + '|' + $ExpectedFormalAggregate + '|' + (Get-Sha256 $packageManifest) + '|' + (Get-Sha256 $backupManifestPath)
    Assert-Check ($marker -ceq $expectedMarker) 'Bundle formal backup authorization marker differs.'
}else {
    Assert-Check (-not $AllowFormalRoot.IsPresent) '-AllowFormalRoot is valid only when TargetRoot is the current formal SourceRoot.'
    Assert-Check ([string]::IsNullOrWhiteSpace($FormalAuthorizationToken)) 'Authorization token must be empty for a non-formal target.'
    Assert-Check ([string]::IsNullOrWhiteSpace($AuthorizationSignoffSha256)) 'Authorization signoff must be empty for a non-formal target.'
    Assert-Check ([string]::IsNullOrWhiteSpace($TransactionReviewSignoffPath)) 'Transaction-review signoff must be empty for a non-formal target.'
    Assert-Check (-not [string]::IsNullOrWhiteSpace($ResultRoot)) 'ResultRoot is required for a non-formal target.'
}

$backupList = @(Import-Csv -LiteralPath $BackupListPath -Encoding UTF8)
$guardList = @(Import-Csv -LiteralPath $GuardListPath -Encoding UTF8)
$newFileList = @(Import-Csv -LiteralPath $NewFileListPath -Encoding UTF8)
Assert-Check ($backupList.Count -eq 20) 'Backup-candidate list is not 20 rows.'
Assert-Check ($guardList.Count -eq 11) 'Guard list is not 11 rows.'
Assert-Check ($newFileList.Count -eq 15) 'New-file target list is not 15 rows.'

if ($isFormalRoot) {
    $BackupRoot = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
    Assert-Check (Test-Path -LiteralPath $BackupRoot -PathType Container) "Formal BackupRoot does not exist: $BackupRoot"
    $backupCanonical = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
    Assert-Check (-not $backupCanonical.Equals($canonicalTarget, [StringComparison]::OrdinalIgnoreCase)) 'BackupRoot must differ from TargetRoot.'
    Assert-Check (-not $backupCanonical.StartsWith($canonicalTarget + '\', [StringComparison]::OrdinalIgnoreCase)) 'BackupRoot must be outside TargetRoot.'
    Assert-Check (-not $canonicalTarget.StartsWith($backupCanonical + '\', [StringComparison]::OrdinalIgnoreCase)) 'TargetRoot must not be inside BackupRoot.'
    if ([string]::IsNullOrWhiteSpace($ResultRoot)) { $ResultRoot = Join-Path $BackupRoot 'transaction-results' }
}
$ResultRoot = [IO.Path]::GetFullPath($ResultRoot).TrimEnd('\')
if ($isFormalRoot) {
    $resultContainer = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
    Assert-Check ($ResultRoot.StartsWith($resultContainer + '\', [StringComparison]::OrdinalIgnoreCase)) 'Formal ResultRoot must be inside the external BackupRoot.'
}
$resultPrefix = $canonicalTarget + '\'
Assert-Check (-not $ResultRoot.Equals($canonicalTarget, [StringComparison]::OrdinalIgnoreCase)) 'ResultRoot must differ from TargetRoot.'
Assert-Check (-not $ResultRoot.StartsWith($resultPrefix, [StringComparison]::OrdinalIgnoreCase)) 'ResultRoot must be outside TargetRoot.'
if (Test-Path -LiteralPath $ResultRoot) {
    Assert-Check (Test-Path -LiteralPath $ResultRoot -PathType Container) 'ResultRoot exists but is not a directory.'
    Assert-Check (@(Get-ChildItem -LiteralPath $ResultRoot -Force).Count -eq 0) 'ResultRoot must be empty.'
}
else { [IO.Directory]::CreateDirectory($ResultRoot) | Out-Null }
Assert-Check (Test-Path -LiteralPath $ResultRoot -PathType Container) 'ResultRoot was not created.'

if (-not $isFormalRoot) {
    $markerPath = Join-Path $TargetRoot '.m2w3-bundle-formal-transaction-mirror'
    Assert-Check (Test-Path -LiteralPath $markerPath -PathType Leaf) 'Non-formal TargetRoot lacks .m2w3-bundle-formal-transaction-mirror.'
    $markerText = [IO.File]::ReadAllText($markerPath, [Text.Encoding]::UTF8).Trim()
    Assert-Check ($markerText -ceq 'M2W3-BUNDLE-FORMAL-TRANSACTION-MIRROR-20260813') 'Non-formal TargetRoot marker content differs.'
}

$preflightOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $Preflight -SourceRoot $SourceRoot -TargetRoot $TargetRoot 2>&1)
Assert-Check ($LASTEXITCODE -eq 0) "Transaction preflight failed: $($preflightOutput -join ' | ')"
$preflightJsonLine = @($preflightOutput | Where-Object { [string]$_ -match '^\{"status":"passed"' } | Select-Object -Last 1)
Assert-Check ($preflightJsonLine.Count -eq 1) 'Transaction preflight passed JSON is missing.'
Write-Utf8NoBom -Path (Join-Path $ResultRoot 'preflight-output.txt') -Text (($preflightOutput -join ([char]13 + [char]10)) + [char]13 + [char]10)

$tablePaths = @($formalManifest.relative_path | Sort-Object -Unique)
Assert-Check ($tablePaths.Count -eq 32) 'Frozen formal baseline does not contain 32 table paths.'
$baselineAggregate = Get-FormalAggregate -Root $TargetRoot -TablePaths $tablePaths
Assert-Check ($baselineAggregate -ceq $ExpectedFormalAggregate) 'TargetRoot baseline aggregate differs before candidate generation.'
$transactionContainer = if ($isFormalRoot) { $BackupRoot } else { Split-Path -Parent $ResultRoot }
$transactionRoot = Join-Path $transactionContainer ('.tmp-m2w3-bundle-formal-' + [guid]::NewGuid().ToString('N'))
$candidateRoot = Join-Path $transactionRoot 'candidate'
$backupStage = Join-Path $transactionRoot 'premerge-backup'
$replacedPaths = [System.Collections.Generic.List[string]]::new()
$createdPaths = [System.Collections.Generic.List[string]]::new()
$committed = $false
$rollbackSucceeded = $false
$FaultAfterReplacements = 0
$FaultAfterPayloads = 0
if (-not [string]::IsNullOrWhiteSpace($env:M2W3_BUNDLE_TEST_FAIL_AFTER_REPLACEMENTS)) { $FaultAfterReplacements = [int]$env:M2W3_BUNDLE_TEST_FAIL_AFTER_REPLACEMENTS }
if (-not [string]::IsNullOrWhiteSpace($env:M2W3_BUNDLE_TEST_FAIL_AFTER_PAYLOADS)) { $FaultAfterPayloads = [int]$env:M2W3_BUNDLE_TEST_FAIL_AFTER_PAYLOADS }
Assert-Check ($FaultAfterReplacements -ge 0 -and $FaultAfterReplacements -le 20) 'Replacement fault-injection value must be between 0 and 20.'
Assert-Check ($FaultAfterPayloads -ge 0 -and $FaultAfterPayloads -le 15) 'Payload fault-injection value must be between 0 and 15.'
if ($isFormalRoot) {
    Assert-Check ($FaultAfterReplacements -eq 0) 'Fault injection is forbidden for a formal-root transaction.'
    Assert-Check ($FaultAfterPayloads -eq 0) 'Fault injection is forbidden for a formal-root transaction.'
}
$script:TransactionJournal = [System.Collections.Generic.List[object]]::new()
$script:JournalSequence = 0
$script:JournalPath = Join-Path $ResultRoot 'commit-rollback-journal.csv'
function Add-JournalEvent {
    param([string]$Phase, [string]$Kind, [string]$RelativePath, [string]$ObservedSha256, [string]$Details)
    $script:JournalSequence++
    $script:TransactionJournal.Add([pscustomobject][ordered]@{
        sequence = $script:JournalSequence
        timestamp_utc = [DateTime]::UtcNow.ToString('o')
        phase = $Phase
        kind = $Kind
        relative_path = $RelativePath
        observed_sha256 = $ObservedSha256
        details = $Details
    })
    Write-CsvUtf8NoBomCrlf -Path $script:JournalPath -Rows @($script:TransactionJournal)
}


$lockRoot = $transactionContainer
Assert-Check (Test-Path -LiteralPath $lockRoot -PathType Container) 'Transaction lock root does not exist.'
$lockKey = (Get-TextSha256 $canonicalTarget).Substring(0,16)
$lockPath = Join-Path $lockRoot ('M2W3-BUNDLE-FORMAL-TRANSACTION-LOCK-' + $lockKey + '.lock')
$lockStream = $null
$lockOwned = $false
try {
    $lockStream = New-Object IO.FileStream($lockPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $lockOwned = $true
    $lockText = $canonicalTarget + '|' + [DateTime]::UtcNow.ToString('o') + '|' + $PID
    $lockBytes = (New-Object Text.UTF8Encoding($false)).GetBytes($lockText)
    $lockStream.Write($lockBytes, 0, $lockBytes.Length)
    $lockStream.Flush($true)
}
catch {
    if ($null -ne $lockStream) { $lockStream.Dispose() }
    if ($lockOwned -and (Test-Path -LiteralPath $lockPath -PathType Leaf)) { [IO.File]::Delete($lockPath) }
    throw "TRANSACTION LOCK ACQUISITION FAILED: $lockPath. $($_.Exception.Message)"
}

try {
    Add-JournalEvent -Phase 'precommit' -Kind 'lock_acquired' -RelativePath '' -ObservedSha256 (Get-TextSha256 $lockText) -Details $lockPath
    [IO.Directory]::CreateDirectory($candidateRoot) | Out-Null
    [IO.Directory]::CreateDirectory($backupStage) | Out-Null
    foreach ($relative in $tablePaths) {
        $source = Get-ChildPath -Root $TargetRoot -RelativePath $relative -MustExist $true
        $target = Get-ChildPath -Root $candidateRoot -RelativePath $relative -MustExist $false
        [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        [IO.File]::Copy($source, $target, $false)
    }
    [IO.File]::WriteAllText((Join-Path $candidateRoot '.m2w3-bundle-isolated-target'), $IsolatedMarkerText, (New-Object Text.UTF8Encoding($false)))

    $previousPreference = $ErrorActionPreference; $ErrorActionPreference = 'Continue'; $replayOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $ReplayEngine -SourceRoot $SourceRoot -TargetRoot $candidateRoot -PackageRoot $PackageRoot 2>&1); $replayExitCode = $LASTEXITCODE; $ErrorActionPreference = $previousPreference
    Write-Utf8NoBom -Path (Join-Path $ResultRoot 'accepted-replay-output.txt') -Text (($replayOutput -join ([char]13 + [char]10)) + [char]13 + [char]10)
    Assert-Check ($replayExitCode -eq 0) "Accepted replay engine failed: $($replayOutput -join ' | ')"
    $replayJsonLine = @($replayOutput | Where-Object { [string]$_ -match '^\{"status":"PASS"' } | Select-Object -Last 1)
    Assert-Check ($replayJsonLine.Count -eq 1) 'Accepted replay-engine PASS JSON is missing.'
    $replayResult = $replayJsonLine[0] | ConvertFrom-Json
    Assert-Check ([int]$replayResult.authorized_writes -eq 1057) 'Accepted replay engine did not execute 1057 writes.'
    Assert-Check ([int]$replayResult.files_created -eq 15) 'Accepted replay engine did not copy 15 transaction files.'

    $validatorOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $Validator -RootPath $candidateRoot 2>&1)
    Write-Utf8NoBom -Path (Join-Path $ResultRoot 'candidate-validator-output.txt') -Text (($validatorOutput -join ([char]13 + [char]10)) + [char]13 + [char]10)
    Assert-Check ($LASTEXITCODE -eq 0) "Candidate validator failed: $($validatorOutput -join ' | ')"
    $validatorText = $validatorOutput -join [char]10
    $match = [regex]::Match($validatorText, '([0-9]+) checks executed')
    Assert-Check ($match.Success) 'Candidate validator check count is missing.'
    Assert-Check ([int]$match.Groups[1].Value -eq $ExpectedValidatorChecks) "Candidate validator checks differ: $($match.Groups[1].Value)."
    Assert-Check ($validatorText -match 'subject_contract_mode=gate') 'Candidate validator did not use gate mode.'
    $candidateAggregate = Get-FormalAggregate -Root $candidateRoot -TablePaths $tablePaths

    Assert-Check ($candidateAggregate -ceq $ExpectedCandidateAggregate) 'Validated candidate 32-table aggregate differs from the frozen bundle aggregate.'
    foreach ($item in $backupList) {
        $current = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
        $backup = Get-ChildPath -Root $backupStage -RelativePath $item.target_path -MustExist $false
        [IO.Directory]::CreateDirectory((Split-Path -Parent $backup)) | Out-Null
        [IO.File]::Copy($current, $backup, $false)
        Assert-Check ((Get-Sha256 $backup) -ceq $item.premerge_sha256) "Staged backup hash differs: $($item.target_path)"

        $expectedRows = @($expectedCandidatePosthash | Where-Object target_path -ceq $item.target_path)
        Assert-Check ($expectedRows.Count -eq 1) "Frozen candidate-posthash row count differs: $($item.target_path)"
        $expectedRow = $expectedRows[0]
        Assert-Check ($expectedRow.premerge_sha256 -ceq $item.premerge_sha256) "Frozen candidate premerge hash differs: $($item.target_path)"
        Assert-Check ($expectedRow.formal_baseline_aggregate -ceq $ExpectedFormalAggregate) "Frozen candidate baseline aggregate differs: $($item.target_path)"
        Assert-Check ($expectedRow.candidate_aggregate -ceq $ExpectedCandidateAggregate) "Frozen candidate aggregate binding differs: $($item.target_path)"
        Assert-Check ([int]$expectedRow.validator_checks -eq $ExpectedValidatorChecks) "Frozen candidate validator-check binding differs: $($item.target_path)"
        Assert-Check ($expectedRow.authorized_write_set_sha256 -ceq $ExpectedAuthorizedWriteSetSha256) "Frozen candidate write-set binding differs: $($item.target_path)"
        Assert-Check ($expectedRow.new_file_targets_sha256 -ceq $ExpectedNewFileTargetsSha256) "Frozen candidate payload binding differs: $($item.target_path)"
        Assert-Check ($expectedRow.no_write_guards_sha256 -ceq $ExpectedNoWriteGuardsSha256) "Frozen candidate guard binding differs: $($item.target_path)"

        $candidate = Get-ChildPath -Root $candidateRoot -RelativePath $item.target_path -MustExist $true
        $candidateHash = Get-Sha256 $candidate
        Assert-Check ($candidateHash -ceq $expectedRow.candidate_postmerge_sha256) "Candidate table hash differs from the frozen posthash: $($item.target_path)"
        Assert-Check ((Get-Item -LiteralPath $candidate).Length -eq [int64]$expectedRow.candidate_bytes) "Candidate table bytes differ from the frozen posthash: $($item.target_path)"
        Assert-Check ($candidateHash -cne $item.premerge_sha256) "Candidate table did not change: $($item.target_path)"
    }
    $candidateHashPath = Join-Path $ResultRoot 'candidate-20-table-posthashes.csv'
    [IO.File]::Copy($ExpectedCandidatePosthashPath, $candidateHashPath, $false)
    Assert-Check (@(Import-Csv -LiteralPath $candidateHashPath -Encoding UTF8).Count -eq 20) 'Candidate posthash freeze is not 20 rows.'
    $candidateHashManifestSha256 = Get-Sha256 $candidateHashPath
    Assert-Check ($candidateHashManifestSha256 -ceq $ExpectedCandidatePosthashSha256) 'Candidate 20-table posthash manifest differs from the frozen expected manifest.'
    if ($isFormalRoot) {
        Assert-Check ((Get-Sha256 $TransactionReviewSignoffPath) -ceq $transactionReviewActualSha) 'Bundle transaction-review signoff changed after authorization.'
        Assert-Check ((Get-Sha256 $packageManifest) -ceq $transactionReviewRow.package_manifest_sha256) 'Frozen bundle package manifest changed after authorization.'
        Assert-Check ((Get-Sha256 $UpstreamBindingsPath) -ceq $ExpectedUpstreamBindingsSha256) 'Upstream bindings changed after authorization.'
        Assert-Check ((Get-Sha256 $ExpectedCandidatePosthashPath) -ceq $ExpectedCandidatePosthashSha256) 'Frozen candidate-posthash manifest changed after authorization.'

        $authorizationMarker = Join-Path $BackupRoot 'M2W3-BUNDLE-FORMAL-TRANSACTION-AUTHORIZATION.txt'
        Assert-Check (Test-Path -LiteralPath $authorizationMarker -PathType Leaf) 'Formal BackupRoot lacks M2W3-BUNDLE-FORMAL-TRANSACTION-AUTHORIZATION.txt.'
        $marker = [IO.File]::ReadAllText($authorizationMarker, [Text.Encoding]::UTF8).Trim()
        $backupManifestPath = Join-Path $BackupRoot 'M2W3-BUNDLE-FORMAL-BACKUP-MANIFEST.csv'
        Assert-Check (Test-Path -LiteralPath $backupManifestPath -PathType Leaf) 'Bundle formal backup manifest is missing.'
        $backupManifest = @(Import-Csv -LiteralPath $backupManifestPath -Encoding UTF8)
        Assert-Check ($backupManifest.Count -eq 24) "Bundle formal backup manifest row count differs: $($backupManifest.Count)."
        Assert-Check (@($backupManifest.relative_path | Sort-Object -Unique).Count -eq 24) 'Bundle formal backup manifest paths are not unique.'
        $expectedBackupPaths = @($backupList.target_path) + @($guardList.target_path | Sort-Object -Unique) + @(
            'M2W3-BUNDLE-NEW-FILE-TARGETS-ABSENT.csv',
            'M2W3-BUNDLE-CANDIDATE-20-TABLE-POSTHASHES.csv'
        )
        Assert-Check ((@($backupManifest.relative_path | Sort-Object) -join [char]31) -ceq (@($expectedBackupPaths | Sort-Object) -join [char]31)) 'Bundle formal backup manifest path set differs after candidate validation.'
        foreach ($backupEntry in $backupManifest) {
            $backupFile = Get-ChildPath -Root $BackupRoot -RelativePath $backupEntry.relative_path -MustExist $true
            Assert-Check ((Get-Sha256 $backupFile) -ceq $backupEntry.sha256) "Bundle formal backup hash changed after candidate validation: $($backupEntry.relative_path)"
            Assert-Check ((Get-Item -LiteralPath $backupFile).Length -eq [int64]$backupEntry.bytes) "Bundle formal backup bytes changed after candidate validation: $($backupEntry.relative_path)"
        }
        $expectedMarker = $ExpectedToken + '|' + $transactionReviewActualSha + '|' + $ExpectedUpstreamBindingsSha256 + '|' + $ExpectedFormalAggregate + '|' + (Get-Sha256 $packageManifest) + '|' + (Get-Sha256 $backupManifestPath)
        Assert-Check ($marker -ceq $expectedMarker) 'Bundle formal backup authorization marker changed after candidate validation.'
        foreach ($item in $backupList) {
            $formalBackup = Get-ChildPath -Root $BackupRoot -RelativePath $item.target_path -MustExist $true
            Assert-Check ((Get-Sha256 $formalBackup) -ceq $item.premerge_sha256) "Bundle formal backup hash differs: $($item.target_path)"
        }
        foreach ($guardPath in @($guardList.target_path | Sort-Object -Unique)) {
            $signedGuard = @($guardList | Where-Object target_path -ceq $guardPath | Select-Object -First 1)
            $formalBackup = Get-ChildPath -Root $BackupRoot -RelativePath $guardPath -MustExist $true
            Assert-Check ((Get-Sha256 $formalBackup) -ceq $signedGuard[0].formal_file_sha256) "Bundle formal defensive guard backup hash differs: $guardPath"
        }
        $absenceBackup = Get-ChildPath -Root $BackupRoot -RelativePath 'M2W3-BUNDLE-NEW-FILE-TARGETS-ABSENT.csv' -MustExist $true
        Assert-Check ((Get-Sha256 $absenceBackup) -ceq $ExpectedNewFileTargetsSha256) 'Bundle formal backup absent-target list differs.'
        $posthashBackup = Get-ChildPath -Root $BackupRoot -RelativePath 'M2W3-BUNDLE-CANDIDATE-20-TABLE-POSTHASHES.csv' -MustExist $true
        Assert-Check ((Get-Sha256 $posthashBackup) -ceq $candidateHashManifestSha256) 'Bundle formal backup candidate-posthash manifest differs.'
    }
    foreach ($item in $backupList) {
        $current = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
        Assert-Check ((Get-Sha256 $current) -ceq $item.premerge_sha256) "Target table changed before commit: $($item.target_path)"
    }
    foreach ($item in $newFileList) {
        $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $false
        Assert-Check (-not (Test-Path -LiteralPath $target)) "New-file target appeared before commit: $($item.target_path)"
    }

    $criticalAggregate = Get-FormalAggregate -Root $TargetRoot -TablePaths $tablePaths
    Assert-Check ($criticalAggregate -ceq $ExpectedFormalAggregate) 'Full 32-table aggregate changed before commit.'
    foreach ($item in $guardList) {
        $guardTarget = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
        Assert-Check ((Get-Sha256 $guardTarget) -ceq $item.formal_file_sha256) "Guard file changed before commit: $($item.guard_id)"
    }

    foreach ($item in $backupList) {
        $candidate = Get-ChildPath -Root $candidateRoot -RelativePath $item.target_path -MustExist $true
        $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
        $tempReplacement = $target + '.m2w3-bundle-formal-transaction-new'
        Assert-Check (-not (Test-Path -LiteralPath $tempReplacement)) "Replacement temp already exists: $tempReplacement"
        [IO.File]::Copy($candidate, $tempReplacement, $false)
        $replacedPaths.Add($item.target_path)
        Add-JournalEvent -Phase 'commit_begin' -Kind 'csv_replace' -RelativePath $item.target_path -ObservedSha256 $item.premerge_sha256 -Details ('registered_before_move;candidate=' + (Get-Sha256 $candidate))
        Move-Item -LiteralPath $tempReplacement -Destination $target -Force -ErrorAction Stop
        $committedHash = Get-Sha256 $target
        Assert-Check ($committedHash -ceq (Get-Sha256 $candidate)) "Committed table hash differs: $($item.target_path)"
        Add-JournalEvent -Phase 'commit_complete' -Kind 'csv_replace' -RelativePath $item.target_path -ObservedSha256 $committedHash -Details ('commit_index=' + $replacedPaths.Count)
        if ($FaultAfterReplacements -gt 0 -and $replacedPaths.Count -eq $FaultAfterReplacements) { throw "INJECTED_TEST_FAILURE_AFTER_$FaultAfterReplacements`_REPLACEMENTS" }
    }

    foreach ($item in $newFileList) {
        $candidate = Get-ChildPath -Root $candidateRoot -RelativePath $item.target_path -MustExist $true
        $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $false
        Assert-Check (-not (Test-Path -LiteralPath $target)) "New-file target appeared during commit: $($item.target_path)"
        [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        $createdPaths.Add($item.target_path)
        Add-JournalEvent -Phase 'commit_begin' -Kind 'payload_copy' -RelativePath $item.target_path -ObservedSha256 '' -Details ('registered_before_copy;expected=' + $item.source_sha256)
        [IO.File]::Copy($candidate, $target, $false)
        $payloadHash = Get-Sha256 $target
        Assert-Check ($payloadHash -ceq $item.source_sha256) "Committed payload hash differs: $($item.target_path)"
        Add-JournalEvent -Phase 'commit_complete' -Kind 'payload_copy' -RelativePath $item.target_path -ObservedSha256 $payloadHash -Details ('commit_index=' + $createdPaths.Count)
        if ($FaultAfterPayloads -gt 0 -and $createdPaths.Count -eq $FaultAfterPayloads) { throw "INJECTED_TEST_FAILURE_AFTER_$FaultAfterPayloads" + '_PAYLOADS' }
    }

    $postValidatorOutput = @(& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $Validator -RootPath $TargetRoot 2>&1)
    Write-Utf8NoBom -Path (Join-Path $ResultRoot 'post-commit-validator-output.txt') -Text (($postValidatorOutput -join ([char]13 + [char]10)) + [char]13 + [char]10)
    Assert-Check ($LASTEXITCODE -eq 0) "Post-commit validator failed: $($postValidatorOutput -join ' | ')"
    $postValidatorText = $postValidatorOutput -join [char]10
    $postMatch = [regex]::Match($postValidatorText, '([0-9]+) checks executed')
    Assert-Check ($postMatch.Success -and [int]$postMatch.Groups[1].Value -eq $ExpectedValidatorChecks) 'Post-commit validator check count differs.'
    Assert-Check ($postValidatorText -match 'subject_contract_mode=gate') 'Post-commit validator did not use gate mode.'
    $postCommitAggregate = Get-FormalAggregate -Root $TargetRoot -TablePaths $tablePaths
    Assert-Check ($postCommitAggregate -ceq $candidateAggregate) 'Post-commit 32-table aggregate differs from the validated candidate.'

    foreach ($item in $guardList) {
        $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
        Assert-Check ((Get-Sha256 $target) -ceq $item.formal_file_sha256) "Guard table changed after commit: $($item.guard_id)"
    }

    foreach ($item in $backupList) {
        $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
        Assert-Check (-not (Test-Path -LiteralPath ($target + '.m2w3-bundle-formal-transaction-new'))) "Replacement temp remains after success: $($item.target_path)"
        Assert-Check (-not (Test-Path -LiteralPath ($target + '.m2w3-bundle-formal-transaction-restore'))) "Restore temp remains after success: $($item.target_path)"
    }

    $committed = $true
    $result = [pscustomobject][ordered]@{
        status = 'PASS'
        checks = $script:Checks
        target_kind = if ($isFormalRoot) { 'formal_root' } else { 'mirror_root' }
        candidate_validator_checks = $ExpectedValidatorChecks
        post_commit_validator_checks = $ExpectedValidatorChecks
        authorized_writes = 1057
        no_write_guards = 11
        csv_tables_replaced = $replacedPaths.Count
        files_created = $createdPaths.Count
        candidate_posthash_manifest_sha256 = $candidateHashManifestSha256
        candidate_32_table_aggregate = $candidateAggregate
        post_commit_32_table_aggregate = $postCommitAggregate
        rollback_used = $false
    }
    Add-JournalEvent -Phase 'commit_complete' -Kind 'transaction' -RelativePath '' -ObservedSha256 $candidateHashManifestSha256 -Details '1057_writes_11_guards_125619_checks'
    $resultJson = $result | ConvertTo-Json -Compress
    Write-Utf8NoBom -Path (Join-Path $ResultRoot 'transaction-outcome.json') -Text ($resultJson + [char]13 + [char]10)
    $resultJson
}
catch {
    $originalError = $_
    try {
        for ($index = $createdPaths.Count - 1; $index -ge 0; $index--) {
            $relative = $createdPaths[$index]
            $signedPayload = @($newFileList | Where-Object target_path -ceq $relative)
            Assert-Check ($signedPayload.Count -eq 1) "Rollback payload journal is not bound to one signed target: $relative"
            $target = Get-ChildPath -Root $TargetRoot -RelativePath $relative -MustExist $false
            if (Test-Path -LiteralPath $target -PathType Leaf) {
                $currentPayloadHash = Get-Sha256 $target
                Assert-Check ($currentPayloadHash -ceq $signedPayload[0].source_sha256) "ROLLBACK PAYLOAD HASH DRIFT: $relative. Automatic deletion is forbidden."
                Add-JournalEvent -Phase 'rollback_begin' -Kind 'payload_delete' -RelativePath $relative -ObservedSha256 $currentPayloadHash -Details ('reverse_index=' + $index)
                [IO.File]::Delete($target)
                Add-JournalEvent -Phase 'rollback_complete' -Kind 'payload_delete' -RelativePath $relative -ObservedSha256 '' -Details 'deleted_signed_transaction_payload'
            }
        }
        for ($index = $replacedPaths.Count - 1; $index -ge 0; $index--) {
            $relative = $replacedPaths[$index]
            $backup = Get-ChildPath -Root $backupStage -RelativePath $relative -MustExist $true
            $target = Get-ChildPath -Root $TargetRoot -RelativePath $relative -MustExist $true
            $restoreTemp = $target + '.m2w3-bundle-formal-transaction-restore'
            if (Test-Path -LiteralPath $restoreTemp) { [IO.File]::Delete($restoreTemp) }
            Add-JournalEvent -Phase 'rollback_begin' -Kind 'csv_restore' -RelativePath $relative -ObservedSha256 (Get-Sha256 $target) -Details ('reverse_index=' + $index)
            [IO.File]::Copy($backup, $restoreTemp, $false)
            Move-Item -LiteralPath $restoreTemp -Destination $target -Force -ErrorAction Stop
            Add-JournalEvent -Phase 'rollback_complete' -Kind 'csv_restore' -RelativePath $relative -ObservedSha256 (Get-Sha256 $target) -Details 'restored_premerge_backup'
        }
        foreach ($item in $backupList) {
            $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
            Assert-Check ((Get-Sha256 $target) -ceq $item.premerge_sha256) "Rollback table hash differs: $($item.target_path)"
        }
        foreach ($item in $newFileList) {
            $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $false
            Assert-Check (-not (Test-Path -LiteralPath $target)) "Rollback left a new file: $($item.target_path)"
        }
        foreach ($item in $backupList) {
            $target = Get-ChildPath -Root $TargetRoot -RelativePath $item.target_path -MustExist $true
            $replacementTemp = $target + '.m2w3-bundle-formal-transaction-new'
            $restoreTemp = $target + '.m2w3-bundle-formal-transaction-restore'
            if (Test-Path -LiteralPath $replacementTemp -PathType Leaf) { [IO.File]::Delete($replacementTemp) }
            if (Test-Path -LiteralPath $restoreTemp -PathType Leaf) { [IO.File]::Delete($restoreTemp) }
            Assert-Check (-not (Test-Path -LiteralPath $replacementTemp)) "Rollback left a replacement temp: $($item.target_path)"
            Assert-Check (-not (Test-Path -LiteralPath $restoreTemp)) "Rollback left a restore temp: $($item.target_path)"
        }
        $rollbackAggregate = Get-FormalAggregate -Root $TargetRoot -TablePaths $tablePaths
        Assert-Check ($rollbackAggregate -ceq $ExpectedFormalAggregate) 'Rollback full 32-table aggregate differs.'
        foreach ($guardPath in @($guardList.target_path | Sort-Object -Unique)) {
            $signedGuard = @($guardList | Where-Object target_path -ceq $guardPath | Select-Object -First 1)
            $guardTarget = Get-ChildPath -Root $TargetRoot -RelativePath $guardPath -MustExist $true
            $guardCurrentHash = Get-Sha256 $guardTarget
            Assert-Check ($guardCurrentHash -ceq $signedGuard[0].formal_file_sha256) "GUARD TABLE DRIFT DURING ROLLBACK: $guardPath. Automatic overwrite is forbidden."
            if ($isFormalRoot) {
                $guardBackup = Get-ChildPath -Root $BackupRoot -RelativePath $guardPath -MustExist $true
                Assert-Check ((Get-Sha256 $guardBackup) -ceq $guardCurrentHash) "Guard defensive backup differs after rollback: $guardPath"
            }
        }
        $rollbackSucceeded = $true
        Add-JournalEvent -Phase 'rollback_complete' -Kind 'transaction' -RelativePath '' -ObservedSha256 $ExpectedFormalAggregate -Details 'all_registered_changes_reversed'
        $failureResult = [pscustomobject][ordered]@{status='FAIL_ROLLED_BACK';error=$originalError.Exception.Message;rollback_succeeded=$true;tables_restored=$replacedPaths.Count;payloads_removed=$createdPaths.Count;formal_baseline_aggregate=$ExpectedFormalAggregate}
        Write-Utf8NoBom -Path (Join-Path $ResultRoot 'transaction-outcome.json') -Text (($failureResult | ConvertTo-Json) + [char]13 + [char]10)
    }
    catch {
        $rollbackError = $_
        $severeResult = [pscustomobject][ordered]@{status='FAIL_ROLLBACK_FAILED';original_error=$originalError.Exception.Message;rollback_error=$rollbackError.Exception.Message;rollback_succeeded=$false;tables_registered=$replacedPaths.Count;payloads_registered=$createdPaths.Count}
        Write-Utf8NoBom -Path (Join-Path $ResultRoot 'transaction-outcome.json') -Text (($severeResult | ConvertTo-Json) + [char]13 + [char]10)
        throw "TRANSACTION FAILED AND ROLLBACK FAILED. Original: $($originalError.Exception.Message) Rollback: $($rollbackError.Exception.Message)"
    }
    throw "TRANSACTION FAILED; ROLLBACK SUCCEEDED. $($originalError.Exception.Message)"
}
finally {
    if (Test-Path -LiteralPath $transactionRoot) { Remove-Item -LiteralPath $transactionRoot -Recurse -Force }
    if ($null -ne $lockStream) { $lockStream.Dispose() }
    if ($lockOwned -and (Test-Path -LiteralPath $lockPath -PathType Leaf)) { [IO.File]::Delete($lockPath) }
    Assert-Check ((-not $lockOwned) -or (-not (Test-Path -LiteralPath $lockPath))) 'Transaction lock file remains after completion.'
}
