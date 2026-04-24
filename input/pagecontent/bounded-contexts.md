# Bounded Contexts: ETPS vs EPS

## Why two simulators?

NHS literature uses "EPS" as the product name and "ETP" as the generic
concept; in practice they are the same thing. But the Symphonix BulletTrain
HIE models simulators per actor and per bounded context. Separating the
transport layer from the clinical-workflow layer gives three benefits:

1. **Blast-radius isolation.** A transport outage cannot take down
   clinical-workflow test scenarios.
2. **Different scaling profiles.** ETPS is a high-throughput idempotent
   message router; EPS is a stateful clinical engine with UI.
3. **Parallel engineer worktrees.** CAID's L-242 isolation assumes
   per-project worktrees; a combined repo would serialise engineer
   delegation.

## ETPS responsibilities

- Ingest signed bundles via `$process-message`.
- Verify JWS + profile-validate against this IG.
- Persist authoritative state (the Spine-analogue).
- Route to nominated dispenser or hold for opportunistic pull.
- Accept dispense notifications and reconcile against prescription state.
- Reconcile cancel-vs-dispense races.
- Expose the Prescription Tracker read API.
- Offline store-and-forward via `IdempotencyKey`.
- Tamper-evident hash-chained audit (`EpsAuditEvent.HashChainLink`).

ETPS does **not** enforce CDS rules. It passes signed bundles through
unchanged once JWS is verified.

## EPS responsibilities

- Prescription lifecycle state machine.
- Clinical Decision Support: duplicate-therapy, DDI, drug-allergy,
  paediatric dose bands.
- Repeat-dispensing (eRD) engine.
- Dispense reconciliation with formulary.
- Discharge push to community pharmacy.
- Controlled-drug register.
- Clinical UI for prescribers and pharmacists.

## Contract between them

Both simulators load this IG at startup. They communicate via ETPS's
FHIR messaging operations. Integration diagrams are in
[workflows.html](workflows.html).
