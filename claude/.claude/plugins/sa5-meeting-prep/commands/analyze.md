---
description: Process 3GPP SA5 TDocs from a folder and generate a meeting preparation report
allowed-tools: Bash, Read, Write, Glob, Task
---

# SA5 Meeting Preparation

Process all TDocs in a folder and generate a prioritized meeting preparation report.

## Usage

```
/sa5-meeting-prep:analyze <folder-path> [meeting-number]
```

Example:
```
/sa5-meeting-prep:analyze ~/3gpp/sa5-162 162
```

## Prerequisites

- **pandoc** installed for .docx conversion:
  - macOS: `brew install pandoc`
  - Linux: `sudo apt install pandoc`
- TDocs downloaded from ftp.3gpp.org (can be in zip files or already extracted)
- Documents should be .doc or .docx format (S5-XXXXXX.docx)
- **macOS note**: Uses bash-compatible commands (no GNU coreutils required)

## Pipeline Steps

### Step 1: Validate Environment

1. Check that pandoc is installed: `command -v pandoc`
2. Verify the input folder exists

### Step 2: Create Working Directory

Create `/tmp/sa5-meeting-prep-<timestamp>/` for intermediate files:

```bash
WORK_DIR="/tmp/sa5-meeting-prep-$(date +%s)"
mkdir -p "$WORK_DIR"/{extracted,converted,metadata,fragments,report}
```

Subdirectories:
- `extracted/` - Documents extracted from zip files
- `converted/` - Converted text files from .doc/.docx
- `metadata/` - Compact metadata-only extractions (Stage 3.1)
- `fragments/` - Full TDoc extractions for HIGH/MEDIUM + metadata for LOW/NONE
- `report/` - Final output

### Step 2.5: Extract Zip Files (MANDATORY)

**CRITICAL**: 3GPP TDocs are distributed as zip files. This step MUST run before counting documents.

#### Zip Extraction Script

Search the ENTIRE input folder (recursively) for zip files and extract them:

```bash
#!/bin/bash
# Extract all zip files from input folder to working directory
set -euo pipefail

INPUT_FOLDER="$1"
EXTRACT_DIR="$2"

mkdir -p "$EXTRACT_DIR"

zip_count=0
extracted_count=0
failed_count=0

# Find ALL zip files recursively in the input folder
while IFS= read -r -d '' zipfile; do
    zip_count=$((zip_count + 1))

    # Extract to the working directory (flat structure, overwrite existing)
    if unzip -o -q "$zipfile" -d "$EXTRACT_DIR" 2>/dev/null; then
        extracted_count=$((extracted_count + 1))
    else
        echo "Warning: Failed to extract $zipfile"
        failed_count=$((failed_count + 1))
    fi

    # Progress every 100 zips
    if (( zip_count % 100 == 0 )); then
        echo "Zip extraction progress: $zip_count files processed..."
    fi
done < <(find "$INPUT_FOLDER" -type f -iname "*.zip" -print0)

echo "Zip extraction complete: $extracted_count successful, $failed_count failed out of $zip_count total"
```

#### Execution

1. Run the extraction script with `INPUT_FOLDER` and `WORK_DIR/extracted/` as arguments
2. **MUST report** extraction statistics to user:
   - Number of zip files found
   - Number successfully extracted
   - Number failed
3. **If zero zip files found**, check for already-extracted .docx files in input folder

### Step 2.6: Count and Validate Documents

**AFTER** zip extraction, count available documents:

```bash
# Count documents in BOTH extracted folder AND original input folder
doc_count=$(find "$WORK_DIR/extracted" "$INPUT_FOLDER" -type f \( -iname "*.doc" -o -iname "*.docx" \) 2>/dev/null | wc -l)
echo "Found $doc_count .doc/.docx files to process"
```

**CRITICAL VALIDATION**:
- If `doc_count` is 0: **ABORT** with error "No documents found. Check that the input folder contains .zip files or .docx files."
- If `doc_count` < 10: **WARN** user "Only found X documents - this seems low for a 3GPP meeting. Expected 200-600 documents."

### Step 3: Batch Convert Documents to Text

Convert ALL .doc/.docx files to plain text.

**IMPORTANT**: Search BOTH the extracted folder AND the original input folder.

#### Conversion Script (macOS compatible)

```bash
#!/bin/bash
# macOS-compatible batch conversion script
set -euo pipefail

EXTRACTED_FOLDER="$1"
INPUT_FOLDER="$2"
OUTPUT_FOLDER="$3"

mkdir -p "$OUTPUT_FOLDER"

converted=0
failed=0
total=0

# Search BOTH extracted folder and original input folder
while IFS= read -r -d '' docfile; do
    total=$((total + 1))

    filename=$(basename "$docfile")
    tdoc_id="${filename%.*}"
    outfile="$OUTPUT_FOLDER/${tdoc_id}.txt"

    # Skip if already converted
    if [[ -f "$outfile" ]]; then
        converted=$((converted + 1))
        continue
    fi

    if pandoc -f docx -t plain "$docfile" -o "$outfile" 2>/dev/null; then
        if [[ -s "$outfile" ]]; then
            converted=$((converted + 1))
        else
            rm -f "$outfile"
            failed=$((failed + 1))
        fi
    else
        failed=$((failed + 1))
    fi

    if (( total % 50 == 0 )); then
        echo "Conversion progress: $total files (converted: $converted, failed: $failed)..."
    fi
done < <(find "$EXTRACTED_FOLDER" "$INPUT_FOLDER" -type f \( -iname "*.doc" -o -iname "*.docx" \) -print0 2>/dev/null)

echo "Conversion complete: $converted successful, $failed failed out of $total total"
```

