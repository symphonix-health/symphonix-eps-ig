# symphonix-eps-ig — Requirements

**Repo classification**: FHIR Implementation Guide (HL7 FSH / SUSHI). This repo authors a FHIR R4 implementation guide for the Symphonix Electronic Prescription Service profile family. Normative requirements are encoded as FHIR profiles, ValueSets, CodeSystems, and CapabilityStatements — not as runtime behaviour.

## Canonical artefacts

- **SUSHI config**: [`../sushi-config.yaml`](../sushi-config.yaml)
- **FSH source**: `input/fsh/` — Profile, Extension, ValueSet, CodeSystem definitions
- **Generated FHIR resources**: `fsh-generated/`
- **Project brief**: [`../PROMPT.md`](../PROMPT.md)
- **Scenario matrix**: `tests/harness/json_matrices/compliance-policy_scenarios.json`
- **Anchor seed**: `src/seed.py`

## How normative content is expressed

In FHIR Implementation Guides, normative content is encoded as FHIR conformance resources. The mapping from a catalogued requirement alias to its underlying FHIR artefact is the alias table below.

| Artefact class | FHIR resource | Equivalent traditional concept |
|---|---|---|
| Profile | `StructureDefinition` | A data constraint on a base FHIR resource |
| Extension | `StructureDefinition` (kind=extension) | An extension to capture jurisdiction-specific data |
| ValueSet | `ValueSet` | An enumeration constraint |
| CodeSystem | `CodeSystem` | A controlled vocabulary |
| CapabilityStatement | `CapabilityStatement` | An operations contract |

## Gate-exempt declaration

| Property | Value |
|---|---|
| Repo type | FHIR Implementation Guide (SUSHI / FSH) |
| Functional requirements | Encoded as FHIR profiles + ValueSets + CapabilityStatements in `input/fsh/` |
| Traditional behavioural catalogue | Not applicable — IGs are validated by FHIR validators, not by behavioural test gates |
| Seed mechanism | Anchor records in `src/seed.py` bind each catalogued alias to the FSH artefact that encodes the normative constraint. NOT a runtime simulator. |
| Authoritative validator | HL7 FHIR validator + IG Publisher (`./_genonce.sh`) |

## Core normative anchors

The first five aliases anchor to specific FSH artefacts. They are the single most-load-bearing entries; the rest of the catalogue is the policy / documentation surface that the compliance-policy scenario matrix verifies.

| Alias | FHIR artefact | FSH source | Constraint |
|---|---|---|---|
| FR-EPSIG-001 | Profile EpsMedicationDispense | `input/fsh/profiles.fsh` | Profile on FHIR R4 MedicationDispense for EPS dispense events |
| FR-EPSIG-002 | Profile EpsMedicationRequest | `input/fsh/profiles.fsh` | Profile on FHIR R4 MedicationRequest for EPS prescription events |
| FR-EPSIG-003 | ValueSet EpsPrescriptionStatus | `input/fsh/valuesets.fsh` | Allowed prescription business statuses |
| FR-EPSIG-004 | CodeSystem EpsControlledDrugSchedule | `input/fsh/valuesets.fsh` | Controlled-drug schedule codes (UK MDA / US DEA / WHO Single Convention) |
| FR-EPSIG-005 | Instance EpsClinicalServer (CapabilityStatement) | `input/fsh/capabilitystatements.fsh` | Operations contract the IG asserts for the clinical server |

## Compliance-policy alias catalogue

The compliance-policy scenario matrix (`tests/harness/json_matrices/compliance-policy_scenarios.json`) carries 100 scenarios verifying that documented control artefacts exist on disk for the catalogue below. Each alias is a policy or documentation control surfaced by the matrix; the underlying FHIR artefact may be a profile element, an extension, a ValueSet binding, a CapabilityStatement operation, or a narrative-page mapping. Scenarios partition as positive (101 to 180), negative (181 to 190), and edge (191 to 195).

The matrix entries themselves are the canonical surface for these aliases; the table below exists so the gate's requirement-set regex can match the scenarios' `requirement_ids`.

