#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
File: cis_batch_runner.py
Author: Nicole Kemp
Created: 2026-03-25
Last Updated: 2026-03-25
Documentation Created: 2026-03-25

Description
-----------
Batch processing wrapper for cis_benchmark_converter.py.

Scans a directory (recursively by default) for CIS Benchmark PDF files,
runs cis_benchmark_converter.py against each one as a subprocess, collects
per-file results, and writes a Markdown run report summarising what succeeded,
what failed, and how many recommendations were extracted.

Intended to be invoked from a CI/CD pipeline (e.g. GitHub Actions) but can
also be run locally against any folder containing CIS PDFs.

Usage
-----
    python cis_batch_runner.py \\
        --input-dir ./CIS \\
        --output-dir ./CIS/outputs \\
        --format excel \\
        --start-page 10 \\
        --log-level INFO

Exit Codes
----------
0   All PDFs converted successfully, or no PDFs were found.
1   One or more conversions failed.
"""

import argparse
import logging
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import List, NamedTuple, Optional


# -----------------------------------------------------------------------------
# Data types
# -----------------------------------------------------------------------------

class ConversionResult(NamedTuple):
    """Captures the outcome of a single PDF conversion attempt."""
    pdf_path: Path
    output_path: Optional[Path]
    success: bool
    recommendation_count: int
    duration_seconds: float
    error_message: str
    stdout: str
    stderr: str


# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------

def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments for the batch runner."""
    parser = argparse.ArgumentParser(
        description="Batch-convert CIS Benchmark PDFs using cis_benchmark_converter.py.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument(
        "--input-dir",
        default=".",
        metavar="DIR",
        help="Directory to scan for CIS Benchmark PDF files.",
    )

    parser.add_argument(
        "--output-dir",
        default="outputs",
        metavar="DIR",
        help="Directory where converted files will be written.",
    )

    parser.add_argument(
        "--format",
        dest="output_format",
        choices=["csv", "excel", "json"],
        default="excel",
        help="Output format applied to all conversions.",
    )

    parser.add_argument(
        "--start-page",
        type=int,
        default=10,
        metavar="N",
        help="1-based page number where benchmark controls begin (passed to converter).",
    )

    parser.add_argument(
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Logging verbosity.",
    )

    parser.add_argument(
        "--no-recursive",
        action="store_true",
        help="Only scan the top level of --input-dir, not subdirectories.",
    )

    parser.add_argument(
        "--report",
        default=None,
        metavar="PATH",
        help="Path for the Markdown run report. Defaults to <output-dir>/run_report.md.",
    )

    return parser.parse_args()


# -----------------------------------------------------------------------------
# PDF discovery
# -----------------------------------------------------------------------------

def find_pdfs(input_dir: Path, recursive: bool) -> List[Path]:
    """
    Find PDF files in input_dir.

    Args:
        input_dir: Directory to scan.
        recursive: If True, scan all subdirectories recursively.

    Returns:
        Sorted list of PDF paths (by filename, case-insensitive).
    """
    pattern = "**/*.pdf" if recursive else "*.pdf"
    pdfs = sorted(input_dir.glob(pattern), key=lambda p: p.name.lower())

    logging.info(
        "Found %d PDF(s) in '%s' (%s).",
        len(pdfs),
        input_dir,
        "recursive" if recursive else "top-level only",
    )
    for pdf in pdfs:
        logging.debug("  PDF: %s", pdf)

    return pdfs


# -----------------------------------------------------------------------------
# Conversion
# -----------------------------------------------------------------------------

def _parse_recommendation_count(stdout: str) -> int:
    """
    Extract the recommendation count from converter stdout.

    Looks for the line printed by cis_benchmark_converter.py:
        "Extraction complete: N recommendations written to ..."

    Args:
        stdout: Full stdout string from the converter subprocess.

    Returns:
        Parsed count, or 0 if the line is not found.
    """
    match = re.search(r"Extraction complete:\s*(\d+)\s+recommendations", stdout)
    if match:
        return int(match.group(1))
    return 0


