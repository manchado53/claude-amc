---
name: plan-review
description: Multi-agent critique of a PLAN or experiment design BEFORE code exists. Launches 3 reviewer agents with distinct lenses (validity / reproducibility / compute-cost) in parallel, then a judge merges them into one ranked verdict. Use to stress-test a research plan or experiment design before building. Different from /code-review, which reviews a diff — this reviews the plan. Reports only.
allowed-tools: Agent, Read, Grep, Glob
---

# plan-review — tear apart the plan before you build it

Reviews a **plan or experiment design**, not a diff. `/code-review` and `/simplify`
already cover code; this catches the design-level mistakes that are cheapest to fix
before any code or compute exists — chiefly: *would this result even be valid?*

## Input
A plan: a file path (e.g. `plans/foo.md`) or pasted text. If none given, ask for one.
Read it, and skim any code/repo it references so reviewers ground their critique.

## How it runs (phase-gated)

### Phase 1 — 3 reviewers IN PARALLEL
Launch **three `Agent` calls in a single message** so they run concurrently. Each
MUST carry an explicit **role prompt** (the lens) — a bare subagent will critique
prose, not ML validity. Give each the plan text + relevant file paths. Use
`subagent_type: general-purpose` (or `Explore` for read-only repos).

- **(a) Validity — "could the result lie?"** Check this list explicitly:
  train/test contamination · eval-set reused for tuning · metric mismatch · dataset
  version drift · single-seed claims (no variance) · cherry-picked checkpoint ·
  test-set peeking · baseline not comparable.
- **(b) Reproducibility.** Pinned env (container/conda-lock, torch+CUDA) · seed
  policy · config logged · deterministic data pipeline · commit pinned · can someone
  else rerun this exactly?
- **(c) Compute-cost / feasibility.** Is the budget real? Is there a cheap sanity
  run before the big job? SLURM time-limit vs wall-clock · checkpoint/resume · is the
  smallest experiment that answers the question actually the one planned?

Each reviewer returns findings as: severity (MUST-FIX / SHOULD / NICE) · the issue ·
a concrete fix.

### Phase 2 — the judge
Launch **one** judge agent with all three reviewers' findings. It:
- Dedupes overlapping findings.
- Ranks MUST-FIX → SHOULD → NICE.
- **Tie-break rule:** on conflict, **correctness/reproducibility outranks
  simplicity.** (Don't drop seed-averaging to save code if it makes the result a lie.)
- Returns a single verdict: **GO** or **FIX-FIRST**, with the must-fixes listed.

## Output
One table, then the verdict:

| # | Lens | Severity | Finding | Fix |
|---|------|----------|---------|-----|
| 1 | validity | MUST-FIX | eval set reused for tuning | hold out a true test split |

Then: `Verdict: FIX-FIRST — resolve #1, #3 before building.` (or `GO`.)

End with: `Review only — no code changed.`

## Notes
- 3 reviewers + 1 judge is the workable size — don't fan out to a fleet.
- This is a *plan* gate. For the resulting diff, use `/code-review` after building.
- If the plan is trivial, say so and do a single pass instead of spawning agents.
