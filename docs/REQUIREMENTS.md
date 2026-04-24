# Software Requirements Specification

**Project:** symphonix-eps-ig
**Type:** spring-service
**Version:** 1.0
**Date:** 2026-04-24
**Standard:** IEEE 29148:2018 / IEEE 830
**Status:** Draft

---

## 1. Introduction

### 1.1 Purpose
This document specifies the software requirements for symphonix-eps-ig.
It serves as the primary input for design, implementation, and verification.

### 1.2 Scope
# Symphonix EPS Implementation Guide (symphonix-eps-ig)

Fills the CAID Requirement Prompt Template. The deliverable is a **FHIR R4 Implementation Guide** (not an application) used as the shared contract between the `etps` transport simulator and the `eps` clinical-workflow simulator, both onboarded onto BulletTrain.

## 1. What are you building? [MANDATORY]

A **HL7 FHIR R4 Implementation Guide** — `symphonix.eps.ig` — authored in **SUSHI / FSH** and published as a static HTML IG via the **HL7 IG Publisher**. The IG defines every wire shape that the `etps` and `eps` simulators must agree on, anchored to NHS Digital's EPS FHIR guides and IHE's Medication Prescription and Dispense (MPD, FHIR-era successor to CMPD) profile family so the contract is globally portable, not UK-only.

Scope of deliverables:

1. **FSH sources** under `input/fsh/`:
   - StructureDefinitions (profiles) on: `MedicationRequest`, `MedicationDispense`, `MedicationAdministration`, `Task` (workflow state machine), `Provenance` (signed-bundle chain), `Patient`, `Practitioner`, `PractitionerRole`, `Organization`, `Bundle` (message + transaction), `MessageHeader`, `AuditEvent`.
   - Extensions: nomination (nominated dispenser), repeat-dispensing issue-number, controlled-drug schedule, dose-band-limit (paediatric), allergen-group, hash-chain-link (audit).
   - ValueSets + CodeSystems: `eps-prescription-status`, `eps-dispense-status`, `eps-alert-severity` (hard-stop / advisory / info), `eps-controlled-drug-schedule`, `eps-cancellation-reason`, `eps-nomination-type`. Bind to SNOMED CT, dm+d (UK), RxNorm (US), ATC (WHO) using `preferred`/`extensible` bindings where portability matters.
   - Example instances under `input/examples/`: signed prescription bundle (happy-path), dispense notification, cancel race (prescriber cancel arriving after dispense), repeat-dispensing issue #3 of 6, paediatric weight-based dose, controlled-drug Schedule 2 bundle, discharge push to community pharmacy, offline-queued dispense.
2. **SUSHI config** — `sushi-config.yaml` with package id `symphonix.eps.ig`, canonical URL `https://symphonix.health/fhir/eps`, FHIR 4.0.1, dependency on `hl7.fhir.uv.ips` (International Patient Summary) and `hl7.fhir.uv.pharm-mpd` where available.
3. **Narrative pages** in `input/pagecontent/`: Home, Overview, Bounded Contexts (ETPS transport vs EPS clinical), Security (digital signatures, JWS envelope, hash-chain audit), Workflow (state machines drawn as Mermaid sequence diagrams), Terminology Binding Strategy, Safety (DCB0129 / DCB0160 mapping + top-10 pain-point controls), Global Deployment Notes (dm+d / RxNorm / ATC mapping), Conformance (CapabilityStatement references).
4. **CapabilityStatements**: `etps-transport-server` (signed-bundle ingest + tracker read API), `eps-clinical-server` (prescribe/dispense/repeat endpoints + CDS), `etps-dispenser-client`, `eps-prescriber-client`.
5. **Tooling**: `_genonce.sh` / `_genonce.bat` to run the IG Publisher locally; `_updatePublisher.sh` to fetch latest; `pyproject.toml` with `pytest` fixtures that import the `input/examples/*.json` and validate them against the published profiles using `fhir.resources` + `fhirpathpy`.
6. **CI workflow** — `.github/workflows/ig-build.yml` that runs SUSHI + the IG Publisher on every push and fails on any `fatal` or `error` output.
7. **README.md** with (a) how to consume the IG as a dependency from Python and TS simulators, (b) the release-and-tagging policy, (c) the compliance surface (DCB0129 risk items, DTAC alignment, GDPR Art 30), (d) research citations.

**Out of scope**: any application code, database, or UI. This is a publication artefact only.

## 2. Who are the users? [MANDATORY]

- **Simulator engineers** (primary) — backend/frontend developers of `etps` and `eps` who need canonical JSON schemas, code-gen artefacts, and example fixtures to test against.
- **Integration partners** (secondary) — other BulletTrain simulators (pharmacy-system, provider-portal, citizen-portal) that must understand the EPS contract.
- **Clinical safety officers** — DCB0129 / DCB0160 authors who must link safety cases to specific profile / ValueSet entries.
- **External conformance testers** — teams running Inferno-style validators.

## 3. What platform? [MANDATORY]

- **FHIR Shorthand (FSH) + SUSHI** (npm package `fsh-sushi`) as the authoring layer.
- **HL7 IG Publisher** (Java JAR auto-downloaded) as the build layer.
- **Python 3.12** harness for validation tests (`fhir.resources` 7.1+, `fhirpathpy`, `pytest`).
- **GitHub Actions** for CI.
- Published as static HTML to `output/` (gitignored), deployable to GitHub Pages via the `gh-pages` branch.
- Consumable from Python via `pip install fhir.resources` + downloading StructureDefinitions, and from TypeScript via `@types/fhir` + the published `package.tgz`.

## 4. What data? [MANDATORY]

FHIR resource profiles (no persistent user data; the IG is definitional).

Core resources profiled:
- `MedicationRequest` (the prescription)
- `MedicationDispense` (the fill / claim)
- `MedicationAdministration` (hospital inpatient charting — optional profile)
- `Task` (workflow state: `draft | requested | received | accepted | rejected | ready | in-progress | on-hold | failed | completed | cancelled`; `businessStatus` drives EPS-specific sub-states `signed | released | downloaded | partially-dispensed | claimed | expired`).
- `Provenance` — digital-signature envelope, `signature.type = 1.2.840.10065.1.12.1.5` (author signature), `signature.data` holds detached JWS.
- `Patient` — NHS Number + globally-generic `MedicalRecordNumber` identifier slices.
- `Practitioner` + `PractitionerRole` — prescriber identity assurance (CIS2 / OpenID Connect sub, eIDAS, DEA-number for US).
- `Organization` — dispensing org (ODS code slice + globally-generic `OrganizationNPI` / WHO facility-code slices).
- `Bundle` — both `message` and `transaction` modes.
- `MessageHeader` — ETPS routing header (idempotency key, replay-token, prior-id on retransmits).
- `AuditEvent` — aligned with IHE ATNA + CAID `HealthcareAuditTrail` hash-chain extension.

Example instances seed real pharmacology, not lorem-ipsum:
- Amoxicillin 500mg caps × 21 (RxNorm 723,ATC J01CA04, dm+d VMP 39113611000001104, SNOMED CT 27658006)
- Methylphenidate 10mg (Schedule 2 controlled drug; UK MDA Sch 2)
- Paracetamol 500mg (duplicate-therapy reference case — the Queen Elizabeth coroner PFD)
- Penicillin-V 250mg (allergy-disambiguation reference case — NatPSA Nov 2025)
- Oral paediatric ibuprofen 100mg/5mL weight-based suspension

## 5. What can users do? [MANDATORY]

Functional requirements — since this is an IG the "users" are the consumers (simulator engineers and validators):

