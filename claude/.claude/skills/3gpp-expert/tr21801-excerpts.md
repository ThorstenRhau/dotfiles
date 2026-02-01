# TR 21.801 Excerpts: Specification Drafting Rules

Source: 3GPP TR 21.801 V19.0.0 (2025-03)

---

## Clause 4: General Principles

### 4.1 Objective

The objective of a 3GPP TS or TR is to define clear and unambiguous provisions. The document shall:
- be as complete as necessary within the limits specified by its scope
- be consistent, clear and accurate
- provide a framework for future technological development
- be comprehensible to qualified persons who have not participated in its preparation

### 4.2 Homogeneity

Uniformity of structure, style and terminology shall be maintained not only within each document but also within a series of associated TSs or TRs.
- Analogous wording for analogous provisions
- Identical wording for identical provisions
- Same term used throughout for a given concept (avoid synonyms)
- Only one meaning attributed to each term chosen

---

## Clause 5: Structure

### 5.1 Subdivision of Subject Matter

**Table 1: Names of divisions and subdivisions**

| Term   | Example of numbering |
|--------|---------------------|
| part   | 3GPP TS 21.299-1    |
| clause | 1                   |
| clause | 1.1                 |
| clause | 1.1.1               |
| annex  | A                   |
| clause | A.1                 |
| clause | A.1.1               |

### 5.2.1A General Numbering Issues

- New elements may be inserted using alphanumeric designation (e.g., clause 8A between 8 and 9)
- Deleted elements replaced with "(Void)" to minimize disruption
- Once under change control, changing existing clause numbers is **strongly deprecated**

### 5.2.4 Paragraph - Hanging Paragraphs

**Hanging paragraphs are forbidden.** No text shall appear between a heading and its first subheading.

**Solutions:**
- Move text to a subclause (e.g., "6.1 General")
- Add clause numbered 5.0 if needed to avoid renumbering
- Place after all subclauses

### 5.2.5 Lists

- Lists may be introduced by a sentence ending with a colon
- Each item preceded by a dash
- For identification, use lowercase letter + parenthesis: a), b), c)
- Nested lists: arabic numerals + parenthesis: 1), 2), 3)

**Punctuation:**
- Semicolon after each item except last
- Period after final item
- Use "and" or "or" at penultimate item to indicate combinability

### 5.2.6 Annex

- Each annex starts on a new page
- Designated by "Annex" followed by capital letter (A, B, C...)
- TS annexes shall include "(normative):" or "(informative):" after heading
- TR annexes omit normative/informative label (entire document is informative)
- Tables/figures in annexes numbered with letter prefix (e.g., Table A.1-1)

---

## Clause 6: Drafting

### 6.1.5 Scope (Clause 1)

- Defines the subject and aspects covered without ambiguity
- Shall not contain requirements
- Worded as statements of fact:
  - "The present document specifies..."
  - "The present document establishes..."
  - "The present document gives guidelines for..."

### 6.1.6 References (Clause 2)

- Split into: **2.1 Normative references** and **2.2 Informative references**
- Format: `[n] 3GPP TS 21.299 (V1.1): "Title".`
- Do NOT reference internal working documents (TDocs, meeting reports, internal TRs)
- If reference removed under change control: replace with `[void]`

### 6.1.7 Terms (Clause 3.1)

- Term in **bold**, lowercase (unless always capitalised)
- Followed by colon, space, definition
- Ordered alphabetically unless logical grouping required
- Example: **requirement:** a provision that conveys criteria to be fulfilled

### 6.1.9 Abbreviations (Clause 3.3)

- Listed alphabetically
- Contains all abbreviations used in the document
- Separated from full term with a tab

### 6.5.1 Notes and Examples

- Notes and examples are **informative only** - shall not contain requirements
- Single note: `NOTE:` (uppercase)
- Multiple notes: `NOTE 1:`, `NOTE 2:`, etc.
- Single example: `EXAMPLE:`
- Multiple examples: `EXAMPLE 1:`, `EXAMPLE 2:`, etc.

---

## Clause 6.6: Common Rules and Elements

### 6.6.4 Figures

**Numbering options:**
- Sequential throughout document: Figure 1, Figure 2...
- Clause-based: Figure 7.3.2-1 (first figure in clause 7.3.2)

