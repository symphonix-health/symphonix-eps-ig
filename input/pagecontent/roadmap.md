# Roadmap

## v0.1.0 (this release)

- Core profiles: MedicationRequest, MedicationDispense, Task, Provenance,
  Bundle (prescribe / dispense / discharge / tracker), MessageHeader,
  AuditEvent, AllergyIntolerance.
- Extensions: AllergenGroup, AlertSeverity, ControlledDrugSchedule,
  DoseBandLimit, NominationType, RepeatIssueNumber, HashChainLink,
  IdempotencyKey.
- ValueSets / CodeSystems for the above plus cancellation reasons.
- CapabilityStatements: ETPS transport server, EPS clinical server.
- Example instances: happy-path amoxicillin, paracetamol duplicate pair,
  paediatric ibuprofen, methylphenidate Schedule 2, penicillin allergy.
- Narrative: index, safety, workflows, bounded contexts, terminology,
  references, roadmap.
- Python validator harness.
- GitHub Actions CI for SUSHI + IG Publisher.

## v0.2.0 (released)

- Cephalosporin cross-reactivity cascade added to the `eps-allergen-group`
  ValueSet: `cephalosporin-class` (1st/2nd gen, ~10% empirical
  cross-reactivity with penicillin allergy per BNF, advisory at sign-time)
  and `cephalosporin-class-extended` (3rd/4th/5th gen, ~1-3% side-chain-
  specific cross-reactivity per the 2026 NatPSA update, advisory only when
  the patient is recorded penicillin-class allergic with no prior
  tolerance). Additive bump per `update-cascade.md`.
- Five canonical FHIR Bundle example fixtures added under
  `input/examples/bundles/`, consumed by the caid-agent journey runner:
  `j1-amoxicillin-prescribe.json` (happy-path nominated Rx),
  `j6-paracetamol-duplicate-pair.json` (QE coroner duplicate-therapy
  hard-stop reference case), `j7-cefalexin-cross-reactivity.json`
  (penicillin-allergic patient + cefalexin -> advisory cross-reactivity
  alert), `j8-paediatric-overdose.json` (10x enoxaparin in an 18.5kg child
  -> hard-stop per HSSIB reference case), and `j9-cross-border.json` (Irish
  prescriber + UK dispenser per EU Directive 2011/24 -- delivers the
  cross-border EU 2011/24 example instance planned below).
- Downstream cascade: `eps` sibling repo's allergen-group data, CDS rule,
  and matrix rows were updated in lock-step; `etps` pins the v0.2.0
  dependency (additive, no code change); frontend allergen-group dropdowns
  pick the new codes up automatically via `/api/reference/allergen-groups`.

### Carried forward to a future release

- Negative-example validator fixtures with `.expected.txt` sidecars.
- Discharge push, cancel race, and repeat-dispensing issue progression
  example instances.
- Extended DDI extension for drug-pair severity metadata.
- openEHR medication archetype crosswalk.
- US-core Patient/Practitioner/Organization crosswalk.

## v1.0.0 (stability target)

- Full IHE Pharm MPD alignment once the MPD draft is balloted.
- NCPDP SCRIPT 2023011 wire-shape crosswalk.
- Published as `package.tgz` on FHIR package registry.
- DCB0129 safety case template locked.
- DTAC assessment template bundled in `docs/`.

## Long-term

- Bevan LLM + Nexus A2A agent-to-agent advocacy bindings (CAID advocacy
  layer integration).
- WHO Medicines DAK alignment when published.
- HL7 FHIR R5 migration path with conversion maps.