1. **Download the published IG** from GitHub Pages and browse the human-readable artefact index, StructureDefinition detail pages, ValueSet expansions, and example Bundles.
2. **Consume the IG as a dependency** — Python simulators `import fhir.resources` and load the published StructureDefinition JSON at startup; TS simulators use `openapi-typescript` / generated types.
3. **Validate a candidate Bundle** against the IG — both via the official Java validator and via the Python `fhir.resources` + `fhirpathpy` harness included in `tests/`.
4. **See a sequence diagram for each core workflow** (signed prescription → transport → dispense → claim; cancel race; repeat-dispensing issues; paediatric safety override; discharge push; offline store-and-forward).
5. **Cross-reference each profile with an authoritative external source** (NHS Digital EPS FHIR, IHE MPD, WHO DAKs, SNOMED CT) via clickable links on the narrative pages.
6. **Trace every profile back to a safety concern** — the IG's Safety page maps each of the top-10 pain-point controls (see NFR §6f) to the StructureDefinition element that enforces it.

Acceptance criteria (author in Given/When/Then):
- Given the IG source checked out, When `./_genonce.sh` runs, Then SUSHI emits zero errors and the IG Publisher emits zero `fatal` / `error` messages and produces `output/index.html`.
- Given the published IG, When the Java validator runs against each `input/examples/*.json`, Then every example validates successfully with zero errors.
- Given the Python harness `pytest tests/test_profiles.py`, When it validates every example against its declared profile, Then all tests pass.
- Given a consumer Python app, When it installs the published NPM package tarball (converted to Python package) and loads a StructureDefinition, Then `resource_type` equals `StructureDefinition` and `url` matches the canonical URL.
- Given the Safety page, When a reader clicks the "penicillin / penicillamine allergy" control, Then the page anchors to the `allergen-group` extension's StructureDefinition and renders the NHSE NatPSA URL.

## 6. Non-Functional Requirements [MANDATORY]

### 6a. Performance
- IG Publisher build under 6 minutes on a 4-core CI runner.
- SUSHI compile under 30 seconds.

### 6b. Security & Auth
- All signed-bundle examples MUST include a `Provenance.signature` with either a JWS detached signature (default, global) or an XAdES payload (EU-eIDAS-QES deployments). Document both binding profiles.
- CapabilityStatements MUST reference SMART App Launch 2.0 + OpenID Connect (with Symphonix CIS2-analogue extension points).
- No PHI in any example bundle — synthetic identifiers only.

### 6c. Accessibility
- Published HTML must achieve WCAG 2.1 AA on the home, profile, and safety pages (axe-core zero violations in CI).

### 6d. Reliability
- Every profile MUST have at least one positive example and one negative (invalid) example documented under `input/examples/negative/` with the expected validator failure messages captured in a `.expected.txt` sidecar — so consumers can build their own regression harness.

### 6e. Data Privacy
- Documentation MUST cover GDPR Art 30 register mapping, HIPAA minimum-necessary guidance, and POPIA Section 19 alignment. All example identifiers must be flagged non-PHI.

### 6f. Compliance + top-10 pain-point control map
Each control is expressed as a StructureDefinition element or extension that the simulators MUST honour:
1. **Allergy grouping** — `allergen-group` extension on `AllergyIntolerance.code` (binding: `eps-allergen-group` ValueSet, grouped by mechanism not alphabetical). Rationale: NHS England NatPSA Nov 2025 (penicillin / penicillamine case).
2. **Duplicate-therapy hard-stop** — `alert-severity` extension on `Task.businessStatus` with ValueSet `eps-alert-severity` including `hard-stop`. High-risk classes (paracetamol, opioids, anticoagulants, insulin) documented as MUST-hard-stop. Rationale: QE Hospital paracetamol coroner PFD 2025.
3. **Paediatric weight-mandatory** — `patient-weight` slice on `MedicationRequest.supportingInformation` with mandatory cardinality 1..1 when `subject.age < 18y`. `dose-band-limit` extension on `Dosage.doseAndRate`. Rationale: HSSIB 2024 weight-based errors report.
4. **Medical device posture** — narrative page `safety.html` maps every profile to a DCB0129 hazard line and references UK MDR 2002 § relevant to ePMA classification.
5. **Tiered alerts** — `alert-severity` ValueSet carries `hard-stop | advisory | info`; CapabilityStatements REQUIRE per-tenant override-rate telemetry operations (`$alert-metrics`).
6. **Structured Dosage** — `Dosage` profile REQUIRES `doseAndRate[0].doseQuantity` (UCUM-coded) OR `doseAndRate[0].doseRange`; free-text `Dosage.text` allowed only alongside structured `additionalInstruction`.
7. **Discharge push** — a `DischargePushBundle` profile (message Bundle) carrying `MedicationStatement` to community pharmacy + GP with positive-ack required within 24 h (documented as operator SLA, not wire-level timeout).
8. **No LASA pick-lists** — narrative page `safety.html` MANDATES that simulator UIs render medication options grouped by mechanism + Tall-Man case; the IG provides reference `pick-list-ordering` ValueSets.
9. **Offline idempotent dispense** — `MessageHeader.meta.tag` includes `idempotency-key` binding; `MedicationDispense` includes `priorPrescription` reference + `Task.replaces` to make replays safe.
10. **End-to-end tracker** — a separate `TrackerQueryBundle` (search-set Bundle) profile carrying prescription state + dispense state + claim state + hash-chain audit anchor hash, retrievable by prescriber, dispenser, AND patient.

**Research & standards citations** (MUST appear in `README.md` and `input/pagecontent/references.md`):
- NHS Digital EPS FHIR API catalogue: https://digital.nhs.uk/developer/api-catalogue/electronic-prescription-service-fhir
- NHS Dose Syntax Implementation Guide: https://nhsconnect.github.io/Dose-Syntax-Implementation/
- IHE Pharm MPD (FHIR): https://build.fhir.org/ig/IHE/pharm-mpd/
- HL7 FHIR R4 Medications module: https://hl7.org/fhir/R4/medications-module.html
- WHO Digital Adaptation Kits overview: https://www.who.int/teams/digital-health-and-innovation/harnessing-digital-health/smart-guidelines
- NHSE NatPSA — penicillin/penicillamine allergy: https://www.england.nhs.uk/long-read/national-patient-safety-alert-harm-from-incorrect-recording-of-a-penicillin-allergy-as-a-penicillamine-allergy/
- HSSIB weight-based medication errors in children: https://www.hssib.org.uk/patient-safety-investigations/weight-based-medication-errors-in-children/investigation-report/
- QE Hospital paracetamol coroner PFD: https://pharmaceutical-journal.com/article/news/disabling-prescribing-system-alerts-may-have-led-to-hospital-paracetamol-overdose
- JAMIA 2024 CDS alert-override study: https://academic.oup.com/jamia/article/31/6/1411/7654019
- CPE EPS technical failures factsheet: https://cpe.org.uk/wp-content/uploads/2013/07/EPS-How-to-manage-EPS-technical-failures-Factsheet.pdf

Every citation MUST be verified live during the build (L-244) and marked `[unverified]` if the fetch fails; no fabricated DOIs, no future-dated preprints.

## 7. What's out of scope? [OPTIONAL]

- Runnable application code. The IG is a contract, not an executable.
- US NCPDP SCRIPT wire format — out of scope for v1; flagged as a future extension in `pagecontent/roadmap.md`.
- openEHR archetype bindings — reference-only link; no archetype authoring in v1.
- Mobile app / FHIR client SDK — lives in the consumer simulators, not the IG.