def convert_pdf(
    pdf_path: Path,
    output_dir: Path,
    output_format: str,
    start_page: int,
    log_level: str,
    converter_path: Path,
) -> ConversionResult:
    """
    Run cis_benchmark_converter.py against a single PDF via subprocess.

    Args:
        pdf_path: Path to the input PDF.
        output_dir: Directory to write the converted output file into.
        output_format: csv, excel, or json.
        start_page: 1-based start page passed to the converter.
        log_level: Logging verbosity passed to the converter.
        converter_path: Absolute path to cis_benchmark_converter.py.

    Returns:
        ConversionResult capturing success, output path, recommendation count,
        timing, and any error details.
    """
    ext_map = {"csv": "csv", "excel": "xlsx", "json": "json"}
    output_stem = str(output_dir / pdf_path.stem)
    expected_output = output_dir / f"{pdf_path.stem}.{ext_map[output_format]}"

    cmd = [
        sys.executable,
        str(converter_path),
        "-i", str(pdf_path),
        "-o", output_stem,
        "-f", output_format,
        "--start_page", str(start_page),
        "--log_level", log_level,
    ]

    logging.info("Converting: %s", pdf_path.name)
    logging.debug("Command: %s", " ".join(cmd))

    start = time.monotonic()

    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300,
        )
    except subprocess.TimeoutExpired:
        duration = time.monotonic() - start
        logging.error("Timed out after 300s: %s", pdf_path.name)
        return ConversionResult(
            pdf_path=pdf_path,
            output_path=None,
            success=False,
            recommendation_count=0,
            duration_seconds=round(duration, 1),
            error_message="Conversion timed out after 300 seconds.",
            stdout="",
            stderr="",
        )
    except Exception as exc:
        duration = time.monotonic() - start
        logging.error("Unexpected error for '%s': %s", pdf_path.name, exc)
        return ConversionResult(
            pdf_path=pdf_path,
            output_path=None,
            success=False,
            recommendation_count=0,
            duration_seconds=round(duration, 1),
            error_message=str(exc),
            stdout="",
            stderr="",
        )

    duration = time.monotonic() - start
    success = proc.returncode == 0
    count = _parse_recommendation_count(proc.stdout)

    if success:
        logging.info(
            "  OK    %s  →  %s  (%d recommendations, %.1fs)",
            pdf_path.name,
            expected_output.name,
            count,
            duration,
        )
    else:
        logging.error(
            "  FAIL  %s  (exit code %d, %.1fs)",
            pdf_path.name,
            proc.returncode,
            duration,
        )
        for line in (proc.stderr or "").strip().splitlines():
            logging.debug("    stderr: %s", line)

    return ConversionResult(
        pdf_path=pdf_path,
        output_path=expected_output if success and expected_output.exists() else None,
        success=success,
        recommendation_count=count,
        duration_seconds=round(duration, 1),
        error_message="" if success else (
            proc.stderr.strip() or f"Converter exited with code {proc.returncode}."
        ),
        stdout=proc.stdout,
        stderr=proc.stderr,
    )


# -----------------------------------------------------------------------------
# Run report
# -----------------------------------------------------------------------------