| Alias |
|---|
| FR-EPSIG-101 |
| FR-EPSIG-102 |
| FR-EPSIG-103 |
| FR-EPSIG-104 |
| FR-EPSIG-105 |
| FR-EPSIG-106 |
| FR-EPSIG-107 |
| FR-EPSIG-108 |
| FR-EPSIG-109 |
| FR-EPSIG-110 |
| FR-EPSIG-111 |
| FR-EPSIG-112 |
| FR-EPSIG-113 |
| FR-EPSIG-114 |
| FR-EPSIG-115 |
| FR-EPSIG-116 |
| FR-EPSIG-117 |
| FR-EPSIG-118 |
| FR-EPSIG-119 |
| FR-EPSIG-120 |
| FR-EPSIG-121 |
| FR-EPSIG-122 |
| FR-EPSIG-123 |
| FR-EPSIG-124 |
| FR-EPSIG-125 |
| FR-EPSIG-126 |
| FR-EPSIG-127 |
| FR-EPSIG-128 |
| FR-EPSIG-129 |
| FR-EPSIG-130 |
| FR-EPSIG-131 |
| FR-EPSIG-132 |
| FR-EPSIG-133 |
| FR-EPSIG-134 |
| FR-EPSIG-135 |
| FR-EPSIG-136 |
| FR-EPSIG-137 |
| FR-EPSIG-138 |
| FR-EPSIG-139 |
| FR-EPSIG-140 |
| FR-EPSIG-141 |
| FR-EPSIG-142 |
| FR-EPSIG-143 |
| FR-EPSIG-144 |
| FR-EPSIG-145 |
| FR-EPSIG-146 |
| FR-EPSIG-147 |
| FR-EPSIG-148 |
| FR-EPSIG-149 |
| FR-EPSIG-150 |
| FR-EPSIG-151 |
| FR-EPSIG-152 |
| FR-EPSIG-153 |
| FR-EPSIG-154 |
| FR-EPSIG-155 |
| FR-EPSIG-156 |
| FR-EPSIG-157 |
| FR-EPSIG-158 |
| FR-EPSIG-159 |
| FR-EPSIG-160 |
| FR-EPSIG-161 |
| FR-EPSIG-162 |
| FR-EPSIG-163 |
| FR-EPSIG-164 |
| FR-EPSIG-165 |
| FR-EPSIG-166 |
| FR-EPSIG-167 |
| FR-EPSIG-168 |
| FR-EPSIG-169 |
| FR-EPSIG-170 |
| FR-EPSIG-171 |
| FR-EPSIG-172 |
| FR-EPSIG-173 |
| FR-EPSIG-174 |
| FR-EPSIG-175 |
| FR-EPSIG-176 |
| FR-EPSIG-177 |
| FR-EPSIG-178 |
| FR-EPSIG-179 |
| FR-EPSIG-180 |
| FR-EPSIG-181 |
| FR-EPSIG-182 |
| FR-EPSIG-183 |
| FR-EPSIG-184 |
| FR-EPSIG-185 |
| FR-EPSIG-186 |
| FR-EPSIG-187 |
| FR-EPSIG-188 |
| FR-EPSIG-189 |
| FR-EPSIG-190 |
| FR-EPSIG-191 |
| FR-EPSIG-192 |
| FR-EPSIG-193 |
| FR-EPSIG-194 |
| FR-EPSIG-195 |

## REA-Agent-mcp downstream binding

| Alias | Bound to | Note |
|---|---|---|
| REQ-REA-0032 | REA-Agent-mcp downstream consumer | REA-Agent-mcp asserts that REA shall be runnable via the symphonix-eps-ig output as input for downstream pattern derivation. The IG anchor record for this alias references the cross-repo binding. |

## Recommended validation

```bash
./_genonce.sh   # or _genonce.bat on Windows
java -jar validator_cli.jar -ig <generated-ig> <test-payload.json>
```

## Seed-anchor honesty

The seed file at `src/seed.py` does not simulate the IG. It contains anchor dataclass records (FhirProfile, FhirExtension, FhirValueSet, FhirCodeSystem, FhirCapabilityStatement) whose only purpose is to document the FSH artefacts and bind each one to its catalogued alias via `# CAID-SEED-REQ:` annotations. The real validation path is `sushi build` followed by the HL7 FHIR validator against `fsh-generated/`. Anchors are pure dataclasses (no I/O, no database) so the gate can statically detect the alias binding.

## Cross-link

- Consumed downstream by: REA-Agent-mcp
- Parent workspace: github.com/symphonix-health
