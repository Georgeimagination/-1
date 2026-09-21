$ErrorActionPreference = 'Stop'
$PackageRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$OutDir = Join-Path $PackageRoot 'structured'
if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
function New-DataRow {
    param([string[]]$Header, [object[]]$Values)
    if ($Header.Count -ne $Values.Count) { throw "Header/value count mismatch: $($Header.Count) != $($Values.Count)" }
    $record = [ordered]@{}
    for ($i = 0; $i -lt $Header.Count; $i++) { $record[$Header[$i]] = if ($null -eq $Values[$i]) { '' } else { [string]$Values[$i] } }
    [pscustomobject]$record
}
function Write-DataCsv {
    param([string]$Name, [string[]]$Header, [object[]]$Rows)
    $path = Join-Path $OutDir $Name
    if ($Rows.Count -eq 0) {
        $line = ($Header | ForEach-Object { '"' + ($_ -replace '"','""') + '"' }) -join ','
        [System.IO.File]::WriteAllText($path, $line + "`r`n", $Utf8NoBom)
    } else {
        $lines = @($Rows | Select-Object -Property $Header | ConvertTo-Csv -NoTypeInformation)
        [System.IO.File]::WriteAllLines($path, $lines, $Utf8NoBom)
    }
    if (-not (Test-Path -LiteralPath $path)) { throw "Failed to write $path" }
}
$H = @{}
$H['card-completeness.csv'] = @('card_completeness_id','object_id','domain','completeness_status','assessed_date','assessor','review_status','notes')
$H['components.csv'] = @('component_id','owner_object_id','parent_component_id','component_domain','component_type','canonical_label','review_status','notes')
$H['condition-sets.csv'] = @('condition_set_id','condition_fingerprint','precision_path_id','sparsity_mode','sparsity_pattern','operation_type','operation_count_rule','performance_basis','support_level','power_mode','frequency_value','frequency_unit','software_version','workload_stage','bandwidth_direction','aggregation_scope','traffic_basis','measurement_scope','effective_date','review_status','notes')
$H['derived-inputs.csv'] = @('derived_input_id','derived_fact_id','input_order','input_fact_id','input_role','review_status','notes')
$H['derived-metrics.csv'] = @('derived_metric_id','derived_fact_id','formula_id','formula_expression','output_unit','scope_check_status','precision_check_status','direction_check_status','review_status','notes')
$H['facts.csv'] = @('fact_id','object_id','component_id','link_id','object_relation_id','precision_path_id','capability_id','topology_id','field_id','normalized_value_text','normalized_value_number','normalized_unit','condition_set_id','fact_kind','evidence_state','resolution_state','valid_from','valid_to','confidence','confidence_reason','fact_fingerprint','review_status','notes')
$H['field-requirements.csv'] = @('requirement_id','object_id','component_id','link_id','object_relation_id','precision_path_id','capability_id','topology_id','field_id','requirement_status','applicability_reason','search_status','last_searched_date','requirement_fingerprint','review_status','notes')
$H['links.csv'] = @('link_id','owner_object_id','endpoint_a_id','endpoint_b_id','link_level','canonical_label','review_status','notes')
$H['memory-levels.csv'] = @('memory_level_id','parent_memory_level_id','level_class','canonical_label','review_status','notes')
$H['precision-paths.csv'] = @('precision_path_id','component_id','canonical_label','operation_class','review_status','notes')
$H['special-capabilities.csv'] = @('capability_id','owner_object_id','component_id','capability_type','canonical_label','review_status','notes')
$H['topologies.csv'] = @('topology_id','owner_object_id','canonical_label','review_status','notes')
$H['conflict-groups.csv'] = @('conflict_group_id','object_id','component_id','link_id','object_relation_id','precision_path_id','capability_id','topology_id','field_id','condition_set_id','conflict_type','resolution_status','preferred_fact_id','resolution_rationale','reviewer','review_date','review_status','notes')
$H['conflict-members.csv'] = @('conflict_member_id','conflict_group_id','fact_id','member_role','review_status','notes')
$H['fact-assertions.csv'] = @('assertion_id','fact_id','source_id','claim_role','assertion_mode','assertion_relation','raw_value_text','raw_value_number','raw_unit','source_locator','quoted_context','extraction_status','extractor','reviewer','review_date','assertion_fingerprint','review_status','notes')
$H['requirement-evidence.csv'] = @('requirement_evidence_id','requirement_id','source_id','evidence_relation','source_locator','quoted_context','reviewer','review_date','review_status','notes')
$H['search-log.csv'] = @('search_id','requirement_id','searched_date','query_or_path','source_types_checked','result_status','researcher','review_status','notes')
$H['search-results.csv'] = @('search_result_id','search_id','source_id','result_relation','review_status','notes')
$H['selection-members.csv'] = @('selection_member_id','selection_run_id','source_id','selected_role','mandatory_reason','review_status','notes')
$H['selection-runs.csv'] = @('selection_run_id','scope_kind','scope_id','cutoff_date','algorithm_version','created_date','reviewer','status','review_status','notes')
$H['source-coverage.csv'] = @('coverage_id','covered_source_id','covering_source_id','coverage_scope','equivalence_status','rationale','reviewed_by','review_date','review_status','notes')
$H['source-endpoints.csv'] = @('endpoint_id','source_id','endpoint_type','url','local_path','sha256','page_count','mime_type','access_date','http_status','snapshot_date','is_preferred_endpoint','accessibility_status','review_status','notes')
$H['source-families.csv'] = @('source_family_id','canonical_title','family_kind','publisher_or_organization','persistent_work_id','review_status','notes')
$H['sources.csv'] = @('source_id','source_family_id','title','author_or_organization','source_type','publication_date','version_label','language','source_authority','source_status','content_fingerprint','last_verified_date','review_status','notes')
$H['source-screening.csv'] = @('screening_id','source_id','screening_status','rationale','full_text_read_status','screened_by','screened_date','screening_fingerprint','review_status','notes')
$H['source-selected-roles.csv'] = @('source_selected_role_id','source_id','selected_role','rationale','review_status','notes')

