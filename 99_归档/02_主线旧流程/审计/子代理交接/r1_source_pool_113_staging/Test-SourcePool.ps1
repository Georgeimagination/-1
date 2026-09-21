[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$RootPath,

    [string]$PdfInfoPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RootPath)) {
    $RootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

$resolvedRoot = Resolve-Path -LiteralPath $RootPath -ErrorAction Stop
$root = [System.IO.Path]::GetFullPath($resolvedRoot.Path)
$script:Checks = New-Object 'System.Collections.Generic.List[object]'

function Add-Check {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Status,

        [AllowNull()]
        [object]$Expected,

        [AllowNull()]
        [object]$Actual,

        [bool]$Critical = $true,

        [string]$Details = ''
    )

    $script:Checks.Add([PSCustomObject]@{
        Name     = $Name
        Status   = $Status
        Expected = if ($null -eq $Expected) { '<none>' } else { [string]$Expected }
        Actual   = if ($null -eq $Actual) { '<none>' } else { [string]$Actual }
        Critical = $Critical
        Details  = $Details
    }) | Out-Null
}

function Add-EqualityCheck {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [AllowNull()]
        [object]$Expected,

        [AllowNull()]
        [object]$Actual,

        [bool]$Critical = $true,

        [string]$Details = ''
    )

    $matches = [object]::Equals($Expected, $Actual)
    Add-Check -Name $Name -Status $(if ($matches) { 'PASS' } elseif ($Critical) { 'FAIL' } else { 'WARN' }) -Expected $Expected -Actual $Actual -Critical $Critical -Details $Details
}

function Show-Summary {
    Write-Host ''
    Write-Host 'Checks:'
    foreach ($check in $script:Checks) {
        $line = '[{0}] {1}: expected={2}; actual={3}' -f $check.Status, $check.Name, $check.Expected, $check.Actual
        if (-not [string]::IsNullOrWhiteSpace($check.Details)) {
            $line += '; ' + $check.Details
        }
        Write-Host $line
    }

    $failureCount = @($script:Checks | Where-Object { $_.Status -eq 'FAIL' -and $_.Critical }).Count
    $warningCount = @($script:Checks | Where-Object { $_.Status -eq 'WARN' }).Count

    Write-Host ''
    if ($failureCount -eq 0) {
        Write-Host ('RESULT: PASS ({0} warning(s))' -f $warningCount)
        return 0
    }

    Write-Host ('RESULT: FAIL ({0} critical failure(s), {1} warning(s))' -f $failureCount, $warningCount)
    return 1
}
function Resolve-ContainedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,

        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $separator = [string][System.IO.Path]::DirectorySeparatorChar
    $nativeRelativePath = $RelativePath.Replace('/', $separator).Replace('\', $separator)
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $BasePath $nativeRelativePath))
    $prefix = $BasePath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar

    if (-not $candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Manifest path escapes RootPath: $RelativePath"
    }

    return $candidate
}

function Resolve-PdfInfoExecutable {
    param(
        [string]$RequestedPath
    )

    $candidate = $null

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        if ([System.IO.Path]::IsPathRooted($RequestedPath)) {
            if (Test-Path -LiteralPath $RequestedPath -PathType Leaf) {
                $candidate = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $RequestedPath).Path)
            }
        }
        else {
            $requestedCommand = Get-Command $RequestedPath -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($null -ne $requestedCommand) {
                $candidate = $requestedCommand.Path
            }
        }
    }
    else {
        $exeCommand = Get-Command 'pdfinfo.exe' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $exeCommand) {
            $candidate = $exeCommand.Path
        }
        else {
            $cmdCommand = Get-Command 'pdfinfo.cmd' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($null -ne $cmdCommand) {
                $candidate = $cmdCommand.Path
            }
        }
    }

    if ($null -eq $candidate) {
        return $null
    }

    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    for ($depth = 0; $depth -lt 6; $depth++) {
        $candidate = [System.IO.Path]::GetFullPath($candidate)
        if (-not $seen.Add($candidate)) {
            return $null
        }

        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return $null
        }

        if ([System.IO.Path]::GetExtension($candidate).Equals('.exe', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $candidate
        }

        if (-not [System.IO.Path]::GetExtension($candidate).Equals('.cmd', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $null
        }

        $wrapperText = Get-Content -LiteralPath $candidate -Raw -Encoding UTF8
        $match = [regex]::Match($wrapperText, '%~dp0(?<relative>[^"\r\n]*pdfinfo\.(?:exe|cmd))', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if (-not $match.Success) {
            $match = [regex]::Match($wrapperText, '%SCRIPT_DIR%(?<relative>[^"\r\n]*pdfinfo\.(?:exe|cmd))', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        }

        if (-not $match.Success) {
            return $null
        }

        $candidate = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $candidate) $match.Groups['relative'].Value))
    }

    return $null
}

