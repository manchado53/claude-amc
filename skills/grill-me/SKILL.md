---
name: grill-me
description: Interrogate a research experiment (or a Second Brain feature) BEFORE any code or compute. Asks the sharp questions that stop fake ML results — dataset/split, seeds, eval leakage, sanity run, budget — then prints a one-page Brief. Use before starting a training run, an experiment, or a non-trivial build, when you want the goal pinned down first. Reports only; writes no code.
allowed-tools: AskUserQuestion, Read, Grep, Glob, Bash(git remote *), Bash(git rev-parse *)
---

# grill-me — the interviewer

Pin the goal **before** burning GPU/time. This skill interrogates; it does not
build. The deliverable is a tight one-page **Brief**, nothing else.

It exists because the expensive failure in research is a run that was never going
to answer the question — leaky data, one-seed noise, a broken pipeline you didn't
sanity-check. Catch that in five minutes of questions, not twelve hours of compute.

## Hard rules
- **Interrogate, don't implement.** No code, no edits, no experiment kicked off.
- **One concern at a time.** Ask in small batches; follow the answers.
- **Open-ended questions are free text** (hypothesis, metric, dataset). Use the
  AskUserQuestion tool ONLY for branch/tier choices (which mode, which machine,
  NDA yes/no). Don't force a hypothesis into four chips.
- **Don't accept hand-waving.** "I'll use the standard split" → which version, is
  it frozen, any overlap? Push until the answer is reproducible.

## Mode

Pick the mode first (AskUserQuestion): **research** (default) or **asb-dev**.

### Research mode — the questions (ask, in roughly this order)
1. **Hypothesis** — what are you actually testing? (free text, one sentence)
2. **Metric + bar** — what do you measure, how, and what delta over baseline counts
   as *real* given run-to-run variance? (A 0.3-point bump on one seed is noise.)
3. **Baseline** — what are you beating? Where's its number from?
4. **Data — the #1 source of fake results:**
   - Exact dataset + version/hash.
   - How is train/val/test split, and is the split **frozen**?
   - Any overlap/leakage across splits, or with pretrain data, or eval reuse for tuning?
5. **Determinism:**
   - Seed(s)? Single-seed or seed-averaged (how many)?
   - Pinned env — container / conda-lock, torch + CUDA version?
6. **Sanity run FIRST** — what's the 5-minute proxy you run *before* the real job to
   prove the pipeline isn't broken? (overfit one batch / 1% data / 100 steps)
7. **Compute + budget** — laptop vs 5090 vs Rosie/SLURM? Checkpoint cadence + resume
   path? SLURM time-limit vs expected wall-clock — is it requeue-safe?
8. **Decision** — what result changes what you do next? (If nothing, why run it?)
9. *(RL only, optional)* eval on held-out envs/seeds? reward spec sane? sim determinism?

### asb-dev mode — keep it short (research is the priority)
- Real user need — who does this help, concretely?
- Simplest thing that works (YAGNI) — what's the smallest version?
- Privacy tier — `pushed` or 🔒 `local-only`?
- The gate — which inbox→staging→PR path does it flow through?

## Output — the Brief
Print exactly one block, then stop:

```
BRIEF
- Goal:            <one line>
- Hypothesis:      <one line>
- Metric + bar:    <metric, and the delta that counts as real>
- Dataset/split:   <version/hash · frozen? · leakage check>
- Seed/env:        <seeds · #runs · pinned env>
- Sanity run:      <the 5-min check to run first>
- Full run:        <machine · budget · checkpoint/resume>
- Risks:           <the 1-3 ways this result could be a lie>
- Done when:       <definition of done>
- Open:            <anything still unanswered>
```

End with: `Brief only — no code written, no run started.` Next step is usually
`plan-review` on the implementation plan, or just start the sanity run.

## Notes
- If the user can't answer the data/seed questions, that *is* the finding — say so.
- Don't pad. A short Brief the user trusts beats a long interrogation.