**Title:** Below the figure
- Format: `Figure 6.2.3-1: Title text`

### 6.6.5 Tables

**Numbering:** Same options as figures (sequential or clause-based)

**Title:** Above the table
- Format: `Table 6.2.3-1: Title text`

**Notes to tables:**
- Located within the table frame (merged cell at bottom)
- Separate numbering sequence per table

### 6.6.6 References

**Internal references (within same document):**
- "see clause 6.2.3" (lowercase 'clause' mid-sentence)
- "see annex A" (lowercase 'annex' mid-sentence)
- "see table 6.2.3-1" or "see figure 6.2.3-1"
- "Clause 1 specifies..." (capitalised at sentence start)

**External references:**
- "in accordance with TS 21.299 [n]" (with reference number)
- Non-specific: implicitly refers to latest version in same Release

**Prohibited:**
- "see section 4" (use "clause")
- "the table below" (use explicit reference)
- Page number references

### 6.6.7 Numbers and Numerical Values

**Decimal separator:** Point (.) or comma (,) - be consistent throughout document

**Thousands separator:** Space or none - NEVER comma
- Correct: 1000 or 1 000
- Wrong: 1,000

**Ranges:** En-dash (–) or "to"
- Correct: "10–20" or "10 to 20"
- Wrong: "10-20" (hyphen)

**Units:** Non-breaking space between number and unit
- Correct: "100 ms", "5 s", "10 MHz", "5 %"
- Wrong: "100ms", "5s", "10MHz"

---

## Annex E: Verbal Forms for Expression of Provisions

### Table E.1: Requirement

| Verbal form    | Meaning | Equivalent expressions (exceptional use) |
|----------------|---------|------------------------------------------|
| **shall**      | Absolute requirement | is to, is required to, has to, only...is permitted, it is necessary |
| **shall not**  | Absolute prohibition | is not allowed/permitted/acceptable, is required to be not |

**Do not use:**
- "must" (reserved for external quotes)
- "may not" to express prohibition

### Table E.2: Recommendation

| Verbal form      | Meaning | Equivalent expressions |
|------------------|---------|------------------------|
| **should**       | Recommended but not required | it is recommended that, ought to |
| **should not**   | Deprecated but not prohibited | it is not recommended that, ought not to |

### Table E.3: Permission

| Verbal form  | Meaning | Equivalent expressions |
|--------------|---------|------------------------|
| **may**      | Permitted/optional | is permitted, is allowed, is permissible |
| **need not** | No obligation | it is not required that, no...is required |

**Do not use:**
- "can" instead of "may" for permission
- "possible/impossible" in this context

### Table E.4: Possibility and Capability

| Verbal form | Meaning | Equivalent expressions |
|-------------|---------|------------------------|
| **can**     | Capability/possibility | be able to, there is a possibility of, it is possible to |
| **cannot**  | Inability/impossibility | be unable to, there is no possibility of, it is not possible to |

### Table E.5: Inevitability (External Behaviour)

| Verbal form  | Usage |
|--------------|-------|
| **will**     | Future fact (not requirement) - behaviour outside document scope |
| **will not** | Negative future fact |

Example: "The terminal **shall** send a TIMEOUT message. The network **will** respond with an ACKNOWLEDGE."

### Table E.6: Fact

| Verbal form | Usage |
|-------------|-------|
| **is/are**  | Statements of present fact |

**Do not use** present indicative for expressing requirements.

---

## Common Editorial Errors Summary

| Error | Correction | Rule |
|-------|------------|------|
| "must support" | "shall support" | TR 21.801 Annex E |
| "has to be" | "shall be" | TR 21.801 Annex E |
| "can be used" (permission) | "may be used" | TR 21.801 Annex E |
| "See Clause 6.2" | "see clause 6.2" | Lowercase mid-sentence |
| "see section 4" | "see clause 4" | 3GPP uses "clause" |
| "100ms" | "100 ms" | Space before unit |
| "1,000" | "1000" or "1 000" | No comma for thousands |
| "10-20" (hyphen) | "10–20" (en-dash) | Range notation |
| Text between heading and subheading | Move to "x.1 General" | Hanging paragraph |
| Annex without label | Add "(normative)" or "(informative)" | TR 21.801 clause 5.2.6 |