Write-Output 'Source pool baseline validation'
Write-Output ('RootPath: {0}' -f $root)
Write-Output 'Mode: read-only'

$relativeFiles = [ordered]@{
    PdfManifest     = '清单\论文PDF清单.csv'
    WebManifest     = '清单\网页与在线资料.csv'
    PendingManifest = '清单\待补论文清单.csv'
    Summary         = '清单\汇总统计.json'
    ControlledLedger = '清单\资料池受控输入\source-pool-input-ledger.json'
    FrozenLegacyManifest = '清单\资料池受控输入\frozen-legacy-pdf-manifest.csv'
}

$expectedHashes = [ordered]@{
    '清单\论文PDF清单.csv' = '4df7c2212c827e34d3483f6021d7af5bf854f374d0000b42bc5d88d57316c1ab'
    '清单\网页与在线资料.csv' = 'f19991c731fcdca8e0dee65601a2637a5568bc1fde46b357757d19292aa1395f'
    '清单\待补论文清单.csv' = 'b5a5993c0a29364c5be3c2d6d35321e3150b5599913e3fafe887bff3a02307bd'
    '清单\汇总统计.json' = '994a4950577914114e66f195b3900f2d9f9bd1baf50ca62cb7d5b9bce1a4785e'
    '清单\资料池受控输入\source-pool-input-ledger.json' = '08994b2402f6f1bdcfceecb2504b50dd317aa91e6d2b7c947f974ffdbc7e8812'
    '清单\资料池受控输入\frozen-legacy-pdf-manifest.csv' = 'c8c43df658daa1671e32b5389e29a33cf5179c269ae56f29d9e95404cdb38b27'
}

$filePaths = @{}
$missingRequiredFiles = New-Object 'System.Collections.Generic.List[string]'

foreach ($key in $relativeFiles.Keys) {
    $relativePath = $relativeFiles[$key]
    $fullPath = Resolve-ContainedPath -BasePath $root -RelativePath $relativePath
    $filePaths[$key] = $fullPath

    if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        Add-Check -Name ("Required file exists: {0}" -f $relativePath) -Status 'PASS' -Expected 'present' -Actual 'present'
    }
    else {
        $missingRequiredFiles.Add($relativePath) | Out-Null
        Add-Check -Name ("Required file exists: {0}" -f $relativePath) -Status 'FAIL' -Expected 'present' -Actual 'missing'
    }
}

if ($missingRequiredFiles.Count -gt 0) {
    $exitCode = Show-Summary
    exit $exitCode
}

foreach ($relativePath in $expectedHashes.Keys) {
    $fullPath = Resolve-ContainedPath -BasePath $root -RelativePath $relativePath
    $actualHash = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $expectedHash = $expectedHashes[$relativePath]
    Add-EqualityCheck -Name ("Baseline SHA-256: {0}" -f $relativePath) -Expected $expectedHash -Actual $actualHash
}

$pdfRows = @(Import-Csv -LiteralPath $filePaths['PdfManifest'])
$webRows = @(Import-Csv -LiteralPath $filePaths['WebManifest'])
$pendingRows = @(Import-Csv -LiteralPath $filePaths['PendingManifest'])
$frozenLegacyRows = @(Import-Csv -LiteralPath $filePaths['FrozenLegacyManifest'])
$summary = Get-Content -LiteralPath $filePaths['Summary'] -Raw -Encoding UTF8 | ConvertFrom-Json

