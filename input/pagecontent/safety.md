# Safety Controls

Every profile and extension in this IG exists to prevent a specific real-world
failure mode documented in peer-reviewed or regulatory sources. This page
is the authoritative cross-reference.

## Top-10 pain-point controls

| # | Pain point (source) | IG artefact | Downstream enforcement |
|---|---|---|---|
| 1 | **Penicillin / penicillamine allergy disambiguation** (NHSE NatPSA Nov 2025) | `AllergenGroup` extension + `eps-allergen-group` ValueSet | EPS CDS rule `allergy-group-match` fires hard-stop when the prescribed medication's class matches a patient's recorded `allergen-group`. Alphabetical matching forbidden. |
| 2 | **Duplicate-therapy hard-stop** (QE Hospital paracetamol coroner PFD 2025) | `AlertSeverity` extension = `hard-stop` + ValueSet | EPS CDS rule `duplicate-therapy-ingredient` fires `hard-stop` that cannot be silently overridden; `safety_officer` co-signature required for paracetamol, opioids, anticoagulants, insulin. |
| 3 | **Paediatric weight-based dose band** (HSSIB 2024 weight-based med errors report) | `DoseBandLimit` extension on `Dosage.doseAndRate` | EPS CDS rule `paediatric-dose-band` requires `patient-weight` when `age < 18y`; calculated dose > `hardLimitPerKg` produces `hard-stop`; > `softLimitPerKg` produces `advisory`. |
| 4 | **ePMA medical-device posture** (HSSIB 2024 + UK MDR 2002) | `safety.md` narrative + DCB0129 mapping below | Deployers MUST produce a DCB0129 on the product and a DCB0160 on the deployment before go-live. |
| 5 | **Tiered alerts + per-tenant override SLO** (JAMIA 2024 CDS overrides study) | `AlertSeverity` ValueSet with `hard-stop / advisory / info` | EPS exposes `$alert-metrics`; tenants with `hard-stop` override rate > 80% over 24h WINDOW fail the deploy gate. |
| 6 | **Structured Dosage mandatory** (NHS Dose Syntax IG) | `EpsMedicationRequest` invariant `eps-req-structured-dose` | Free-text `Dosage.text` allowed only alongside coded `additionalInstruction`; invariant is enforced at validator level. |
| 7 | **Discharge push to community pharmacy + GP** (HSSIB safe-discharge report) | `EpsDischargePushBundle` profile | Hospital discharge producer pushes within 24h; positive ack required; missing ack triggers fallback alert. |
| 8 | **LASA pick-list safety** (APSF LASA primer, BJCP 2021) | Narrative `safety.md` guidance; no profile element (UI concern) | Downstream simulator UIs MUST render high-risk drug options grouped by mechanism; alphabetical ordering forbidden for high-risk classes. |
| 9 | **Offline + idempotent dispense** (CPE EPS technical-failure contingency) | `IdempotencyKey` extension on `MessageHeader` | ETPS deduplicates messages by `idempotency-key` within a 24h window; dispenser clients queue locally on outage and replay with the same key. |
| 10 | **End-to-end prescription tracker** (CPE EPS Tracker; NHS App) | `EpsTrackerQueryBundle` profile | ETPS `GET /FHIR/R4/prescription-tracker` returns state + dispense events + audit-anchor hash visible to prescriber, dispenser, and patient scopes. |

## DCB0129 mapping (per-profile hazard sheet)

Deployers SHALL extend the following table in their local DCB0129:

| Profile / extension | Hazard | Cause | Mitigation in this IG |
|---|---|---|---|
| `EpsMedicationRequest` | Wrong medication dispensed | Free-text dosage interpreted incorrectly | `eps-req-structured-dose` invariant forces structured dose; free-text only alongside coded `additionalInstruction` |
| `EpsAllergyIntolerance` + `AllergenGroup` | Allergen-mediated adverse drug reaction | Alphabetical allergy pick-list confuses cross-class drugs | `allergen-group` ValueSet grouped by mechanism, not alphabetical |
| `Dosage.DoseBandLimit` | Paediatric overdose | Weight-based calculation omitted | Extension mandatory when `age < 18y`; `hardLimitPerKg` blocks dispense |
| `EpsTask.AlertSeverity` | Adverse event from overridden alert | CDS alert fatigue | `hard-stop` tier requires safety-officer co-signature |
| `EpsProvenance` | Non-repudiation / identity assurance | Missing signer record | Mandatory JWS with `signature.sigFormat = application/jose` |
| `MessageHeader.IdempotencyKey` | Duplicate dispense | Retry on transport failure creates double-claim | Idempotency-key deduplicates within 24h |
| `EpsAuditEvent.HashChainLink` | Audit tampering | Untrusted server could rewrite history | SHA-256 linked chain verifiable without server trust |
| `EpsDischargePushBundle` | Missed discharge medication | No push to community pharmacy | Positive-ack protocol with 24h escalation |

## GDPR Art 30 register (starter)

| Processing activity | Lawful basis | Retention | Recipient category |
|---|---|---|---|
| Prescription ingest (ETPS) | Art 9(2)(h) healthcare | 8 years (or longer per jurisdiction) | Dispensing organisations |
| Dispense notification | Art 9(2)(h) | 8 years | Prescribing clinicians |
| Audit log | Art 6(1)(c) legal obligation | 20 years | Regulator on request only |
| Prescription tracker read | Art 9(2)(h) + patient consent | Session only | Patient |

Deployers SHALL localise this table and attach it to their data-protection
impact assessment (DPIA).
