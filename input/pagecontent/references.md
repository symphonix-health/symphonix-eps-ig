# Research and Standards References

Every citation resolves on its canonical host. The Python harness at
`tests/test_citations.py` checks every URL on every CI run; unverifiable
links are marked `[unverified]` inline and must be resolved before the
next release (L-244).

## NHS England / NHS Digital / NHSBSA

- [NHS Digital EPS FHIR API catalogue](https://digital.nhs.uk/developer/api-catalogue/electronic-prescription-service-fhir)
- [EPS Prescribing developer guide](https://digital.nhs.uk/developer/guides-and-documentation/building-healthcare-software/prescriptions/eps-prescriber-developer-guide)
- [EPS Prescription Tracker FHIR API](https://digital.nhs.uk/developer/api-catalogue/eps-prescription-tracker-fhir-api)
- [NHS CIS2 Authentication](https://digital.nhs.uk/services/care-identity-service/applications-and-services/cis2-authentication)
- [NHS Dose Syntax Implementation Guide](https://nhsconnect.github.io/Dose-Syntax-Implementation/)
- [ITK3 FHIR Messaging Distribution spec](https://nhsconnect.github.io/ITK3-FHIR-Messaging-Distribution/mesh.html)
- [dm+d (NHSBSA)](https://www.nhsbsa.nhs.uk/pharmacies-gp-practices-and-appliance-contractors/nhs-dictionary-medicines-and-devices-dmd)
- [NHS Digital DCB0129/DCB0160 review](https://digital.nhs.uk/data-and-information/information-standards/governance/latest-activity/standards-and-collections/review-of-digital-clinical-safety-standards-dcb0129-and-dcb0160/)
- [NHSE Digital Clinical Safety Assurance](https://www.england.nhs.uk/long-read/digital-clinical-safety-assurance/)
- [NHSE NatPSA — penicillin/penicillamine (Nov 2025)](https://www.england.nhs.uk/long-read/national-patient-safety-alert-harm-from-incorrect-recording-of-a-penicillin-allergy-as-a-penicillamine-allergy/)
- [NHSE Digital Technology Assessment Criteria (DTAC)](https://transform.england.nhs.uk/key-tools-and-info/digital-technology-assessment-criteria-dtac/)

## HSSIB, MHRA, CQC

- [HSSIB weight-based medication errors in children (2024)](https://www.hssib.org.uk/patient-safety-investigations/weight-based-medication-errors-in-children/investigation-report/)
- [HSSIB ePrescribing and safe discharge](https://www.hssib.org.uk/patient-safety-investigations/electronic-prescribing-and-medicines-administration-systems-and-safe-discharge/investigation-report/)
- [HSSIB EPR systems thematic review (2025)](https://www.hssib.org.uk/patient-safety-investigations/electronic-patient-record-epr-systems-thematic-review/investigation-report/)
- [CQC Safer Management of Controlled Drugs 2023](https://www.cqc.org.uk/publications/controlled-drugs/2023/issues)

## Peer-reviewed research

- [JAMIA 2024 — AI to optimise medication alerts](https://academic.oup.com/jamia/article/31/6/1411/7654019)
- [Lancet Digital Health — UK hospital ePrescribing errors](https://www.thelancet.com/journals/landig/article/PIIS2589-7500(19)30158-X/fulltext)
- [Exploratory Research in Clinical and Social Pharmacy 2024 — NRLS high-risk medications](https://pmc.ncbi.nlm.nih.gov/articles/PMC11683304/)
- [Bryan et al. BJCP 2021 — LASA drivers and solutions](https://bpspubs.onlinelibrary.wiley.com/doi/pdf/10.1111/bcp.14285)
- [APSF — LASA medication errors primer](https://www.apsf.org/article/medication-errors-related-to-look-alike-sound-alike-drugs-how-big-is-the-problem-and-what-progress-is-being-made/)
- [AHRQ PSNet — medication-related CDS alert overrides](https://psnet.ahrq.gov/issue/medication-related-clinical-decision-support-alert-overrides-inpatients)
- [AHRQ Medication Reconciliation primer](https://www.ncbi.nlm.nih.gov/books/NBK2648/)
- [Pharmaceutical Journal — QE Hospital paracetamol coroner PFD](https://pharmaceutical-journal.com/article/news/disabling-prescribing-system-alerts-may-have-led-to-hospital-paracetamol-overdose)
- [Tsang et al. Lancet Digital Health 2025 — LLM medication error detection](https://www.sciencedirect.com/science/article/pii/S2666379125003969)

## Standards bodies

- [HL7 FHIR R4 Medications module](https://hl7.org/fhir/R4/medications-module.html)
- [HL7 FHIR R5 MedicationRequest](https://www.hl7.org/fhir/medicationrequest.html)
- [IHE Community Medication Prescription and Dispense (CMPD)](https://wiki.ihe.net/index.php/Community_Medication_Prescription_and_Dispense)
- [IHE Pharm MPD (FHIR-era successor)](https://build.fhir.org/ig/IHE/pharm-mpd/)
- [IHE Hospital Medication Workflow (HMW)](https://wiki.ihe.net/index.php/Hospital_Medication_Workflow)
- [IHE Audit Trail and Node Authentication (ATNA)](https://wiki.ihe.net/index.php/Audit_Trail_and_Node_Authentication)
- [ISO 27799:2025 — health info security controls](https://www.iso.org/standard/84647.html)
- [eIDAS 2 Regulation (EU) 2024/1183](https://eur-lex.europa.eu/eli/reg/2024/1183/oj)
- [EU Directive 2011/24 cross-border healthcare](https://eur-lex.europa.eu/eli/dir/2011/24/oj/eng)
- [NCPDP ePrescribing Industry Information](https://www.ncpdp.org/Resources/ePrescribing-Industry-Information)
- [SNOMED International](https://www.snomed.org/)
- [RxNorm (NLM)](https://www.nlm.nih.gov/research/umls/rxnorm/index.html)
- [WHO ATC/DDD index](https://www.whocc.no/atc_ddd_index/)

## WHO / global

- [WHO Global Strategy on Digital Health 2020-2025 / -2027 extension](https://www.who.int/publications/b/81640)
- [WHO SMART Guidelines](https://www.who.int/teams/digital-health-and-innovation/smart-guidelines)

## Community Pharmacy England / operational guidance

- [CPE EPS home](https://cpe.org.uk/digital-and-technology/eps/)
- [CPE EPS technical failures factsheet](https://cpe.org.uk/wp-content/uploads/2013/07/EPS-How-to-manage-EPS-technical-failures-Factsheet.pdf)
- [CPE EPS Prescription Tracker](https://cpe.org.uk/digital-and-technology/eps/eps-prescription-tracker/)
- [CPE Nomination](https://cpe.org.uk/digital-and-technology/eps/nomination-patients/)

## NHS Digital open source

- [NHSDigital/electronic-prescription-service-api](https://github.com/NHSDigital/electronic-prescription-service-api)
- [NHSDigital/eps-prescription-tracker-ui](https://github.com/NHSDigital/eps-prescription-tracker-ui)
- [NHSDigital/prescriptionsforpatients](https://github.com/NHSDigital/prescriptionsforpatients)

## LMIC / global open source reference

- [Bahmni / OpenMRS Medication module](https://www.bahmni.org/)
- [OpenHIE](https://ohie.org/)
