# IG Update Cascade — Frontend & Service Responsibilities

When this IG bumps a version, every consumer needs to know **what changes
where**. This page is the authoritative cascade: an IG editor changes a
profile / ValueSet / extension; downstream services + frontends pick the
change up either automatically (via reference endpoints) or via
coordinated code releases.

The pattern below is named after CAID lesson **L-120 ("no hardcoded
dropdowns")**: every UI dropdown sourced from a `/api/reference/*`
endpoint. Hardcoded enums force coordinated frontend releases on every
ValueSet change; reference-endpoint mediation makes most IG bumps
runtime-zero-cost for UIs.

## Change classes

| IG change class | Coordination required | Examples |
|---|---|---|
| **Additive** (new optional field, new ValueSet entry, new extension) | Minor IG bump. Most consumers pick up at runtime via reference endpoints; CDS-engine code change is the only hard dependency. | New `eps-allergen-group` value `cephalosporin-class-extended` |
| **Tightening** (cardinality 1..* → 1..1, optional → required, narrow enum) | Major IG bump. ALL consumers re-release coordinated. | `MedicationRequest.dosageInstruction` cardinality changes |
| **Removal** (field, ValueSet entry, extension) | Major IG bump + deprecation window. ALL consumers re-release. | Removing `eps-nomination-type` value `legacy-fax` |

## Reference scenario: NHSE NatPSA Nov 2025 → cephalosporin cross-reactivity

The walked-through example below is the **additive** class — an NHSE
National Patient Safety Alert introduces a new allergen-group value
`cephalosporin-class-extended` with documented partial cross-reactivity
to penicillin-class allergies (~10% empirical rate per BNF guidance).

### IG (this repo) — originator

| File | Change |
|---|---|
| `input/fsh/valuesets.fsh` | Add `cephalosporin-class-extended` code to `eps-allergen-group` CodeSystem + ValueSet |
| `input/fsh/examples.fsh` | Add example `AllergyIntolerance` carrying the new allergen-group |
| `input/pagecontent/safety.md` | Update row 1 (allergy grouping) to reference cross-reactivity + cite the NatPSA URL |
| `input/pagecontent/references.md` | Add the NatPSA URL |
| `sushi-config.yaml` | Bump `version: 0.2.0` |
| `tests/test_profiles.py` | Add positive example validation for new value |
| `tests/test_citations.py` | Live URL resolves (auto-runs in CI) |

Release: tag `v0.2.0`, GitHub Pages auto-publishes.

---

### `eps` (clinical workflow) — required code change

This is the only sibling that needs **engineer-time work** on this
class of change. Wiring per-component:

| Path in `eps/` | Responsibility | Required edit |
|---|---|---|
| `pyproject.toml` | IG dependency pin | Bump to `symphonix-eps-ig ^0.2.0` |
| `data/allergen_groups.yaml` | Reference-data seed | Add `cephalosporin-class-extended` with member SNOMED codes (cefalexin, cefuroxime, ceftriaxone) |
| `data/ddi/cross_reactivity.yaml` | Cross-reactivity rule data | Add penicillin↔cephalosporin partial-overlap rule (10% rate, advisory severity) |
| `services/cds-engine/src/cds/rules/allergy_group_match.yaml` | CDS rule logic | New clause: penicillin-allergic patient + cephalosporin prescription → advisory alert; cephalosporin-allergic + cephalosporin → hard-stop |
| `services/cds-engine/src/cds/rules/cross_reactivity.py` | Severity tiering | Implement BNF cross-reactivity advisory weighting |
| `services/cds-engine/tests/harness/json_matrices/cds-engine_scenarios.json` | L-284 canonical scenarios | **+10 new rows** (8/1/1 ratio at this delta; preserves overall 85/10/5): cephalosporin-allergic + ceftriaxone (hard-stop), penicillin-allergic + cefalexin (advisory), penicillin-allergic + ceftriaxone (advisory), confirmed-prior-tolerance suppress, etc. |
| `docs/SAFETY_CASE.md` | DCB0129 hazard line | New row: H-12 cephalosporin cross-reactivity → control = CDS rule + advisory alert + recorded clinician acknowledgement |
| `docs/DCB0160.md` | Deployer template | Re-run note: rule update requires fresh DCB0160 sign-off |
| `services/cds-engine/api/reference/allergen-groups` | Reference endpoint | Auto-pickup for all UIs once data file updated |

Release: `eps v0.2.0`, coordinated with IG `v0.2.0`.

---

### `etps` (transport) — minimal

Transport doesn't make clinical decisions — it just validates signed
bundles against the IG. Single edit:

| Path in `etps/` | Responsibility | Required edit |
|---|---|---|
| `pyproject.toml` | IG dependency pin | Bump to `symphonix-eps-ig ^0.2.0` so `MedicationRequest` validation accepts the new allergen-group value |

Release: `etps v0.1.x` patch (no behaviour change). Optional — if the
ETPS validation cache is loaded at startup from the published IG, no
release is needed at all.

---

### Frontend consumers — runtime auto-pickup *if* on the L-120 pattern

The **only** UI work the additive change requires per consumer is
verifying the reference endpoint is being used (not hardcoded).
Concrete component-by-component:

#### `provider-portal/frontend/src/`

| Component | Reference endpoint it should fetch | Auto-pickup on this change? |
|---|---|---|
| `pages/AllergyAuthoring.tsx` (allergy entry) | `GET /api/reference/allergen-groups` | **Yes** |
| `pages/Prescribe.tsx` (CDS alert rendering) | `GET /api/reference/cds-alert-rules` (or alerts streamed inline on the prescription response) | Yes |
| `components/AllergyChip.tsx` (display badge) | Group → display-label map fetched at startup | Yes |
| `lib/labels.ts` if it hardcodes group → label | **No** — code change required (anti-pattern; flagged by L-120 / L-261 form-utility check) | No |

UI test additions (Playwright):

```ts
// frontend/e2e/allergy.spec.ts
test('cephalosporin-class-extended appears in allergen-group dropdown', async ({ page }) => {
  await page.goto('/allergy/new');
  await expect(page.getByRole('combobox', { name: 'Allergen group' }))
    .toContainText('Cephalosporin class (extended)');
});
test('cephalosporin alert renders with NatPSA evidence link', async ({ page }) => {
  // patient has penicillin-class allergy, prescribe cefalexin
  await page.goto('/prescribe?patient=SYN-P-0001&drug=cefalexin');
  await expect(page.getByRole('alert', { name: /cross-reactivity/i }))
    .toBeVisible();
  await expect(page.getByRole('link', { name: /NatPSA/i })).toHaveAttribute(
    'href', /england\.nhs\.uk.*natpsa/,
  );
});
```

#### `pharmacy-system/frontend/src/`

| Component | Reference endpoint | Auto-pickup? |
|---|---|---|
| `pages/ClinicalReview.tsx` (alert queue) | Renders `cds_alerts[]` from EPS dispense-side response | **Yes** |
| `pages/Dispense.tsx` | Same | Yes |
| `components/AlertCard.tsx` | Group → severity-style mapper from `/api/reference/cds-alert-rules` | Yes |

UI test addition: pharmacist reviews the new advisory class and can record an intervention.

#### `citizen-portal/frontend/src/`

| Component | Reference endpoint | Auto-pickup? |
|---|---|---|
| `pages/MyAllergies.tsx` | `GET /api/reference/allergen-groups` for display labels | **Yes** |
| `pages/MyPrescriptions.tsx` | Renders alert summaries (read-only) | Yes |

#### `etps/frontend/src/` (ops console)

| Component | Required edit | Why |
|---|---|---|
| `pages/Ops.tsx` (Queue / Audit / Dead-letter) | None | Ops console is transport-level; doesn't render allergen labels |

#### `eps/clinical-console/src/`

| Component | Reference endpoint | Auto-pickup? |
|---|---|---|
| `pages/Prescribe.tsx` | `GET /api/reference/allergen-groups` | **Yes** |
| `pages/ClinicalReview.tsx` | Inline `cds_alerts[]` from prescription state response | Yes |
| `pages/AllergyManager.tsx` | `GET /api/reference/allergen-groups` | Yes |

---

## Frontend wiring contract (L-120 enforcement)

Every consumer simulator MUST source these enums from `/api/reference/*`,
NEVER hardcode them. The CAID Phase 4 verify already enforces L-120 via
the `_check_frontend_pages_wired()` static check; flagged hardcoded
allergen lists, schedule lists, status lists all fail Phase 4 closed.

| Enum | Reference endpoint | Owner sim |
|---|---|---|
| `allergen-groups` | `GET /api/reference/allergen-groups` | EPS |
| `cd-schedules` | `GET /api/reference/controlled-drug-schedules` | EPS |
| `cancellation-reasons` | `GET /api/reference/cancellation-reasons` | ETPS |
| `prescription-statuses` | `GET /api/reference/prescription-statuses` | ETPS |
| `webhook-statuses` | `GET /api/reference/webhook-statuses` | ETPS |
| `actor-roles` | `GET /api/reference/actor-roles` | ETPS |

---

## Operator checklist for any IG additive bump

1. IG editor: change FSH + bump version + tag.
2. EPS engineer: data file + CDS rule + matrix scenarios (≥10 new rows
   per allergen-group, 85/10/5; L-284 enforces the canonical shape).
3. EPS releases new version pinning new IG.
4. ETPS pins new IG (no code change in nominal additive case).
5. Run **all** BulletTrain journeys (`journeys/runner.py all`) and
   confirm no regression.
6. Clinical Safety Officer signs off DCB0160 deployer change for each
   deployment.
7. Frontend consumers: no code change if reference endpoints are used;
   smoke test the dropdown via Playwright headed + headless to confirm
   the new option renders.

---

## Where to add new test scenarios

For each new allergen-group / drug-class / interaction added by the IG,
the canonical 14-column matrix at
`eps/services/cds-engine/tests/harness/json_matrices/cds-engine_scenarios.json`
MUST gain ≥10 new rows mapped to the new clinical concept, distributed
85/10/5 positive/negative/edge per L-284. CAID engineer prompts already
mandate this via the L-284 canonical-matrix block. The L-284 Phase 4
gate fails the build if the new rows are missing.

For frontend behaviour, the corresponding Playwright spec MUST gain ≥1
positive + ≥1 negative scenario asserting the new allergen-group renders
in the dropdown and the new alert surfaces correctly.