$components = @(
    (New-DataRow $H['components.csv'] @('COMP-M2W3-AMD-MI350P-CU','OBJ-AMD-MI350P','','control','control','MI350P enabled Compute Unit configuration','draft','Product-scoped count anchor only; CDNA 4 CU mechanisms remain on the architecture object.')),
    (New-DataRow $H['components.csv'] @('COMP-M2W3-AMD-MI350P-MATRIX','OBJ-AMD-MI350P','','compute','matrix','MI350P published matrix peak paths','draft','Logical product aggregate for vendor-published matrix peaks; not an added physical block.')),
    (New-DataRow $H['components.csv'] @('COMP-M2W3-AMD-MI350P-VECTOR','OBJ-AMD-MI350P','','compute','vector','MI350P published vector peak paths','draft','Logical product aggregate for vendor-published vector peaks; not an added physical block.')),
    (New-DataRow $H['components.csv'] @('COMP-M2W3-AMD-MI350P-HBM3E','OBJ-AMD-MI350P','','memory','memory_level','MI350P HBM3E memory','draft','Product-local HBM3E capacity and vendor peak bandwidth only.')),
    (New-DataRow $H['components.csv'] @('COMP-M2W3-AMD-MI350P-LLC','OBJ-AMD-MI350P','','memory','memory_level','MI350P last-level cache','draft','Product page publishes 128 MB LLC; brochure calls the same 128 MB AMD Infinity Cache last level.'))
)
$memory = @(
    (New-DataRow $H['memory-levels.csv'] @('COMP-M2W3-AMD-MI350P-HBM3E','','hbm','MI350P HBM3E memory','draft','144 GB and 4 TB/s are direct per-card values; decimal units are retained.')),
    (New-DataRow $H['memory-levels.csv'] @('COMP-M2W3-AMD-MI350P-LLC','','llc','MI350P last-level cache','draft','128 MB as printed; not reinterpreted as 128 MiB.'))
)
$links = @(
    (New-DataRow $H['links.csv'] @('LINK-M2W3-AMD-MI350P-PCIE','OBJ-AMD-MI350P','OBJ-AMD-MI350P','','host_device','MI350P PCIe Gen 5 x16 host-device endpoint','draft','Brochure gives 128 GB/s without direction; no single-direction or bidirectional conversion is inferred.'))
)
$paths = @(
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-MXFP4-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P peak MXFP4 matrix path','matrix','draft','Vendor performance-format label only; A/B, product, accumulation and output encodings are not stated.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-MXFP6-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P peak MXFP6 matrix path','matrix','draft','Vendor performance-format label only; A/B, product, accumulation and output encodings are not stated.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-MXFP8-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P peak MXFP8 matrix path','matrix','draft','Vendor performance-format label only; A/B, product, accumulation and output encodings are not stated.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-OCP-FP8-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P peak OCP-FP8 E5M2/E4M3 matrix path','matrix','draft','Base and structured-sparsity peaks are separate; no exact operand pairing, product, accumulation or output contract is stated.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-FP16-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P FP16 matrix path','matrix','draft','Base and structured-sparsity peaks are separate; the base row is not silently labeled dense.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-BF16-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P BF16 matrix path','matrix','draft','Base and structured-sparsity peaks are separate; the base row is not silently labeled dense.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-INT8-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P INT8 matrix path','matrix','draft','Base and structured-sparsity peaks use OP/s; the base row is not silently labeled dense.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-FP32-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P FP32 matrix path','matrix','draft','Vendor peak label only; sparsity, product, accumulation and output formats are not stated.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-FP64-MATRIX','COMP-M2W3-AMD-MI350P-MATRIX','MI350P FP64 matrix path','matrix','draft','Vendor peak label only; sparsity, product, accumulation and output formats are not stated.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-FP16-VECTOR','COMP-M2W3-AMD-MI350P-VECTOR','MI350P FP16 vector path','vector','draft','Vendor peak label only; lane count and product-specific accumulation are not inferred.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-FP32-VECTOR','COMP-M2W3-AMD-MI350P-VECTOR','MI350P FP32 vector path','vector','draft','Vendor peak label only; lane count and product-specific accumulation are not inferred.')),
    (New-DataRow $H['precision-paths.csv'] @('PPATH-M2W3-AMD-MI350P-FP64-VECTOR','COMP-M2W3-AMD-MI350P-VECTOR','MI350P FP64 vector path','vector','draft','Vendor peak label only; lane count and product-specific accumulation are not inferred.'))
)
$conditions = @(
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-XCD-COUNT','M2W3|MI350P|die-count|XCD','','not_applicable','','fixed_function','not_specified','vendor_label_unresolved','hardware_capability','','','','','not_specified','','','','per_object','2026-08-13','draft','Count is specifically for accelerated compute dies in one MI350P PCIe card; the brochure per-CU details are not copied.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-IOD-COUNT','M2W3|MI350P|die-count|IOD','','not_applicable','','fixed_function','not_specified','vendor_label_unresolved','hardware_capability','','','','','not_specified','','','','per_object','2026-08-13','draft','Count is specifically for I/O dies in one MI350P PCIe card.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-POWER-MAX','M2W3|MI350P|power|max-tbp','','not_applicable','','fixed_function','not_specified','vendor_label_unresolved','hardware_capability','max_tbp','','','','not_specified','','','','per_object','2026-08-13','draft','Maximum typical board power, not a sustained workload measurement.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-POWER-CONFIG','M2W3|MI350P|power|configurable-tbp','','not_applicable','','fixed_function','not_specified','vendor_label_unresolved','hardware_capability','configurable_tbp','','','','not_specified','','','','per_object','2026-08-13','draft','Vendor-configurable 450 W TBP point; no software or workload condition is published.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-PEAK-MATRIX-UNSPEC','M2W3|MI350P|matrix|peak|sparsity-not-specified','','not_specified','Product page does not label MXFP4, MXFP6, MXFP8, FP32 or FP64 rows dense or sparse.','matrix_mma','vendor_label','theoretical_peak','hardware_peak_published','','','','','not_specified','','per_endpoint','vendor_nameplate','per_object','2026-08-13','draft','Single-card vendor peak. Power mode, path-specific frequency and FMA counting are not stated.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-PEAK-MATRIX-BASE','M2W3|MI350P|matrix|peak|base-row|sparsity-not-specified','','not_specified','Base product-page row, distinct from a separately labeled with-structured-sparsity row.','matrix_mma','vendor_label','theoretical_peak','hardware_peak_published','','','','','not_specified','','per_endpoint','vendor_nameplate','per_object','2026-08-13','draft','The source does not print dense; power mode and operation-count rule remain unspecified.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-PEAK-MATRIX-STRUCTURED','M2W3|MI350P|matrix|peak|structured-sparsity-pattern-unstated','','structured_sparse','Vendor calls it structured sparsity but does not state the pattern on the product page or brochure.','matrix_mma','vendor_label','theoretical_peak','hardware_peak_published','','','','','not_specified','','per_endpoint','vendor_nameplate','per_object','2026-08-13','draft','Do not assume 2:4 from CDNA 4 or a neighboring SKU.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-PEAK-VECTOR','M2W3|MI350P|vector|peak','','not_applicable','','vector_alu','vendor_label','theoretical_peak','hardware_peak_published','','','','','not_specified','','per_endpoint','vendor_nameplate','per_object','2026-08-13','draft','Single-card vector peaks from the fixed brochure table labeled Estimated; no lane count or product-specific accumulation is inferred.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-HBM3E-PEAK-BW','M2W3|MI350P|HBM3E|peak-memory-bandwidth|direction-unstated','','not_applicable','','data_move','not_specified','theoretical_peak','hardware_peak_published','','','','','not_specified','direction_not_specified','per_endpoint','vendor_nameplate','per_object','2026-08-13','draft','4 TB/s is the per-card peak memory bandwidth; read/write direction is not stated.')),
    (New-DataRow $H['condition-sets.csv'] @('COND-M2W3-AMD-MI350P-PCIE-BW','M2W3|MI350P|PCIe5x16|128GBps|direction-unstated','','not_applicable','','data_move','not_specified','vendor_label_unresolved','hardware_capability','','','','','not_specified','direction_not_specified','per_endpoint','vendor_nameplate','per_object','2026-08-13','draft','Brochure gives 128 GB/s without direction, payload basis or theoretical-versus-sustained qualifier; no halving or doubling is applied.'))
)

$families = @(
    (New-DataRow $H['source-families.csv'] @('SFAM-M2W3-AMD-MI350P-PRODUCT','AMD Instinct MI350P PCIe product page','dynamic_page_history','AMD','','draft','Exact-object dynamic product-page family.')),
    (New-DataRow $H['source-families.csv'] @('SFAM-M2W3-AMD-MI350P-BROCHURE','AMD Instinct MI350P PCIe product brochure','document_revision_series','AMD','','draft','Fixed product-brochure revision family.')),
    (New-DataRow $H['source-families.csv'] @('SFAM-M2W3-AMD-MI350P-BLOG','AMD Instinct MI350P PCIe dated official article','publication_versions','AMD','','draft','Dated AMD article family.'))
)
$sources = @(
    (New-DataRow $H['sources.csv'] @('SRC-M2W3-AMD-MI350P-PRODUCT-20260813','SFAM-M2W3-AMD-MI350P-PRODUCT','AMD Instinct™ MI350P PCIe® Cards','AMD','product_page','','snapshot-2026-08-13','en','first_party','current','sha256:09b3ffd469353dfb2456fc2fca67b421aa8bf5ae48be809fa64f1a30dda3c088','2026-08-13','draft','Fixed official HTML, 196,285 bytes. Dynamic values are bounded to the access date.')),
    (New-DataRow $H['sources.csv'] @('SRC-M2W3-AMD-MI350P-BROCHURE-202605','SFAM-M2W3-AMD-MI350P-BROCHURE','AMD Instinct™ MI350P PCIe® Card','AMD','product_brief','','LE-93401-00 05/26','en','first_party','current','sha256:a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29','2026-08-13','draft','Fixed official two-page brochure, 782,486 bytes. Its estimated table directly labels the FP16, FP32 and FP64 vector peaks; later product-page rows corroborate the values without the vector label.')),
    (New-DataRow $H['sources.csv'] @('SRC-M2W3-AMD-MI350P-BLOG-20260507','SFAM-M2W3-AMD-MI350P-BLOG','AMD Instinct MI350P PCIe GPUs: Run Enterprise AI on Your Existing Infrastructure','AMD','other','2026-05-07','published-2026-05-07;snapshot-2026-08-13','en','first_party','current','sha256:2bc9cbb81e424e4d1c5d6912b43e7cfb1107081f159b012d8ad9cffd3b66dfb8','2026-08-13','draft','Fixed dated article, 184,522 bytes. Used only for date-bounded available status; preliminary performance claims are excluded.'))
)
$endpoints = @(
    (New-DataRow $H['source-endpoints.csv'] @('END-M2W3-AMD-MI350P-PRODUCT-REMOTE','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','html_page','https://www.amd.com/en/products/accelerators/instinct/mi350/mi350p.html','','','','text/html','2026-08-13','200','','false','accessible','draft','Official canonical page. Initial sandboxed network access was denied; approved elevated GET returned HTTP 200.')),
    (New-DataRow $H['source-endpoints.csv'] @('END-M2W3-AMD-MI350P-PRODUCT-SNAPSHOT','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','web_snapshot','','审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD/fixed-candidates/amd-instinct-mi350p-pcie-2026-08-13.html','09b3ffd469353dfb2456fc2fca67b421aa8bf5ae48be809fa64f1a30dda3c088','','text/html','2026-08-13','','2026-08-13','true','accessible','draft','Fixed official HTML snapshot; 196,285 bytes.')),
    (New-DataRow $H['source-endpoints.csv'] @('END-M2W3-AMD-MI350P-BROCHURE-REMOTE','SRC-M2W3-AMD-MI350P-BROCHURE-202605','pdf_direct','https://www.amd.com/content/dam/amd/en/documents/epyc-business-docs/other/amd-instinct-mi350p-product-brochure.pdf','','','','application/pdf','2026-08-13','200','','false','accessible','draft','Official AMD PDF endpoint checked on 2026-08-13.')),
    (New-DataRow $H['source-endpoints.csv'] @('END-M2W3-AMD-MI350P-BROCHURE-LOCAL','SRC-M2W3-AMD-MI350P-BROCHURE-202605','local_pdf','','审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD/fixed-candidates/amd-instinct-mi350p-product-brochure-2026-08-13.pdf','a4e93edffc6c2a03668eef72b84d85e1d2586afb331c2228595d1549609afb29','2','application/pdf','2026-08-13','','2026-08-13','true','accessible','draft','Fixed official PDF; 782,486 bytes. Both pages visually and textually checked.')),
    (New-DataRow $H['source-endpoints.csv'] @('END-M2W3-AMD-MI350P-BLOG-REMOTE','SRC-M2W3-AMD-MI350P-BLOG-20260507','html_page','https://www.amd.com/en/blogs/2026/amd-instinct-mi350p-pcie-gpus-run-enterprise-ai-on-your.html','','','','text/html','2026-08-13','200','','false','accessible','draft','Official dated article checked on 2026-08-13.')),
    (New-DataRow $H['source-endpoints.csv'] @('END-M2W3-AMD-MI350P-BLOG-SNAPSHOT','SRC-M2W3-AMD-MI350P-BLOG-20260507','web_snapshot','','审计/子代理交接/m2_staging/M2-W3-AMD-MI350P-CARD/fixed-candidates/amd-mi350p-pcie-blog-2026-08-13.html','2bc9cbb81e424e4d1c5d6912b43e7cfb1107081f159b012d8ad9cffd3b66dfb8','','text/html','2026-08-13','','2026-08-13','true','accessible','draft','Fixed official HTML snapshot; 184,522 bytes.'))
)
$facts = @()
$assertions = @()
function Add-DirectFact {
    param(
        [string]$Suffix,[string]$Component,[string]$Link,[string]$PrecisionPath,[string]$Field,
        [string]$ValueText,[string]$ValueNumber,[string]$Unit,[string]$Condition,[string]$Evidence,
        [string]$ValidFrom,[string]$Confidence,[string]$ConfidenceReason,[string]$Notes,
        [string]$Source,[string]$SourceTag,[string]$ClaimRole,[string]$RawText,[string]$RawNumber,[string]$RawUnit,
        [string]$Locator,[string]$Quote,[string]$AssertionRelation,[string]$AssertionNotes
    )
    $factId = "FACT-M2W3-AMD-MI350P-$Suffix"
    if (-not $AssertionRelation) { $AssertionRelation = 'supports' }
    $object = if (-not $Component -and -not $Link -and -not $PrecisionPath) { 'OBJ-AMD-MI350P' } else { '' }
    $target = if ($Component) { $Component } elseif ($Link) { $Link } elseif ($PrecisionPath) { $PrecisionPath } else { $object }
    $valueKey = if ($ValueNumber) { $ValueNumber } else { ($ValueText -replace '\s+','-') }
    $fingerprint = "$target|$Field|$valueKey|$Condition"
    $script:facts += New-DataRow $H['facts.csv'] @($factId,$object,$Component,$Link,'',$PrecisionPath,'','',$Field,$ValueText,$ValueNumber,$Unit,$Condition,'direct_statement',$Evidence,'provisional',$ValidFrom,'',$Confidence,$ConfidenceReason,$fingerprint,'draft',$Notes)
    $assertId = "ASSERT-M2W3-AMD-MI350P-$Suffix-$SourceTag"
    if ($RawNumber -and $RawText) { $RawText = '' }
    $assertFp = "$factId|$Source|$AssertionRelation|$Locator"
    $extractor = if ($Suffix -in @('TRANSISTORS','FP16-VECTOR-PEAK','FP32-VECTOR-PEAK','FP64-VECTOR-PEAK')) { 'm2_w3_mi350p_remediation' } else { 'm2_w3_mi350p_source_prep' }
    $script:assertions += New-DataRow $H['fact-assertions.csv'] @($assertId,$factId,$Source,$ClaimRole,'direct_statement',$AssertionRelation,$RawText,$RawNumber,$RawUnit,$Locator,$Quote,'source_checked',$extractor,'','2026-08-13',$assertFp,'draft',$AssertionNotes)
}
function Add-SecondAssertion {
    param([string]$Suffix,[string]$Source,[string]$SourceTag,[string]$ClaimRole,[string]$RawText,[string]$RawNumber,[string]$RawUnit,[string]$Locator,[string]$Quote,[string]$Relation='supports',[string]$Notes='')
    $factId = "FACT-M2W3-AMD-MI350P-$Suffix"
    $assertId = "ASSERT-M2W3-AMD-MI350P-$Suffix-$SourceTag"
    if ($RawNumber -and $RawText) { $RawText = '' }
    $assertFp = "$factId|$Source|$Relation|$Locator"
    $script:assertions += New-DataRow $H['fact-assertions.csv'] @($assertId,$factId,$Source,$ClaimRole,'direct_statement',$Relation,$RawText,$RawNumber,$RawUnit,$Locator,$Quote,'source_checked','m2_w3_mi350p_source_prep','','2026-08-13',$assertFp,'draft',$Notes)
}