$pdfRequiredColumns = @('汇总后文件', '页数', '文件大小_字节', 'SHA256')
$pdfColumns = if ($pdfRows.Count -gt 0) { @($pdfRows[0].PSObject.Properties.Name) } else { @() }
$missingPdfColumns = @($pdfRequiredColumns | Where-Object { $_ -notin $pdfColumns })
Add-EqualityCheck -Name 'PDF manifest required columns missing' -Expected 0 -Actual $missingPdfColumns.Count -Details ($missingPdfColumns -join ', ')

$webColumns = if ($webRows.Count -gt 0) { @($webRows[0].PSObject.Properties.Name) } else { @() }
$missingWebColumns = @('URL' | Where-Object { $_ -notin $webColumns })
Add-EqualityCheck -Name 'Web manifest required columns missing' -Expected 0 -Actual $missingWebColumns.Count -Details ($missingWebColumns -join ', ')

if ($missingPdfColumns.Count -gt 0 -or $missingWebColumns.Count -gt 0) {
    $exitCode = Show-Summary
    exit $exitCode
}

$frozenLegacyColumns = if ($frozenLegacyRows.Count -gt 0) { @($frozenLegacyRows[0].PSObject.Properties.Name) } else { @() }
$missingFrozenLegacyColumns = @($pdfRequiredColumns | Where-Object { $_ -notin $frozenLegacyColumns })
Add-EqualityCheck -Name 'Frozen legacy manifest required columns missing' -Expected 0 -Actual $missingFrozenLegacyColumns.Count -Details ($missingFrozenLegacyColumns -join ', ')
Add-EqualityCheck -Name 'Frozen legacy PDF manifest row count' -Expected 111 -Actual $frozenLegacyRows.Count

