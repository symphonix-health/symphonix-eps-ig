# Repository assurance pack

- Repository: `symphonix-eps-ig`
- Verdict: `BLOCKED`
- Requirements: `134`
- Matrix files: `3`
- Matrix rows: `334`
- Scenario execution: `BLOCKED`

| Domain | Status | Gaps | Evidence |
| --- | --- | --- | --- |
| requirements_completeness | PASS | 0 | tests/harness/requirements_matrix.json<br>tests/harness/healthcare_requirements_superset.json<br>docs/specifications/functional-requirements.md<br>docs/specifications/non-functional-requirements.md |
| requirements_traceability | PASS | 0 | tests/harness/requirements_matrix.json<br>docs/specifications/seeded-requirement-traceability.md<br>tests/harness/reduced_json_matrices/*.14col.json |
| canonical_use_case_alignment | PASS | 0 | tests/harness/reduced_json_matrices/*.14col.json<br>tests/harness/requirements_matrix.json |
| implementation_alignment | PASS | 0 | seeded_alignment_trace.py<br>seed_data/seeded_requirement_traceability.json<br>docs/specifications/design-specification.md |
| testing_completeness | BLOCKED | 1 | tests/test_requirement_acceptance_alignment.py<br>tests/test_specification_alignment.py<br>tests/test_acceptance_alignment.py<br>tests/harness/reduced_json_matrices/*.14col.json |
| documentation_completeness | BLOCKED | 6 | README.md<br>docs/specifications |
| healthcare_superset_validation | BLOCKED | 2 | tests/harness/healthcare_requirements_superset.json<br>tests/harness/requirements_matrix.json<br>docs/specifications |
| repository_seeding_completion | BLOCKED | 3 | seed_data<br>seeded_alignment_trace.py<br>tests/harness/persona_journeys<br>tests/harness/browser_states<br>tests/harness/signalbox |