Add-DirectFact 'VENDOR' '' '' '' 'FIELD-ID-VENDOR' 'AMD' '' '' 'COND-NONE' 'single_source' '' 'high' 'Dedicated first-party exact product page.' '' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'identity' 'AMD' '' '' 'HTML title, H1 and page publisher' ''
Add-DirectFact 'FAMILY' '' '' '' 'FIELD-ID-FAMILY' 'AMD Instinct' '' '' 'COND-NONE' 'single_source' '' 'high' 'Product Basics names the Instinct family on the exact object page.' '' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'identity' 'Instinct' '' '' 'HTML lines 7013-7043, Product Basics: Family and Series' 'Family: Instinct; Series: Instinct MI350 Series' '' 'Normalized with vendor prefix; Series is not promoted to a separate fact.'
Add-DirectFact 'NAME' '' '' '' 'FIELD-ID-NAME' 'AMD Instinct MI350P PCIe' '' '' 'COND-NONE' 'corroborated' '' 'high' 'Exact product page and fixed brochure title match the PCIe card identity.' 'Trademark marks and plural Cards are omitted only in normalized text.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'identity' 'AMD Instinct™ MI350P PCIe® Cards' '' '' 'HTML title and H1, lines 8 and 6841' 'AMD Instinct™ MI350P PCIe® Cards'
Add-SecondAssertion 'NAME' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'identity' 'AMD Instinct™ MI350P PCIe® Card' '' '' 'p. 1 title' 'AMD INSTINCT™ MI350P PCIe® CARD'
Add-DirectFact 'SKU' '' '' '' 'FIELD-ID-SKU' 'MI350P' '' '' 'COND-NONE' 'single_source' '' 'high' 'Exact product title identifies the MI350P SKU; PCIe remains the form-factor qualifier.' '' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'identity' 'MI350P' '' '' 'HTML title and Product Basics, line 7005' 'AMD Instinct™ MI350P'
Add-DirectFact 'OBJECT-TYPE' '' '' '' 'FIELD-ID-OBJECT-TYPE' 'card' '' '' 'COND-NONE' 'single_source' '' 'high' 'Board Specifications explicitly states PCIe Add-in Card, matching the frozen project object_type.' 'The generic Product Basics value Servers is not used for object type.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'identity' 'PCIe® Add-in Card' '' '' 'HTML lines 7760-7798, Board Specifications' 'GPU Form Factor: PCIe® Add-in Card'
Add-DirectFact 'STATUS' '' '' '' 'FIELD-ID-STATUS' 'available' '' '' 'COND-NONE' 'source_with_caveat' '2026-05-07' 'high' 'The dated exact-product AMD article explicitly says MI350P PCIe cards are available in air-cooled systems.' '2026-05-07 is the earliest evidenced status date in this package, not a claimed first-availability date; the sentence is system-deployment context.' 'SRC-M2W3-AMD-MI350P-BLOG-20260507' 'BLOG' 'status_version' 'Available in air-cooled systems with up to eight accelerator cards' '' '' 'HTML line 6644; publication date line 6572' 'Available in air-cooled systems with up to eight accelerator cards' 'qualifies' 'Available status is retained; up-to-eight-card system aggregation migrates zero facts.'
Add-DirectFact 'PROCESS' '' '' '' 'FIELD-PHY-PROCESS' 'TSMC 3 nm and 6 nm FinFET' '' '' 'COND-NONE' 'corroborated' '' 'high' 'Exact product page and fixed brochure match.' 'The sources do not map each node to XCD or IOD.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'TSMC 3nm | 6nm FinFET' '' '' 'HTML lines 7109-7119, GPU Specifications' 'Lithography: TSMC 3nm | 6nm FinFET'
Add-SecondAssertion 'PROCESS' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'TSMC 3nm/6nm FinFET' '' '' 'p. 1, Specifications, Lithography' 'TSMC 3nm/6nm FinFET'
Add-DirectFact 'XCD-COUNT' '' '' '' 'FIELD-PHY-DIE-COUNT' '' '4' 'count' 'COND-M2W3-AMD-MI350P-XCD-COUNT' 'single_source' '' 'high' 'Fixed brochure explicitly predicates four accelerated compute dies on each MI350P PCIe card.' 'The same paragraph says 32 CUs per XCD; that architecture/per-die detail is not copied or multiplied.' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'Four accelerated compute dies (XCDs)' '4' 'count' 'p. 2, Multi-Chip Architecture, first bullet' 'Each AMD Instinct MI350P PCIe card includes: Four accelerated compute dies (XCDs)'
Add-DirectFact 'IOD-COUNT' '' '' '' 'FIELD-PHY-DIE-COUNT' '' '1' 'count' 'COND-M2W3-AMD-MI350P-IOD-COUNT' 'single_source' '' 'high' 'Fixed brochure specification table directly gives one I/O die.' '' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'I/O DIES (IODS): 1' '1' 'count' 'p. 1, Specifications, I/O Dies (IODs)' 'I/O DIES (IODS): 1'
Add-DirectFact 'CLOCK' '' '' '' 'FIELD-PHY-CLOCK' '' '2200000000' 'Hz' 'COND-NONE' 'corroborated' '' 'high' 'Exact page and fixed brochure publish the same peak engine clock.' 'Peak engine clock; not a guaranteed sustained clock.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' '2200 MHz' '2200' 'MHz' 'HTML lines 7186-7197, GPU Specifications' 'Peak Engine Clock: 2200 MHz'
Add-SecondAssertion 'CLOCK' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' '2.2 GHz' '2.2' 'GHz' 'p. 1, Specifications, Peak Engine Clock' 'PEAK ENGINE CLOCK: 2.2 GHz'
Add-DirectFact 'POWER-MAX' '' '' '' 'FIELD-PHY-POWER' '' '600' 'W' 'COND-M2W3-AMD-MI350P-POWER-MAX' 'corroborated' '' 'high' 'Exact page and fixed brochure match the maximum TBP.' 'Maximum TBP is separated from the configurable 450 W point.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' '600W TBP (Max)' '600' 'W' 'HTML lines 7584-7595, Requirements' '600W TBP (Max); 450W TBP configurable'
Add-SecondAssertion 'POWER-MAX' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' '600W' '600' 'W' 'p. 1, Specifications, Maximum TBP' 'MAXIMUM TBP: 600W (configurable to 450W)'
Add-DirectFact 'POWER-CONFIG' '' '' '' 'FIELD-PHY-POWER' '' '450' 'W' 'COND-M2W3-AMD-MI350P-POWER-CONFIG' 'corroborated' '' 'high' 'Exact page and fixed brochure match the configurable TBP point.' 'No mode name, software version or workload condition is published.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' '450W TBP configurable' '450' 'W' 'HTML lines 7584-7595, Requirements' '600W TBP (Max); 450W TBP configurable'
Add-SecondAssertion 'POWER-CONFIG' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'configurable to 450W' '450' 'W' 'p. 1, Specifications, Maximum TBP' 'MAXIMUM TBP: 600W (configurable to 450W)'
Add-DirectFact 'COOLING' '' '' '' 'FIELD-PHY-COOLING' 'passive' '' '' 'COND-NONE' 'single_source' '' 'high' 'Exact product page Board Specifications states Passive.' 'The blog and brochure discuss air-cooled servers, which is a system deployment condition and not substituted for card cooling.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Passive' '' '' 'HTML lines 7808-7819, Board Specifications' 'Cooling: Passive'
Add-DirectFact 'FORM-FACTOR' '' '' '' 'FIELD-PHY-FORM-FACTOR' 'Full-height, full-length, dual-slot PCIe CEM add-in card' '' '' 'COND-NONE' 'corroborated' '' 'high' 'Fixed brochure gives the full card form and the exact page independently confirms PCIe add-in, full-height, 267 mm and double-slot dimensions.' 'CEM means Card Electromechanical. Air-cooled server compatibility is not encoded as the card cooling method.' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'FHFL 2-slot PCIe CEM Card' '' '' 'p. 1, Specifications, Form Factor' 'FORM FACTOR: FHFL 2-slot PCIe CEM Card'
Add-SecondAssertion 'FORM-FACTOR' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'PCIe® Add-in Card; Full Height; 10.5 in (267 mm); Double Slot' '' '' 'HTML lines 7769-7892, Board Specifications and Dimensions' 'PCIe® Add-in Card; Full Height; 10.5 in (267 mm); Double Slot' 'supports' 'Product page supplies compatible dimensions; brochure supplies the full-length/CEM wording.'
Add-DirectFact 'HBM-INTERFACE' '' '' '' 'FIELD-PHY-HBM-INTERFACE' '' '4096' 'bit' 'COND-NONE' 'single_source' '' 'high' 'Exact product page directly publishes the total memory interface width.' 'No width is derived from capacity or an assumed HBM stack count.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' '4096-bit' '4096' 'bit' 'HTML lines 7696-7707, GPU Memory' 'Memory Interface: 4096-bit'
Add-DirectFact 'TRANSISTORS' '' '' '' 'FIELD-PHY-TRANSISTORS' '' '73000000000' 'count' 'COND-NONE' 'single_source' '' 'high' 'Exact product page directly publishes the transistor count for the MI350P PCIe card.' 'The source value 73 Billion is normalized to the exact decimal count; no die-level split is inferred.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' '73 Billion' '' '' 'HTML lines 7509-7520, GPU Specifications' 'Transistor Count: 73 Billion'
Add-DirectFact 'CU-COUNT' 'COMP-M2W3-AMD-MI350P-CU' '' '' 'FIELD-COMP-UNIT-COUNT' '' '128' 'count' 'COND-NONE' 'single_source' '' 'high' 'Exact product page publishes the enabled product-level count.' 'No per-CU throughput or per-XCD multiplication is used.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Compute Units: 128' '128' 'count' 'HTML lines 7167-7178, GPU Specifications' 'Compute Units: 128'
Add-DirectFact 'MATRIX-CORE-COUNT' 'COMP-M2W3-AMD-MI350P-MATRIX' '' '' 'FIELD-COMP-UNIT-COUNT' '' '512' 'count' 'COND-NONE' 'single_source' '' 'high' 'Exact product page publishes the product-level Matrix Cores count.' 'No internal width or operation count is inferred.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Matrix Cores: 512' '512' 'count' 'HTML lines 7148-7159, GPU Specifications' 'Matrix Cores: 512'
Add-DirectFact 'STREAM-PROCESSOR-COUNT' 'COMP-M2W3-AMD-MI350P-VECTOR' '' '' 'FIELD-COMP-UNIT-COUNT' '' '8192' 'count' 'COND-NONE' 'single_source' '' 'high' 'Exact product page publishes the product-level Stream Processors count.' 'The count is not converted to lanes or vector width.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Stream Processors: 8,192' '8192' 'count' 'HTML lines 7129-7140, GPU Specifications' 'Stream Processors: 8,192'
Add-DirectFact 'HBM3E-CAPACITY' 'COMP-M2W3-AMD-MI350P-HBM3E' '' '' 'FIELD-MEM-CAPACITY' '' '144000000000' 'byte' 'COND-NONE' 'corroborated' '' 'high' 'Exact page and fixed brochure publish 144 GB HBM3E for one card.' 'GB is treated as the source decimal unit; it is not reinterpreted as GiB.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' '144 GB HBM3E' '144' 'GB' 'HTML lines 7638-7667, GPU Memory' 'Dedicated Memory Size: 144 GB; Dedicated Memory Type: HBM3E'
Add-SecondAssertion 'HBM3E-CAPACITY' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' '144GB HBM3e' '144' 'GB' 'p. 1, Specifications, Memory Capacity' 'MEMORY CAPACITY: 144GB HBM3e'
Add-DirectFact 'LLC-CAPACITY' 'COMP-M2W3-AMD-MI350P-LLC' '' '' 'FIELD-MEM-CAPACITY' '' '128000000' 'byte' 'COND-NONE' 'single_source' '' 'high' 'Exact product page labels 128 MB as the last-level cache.' 'MB remains decimal and is not reinterpreted as MiB.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Last Level Cache (LLC): 128 MB' '128' 'MB' 'HTML lines 7619-7630, GPU Memory' 'Last Level Cache (LLC): 128 MB'
Add-DirectFact 'HBM3E-BW' 'COMP-M2W3-AMD-MI350P-HBM3E' '' '' 'FIELD-MEM-BIDIR-BW' '' '4000000000000' 'byte/s' 'COND-M2W3-AMD-MI350P-HBM3E-PEAK-BW' 'corroborated' '' 'high' 'Exact page and fixed brochure publish the same per-card peak memory bandwidth.' 'The field name does not override the source: read/write direction is not specified.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak Memory Bandwidth: 4 TB/s' '4' 'TB/s' 'HTML lines 7715-7726, GPU Memory' 'Peak Memory Bandwidth: 4 TB/s'
Add-SecondAssertion 'HBM3E-BW' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' '4 TB/s' '4' 'TB/s' 'p. 1, Specifications, Memory Bandwidth' 'MEMORY BANDWIDTH: 4 TB/s'
Add-DirectFact 'PCIE-PROTOCOL' '' 'LINK-M2W3-AMD-MI350P-PCIE' '' 'FIELD-INT-PROTOCOL' 'PCIe 5.0 x16' '' '' 'COND-NONE' 'corroborated' '' 'high' 'Exact page and fixed brochure agree on PCIe Gen 5 x16.' 'Protocol and bandwidth remain separate facts.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'PCIe® 5.0 x16' '' '' 'HTML lines 7788-7798, Board Specifications' 'Bus Type: PCIe® 5.0 x16'
Add-SecondAssertion 'PCIE-PROTOCOL' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' '1 PCIe® Gen 5 x16' '' '' 'p. 1, Specifications, I/O Interconnect' 'I/O INTERCONNECT: 1 PCIe® Gen 5 x16 (128 GB/s)'
Add-DirectFact 'PCIE-BW' '' 'LINK-M2W3-AMD-MI350P-PCIE' '' 'FIELD-INT-AGGREGATE-BW' '' '128000000000' 'byte/s' 'COND-M2W3-AMD-MI350P-PCIE-BW' 'single_source' '' 'high' 'Fixed brochure directly prints 128 GB/s for the one PCIe Gen 5 x16 endpoint.' 'Direction, payload basis and sustained-versus-nameplate basis are not stated; no halving or doubling is applied.' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' '1 PCIe® Gen 5 x16 (128 GB/s)' '128' 'GB/s' 'p. 1, Specifications, I/O Interconnect' 'I/O INTERCONNECT: 1 PCIe® Gen 5 x16 (128 GB/s)'
Add-DirectFact 'MXFP4-MATRIX-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-MXFP4-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '4600000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-UNSPEC' 'single_source' '' 'high' 'Exact product page publishes a single-card peak for this named path.' 'MXFP4 is a vendor performance-format label here; no A/B, product, accumulation, output or FMA-count rule is inferred.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak MXFP4 Matrix Performance: 4.6 PFLOPs' '4.6' 'PFLOPs' 'HTML lines 7205-7216, GPU Specifications' 'Peak Microscaling Four-bit Precision Matrix (MXFP4) Performance: 4.6 PFLOPs'
Add-DirectFact 'MXFP6-MATRIX-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-MXFP6-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '4600000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-UNSPEC' 'single_source' '' 'high' 'Exact product page publishes a single-card peak for this named path.' 'MXFP6 is a vendor performance-format label here; no A/B, product, accumulation, output or FMA-count rule is inferred.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak MXFP6 Matrix Performance: 4.6 PFLOPs' '4.6' 'PFLOPs' 'HTML lines 7224-7235, GPU Specifications' 'Peak Microscaling Six-bit Precision Matrix (MXFP6) Performance: 4.6 PFLOPs'
Add-DirectFact 'MXFP8-MATRIX-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-MXFP8-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '2300000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-UNSPEC' 'single_source' '' 'high' 'Exact product page publishes a single-card peak for this named path.' 'MXFP8 is a vendor performance-format label here; no A/B, product, accumulation, output or FMA-count rule is inferred.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak MXFP8 Matrix Performance: 2.3 PFLOPs' '2.3' 'PFLOPs' 'HTML lines 7243-7254, GPU Specifications' 'Peak Microscaling Eight-bit Precision Matrix (MXFP8) Performance: 2.3 PFLOPs'
Add-DirectFact 'OCP-FP8-MATRIX-BASE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-OCP-FP8-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '2300000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-BASE' 'single_source' '' 'high' 'Exact product page publishes the base OCP-FP8 peak and separately publishes a structured-sparsity peak.' 'E5M2/E4M3 are printed labels; exact A/B pairing, product, accumulation, output and FMA count are not stated.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak OCP-FP8 Matrix Performance (E5M2, E4M3): 2.3 PFLOPs' '2.3' 'PFLOPs' 'HTML lines 7262-7273, GPU Specifications' 'Peak Open Compute Project Eight-bit Precision Matrix (OCP-FP8) Performance (E5M2, E4M3): 2.3 PFLOPs'
Add-DirectFact 'OCP-FP8-MATRIX-SPARSE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-OCP-FP8-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '4600000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-STRUCTURED' 'single_source' '' 'high' 'Exact product page explicitly labels this separate peak with structured sparsity.' 'The sparse pattern is not stated; no 2:4 assumption or physical-unit inference is made.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak OCP-FP8 Matrix Performance with Structured Sparsity: 4.6 PFLOPs' '4.6' 'PFLOPs' 'HTML lines 7281-7292, GPU Specifications' 'Peak OCP-FP8 Performance with Structured Sparsity (E5M2, E4M3): 4.6 PFLOPs'
Add-DirectFact 'FP16-MATRIX-BASE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-FP16-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '1150000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-BASE' 'single_source' '' 'high' 'Exact product page publishes the base FP16 matrix peak and a separate structured-sparsity peak.' 'The base row is not relabeled dense; product and accumulation formats are not inferred.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak FP16 Matrix Performance: 1.15 PFLOPs' '1.15' 'PFLOPs' 'HTML lines 7300-7311, GPU Specifications' 'Peak Half Precision Matrix (FP16) Performance: 1.15 PFLOPs'
Add-DirectFact 'FP16-MATRIX-SPARSE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-FP16-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '2300000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-STRUCTURED' 'single_source' '' 'high' 'Exact product page explicitly labels this separate FP16 peak with structured sparsity.' 'The sparse pattern is not stated; no 2:4 assumption is made.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak FP16 Matrix Performance with Structured Sparsity: 2.3 PFLOPs' '2.3' 'PFLOPs' 'HTML lines 7319-7330, GPU Specifications' 'Peak Half Precision Matrix (FP16) Performance with Structured Sparsity: 2.3 PFLOPs'
Add-DirectFact 'BF16-MATRIX-BASE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-BF16-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '1150000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-BASE' 'single_source' '' 'high' 'Exact product page publishes the base BF16 matrix peak and a separate structured-sparsity peak.' 'The base row is not relabeled dense; product and accumulation formats are not inferred.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak BF16 Matrix Performance: 1.15 PFLOPs' '1.15' 'PFLOPs' 'HTML lines 7471-7482, GPU Specifications' 'Peak bfloat16 (BF16) Matrix Performance: 1.15 PFLOPs'
Add-DirectFact 'BF16-MATRIX-SPARSE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-BF16-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '2300000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-STRUCTURED' 'single_source' '' 'high' 'Exact product page explicitly labels this separate BF16 peak with structured sparsity.' 'The sparse pattern is not stated; no 2:4 assumption is made.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak BF16 Matrix Performance with Structured Sparsity: 2.3 PFLOPs' '2.3' 'PFLOPs' 'HTML lines 7490-7501, GPU Specifications' 'Peak bfloat16 (BF16) Matrix Performance with Structured Sparsity: 2.3 PFLOPs'
Add-DirectFact 'INT8-MATRIX-BASE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-INT8-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '2300000000000000' 'OP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-BASE' 'single_source' '' 'high' 'Exact product page publishes the base INT8 matrix peak and a separate structured-sparsity peak.' 'Integer throughput remains OP/s, not FLOP/s; the base row is not relabeled dense.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak INT8 Matrix Performance: 2.3 POPs' '2.3' 'POPs' 'HTML lines 7433-7444, GPU Specifications' 'Peak INT8 Matrix Performance: 2.3 POPs'
Add-DirectFact 'INT8-MATRIX-SPARSE-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-INT8-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '4600000000000000' 'OP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-STRUCTURED' 'single_source' '' 'high' 'Exact product page explicitly labels this separate INT8 peak with structured sparsity.' 'Integer throughput remains OP/s; the sparse pattern is not stated.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak INT8 Matrix Performance with Structured Sparsity: 4.6 POPs' '4.6' 'POPs' 'HTML lines 7452-7463, GPU Specifications' 'Peak INT8 Matrix Performance with Structured Sparsity: 4.6 POPs'
Add-DirectFact 'FP32-MATRIX-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-FP32-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '72000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-UNSPEC' 'single_source' '' 'high' 'Exact product page publishes a single-card FP32 matrix peak.' 'Sparsity, operation-count rule and product-specific accumulation are not stated.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak FP32 Matrix Performance: 72 TFLOPs' '72' 'TFLOPs' 'HTML lines 7357-7368, GPU Specifications' 'Peak Single Precision Matrix (FP32) Performance: 72 TFLOPs'
Add-DirectFact 'FP64-MATRIX-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-FP64-MATRIX' 'FIELD-COMP-THROUGHPUT' '' '36000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-MATRIX-UNSPEC' 'single_source' '' 'high' 'Exact product page publishes a single-card FP64 matrix peak.' 'Sparsity, operation-count rule and product-specific accumulation are not stated.' 'SRC-M2W3-AMD-MI350P-PRODUCT-20260813' 'PRODUCT' 'core_spec' 'Peak FP64 Matrix Performance: 36 TFLOPs' '36' 'TFLOPs' 'HTML lines 7395-7406, GPU Specifications' 'Peak Double Precision Matrix (FP64) Performance: 36 TFLOPs'
Add-DirectFact 'FP16-VECTOR-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-FP16-VECTOR' 'FIELD-COMP-THROUGHPUT' '' '72000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-VECTOR' 'single_source' '' 'high' 'Fixed brochure directly labels the estimated single-card FP16 peak as vector performance.' 'The later product page corroborates the 72 TFLOPs value without labeling it vector; no lane count is inferred.' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'FP16 VECTOR (TFLOPS): 72' '72' 'TFLOPs' 'p. 1, HPC Peak Performance (Estimated)' 'FP16 VECTOR (TFLOPS): 72'
Add-DirectFact 'FP32-VECTOR-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-FP32-VECTOR' 'FIELD-COMP-THROUGHPUT' '' '72000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-VECTOR' 'single_source' '' 'high' 'Fixed brochure directly labels the estimated single-card FP32 peak as vector performance.' 'The later product page corroborates the 72 TFLOPs value without labeling it vector; no lane count is inferred.' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'FP32 VECTOR (TFLOPS): 72' '72' 'TFLOPs' 'p. 1, HPC Peak Performance (Estimated)' 'FP32 VECTOR (TFLOPS): 72'
Add-DirectFact 'FP64-VECTOR-PEAK' '' '' 'PPATH-M2W3-AMD-MI350P-FP64-VECTOR' 'FIELD-COMP-THROUGHPUT' '' '36000000000000' 'FLOP/s' 'COND-M2W3-AMD-MI350P-PEAK-VECTOR' 'single_source' '' 'high' 'Fixed brochure directly labels the estimated single-card FP64 peak as vector performance.' 'The later product page corroborates the 36 TFLOPs value without labeling it vector; no lane count is inferred.' 'SRC-M2W3-AMD-MI350P-BROCHURE-202605' 'BROCHURE' 'core_spec' 'FP64 VECTOR (TFLOPS): 36' '36' 'TFLOPs' 'p. 1, HPC Peak Performance (Estimated)' 'FP64 VECTOR (TFLOPS): 36'
$requirements = @()
function Add-Requirement {
    param([string]$Suffix,[string]$TargetKind,[string]$TargetId,[string]$Field,[string]$Status,[string]$Reason,[string]$SearchStatus,[string]$Notes)
    $slots = @{ object=''; component=''; link=''; relation=''; precision_path=''; capability=''; topology='' }
    if (-not $slots.ContainsKey($TargetKind)) { throw "Unknown requirement target kind $TargetKind" }
    $slots[$TargetKind] = $TargetId
    $fpKind = if ($TargetKind -eq 'relation') { 'object_relation_id' } else { "${TargetKind}_id" }
    $fingerprint = "M2W3|MI350P|$fpKind|$TargetId|$Field"
    if ($Status -ne 'value_available') { $fingerprint += "|$($Status -replace '_','-')-2026-08-13" }
    $script:requirements += New-DataRow $H['field-requirements.csv'] @("REQ-M2W3-AMD-MI350P-$Suffix",$slots.object,$slots.component,$slots.link,$slots.relation,$slots.precision_path,$slots.capability,$slots.topology,$Field,$Status,$Reason,$SearchStatus,'2026-08-13',$fingerprint,'draft',$Notes)
}
function Add-ValueRequirement {
    param([string]$Suffix,[string]$TargetKind,[string]$TargetId,[string]$Field,[string]$FactIds)
    Add-Requirement $Suffix $TargetKind $TargetId $Field 'value_available' "Selected object-matched first-party evidence supports this $Field value for $TargetId." 'completed' "Canonical fact(s): $FactIds."
}
Add-ValueRequirement 'VENDOR' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-VENDOR' 'FACT-M2W3-AMD-MI350P-VENDOR'
Add-ValueRequirement 'FAMILY' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-FAMILY' 'FACT-M2W3-AMD-MI350P-FAMILY'
Add-ValueRequirement 'NAME' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-NAME' 'FACT-M2W3-AMD-MI350P-NAME'
Add-ValueRequirement 'SKU' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-SKU' 'FACT-M2W3-AMD-MI350P-SKU'
Add-ValueRequirement 'OBJECT-TYPE' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-OBJECT-TYPE' 'FACT-M2W3-AMD-MI350P-OBJECT-TYPE'
Add-ValueRequirement 'STATUS' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-STATUS' 'FACT-M2W3-AMD-MI350P-STATUS'
Add-ValueRequirement 'PROCESS' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-PROCESS' 'FACT-M2W3-AMD-MI350P-PROCESS'
Add-ValueRequirement 'DIE-COUNT' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-DIE-COUNT' 'FACT-M2W3-AMD-MI350P-XCD-COUNT; FACT-M2W3-AMD-MI350P-IOD-COUNT'
Add-ValueRequirement 'CLOCK' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-CLOCK' 'FACT-M2W3-AMD-MI350P-CLOCK'
Add-ValueRequirement 'POWER' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-POWER' 'FACT-M2W3-AMD-MI350P-POWER-MAX; FACT-M2W3-AMD-MI350P-POWER-CONFIG'
Add-ValueRequirement 'COOLING' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-COOLING' 'FACT-M2W3-AMD-MI350P-COOLING'
Add-ValueRequirement 'FORM-FACTOR' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-FORM-FACTOR' 'FACT-M2W3-AMD-MI350P-FORM-FACTOR'
Add-ValueRequirement 'HBM-INTERFACE' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-HBM-INTERFACE' 'FACT-M2W3-AMD-MI350P-HBM-INTERFACE'
Add-ValueRequirement 'TRANSISTORS' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-TRANSISTORS' 'FACT-M2W3-AMD-MI350P-TRANSISTORS'
Add-ValueRequirement 'CU-COUNT' 'component' 'COMP-M2W3-AMD-MI350P-CU' 'FIELD-COMP-UNIT-COUNT' 'FACT-M2W3-AMD-MI350P-CU-COUNT'
Add-ValueRequirement 'MATRIX-CORE-COUNT' 'component' 'COMP-M2W3-AMD-MI350P-MATRIX' 'FIELD-COMP-UNIT-COUNT' 'FACT-M2W3-AMD-MI350P-MATRIX-CORE-COUNT'
Add-ValueRequirement 'STREAM-PROCESSOR-COUNT' 'component' 'COMP-M2W3-AMD-MI350P-VECTOR' 'FIELD-COMP-UNIT-COUNT' 'FACT-M2W3-AMD-MI350P-STREAM-PROCESSOR-COUNT'
Add-ValueRequirement 'HBM3E-CAPACITY' 'component' 'COMP-M2W3-AMD-MI350P-HBM3E' 'FIELD-MEM-CAPACITY' 'FACT-M2W3-AMD-MI350P-HBM3E-CAPACITY'
Add-ValueRequirement 'LLC-CAPACITY' 'component' 'COMP-M2W3-AMD-MI350P-LLC' 'FIELD-MEM-CAPACITY' 'FACT-M2W3-AMD-MI350P-LLC-CAPACITY'
Add-ValueRequirement 'HBM3E-BW' 'component' 'COMP-M2W3-AMD-MI350P-HBM3E' 'FIELD-MEM-BIDIR-BW' 'FACT-M2W3-AMD-MI350P-HBM3E-BW'
Add-ValueRequirement 'PCIE-PROTOCOL' 'link' 'LINK-M2W3-AMD-MI350P-PCIE' 'FIELD-INT-PROTOCOL' 'FACT-M2W3-AMD-MI350P-PCIE-PROTOCOL'
Add-ValueRequirement 'PCIE-BW' 'link' 'LINK-M2W3-AMD-MI350P-PCIE' 'FIELD-INT-AGGREGATE-BW' 'FACT-M2W3-AMD-MI350P-PCIE-BW'
Add-ValueRequirement 'MXFP4-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-MXFP4-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-MXFP4-MATRIX-PEAK'
Add-ValueRequirement 'MXFP6-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-MXFP6-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-MXFP6-MATRIX-PEAK'
Add-ValueRequirement 'MXFP8-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-MXFP8-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-MXFP8-MATRIX-PEAK'
Add-ValueRequirement 'OCP-FP8-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-OCP-FP8-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-OCP-FP8-MATRIX-BASE-PEAK; FACT-M2W3-AMD-MI350P-OCP-FP8-MATRIX-SPARSE-PEAK'
Add-ValueRequirement 'FP16-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-FP16-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-FP16-MATRIX-BASE-PEAK; FACT-M2W3-AMD-MI350P-FP16-MATRIX-SPARSE-PEAK'
Add-ValueRequirement 'BF16-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-BF16-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-BF16-MATRIX-BASE-PEAK; FACT-M2W3-AMD-MI350P-BF16-MATRIX-SPARSE-PEAK'
Add-ValueRequirement 'INT8-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-INT8-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-INT8-MATRIX-BASE-PEAK; FACT-M2W3-AMD-MI350P-INT8-MATRIX-SPARSE-PEAK'
Add-ValueRequirement 'FP32-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-FP32-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-FP32-MATRIX-PEAK'
Add-ValueRequirement 'FP64-MATRIX-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-FP64-MATRIX' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-FP64-MATRIX-PEAK'
Add-ValueRequirement 'FP16-VECTOR-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-FP16-VECTOR' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-FP16-VECTOR-PEAK'
Add-ValueRequirement 'FP32-VECTOR-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-FP32-VECTOR' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-FP32-VECTOR-PEAK'
Add-ValueRequirement 'FP64-VECTOR-PEAK' 'precision_path' 'PPATH-M2W3-AMD-MI350P-FP64-VECTOR' 'FIELD-COMP-THROUGHPUT' 'FACT-M2W3-AMD-MI350P-FP64-VECTOR-PEAK'

