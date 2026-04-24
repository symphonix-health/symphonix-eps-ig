// ---------------------------------------------------------------------------
// Symphonix EPS Profiles
// ---------------------------------------------------------------------------
// Each profile documents its relationship to NHS Digital's EPS FHIR guides
// and to IHE Pharm MPD where applicable. Extensions and ValueSets are
// defined in extensions.fsh and valuesets.fsh respectively.

Profile: EpsMedicationRequest
Parent: MedicationRequest
Id: eps-medication-request
Title: "EPS MedicationRequest"
Description: "The prescription, as authored by a prescriber and carried
through the EPS / ETPS flow. Profiled to require structured Dosage,
to record controlled-drug schedule, paediatric dose bands where
applicable, and nomination type."
* status 1..1
* intent = #order
* subject 1..1
* requester 1..1
* medicationCodeableConcept 1..1 MS
* medicationCodeableConcept from http://snomed.info/sct (preferred)
* dosageInstruction 1..* MS
* dosageInstruction.text 0..1  // free-text allowed only alongside structured additionalInstruction (see invariant)
* dosageInstruction.additionalInstruction 0..* MS
* dosageInstruction.doseAndRate 1..*
* dosageInstruction.doseAndRate.dose[x] 1..1
* extension contains
    ControlledDrugSchedule named controlledDrugSchedule 0..1 MS and
    NominationType named nominationType 0..1 MS and
    RepeatIssueNumber named repeatIssue 0..1 MS
* obeys eps-req-structured-dose

Invariant: eps-req-structured-dose
Description: "If dosageInstruction.text is populated, at least one
additionalInstruction MUST also be coded. Free-text-only dosage is
forbidden by the NHS Dose Syntax IG safety guidance."
Severity: #error
Expression: "dosageInstruction.all($this.text.empty() or $this.additionalInstruction.exists())"

// ---------------------------------------------------------------------------

Profile: EpsMedicationDispense
Parent: MedicationDispense
Id: eps-medication-dispense
Title: "EPS MedicationDispense"
Description: "A dispense event referencing a prescription via
authorizingPrescription. Substitution disclosed when a generic
replaces a brand."
* status 1..1
* authorizingPrescription 1..1
* subject 1..1
* performer 1..*
* medicationCodeableConcept 1..1 MS
* whenHandedOver 1..1 MS
* quantity 1..1
* daysSupply 0..1
* substitution 0..1
* substitution.wasSubstituted 0..1

// ---------------------------------------------------------------------------

Profile: EpsTask
Parent: Task
Id: eps-task
Title: "EPS Workflow Task"
Description: "The prescription's workflow state machine. businessStatus
is drawn from the eps-prescription-status ValueSet. alert-severity
extension carries CDS tiering information. replaces links supersessions
for cancel / reissue reconciliation."
* status 1..1
* businessStatus 1..1
* businessStatus from eps-prescription-status (required)
* intent 1..1
* focus 1..1
* for 1..1
* replaces 0..*
* extension contains
    AlertSeverity named alertSeverity 0..*

// ---------------------------------------------------------------------------

Profile: EpsProvenance
Parent: Provenance
Id: eps-provenance
Title: "EPS Signed-Bundle Provenance"
Description: "Captures the JWS detached signature over the canonical
prescription bundle. signature.type is bound to FHIR's author-signature
OID 1.2.840.10065.1.12.1.5. signature.data holds the base64-encoded
detached JWS."
* target 1..*
* recorded 1..1
* agent 1..*
* agent.who 1..1
* signature 1..*
* signature.type 1..*
* signature.data 1..1
* signature.who 1..1
* signature.sigFormat 1..1
* signature.sigFormat = "application/jose"

// ---------------------------------------------------------------------------

Profile: EpsPrescribeBundle
Parent: Bundle
Id: eps-prescribe-bundle
Title: "EPS Prescribe Message Bundle"
Description: "The message Bundle sent by the prescriber to ETPS via
$process-message. Carries the MedicationRequest(s), the Patient,
the Practitioner, and a Provenance anchor with the JWS signature."
* type = #message
* entry 1..*
* entry.resource 1..1

// ---------------------------------------------------------------------------

Profile: EpsDispenseBundle
Parent: Bundle
Id: eps-dispense-bundle
Title: "EPS Dispense Message Bundle"
Description: "The message Bundle sent by the dispenser to ETPS with
a MedicationDispense + Provenance signature. Replay-safe via
MessageHeader.eps-idempotency-key extension."
* type = #message
* entry 1..*

// ---------------------------------------------------------------------------

Profile: EpsMessageHeader
Parent: MessageHeader
Id: eps-message-header
Title: "EPS Transport MessageHeader"
Description: "Routing header for every signed message entering or
leaving ETPS. Carries the idempotency key and the prior-id chain for
retransmits. eventUri values: .../eps/prescribe, .../eps/dispense,
.../eps/cancel, .../eps/nomination-change."
* event[x] 1..1
* event[x] only uri
* destination 1..*
* source 1..1
* extension contains
    IdempotencyKey named idempotencyKey 1..1 MS

// ---------------------------------------------------------------------------

Profile: EpsAllergyIntolerance
Parent: AllergyIntolerance
Id: eps-allergy-intolerance
Title: "EPS AllergyIntolerance"
Description: "Patient allergy record; allergen-group extension MUST be
populated when the allergen belongs to any of the cross-reactive
groups enumerated by eps-allergen-group. Addresses the penicillin /
penicillamine disambiguation error (NHSE NatPSA Nov 2025)."
* patient 1..1
* code 1..1
* extension contains
    AllergenGroup named allergenGroup 0..1 MS

// ---------------------------------------------------------------------------

Profile: EpsDischargePushBundle
Parent: Bundle
Id: eps-discharge-push-bundle
Title: "Hospital Discharge Push Bundle"
Description: "Pushes the patient's discharge medications to community
pharmacy and GP practice within 24h of discharge. Positive ack
required. Addresses HSSIB safe-discharge failure mode."
* type = #message
* entry 1..*

// ---------------------------------------------------------------------------

Profile: EpsTrackerQueryBundle
Parent: Bundle
Id: eps-tracker-query-bundle
Title: "Prescription Tracker Query Response"
Description: "Search-set Bundle returned by GET
/FHIR/R4/prescription-tracker. Includes Task state, associated
MedicationDispense events, and the audit-anchor hash so clients can
verify the chain. Addresses the 'where is this prescription?' visibility
gap."
* type = #searchset
* entry 0..*

// ---------------------------------------------------------------------------

Profile: EpsAuditEvent
Parent: AuditEvent
Id: eps-audit-event
Title: "EPS Hash-Chained Audit Event"
Description: "An AuditEvent with the eps-hash-chain-link extension.
Hash chain anchors the log in a tamper-evident sequence aligned with
IHE ATNA and CAID's HealthcareAuditTrail. Mandatory on every
state-mutating EPS / ETPS endpoint."
* type 1..1
* recorded 1..1
* agent 1..*
* source 1..1
* entity 1..*
* extension contains
    HashChainLink named hashChain 1..1 MS
