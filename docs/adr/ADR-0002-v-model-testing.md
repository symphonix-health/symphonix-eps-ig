# ADR-0002: V-Model Testing Strategy

## Status
Accepted

## Date
2026-04-24

## Context
Verification must trace from requirements through implementation to ensure
complete coverage. Ad hoc testing leaves gaps that surface in production.

## Decision
Adopt V-model testing with 4 verification levels:
- Level 4 (Unit): Engineer self-verification during implementation
- Level 3 (Integration): Manager runs after merge
- Level 2 (System): Computer-use browser verification
- Level 1 (Acceptance): Use case scenario validation against requirements

Test scenarios use BulletTrain 14-column canonical format for parametric
loading by pytest harness.

## Rationale
- V-model ensures bidirectional traceability (requirements <-> tests)
- 14-column format enables automated matrix-driven testing (100K+ scenarios
  proven at scale in BulletTrain)
- Computer-use verification catches visual/interaction bugs missed by API tests
- Agentic Testing (arXiv 2601.02454) shows closed-loop test agents outperform
  static test suites

## Consequences

### Positive
- 100% requirements coverage verifiable via traceability matrix
- Test matrices reusable across environments (dev, staging, prod)
- Visual verification via browser catches UI regressions

### Negative
- Initial overhead to define requirements and test matrices
- Computer-use verification slower than API-only testing
- Matrix maintenance cost as requirements evolve

## References
- IEEE 29119: Software Testing Standard
- BulletTrain 14-column canonical test matrix format
- Agentic Testing (arXiv 2601.02454)