Add-Requirement 'RELEASE-DATE' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-RELEASE-DATE' 'not_found' 'A product release or launch date is relevant, but D-1 has no launchDate and the dated article is not identified as the product release event.' 'completed' 'Do not substitute the article publication date for a release date.'
Add-Requirement 'AVAILABILITY-DATE' 'object' 'OBJ-AMD-MI350P' 'FIELD-ID-AVAILABILITY-DATE' 'not_found' 'The exact article establishes available status by 2026-05-07 but does not state the first availability date.' 'completed' 'The status valid_from is an earliest evidenced date, not a first-supply date.'
Add-Requirement 'HBM-STACKS' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-HBM-STACKS' 'not_found' 'HBM stack count is relevant, but capacity and interface width do not establish a public physical stack count.' 'completed' 'Do not infer stacks from 144 GB or 4096-bit interface width.'
Add-Requirement 'DIE-AREA' 'object' 'OBJ-AMD-MI350P' 'FIELD-PHY-DIE-AREA' 'not_found' 'XCD or IOD area is relevant, but no selected first-party source gives an area value.' 'completed' 'Do not estimate from package images or neighboring MI350 OAM products.'
Add-Requirement 'OPERAND-A' 'component' 'COMP-M2W3-AMD-MI350P-MATRIX' 'FIELD-NUM-OPERAND-A' 'not_found' 'The product peak labels name formats, but they do not define a common MI350P A-operand encoding contract for the published matrix paths.' 'completed' 'CDNA 4 instruction formats remain architecture-scoped and are not copied to product peaks.'
Add-Requirement 'OPERAND-B' 'precision_path' 'PPATH-M2W3-AMD-MI350P-OCP-FP8-MATRIX' 'FIELD-NUM-OPERAND-B' 'not_found' 'The OCP-FP8 product peak row names E5M2/E4M3, but it does not define the exact B-operand encoding or A/B pairing for this path.' 'completed' 'Representative exact path gap; do not assume A and B have the same format from a row label.'
Add-Requirement 'PRODUCT-FORMAT' 'component' 'COMP-M2W3-AMD-MI350P-MATRIX' 'FIELD-NUM-PRODUCT' 'not_found' 'The selected product sources do not state a product/intermediate format for the published matrix peak rows.' 'completed' 'Input-format names do not determine product precision.'
Add-Requirement 'ACCUMULATION' 'component' 'COMP-M2W3-AMD-MI350P-MATRIX' 'FIELD-NUM-ACCUMULATION' 'not_found' 'The selected product sources do not state a product/path-specific programmer-visible accumulation format.' 'completed' 'Architecture-level C/D semantics are referenced through CDNA 4; they are not copied as MI350P product facts.'
Add-Requirement 'PHYSICAL-ACCUM' 'component' 'COMP-M2W3-AMD-MI350P-MATRIX' 'FIELD-NUM-PHYSICAL-ACCUM' 'not_found' 'The selected sources do not predicate physical internal accumulator width or semantics on the MI350P product.' 'completed' 'Do not infer physical width from input, output or advertised throughput.'
Add-Requirement 'OUTPUT-FORMAT' 'precision_path' 'PPATH-M2W3-AMD-MI350P-OCP-FP8-MATRIX' 'FIELD-NUM-OUTPUT' 'not_found' 'The OCP-FP8 product peak rows name E5M2/E4M3 but do not state the output encoding or conversion conditions.' 'completed' 'Representative exact path gap; no output format is generalized from the performance label.'
Add-Requirement 'SPECIAL-IMPLEMENTATION' 'object' 'OBJ-AMD-MI350P' 'FIELD-CAP-IMPLEMENTATION-DETAIL' 'not_found' 'Dedicated MoE routing, Top-K or related product-level hardware would be relevant, but no selected source identifies one.' 'completed' 'No placeholder capability entity is created; general matrix or sparsity support is not treated as a dedicated routing engine.'
Add-Requirement 'RUNTIME-VERSION' 'object' 'OBJ-AMD-MI350P' 'FIELD-SW-RUNTIME' 'not_found' 'The sources name ROCm and software stacks but do not establish a minimum MI350P runtime, compiler or library version.' 'completed' 'No current version is inferred from the architecture documents or live ecosystem.'
$searchLogs = @()
$searchResults = @()
$ProductSources = @(
    'SRC-M2W3-AMD-MI350P-PRODUCT-20260813',
    'SRC-M2W3-AMD-MI350P-BROCHURE-202605',
    'SRC-M2W3-AMD-MI350P-BLOG-20260507'
)
$ProductAndArchitectureSources = @(
    'SRC-M2W3-AMD-MI350P-PRODUCT-20260813',
    'SRC-M2W3-AMD-MI350P-BROCHURE-202605',
    'SRC-M2W3-AMD-MI350P-BLOG-20260507',
    'SRC-M2NA-AMD-CDNA4-WP',
    'SRC-M2NA-AMD-CDNA4-ISA'
)
function Add-GapSearch {
    param([string]$Suffix,[string]$Types,[string]$Query,[string]$Conclusion,[string[]]$SourceIds,[string]$ResultNote)
    $searchId = "SEARCH-M2W3-AMD-MI350P-$Suffix"
    $requirementId = "REQ-M2W3-AMD-MI350P-$Suffix"
    $script:searchLogs += New-DataRow $H['search-log.csv'] @($searchId,$requirementId,'2026-08-13',$Query,$Types,'no_reliable_result','m2_w3_mi350p_source_prep','draft',$Conclusion)
    foreach ($sourceId in $SourceIds) {
        $tag = switch -Regex ($sourceId) {
            'PRODUCT' { 'PRODUCT'; break }
            'BROCHURE' { 'BROCHURE'; break }
            'BLOG' { 'BLOG'; break }
            'CDNA4-WP' { 'CDNA4-WP'; break }
            'CDNA4-ISA' { 'CDNA4-ISA'; break }
            default { throw "Unknown search source $sourceId" }
        }
        $note = if ($sourceId -match 'CDNA4') { "Architecture-scoped source checked: $ResultNote It does not establish the MI350P product/path field." } else { "$ResultNote Checked source does not establish the required MI350P value." }
        $script:searchResults += New-DataRow $H['search-results.csv'] @("SRESULT-M2W3-AMD-MI350P-$Suffix-$tag",$searchId,$sourceId,'checked_no_support','draft',$note)
    }
}
$identityQuery = 'Exact review of fixed MI350P product page, LE-93401-00 05/26 brochure and 2026-05-07 official article; D-1 and D-7 fixed identity snapshots were also checked in the source-gate audit.'
$fullQuery = 'Exact review of fixed MI350P product page, fixed brochure, dated official article, existing CDNA 4 whitepaper record and existing CDNA 4 ISA record; D-1 and D-7 fixed identity snapshots were checked outside structured source registration.'
Add-GapSearch 'RELEASE-DATE' 'product_page;product_brief;other' $identityQuery 'No source states a MI350P product release or launch date; an article publication date is not substituted.' $ProductSources 'Publication or snapshot timing is not an exact product release date.'
Add-GapSearch 'AVAILABILITY-DATE' 'product_page;product_brief;other' $identityQuery 'Available status is evidenced by 2026-05-07, but no source states the first availability date.' $ProductSources 'The article supports status by its date, not a first-supply date.'
Add-GapSearch 'HBM-STACKS' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'No reliable first-party value states the MI350P physical HBM stack count.' $ProductAndArchitectureSources 'Capacity and interface width do not determine a published stack count.'
Add-GapSearch 'DIE-AREA' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'No selected first-party source gives MI350P XCD, IOD or total die area.' $ProductAndArchitectureSources 'No object-matched area value is present.'
Add-GapSearch 'OPERAND-A' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'Product peak row names do not establish a common MI350P A-operand contract.' $ProductAndArchitectureSources 'A performance-format label is not a product/path operand contract.'
Add-GapSearch 'OPERAND-B' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'Product peak row names do not establish a common MI350P B-operand contract.' $ProductAndArchitectureSources 'A performance-format label is not a product/path operand contract.'
Add-GapSearch 'PRODUCT-FORMAT' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'No selected source states a MI350P product/intermediate format for the published peak rows.' $ProductAndArchitectureSources 'Input naming does not define product precision.'
Add-GapSearch 'ACCUMULATION' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'No selected source binds a programmer-visible accumulation format to the published MI350P product peak paths.' $ProductAndArchitectureSources 'Architecture-level C/D semantics are not automatically product-peak semantics.'
Add-GapSearch 'PHYSICAL-ACCUM' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'No selected source predicates physical internal accumulator width or semantics on MI350P.' $ProductAndArchitectureSources 'No product-specific internal width or semantics are stated.'
Add-GapSearch 'OUTPUT-FORMAT' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'The OCP-FP8 peak labels do not state output encoding or conversion conditions.' $ProductAndArchitectureSources 'E5M2/E4M3 labels do not establish the product peak output format.'
Add-GapSearch 'SPECIAL-IMPLEMENTATION' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'No selected source identifies a MI350P-dedicated MoE routing, Top-K, sorting or sampling implementation.' $ProductAndArchitectureSources 'General matrix, sparsity or software support is not evidence of a dedicated product-level routing unit.'
Add-GapSearch 'RUNTIME-VERSION' 'product_page;product_brief;other;architecture_whitepaper;api_or_isa_documentation' $fullQuery 'No selected source establishes a minimum MI350P runtime, compiler or library version.' $ProductAndArchitectureSources 'Ecosystem naming does not establish a versioned minimum support floor.'
$completeness = @(
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-IDENTITY','OBJ-AMD-MI350P','identity','partial','2026-08-13','m2_w3_mi350p_source_prep','draft','Vendor, family, name, SKU, PCIe card type, available status and CDNA 4 relation are supported; exact release and first-availability dates remain not_found.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-PHYSICAL','OBJ-AMD-MI350P','physical','partial','2026-08-13','m2_w3_mi350p_source_prep','draft','Process, 73 billion transistors, four XCDs, one IOD, peak clock, maximum/configurable TBP, passive card cooling, FHFL dual-slot form and 4096-bit HBM interface are supported; HBM stack count and die area remain not_found.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-COMPUTE','OBJ-AMD-MI350P','compute','partial','2026-08-13','m2_w3_mi350p_source_prep','draft','The exact product page publishes CU, Matrix Core, Stream Processor and matrix-peak rows; the fixed brochure directly labels three estimated vector-peak rows. No additive total-compute fact, per-CU derivation or sustained workload result is created.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-NUMERICS','OBJ-AMD-MI350P','numerics','partial','2026-08-13','m2_w3_mi350p_source_prep','draft','Base and structured-sparsity rows are separated and INT8 remains OP/s. Performance labels do not establish A/B, product, accumulation, physical accumulation or output contracts, so no compute/bandwidth ratio is derived.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-MEMORY','OBJ-AMD-MI350P','memory','partial','2026-08-13','m2_w3_mi350p_source_prep','draft','HBM3E capacity, vendor peak bandwidth, total interface width and LLC capacity are supported. Memory-bandwidth direction, HBM stack count, latency and lower product-level cache bandwidths are absent.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-INTERCONNECT','OBJ-AMD-MI350P','interconnect','partial','2026-08-13','m2_w3_mi350p_source_prep','draft','PCIe Gen 5 x16 and a brochure-labeled 128 GB/s endpoint are supported. Direction, payload basis, sustained basis, additional device links and topology are not published for the card.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-SPECIAL_ENGINES','OBJ-AMD-MI350P','special_engines','missing_public_data','2026-08-13','m2_w3_mi350p_source_prep','draft','No selected source identifies a MI350P-dedicated MoE routing, Top-K, sorting or sampling unit. No placeholder capability entity is created.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-SOFTWARE','OBJ-AMD-MI350P','software','partial','2026-08-13','m2_w3_mi350p_source_prep','draft','AMD names ROCm and enterprise AI software, but the selected sources do not establish a versioned minimum runtime, compiler or library floor.')),
    (New-DataRow $H['card-completeness.csv'] @('COMPLETE-M2W3-AMD-MI350P-EVIDENCE','OBJ-AMD-MI350P','evidence','needs_review','2026-08-13','m2_w3_mi350p_source_prep','draft','Three-source reverse-removal set, 49 assertions and 12 completed no-result searches are staged. Final independent review and total-control acceptance have not occurred.'))
)
$screening = @(
    (New-DataRow $H['source-screening.csv'] @('SCREEN-M2W3-AMD-MI350P-PRODUCT','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','selected','Exact-object current page provides product identity, 73-billion transistor count, card cooling, product resource counts, memory/interface fields and matrix peak rows.','relevant_sections_read','m2_w3_mi350p_source_prep','2026-08-13','SRC-M2W3-AMD-MI350P-PRODUCT-20260813|selected|OBJ-AMD-MI350P|2026-08-13','draft','The fixed snapshot controls later page changes. Generic Product Basics formFactor=Servers is rejected in favor of Board Specifications; generic FP16/FP32/FP64 performance values do not carry the vector label.')),
    (New-DataRow $H['source-screening.csv'] @('SCREEN-M2W3-AMD-MI350P-BROCHURE','SRC-M2W3-AMD-MI350P-BROCHURE-202605','selected','Fixed revision uniquely supplies four-XCD/one-IOD composition, full CEM card wording, PCIe 128 GB/s and direct FP16/FP32/FP64 vector labels while corroborating static specs.','full_text_read','m2_w3_mi350p_source_prep','2026-08-13','SRC-M2W3-AMD-MI350P-BROCHURE-202605|selected|OBJ-AMD-MI350P|2026-08-13','draft','The three vector facts retain the brochure Estimated qualifier. Per-XCD CU/cache details, up-to-eight-card server claims and future SR-IOV are not migrated.')),
    (New-DataRow $H['source-screening.csv'] @('SCREEN-M2W3-AMD-MI350P-BLOG','SRC-M2W3-AMD-MI350P-BLOG-20260507','selected','Dated exact-product article uniquely establishes available status by 2026-05-07.','relevant_sections_read','m2_w3_mi350p_source_prep','2026-08-13','SRC-M2W3-AMD-MI350P-BLOG-20260507|selected|OBJ-AMD-MI350P|2026-08-13','draft','Air-cooled systems and up-to-eight cards remain system context; preliminary performance values are excluded.')),
    (New-DataRow $H['source-screening.csv'] @('SCREEN-M2W3-AMD-CDNA4-WP-FOR-MI350P','SRC-M2NA-AMD-CDNA4-WP','lead_only','Checked for architecture-versus-product scope; it directly supports no MI350P card fact and is removed from the object-level minimum set.','relevant_sections_read','m2_w3_mi350p_source_prep','2026-08-13','SRC-M2NA-AMD-CDNA4-WP|lead_only|OBJ-AMD-MI350P|2026-08-13','draft','It remains search evidence for product-level gaps and serves the separate architecture card. Pages 3, 15 and 18 describe MI350X/MI355X OAM or platform configurations; those values migrate zero facts.')),
    (New-DataRow $H['source-screening.csv'] @('SCREEN-M2W3-AMD-CDNA4-ISA-FOR-MI350P','SRC-M2NA-AMD-CDNA4-ISA','lead_only','Checked as an architecture-scoped numerical-semantics lead; it directly supports no MI350P card fact and is removed from the object-level minimum set.','inaccessible','m2_w3_mi350p_source_prep','2026-08-13','SRC-M2NA-AMD-CDNA4-ISA|lead_only|OBJ-AMD-MI350P|2026-08-13','draft','The current formal endpoint is restricted. It remains checked_no_support search evidence for product-level numerical gaps; no ISA fact is copied into the card.'))
)
$roles = @(
    (New-DataRow $H['source-selected-roles.csv'] @('SROLE-M2W3-AMD-MI350P-PRODUCT-IDENTITY','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','identity','Exact current object name, family, SKU and PCIe card identity.','draft','D-1/D-7 are retained as gate audit rather than duplicate structured sources.')),
    (New-DataRow $H['source-selected-roles.csv'] @('SROLE-M2W3-AMD-MI350P-PRODUCT-CORE','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','core_spec','Current card-level transistor count, resource, memory, cooling and matrix-peak fields from the dated snapshot.','draft','No server or OAM aggregation is selected; generic FP16/FP32/FP64 values only corroborate brochure-labeled vector peaks.')),
    (New-DataRow $H['source-selected-roles.csv'] @('SROLE-M2W3-AMD-MI350P-BROCHURE-CORE','SRC-M2W3-AMD-MI350P-BROCHURE-202605','core_spec','Fixed revision supplies die counts, full card form, direction-unspecified PCIe 128 GB/s and direct FP16/FP32/FP64 vector labels.','draft','The three vector rows retain the brochure Estimated qualifier; per-CU and server values are excluded.')),
    (New-DataRow $H['source-selected-roles.csv'] @('SROLE-M2W3-AMD-MI350P-BLOG-STATUS','SRC-M2W3-AMD-MI350P-BLOG-20260507','status_version_evidence','Dated first-party available-status evidence for the exact MI350P PCIe card.','draft','Publication date is not promoted to release or first-availability date.'))
)
$coverage = @(
    (New-DataRow $H['source-coverage.csv'] @('COV-M2W3-AMD-MI350P-PRODUCT-BY-BROCHURE','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','SRC-M2W3-AMD-MI350P-BROCHURE-202605','selected_fact_set','partially_covered','Brochure covers many static specifications and directly labels the three vector peaks, but it does not cover the 73-billion transistor count, passive card cooling, several current resource/matrix rows or the dated snapshot role.','m2_w3_mi350p_source_prep','2026-08-13','draft','Removing the product page loses the transistor fact and other current exact-object specification evidence.')),
    (New-DataRow $H['source-coverage.csv'] @('COV-M2W3-AMD-MI350P-BROCHURE-BY-PRODUCT','SRC-M2W3-AMD-MI350P-BROCHURE-202605','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','selected_fact_set','partially_covered','Product page overlaps most core specs and corroborates 72/72/36 TFLOPs, but it does not label those rows vector and does not state four XCDs, one IOD in the same stable version, full FHFL CEM wording or PCIe 128 GB/s.','m2_w3_mi350p_source_prep','2026-08-13','draft','Removing the brochure loses the direct vector classification plus fixed-version physical/interface evidence.')),
    (New-DataRow $H['source-coverage.csv'] @('COV-M2W3-AMD-MI350P-BLOG-NOT-EQUIV-PRODUCT','SRC-M2W3-AMD-MI350P-BLOG-20260507','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','selected_fact_set','not_equivalent','The product page does not replace the dated article statement that MI350P PCIe cards are available in systems.','m2_w3_mi350p_source_prep','2026-08-13','draft','Only available status is selected from the article.'))
)
$selectionRun = @(
    (New-DataRow $H['selection-runs.csv'] @('SELRUN-M2W3-AMD-MI350P-20260813','object','OBJ-AMD-MI350P','2026-08-13','reverse-removal-v1+scope-gate+adversarial-3pass-remediation1','2026-08-13','m2_w3_mi350p_remediation','draft','draft','Re-run against the remediated 40-direct-fact set. Product page, fixed brochure and dated article each lose unique object-level evidence under removal; CDNA4 architecture sources directly support no MI350P card fact and are excluded. Final independent review remains pending.'))
)
$selectionMembers = @(
    (New-DataRow $H['selection-members.csv'] @('SELMEM-M2W3-AMD-MI350P-PRODUCT','SELRUN-M2W3-AMD-MI350P-20260813','SRC-M2W3-AMD-MI350P-PRODUCT-20260813','core_spec','Removal loses current exact-object identity, the 73-billion transistor count, passive card cooling, LLC and several product-scoped resource, interface and matrix-peak facts.','draft','Dynamic page is cited through the fixed 2026-08-13 snapshot. Generic vector values are not counted as direct vector-classification evidence.')),
    (New-DataRow $H['selection-members.csv'] @('SELMEM-M2W3-AMD-MI350P-BROCHURE','SELRUN-M2W3-AMD-MI350P-20260813','SRC-M2W3-AMD-MI350P-BROCHURE-202605','core_spec','Removal loses four-XCD/one-IOD evidence, stable FHFL CEM form, direction-unspecified PCIe 128 GB/s and the direct FP16/FP32/FP64 vector labels.','draft','Estimated qualifier is retained for the vector rows; per-CU details, server aggregation and future SR-IOV are excluded.')),
    (New-DataRow $H['selection-members.csv'] @('SELMEM-M2W3-AMD-MI350P-BLOG','SELRUN-M2W3-AMD-MI350P-20260813','SRC-M2W3-AMD-MI350P-BLOG-20260507','status_version_evidence','Removal loses the dated exact-product statement supporting available status by 2026-05-07.','draft','Preliminary performance and up-to-eight-card system context are excluded.'))
)
if (@($facts).Count -ne 40) { throw "Expected 40 facts, found $(@($facts).Count)" }
if (@($assertions).Count -ne 49) { throw "Expected 49 assertions, found $(@($assertions).Count)" }
if (@($requirements).Count -ne 46) { throw "Expected 46 requirements, found $(@($requirements).Count)" }
if (@($selectionMembers).Count -ne 3) { throw "Expected 3 selection members, found $(@($selectionMembers).Count)" }
if (@($searchLogs).Count -ne 12) { throw "Expected 12 search logs, found $(@($searchLogs).Count)" }
if (@($searchResults).Count -ne 56) { throw "Expected 56 search results, found $(@($searchResults).Count)" }
if (@($completeness).Count -ne 9) { throw "Expected 9 completeness rows, found $(@($completeness).Count)" }
if (@($sources).Count -ne 3 -or @($endpoints).Count -ne 6) { throw 'Source/endpoint budget mismatch' }

