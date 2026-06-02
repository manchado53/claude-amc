# claude-amc

My portable Claude Code configuration. This repo **is** `~/.claude` — it carries
my global instructions, custom skills, agents, and hooks across every machine I
work on (Rosie HPC and a Windows laptop), with machine-specific bits kept separate
so the two never clobber each other.

## Layout

```
~/.claude/                     (this repo)
├── CLAUDE.md                  universal rules — load on every machine
├── CLAUDE.machine.md          live per-machine env facts  (gitignored, generated)
├── machines/
│   ├── rosie.md               Rosie HPC env: SLURM, conda, datasets, log rule
│   └── laptop.md              laptop env (placeholder)
├── setup.sh                   pick this machine's env file (run once per machine)
├── skills/
│   └── keep-or-cut/SKILL.md   triage uncommitted changes (report-only)
├── agents/                    custom subagents
├── hooks/                     event hooks (e.g. prompt counter)
├── settings.json              portable settings (permissions, theme, plugins)
├── settings.local.json        per-machine settings + secrets  (gitignored)
└── .gitignore                 allowlist config; ignore secrets + regenerable junk
```

## How the shared / machine split works

`CLAUDE.md` is identical on every machine. At the bottom it imports one file:

```
@~/.claude/CLAUDE.machine.md
```

That import path is fixed, but its **contents** differ per machine. The real env
files live tracked in `machines/`; `setup.sh` copies the right one into the
gitignored `CLAUDE.machine.md`:

```
        CLAUDE.md  (shared, tracked)
            | @import
            v
   CLAUDE.machine.md   <- gitignored live COPY (never moved/deleted)
        /        \
machines/rosie.md  machines/laptop.md   <- both tracked & backed up
```

Result: one brain everywhere (plan-first, caveman explanations, branch-per-task),
plus each machine's own environment map — and `git pull` never causes a conflict
over the per-machine file.

## Setup on a new machine

```bash
# Rosie / Linux / macOS
git clone git@github.com:manchado53/claude-amc.git ~/.claude
cd ~/.claude && ./setup.sh        # auto-detects host, drops the right env file in

# Windows — run inside Git Bash or WSL (setup.sh is bash)
git clone git@github.com:manchado53/claude-amc.git "$USERPROFILE/.claude"
cd "$USERPROFILE/.claude" && ./setup.sh
```

`setup.sh` sniffs the hostname (Rosie nodes use the `dh-` prefix; Windows shells
report `MINGW*`/`MSYS*`) and asks only if it can't tell. Force a choice with
`./setup.sh rosie` or `./setup.sh laptop`. It only ever **copies** into
`CLAUDE.machine.md`; the tracked source files stay untouched.

If `~/.claude` already exists on the new machine, init/pull into it rather than
cloning over it.

## Workflow rule: branch per task

`main` is sacred — never commit to it directly. Every new idea, task, experiment,
or research thread gets its own branch off `main`, merged back through a PR.

```bash
git checkout main && git pull
git checkout -b feature/my-thing      # intent prefix: feature/ fix/ research/ experiment/ docs/
# ...work, commit...
git push -u origin feature/my-thing
gh pr create --base main --fill
gh pr merge --merge --delete-branch
git checkout main && git pull
```

The only exception is the first commit that bootstraps a brand-new empty repo.

## The `keep-or-cut` skill

Triage a messy working tree **before** committing. It sorts each chunk of
uncommitted change into:

| Verdict | Meaning |
|---------|---------|
| KEEP    | good and intended — ship it |
| CUT     | junk — debug prints, dead code, stray edits |
| FIX     | good idea, but the code has a real problem |
| SPLIT   | unrelated — belongs in its own commit |

It prints a verdict table plus suggested commit groups and **changes nothing** —
no staging, no deleting, no edits. For FIX chunks it points you at the existing
`/code-review` skill for the deep bug hunt. Run it with `/keep-or-cut` in any git
repo. It answers "should this code be here at all?" — the triage step that
`/code-review` (bug-finding) and `/simplify` (polish) don't cover.

## What is and isn't tracked

**Tracked** (shareable): `CLAUDE.md`, `machines/`, `setup.sh`, `skills/`,
`agents/`, `hooks/`, `settings.json`, `.gitignore`, this README.

**Ignored** (secrets / per-machine / regenerable): `.credentials.json`,
`settings.local.json`, `CLAUDE.machine.md`, and all of Claude Code's runtime junk
(`cache/`, `history.jsonl`, `file-history/`, `projects/`, `remote/`, etc.). The
`.gitignore` uses an allowlist — new runtime files dropped into `~/.claude` are
ignored by default, so nothing leaks by accident.
