# SA5 Meeting Prep Plugin

A Claude Code plugin for processing 3GPP SA5 TDocs and generating meeting
preparation reports.

## Features

- **Batch TDoc processing**: Process all documents from a meeting folder
- **Efficient model routing**: Uses Haiku for fast extraction, Opus for
  synthesis
- **Prioritized output**: Documents ranked by relevance to your focus areas
- **Cross-reference analysis**: Identifies conflicts, alignments, and discussion
  opportunities

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

- `tdoc-extractor`: Haiku (fast, cost-effective for structured extraction)
- `meeting-synthesizer`: Opus (best reasoning for cross-reference analysis)

## Plugin Structure

```
sa5-meeting-prep/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   └── analyze.md           # Main slash command
├── agents/
│   ├── tdoc-extractor.md    # Haiku agent for document extraction
│   └── meeting-synthesizer.md # Opus agent for report synthesis
├── skills/
│   └── tdoc-formats/
│       └── SKILL.md         # 3GPP document format reference
└── README.md
```

## License

MIT
