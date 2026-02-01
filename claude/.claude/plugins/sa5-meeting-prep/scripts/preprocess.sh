#!/bin/bash
#
# preprocess.sh - Extract and convert 3GPP SA5 meeting documents for AI ingestion
#
# Usage: ./preprocess.sh <meeting-folder> [output-folder]
#
# Example:
#   ./preprocess.sh ~/3gpp/TSGS5_165
#   ./preprocess.sh ~/3gpp/TSGS5_165 /tmp/sa5-prep
#
# This script:
#   1. Extracts all zip files from Docs/, LSin/, LSout/, Agenda/
#   2. Converts .doc/.docx files to plain text using pandoc
#   3. Outputs organized text files ready for AI processing
#
# Requirements:
#   - pandoc (brew install pandoc)
#   - unzip (usually pre-installed on macOS/Linux)

set -euo pipefail

# Colors for output (disabled if not a terminal)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log_info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat <<EOF
Usage: $(basename "$0") <meeting-folder> [output-folder]

Extract and convert 3GPP SA5 meeting documents for AI ingestion.

Arguments:
  meeting-folder   Path to the downloaded 3GPP meeting folder (e.g., TSGS5_165)
  output-folder    Optional output directory (default: /tmp/sa5-prep-<meeting-number>)

The script processes these subdirectories:
  Docs/    - Main TDocs (contributions)
  LSin/    - Incoming liaison statements
  LSout/   - Outgoing liaison statements
  Agenda/  - Meeting agenda documents

Output structure:
  <output-folder>/
    extracted/     - Raw extracted files from zips
    converted/     - Plain text versions of documents
    stats.json     - Processing statistics

Requirements:
  - pandoc: brew install pandoc

Examples:
  $(basename "$0") ~/3gpp/TSGS5_165
  $(basename "$0") ~/3gpp/TSGS5_165 ./output
EOF
    exit 1
}

# Check dependencies
check_dependencies() {
    local missing=()

    if ! command -v pandoc &>/dev/null; then
        missing+=("pandoc")
    fi

    if ! command -v unzip &>/dev/null; then
        missing+=("unzip")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        for dep in "${missing[@]}"; do
            case "$dep" in
                pandoc) echo "  brew install pandoc" ;;
                unzip)  echo "  brew install unzip" ;;
            esac
        done
        exit 1
    fi
}

