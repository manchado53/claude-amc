---
name: keep-or-cut
description: Triage uncommitted changes — sort each chunk of the working tree into KEEP / CUT / FIX / SPLIT and print a verdict table. Report only; never stages, commits, deletes, or edits. Use before committing a messy working tree to decide what is worth keeping, what is junk, what needs fixing, and what belongs in its own commit.
---

# keep-or-cut

Triage a messy working tree. Decide **what to keep**, not just whether code is buggy.

This skill answers a different question than `/code-review` or `/simplify`. Those ask "is this code buggy or messy?" This asks "**should this code be here at all?**" — the keep/cut decision you make before committing work-in-progress.

## Hard rule: report only

**Never modify anything.** Do not `git add`, `git stage`, `git commit`, `git restore`, `git checkout`, delete files, or edit code. Read-only git commands only. The user acts on the report by hand. If the working tree changes between your first and last command, something is wrong — stop and say so.

## Steps

1. **Confirm a repo.** Run `git rev-parse --is-inside-work-tree`. If not a git repo, tell the user and stop.

2. **Gather the full picture** with read-only commands:
   - `git status --short` — see staged, unstaged, and untracked at a glance.
   - `git diff` — unstaged changes to tracked files.
   - `git diff --staged` — staged changes.
   - For untracked files (the `??` lines in status), read them directly — they have no diff.

3. **Group into chunks by intent.** A chunk is a set of edits that belong to one idea (one feature, one fix, one stray tweak). A chunk can span files; one file can hold several chunks. Group by *what the change is trying to do*, not by file boundary.

4. **Label each chunk** with exactly one verdict:
   - **KEEP** — good and intended. Ship it.
   - **CUT** — junk that should not be committed: debug/print/log statements added for debugging, commented-out dead code, leftover scratch code, accidental/stray edits, committed secrets or local paths, `.env`/credentials, large binaries that look accidental.
   - **FIX** — the idea is good but the code has a real problem (likely bug, missing error handling, broken edge case). Flag it; do not fix it here.
   - **SPLIT** — legitimate but unrelated to the main change; belongs in its own separate commit.

5. **For FIX chunks, defer the bug hunt.** Do not re-derive bugs from scratch. Note that the user should run `/code-review` (the existing, confidence-scored bug finder) on the FIX chunks for a thorough pass. You may give a one-line reason for the FIX label, but `/code-review` owns the deep analysis. This skill owns only the keep/cut/split judgment.

6. **Print one verdict table**, then suggested commit groups. Nothing else changes.

## Output format

Start with a one-line summary: `N chunks — X keep, Y cut, Z fix, W split`.

Then a table:

| # | Verdict | File(s) | What it is | One-line reason |
|---|---------|---------|-----------|-----------------|
| 1 | KEEP | src/auth.py | new token refresh | core of this change, looks intended |
| 2 | CUT | src/auth.py | `print(token)` debug line | leftover debug, don't commit |
| 3 | FIX | src/db.py | retry loop | no backoff — run `/code-review` on this |
| 4 | SPLIT | README.md | unrelated typo fix | own commit, unrelated to auth work |

Then **Suggested commit groups** — how to slice the KEEP/FIX/SPLIT chunks into clean commits, e.g.:
- Commit A: chunks 1, 3 (after fixing) — "add token refresh"
- Commit B: chunk 4 — "fix README typo"
- Drop before committing: chunk 2

End with: `Report only — nothing was staged, changed, or deleted.`

## Notes

- Be decisive. A short table the user trusts beats a long hedge. If genuinely unsure between KEEP and CUT, label it FIX and say why.
- Don't nitpick style — that's `/simplify`'s job. Focus on the keep/cut/split call.
- Honor the repo's own `CLAUDE.md` if present (e.g. a debug print might be intentional logging there).
- If the working tree is clean (nothing uncommitted), say so and stop.