$frozenLegacySourceOccurrences = 0
$frozenLegacyHashSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
$frozenLegacyBlankHashes = 0
$frozenLegacyBytes = [long]0
$frozenLegacyPages = [long]0
foreach ($legacyRow in $frozenLegacyRows) {
    $legacySourceItems = @((([string]$legacyRow.'源文件') -split '；') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $frozenLegacySourceOccurrences += $legacySourceItems.Count
    $legacyHash = ([string]$legacyRow.SHA256).Trim()
    if ([string]::IsNullOrWhiteSpace($legacyHash)) {
        $frozenLegacyBlankHashes++
    }
    else {
        $frozenLegacyHashSet.Add($legacyHash) | Out-Null
    }
    $frozenLegacyBytes += [long]$legacyRow.'文件大小_字节'
    $frozenLegacyPages += [long]$legacyRow.'页数'
}
Add-EqualityCheck -Name 'Frozen legacy source-file occurrences' -Expected 112 -Actual $frozenLegacySourceOccurrences
Add-EqualityCheck -Name 'Frozen legacy blank SHA-256 values' -Expected 0 -Actual $frozenLegacyBlankHashes
Add-EqualityCheck -Name 'Frozen legacy unique SHA-256 values' -Expected 111 -Actual $frozenLegacyHashSet.Count
Add-EqualityCheck -Name 'Frozen legacy duplicate arithmetic' -Expected 1 -Actual ($frozenLegacySourceOccurrences - $frozenLegacyHashSet.Count)
Add-EqualityCheck -Name 'Frozen legacy total bytes' -Expected ([long]313921821) -Actual $frozenLegacyBytes
Add-EqualityCheck -Name 'Frozen legacy total pages' -Expected ([long]2210) -Actual $frozenLegacyPages

Add-EqualityCheck -Name 'PDF manifest row count' -Expected 113 -Actual $pdfRows.Count
Add-EqualityCheck -Name 'Web manifest row count' -Expected 914 -Actual $webRows.Count
Add-EqualityCheck -Name 'Pending manifest row count' -Expected 11 -Actual $pendingRows.Count

$pdfDirectory = Join-Path $root '论文'
if (Test-Path -LiteralPath $pdfDirectory -PathType Container) {
    $diskPdfFiles = @(Get-ChildItem -LiteralPath $pdfDirectory -Recurse -File | Where-Object { $_.Extension -ieq '.pdf' })
}
else {
    $diskPdfFiles = @()
    Add-Check -Name 'PDF directory exists' -Status 'FAIL' -Expected 'present' -Actual 'missing'
}

Add-EqualityCheck -Name 'PDF files on disk' -Expected 113 -Actual $diskPdfFiles.Count
Add-EqualityCheck -Name 'PDF manifest rows versus disk files' -Expected $pdfRows.Count -Actual $diskPdfFiles.Count

$manifestPathSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
$diskPathSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($file in $diskPdfFiles) {
    $diskPathSet.Add($file.FullName) | Out-Null
}

$invalidPathRows = New-Object 'System.Collections.Generic.List[string]'
$duplicateManifestPaths = New-Object 'System.Collections.Generic.List[string]'
$missingPdfPaths = New-Object 'System.Collections.Generic.List[string]'
$sizeMismatchPaths = New-Object 'System.Collections.Generic.List[string]'
$hashMismatchPaths = New-Object 'System.Collections.Generic.List[string]'
$manifestPdfPaths = New-Object 'System.Collections.Generic.List[string]'
$manifestHashSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
$duplicateManifestHashes = New-Object 'System.Collections.Generic.List[string]'
$blankManifestHashes = New-Object 'System.Collections.Generic.List[string]'
$sizeMatchCount = 0
$hashMatchCount = 0

foreach ($row in $pdfRows) {
    try {
        $pdfPath = Resolve-ContainedPath -BasePath $root -RelativePath ([string]$row.'汇总后文件')
    }
    catch {
        $invalidPathRows.Add(([string]$row.'汇总后文件')) | Out-Null
        continue
    }

    $manifestPdfPaths.Add($pdfPath) | Out-Null
    if (-not $manifestPathSet.Add($pdfPath)) {
        $duplicateManifestPaths.Add($pdfPath) | Out-Null
    }

    if (-not (Test-Path -LiteralPath $pdfPath -PathType Leaf)) {
        $missingPdfPaths.Add($pdfPath) | Out-Null
        continue
    }

    $manifestHash = ([string]$row.SHA256).Trim()
    if ([string]::IsNullOrWhiteSpace($manifestHash)) {
        $blankManifestHashes.Add($pdfPath) | Out-Null
    }
    elseif (-not $manifestHashSet.Add($manifestHash)) {
        $duplicateManifestHashes.Add($manifestHash) | Out-Null
    }

    $fileInfo = Get-Item -LiteralPath $pdfPath
    try {
        $expectedSize = [long]::Parse([string]$row.'文件大小_字节', [System.Globalization.CultureInfo]::InvariantCulture)
    }
    catch {
        $expectedSize = -1
    }

    if ($expectedSize -eq $fileInfo.Length) {
        $sizeMatchCount++
    }
    else {
        $sizeMismatchPaths.Add($pdfPath) | Out-Null
    }

    $actualHash = (Get-FileHash -LiteralPath $pdfPath -Algorithm SHA256).Hash
    if ($actualHash.Equals($manifestHash, [System.StringComparison]::OrdinalIgnoreCase)) {
        $hashMatchCount++
    }
    else {
        $hashMismatchPaths.Add($pdfPath) | Out-Null
    }
}

Add-EqualityCheck -Name 'Manifest paths outside RootPath or invalid' -Expected 0 -Actual $invalidPathRows.Count -Details (($invalidPathRows | Select-Object -First 3) -join ' | ')
Add-EqualityCheck -Name 'Duplicate PDF paths in manifest' -Expected 0 -Actual $duplicateManifestPaths.Count -Details (($duplicateManifestPaths | Select-Object -First 3) -join ' | ')
Add-EqualityCheck -Name 'Manifest PDF files present' -Expected $pdfRows.Count -Actual ($pdfRows.Count - $missingPdfPaths.Count - $invalidPathRows.Count) -Details (($missingPdfPaths | Select-Object -First 3) -join ' | ')
Add-EqualityCheck -Name 'PDF file sizes match manifest' -Expected $pdfRows.Count -Actual $sizeMatchCount -Details (($sizeMismatchPaths | Select-Object -First 3) -join ' | ')
Add-EqualityCheck -Name 'PDF SHA-256 values match manifest' -Expected $pdfRows.Count -Actual $hashMatchCount -Details (($hashMismatchPaths | Select-Object -First 3) -join ' | ')
Add-EqualityCheck -Name 'Blank PDF SHA-256 values in manifest' -Expected 0 -Actual $blankManifestHashes.Count -Details (($blankManifestHashes | Select-Object -First 3) -join ' | ')
Add-EqualityCheck -Name 'Duplicate PDF SHA-256 values in manifest' -Expected 0 -Actual $duplicateManifestHashes.Count -Details (($duplicateManifestHashes | Select-Object -First 3) -join ' | ')

$unlistedDiskPdfs = New-Object 'System.Collections.Generic.List[string]'
foreach ($file in $diskPdfFiles) {
    if (-not $manifestPathSet.Contains($file.FullName)) {
        $unlistedDiskPdfs.Add($file.FullName) | Out-Null
    }
}
Add-EqualityCheck -Name 'Unlisted PDF files on disk' -Expected 0 -Actual $unlistedDiskPdfs.Count -Details (($unlistedDiskPdfs | Select-Object -First 3) -join ' | ')

$diskTotalBytes = [long]0
foreach ($file in $diskPdfFiles) {
    $diskTotalBytes += [long]$file.Length
}
Add-EqualityCheck -Name 'PDF total bytes' -Expected ([long]315363681) -Actual $diskTotalBytes

$pdfInfoExe = $null
$pdfInfoDiscoveryDetail = ''
try {
    $pdfInfoExe = Resolve-PdfInfoExecutable -RequestedPath $PdfInfoPath
}
catch {
    $pdfInfoDiscoveryDetail = $_.Exception.Message
}

if ($null -eq $pdfInfoExe) {
    Add-Check -Name 'PDF page count verification' -Status 'WARN' -Expected 2214 -Actual 'NOT_VERIFIED' -Critical $false -Details ('No explicit pdfinfo.exe was found. ' + $pdfInfoDiscoveryDetail).Trim()
}
else {
    Write-Output ('PDF page verifier: {0}' -f $pdfInfoExe)
    $pageMatchCount = 0
    $pageTotal = 0
    $pageParseFailures = New-Object 'System.Collections.Generic.List[string]'
    $pageMismatchPaths = New-Object 'System.Collections.Generic.List[string]'
    $pdfInfoWarningPaths = New-Object 'System.Collections.Generic.List[string]'

    foreach ($row in $pdfRows) {
        try {
            $pdfPath = Resolve-ContainedPath -BasePath $root -RelativePath ([string]$row.'汇总后文件')
        }
        catch {
            $pageParseFailures.Add(([string]$row.'汇总后文件')) | Out-Null
            continue
        }

        if (-not (Test-Path -LiteralPath $pdfPath -PathType Leaf)) {
            $pageParseFailures.Add($pdfPath) | Out-Null
            continue
        }

        $previousErrorActionPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $output = @(& $pdfInfoExe $pdfPath 2>&1)
            $pdfInfoExitCode = $LASTEXITCODE
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }
        $outputText = ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
        $pageMatch = [regex]::Match($outputText, '(?m)^Pages:\s*(\d+)\s*$')
        $hasDiagnostic = [regex]::IsMatch($outputText, '(?im)(Internal Error|Syntax (?:Warning|Error)|^Error:)')

        if ($hasDiagnostic) {
            $pdfInfoWarningPaths.Add($pdfPath) | Out-Null
        }

        if ($pdfInfoExitCode -ne 0 -or -not $pageMatch.Success) {
            $pageParseFailures.Add($pdfPath) | Out-Null
            continue
        }

        $actualPages = [int]$pageMatch.Groups[1].Value
        $pageTotal += $actualPages

        try {
            $expectedPages = [int]::Parse([string]$row.'页数', [System.Globalization.CultureInfo]::InvariantCulture)
        }
        catch {
            $expectedPages = -1
        }

        if ($actualPages -eq $expectedPages) {
            $pageMatchCount++
        }
        else {
            $pageMismatchPaths.Add($pdfPath) | Out-Null
        }
    }

    Add-EqualityCheck -Name 'PDF page counts parsed' -Expected $pdfRows.Count -Actual ($pdfRows.Count - $pageParseFailures.Count) -Details (($pageParseFailures | Select-Object -First 3) -join ' | ')
    Add-EqualityCheck -Name 'PDF page counts match manifest' -Expected $pdfRows.Count -Actual $pageMatchCount -Details (($pageMismatchPaths | Select-Object -First 3) -join ' | ')
    Add-EqualityCheck -Name 'PDF total pages' -Expected 2214 -Actual $pageTotal

    if ($pdfInfoWarningPaths.Count -gt 0) {
        Add-Check -Name 'PDF parser diagnostic files' -Status 'WARN' -Expected 0 -Actual $pdfInfoWarningPaths.Count -Critical $false -Details (($pdfInfoWarningPaths | Select-Object -First 3) -join ' | ')
    }
    else {
        Add-Check -Name 'PDF parser diagnostic files' -Status 'PASS' -Expected 0 -Actual 0 -Critical $false
    }
}

