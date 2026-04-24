# Symphonix EPS Implementation Guide

This Implementation Guide (IG) defines the FHIR R4 contract shared by the
`etps` (Electronic Transmission of Prescription System) transport simulator
and the `eps` (Electronic Prescription System) clinical-workflow simulator,
both onboarded onto the Symphonix BulletTrain Health Information Exchange.

The IG is anchored to NHS Digital's [EPS FHIR API family](https://digital.nhs.uk/developer/api-catalogue/electronic-prescription-service-fhir)
and IHE's [Pharm MPD profile](https://build.fhir.org/ig/IHE/pharm-mpd/), and
is generalised for global deployment (US RxNorm, WHO ATC, international
SNOMED CT, openEHR medication archetypes where applicable).

## Structure

- **[Workflows](workflows.html)** — state machines and sequence diagrams for
  the core journeys (happy-path, cancel race, repeat dispensing,
  paediatric safety, discharge push, offline store-and-forward).
- **[Safety](safety.html)** — mapping of every profile and extension to the
  top-10 real-world ePrescribing pain-point controls derived from NHSE,
  HSSIB, JAMIA, APSF, AHRQ, and CPE sources.
- **[Bounded contexts](bounded-contexts.html)** — why ETPS (transport) and
  EPS (clinical) are two simulators rather than one, and the contract
  between them.
- **[Terminology](terminology.html)** — SNOMED CT, dm+d, RxNorm, ATC, UCUM
  binding strategy for global deployment.
- **[References](references.html)** — every cited research paper, standard,
  or safety alert with its canonical URL.
- **[Roadmap](roadmap.html)** — planned expansions (US NCPDP SCRIPT,
  openEHR bindings, WHO DAK alignment).

## Versioning

Semantic versioning: `vMAJOR.MINOR.PATCH`.
- **Major** — breaking profile changes (element cardinality tightened,
  required extension added, ValueSet rebound).
- **Minor** — additive value-set entries, new optional extensions.
- **Patch** — narrative-only edits.

## Consuming the IG

Python:
```python
from pathlib import Path
import json

SD_DIR = Path(__file__).parent / "ig-dependency/symphonix.eps.ig/package"
profile = json.loads((SD_DIR / "StructureDefinition-eps-medication-request.json").read_text())
```

TypeScript / Node:
```ts
import fhir from "symphonix-eps-ig";
const sd = fhir.profile("eps-medication-request");
```

## Compliance surface

Each profile and extension has a corresponding row in the
[DCB0129 safety case](safety.html#dcb0129-mapping) and the
[GDPR Art 30 register](safety.html#gdpr-register). Deployers MUST regenerate
their DCB0160 at each IG release.

No PHI in any example; all identifiers are synthetic (`SYN-*`).