# Extract all zip files from a directory
extract_zips() {
    local src_dir="$1"
    local dest_dir="$2"
    local category="$3"

    local zip_count=0
    local success_count=0
    local fail_count=0

    if [[ ! -d "$src_dir" ]]; then
        return 0
    fi

    # Count zips first
    local total_zips
    total_zips=$(find "$src_dir" -maxdepth 1 -type f -iname "*.zip" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$total_zips" -eq 0 ]]; then
        return 0
    fi

    log_info "Extracting $total_zips zip files from $category..."

    while IFS= read -r -d '' zipfile; do
        zip_count=$((zip_count + 1))

        if unzip -o -q -j "$zipfile" -d "$dest_dir" 2>/dev/null; then
            success_count=$((success_count + 1))
        else
            log_warn "Failed to extract: $(basename "$zipfile")"
            fail_count=$((fail_count + 1))
            echo "$(basename "$zipfile")" >> "$OUTPUT_DIR/failed_extractions.txt"
        fi

        # Progress every 50 files
        if (( zip_count % 50 == 0 )); then
            echo "  Progress: $zip_count / $total_zips"
        fi
    done < <(find "$src_dir" -maxdepth 1 -type f -iname "*.zip" -print0 2>/dev/null)

    log_ok "$category: $success_count extracted, $fail_count failed"

    # Return counts via global variables (bash limitation)
    EXTRACT_SUCCESS=$((EXTRACT_SUCCESS + success_count))
    EXTRACT_FAIL=$((EXTRACT_FAIL + fail_count))
}

# Convert a single document to text
convert_doc() {
    local docfile="$1"
    local outdir="$2"

    local filename
    filename=$(basename "$docfile")

    # Skip macOS resource fork files
    if [[ "$filename" == ._* ]]; then
        return 2  # Special return code for "skipped intentionally"
    fi

    local tdoc_id="${filename%.*}"
    local outfile="$outdir/${tdoc_id}.txt"

    # Skip if already converted
    if [[ -f "$outfile" ]]; then
        return 0
    fi

    # Determine input format (case-insensitive check, macOS compatible)
    local ext="${filename##*.}"

    # Try conversion - let pandoc auto-detect format first, fall back to explicit
    if pandoc -t plain --wrap=none "$docfile" -o "$outfile" 2>/dev/null; then
        if [[ -s "$outfile" ]]; then
            return 0
        fi
    fi

    # Fallback: try with explicit docx format for .doc files (sometimes works)
    if [[ "$ext" == "doc" ]] || [[ "$ext" == "DOC" ]]; then
        if pandoc -f docx -t plain --wrap=none "$docfile" -o "$outfile" 2>/dev/null; then
            if [[ -s "$outfile" ]]; then
                return 0
            fi
        fi
    fi

    # Failed
    rm -f "$outfile"
    return 1
}

# Convert all documents in a directory
convert_documents() {
    local src_dir="$1"
    local dest_dir="$2"

    local total=0
    local converted=0
    local skipped=0
    local failed=0
    local ignored=0

    # Count documents first (excluding macOS resource forks)
    local doc_count
    doc_count=$(find "$src_dir" -type f \( -iname "*.doc" -o -iname "*.docx" \) ! -name "._*" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$doc_count" -eq 0 ]]; then
        log_warn "No .doc/.docx files found in extracted folder"
        return 0
    fi

    log_info "Converting $doc_count documents to plain text..."

    while IFS= read -r -d '' docfile; do
        total=$((total + 1))

        local filename
        filename=$(basename "$docfile")

        # Skip macOS resource fork files silently
        if [[ "$filename" == ._* ]]; then
            ignored=$((ignored + 1))
            continue
        fi

        local tdoc_id="${filename%.*}"
        local outfile="$dest_dir/${tdoc_id}.txt"

        # Skip if already converted
        if [[ -f "$outfile" ]]; then
            skipped=$((skipped + 1))
            continue
        fi

        if convert_doc "$docfile" "$dest_dir"; then
            converted=$((converted + 1))
        else
            local result=$?
            if [[ $result -eq 2 ]]; then
                ignored=$((ignored + 1))
            else
                failed=$((failed + 1))
                echo "$filename" >> "$OUTPUT_DIR/failed_conversions.txt"
            fi
        fi

        # Progress every 50 files (excluding ignored)
        local processed=$((converted + skipped + failed))
        if (( processed % 50 == 0 )) && (( processed > 0 )); then
            echo "  Progress: $processed / $doc_count (converted: $converted, skipped: $skipped, failed: $failed)"
        fi
    done < <(find "$src_dir" -type f \( -iname "*.doc" -o -iname "*.docx" \) -print0 2>/dev/null)

    if [[ $ignored -gt 0 ]]; then
        log_ok "Conversion complete: $converted new, $skipped skipped, $failed failed (ignored $ignored resource forks)"
    else
        log_ok "Conversion complete: $converted new, $skipped skipped, $failed failed"
    fi

    CONVERT_SUCCESS=$((CONVERT_SUCCESS + converted))
    CONVERT_SKIP=$((CONVERT_SKIP + skipped))
    CONVERT_FAIL=$((CONVERT_FAIL + failed))
}

# Also convert any loose documents in the input folder
convert_loose_documents() {
    local input_dir="$1"
    local dest_dir="$2"

    # Only process specific subdirectories that might have loose docs
    for subdir in "Docs" "LSin" "LSout" "Agenda"; do
        local src="$input_dir/$subdir"
        if [[ -d "$src" ]]; then
            while IFS= read -r -d '' docfile; do
                if convert_doc "$docfile" "$dest_dir"; then
                    CONVERT_SUCCESS=$((CONVERT_SUCCESS + 1))
                fi
            done < <(find "$src" -maxdepth 1 -type f \( -iname "*.doc" -o -iname "*.docx" \) -print0 2>/dev/null)
        fi
    done
}

# Write statistics JSON
write_stats() {
    local stats_file="$OUTPUT_DIR/stats.json"
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))

    local txt_count
    txt_count=$(find "$OUTPUT_DIR/converted" -type f -name "*.txt" 2>/dev/null | wc -l | tr -d ' ')

    cat > "$stats_file" <<EOF
{
  "input_folder": "$INPUT_DIR",
  "output_folder": "$OUTPUT_DIR",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "duration_seconds": $duration,
  "extraction": {
    "success": $EXTRACT_SUCCESS,
    "failed": $EXTRACT_FAIL
  },
  "conversion": {
    "success": $CONVERT_SUCCESS,
    "skipped": $CONVERT_SKIP,
    "failed": $CONVERT_FAIL
  },
  "output_files": $txt_count
}
EOF

    log_info "Statistics written to: $stats_file"
}

