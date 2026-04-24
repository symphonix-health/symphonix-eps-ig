# ADR-0001: Multi-Agent Coordination via CAID

## Status
Accepted

## Date
2026-04-24

## Context
Building symphonix-eps-ig requires coordinating multiple development tasks
with file-level dependencies. Single-agent approaches plateau quickly --
doubling iterations yields marginal or negative improvement (CAID paper
Section 3.7). The system needs parallel execution with conflict avoidance.

## Decision
Adopt CAID (Centralized Asynchronous Isolated Delegation) multi-agent
coordination with:
- Manager agent for task decomposition and merge orchestration
- 2-4 engineer agents for parallel implementation
- Git worktree isolation for each engineer
- Dependency-aware scheduling via topological sort

## Rationale
- CAID improves accuracy 26.7% on PaperBench, 14.3% on Commit0 vs single-agent
- Worktree isolation outperforms soft isolation (63.3% vs 55.5%, Table 3)
- Optimal parallelism is 2-4 engineers; N=8 degrades to 44.3% (Figure 3)
- Manager delegation quality is the #1 factor (8.7% vs 34.3%, Section 4.3)

## Consequences

### Positive
- Parallel execution reduces wall-clock time for independent tasks
- File-level isolation prevents merge conflicts
- Dependency graph ensures correct execution ordering

### Negative
- Higher API cost than single-agent (multi-agent overhead)
- Integration complexity at merge time
- Manager delegation errors amplify to all downstream tasks

## References
- Geng & Neubig, "Effective Strategies for Asynchronous Software Engineering
  Agents", arXiv 2603.21489
- Agyn (arXiv 2602.01465): team-based roles achieving 72.2% SWE-bench
- Self-Organizing MAS (arXiv 2603.25928): Strategy/Execution/Verification phases
