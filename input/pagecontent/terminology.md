# Terminology Binding Strategy

Global deployment demands multi-terminology support; UK-only bindings
cannot travel. This IG uses the following approach.

## Drug codes

- **SNOMED CT International** — primary clinical code. `preferred` binding
  on `MedicationRequest.medicationCodeableConcept`.
- **dm+d** (UK) — coded alongside SNOMED on UK deployments. `example`
  binding for the IG; mandatory in deploy-scoped profiles.
- **RxNorm** (US / global reference) — parallel coding recommended;
  the `EpsMedicationRequest` examples in this IG carry both SNOMED and
  RxNorm codings.
- **ATC / DDD** (WHO Collaborating Centre, Oslo) — classification code
  used for duplicate-therapy-by-class rules.
- **NCPDP SCRIPT 2023011** (US) — out of scope v1; tracked in roadmap.

## Units

- **UCUM** — required for all `Dosage.doseQuantity`. FHIR R4 normative.
- **SNOMED CT** — fallback for ampule / tablet / spray where UCUM is
  insufficient. Documented in the NHS Dose Syntax IG.

## Observations

- **LOINC** for lab results and clinical observations.
- **SNOMED CT** for findings, procedures, allergen-substance codes.
- **ICD-10 / ICD-11** for diagnosis context where referenced.

## Identity

- **Patient** — a global identifier system
  (`https://symphonix.health/fhir/identifier/global-patient-id`) is used
  in examples; production deployments SHALL slice to their jurisdiction's
  identifier (NHS Number, MRN, national health ID).
- **Practitioner** — same pattern.
- **Organization** — ODS codes (UK) / NPI (US) / WHO facility codes
  sliced per jurisdiction.

## Binding strength conventions

- `required` — use only where no alternative exists (workflow-internal
  enums such as `eps-prescription-status`).
- `extensible` — primary for terminology-driven ValueSets where
  extension by implementers is expected (`eps-allergen-group`,
  `eps-controlled-drug-schedule`).
- `preferred` — used for clinical code systems (SNOMED CT).
- `example` — used for illustrative codings only.
