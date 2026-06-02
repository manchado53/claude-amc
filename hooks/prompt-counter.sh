#!/bin/bash
# ~/.claude/hooks/prompt-counter.sh
# Fires on every Stop event. At THRESHOLD, creates a trigger file so the
# prompt hook knows to run the project-memory subagent. Always exits 0 (silent).

THRESHOLD=20

# Per-project counter keyed by git root (falls back to cwd)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_HASH=$(echo "$PROJECT_ROOT" | md5sum | cut -c1-8)
COUNTER_FILE="$HOME/.claude/prompt_count_${PROJECT_HASH}"
TRIGGER_FILE="$HOME/.claude/memory_trigger"

# Initialize counter if missing
if [ ! -f "$COUNTER_FILE" ]; then
  echo "0" > "$COUNTER_FILE"
fi

COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))

if [ "$COUNT" -ge "$THRESHOLD" ]; then
  echo "0" > "$COUNTER_FILE"
  touch "$TRIGGER_FILE"
else
  echo "$COUNT" > "$COUNTER_FILE"
fi

exit 0
