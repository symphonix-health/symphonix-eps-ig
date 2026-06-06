# Design specification

Repository: `symphonix-eps-ig`.

## Purpose

This design specification is reverse-engineered from the repo codebase and aligned to the functional and non-functional requirement sets. It uses the REA Agent as a requirements-quality feedback source and defines the product, workflow, interface, and safety constraints that must remain consistent with the canonical use-case matrices.

## Reverse-engineered codebase profile

- Package or project name: `symphonix-eps-ig`
- Description evidence: Symphonix EPS Implementation Guide
- Observed surfaces: documentation, seeded_data, workflow_or_matrix.
- Observed frameworks and tools: pytest, ruff.

Observed implementation evidence:
- `conftest.py`
- `seeded_alignment_trace.py`
- `src/__init__.py`
- `src/seed.py`

## Requirement alignment

- Total requirement IDs: 134.
- Functional requirement IDs: 113.
- Non-functional requirement IDs: 21.
- Canonical use-case matrix: `tests/harness/reduced_json_matrices/seeded_alignment_trace.14col.json`.
- Traceability test: `tests/test_specification_alignment.py`.

The design must not introduce UI, API, workflow, data, or documentation behaviours that are absent from the requirement set or canonical use-case matrix. New behaviours require a requirement ID, a use-case row, implementation evidence, seeded evidence where applicable, and a test.

## Interaction and workflow design

- Clinical and operational workflows must answer provenance, confidence, and next action clearly.
- Persona, tenant, care-setting, jurisdiction, and role variation must be handled by configurable profiles rather than hard-coded assumptions.
- Critical clinical safety states must use icon, label, and visual weight; color alone is not sufficient.
- Any patient-facing or clinician-facing surface must preserve keyboard operation, readable density, and explicit error recovery.
- Documentation-only repos must apply the same information architecture: source evidence, requirement IDs, use cases, verification, and operational ownership.
- REA self-improvement findings must feed back into requirement scope, requirement wording, use-case coverage, and traceability tests.

## Symphonix Health design constraints

- Use a sober technical visual model with dark indigo-violet, teal, blue, green, amber, and purple accents.
- Reserve rainbow treatment for the Symphonix ECG or thin evidence accents; do not use it as a general background.
- Use layered diagrams and cards to explain data flow, standardization, intelligence, implementation, evaluation, and governance.
- Keep clinical governance visible in architecture and workflow documentation.
- Do not rely on stock imagery or decorative illustrations for inspectable system behaviour.

## Safety and governance design

- Protected health data, role permissions, audit events, and seeded personas must use real internal service paths when the repo owns them.
- Internal fakes, mocks, or placeholder backends are not accepted as readiness evidence.
- External service doubles are allowed only when named as external contract substitutes and excluded from direct internal readiness claims.
- Observability evidence must come from real emitted logs, metrics, traces, dashboards, reports, or documented operational outputs where the repo owns runtime behaviour.

## Change control

A design change is complete only when this specification, the FR/NFR specifications, the architecture specification, canonical matrices, and tests continue to agree on the same requirement and use-case set.
