"""V-Model L3 system/e2e coverage for canonical harness contracts."""

from __future__ import annotations

import json
from pathlib import Path

HARNESS = Path(__file__).resolve().parents[1]


def _load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def test_l3_system_contracts_have_observable_triggers_and_outcomes() -> None:
    checked = 0
    missing: list[str] = []
    for path in sorted((HARNESS / "json_matrices").glob("*_scenarios.json")):
        doc = _load(path)
        is_aux = doc.get("matrix_kind") == "auxiliary"
        for index, scenario in enumerate(doc.get("scenarios", []), start=1):
            checked += 1
            if is_aux:
                if not scenario.get("title") or not scenario.get("requirement_ids"):
                    missing.append(f"{path.name}[{index}] missing auxiliary title/requirement_ids")
                continue
            has_trigger = scenario.get("trigger") is not None or scenario.get("scenario") is not None
            has_outcomes = scenario.get("expected_outputs") is not None or scenario.get("expected_outcomes") is not None
            if not has_trigger:
                missing.append(f"{path.name}[{index}] missing trigger/scenario")
            if not has_outcomes:
                missing.append(f"{path.name}[{index}] missing expected_outputs/expected_outcomes")

    assert checked
    assert not missing, "Incomplete system contracts: " + ", ".join(missing[:10])
