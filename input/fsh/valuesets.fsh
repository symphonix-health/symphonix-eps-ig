// ---------------------------------------------------------------------------
// Symphonix EPS ValueSets and CodeSystems
// ---------------------------------------------------------------------------

CodeSystem: EpsPrescriptionStatus
Id: eps-prescription-status
Title: "EPS Prescription Business Status"
Description: "Finer-grained prescription lifecycle state beyond FHIR
Task.status. Used in Task.businessStatus. Mirrors the NHS Spine EPS
state machine while remaining jurisdiction-agnostic."
* #draft        "Draft"          "Being composed by the prescriber; not yet signed."
* #signed       "Signed"         "JWS-signed by the prescriber; awaiting transport ingest."
* #released     "Released"       "Accepted by the transport layer (ETPS); awaiting dispenser download."
* #downloaded   "Downloaded"     "Dispenser has retrieved the prescription but not yet dispensed."
* #partially-dispensed "Partially Dispensed" "At least one line item dispensed; others outstanding."
* #dispensed    "Dispensed"      "All line items fully dispensed."
* #claimed      "Claimed"        "Dispenser has submitted the reimbursement claim."
* #cancelled    "Cancelled"      "Cancelled by prescriber before full dispense."
* #expired      "Expired"        "Not dispensed within the validity window."

ValueSet: EpsPrescriptionStatus
Id: eps-prescription-status
Title: "EPS Prescription Business Status"
Description: "Values for Task.businessStatus on prescription Tasks."
* include codes from system EpsPrescriptionStatus

CodeSystem: EpsAlertSeverity
Id: eps-alert-severity
Title: "CDS Alert Severity"
Description: "Tiered severity for a Clinical Decision Support alert.
Tenants are expected to measure per-severity override rates; a
sustained hard-stop override rate above 80% fails the deploy gate per
the EPS safety case."
* #hard-stop "Hard Stop" "Must not be silently overridden; requires clinical-safety-officer co-signature."
* #advisory  "Advisory"  "Clinician override permitted with recorded reason."
* #info      "Info"      "Non-blocking informational."

ValueSet: EpsAlertSeverity
Id: eps-alert-severity
Title: "CDS Alert Severity"
Description: "Severity tiers for CDS alerts."
* include codes from system EpsAlertSeverity

CodeSystem: EpsControlledDrugSchedule
Id: eps-controlled-drug-schedule
Title: "Controlled Drug Schedule"
Description: "Controlled-drug schedule for prescribed medications.
Unified across UK MDA 1971 Schedules 1-5, US DEA Schedules I-V, and
WHO Single Convention schedules where equivalent."
* #none       "Not scheduled"     "Not a controlled drug."
* #schedule-1 "Schedule 1 / UK Sch 1" "Research-only; prescribing prohibited in most jurisdictions."
* #schedule-2 "Schedule 2 / UK Sch 2 / US DEA II" "Highest clinical-use schedule; enhanced audit mandatory."
* #schedule-3 "Schedule 3 / UK Sch 3 / US DEA III" "Subject to register requirements."
* #schedule-4 "Schedule 4 / UK Sch 4" "Moderate restriction."
* #schedule-5 "Schedule 5 / UK Sch 5 / US DEA V" "Lowest controlled-drug restriction."

ValueSet: EpsControlledDrugSchedule
Id: eps-controlled-drug-schedule
Title: "Controlled Drug Schedule"
* include codes from system EpsControlledDrugSchedule

CodeSystem: EpsNominationType
Id: eps-nomination-type
Title: "Dispenser Nomination Type"
Description: "How the patient's dispenser was selected for this prescription."
* #explicit       "Explicit"       "Patient explicitly nominated this dispenser."
* #default        "Default"        "Applied by jurisdiction rules where no explicit nomination."
* #one-off        "One-off"        "Nomination applies to this prescription only."
* #opportunistic  "Opportunistic"  "No nomination; any authorised dispenser may claim."

ValueSet: EpsNominationType
Id: eps-nomination-type
Title: "Dispenser Nomination Type"
* include codes from system EpsNominationType

CodeSystem: EpsCancellationReason
Id: eps-cancellation-reason
Title: "Prescription Cancellation Reason"
Description: "Why a prescription was cancelled. Semantic categories
taken from NHS EPS cancellation-reason codes but generalised."
* #prescribing-error    "Prescribing error"       "Prescriber-identified authoring error."
* #clinical-change      "Clinical change"         "Patient's clinical state changed."
* #patient-request      "Patient request"         "Patient withdrew."
* #duplicate            "Duplicate"               "Duplicate prescription identified."
* #dispenser-refusal    "Dispenser refusal"       "Dispenser unable to fulfil."
* #other                "Other"                   "Other reason; free-text required."

ValueSet: EpsCancellationReason
Id: eps-cancellation-reason
Title: "Prescription Cancellation Reason"
* include codes from system EpsCancellationReason

CodeSystem: EpsAllergenGroup
Id: eps-allergen-group
Title: "Allergen Group"
Description: "Mechanism-based allergen grouping to prevent the
alphabetical-ordering disambiguation errors documented in the NHSE
National Patient Safety Alert on penicillin vs penicillamine
(November 2025). Grouped by clinically-relevant cross-reactivity, not
by drug-name prefix."
* #penicillin-class            "Penicillin class"                  "All penicillins and beta-lactams with documented cross-reactivity."
* #cephalosporin-class         "Cephalosporin class"               "First / second-generation cephalosporins (cefalexin, cefuroxime). Empirical ~10% cross-reactivity with penicillin-allergic patients per BNF; advisory severity at sign-time, not hard-stop."
* #cephalosporin-class-extended "Cephalosporin class (extended)"    "Third / fourth / fifth-generation cephalosporins (ceftriaxone, ceftazidime, cefepime, ceftaroline) with reduced (~1-3%) penicillin cross-reactivity. Adds the side-chain-specific cross-reactivity model from the 2026 NatPSA update; advisory only when patient is recorded penicillin-class allergic AND no prior tolerance documented."
* #sulfonamide-antibiotic      "Sulfonamide antibiotic"            "Sulfonamide antibiotics (distinct from non-antibiotic sulfonamides)."
* #nsaid-class                 "NSAID class"                       "Non-steroidal anti-inflammatory drugs as a cross-reactive group."
* #iodinated-contrast          "Iodinated contrast media"          "Radiocontrast agents."
* #latex                       "Latex"                             "Natural rubber latex."
* #aspirin-salicylate          "Aspirin / salicylate"              "Aspirin and other salicylates."
* #macrolide                   "Macrolide antibiotic"              "Erythromycin-class."
* #tetracycline                "Tetracycline class"                "Tetracyclines."
* #opioid                      "Opioid"                            "All opioids (codeine, morphine, etc.)."
* #other                       "Other"                             "Other allergen; text MUST be populated."

ValueSet: EpsAllergenGroup
Id: eps-allergen-group
Title: "Allergen Group"
* include codes from system EpsAllergenGroup
