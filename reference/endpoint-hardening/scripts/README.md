# CIS Benchmark Converter

Author: Nicole Kemp  
Documentation Created: 2026-03-11  
Last Updated: 2026-03-11  

---

# Overview

CIS Benchmark Converter is a Python utility designed to extract security recommendations from CIS Benchmark PDF documents and convert them into structured formats such as Excel, CSV, or JSON.

CIS Benchmarks are widely used security configuration standards published by the Center for Internet Security (CIS). However, these benchmarks are distributed primarily as large PDF documents, making them difficult to analyze programmatically or integrate into compliance workflows.

This tool automates the process of converting CIS benchmark guidance into structured datasets that can be used for:

• security hardening reviews  
• compliance audits  
• baseline configuration development  
• infrastructure security assessments  
• ISO 27001 evidence preparation  
• vulnerability remediation tracking  

---

# Features

### Automated CIS Control Extraction

The script scans benchmark PDFs and automatically detects individual security recommendations.

Each recommendation is parsed to extract key sections including:

- Profile Applicability
- Description
- Rationale
- Impact
- Audit
- Remediation
- Default Value
- References
- Additional Information

---

### Multiple Output Formats

The extracted benchmark data can be exported in multiple formats:

| Format | Description |
|------|------|
| CSV | Pipe-delimited dataset suitable for spreadsheets or data processing |
| Excel | Structured spreadsheet with formatting and compliance tracking |
| JSON | Machine-readable structured data for automation workflows |

---

### Excel Compliance Review Features

When exporting to Excel, the generated spreadsheet includes:

• Pre-populated **Compliance Status** column  
• Dropdown values for status tracking  
• Conditional formatting for quick visual identification  
• Structured table layout  

Compliance statuses include:

- Compliant
- Non-Compliant
- To Review

---

# Installation

Clone the repository and install dependencies.

```bash
pip install -r requirements.txt
```

Required packages:

```
pdfplumber
openpyxl
tqdm
```

---

# Usage

Run the script using the command line.

```bash
python cis_benchmark_converter.py \
-i path/to/benchmark.pdf \
-o output_file \
-f [csv|excel|json] \
--start_page 10 \
--log_level INFO
```

---

# Parameters

| Parameter | Description |
|--------|--------|
| `-i`, `--input` | Path to the CIS benchmark PDF |
| `-o`, `--output` | Output file path (optional) |
| `-f`, `--format` | Output format: csv, excel, or json |
| `--start_page` | Page number where benchmark controls begin |
| `--log_level` | Logging verbosity |

---

# Example

Convert an Azure CIS Benchmark to Excel:

```bash
python cis_benchmark_converter.py \
-i ./CIS_Azure_Benchmark_v5.pdf \
-f excel \
--start_page 22 \
--log_level INFO
```

Output file generated:

```
CIS_Azure_Benchmark_v5.xlsx
```

---

# Workflow Example

Typical usage workflow for security engineers:

1. Download CIS benchmark PDF
2. Run the converter script
3. Review generated Excel sheet
4. Mark compliance status
5. Track remediation activities

This workflow simplifies large benchmark reviews containing hundreds of configuration controls.

---

# Limitations

• Extraction accuracy depends on the formatting of the benchmark PDF.  
• Some benchmark titles span multiple lines and may require manual validation.  
• Tables embedded inside PDFs may not extract perfectly.  

---

# Licensing Notice

This tool processes CIS Benchmark documents but does not distribute the original benchmark content.

Users must ensure compliance with CIS licensing requirements when using benchmark materials.

---

# Future Improvements

Potential enhancements planned for future versions:

• Improved parsing for complex benchmark formatting  
• automatic control mapping to security frameworks  
• vulnerability scanner integration  
• automated baseline comparison reports  
• direct export to compliance management platforms  

---

# Maintainer

Nicole Kemp  
Security Engineering / Governance Documentation
