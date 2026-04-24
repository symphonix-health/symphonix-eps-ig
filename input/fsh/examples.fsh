// ---------------------------------------------------------------------------
// Symphonix EPS Example Instances
// ---------------------------------------------------------------------------
// Real pharmacology, synthetic identifiers. Every example demonstrates a
// specific workflow or safety control. See input/pagecontent/safety.md for
// the mapping of examples to top-10 pain-point controls.

Instance: PatientAlice
InstanceOf: Patient
Usage: #example
Title: "Patient: Alice Example (synthetic)"
* identifier.system = "https://symphonix.health/fhir/identifier/global-patient-id"
* identifier.value = "SYN-P-0001"
* name.family = "Example"
* name.given = "Alice"
* gender = #female
* birthDate = "1987-03-14"

Instance: PatientKaoruMinor
InstanceOf: Patient
Usage: #example
Title: "Patient: Kaoru Example (synthetic paediatric)"
* identifier.system = "https://symphonix.health/fhir/identifier/global-patient-id"
* identifier.value = "SYN-P-0002"
* name.family = "Example"
* name.given = "Kaoru"
* gender = #other
* birthDate = "2020-07-21"  // ~5y at IG v0.1.0 release

Instance: PractitionerDrHale
InstanceOf: Practitioner
Usage: #example
Title: "Practitioner: Dr Hale (synthetic prescriber)"
* identifier.system = "https://symphonix.health/fhir/identifier/global-prescriber-id"
* identifier.value = "SYN-PR-0001"
* name.family = "Hale"
* name.given = "J"
* name.prefix = "Dr"

Instance: OrgSouthBridgePharmacy
InstanceOf: Organization
Usage: #example
Title: "Dispenser: SouthBridge Pharmacy (synthetic)"
* identifier.system = "https://symphonix.health/fhir/identifier/global-org-id"
* identifier.value = "SYN-O-0001"
* name = "SouthBridge Pharmacy"
* type.coding.system = "http://terminology.hl7.org/CodeSystem/organization-type"
* type.coding.code = #prov

// ---------------------------------------------------------------------------
// Example 1: Happy-path amoxicillin prescription (nominated)
// Mapped to workflow J1 (prescribe -> transport -> dispense).
// ---------------------------------------------------------------------------
Instance: ExampleRxAmoxicillin
InstanceOf: EpsMedicationRequest
Usage: #example
Title: "Rx: Amoxicillin 500mg caps x 21 (happy-path, nominated)"
* status = #active
* intent = #order
* subject = Reference(PatientAlice)
* requester = Reference(PractitionerDrHale)
* medicationCodeableConcept.coding[+].system = "http://snomed.info/sct"
* medicationCodeableConcept.coding[=].code = #27658006
* medicationCodeableConcept.coding[=].display = "Amoxicillin"
* medicationCodeableConcept.coding[+].system = "http://www.nlm.nih.gov/research/umls/rxnorm"
* medicationCodeableConcept.coding[=].code = #723
* medicationCodeableConcept.coding[+].system = "http://www.whocc.no/atc"
* medicationCodeableConcept.coding[=].code = #J01CA04
* dosageInstruction[0].text = "500mg three times a day for 7 days"
* dosageInstruction[0].additionalInstruction.coding.system = "http://snomed.info/sct"
* dosageInstruction[0].additionalInstruction.coding.code = #395104009
* dosageInstruction[0].additionalInstruction.coding.display = "Take regularly with meals"
* dosageInstruction[0].doseAndRate[0].doseQuantity.value = 500
* dosageInstruction[0].doseAndRate[0].doseQuantity.unit = "mg"
* dosageInstruction[0].doseAndRate[0].doseQuantity.system = "http://unitsofmeasure.org"
* dosageInstruction[0].doseAndRate[0].doseQuantity.code = #mg
* extension[NominationType].valueCode = #explicit

// ---------------------------------------------------------------------------
// Example 2: Paracetamol duplicate-therapy positive test vector.
// Paired with ExampleRxParacetamolTwo to trigger the EPS hard-stop.
// Mapped to pain-point #2 (QE Hospital paracetamol coroner PFD 2025).
// ---------------------------------------------------------------------------
Instance: ExampleRxParacetamolOne
InstanceOf: EpsMedicationRequest
Usage: #example
Title: "Rx: Paracetamol 500mg (duplicate-therapy vector, first of pair)"
* status = #active
* intent = #order
* subject = Reference(PatientAlice)
* requester = Reference(PractitionerDrHale)
* medicationCodeableConcept.coding.system = "http://snomed.info/sct"
* medicationCodeableConcept.coding.code = #387517004
* medicationCodeableConcept.coding.display = "Paracetamol"
* dosageInstruction[0].text = "500mg four times a day PRN"
* dosageInstruction[0].doseAndRate[0].doseQuantity.value = 500
* dosageInstruction[0].doseAndRate[0].doseQuantity.unit = "mg"
* dosageInstruction[0].doseAndRate[0].doseQuantity.system = "http://unitsofmeasure.org"
* dosageInstruction[0].doseAndRate[0].doseQuantity.code = #mg

