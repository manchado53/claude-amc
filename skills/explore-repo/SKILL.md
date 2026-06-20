---
name: explore-repo
description: Explore and analyze a codebase using read-only commands. Use when understanding project structure, finding relevant code, or learning how something works.
allowed-tools: Read, Grep, Glob, Bash(ls *), Bash(git log *), Bash(git status), Bash(git diff *)
---

# Codebase Explorer

Use ONLY read-only tools (Read, Grep, Glob, ls, git log, git status, git diff) to understand the repository. NEVER write, edit, or modify any files.

## Workflow

1. **Structure first**: Glob to map directory layout and identify key directories
2. **Entry points**: Read README, package.json, docker-compose, config files
3. **Search patterns**: Grep for classes, functions, imports, and cross-references
4. **Deep read**: Follow imports, check types, signatures, and relationships
5. **Synthesize**: Summarize findings with a Mermaid architecture diagram

## Arguments

If `$ARGUMENTS` is provided, focus exploration on that area of the codebase.

## Rules

- NEVER use Write, Edit, or destructive Bash commands
- Start broad, then zoom in
- Reference exact file paths and line numbers
- Provide a Mermaid diagram summarizing architecture
