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

## v0.2.0 (planned)

- Additional example instances: cross-border EU 2011/24, discharge push,
  cancel race, repeat-dispensing issue progression.
- Negative-example validator fixtures with `.expected.txt` sidecars.
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
