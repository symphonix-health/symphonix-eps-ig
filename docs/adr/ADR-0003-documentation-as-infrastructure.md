# ADR-0003: Documentation as Infrastructure

## Status
Accepted

## Date
2026-04-24

## Context
AI coding agents perform significantly better when codified context
(conventions, patterns, constraints) is available. Without documentation,
agents reinvent patterns, violate constraints, and produce inconsistent code.

## Decision
Generate documentation artifacts at plan time (not post-hoc):
- REQUIREMENTS.md before implementation begins
- DESIGN-*.md and ADR-*.md before engineers start coding
- TEST_STRATEGY.md before tests are written
- DEPLOYMENT.md and OPERATIONS.md before release

## Rationale
- Codified Context (arXiv 2602.20478) built 108K-line system with Claude Code
  using documentation-as-infrastructure approach
- CLAUDE.md conventions prevent 80%+ of common coding errors
- Pre-generated docs ensure engineers have context before they start

## Consequences

### Positive
- Engineers have full context before implementation
- Documentation stays synchronized with code (generated from same plan)
- IEEE compliance artifacts produced automatically

### Negative
- Plan phase takes longer (document generation overhead)
- Generated docs need human refinement for nuance
- Template-based docs may miss project-specific concerns

## References
- Codified Context (arXiv 2602.20478)
- IEEE 29148 (Requirements), IEEE 1016 (Design), IEEE 829 (Test Documentation)