Write-DataCsv 'card-completeness.csv' $H['card-completeness.csv'] @($completeness)
Write-DataCsv 'components.csv' $H['components.csv'] @($components)
Write-DataCsv 'condition-sets.csv' $H['condition-sets.csv'] @($conditions)
Write-DataCsv 'derived-inputs.csv' $H['derived-inputs.csv'] @()
Write-DataCsv 'derived-metrics.csv' $H['derived-metrics.csv'] @()
Write-DataCsv 'facts.csv' $H['facts.csv'] @($facts)
Write-DataCsv 'field-requirements.csv' $H['field-requirements.csv'] @($requirements)
Write-DataCsv 'links.csv' $H['links.csv'] @($links)
Write-DataCsv 'memory-levels.csv' $H['memory-levels.csv'] @($memory)
Write-DataCsv 'precision-paths.csv' $H['precision-paths.csv'] @($paths)
Write-DataCsv 'special-capabilities.csv' $H['special-capabilities.csv'] @()
Write-DataCsv 'topologies.csv' $H['topologies.csv'] @()
Write-DataCsv 'conflict-groups.csv' $H['conflict-groups.csv'] @()
Write-DataCsv 'conflict-members.csv' $H['conflict-members.csv'] @()
Write-DataCsv 'fact-assertions.csv' $H['fact-assertions.csv'] @($assertions)
Write-DataCsv 'requirement-evidence.csv' $H['requirement-evidence.csv'] @()
Write-DataCsv 'search-log.csv' $H['search-log.csv'] @($searchLogs)
Write-DataCsv 'search-results.csv' $H['search-results.csv'] @($searchResults)
Write-DataCsv 'selection-members.csv' $H['selection-members.csv'] @($selectionMembers)
Write-DataCsv 'selection-runs.csv' $H['selection-runs.csv'] @($selectionRun)
Write-DataCsv 'source-coverage.csv' $H['source-coverage.csv'] @($coverage)
Write-DataCsv 'source-endpoints.csv' $H['source-endpoints.csv'] @($endpoints)
Write-DataCsv 'source-families.csv' $H['source-families.csv'] @($families)
Write-DataCsv 'sources.csv' $H['sources.csv'] @($sources)
Write-DataCsv 'source-screening.csv' $H['source-screening.csv'] @($screening)
Write-DataCsv 'source-selected-roles.csv' $H['source-selected-roles.csv'] @($roles)

[pscustomobject]@{
    output_directory = $OutDir
    facts = @($facts).Count
    assertions = @($assertions).Count
    requirements = @($requirements).Count
    searches = @($searchLogs).Count
    search_results = @($searchResults).Count
    completeness = @($completeness).Count
    sources = @($sources).Count
    endpoints = @($endpoints).Count
    files = @(Get-ChildItem -LiteralPath $OutDir -File).Count
}