$ordinalUrls = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$ordinalIgnoreCaseUrls = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
$blankUrlCount = 0
foreach ($row in $webRows) {
    $url = [string]$row.URL
    if ([string]::IsNullOrWhiteSpace($url)) {
        $blankUrlCount++
        continue
    }

    $ordinalUrls.Add($url) | Out-Null
    $ordinalIgnoreCaseUrls.Add($url) | Out-Null
}

Add-EqualityCheck -Name 'Blank URL rows' -Expected 0 -Actual $blankUrlCount
Add-EqualityCheck -Name 'Unique URLs (StringComparer.Ordinal)' -Expected 893 -Actual $ordinalUrls.Count
Add-EqualityCheck -Name 'Unique URLs (StringComparer.OrdinalIgnoreCase)' -Expected 892 -Actual $ordinalIgnoreCaseUrls.Count

Add-EqualityCheck -Name 'Summary unique_pdfs' -Expected 113 -Actual ([int]$summary.unique_pdfs)
Add-EqualityCheck -Name 'Summary source_pdf_occurrences' -Expected 114 -Actual ([int]$summary.source_pdf_occurrences)
Add-EqualityCheck -Name 'Summary duplicates_removed' -Expected 1 -Actual ([int]$summary.duplicates_removed)
Add-EqualityCheck -Name 'Summary source occurrences minus duplicates equals unique PDFs' -Expected 113 -Actual (([int]$summary.source_pdf_occurrences) - ([int]$summary.duplicates_removed))
Add-EqualityCheck -Name 'Summary paper_inventory_records (frozen legacy snapshot)' -Expected 112 -Actual ([int]$summary.paper_inventory_records)
Add-EqualityCheck -Name 'Summary paper_inventory_downloaded (frozen legacy snapshot)' -Expected 101 -Actual ([int]$summary.paper_inventory_downloaded)
Add-EqualityCheck -Name 'Summary combined_online_urls' -Expected 893 -Actual ([int]$summary.combined_online_urls)
Add-EqualityCheck -Name 'Summary pending_papers' -Expected 11 -Actual ([int]$summary.pending_papers)

