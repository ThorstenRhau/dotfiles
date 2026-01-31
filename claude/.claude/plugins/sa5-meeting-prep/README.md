# SA5 Meeting Prep Plugin

A Claude Code plugin for processing 3GPP SA5 TDocs and generating meeting
preparation reports.

## Features

- **Optimized batch processing**: Process 500+ documents efficiently with batched extraction
- **Two-stage filtering**: Metadata-only extraction for low-relevance documents
- **Cost-effective model routing**: Uses Haiku for extraction, Sonnet for synthesis
- **Prioritized output**: Documents ranked by relevance to your focus areas
- **Cross-reference analysis**: Identifies conflicts, alignments, and discussion opportunities
- **~75% cost reduction**: Processes typical SA5 meetings at ~20-30% of original cost

## Installation

### Option 1: Local Installation

```bash
# Clone or copy the plugin to your Claude Code plugins directory
cp -r sa5-meeting-prep ~/.claude/plugins/

# Or use the plugin directory flag when testing
claude --plugin-dir /path/to/sa5-meeting-prep
```

### Option 2: Via Marketplace (if published)

```
/plugin marketplace add your-marketplace
/plugin install sa5-meeting-prep@your-marketplace
```

## Prerequisites

1. **pandoc** - Required for .docx conversion

   ```bash
   # Ubuntu/Debian
   sudo apt install pandoc

   # macOS
   brew install pandoc
   ```

2. **TDocs downloaded** - Get documents from ftp.3gpp.org and unzip them

## Usage

```
/sa5-meeting-prep:analyze <folder-path> [meeting-number]
```

### Example

```bash
# Download TDocs from 3GPP
mkdir -p ~/3gpp/sa5-162
cd ~/3gpp/sa5-162
# Download and unzip documents...

# Run analysis
claude
> /sa5-meeting-prep:analyze ~/3gpp/sa5-162 162
```

## Output

The plugin generates a markdown report with:

- **Executive Summary**: Key themes and priorities
- **Priority Reading List**: Documents ranked HIGH/MEDIUM/LOW by relevance
- **Thematic Analysis**: Grouped by topic area
- **Conflicts & Alignments**: Potential issues and collaboration opportunities
- **Suggested Discussions**: Delegates/companies to meet with
- **Full TDoc Index**: Complete listing for reference

## Configuration

### Focus Areas (edit agents/meeting-synthesizer.md)

Default focus areas:

- Cloud management and orchestration
- Correlation context / distributed tracing
- O-RAN interfaces
- NRM IOCs (TS 28.541, 28.623, 28.532, 32.158)
- Data management framework

### Model Selection

- `metadata-extractor`: Haiku (ultra-fast relevance scoring, processes 80-100 docs/batch)
- `batch-extractor`: Haiku (efficient full extraction, processes 40-50 docs/batch)
- `meeting-synthesizer`: Sonnet (excellent synthesis quality, ~5x cheaper than Opus)

### Performance

Typical SA5 meeting with 500 TDocs:

- **Runtime**: ~15-20 minutes (down from 60 minutes)
- **Agent invocations**: ~15-20 (down from 500+)
- **Token cost**: ~20-30% of original implementation
- **Quality**: Maintained through two-stage filtering and Sonnet synthesis

## Plugin Structure

```
sa5-meeting-prep/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── commands/
│   └── analyze.md               # Main slash command (orchestrates pipeline)
├── agents/
│   ├── metadata-extractor.md    # Haiku: Stage 1 relevance scoring (80-100 docs/batch)
│   ├── batch-extractor.md       # Haiku: Stage 2 full extraction (40-50 docs/batch)
│   └── meeting-synthesizer.md   # Sonnet: Report synthesis
├── skills/
│   └── tdoc-formats/
│       └── SKILL.md             # 3GPP document format reference
└── README.md
```

## Optimization Details

The plugin uses a multi-stage optimization strategy:

1. **Batch pandoc conversion**: All documents converted upfront (no per-agent overhead)
2. **Batched extraction**: Process 40-100 docs per agent vs 1 doc per agent
3. **Two-stage filtering**: Metadata-only for LOW/NONE relevance (~60-70% of docs)
4. **Sonnet synthesis**: ~5x cheaper than Opus with excellent quality
5. **Result**: ~75% cost reduction, 4x faster processing

## License

MIT
