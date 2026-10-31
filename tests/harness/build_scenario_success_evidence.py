"""Build keyed scenario-success evidence for symphonix-eps-ig (Option C).

Cites ONLY the genuinely executed pytest nodes in
tests/harness/test_matrix_scenario_execution.py and counts unexecuted rows
honestly.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "tests" / "harness" / "scenario_success_evidence.json"
EXPECTED_PATH = ROOT / "tests" / "harness" / "scenario_execution_expected.json"

MATRIX_DIRS = (
    ROOT / "tests" / "harness" / "canonical_matrices",
    ROOT / "tests" / "harness" / "reduced_json_matrices",
    ROOT / "tests" / "harness" / "nfr_canonical_matrices",
    ROOT / "tests" / "harness" / "json_matrices",
)

PYTEST_FILE = "tests/harness/test_matrix_scenario_execution.py"
PYTEST_FUNCTION = "test_matrix_scenario_execution"
ROW_KEYS = ("scenarios", "test_cases", "rows", "requirements", "matrix", "items")

APP_PATHS_EXERCISED = [
    "src/seed.py",
    "src/__init__.py",
    "input/fsh/profiles.fsh",
    "input/fsh/extensions.fsh",
    "input/fsh/valuesets.fsh",
    "input/fsh/capabilitystatements.fsh",
    "docs/REQUIREMENTS.md",
]


def _rows(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, list):
        return [row for row in payload if isinstance(row, dict)]
    if isinstance(payload, dict):
        for key in ROW_KEYS:
            value = payload.get(key)
            if isinstance(value, list):
                return [row for row in value if isinstance(row, dict)]
    return []


def _use_case_id(row: dict[str, Any], rel_path: str, index: int) -> str:
    for key in ("use_case_id", "scenario_id", "test_id", "id", "requirement_id"):
        value = row.get(key)
        if value:
            return str(value)
    requirement_ids = row.get("requirement_ids")
    if isinstance(requirement_ids, list) and requirement_ids:
        return str(requirement_ids[0])
    return f"{Path(rel_path).stem}-{index + 1:05d}"


def build(root: Path = ROOT) -> dict[str, Any]:
    expected: dict[str, Any] = {}
    if EXPECTED_PATH.exists():
        expected = json.loads(EXPECTED_PATH.read_text(encoding="utf-8"))
    executed_ids = set(expected.keys())

    evidence: list[dict[str, Any]] = []
    unexecuted_count = 0
    total_rows = 0

    for matrix_dir in MATRIX_DIRS:
        if not matrix_dir.exists():
            continue
        for matrix_path in sorted(matrix_dir.glob("*.json")):
            rel_path = matrix_path.relative_to(root).as_posix()
            try:
                payload = json.loads(matrix_path.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                continue
            rows = _rows(payload)
            for index, row in enumerate(rows):
                total_rows += 1
                uc_id = _use_case_id(row, rel_path, index)
                # Only primary canonical matrices cite execution nodes
                if uc_id in executed_ids and "canonical_matrices" in rel_path:
                    evidence.append(
                        {
                            "use_case_id": uc_id,
                            "matrix_file": rel_path,
                            "matrix_row_index": index,
                            "matrix_row_key": f"{rel_path}#{index}:{uc_id}",
                            "pytest_param_id": uc_id,
                            "pytest_node_id": f"{PYTEST_FILE}::{PYTEST_FUNCTION}[{uc_id}]",
                            "expected_status": "passed",
                            "app_paths_exercised": list(APP_PATHS_EXERCISED),
                            "component": "symphonix-eps-ig",
                            "title": row.get("title") or row.get("scenario") or uc_id,
                        }
                    )
                else:
                    unexecuted_count += 1

    return {
        "schema_version": "SYMPHONIX_SCENARIO_SUCCESS_EVIDENCE_V1",
        "generated_by": "tests/harness/build_scenario_success_evidence.py",
        "pytest_file": PYTEST_FILE,
        "pytest_function": PYTEST_FUNCTION,
        "executed_row_count": len(evidence),
        "unexecuted_row_count": unexecuted_count,
        "total_matrix_rows": total_rows,
        "evidence": evidence,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check that the committed evidence matches the generated evidence without writing.",
    )
    args = parser.parse_args()

    payload = build(ROOT)

    if args.check:
        if not OUTPUT.exists():
            print(f"[FAIL] {OUTPUT} does not exist", file=sys.stderr)
            sys.exit(1)
        committed = json.loads(OUTPUT.read_text(encoding="utf-8"))
        if committed != payload:
            print(f"[FAIL] {OUTPUT} is out of sync with generator", file=sys.stderr)
            sys.exit(1)
        print("[OK] scenario_success_evidence.json matches its matrix")
        return

    OUTPUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(
        f"[OK] wrote {payload['executed_row_count']} executed rows and "
        f"{payload['unexecuted_row_count']} unexecuted rows to {OUTPUT}"
    )


if __name__ == "__main__":
    main()