$sourcePdfOccurrences = 0
foreach ($row in $pdfRows) {
    $sourceEntries = @(([string]$row.'源文件').Split('；') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $sourcePdfOccurrences += $sourceEntries.Count
}
Add-EqualityCheck -Name 'Manifest source-file occurrences' -Expected 114 -Actual $sourcePdfOccurrences
Add-EqualityCheck -Name 'Manifest unique SHA-256 values' -Expected 113 -Actual $manifestHashSet.Count
Add-EqualityCheck -Name 'Manifest source occurrences minus unique SHA-256 values' -Expected 1 -Actual ($sourcePdfOccurrences - $manifestHashSet.Count)

$manifestPlatformCounts = @{}
$manifestCategoryCounts = @{}
foreach ($row in $pdfRows) {
    $platform = [string]$row.'平台'
    $category = [string]$row.'资料类别'
    if (-not $manifestPlatformCounts.ContainsKey($platform)) {
        $manifestPlatformCounts[$platform] = 0
    }
    $manifestPlatformCounts[$platform]++

    $categoryKey = $platform + ' / ' + $category
    if (-not $manifestCategoryCounts.ContainsKey($categoryKey)) {
        $manifestCategoryCounts[$categoryKey] = 0
    }
    $manifestCategoryCounts[$categoryKey]++
}

$expectedPlatformCounts = [ordered]@{
    'Google TPU' = 25
    'NVIDIA GPU' = 65
    '华为昇腾/达芬奇' = 15
    'Groq LPU' = 2
    'AMD Instinct' = 6
}
$expectedCategoryCounts = [ordered]@{
    'Google TPU / 厂商直接架构论文' = 13
    'Google TPU / 独立逆向与微基准' = 7
    'Google TPU / 系统与性能补充' = 5
    'NVIDIA GPU / 厂商直接架构论文' = 12
    'NVIDIA GPU / 官方白皮书与技术资料' = 11
    'NVIDIA GPU / 独立逆向与微基准' = 38
    'NVIDIA GPU / 系统与性能补充' = 4
    '华为昇腾/达芬奇 / 厂商直接架构论文' = 2
    '华为昇腾/达芬奇 / 独立逆向与微基准' = 8
    '华为昇腾/达芬奇 / 系统与性能补充' = 5
    'Groq LPU / 厂商直接架构论文' = 1
    'Groq LPU / 官方白皮书与技术资料' = 1
    'AMD Instinct / 官方白皮书与技术资料' = 4
    'AMD Instinct / 厂商产品资料' = 2
}

$summaryPlatformTotal = 0
foreach ($property in $summary.platform_pdf_counts.PSObject.Properties) {
    $summaryPlatformTotal += [int]$property.Value
}
Add-EqualityCheck -Name 'Manifest platform count key count' -Expected $expectedPlatformCounts.Count -Actual $manifestPlatformCounts.Count
Add-EqualityCheck -Name 'Summary platform count key count' -Expected $expectedPlatformCounts.Count -Actual $summary.platform_pdf_counts.PSObject.Properties.Count
Add-EqualityCheck -Name 'Manifest platform count total' -Expected 113 -Actual (($manifestPlatformCounts.Values | Measure-Object -Sum).Sum)
Add-EqualityCheck -Name 'Summary platform count total' -Expected 113 -Actual $summaryPlatformTotal
foreach ($platform in $expectedPlatformCounts.Keys) {
    $summaryProperty = $summary.platform_pdf_counts.PSObject.Properties[$platform]
    $summaryCount = if ($null -eq $summaryProperty) { -1 } else { [int]$summaryProperty.Value }
    $manifestCount = if ($manifestPlatformCounts.ContainsKey($platform)) { [int]$manifestPlatformCounts[$platform] } else { -1 }
    Add-EqualityCheck -Name ('Manifest platform count: ' + $platform) -Expected $expectedPlatformCounts[$platform] -Actual $manifestCount
    Add-EqualityCheck -Name ('Summary platform count: ' + $platform) -Expected $expectedPlatformCounts[$platform] -Actual $summaryCount
}

$summaryCategoryTotal = 0
foreach ($property in $summary.category_pdf_counts.PSObject.Properties) {
    $summaryCategoryTotal += [int]$property.Value
}
Add-EqualityCheck -Name 'Manifest category count key count' -Expected $expectedCategoryCounts.Count -Actual $manifestCategoryCounts.Count
Add-EqualityCheck -Name 'Summary category count key count' -Expected $expectedCategoryCounts.Count -Actual $summary.category_pdf_counts.PSObject.Properties.Count
Add-EqualityCheck -Name 'Manifest category count total' -Expected 113 -Actual (($manifestCategoryCounts.Values | Measure-Object -Sum).Sum)
Add-EqualityCheck -Name 'Summary category count total' -Expected 113 -Actual $summaryCategoryTotal
foreach ($categoryKey in $expectedCategoryCounts.Keys) {
    $summaryProperty = $summary.category_pdf_counts.PSObject.Properties[$categoryKey]
    $summaryCount = if ($null -eq $summaryProperty) { -1 } else { [int]$summaryProperty.Value }
    $manifestCount = if ($manifestCategoryCounts.ContainsKey($categoryKey)) { [int]$manifestCategoryCounts[$categoryKey] } else { -1 }
    Add-EqualityCheck -Name ('Manifest category count: ' + $categoryKey) -Expected $expectedCategoryCounts[$categoryKey] -Actual $manifestCount
    Add-EqualityCheck -Name ('Summary category count: ' + $categoryKey) -Expected $expectedCategoryCounts[$categoryKey] -Actual $summaryCount
}

$exitCode = Show-Summary
exit $exitCode

