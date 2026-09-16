#!/usr/bin/env bash
# Thin wrapper: the checker lives with the linting-requirements skill.
cd "$(dirname "$0")/.." && exec .claude/skills/linting-requirements/check.sh "${1:-docs/requirements.md}" "${2:-docs/decisions.md}"
