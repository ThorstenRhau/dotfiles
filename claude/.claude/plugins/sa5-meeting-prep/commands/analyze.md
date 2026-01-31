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

- `pandoc` installed for .docx conversion (`sudo apt install pandoc` or `brew install pandoc`)
- TDocs downloaded from ftp.3gpp.org and unzipped into the target folder
- Documents should be .doc or .docx format (S5-XXXXXX.docx)

## Pipeline Steps

### Step 1: Validate Environment

1. Check that pandoc is installed
2. Verify the input folder exists
3. Count .doc/.docx files and report to user

### Step 2: Create Working Directory

Create `/tmp/sa5-meeting-prep-<timestamp>/` for intermediate files:
- `fragments/` - Individual TDoc extractions
- `report/` - Final output

### Step 3: Extract TDocs (Fan-out with Haiku)

For each .doc/.docx file in the input folder:

1. Use the `tdoc-extractor` agent (runs on Haiku) to process each document
2. The agent will:
   - Convert document to text using pandoc
   - Extract structured information
   - Write a fragment file to the fragments directory
3. **Process documents in batches of 10 parallel agents**, reporting progress after each batch
4. Log any extraction failures for the final report (see Error Tracking below)

**Important**: Invoke the tdoc-extractor agent for EACH document individually:
```
Use the tdoc-extractor agent to extract information from [filepath] and write the fragment to [fragments-dir]/[TDoc-ID].md
```

### Step 4: Synthesize Report (Opus)

Once all extractions complete:

1. Use the `meeting-synthesizer` agent (runs on Opus) to create the final report
2. The agent reads all fragments and produces a comprehensive meeting prep document
3. Save the report to the working directory

**Invocation**:
```
Use the meeting-synthesizer agent to synthesize all fragments in [fragments-dir] into a meeting preparation report for SA5#[meeting-number]
```

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
     "error_type": "pandoc_timeout|format_unsupported|parse_failure|unknown",
     "filepath": "/path/to/S5-251234.docx",
     "message": "Brief error description"
   }
   ```

2. **At end of extraction phase**, write errors to:
   ```
   [working-dir]/errors.json
   ```

3. **Pass error count** to the synthesizer agent for statistics

## Error Handling

- If pandoc is missing: Provide installation instructions and abort
- If a document fails extraction: Record in errors list, continue with remaining documents
- If folder is empty: Inform user and abort
- Include failed documents in the final report appendix (via errors.json)

## Notes

- The pipeline uses Haiku for extraction (fast, cost-effective) and Opus for synthesis (better reasoning)
- Each subagent runs in its own context, preventing context pollution
- Progress is reported to keep the user informed during long runs
