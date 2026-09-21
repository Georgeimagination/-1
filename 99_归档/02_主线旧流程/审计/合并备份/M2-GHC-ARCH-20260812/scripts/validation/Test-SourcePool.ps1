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
}

$expectedHashes = [ordered]@{
    '清单\论文PDF清单.csv' = 'af156c11bbfa6ca81096e776b91ff3b0ae303515855fcce0b37195434e4ea313'
    '清单\网页与在线资料.csv' = 'f19991c731fcdca8e0dee65601a2637a5568bc1fde46b357757d19292aa1395f'
    '清单\待补论文清单.csv' = 'b5a5993c0a29364c5be3c2d6d35321e3150b5599913e3fafe887bff3a02307bd'
    '清单\汇总统计.json' = 'd07c45e52e9214cee416a843a8e77f5f982bf7eb21d8bb80b81a736a7d298770'
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

Add-EqualityCheck -Name 'PDF manifest row count' -Expected 105 -Actual $pdfRows.Count
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

Add-EqualityCheck -Name 'PDF files on disk' -Expected 105 -Actual $diskPdfFiles.Count
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
    if ($actualHash.Equals([string]$row.SHA256, [System.StringComparison]::OrdinalIgnoreCase)) {
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
Add-EqualityCheck -Name 'PDF total bytes' -Expected ([long]291015241) -Actual $diskTotalBytes

$pdfInfoExe = $null
$pdfInfoDiscoveryDetail = ''
try {
    $pdfInfoExe = Resolve-PdfInfoExecutable -RequestedPath $PdfInfoPath
}
catch {
    $pdfInfoDiscoveryDetail = $_.Exception.Message
}

if ($null -eq $pdfInfoExe) {
    Add-Check -Name 'PDF page count verification' -Status 'WARN' -Expected 2104 -Actual 'NOT_VERIFIED' -Critical $false -Details ('No explicit pdfinfo.exe was found. ' + $pdfInfoDiscoveryDetail).Trim()
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
    Add-EqualityCheck -Name 'PDF total pages' -Expected 2104 -Actual $pageTotal

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

Add-EqualityCheck -Name 'Summary unique_pdfs' -Expected 105 -Actual ([int]$summary.unique_pdfs)
Add-EqualityCheck -Name 'Summary combined_online_urls' -Expected 893 -Actual ([int]$summary.combined_online_urls)
Add-EqualityCheck -Name 'Summary pending_papers' -Expected 11 -Actual ([int]$summary.pending_papers)

$exitCode = Show-Summary
exit $exitCode

