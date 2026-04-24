// ---------------------------------------------------------------------------
// Symphonix EPS Extensions
// ---------------------------------------------------------------------------
// Each extension maps to a top-10 ePrescribing pain-point control documented
// in input/pagecontent/safety.md. All URLs are canonical under
// https://symphonix.health/fhir/eps/StructureDefinition/<id>.

Extension: AllergenGroup
Id: eps-allergen-group
Title: "Allergen Group"
Description: "Groups allergens by mechanism (e.g. penicillin class) rather
than by drug-name alphabetical. Fixes the penicillin/penicillamine
disambiguation error documented in the NHS England National Patient
Safety Alert of November 2025. SHALL be populated on AllergyIntolerance
when the allergen is in any of the high-risk groups enumerated by the
eps-allergen-group ValueSet."
* ^context.type = #element
* ^context.expression = "AllergyIntolerance.code"
* value[x] only CodeableConcept
* valueCodeableConcept from eps-allergen-group (required)

Extension: AlertSeverity
Id: eps-alert-severity
Title: "Clinical Decision Support Alert Severity"
Description: "Tiered severity for a CDS alert emitted alongside a
MedicationRequest or Task. Values: hard-stop | advisory | info.
hard-stop alerts MUST NOT be silently overridden; override requires a
second-signer per operating policy. Derived from JAMIA 2024 alert
override study."
* ^context.type = #element
* ^context.expression = "Task.businessStatus"
* value[x] only code
* valueCode from eps-alert-severity (required)

Extension: ControlledDrugSchedule
Id: eps-controlled-drug-schedule
Title: "Controlled Drug Schedule"
Description: "UK Misuse of Drugs Act / US DEA Schedule / WHO Narcotic
Convention schedule for the prescribed medication. Enforces enhanced
audit and two-factor dispense requirements."
* ^context.type = #element
* ^context.expression = "MedicationRequest"
* value[x] only code
* valueCode from eps-controlled-drug-schedule (required)

Extension: DoseBandLimit
Id: eps-dose-band-limit
Title: "Paediatric Dose Band Limit"
Description: "Soft and hard limits expressed as dose per kilogram
bodyweight. Required when patient.age < 18y. Fix for the 10x
paediatric anticoagulant overdose documented in the HSSIB weight-based
medication errors report."
* ^context.type = #element
* ^context.expression = "Dosage.doseAndRate"
* extension contains
    softLimitPerKg 1..1 and
    hardLimitPerKg 1..1
* extension[softLimitPerKg].value[x] only Quantity
* extension[hardLimitPerKg].value[x] only Quantity

Extension: NominationType
Id: eps-nomination-type
Title: "Dispenser Nomination Type"
Description: "How the patient nominated their dispensing pharmacy:
explicit (set by patient) | default (per jurisdiction rules) | one-off
(this prescription only) | opportunistic (no nomination, any dispenser
may claim)."
* ^context.type = #element
* ^context.expression = "MedicationRequest"
* value[x] only code
* valueCode from eps-nomination-type (required)

Extension: RepeatIssueNumber
Id: eps-repeat-issue-number
Title: "Repeat / eRD Issue Number"
Description: "Issue number and total of issues for repeat dispensing
(NHS eRD / Scottish Chronic Medication Service / cross-jurisdiction
equivalent). Matches the ITK3 / EPS electronic Repeat Dispensing
model."
* ^context.type = #element
* ^context.expression = "MedicationRequest"
* extension contains
    currentIssue 1..1 and
    totalIssues 1..1 and
    intervalDays 0..1
* extension[currentIssue].value[x] only positiveInt
* extension[totalIssues].value[x] only positiveInt
* extension[intervalDays].value[x] only positiveInt

Extension: HashChainLink
Id: eps-hash-chain-link
Title: "Tamper-Evident Audit Chain Link"
Description: "SHA-256 hash-chain predecessor for this AuditEvent.
Enables independent chain verification by consumers without trusting
the server. Aligns with CAID HealthcareAuditTrail pattern and
IHE ATNA."
* ^context.type = #element
* ^context.expression = "AuditEvent"
* extension contains
    prevHash 1..1 and
    currHash 1..1
* extension[prevHash].value[x] only string
* extension[currHash].value[x] only string

Extension: IdempotencyKey
Id: eps-idempotency-key
Title: "Idempotency Key"
Description: "Client-assigned idempotency key for signed message
replay. When ETPS (the transport sim) sees a duplicate key within the
24h retention window, it returns the original response without
mutating state. Addresses CPE EPS technical-failure contingency
requirements."
* ^context.type = #element
* ^context.expression = "MessageHeader"
* value[x] only string