## 8. Design preference? [OPTIONAL]

- The published HTML follows the Symphonix Health brand (use the `symphonix-health-design` submodule's colour + type tokens on the home page customisations only; the rest of the IG uses the default IG Publisher template).
- Narrative pages favour short paragraphs + mermaid diagrams over prose.
- Every profile page includes a "Used by" backlink to the simulator tasks that rely on it.

## 9. Deployment? [OPTIONAL]

- GitHub repo at `https://github.com/symphonix-health/symphonix-eps-ig` (user to create; CAID just initialises a local repo + pushes when credentials are present, otherwise leaves it local).
- GitHub Pages deployment of `output/` on every `main` push via the `ig-build.yml` workflow.
- Release policy: semantic-version tags `v1.0.0` / `v1.1.0` — breaking profile changes bump major, additive value-set entries bump minor.

---

## Operating-posture reminders (CAID L-244, L-259, top-10 pain points)

- **L-244**: every paper / standard / benchmark cited in the IG narrative MUST resolve on its canonical host; flag with `[unverified]` if fetch fails; no placeholder IDs.
- **L-259**: N/A for an IG (no internal components to mock) but document that *downstream simulators* MUST NOT stub the IG-defined shapes.
- **No emoji** anywhere.
- **British English** in advisory/narrative prose; ASCII-only status markers (`[OK]`, `[FAIL]`, `[WARN]`).


**Structured breakdown** (auto-derived by Business Analyst extraction):

- **Entities:** profiled
- **Fields:** statu
- **User actions:** create, read, delete, login, schedule, notify, import, update
- **Journeys:** create profiled, read profiled, delete profiled, login profiled, schedule profiled, notify profiled, import profiled, update profiled

### 1.2.1 Prompt Trace (L-245)

The user prompt is preserved verbatim as `REQ-PROMPT-000`. Every clause of the prompt is registered as `REQ-PROMPT-NNN` with exact character offsets so every derived FR/NFR can be audited back to the clause it originated from. Research: ISO/IEC/IEEE 29148:2018 §5.2.6 (backward traceability); Abualhaija et al. RE'22 (verbatim provenance).

**Prompt coverage:** 23% (130 orphan clauses).

| REQ ID | Kind | Verbatim clause | Offsets | Derived requirements |
| --- | --- | --- | --- | --- |
| REQ-PROMPT-000 | root | # Symphonix EPS Implementation Guide (symphonix-eps-ig) Fills the CAID Requirement Prom... | full prompt | FR-001, FR-002, FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b, FR-004 |
| REQ-PROMPT-001 | clause | # Symphonix EPS Implementation Guide (symphonix-eps-ig) | 0..55 | - |
| REQ-PROMPT-002 | clause | Fills the CAID Requirement Prompt Template. | 57..100 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-003 | clause | The deliverable is a **FHIR R4 Implementation Guide** (not an application) used as the ... | 101..318 | FR-002 |
| REQ-PROMPT-004 | clause | ## 1. | 320..325 | - |
| REQ-PROMPT-005 | clause | What are you building? [MANDATORY] | 326..360 | - |
| REQ-PROMPT-006 | clause | A **HL7 FHIR R4 Implementation Guide** — `symphonix.eps.ig` — authored in **SUSHI / FSH... | 362..515 | - |
| REQ-PROMPT-007 | clause | The IG defines every wire shape that the `etps` and `eps` simulators must agree on, anc... | 516..788 | - |
| REQ-PROMPT-008 | clause | Scope of deliverables: | 790..812 | - |
| REQ-PROMPT-009 | clause | **FSH sources** under `input/fsh/`: | 817..852 | - |
| REQ-PROMPT-010 | clause | StructureDefinitions (profiles) on: `MedicationRequest`, `MedicationDispense`, `Medicat... | 858..1161 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-011 | clause | Extensions: nomination (nominated dispenser), repeat-dispensing issue-number, controlle... | 1167..1341 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-012 | clause | ValueSets + CodeSystems: `eps-prescription-status`, `eps-dispense-status`, `eps-alert-s... | 1347..1555 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-013 | clause | Bind to SNOMED CT, dm+d (UK), RxNorm (US), ATC (WHO) using `preferred`/`extensible` bin... | 1556..1675 | - |
| REQ-PROMPT-014 | clause | Example instances under `input/examples/`: signed prescription bundle (happy-path), dis... | 1681..2005 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-015 | clause | **SUSHI config** — `sushi-config.yaml` with package id `symphonix.eps.ig`, canonical UR... | 2009..2255 | FR-003 |
| REQ-PROMPT-016 | clause | **Narrative pages** in `input/pagecontent/`: Home, Overview, Bounded Contexts (ETPS tra... | 2259..2691 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-017 | clause | **CapabilityStatements**: `etps-transport-server` (signed-bundle ingest + tracker read ... | 2695..2904 | FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-018 | clause | **Tooling**: `_genonce.sh` / `_genonce.bat` to run the IG Publisher locally | 2908..2983 | - |
| REQ-PROMPT-019 | clause | `_updatePublisher.sh` to fetch latest | 2985..3022 | - |
| REQ-PROMPT-020 | clause | `pyproject.toml` with `pytest` fixtures that import the `input/examples/*.json` and val... | 3024..3191 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-021 | clause | **CI workflow** — `.github/workflows/ig-build.yml` that runs SUSHI + the IG Publisher o... | 3195..3338 | FR-001, FR-004 |
| REQ-PROMPT-022 | clause | **README.md** with (a) how to consume the IG as a dependency from Python and TS simulat... | 3342..3571 | - |
| REQ-PROMPT-023 | clause | **Out of scope**: any application code, database, or UI. | 3573..3629 | FR-002, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-024 | clause | This is a publication artefact only. | 3630..3666 | - |
| REQ-PROMPT-025 | clause | ## 2. | 3668..3673 | - |
| REQ-PROMPT-026 | clause | Who are the users? [MANDATORY] | 3674..3704 | - |
| REQ-PROMPT-027 | clause | **Simulator engineers** (primary) — backend/frontend developers of `etps` and `eps` who... | 3708..3882 | FR-004 |
| REQ-PROMPT-028 | clause | **Integration partners** (secondary) — other BulletTrain simulators (pharmacy-system, p... | 3885..4042 | - |
| REQ-PROMPT-029 | clause | **Clinical safety officers** — DCB0129 / DCB0160 authors who must link safety cases to ... | 4045..4168 | - |
| REQ-PROMPT-030 | clause | **External conformance testers** — teams running Inferno-style validators. | 4171..4245 | FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-031 | clause | ## 3. | 4247..4252 | - |
| REQ-PROMPT-032 | clause | What platform? [MANDATORY] | 4253..4279 | - |
| REQ-PROMPT-033 | clause | **FHIR Shorthand (FSH) + SUSHI** (npm package `fsh-sushi`) as the authoring layer. | 4283..4365 | - |
| REQ-PROMPT-034 | clause | **HL7 IG Publisher** (Java JAR auto-downloaded) as the build layer. | 4368..4435 | FR-002 |
| REQ-PROMPT-035 | clause | **Python 3.12** harness for validation tests (`fhir.resources` 7.1+, `fhirpathpy`, `pyt... | 4438..4531 | FR-004 |
| REQ-PROMPT-036 | clause | **GitHub Actions** for CI. | 4534..4560 | - |
| REQ-PROMPT-037 | clause | Published as static HTML to `output/` (gitignored), deployable to GitHub Pages via the ... | 4563..4668 | - |
| REQ-PROMPT-038 | clause | Consumable from Python via `pip install fhir.resources` + downloading StructureDefiniti... | 4671..4831 | - |
| REQ-PROMPT-039 | clause | ## 4. | 4833..4838 | - |
| REQ-PROMPT-040 | clause | What data? [MANDATORY] | 4839..4861 | - |
| REQ-PROMPT-041 | clause | FHIR resource profiles (no persistent user data | 4863..4910 | - |
| REQ-PROMPT-042 | clause | the IG is definitional). | 4912..4936 | - |
| REQ-PROMPT-043 | clause | Core resources profiled: | 4938..4962 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-044 | clause | `MedicationRequest` (the prescription) | 4965..5003 | - |
| REQ-PROMPT-045 | clause | `MedicationDispense` (the fill / claim) | 5006..5045 | - |
| REQ-PROMPT-046 | clause | `MedicationAdministration` (hospital inpatient charting — optional profile) | 5048..5123 | - |
| REQ-PROMPT-047 | clause | `Task` (workflow state: `draft \| requested \| received \| accepted \| rejected \| read... | 5126..5267 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-048 | clause | `businessStatus` drives EPS-specific sub-states `signed \| released \| downloaded \| pa... | 5269..5393 | - |
| REQ-PROMPT-049 | clause | `Provenance` — digital-signature envelope, `signature.type = 1.2.840.10065.1.12.1.5` (a... | 5396..5537 | - |
| REQ-PROMPT-050 | clause | `Patient` — NHS Number + globally-generic `MedicalRecordNumber` identifier slices. | 5540..5622 | - |
| REQ-PROMPT-051 | clause | `Practitioner` + `PractitionerRole` — prescriber identity assurance (CIS2 / OpenID Conn... | 5625..5747 | - |
| REQ-PROMPT-052 | clause | `Organization` — dispensing org (ODS code slice + globally-generic `OrganizationNPI` / ... | 5750..5863 | - |
| REQ-PROMPT-053 | clause | `Bundle` — both `message` and `transaction` modes. | 5866..5916 | - |
| REQ-PROMPT-054 | clause | `MessageHeader` — ETPS routing header (idempotency key, replay-token, prior-id on retra... | 5919..6014 | - |
| REQ-PROMPT-055 | clause | `AuditEvent` — aligned with IHE ATNA + CAID `HealthcareAuditTrail` hash-chain extension. | 6017..6105 | - |
| REQ-PROMPT-056 | clause | Example instances seed real pharmacology, not lorem-ipsum: | 6107..6165 | - |
| REQ-PROMPT-057 | clause | Amoxicillin 500mg caps × 21 (RxNorm 723,ATC J01CA04, dm+d VMP 39113611000001104, SNOMED... | 6168..6268 | - |
| REQ-PROMPT-058 | clause | Methylphenidate 10mg (Schedule 2 controlled drug | 6271..6319 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-059 | clause | UK MDA Sch 2) | 6321..6334 | - |
| REQ-PROMPT-060 | clause | Paracetamol 500mg (duplicate-therapy reference case — the Queen Elizabeth coroner PFD) | 6337..6423 | - |
| REQ-PROMPT-061 | clause | Penicillin-V 250mg (allergy-disambiguation reference case — NatPSA Nov 2025) | 6426..6502 | - |
| REQ-PROMPT-062 | clause | Oral paediatric ibuprofen 100mg/5mL weight-based suspension | 6505..6564 | - |
| REQ-PROMPT-063 | clause | ## 5. | 6566..6571 | - |
| REQ-PROMPT-064 | clause | What can users do? [MANDATORY] | 6572..6602 | - |
| REQ-PROMPT-065 | clause | Functional requirements — since this is an IG the "users" are the consumers (simulator ... | 6604..6717 | - |
| REQ-PROMPT-066 | clause | **Download the published IG** from GitHub Pages and browse the human-readable artefact ... | 6722..6891 | - |
| REQ-PROMPT-067 | clause | **Consume the IG as a dependency** — Python simulators `import fhir.resources` and load... | 6895..7032 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-068 | clause | TS simulators use `openapi-typescript` / generated types. | 7034..7091 | - |
| REQ-PROMPT-069 | clause | **Validate a candidate Bundle** against the IG — both via the official Java validator a... | 7095..7261 | FR-004 |
| REQ-PROMPT-070 | clause | **See a sequence diagram for each core workflow** (signed prescription → transport → di... | 7265..7366 | - |
| REQ-PROMPT-071 | clause | cancel race | 7368..7379 | - |
| REQ-PROMPT-072 | clause | repeat-dispensing issues | 7381..7405 | - |
| REQ-PROMPT-073 | clause | paediatric safety override | 7407..7433 | - |
| REQ-PROMPT-074 | clause | discharge push | 7435..7449 | - |
| REQ-PROMPT-075 | clause | offline store-and-forward). | 7451..7478 | - |
| REQ-PROMPT-076 | clause | **Cross-reference each profile with an authoritative external source** (NHS Digital EPS... | 7482..7649 | - |
| REQ-PROMPT-077 | clause | **Trace every profile back to a safety concern** — the IG's Safety page maps each of th... | 7653..7835 | - |
| REQ-PROMPT-078 | clause | Acceptance criteria (author in Given/When/Then): | 7837..7885 | FR-001, FR-002, FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b, FR-004 |
| REQ-PROMPT-079 | clause | Given the IG source checked out, When `./_genonce.sh` runs, Then SUSHI emits zero error... | 7888..8069 | FR-001, FR-002, FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b, FR-004 |
| REQ-PROMPT-080 | clause | Given the published IG, When the Java validator runs against each `input/examples/*.jso... | 8072..8222 | FR-001, FR-002, FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b, FR-004 |
| REQ-PROMPT-081 | clause | Given the Python harness `pytest tests/test_profiles.py`, When it validates every examp... | 8225..8365 | FR-001, FR-002, FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b, FR-004 |
| REQ-PROMPT-082 | clause | Given a consumer Python app, When it installs the published NPM package tarball (conver... | 8368..8597 | FR-001, FR-002, FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b, FR-004 |
| REQ-PROMPT-083 | clause | Given the Safety page, When a reader clicks the "penicillin / penicillamine allergy" co... | 8600..8804 | FR-001, FR-002, FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b, FR-004 |
| REQ-PROMPT-084 | clause | ## 6. | 8806..8811 | - |
| REQ-PROMPT-085 | clause | Non-Functional Requirements [MANDATORY] | 8812..8851 | - |
| REQ-PROMPT-086 | clause | ### 6a. | 8853..8860 | - |
| REQ-PROMPT-087 | clause | Performance | 8861..8872 | - |
| REQ-PROMPT-088 | clause | IG Publisher build under 6 minutes on a 4-core CI runner. | 8875..8932 | - |
| REQ-PROMPT-089 | clause | SUSHI compile under 30 seconds. | 8935..8966 | FR-001 |
| REQ-PROMPT-090 | clause | ### 6b. | 8968..8975 | - |
| REQ-PROMPT-091 | clause | Security & Auth | 8976..8991 | - |
| REQ-PROMPT-092 | clause | All signed-bundle examples MUST include a `Provenance.signature` with either a JWS deta... | 8994..9161 | - |
| REQ-PROMPT-093 | clause | Document both binding profiles. | 9162..9193 | - |
| REQ-PROMPT-094 | clause | CapabilityStatements MUST reference SMART App Launch 2.0 + OpenID Connect (with Symphon... | 9196..9318 | - |
| REQ-PROMPT-095 | clause | No PHI in any example bundle — synthetic identifiers only. | 9321..9379 | - |
| REQ-PROMPT-096 | clause | ### 6c. | 9381..9388 | - |
| REQ-PROMPT-097 | clause | Accessibility | 9389..9402 | - |
| REQ-PROMPT-098 | clause | Published HTML must achieve WCAG 2.1 AA on the home, profile, and safety pages (axe-cor... | 9405..9517 | - |
| REQ-PROMPT-099 | clause | ### 6d. | 9519..9526 | - |
| REQ-PROMPT-100 | clause | Reliability | 9527..9538 | - |
| REQ-PROMPT-101 | clause | Every profile MUST have at least one positive example and one negative (invalid) exampl... | 9541..9811 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-102 | clause | ### 6e. | 9813..9820 | - |
| REQ-PROMPT-103 | clause | Data Privacy | 9821..9833 | - |
| REQ-PROMPT-104 | clause | Documentation MUST cover GDPR Art 30 register mapping, HIPAA minimum-necessary guidance... | 9836..9956 | FR-BA-100a |
| REQ-PROMPT-105 | clause | All example identifiers must be flagged non-PHI. | 9957..10005 | - |
| REQ-PROMPT-106 | clause | ### 6f. | 10007..10014 | - |
| REQ-PROMPT-107 | clause | Compliance + top-10 pain-point control map Each control is expressed as a StructureDefi... | 10015..10162 | - |
| REQ-PROMPT-108 | clause | **Allergy grouping** — `allergen-group` extension on `AllergyIntolerance.code` (binding... | 10166..10325 | - |
| REQ-PROMPT-109 | clause | Rationale: NHS England NatPSA Nov 2025 (penicillin / penicillamine case). | 10326..10399 | - |
| REQ-PROMPT-110 | clause | **Duplicate-therapy hard-stop** — `alert-severity` extension on `Task.businessStatus` w... | 10403..10546 | - |
| REQ-PROMPT-111 | clause | High-risk classes (paracetamol, opioids, anticoagulants, insulin) documented as MUST-ha... | 10547..10642 | - |
| REQ-PROMPT-112 | clause | Rationale: QE Hospital paracetamol coroner PFD 2025. | 10643..10695 | - |
| REQ-PROMPT-113 | clause | **Paediatric weight-mandatory** — `patient-weight` slice on `MedicationRequest.supporti... | 10699..10911 | - |
| REQ-PROMPT-114 | clause | Rationale: HSSIB 2024 weight-based errors report. | 10912..10961 | - |
| REQ-PROMPT-115 | clause | **Medical device posture** — narrative page `safety.html` maps every profile to a DCB01... | 10965..11128 | - |
| REQ-PROMPT-116 | clause | **Tiered alerts** — `alert-severity` ValueSet carries `hard-stop \| advisory \| info` | 11132..11215 | - |
| REQ-PROMPT-117 | clause | CapabilityStatements REQUIRE per-tenant override-rate telemetry operations (`$alert-met... | 11217..11311 | FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-118 | clause | **Structured Dosage** — `Dosage` profile REQUIRES `doseAndRate[0].doseQuantity` (UCUM-c... | 11315..11437 | - |
| REQ-PROMPT-119 | clause | free-text `Dosage.text` allowed only alongside structured `additionalInstruction`. | 11439..11521 | - |
| REQ-PROMPT-120 | clause | **Discharge push** — a `DischargePushBundle` profile (message Bundle) carrying `Medicat... | 11525..11745 | FR-BA-101a |
| REQ-PROMPT-121 | clause | **No LASA pick-lists** — narrative page `safety.html` MANDATES that simulator UIs rende... | 11749..11893 | - |
| REQ-PROMPT-122 | clause | the IG provides reference `pick-list-ordering` ValueSets. | 11895..11952 | - |
| REQ-PROMPT-123 | clause | **Offline idempotent dispense** — `MessageHeader.meta.tag` includes `idempotency-key` b... | 11956..12049 | - |
| REQ-PROMPT-124 | clause | `MedicationDispense` includes `priorPrescription` reference + `Task.replaces` to make r... | 12051..12150 | - |
| REQ-PROMPT-125 | clause | **End-to-end tracker** — a separate `TrackerQueryBundle` (search-set Bundle) profile ca... | 12155..12381 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-126 | clause | **Research & standards citations** (MUST appear in `README.md` and `input/pagecontent/r... | 12383..12485 | - |
| REQ-PROMPT-127 | clause | NHS Digital EPS FHIR API catalogue: https://digital.nhs.uk/developer/api-catalogue/elec... | 12488..12607 | - |
| REQ-PROMPT-128 | clause | NHS Dose Syntax Implementation Guide: https://nhsconnect.github.io/Dose-Syntax-Implemen... | 12610..12704 | - |
| REQ-PROMPT-129 | clause | IHE Pharm MPD (FHIR): https://build.fhir.org/ig/IHE/pharm-mpd/ | 12707..12769 | - |
| REQ-PROMPT-130 | clause | HL7 FHIR R4 Medications module: https://hl7.org/fhir/R4/medications-module.html | 12772..12851 | - |
| REQ-PROMPT-131 | clause | WHO Digital Adaptation Kits overview: https://www.who.int/teams/digital-health-and-inno... | 12854..12990 | FR-003 |
| REQ-PROMPT-132 | clause | NHSE NatPSA — penicillin/penicillamine allergy: https://www.england.nhs.uk/long-read/na... | 12993..13189 | FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-133 | clause | HSSIB weight-based medication errors in children: https://www.hssib.org.uk/patient-safe... | 13192..13361 | - |
| REQ-PROMPT-134 | clause | QE Hospital paracetamol coroner PFD: https://pharmaceutical-journal.com/article/news/di... | 13364..13530 | - |
| REQ-PROMPT-135 | clause | JAMIA 2024 CDS alert-override study: https://academic.oup.com/jamia/article/31/6/1411/7... | 13533..13626 | - |
| REQ-PROMPT-136 | clause | CPE EPS technical failures factsheet: https://cpe.org.uk/wp-content/uploads/2013/07/EPS... | 13629..13767 | - |
| REQ-PROMPT-137 | clause | Every citation MUST be verified live during the build (L-244) and marked `[unverified]`... | 13769..13875 | - |
| REQ-PROMPT-138 | clause | no fabricated DOIs, no future-dated preprints. | 13877..13923 | - |
| REQ-PROMPT-139 | clause | ## 7. | 13925..13930 | - |
| REQ-PROMPT-140 | clause | What's out of scope? [OPTIONAL] | 13931..13962 | - |
| REQ-PROMPT-141 | clause | Runnable application code. | 13966..13992 | FR-002 |
| REQ-PROMPT-142 | clause | The IG is a contract, not an executable. | 13993..14033 | - |
| REQ-PROMPT-143 | clause | US NCPDP SCRIPT wire format — out of scope for v1 | 14036..14085 | - |
| REQ-PROMPT-144 | clause | flagged as a future extension in `pagecontent/roadmap.md`. | 14087..14145 | - |
| REQ-PROMPT-145 | clause | openEHR archetype bindings — reference-only link | 14148..14196 | - |
| REQ-PROMPT-146 | clause | no archetype authoring in v1. | 14198..14227 | - |
| REQ-PROMPT-147 | clause | Mobile app / FHIR client SDK — lives in the consumer simulators, not the IG. | 14230..14306 | - |
| REQ-PROMPT-148 | clause | ## 8. | 14308..14313 | - |
| REQ-PROMPT-149 | clause | Design preference? [OPTIONAL] | 14314..14343 | - |
| REQ-PROMPT-150 | clause | The published HTML follows the Symphonix Health brand (use the `symphonix-health-design... | 14347..14505 | FR-003 |
| REQ-PROMPT-151 | clause | the rest of the IG uses the default IG Publisher template). | 14507..14566 | - |
| REQ-PROMPT-152 | clause | Narrative pages favour short paragraphs + mermaid diagrams over prose. | 14569..14639 | - |
| REQ-PROMPT-153 | clause | Every profile page includes a "Used by" backlink to the simulator tasks that rely on it. | 14642..14730 | - |
| REQ-PROMPT-154 | clause | ## 9. | 14732..14737 | - |
| REQ-PROMPT-155 | clause | Deployment? [OPTIONAL] | 14738..14760 | - |
| REQ-PROMPT-156 | clause | GitHub repo at `https://github.com/symphonix-health/symphonix-eps-ig` (user to create | 14764..14849 | FR-003, FR-BA-100a, FR-BA-100b, FR-BA-101a, FR-BA-101b |
| REQ-PROMPT-157 | clause | CAID just initialises a local repo + pushes when credentials are present, otherwise lea... | 14851..14952 | - |
| REQ-PROMPT-158 | clause | GitHub Pages deployment of `output/` on every `main` push via the `ig-build.yml` workflow. | 14955..15045 | - |
| REQ-PROMPT-159 | clause | Release policy: semantic-version tags `v1.0.0` / `v1.1.0` — breaking profile changes bu... | 15048..15183 | - |
| REQ-PROMPT-160 | clause | --- | 15185..15188 | - |
| REQ-PROMPT-161 | clause | ## Operating-posture reminders (CAID L-244, L-259, top-10 pain points) | 15190..15260 | - |
| REQ-PROMPT-162 | clause | **L-244**: every paper / standard / benchmark cited in the IG narrative MUST resolve on... | 15264..15370 | - |
| REQ-PROMPT-163 | clause | flag with `[unverified]` if fetch fails | 15372..15411 | - |
| REQ-PROMPT-164 | clause | no placeholder IDs. | 15413..15432 | - |
| REQ-PROMPT-165 | clause | **L-259**: N/A for an IG (no internal components to mock) but document that *downstream... | 15435..15571 | - |
| REQ-PROMPT-166 | clause | **No emoji** anywhere. | 15574..15596 | - |
| REQ-PROMPT-167 | clause | **British English** in advisory/narrative prose | 15599..15646 | - |
| REQ-PROMPT-168 | clause | ASCII-only status markers (`[OK]`, `[FAIL]`, `[WARN]`). | 15648..15704 | - |

> **L-245 warning:** the prompt clauses listed below produced no derived requirement. If these are features the user asked for, the Business Analyst extraction silently dropped them. Refine the BA heuristics or the prompt before sign-off.

```
- REQ-PROMPT-001
- REQ-PROMPT-004
- REQ-PROMPT-005
- REQ-PROMPT-006
- REQ-PROMPT-007
- REQ-PROMPT-008
- REQ-PROMPT-009
- REQ-PROMPT-013
- REQ-PROMPT-018
- REQ-PROMPT-019
- REQ-PROMPT-022
- REQ-PROMPT-024
- REQ-PROMPT-025
- REQ-PROMPT-026
- REQ-PROMPT-028
- REQ-PROMPT-029
- REQ-PROMPT-031
- REQ-PROMPT-032
- REQ-PROMPT-033
- REQ-PROMPT-036
- REQ-PROMPT-037
- REQ-PROMPT-038
- REQ-PROMPT-039
- REQ-PROMPT-040
- REQ-PROMPT-041
- REQ-PROMPT-042
- REQ-PROMPT-044
- REQ-PROMPT-045
- REQ-PROMPT-046
- REQ-PROMPT-048
- REQ-PROMPT-049
- REQ-PROMPT-050
- REQ-PROMPT-051
- REQ-PROMPT-052
- REQ-PROMPT-053
- REQ-PROMPT-054
- REQ-PROMPT-055
- REQ-PROMPT-056
- REQ-PROMPT-057
- REQ-PROMPT-059
- REQ-PROMPT-060
- REQ-PROMPT-061
- REQ-PROMPT-062
- REQ-PROMPT-063
- REQ-PROMPT-064
- REQ-PROMPT-065
- REQ-PROMPT-066
- REQ-PROMPT-068
- REQ-PROMPT-070
- REQ-PROMPT-071
- REQ-PROMPT-072
- REQ-PROMPT-073
- REQ-PROMPT-074
- REQ-PROMPT-075
- REQ-PROMPT-076
- REQ-PROMPT-077
- REQ-PROMPT-084
- REQ-PROMPT-085
- REQ-PROMPT-086
- REQ-PROMPT-087
- REQ-PROMPT-088
- REQ-PROMPT-090
- REQ-PROMPT-091
- REQ-PROMPT-092
- REQ-PROMPT-093
- REQ-PROMPT-094
- REQ-PROMPT-095
- REQ-PROMPT-096
- REQ-PROMPT-097
- REQ-PROMPT-098
- REQ-PROMPT-099
- REQ-PROMPT-100
- REQ-PROMPT-102
- REQ-PROMPT-103
- REQ-PROMPT-105
- REQ-PROMPT-106
- REQ-PROMPT-107
- REQ-PROMPT-108
- REQ-PROMPT-109
- REQ-PROMPT-110
- REQ-PROMPT-111
- REQ-PROMPT-112
- REQ-PROMPT-113
- REQ-PROMPT-114
- REQ-PROMPT-115
- REQ-PROMPT-116
- REQ-PROMPT-118
- REQ-PROMPT-119
- REQ-PROMPT-121
- REQ-PROMPT-122
- REQ-PROMPT-123
- REQ-PROMPT-124
- REQ-PROMPT-126
- REQ-PROMPT-127
- REQ-PROMPT-128
- REQ-PROMPT-129
- REQ-PROMPT-130
- REQ-PROMPT-133
- REQ-PROMPT-134
- REQ-PROMPT-135
- REQ-PROMPT-136
- REQ-PROMPT-137
- REQ-PROMPT-138
- REQ-PROMPT-139
- REQ-PROMPT-140
- REQ-PROMPT-142
- REQ-PROMPT-143
- REQ-PROMPT-144
- REQ-PROMPT-145
- REQ-PROMPT-146
- REQ-PROMPT-147
- REQ-PROMPT-148
- REQ-PROMPT-149
- REQ-PROMPT-151
- REQ-PROMPT-152
- REQ-PROMPT-153
- REQ-PROMPT-154
- REQ-PROMPT-155
- REQ-PROMPT-157
- REQ-PROMPT-158
- REQ-PROMPT-159
- REQ-PROMPT-160
- REQ-PROMPT-161
- REQ-PROMPT-162
- REQ-PROMPT-163
- REQ-PROMPT-164
- REQ-PROMPT-165
- REQ-PROMPT-166
- REQ-PROMPT-167
- REQ-PROMPT-168
```

### 1.3 Definitions
- **FR**: Functional Requirement
- **NFR**: Non-Functional Requirement
- **UC**: Use Case
- **RTM**: Requirements Traceability Matrix
- **SUT**: System Under Test

---

## 2. Functional Requirements

### FR-001: Spring Boot project skeleton

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-001 |
| **Title** | Spring Boot project skeleton |
| **Statement** | GIVEN a new project directory, WHEN mvn compile runs, the system SHALL ensure that project compiles. |
| **Category** | functional |
| **Priority** | CRITICAL |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | Foundation |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | REQ-PROMPT-081, REQ-PROMPT-021, REQ-PROMPT-082, REQ-PROMPT-089, REQ-PROMPT-079, REQ-PROMPT-083, REQ-PROMPT-080, REQ-PROMPT-000, REQ-PROMPT-078 |

**Acceptance Criteria:**

1. **[FR001-AC01]** [Positive] [Automated] GIVEN a new project directory, WHEN mvn compile runs, THEN project compiles

### FR-002: Data persistence with JPA

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-002 |
| **Title** | Data persistence with JPA |
| **Statement** | GIVEN JPA entity definitions, WHEN application starts, the system SHALL ensure that tables auto-created. |
| **Category** | functional |
| **Priority** | CRITICAL |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | Database |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | REQ-PROMPT-141, REQ-PROMPT-081, REQ-PROMPT-082, REQ-PROMPT-034, REQ-PROMPT-079, REQ-PROMPT-083, REQ-PROMPT-080, REQ-PROMPT-023, REQ-PROMPT-000, REQ-PROMPT-003, REQ-PROMPT-078 |

**Acceptance Criteria:**

1. **[FR002-AC01]** [Positive] [Automated] GIVEN JPA entity definitions, WHEN application starts, THEN tables auto-created

### FR-003: RESTful API endpoints

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-003 |
| **Title** | RESTful API endpoints |
| **Statement** | GIVEN a running server, WHEN GET /actuator/health, the system SHALL ensure that 200 OK. |
| **Category** | functional |
| **Priority** | HIGH |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | API |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | REQ-PROMPT-081, REQ-PROMPT-082, REQ-PROMPT-150, REQ-PROMPT-030, REQ-PROMPT-079, REQ-PROMPT-156, REQ-PROMPT-083, REQ-PROMPT-017, REQ-PROMPT-080, REQ-PROMPT-131, REQ-PROMPT-000, REQ-PROMPT-015, REQ-PROMPT-078 |

**Acceptance Criteria:**

1. **[FR003-AC01]** [Positive] [Automated] GIVEN a running server, WHEN GET /actuator/health, THEN 200 OK

### FR-BA-100a: User authentication (A)

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-BA-100a |
| **Title** | User authentication (A) |
| **Statement** | GIVEN the app is running and the database is seeded, WHEN A new user can register with username + password, the system SHALL ensure that the journey succeeds and the system state reflects the expected outcome. |
| **Category** | functional |
| **Priority** | HIGH |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | api |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | FR-BA-100, REQ-PROMPT-132, REQ-PROMPT-000, REQ-PROMPT-014, REQ-PROMPT-011, REQ-PROMPT-016, REQ-PROMPT-079, REQ-PROMPT-104, REQ-PROMPT-010, REQ-PROMPT-043, REQ-PROMPT-047, REQ-PROMPT-017, REQ-PROMPT-125, REQ-PROMPT-058, REQ-PROMPT-030, REQ-PROMPT-156, REQ-PROMPT-080, REQ-PROMPT-023, REQ-PROMPT-012, REQ-PROMPT-081, REQ-PROMPT-067, REQ-PROMPT-020, REQ-PROMPT-082, REQ-PROMPT-083, REQ-PROMPT-101, REQ-PROMPT-002, REQ-PROMPT-078 |

**Rationale:** Derived from user-prompt extraction (entities=['profiled'], verbs=['create', 'read', 'delete', 'login', 'schedule', 'notify', 'import', 'update'], fields=['statu']).

**Acceptance Criteria:**

1. **[FR-BA-100-AC01]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN A new user can register with username + password, THEN the journey succeeds and the system state reflects the expected outcome
2. **[FR-BA-100-AC02]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN An existing user can log in and receive a bearer token, THEN the journey succeeds and the system state reflects the expected outcome
3. **[FR-BA-100-AC03]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN An authenticated user can log out and invalidate the token, THEN the journey succeeds and the system state reflects the expected outcome

### FR-BA-100b: User authentication (B)

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-BA-100b |
| **Title** | User authentication (B) |
| **Statement** | GIVEN the app is running and the database is seeded, WHEN An unauthenticated request to a protected route returns 401, the system SHALL ensure that the journey succeeds and the system state reflects the expected outcome. |
| **Category** | functional |
| **Priority** | HIGH |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | api |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | FR-BA-100, REQ-PROMPT-132, REQ-PROMPT-000, REQ-PROMPT-014, REQ-PROMPT-011, REQ-PROMPT-016, REQ-PROMPT-079, REQ-PROMPT-010, REQ-PROMPT-043, REQ-PROMPT-047, REQ-PROMPT-017, REQ-PROMPT-125, REQ-PROMPT-058, REQ-PROMPT-030, REQ-PROMPT-156, REQ-PROMPT-080, REQ-PROMPT-023, REQ-PROMPT-012, REQ-PROMPT-081, REQ-PROMPT-067, REQ-PROMPT-020, REQ-PROMPT-082, REQ-PROMPT-083, REQ-PROMPT-101, REQ-PROMPT-002, REQ-PROMPT-078 |

**Rationale:** Derived from user-prompt extraction (entities=['profiled'], verbs=['create', 'read', 'delete', 'login', 'schedule', 'notify', 'import', 'update'], fields=['statu']).

**Acceptance Criteria:**

1. **[FR-BA-100-AC04]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN An unauthenticated request to a protected route returns 401, THEN the journey succeeds and the system state reflects the expected outcome

### FR-BA-101a: Profiled CRUD operations (A)

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-BA-101a |
| **Title** | Profiled CRUD operations (A) |
| **Statement** | GIVEN the app is running and the database is seeded, WHEN An authenticated user can create a profiled with the required fields, the system SHALL ensure that the journey succeeds and the system state reflects the expected outcome. |
| **Category** | functional |
| **Priority** | HIGH |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | api |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | REQ-PROMPT-117, REQ-PROMPT-132, REQ-PROMPT-000, REQ-PROMPT-014, REQ-PROMPT-011, REQ-PROMPT-016, FR-BA-101, REQ-PROMPT-079, REQ-PROMPT-010, REQ-PROMPT-043, REQ-PROMPT-047, REQ-PROMPT-017, REQ-PROMPT-125, REQ-PROMPT-058, REQ-PROMPT-030, REQ-PROMPT-156, REQ-PROMPT-120, REQ-PROMPT-080, REQ-PROMPT-023, REQ-PROMPT-012, REQ-PROMPT-081, REQ-PROMPT-067, REQ-PROMPT-020, REQ-PROMPT-082, REQ-PROMPT-083, REQ-PROMPT-101, REQ-PROMPT-002, REQ-PROMPT-078 |

**Rationale:** Derived from user-prompt extraction (entities=['profiled'], verbs=['create', 'read', 'delete', 'login', 'schedule', 'notify', 'import', 'update'], fields=['statu']).

**Acceptance Criteria:**

1. **[FR-BA-101-AC01]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN An authenticated user can create a profiled with the required fields, THEN the journey succeeds and the system state reflects the expected outcome
2. **[FR-BA-101-AC02]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN An authenticated user can list their own profileds, THEN the journey succeeds and the system state reflects the expected outcome
3. **[FR-BA-101-AC03]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN An authenticated user can update a profiled they own, THEN the journey succeeds and the system state reflects the expected outcome

### FR-BA-101b: Profiled CRUD operations (B)

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-BA-101b |
| **Title** | Profiled CRUD operations (B) |
| **Statement** | GIVEN the app is running and the database is seeded, WHEN An authenticated user can delete a profiled they own, the system SHALL ensure that the journey succeeds and the system state reflects the expected outcome. |
| **Category** | functional |
| **Priority** | HIGH |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | api |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | REQ-PROMPT-117, REQ-PROMPT-132, REQ-PROMPT-000, REQ-PROMPT-014, REQ-PROMPT-011, REQ-PROMPT-016, FR-BA-101, REQ-PROMPT-079, REQ-PROMPT-010, REQ-PROMPT-043, REQ-PROMPT-047, REQ-PROMPT-017, REQ-PROMPT-125, REQ-PROMPT-058, REQ-PROMPT-030, REQ-PROMPT-156, REQ-PROMPT-080, REQ-PROMPT-023, REQ-PROMPT-012, REQ-PROMPT-081, REQ-PROMPT-067, REQ-PROMPT-020, REQ-PROMPT-082, REQ-PROMPT-083, REQ-PROMPT-101, REQ-PROMPT-002, REQ-PROMPT-078 |

**Rationale:** Derived from user-prompt extraction (entities=['profiled'], verbs=['create', 'read', 'delete', 'login', 'schedule', 'notify', 'import', 'update'], fields=['statu']).

**Acceptance Criteria:**

1. **[FR-BA-101-AC04]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN An authenticated user can delete a profiled they own, THEN the journey succeeds and the system state reflects the expected outcome
2. **[FR-BA-101-AC05]** [Positive] [Automated] GIVEN the app is running and the database is seeded, WHEN A user cannot see or modify profileds owned by others, THEN the journey succeeds and the system state reflects the expected outcome

### FR-004: Automated test suite

| Attribute | Value |
| --- | --- |
| **REQ ID** | FR-004 |
| **Title** | Automated test suite |
| **Statement** | GIVEN the test suite, WHEN mvn test runs, the system SHALL ensure that all tests pass. |
| **Category** | functional |
| **Priority** | HIGH |
| **Source** | User prompt |
| **Owner** | CAID Planner |
| **Component** | Tests |
| **Verification** | Test case |
| **Status** | draft |
| **Version** | 1.0 |
| **Trace Links** | REQ-PROMPT-081, REQ-PROMPT-021, REQ-PROMPT-082, REQ-PROMPT-027, REQ-PROMPT-035, REQ-PROMPT-079, REQ-PROMPT-083, REQ-PROMPT-080, REQ-PROMPT-000, REQ-PROMPT-069, REQ-PROMPT-078 |

**Acceptance Criteria:**

1. **[FR004-AC01]** [Positive] [Automated] GIVEN the test suite, WHEN mvn test runs, THEN all tests pass

---

## 3. Non-Functional Requirements

### NFR-P-001: API Response Time

**Category:** Performance
**Priority:** HIGH
1. API endpoints MUST respond within 100ms (p95) under normal load
2. System MUST handle 100 concurrent requests without degradation

**Acceptance Criteria:**

1. **[NFR-P-001-AC01]** [Positive] [Automated] GIVEN 100 concurrent users, WHEN each sends GET /api/items, THEN p95 response time < 100ms

### NFR-S-001: Authentication

**Category:** Security
**Priority:** CRITICAL
1. ALL endpoints (including GET) MUST require authentication
2. Passwords MUST be hashed with bcrypt (cost >= 12)
3. JWT tokens MUST expire within 24 hours

**Acceptance Criteria:**

1. **[NFR-S-001-AC01]** [Negative] [Automated] GIVEN an unauthenticated request, WHEN GET /api/items, THEN 401 Unauthorized
2. **[NFR-S-001-AC02]** [Negative] [Automated] GIVEN an unauthenticated request, WHEN POST /api/items with valid payload, THEN 401 Unauthorized
3. **[NFR-S-001-AC03]** [Positive] [Automated] GIVEN a registered user, WHEN POST /auth/login with correct credentials, THEN bearer token returned with exp <= 24h

### NFR-S-002: Input Validation

**Category:** Security
**Priority:** CRITICAL
1. All user input MUST be validated against defined schemas
2. SQL injection prevention via parameterized queries

**Acceptance Criteria:**

1. **[NFR-S-002-AC01]** [Negative] [Automated] GIVEN a payload with SQL injection in the title field, WHEN POST /api/items, THEN 422 Validation Error (not a database error)

### NFR-R-001: Availability

**Category:** Reliability
**Priority:** HIGH
1. System MUST include health check endpoint at /health
2. Graceful degradation when external dependencies unavailable

**Acceptance Criteria:**

1. **[NFR-R-001-AC01]** [Positive] [Automated] GIVEN the backend is running, WHEN GET /health, THEN 200 OK with {status: healthy}

### NFR-M-001: Logging

**Category:** Maintainability
**Priority:** MEDIUM
1. All API requests MUST be logged with correlation ID
2. Error responses MUST include trace ID for debugging

**Acceptance Criteria:**

1. **[NFR-M-001-AC01]** [Positive] [Automated] GIVEN any API request, WHEN the response is returned, THEN the response headers include X-Correlation-ID

### NFR-A-001: Accessibility

**Category:** Usability
**Priority:** HIGH
1. All interactive elements MUST be keyboard-navigable
2. All form inputs MUST have associated labels
3. WCAG 2.2 Level AA compliance required

**Acceptance Criteria:**

1. **[NFR-A-001-AC01]** [Positive] [Automated] GIVEN the dashboard page loaded in Playwright, WHEN axe-core accessibility audit runs, THEN zero WCAG 2.2 AA violations

### NFR-DP-001: Data Privacy

**Category:** Security
**Priority:** HIGH
1. Each user MUST only see their own data (tenant isolation)
2. Passwords MUST NOT appear in API responses or logs
3. Personal data MUST be deletable on user request

**Acceptance Criteria:**

1. **[NFR-DP-001-AC01]** [Negative] [Automated] GIVEN user A's task, WHEN user B requests GET /api/items/{task_id}, THEN 403 Forbidden
2. **[NFR-DP-001-AC02]** [Positive] [Automated] GIVEN a registered user, WHEN GET /auth/me or any list endpoint, THEN password_hash is not present in the response body

---

## 4. Use Cases

_Use cases will be generated from project analysis._

---

## 5. Requirements Traceability Matrix

| FR ID | Title | Task | Test Cases | Verification | Priority |
|-------|-------|------|------------|-------------|----------|
| FR-001 | Spring Boot project skeleton | foundation | TC-FR001-AC01 | Test case | CRITICAL |
| FR-002 | Data persistence with JPA | domain | TC-FR002-AC01 | Test case | CRITICAL |
| FR-003 | RESTful API endpoints | api | TC-FR003-AC01 | Test case | HIGH |
| FR-BA-100a | User authentication (A) | api | TC-FR-BA-100-AC01, TC-FR-BA-100-AC02, TC-FR-BA-100-AC03 | Test case | HIGH |
| FR-BA-100b | User authentication (B) | api | TC-FR-BA-100-AC04 | Test case | HIGH |
| FR-BA-101a | Profiled CRUD operations (A) | api | TC-FR-BA-101-AC01, TC-FR-BA-101-AC02, TC-FR-BA-101-AC03 | Test case | HIGH |
| FR-BA-101b | Profiled CRUD operations (B) | api | TC-FR-BA-101-AC04, TC-FR-BA-101-AC05 | Test case | HIGH |
| FR-004 | Automated test suite | tests | TC-FR004-AC01 | Test case | HIGH |

---

## 6. Acceptance Criteria Checklist

- [ ] All FRs documented with >= 2 acceptance criteria
- [ ] All NFRs quantified with measurable targets
- [ ] Traceability matrix complete (100% FRs linked to tests)
- [ ] Use cases cover all primary actor workflows
- [ ] Stakeholder review completed