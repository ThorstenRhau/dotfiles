---
description: Process 3GPP SA5 TDocs from a folder and generate a meeting preparation report
allowed-tools: Bash, Read, Write, Glob, Task
---

# SA5 Meeting Preparation

Process all TDocs in a folder and generate a prioritized meeting preparation report.

## Usage

```
/sa5-meeting-prep:analyze <folder-path>
```

Example:
```
/sa5-meeting-prep:analyze ~/3gpp/TSGS5_165
```

## Prerequisites

- **pandoc** installed: `brew install pandoc`
- TDocs downloaded from ftp.3gpp.org (zip files from Docs/, LSin/, LSout/, Agenda/)

## Pipeline Steps

### Step 1: Preprocess Documents

Run the preprocessing script to extract zips and convert documents to plain text:

```bash
~/.claude/plugins/sa5-meeting-prep/scripts/preprocess.sh <folder-path>
```

The script:
- Extracts all zip files from `Docs/`, `LSin/`, `LSout/`, `Agenda/`
- Converts `.doc`/`.docx` to plain text using pandoc
- Outputs to `/tmp/sa5-prep-<meeting-number>/`
- Produces `stats.json` with processing metrics

**After running**, read the stats file to get the working directory and document counts:

```bash
cat /tmp/sa5-prep-<meeting-number>/stats.json
```

**Validation**:
- If `output_files` is 0: **ABORT** with error
- If `output_files` < 10: **WARN** user this seems low for a 3GPP meeting

### Step 2: Set Up Working Directory

Based on the stats.json, set:
- `WORK_DIR` = the `output_folder` from stats.json
- `CONVERTED_DIR` = `$WORK_DIR/converted/`

Create additional directories for the extraction pipeline:

```bash
mkdir -p "$WORK_DIR"/{metadata,fragments,report}
```

### Step 3: Extract TDocs (Two-Stage Filtered Extraction)

Use a two-stage process to minimize context size while preserving quality.

#### Stage 3.1: Metadata Extraction (ALL documents)

1. Collect all `.txt` files from `$WORK_DIR/converted/`
2. Split into batches of 80-100 files each
3. For each batch, invoke the `metadata-extractor` agent:

```
Use the metadata-extractor agent to process metadata batch [N]: [list of 80-100 text file paths]
```

The agent extracts: TDoc ID, title, source, type, specs, relevance score
Writes compact metadata files (~100 bytes each) to `$WORK_DIR/metadata/`

#### Stage 3.2: Full Extraction (HIGH/MEDIUM only)

1. Read all metadata files and filter for HIGH and MEDIUM relevance
2. Split filtered documents into batches of 40-50 files each
3. For each batch, invoke the `batch-extractor` agent:

```
Use the batch-extractor agent to process batch [N] of HIGH/MEDIUM documents: [list of 40-50 text file paths]
```

The agent performs full extraction with detailed summaries.
Writes complete fragment files to `$WORK_DIR/fragments/`

#### Stage 3.3: Copy Metadata for LOW/NONE

For LOW and NONE relevance documents:
- Copy the metadata files from `metadata/` to `fragments/`
- These compact files (~100 bytes) provide statistics without full extraction

**Impact**:
- Typical meetings: ~60-70% LOW/NONE get metadata-only treatment
- Total context to synthesizer: ~50-70% smaller

### Step 4: Synthesize Report

Invoke the `meeting-synthesizer` agent (runs on Sonnet):

```
Use the meeting-synthesizer agent to synthesize all fragments in $WORK_DIR/fragments/ into a meeting preparation report for SA5#<meeting-number>
```

### Step 5: Deliver Results

1. Copy the final report to the input folder as `SA5-<meeting>-prep-report.md`
2. Present the report to the user
3. Report summary statistics:
   - Total documents processed
   - Breakdown by relevance (HIGH/MEDIUM/LOW/NONE)
   - Preprocessing failures (from stats.json)
   - Extraction failures

## Checkpoint & Resume

To enable resume on failure during long runs:

1. **After each batch of 10 documents**, write a checkpoint file:
   ```json
   {
     "processed": ["S5-251001", "S5-251002", ...],
     "last_batch": 3,
     "timestamp": "2025-01-15T10:30:00Z"
   }
   ```
   Location: `$WORK_DIR/checkpoint.json`

2. **On restart**: Check for existing checkpoint.json
   - Skip documents already in the processed list
   - Resume from the next batch

3. **On completion**: Remove checkpoint.json

## Error Tracking

Track extraction failures in `$WORK_DIR/errors.json`:

```json
{
  "tdoc_id": "S5-251234",
  "error_type": "parse_failure|empty_output|unknown",
  "message": "Brief error description"
}
```

Preprocessing failures are already tracked in:
- `$WORK_DIR/failed_extractions.txt`
- `$WORK_DIR/failed_conversions.txt`

## Notes

- Preprocessing runs as native bash (~60s for 500 docs) vs multiple API calls
- Haiku for batched extraction (fast, cost-effective)
- Sonnet for synthesis (excellent reasoning)
- Batch processing: ~10-15 agent invocations for typical meetings