# Print summary
print_summary() {
    local txt_count
    txt_count=$(find "$OUTPUT_DIR/converted" -type f -name "*.txt" 2>/dev/null | wc -l | tr -d ' ')

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "                    PREPROCESSING COMPLETE"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "  Input:     $INPUT_DIR"
    echo "  Output:    $OUTPUT_DIR"
    echo "  Duration:  ${duration}s"
    echo ""
    echo "  Zip Extraction:"
    echo "    Success: $EXTRACT_SUCCESS"
    echo "    Failed:  $EXTRACT_FAIL"
    echo ""
    echo "  Document Conversion:"
    echo "    Success: $CONVERT_SUCCESS"
    echo "    Skipped: $CONVERT_SKIP (already converted)"
    echo "    Failed:  $CONVERT_FAIL"
    echo ""
    echo "  Ready for AI: $txt_count text files"
    echo "  Location:     $OUTPUT_DIR/converted/"
    echo ""
    echo "═══════════════════════════════════════════════════════════"

    if [[ -f "$OUTPUT_DIR/failed_extractions.txt" ]] || [[ -f "$OUTPUT_DIR/failed_conversions.txt" ]]; then
        log_warn "Some files failed. Check:"
        [[ -f "$OUTPUT_DIR/failed_extractions.txt" ]] && echo "  - $OUTPUT_DIR/failed_extractions.txt"
        [[ -f "$OUTPUT_DIR/failed_conversions.txt" ]] && echo "  - $OUTPUT_DIR/failed_conversions.txt"
    fi
}

# Main
main() {
    if [[ $# -lt 1 ]]; then
        usage
    fi

    INPUT_DIR="$1"

    # Expand tilde if present
    INPUT_DIR="${INPUT_DIR/#\~/$HOME}"

    # Validate input directory
    if [[ ! -d "$INPUT_DIR" ]]; then
        log_error "Input directory does not exist: $INPUT_DIR"
        exit 1
    fi

    # Resolve to absolute path
    INPUT_DIR=$(cd "$INPUT_DIR" && pwd)

    # Extract meeting number from folder name (e.g., TSGS5_165 → 165, SA5#162 → 162)
    local folder_name
    folder_name=$(basename "$INPUT_DIR")
    MEETING_NUM=$(echo "$folder_name" | grep -oE '[0-9]+$' || echo "")

    if [[ -z "$MEETING_NUM" ]]; then
        # Fallback: try to find any number in the folder name
        MEETING_NUM=$(echo "$folder_name" | grep -oE '[0-9]+' | tail -1 || echo "unknown")
    fi

    # Set output directory
    if [[ $# -ge 2 ]]; then
        OUTPUT_DIR="$2"
        OUTPUT_DIR="${OUTPUT_DIR/#\~/$HOME}"
    else
        OUTPUT_DIR="/tmp/sa5-prep-${MEETING_NUM}"
    fi

    # Check dependencies
    check_dependencies

    # Initialize counters
    EXTRACT_SUCCESS=0
    EXTRACT_FAIL=0
    CONVERT_SUCCESS=0
    CONVERT_SKIP=0
    CONVERT_FAIL=0
    START_TIME=$(date +%s)

    # Create output directories
    mkdir -p "$OUTPUT_DIR"/{extracted,converted}

    log_info "Starting preprocessing of: $INPUT_DIR"
    log_info "Output directory: $OUTPUT_DIR"
    echo ""

    # Phase 1: Extract all zip files
    log_info "=== PHASE 1: ZIP EXTRACTION ==="
    extract_zips "$INPUT_DIR/Docs"   "$OUTPUT_DIR/extracted" "Docs"
    extract_zips "$INPUT_DIR/LSin"   "$OUTPUT_DIR/extracted" "LSin"
    extract_zips "$INPUT_DIR/LSout"  "$OUTPUT_DIR/extracted" "LSout"
    extract_zips "$INPUT_DIR/Agenda" "$OUTPUT_DIR/extracted" "Agenda"
    echo ""

    # Phase 2: Convert documents to text
    log_info "=== PHASE 2: DOCUMENT CONVERSION ==="
    convert_documents "$OUTPUT_DIR/extracted" "$OUTPUT_DIR/converted"

    # Also check for loose documents in input folder
    convert_loose_documents "$INPUT_DIR" "$OUTPUT_DIR/converted"
    echo ""

    # Write stats and summary
    write_stats
    print_summary
}

main "$@"
