from __future__ import annotations

import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIREMENT_IDS = [
    "EPSIG-101",
    "EPSIG-102",
    "EPSIG-103",
    "EPSIG-104",
    "EPSIG-105",
    "EPSIG-112",
    "EPSIG-113",
    "EPSIG-121",
    "EPSIG-130",
    "EPSIG-137",
    "EPSIG-142",
    "EPSIG-148",
    "FR-EPSIG-001",
    "FR-EPSIG-002",
    "FR-EPSIG-003",
    "FR-EPSIG-004",
    "FR-EPSIG-005",
    "FR-EPSIG-101",
    "FR-EPSIG-102",
    "FR-EPSIG-103",
    "FR-EPSIG-104",
    "FR-EPSIG-105",
    "FR-EPSIG-106",
    "FR-EPSIG-107",
    "FR-EPSIG-108",
    "FR-EPSIG-109",
    "FR-EPSIG-110",
    "FR-EPSIG-111",
    "FR-EPSIG-112",
    "FR-EPSIG-113",
    "FR-EPSIG-114",
    "FR-EPSIG-115",
    "FR-EPSIG-116",
    "FR-EPSIG-117",
    "FR-EPSIG-118",
    "FR-EPSIG-119",
    "FR-EPSIG-120",
    "FR-EPSIG-121",
    "FR-EPSIG-122",
    "FR-EPSIG-123",
    "FR-EPSIG-124",
    "FR-EPSIG-125",
    "FR-EPSIG-126",
    "FR-EPSIG-127",
    "FR-EPSIG-128",
    "FR-EPSIG-129",
    "FR-EPSIG-130",
    "FR-EPSIG-131",
    "FR-EPSIG-132",
    "FR-EPSIG-133",
    "FR-EPSIG-134",
    "FR-EPSIG-135",
    "FR-EPSIG-136",
    "FR-EPSIG-137",
    "FR-EPSIG-138",
    "FR-EPSIG-139",
    "FR-EPSIG-140",
    "FR-EPSIG-141",
    "FR-EPSIG-142",
    "FR-EPSIG-143",
    "FR-EPSIG-144",
    "FR-EPSIG-145",
    "FR-EPSIG-146",
    "FR-EPSIG-147",
    "FR-EPSIG-148",
    "FR-EPSIG-149",
    "FR-EPSIG-150",
    "FR-EPSIG-151",
    "FR-EPSIG-152",
    "FR-EPSIG-153",
    "FR-EPSIG-154",
    "FR-EPSIG-155",
    "FR-EPSIG-156",
    "FR-EPSIG-157",
    "FR-EPSIG-158",
    "FR-EPSIG-159",
    "FR-EPSIG-160",
    "FR-EPSIG-161",
    "FR-EPSIG-162",
    "FR-EPSIG-163",
    "FR-EPSIG-164",
    "FR-EPSIG-165",
    "FR-EPSIG-166",
    "FR-EPSIG-167",
    "FR-EPSIG-168",
    "FR-EPSIG-169",
    "FR-EPSIG-170",
    "FR-EPSIG-171",
    "FR-EPSIG-172",
    "FR-EPSIG-173",
    "FR-EPSIG-174",
    "FR-EPSIG-175",
    "FR-EPSIG-176",
    "FR-EPSIG-177",
    "FR-EPSIG-178",
    "FR-EPSIG-179",
    "FR-EPSIG-180",
    "FR-EPSIG-181",
    "FR-EPSIG-182",
    "FR-EPSIG-183",
    "FR-EPSIG-184",
    "FR-EPSIG-185",
    "FR-EPSIG-186",
    "FR-EPSIG-187",
    "FR-EPSIG-188",
    "FR-EPSIG-189",
    "FR-EPSIG-190",
    "FR-EPSIG-191",
    "FR-EPSIG-192",
    "FR-EPSIG-193",
    "FR-EPSIG-194",
    "FR-EPSIG-195",
    "NFR-CO-001",
    "NFR-CO-002",
    "NFR-FL-001",
    "NFR-FL-002",
    "NFR-IC-001",
    "NFR-IC-002",
    "NFR-MA-001",
    "NFR-MA-002",
    "NFR-MA-003",
    "NFR-MA-004",
    "NFR-PE-001",
    "NFR-RE-001",
    "NFR-RE-002",
    "NFR-RE-003",
    "NFR-SA-001",
    "NFR-SA-002",
    "NFR-SE-001",
    "NFR-SE-002",
    "NFR-SE-003",
    "NFR-SE-004",
    "NFR-SE-005",
    "REQ-REA-0032"
]


def _load_traceability() -> dict:
    module_path = ROOT / "seeded_alignment_trace.py"
    spec = importlib.util.spec_from_file_location("seeded_alignment_trace", module_path)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.TRACEABILITY


def _load_json(path: str) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def test_seeded_alignment_traceability_paths_exist() -> None:
    traceability = _load_traceability()
    assert traceability, "seeded alignment traceability map is empty"
    assert set(REQUIREMENT_IDS) == set(traceability)

    for requirement_id, evidence in traceability.items():
        assert requirement_id
        for key in (
            "specification_paths",
            "use_case_paths",
            "implementation_paths",
            "test_paths",
            "seed_paths",
            "documentation_paths",
        ):
            paths = evidence.get(key)
            assert paths, f"{requirement_id} has no {key}"
            for rel_path in paths:
                path = ROOT / rel_path
                message = f"{requirement_id} missing {key}: {rel_path}"
                assert path.exists(), message


def test_seeded_alignment_matrix_and_seed_cover_every_requirement() -> None:
    requirement_ids = set(REQUIREMENT_IDS)

    matrix = _load_json(
        "tests/harness/reduced_json_matrices/seeded_alignment_trace.14col.json"
    )
    cases = matrix["test_cases"]
    matrix_ids = {
        tag
        for case in cases
        for tag in case.get("tags", [])
        if tag in requirement_ids
    }
    assert matrix_ids == requirement_ids

    seed_data = _load_json("seed_data/seeded_requirement_traceability.json")
    seed_ids = {row["requirement_id"] for row in seed_data["requirements"]}
    assert seed_ids == requirement_ids

    spec_text = (
        ROOT / "docs/specifications/seeded-requirement-traceability.md"
    ).read_text(encoding="utf-8")
    missing_from_spec = [rid for rid in requirement_ids if rid not in spec_text]
    assert not missing_from_spec