def write_run_report(
    results: List[ConversionResult],
    report_path: Path,
    output_format: str,
    start_page: int,
    run_timestamp: str,
    total_duration: float,
) -> None:
    """
    Write a Markdown run report summarising all conversion results.

    Args:
        results: List of conversion results.
        report_path: File path to write the report to.
        output_format: Output format used for this run.
        start_page: Start page setting used for this run.
        run_timestamp: Human-readable UTC timestamp string.
        total_duration: Wall-clock seconds for the entire batch run.
    """
    succeeded = [r for r in results if r.success]
    failed = [r for r in results if not r.success]
    total_recs = sum(r.recommendation_count for r in succeeded)

    lines = [
        "# CIS Benchmark Conversion Report",
        "",
        f"**Run date:** {run_timestamp}  ",
        f"**Total duration:** {total_duration:.1f}s  ",
        f"**PDFs processed:** {len(results)}  ",
        f"**Succeeded:** {len(succeeded)}  ",
        f"**Failed:** {len(failed)}  ",
        f"**Total recommendations extracted:** {total_recs}  ",
        f"**Output format:** {output_format.upper()}  ",
        f"**Start page setting:** {start_page}  ",
        "",
        "---",
        "",
        "## Results",
        "",
        "| PDF | Status | Recommendations | Output File | Duration |",
        "|-----|--------|----------------|-------------|----------|",
    ]

    for result in results:
        status = "✅ Success" if result.success else "❌ Failed"
        count = str(result.recommendation_count) if result.success else "—"
        output_name = result.output_path.name if result.output_path else "—"
        duration = f"{result.duration_seconds:.1f}s"
        lines.append(
            f"| {result.pdf_path.name} | {status} | {count} | {output_name} | {duration} |"
        )

    if failed:
        lines += [
            "",
            "---",
            "",
            "## Failures",
        ]
        for result in failed:
            lines += [
                "",
                f"### {result.pdf_path.name}",
                "",
                "```",
                result.error_message or "No error details available.",
                "```",
            ]

    lines += [
        "",
        "---",
        "",
        "*Generated by `cis_batch_runner.py`*",
        "",
    ]

    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text("\n".join(lines), encoding="utf-8")
    logging.info("Run report written to: %s", report_path)


# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

def main() -> None:
    """Entry point for the CIS batch runner."""
    args = parse_arguments()

    logging.basicConfig(
        level=getattr(logging, args.log_level.upper(), logging.INFO),
        format="%(asctime)s | %(levelname)s | %(message)s",
    )

    input_dir = Path(args.input_dir).resolve()
    output_dir = Path(args.output_dir).resolve()
    converter_path = (Path(__file__).parent / "cis_benchmark_converter.py").resolve()
    report_path = Path(args.report).resolve() if args.report else output_dir / "run_report.md"

    logging.debug("Input dir:   %s", input_dir)
    logging.debug("Output dir:  %s", output_dir)
    logging.debug("Converter:   %s", converter_path)
    logging.debug("Format:      %s", args.output_format)
    logging.debug("Start page:  %d", args.start_page)
    logging.debug("Recursive:   %s", not args.no_recursive)

    if not input_dir.is_dir():
        logging.error("Input directory does not exist: %s", input_dir)
        sys.exit(1)

    if not converter_path.exists():
        logging.error(
            "cis_benchmark_converter.py not found at: %s", converter_path
        )
        sys.exit(1)

    output_dir.mkdir(parents=True, exist_ok=True)

    pdfs = find_pdfs(input_dir, recursive=not args.no_recursive)

    if not pdfs:
        logging.warning("No PDF files found in '%s'. Nothing to convert.", input_dir)
        sys.exit(0)

    run_timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    logging.info(
        "Starting batch conversion — %d PDF(s) — %s", len(pdfs), run_timestamp
    )

    batch_start = time.monotonic()
    results: List[ConversionResult] = []

    for pdf in pdfs:
        result = convert_pdf(
            pdf_path=pdf,
            output_dir=output_dir,
            output_format=args.output_format,
            start_page=args.start_page,
            log_level=args.log_level,
            converter_path=converter_path,
        )
        results.append(result)

    total_duration = round(time.monotonic() - batch_start, 1)
    succeeded = [r for r in results if r.success]
    failed = [r for r in results if not r.success]

    logging.info(
        "Batch complete: %d/%d succeeded, %d failed. Total time: %.1fs.",
        len(succeeded),
        len(results),
        len(failed),
        total_duration,
    )

    write_run_report(
        results=results,
        report_path=report_path,
        output_format=args.output_format,
        start_page=args.start_page,
        run_timestamp=run_timestamp,
        total_duration=total_duration,
    )

    if failed:
        logging.error(
            "%d conversion(s) failed. See report: %s", len(failed), report_path
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
