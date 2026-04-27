"""symphonix-eps-ig — FHIR R4 Implementation Guide for Symphonix EPS.

Subject: Implementation Guide governance (FHIR R4 IG, profiles, value sets,
example bundles, narrative pages, examples).
"""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).parent.parent.parent
OUT = ROOT / "tests" / "harness" / "requirements_superset.json"


def _build() -> list[dict]:
    reqs: list[dict] = [
        {"requirement_id": "EPSIG-001", "family": "A_PROMPT_PRESERVED",
         "title": "FHIR R4 conformance", "category": "non-functional",
         "statement": "IG SHALL conform to FHIR 4.0.1.",
         "source": "README.md"},
        {"requirement_id": "EPSIG-002", "family": "A_PROMPT_PRESERVED",
         "title": "Canonical URL stable", "category": "non-functional",
         "statement": "IG canonical URL SHALL be https://symphonix.health/fhir/eps.",
         "source": "README.md"},
        {"requirement_id": "EPSIG-003", "family": "A_PROMPT_PRESERVED",
         "title": "Citation resolvability",
         "statement": "Every external citation SHALL resolve on its canonical host.",
         "category": "non-functional",
         "source": "tests/test_citations.py"},
    ]

    families: dict[str, list[tuple[str, str]]] = {
        "B_IG_STRUCTURE": [
            ("StructureDefinition per profile", "Each profile SHALL be a StructureDefinition resource."),
            ("CodeSystem per local terminology", "Local terminology SHALL ship as CodeSystem resources."),
            ("ValueSet bindings", "Profiles SHALL bind to documented ValueSets."),
            ("ConceptMap for translations", "Cross-terminology mappings SHALL be expressed as ConceptMap."),
            ("CapabilityStatement publication", "IG SHALL publish CapabilityStatement(s)."),
            ("OperationDefinition for custom ops", "Custom operations SHALL ship OperationDefinition resources."),
            ("Example bundles per profile", "Each profile SHALL ship example bundles."),
            ("Narrative pages indexed", "Narrative pages SHALL be indexed in the table of contents."),
            ("Profile differential view", "Each profile SHALL ship a differential view."),
            ("Profile snapshot view", "Each profile SHALL ship a snapshot view."),
        ],
        "C_TERMINOLOGY": [
            ("LOINC bindings", "Quantitative results SHALL bind LOINC."),
            ("SNOMED CT bindings", "Clinical findings SHALL bind SNOMED CT."),
            ("ICD-10/11 bindings", "Diagnoses SHALL bind ICD-10/11."),
            ("UCUM bindings", "Quantitative units SHALL bind UCUM."),
            ("RxNorm bindings", "US medication codes SHALL bind RxNorm."),
            ("dm+d bindings", "UK medication codes SHALL bind dm+d."),
            ("BNF bindings", "Where applicable, BNF chapter codes SHALL be bound."),
            ("ATC bindings", "Therapeutic classification SHALL bind ATC."),
            ("ICD-O bindings", "Where applicable, ICD-O bindings SHALL be supported."),
            ("OPCS-4 bindings", "UK procedures SHALL bind OPCS-4."),
        ],
        "D_PROFILES": [
            ("Patient profile", "IG SHALL ship a Patient profile."),
            ("MedicationRequest profile", "IG SHALL ship a MedicationRequest profile."),
            ("MedicationDispense profile", "IG SHALL ship a MedicationDispense profile."),
            ("Practitioner profile", "IG SHALL ship a Practitioner profile."),
            ("Organization profile", "IG SHALL ship an Organization profile."),
            ("Location profile", "IG SHALL ship a Location profile."),
            ("Encounter profile", "IG SHALL ship an Encounter profile."),
            ("Coverage profile", "IG SHALL ship a Coverage profile."),
            ("Communication profile", "IG SHALL ship a Communication profile."),
            ("AuditEvent profile", "IG SHALL ship an AuditEvent profile."),
        ],
        "E_OPERATIONS": [
            ("$process-message", "IG SHALL define $process-message operation."),
            ("$everything", "IG SHALL define $everything operation."),
            ("$transform", "IG SHALL define $transform operation."),
            ("$validate", "IG SHALL define $validate operation."),
            ("$expand for ValueSet", "IG SHALL define $expand for ValueSet."),
            ("$lookup for CodeSystem", "IG SHALL define $lookup for CodeSystem."),
            ("$translate for ConceptMap", "IG SHALL define $translate for ConceptMap."),
            ("Subscription notifications", "IG SHALL describe Subscription notifications."),
            ("Bulk Data export", "IG SHALL describe Bulk Data export."),
            ("PATCH semantics", "IG SHALL describe PATCH semantics where supported."),
        ],
        "F_REGULATORY": [
            ("UK NHSE EPS conformance", "IG SHALL evidence UK NHSE EPS conformance."),
            ("FHIR UK Core compatibility", "IG SHALL be compatible with FHIR UK Core where applicable."),
            ("EU MDR / IVDR mapping", "Where applicable, EU MDR / IVDR mapping SHALL be documented."),
            ("EU AI Act risk class", "Where applicable, EU AI Act risk class SHALL be declared."),
            ("HIPAA mapping", "US deployments SHALL map to HIPAA Privacy/Security Rules."),
            ("ISO 13606 mapping", "Where applicable, ISO 13606 mapping SHALL be documented."),
            ("openEHR mapping", "Where applicable, openEHR mapping SHALL be documented."),
            ("WHO ICD-11 mapping", "Diagnoses SHALL map to WHO ICD-11."),
            ("WHO SMART Guidelines linkage", "Where applicable, WHO SMART Guidelines L2/L3 SHALL be linked."),
            ("DCB 0129 / 0160 applicability note", "Applicability of DCB 0129/0160 SHALL be documented."),
        ],
        "G_BUILD_TOOLING": [
            ("FHIR IG Publisher build", "IG SHALL build via official FHIR IG Publisher."),
            ("Sushi FSH source", "IG SHALL use Sushi FSH as the source of truth."),
            ("CI build per PR", "CI SHALL run IG Publisher per PR."),
            ("Diff vs published version", "CI SHALL diff vs published version."),
            ("Validation report", "CI SHALL emit validation report."),
            ("Broken-link checker", "CI SHALL run broken-link checker."),
            ("QA artefacts archived", "CI SHALL archive QA artefacts."),
            ("Dependency package map", "IG SHALL declare dependency package map."),
            ("Reproducible build", "Build SHALL be reproducible."),
            ("Release tagging", "Releases SHALL be git-tagged."),
        ],
        "H_PUBLICATION": [
            ("Versioned publication URLs", "Versioned publication URLs SHALL be stable."),
            ("Latest URL alias", "A 'latest' URL alias SHALL be maintained."),
            ("Deprecation banners", "Deprecated artefacts SHALL show deprecation banners."),
            ("Migration guides", "Major version changes SHALL ship migration guides."),
            ("Auto-publication CI", "Releases SHALL auto-publish via CI."),
            ("Publication signing", "Published packages SHALL be signed."),
            ("Mirror to FHIR registry", "Published IG SHALL be mirrored to a FHIR registry."),
            ("Public errata page", "Errata SHALL be tracked on a public page."),
            ("Issue tracker public", "Issue tracker SHALL be public."),
            ("Changelog per release", "Each release SHALL ship a changelog."),
        ],
        "I_QUALITY": [
            ("Lint via FHIR IG Publisher",
             "IG SHALL be lint-clean per FHIR IG Publisher."),
            ("Profile coverage of examples",
             "Each profile SHALL be covered by at least one example."),
            ("Citation tests pass",
             "All citation tests SHALL pass (network-permitting)."),
            ("Profile narrative page",
             "Each profile SHALL have a narrative page."),
            ("ImplementationGuide.dependsOn declared",
             "IG SHALL declare dependsOn list."),
            ("ImplementationGuide.global declared",
             "IG SHALL declare global profiles."),
            ("ImplementationGuide.definition.parameter set",
             "IG SHALL set definition.parameter values."),
            ("ImplementationGuide.definition.template set",
             "IG SHALL set definition.template values."),
            ("Examples reference correct profiles",
             "Each example SHALL reference its profile via meta.profile."),
            ("Example bundles validate",
             "Example bundles SHALL validate against their profiles."),
        ],
        "J_REA_BASELINE": [
            ("REA template registry coverage", "IG SHALL trace consumed REA template families."),
            ("REA gap-filler ingestion", "IG SHALL ingest REA gap-filler output."),
            ("REA coverage heatmap export", "IG SHALL emit REA coverage heatmap."),
            ("REA derive_all batch run", "IG SHALL support REA batch runs."),
            ("REA anomaly diagnostics", "IG SHALL expose REA anomaly diagnostics."),
        ],
        "K_CROSS_CUTTING_NFR": [
            ("CONTRIBUTING guide", "IG SHALL ship a CONTRIBUTING guide."),
            ("CODE_OF_CONDUCT", "IG SHALL ship a CODE_OF_CONDUCT."),
            ("LICENSE file", "IG SHALL ship a LICENSE file."),
            ("Security policy", "IG SHALL ship a security policy."),
            ("Documented review cadence", "IG SHALL document review cadence."),
            ("Author + maintainer registry",
             "IG SHALL maintain an author + maintainer registry."),
            ("Comment-period policy",
             "IG SHALL ship a comment-period policy."),
            ("Conformance test compendium",
             "IG SHALL link to a conformance test compendium."),
            ("Public meeting notes", "IG SHALL publish meeting notes."),
            ("Legal liability disclaimer",
             "IG SHALL ship a legal liability disclaimer."),
        ],
    }

    next_id = 1
    used = {r["requirement_id"] for r in reqs}
    for family, items in families.items():
        for title, statement in items:
            while True:
                rid = f"EPSIG-{next_id + 100:03d}"
                next_id += 1
                if rid not in used:
                    break
            used.add(rid)
            reqs.append({
                "requirement_id": rid, "family": family,
                "title": title, "statement": statement,
                "category": "compliance" if family.startswith("F_") else
                            "functional" if family.startswith(("B_", "C_", "D_", "E_")) else
                            "non-functional",
                "source": family.split("_", 1)[1].replace("_", " ").title(),
            })
    return reqs


def main() -> None:
    reqs = _build()
    payload = {
        "schema_version": "BT_REQUIREMENTS_SUPERSET_V1",
        "metadata": {
            "subsystem": "symphonix-eps-ig",
            "requirement_count": len(reqs),
            "families": sorted({r["family"] for r in reqs}),
        },
        "requirements": reqs,
    }
    OUT.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"[OK] {OUT.name} — {len(reqs)} reqs across {len(payload['metadata']['families'])} families")


if __name__ == "__main__":
    main()
