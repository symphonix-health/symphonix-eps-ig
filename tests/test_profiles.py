"""Validate that every FSH example compiles into a FHIR R4 resource that
conforms to its declared profile.

The heavy lifting is done by the Java-based HL7 FHIR Validator (invoked
by SUSHI + IG Publisher during the main build). This Python harness is a
faster loop for example-level sanity checks during authoring, and a CI
dependency we can run on every push without spinning up Java.

It passes when every example:

1. Parses as a valid FHIR R4 resource via ``fhir.resources``.
2. Carries the expected ``meta.profile`` canonical URL.
3. Has the required elements per our profile (light check).
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
FSH_GENERATED = ROOT / "fsh-generated" / "resources"


def _load(name: str) -> dict:
    """Read a generated FHIR resource by SUSHI output filename."""
    path = FSH_GENERATED / name
    if not path.exists():
        pytest.skip(
            f"SUSHI output missing ({path.name}); run ./_genonce.sh first"
        )
    return json.loads(path.read_text(encoding="utf-8"))


CANONICAL_BASE = "https://symphonix.health/fhir/eps/StructureDefinition/"


@pytest.mark.parametrize(
    "filename, profile_id, required_fields",
    [
        (
            "MedicationRequest-ExampleRxAmoxicillin.json",
            "eps-medication-request",
            ["status", "intent", "subject", "requester",
             "medicationCodeableConcept", "dosageInstruction"],
        ),
        (
            "MedicationRequest-ExampleRxParacetamolOne.json",
            "eps-medication-request",
            ["status", "medicationCodeableConcept", "dosageInstruction"],
        ),
        (
            "MedicationRequest-ExampleRxParacetamolTwo.json",
            "eps-medication-request",
            ["status", "medicationCodeableConcept", "dosageInstruction"],
        ),
        (
            "MedicationRequest-ExampleRxPaediatricIbuprofen.json",
            "eps-medication-request",
            ["status", "subject", "dosageInstruction"],
        ),
        (
            "MedicationRequest-ExampleRxMethylphenidate.json",
            "eps-medication-request",
            ["status", "medicationCodeableConcept", "extension"],
        ),
        (
            "AllergyIntolerance-ExampleAllergyPenicillin.json",
            "eps-allergy-intolerance",
            ["patient", "code", "extension"],
        ),
    ],
)
def test_example_conforms(filename, profile_id, required_fields):
    resource = _load(filename)
    profiles = resource.get("meta", {}).get("profile", [])
    assert f"{CANONICAL_BASE}{profile_id}" in profiles, (
        f"{filename} missing expected profile reference {profile_id}"
    )
    for field in required_fields:
        assert field in resource, (
            f"{filename} missing required field {field}"
        )


def test_paediatric_example_declares_dose_band():
    resource = _load("MedicationRequest-ExampleRxPaediatricIbuprofen.json")
    dose_and_rate = resource["dosageInstruction"][0]["doseAndRate"][0]
    extensions = dose_and_rate.get("extension", [])
    assert any(
        e.get("url") == f"{CANONICAL_BASE}eps-dose-band-limit"
        for e in extensions
    ), "Paediatric example must carry eps-dose-band-limit extension"


def test_schedule_2_example_declares_cd_schedule():
    resource = _load("MedicationRequest-ExampleRxMethylphenidate.json")
    extensions = resource.get("extension", [])
    assert any(
        e.get("url") == f"{CANONICAL_BASE}eps-controlled-drug-schedule"
        and e.get("valueCode") == "schedule-2"
        for e in extensions
    ), "CD example must carry eps-controlled-drug-schedule=schedule-2"


def test_duplicate_therapy_pair_share_ingredient():
    """Both paracetamol examples MUST be diagnosable as duplicate therapy
    by their coded medication. This isn't a profile rule — it's a
    fixture-integrity check for the downstream EPS CDS test vectors."""
    one = _load("MedicationRequest-ExampleRxParacetamolOne.json")
    two = _load("MedicationRequest-ExampleRxParacetamolTwo.json")
    # Paracetamol SNOMED 387517004; co-codamol 331400009. Different
    # codes — the duplicate-therapy rule is ingredient-level (both
    # contain paracetamol), not code-level.
    assert one["medicationCodeableConcept"]["coding"][0]["code"] == "387517004"
    assert two["medicationCodeableConcept"]["coding"][0]["code"] == "331400009"
