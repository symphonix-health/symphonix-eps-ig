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