#### Execution

1. Run conversion with `WORK_DIR/extracted/`, `INPUT_FOLDER`, and `WORK_DIR/converted/` as arguments
2. Report conversion statistics to user
3. **If converted count is 0**: ABORT with error

#### Troubleshooting

- **"no matches found" errors**: The script uses `find` instead of glob patterns to avoid zsh issues
- **Hanging conversions**: If a file hangs, kill pandoc; the script continues
- **Corrupted files**: Files producing empty output are counted as failures
- **Resume after interruption**: Re-running skips already-converted files

### Step 4: Extract TDocs (Two-Stage Filtered Extraction)

Use a two-stage process to minimize context size while preserving quality:

#### Stage 3.1: Metadata Extraction (ALL documents)

1. Collect all `.txt` files from the `converted/` directory
2. Split them into batches of 80-100 files each
3. For each batch:
   - Invoke the `metadata-extractor` agent with the list of file paths
   - Agent extracts only: TDoc ID, title, source, type, specs, relevance score
   - Writes compact metadata files (~100 bytes each) to `[working-dir]/metadata/`
   - Report progress and relevance distribution after each batch

**Invocation example**:
```
Use the metadata-extractor agent to process metadata batch [N]: [list of 80-100 text file paths]
```

#### Stage 3.2: Full Extraction (HIGH/MEDIUM only)

1. Read all metadata files and filter for HIGH and MEDIUM relevance
2. Split filtered documents into batches of 40-50 files each
3. For each batch:
   - Invoke the `batch-extractor` agent with the filtered file paths
   - Agent performs full extraction with detailed summaries
   - Writes complete fragment files to `[working-dir]/fragments/`
   - Report progress after each batch

**Invocation example**:
```
Use the batch-extractor agent to process batch [N] of HIGH/MEDIUM documents: [list of 40-50 text file paths]
```

#### Stage 3.3: Copy Metadata for LOW/NONE

For LOW and NONE relevance documents:
- Copy the metadata files from `metadata/` to `fragments/` directory
- These compact files (~100 bytes) will be included in synthesis for statistics
- No detailed summaries needed

**Impact**:
- Typical meetings: ~60-70% LOW/NONE documents get metadata-only treatment
- Fragment size reduction: ~85% for filtered documents
- Total context to synthesizer: ~50-70% smaller

### Step 5: Synthesize Report (Sonnet)

Once all extractions complete:

1. Use the `meeting-synthesizer` agent (runs on Sonnet) to create the final report
2. The agent reads all fragments and produces a comprehensive meeting prep document
3. Save the report to the working directory

**Invocation**:
```
Use the meeting-synthesizer agent to synthesize all fragments in [fragments-dir] into a meeting preparation report for SA5#[meeting-number]
```

**Note**: Sonnet provides excellent synthesis quality at ~5x lower cost than Opus.

### Step 6: Deliver Results

1. Copy the final report to the input folder as `SA5-[meeting]-prep-report.md`
2. Present the report to the user
3. Report summary statistics:
   - Total documents processed
   - Breakdown by relevance (HIGH/MEDIUM/LOW/NONE)
   - Any extraction failures

## Checkpoint & Resume

To enable resume on failure during long runs:

1. **After each batch of 10 documents**, write a checkpoint file:
   ```json
   // [working-dir]/checkpoint.json
   {
     "processed": ["S5-251001", "S5-251002", ...],
     "last_batch": 3,
     "timestamp": "2025-01-15T10:30:00Z"
   }
   ```

2. **On restart**: Check for existing checkpoint.json in the working directory
   - If found, read the list of processed TDoc IDs
   - Skip any documents already in the processed list
   - Resume from the next batch

3. **On completion**: Remove checkpoint.json (processing complete)

## Error Tracking

Maintain structured error tracking throughout extraction:

1. **For each failure**, record:
   ```json
   {
     "tdoc_id": "S5-251234",
     "error_type": "conversion_failed|format_unsupported|parse_failure|empty_output|unknown",
     "filepath": "/path/to/S5-251234.docx",
     "message": "Brief error description"
   }
   ```

2. **At end of extraction phase**, write errors to:
   ```
   [working-dir]/errors.json
   ```

3. **Pass error count** to the synthesizer agent for statistics

**Note**: The orchestrating Claude instance (not the extraction agents) maintains errors.json by parsing agent responses and tracking failures.

## Error Handling

- If pandoc is missing: Provide installation instructions and abort
- If a document fails extraction: Record in errors list, continue with remaining documents
- If folder is empty: Inform user and abort
- Include failed documents in the final report appendix (via errors.json)

## Notes

- The pipeline uses Haiku for batched extraction (fast, cost-effective) and Sonnet for synthesis (excellent reasoning, cost-efficient)
- Batch processing reduces agent invocations from ~500 to ~10-15 for typical meeting sets
- Pre-converting documents eliminates redundant pandoc overhead
- Progress is reported to keep the user informed during long runs
- Total cost: ~20-30% of previous implementation for 500 documents
