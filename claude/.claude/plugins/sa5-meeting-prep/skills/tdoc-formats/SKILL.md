---
name: tdoc-formats
description: Reference for 3GPP TDoc document formats and types. Use when parsing or understanding SA5 meeting documents.
---

# 3GPP TDoc Format Reference

This skill provides reference information for parsing and understanding 3GPP SA5 Technical Documents (TDocs).

## TDoc Naming Convention

TDocs follow the pattern: `S5-YYNNNN`

- `S5` = SA5 working group identifier
- `YY` = Year (e.g., 25 = 2025)
- `NNNN` = Sequential number within the year

Example: `S5-251234` = SA5 document #1234 from 2025

## Document Types

### Change Request (CR)

- Modifies an existing 3GPP specification
- Has a formal structure with CR cover sheet
- Contains "Reason for change", "Summary of change", "Consequences if not approved"
- Includes marked-up text showing proposed changes
- Requires WG agreement to progress

### pseudo-CR (pCR)

- Proposed change request, not yet formally submitted
- Often used during Study Items to propose normative text
- May be converted to CR when work item is approved
- Less formal than CR but follows similar structure

### Discussion Paper (DP)

- Raises issues or proposes approaches for discussion
- No direct spec changes
- Used to gather input before drafting CRs
- May contain analysis, comparisons, or proposals

### Liaison Statement (LS)

- Communication to/from other 3GPP groups or external organizations
- Types:
  - LS IN = Incoming liaison (from another group)
  - LS OUT = Outgoing liaison (to another group)
  - LS Reply = Response to a previous LS
- Contains "To:", "Cc:", and formal request/information sections

### Work Item Description (WID)

- Defines scope and objectives of a new work item
- Specifies deliverables (which specs will be updated)
- Includes timeline and responsible parties
- Requires TSG approval

### Study Item Description (SID)

- Proposes a study (precedes work item)
- Exploratory, may result in Technical Report (TR)
- Less formal deliverables than WID

## Common Sections in TDocs

### Header Block
```
3GPP TSG SA WG5 Meeting #NNN
[Location], [Date]

Title: [Document title]
Source: [Company name]
Document for: [Discussion/Decision/Approval/Information]
Agenda Item: [X.Y]
```

### CR-Specific Fields
```
CR: NNNN
Rev: [revision number]
Current version: XX.Y.Z
Target Release: Rel-XX
Spec: TS 28.XXX
```

## Specification Series

### TS 28.xxx - Management and Orchestration
- 28.532: Management services
- 28.541: 5G NRM
- 28.622: Generic NRM IRP IS
- 28.623: Generic NRM IRP SS (YANG/OpenAPI)

### TS 32.xxx - Charging and Management (Legacy)
- 32.158: Management data collection integration reference point

### TR 28.xxx - Technical Reports
- Study items produce TRs
- May become normative TS later

## Relevance Indicators for Cloud/Orchestration Focus

### High-Priority Keywords
- "cloud-native", "cloud-based", "containerized"
- "orchestration", "NFVO", "VNFM", "LCM"
- "correlation", "trace", "tracing", "distributed"
- "OpenTelemetry", "OTEL", "observability"
- "O-RAN", "O1", "O2"
- "NRM", "IOC", "information object class"
- "management data", "PM", "FM", "CM"

### Medium-Priority Keywords
- "analytics", "AI/ML", "AIML"
- "intent", "intent-driven"
- "performance measurement", "KPI"
- "fault management", "alarm"

### Context Keywords
- "5G-Advanced", "Rel-19", "Rel-20"
- "network function", "NF"
- "service management", "network slice"
