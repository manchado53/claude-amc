---
name: log-experiment
description: Record a finished ML experiment so it is reproducible and (optionally) compounds. Writes a FULL record next to the code in the research repo (commit, env, seed, config, metric, lesson), and optionally distills ONE generalizable lesson into the Second Brain — routed through the brain's own NDA gate so Direct Supply / proprietary work can never leak. Use after a training run or experiment to capture what happened and what you learned.
allowed-tools: Read, Grep, Glob, Bash(git rev-parse *), Bash(git status *), Bash(git remote *), Bash(python *), Write, AskUserQuestion
---

# log-experiment — repo-first record, engine-gated lesson

Two homes, two purposes:

```
FULL RECORD  -> the research repo   (always; reproducibility lives next to the code)
ONE LESSON   -> the Second Brain    (optional, opt-in; only the wisdom that generalizes)
```

## Part 1 — the full record (always)

Write `<repo>/experiments/<date>-<slug>-<shortid>.md` (create `experiments/` if
missing; **never overwrite** — the `<shortid>` keeps same-day runs distinct).

Pin the run, or it isn't reproducible. Gather, don't guess:
- **Commit:** `git rev-parse --short HEAD`, **plus dirty flag** from
  `git status --porcelain` — if dirty, the recorded commit is a lie, so **warn and
  record `dirty: true`**.
- **Env:** torch / CUDA versions or the container/image tag.
- **Dataset:** name + version/hash; the split used.
- **Seed(s)** + how many runs / variance.

Record body:
```
# <title>
- Commit: <sha> (dirty: yes/no)   Env: <torch/cuda or image>
- Dataset: <name@version>   Seed(s): <…>   Runs: <n>
- Hypothesis: <one line>
- Config: <model · key hyperparams>
- Command / SLURM job: <the exact invocation>
- Metric vs baseline: <metric: result ± var  vs  baseline>
- Checkpoint used: <final | best>   Run completed: <yes/no>
- What worked:
- What broke:
- Lesson: <the one generalizable line — this is the compounding payload>
- Next:
```
Date via the engine clock (below), never typed by the model.

## Part 2 — the lesson into the Second Brain (optional, opt-in, gated)

**Off by default.** Only run if the user opts in this invocation. **Never hand-roll
the date, filename, frontmatter, or the NDA decision** — call the brain engine, which
already routes proprietary work to a local-only lane that is never pushed.

Run this (the engine decides the lane; NDA repos can't reach GitHub):

```bash
python - "$REPO_PATH" <<'PY'
import sys
from brain import clock, identity, security, config
from brain.adapters.base import Note, write_note
from brain.adapters.session import target_dir

repo = sys.argv[1]
project = identity.project_identity(repo)          # normalized git-remote key (D4)
body = """<the one-line lesson + 2-3 lines of context>"""

# fail-closed NDA / sensitivity gate — same logic the capture pipeline uses
nda = project in config.CONFIDENTIAL_PROJECTS or project.startswith("local/")
tier = "local-only" if (nda or security.is_content_sensitive(body)) else "pushed"

note = Note(
    meta={
        "source": "experiment",
        "project": project,
        "date": clock.today(),
        "captured": clock.now_iso(),
        "tier": tier,
        "untrusted": False,
        "flagged": [],
    },
    body=body,
)
path = write_note(note, target_dir(note))          # local-only -> LOCAL_INBOX_DIR (gitignored)
print(f"wrote {tier} lesson -> {path}")
PY
```

Rules for the lesson:
- **Detect NDA by remote, not by asking.** `project_identity` + `CONFIDENTIAL_PROJECTS`
  is the gate. The user opt-in only chooses *whether to distill at all* — it can
  never force a proprietary lesson to the pushed lane.
- **Fail-closed:** no remote / `local/...` fallback → treat as local-only.
- Keep the lesson **generalizable** ("lr > 3e-4 diverges on this model class"), not a
  run dump — the full record already holds the details.
- Add a back-pointer to the repo record **only when `tier == "pushed"`** (a local-only
  lesson must not name a proprietary repo path).

> The engine lives in the synced brain clone — run the snippet with that on the
> Python path (e.g. `cwd ~/.asb/sync-clone`, where `brain` is importable).

## Output
Report: the repo record path; and if distilled, the lane + brain path. For a Direct
Supply / proprietary repo, state plainly that the lesson stayed local-only.

End with: `Record written. Lesson: <pushed | local-only | skipped>.`

## Notes
- Repo record is the deliverable; the brain lesson is a bonus, never the point.
- If `experiments/` is the wrong home for a given repo, ask once where records go.
