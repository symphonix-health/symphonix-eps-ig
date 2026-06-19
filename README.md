# Symphonix EPS Implementation Guide


<!-- symphonix-health-ecosystem:start -->
## Symphonix Health ecosystem

<p>
  <a href="https://github.com/symphonix-health"><img alt="Symphonix Health" src="https://img.shields.io/badge/Symphonix_Health-clinical_sibling-6366F1?style=flat-square" /></a>
  <a href="https://github.com/symphonix-health/symphonix-health.github.io/blob/main/docs/system-catalogue.md"><img alt="System catalogue" src="https://img.shields.io/badge/catalogue-43_repos-14919B?style=flat-square" /></a>
</p>

| Field | Value |
|---|---|
| Organisation | `Symphonix-Health` |
| Ecosystem layer | Clinical sibling system |
| Repository role | FHIR R4 implementation guide for electronic prescription workflows. |
| Catalogue | [Symphonix system catalogue](https://github.com/symphonix-health/symphonix-health.github.io/blob/main/docs/system-catalogue.md) |
| Scope basis | Current catalogue snapshot: 43 catalogued repositories; forked/imported repos are excluded. |
| Evidence rule | Catalogue presence is orientation only. Use repo-local tests, CAID artefacts, seeded data, and runbooks for readiness claims. |
<!-- symphonix-health-ecosystem:end -->

FHIR R4 Implementation Guide for the Symphonix Electronic Prescription Service —
the shared contract between the `etps` transport simulator and the `eps`
clinical-workflow simulator on the Symphonix BulletTrain Health Information
Exchange.

- **Canonical URL**: `https://symphonix.health/fhir/eps`
- **FHIR version**: 4.0.1
- **Package id**: `symphonix.eps.ig`
- **Licence**: CC0-1.0

## What is this?

A **publication artefact**, not an application. The IG defines every wire
shape (profiles, extensions, ValueSets, CapabilityStatements, example
bundles) that the ETPS and EPS simulators must agree on.

Anchored to [NHS Digital's EPS FHIR API family](https://digital.nhs.uk/developer/api-catalogue/electronic-prescription-service-fhir)
and [IHE Pharm MPD](https://build.fhir.org/ig/IHE/pharm-mpd/). Generalised
for global deployment (SNOMED CT, dm+d, RxNorm, ATC, UCUM).

Every profile maps to a specific real-world ePrescribing pain-point control
documented in `input/pagecontent/safety.md`.

## Build

Prerequisites:
- Node 20+ (for SUSHI: `npm install -g fsh-sushi`)
- Java 17+ (for IG Publisher — auto-downloaded by `_updatePublisher.sh`)
- Python 3.12+ (for the validator harness)

```sh
./_updatePublisher.sh        # fetches latest HL7 IG Publisher JAR
./_genonce.sh                # runs SUSHI + IG Publisher
open output/index.html
```

Windows PowerShell equivalents: `_updatePublisher.bat`, `_genonce.bat`.

## Test

```sh
pip install -e .[dev]
pytest tests/                # validates every example against its profile
                             # + checks every citation URL resolves (L-244)
```

## Consume

Python — after SUSHI emits StructureDefinitions to `fsh-generated/resources/`:

```python
from pathlib import Path
import json
sd_dir = Path("fsh-generated/resources")
profile = json.loads((sd_dir / "StructureDefinition-eps-medication-request.json").read_text())
assert profile["resourceType"] == "StructureDefinition"
```

TypeScript / Node — publish the IG `package.tgz` to your registry; then:

```ts
import fhir from "symphonix-eps-ig";
const sd = fhir.profile("eps-medication-request");
```

## Scope

**In scope**: FHIR profiles, extensions, ValueSets, CapabilityStatements,
example instances, narrative pages, citation registry.

**Out of scope**: runnable application code (lives in `etps` and `eps`
sibling repos), US NCPDP SCRIPT wire format (v2+), openEHR archetype
authoring (v2+), mobile SDKs.

## Compliance surface

- **DCB0129** (clinical risk in design): starter hazard sheet in
  `input/pagecontent/safety.md`. Manufacturers extend with product-specific
  hazards.
- **DCB0160** (clinical risk in deployment): deployers regenerate at each
  IG release.
- **GDPR / UK DPA 2018**: Art 30 register starter in `safety.md`; deployers
  localise and attach to their DPIA.
- **UK MDR 2002 + MHRA**: ePMA medical-device posture documented; deployers
  complete their own classification statement.

## Related repos

- `etps` — NHS Spine-analogue transport simulator (sibling directory)
- `eps` — clinical-workflow simulator with top-10 pain-point controls
- `caid-agent` — the CAID SDLC orchestrator that generates the simulators

All three are sibling directories under the `github/` workspace root; none
is nested inside another (L-257 compliant).

## Versioning

Semantic versioning: see `input/pagecontent/roadmap.md`. Breaking profile
changes bump major; additive ValueSet entries bump minor.

<!-- bullettrain-v1-matrix:start -->
## BulletTrain 14-column functional matrices

Functional use-case projections are stored in `tests/harness/reduced_json_matrices/*.14col.json`. They preserve the source V2 scenario IDs and requirement IDs, and `tests/test_bullettrain_v1_matrix.py` checks the 14-column schema, source-row parity, and `tests/harness/requirements_matrix.json` coverage. Existing service and integration suites remain the runtime evidence for real service behavior.
<!-- bullettrain-v1-matrix:end -->