Instance: ExampleRxParacetamolTwo
InstanceOf: EpsMedicationRequest
Usage: #example
Title: "Rx: Co-codamol 30/500 (duplicate-therapy vector, second of pair)"
Description: "Co-codamol contains paracetamol. When co-prescribed with
ExampleRxParacetamolOne, EPS MUST fire a hard-stop alert at prescribing
time (ingredient-level duplicate-therapy rule). This pair is the
synthetic reproduction of the QE Hospital paracetamol overdose."
* status = #active
* intent = #order
* subject = Reference(PatientAlice)
* requester = Reference(PractitionerDrHale)
* medicationCodeableConcept.coding.system = "http://snomed.info/sct"
* medicationCodeableConcept.coding.code = #331400009
* medicationCodeableConcept.coding.display = "Co-codamol 30mg/500mg tablet"
* dosageInstruction[0].text = "1-2 tablets four times a day PRN"
* dosageInstruction[0].doseAndRate[0].doseQuantity.value = 500
* dosageInstruction[0].doseAndRate[0].doseQuantity.unit = "mg"
* dosageInstruction[0].doseAndRate[0].doseQuantity.system = "http://unitsofmeasure.org"
* dosageInstruction[0].doseAndRate[0].doseQuantity.code = #mg

// ---------------------------------------------------------------------------
// Example 3: Paediatric ibuprofen weight-based with dose band.
// Mapped to pain-point #3 (HSSIB 2024 weight-based errors report).
// ---------------------------------------------------------------------------
Instance: ExampleRxPaediatricIbuprofen
InstanceOf: EpsMedicationRequest
Usage: #example
Title: "Rx: Ibuprofen 100mg/5mL suspension (paediatric, weight-banded)"
* status = #active
* intent = #order
* subject = Reference(PatientKaoruMinor)
* requester = Reference(PractitionerDrHale)
* medicationCodeableConcept.coding.system = "http://snomed.info/sct"
* medicationCodeableConcept.coding.code = #329157006
* medicationCodeableConcept.coding.display = "Ibuprofen 100mg/5mL oral suspension"
* supportingInformation.display = "Patient weight: 18.5 kg (measured at consultation)"
* dosageInstruction[0].text = "5mg/kg three times a day with food"
* dosageInstruction[0].doseAndRate[0].doseQuantity.value = 92.5
* dosageInstruction[0].doseAndRate[0].doseQuantity.unit = "mg"
* dosageInstruction[0].doseAndRate[0].doseQuantity.system = "http://unitsofmeasure.org"
* dosageInstruction[0].doseAndRate[0].doseQuantity.code = #mg
* dosageInstruction[0].doseAndRate[0].extension[DoseBandLimit].extension[softLimitPerKg].valueQuantity.value = 10
* dosageInstruction[0].doseAndRate[0].extension[DoseBandLimit].extension[softLimitPerKg].valueQuantity.unit = "mg/kg"
* dosageInstruction[0].doseAndRate[0].extension[DoseBandLimit].extension[hardLimitPerKg].valueQuantity.value = 15
* dosageInstruction[0].doseAndRate[0].extension[DoseBandLimit].extension[hardLimitPerKg].valueQuantity.unit = "mg/kg"

// ---------------------------------------------------------------------------
// Example 4: Controlled drug (Schedule 2) methylphenidate.
// Mapped to pain-point #4 (CQC controlled-drug safer management 2023).
// ---------------------------------------------------------------------------
Instance: ExampleRxMethylphenidate
InstanceOf: EpsMedicationRequest
Usage: #example
Title: "Rx: Methylphenidate 10mg tablets (Schedule 2 CD)"
* status = #active
* intent = #order
* subject = Reference(PatientAlice)
* requester = Reference(PractitionerDrHale)
* medicationCodeableConcept.coding.system = "http://snomed.info/sct"
* medicationCodeableConcept.coding.code = #372898002
* medicationCodeableConcept.coding.display = "Methylphenidate 10mg tablet"
* dosageInstruction[0].text = "10mg in the morning, 10mg at noon"
* dosageInstruction[0].doseAndRate[0].doseQuantity.value = 10
* dosageInstruction[0].doseAndRate[0].doseQuantity.unit = "mg"
* dosageInstruction[0].doseAndRate[0].doseQuantity.system = "http://unitsofmeasure.org"
* dosageInstruction[0].doseAndRate[0].doseQuantity.code = #mg
* extension[ControlledDrugSchedule].valueCode = #schedule-2

// ---------------------------------------------------------------------------
// Example 5: Penicillin allergy record with allergen-group extension.
// Mapped to pain-point #1 (NHSE NatPSA Nov 2025 penicillin / penicillamine).
// ---------------------------------------------------------------------------
Instance: ExampleAllergyPenicillin
InstanceOf: EpsAllergyIntolerance
Usage: #example
Title: "Allergy: Penicillin class (with allergen-group)"
Description: "Patient's penicillin allergy record. The allergen-group
extension ensures downstream EPS CDS rules resolve this to the whole
penicillin class (amoxicillin, flucloxacillin, benzylpenicillin, etc.),
not alphabetical neighbours such as penicillamine."
* patient = Reference(PatientAlice)
* code.coding.system = "http://snomed.info/sct"
* code.coding.code = #373270004
* code.coding.display = "Substance with penicillin structure and antibacterial mechanism of action"
* extension[AllergenGroup].valueCodeableConcept.coding.system = "https://symphonix.health/fhir/eps/CodeSystem/eps-allergen-group"
* extension[AllergenGroup].valueCodeableConcept.coding.code = #penicillin-class
