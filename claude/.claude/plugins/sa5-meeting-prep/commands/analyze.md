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

1. Check that pandoc is installed
2. Verify the input folder exists
3. Count .doc/.docx files and report to user

### Step 2: Create Working Directory

Create `/tmp/sa5-meeting-prep-<timestamp>/` for intermediate files:
- `converted/` - Converted text files from .doc/.docx
- `metadata/` - Compact metadata-only extractions (Stage 3.1)
- `fragments/` - Full TDoc extractions for HIGH/MEDIUM + metadata for LOW/NONE
- `report/` - Final output

### Step 2.5: Batch Convert Documents to Text

Before extraction, convert ALL .doc/.docx files to plain text in a single batch operation.

**IMPORTANT**: The conversion script must be macOS-compatible and handle edge cases robustly.

#### Conversion Script (macOS compatible)

Create and run this conversion script:

```bash
#!/bin/bash
# macOS-compatible batch conversion script
set -euo pipefail

INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"

# Create output directory
mkdir -p "$OUTPUT_FOLDER"

# Find all doc/docx files and convert them
# Using find + while loop with process substitution to avoid subshell issues
converted=0
failed=0
total=0

while IFS= read -r -d '' docfile; do
    total=$((total + 1))

    # Extract base name without extension
    filename=$(basename "$docfile")
    tdoc_id="${filename%.*}"
    outfile="$OUTPUT_FOLDER/${tdoc_id}.txt"

    # Convert with pandoc (skip if output already exists)
    if [[ -f "$outfile" ]]; then
        converted=$((converted + 1))
        continue
    fi

    if pandoc -f docx -t plain "$docfile" -o "$outfile" 2>/dev/null; then
        # Check if output is non-empty
        if [[ -s "$outfile" ]]; then
            converted=$((converted + 1))
        else
            rm -f "$outfile"
            failed=$((failed + 1))
        fi
    else
        failed=$((failed + 1))
    fi

    # Progress reporting every 50 files
    if (( total % 50 == 0 )); then
        echo "Progress: $total files processed (converted: $converted, failed: $failed)..."
    fi
done < <(find "$INPUT_FOLDER" -type f \( -iname "*.doc" -o -iname "*.docx" \) -print0)

echo "Conversion complete: $converted successful, $failed failed out of $total total"
```

#### Execution Steps

1. Create the working directory with subdirectories:
   ```bash
   WORK_DIR="/tmp/sa5-meeting-prep-$(date +%s)"
   mkdir -p "$WORK_DIR"/{converted,metadata,fragments,report}
   ```

2. If documents are in zip files (common for 3GPP), extract them first:
   ```bash
   cd "[input-folder]/Docs" && for z in *.zip; do [ -f "$z" ] && unzip -q -o "$z" 2>/dev/null || true; done
   ```

3. Run the conversion (either inline or save as script):
   - The script handles `.doc` and `.docx` files automatically
   - Uses `find` with `-print0` for safe filename handling
   - Process substitution `< <(find ...)` avoids subshell variable scope issues
   - No `timeout` command needed (pandoc is fast; hangs are rare)
   - Skips already-converted files for resume capability

4. Report conversion statistics to user:
   - Total documents found
   - Successfully converted
   - Failed conversions
   - Output directory location

5. **Important**: Extraction agents will now receive paths to `.txt` files instead of `.docx` files

#### Troubleshooting

- **"no matches found" errors**: The script uses `find` instead of glob patterns to avoid zsh issues
- **Hanging conversions**: If a file hangs, you can kill the pandoc process; the script will continue
- **Corrupted files**: Files that produce empty output are counted as failures
- **Resume after interruption**: Re-running skips already-converted files

### Step 3: Extract TDocs (Two-Stage Filtered Extraction)

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

### Step 4: Synthesize Report (Sonnet)

Once all extractions complete:

1. Use the `meeting-synthesizer` agent (runs on Sonnet) to create the final report
2. The agent reads all fragments and produces a comprehensive meeting prep document
3. Save the report to the working directory

**Invocation**:
```
Use the meeting-synthesizer agent to synthesize all fragments in [fragments-dir] into a meeting preparation report for SA5#[meeting-number]
```

**Note**: Sonnet provides excellent synthesis quality at ~5x lower cost than Opus.

### Step 5: Deliver Results

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
