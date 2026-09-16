#!/usr/bin/env bash
# Mechanical checks for a requirements document. Part of the linting-requirements skill.
# Usage: check.sh <requirements.md> [decisions.md]
#   Exit 0 when every check passes. Prints PASS/FAIL lines and an INFO count line.
#   A section whose heading contains "Definitions" is exempt from the word checks,
#   as are quoted lines starting with ">".
set -u
BANNED='\b(near|away|far|adjacent|shortly|sufficient|insufficient|likely|such as|including|appropriate|appropriately|explicitly|explicit|silently|quickly|large|small|etc)\b'
ACTORS='\b(the user|authorized user|authorized users|an authorized)\b'
if [ "${1:-}" = "--help" ] || [ -z "${1:-}" ]; then
  sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
  echo "Banned words (lowercase, whole word): $BANNED"
  echo "Unnamed actors (any case): $ACTORS"
  echo "Requirement lines: **FR-nnn.** or **NFR-nnn.** at line start, each followed by a 'Verify by:' line."
  exit 0
fi
REQ="$1"
DEC="${2:-}"
[ -f "$REQ" ] || { echo "no such file: $REQ"; exit 2; }
fail=0
ok()  { echo "PASS: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

body() {
  awk '
    /^## .*Definitions/ { skip=1; next }
    /^## /              { skip=0 }
    skip                { next }
    /^>/                { next }
    { print }
  ' "$REQ"
}

hits=$(body | grep -nE "$BANNED" || true)
if [ -z "$hits" ]; then ok "no banned words outside Definitions"; else bad "banned words:"; echo "$hits"; fi

hits=$(body | grep -nEi "$ACTORS" || true)
if [ -z "$hits" ]; then ok "actors named by role"; else bad "unnamed actors:"; echo "$hits"; fi

missing=$(awk '
  /^\*\*(FR|NFR)-[0-9]+\.\*\*/ { if (open != "") print open; open=$1; next }
  /^Verify by:/               { open=""; next }
  /^## /                       { if (open != "") print open; open="" }
  END                          { if (open != "") print open }
' "$REQ")
if [ -z "$missing" ]; then ok "every FR/NFR has a Verify by line"; else bad "requirements without Verify by:"; echo "$missing"; fi

hits=$(grep -n 'Proposed' "$REQ" || true)
if [ -z "$hits" ]; then ok "no Proposed tags"; else bad "Proposed tags remain:"; echo "$hits"; fi

cited=$(grep -oE 'D-[0-9]{2}' "$REQ" | sort -u || true)
if [ -n "$cited" ]; then
  if [ -z "$DEC" ] || [ ! -f "$DEC" ]; then
    bad "decision ids cited but no decisions file given:"; echo "$cited" | tr '\n' ' '; echo
  else
    missing=""
    for id in $cited; do grep -q "^| $id |" "$DEC" || missing="$missing $id"; done
    if [ -z "$missing" ]; then ok "every cited decision exists"; else bad "unknown decision ids:$missing"; fi
  fi
else
  ok "no decision ids cited"
fi

hits=$(grep -n '—' "$REQ" || true)
if [ -z "$hits" ]; then ok "no em dashes"; else bad "em dashes:"; echo "$hits"; fi

echo "INFO: $(grep -cE '^\*\*FR-[0-9]+\.\*\*' "$REQ") FR, $(grep -cE '^\*\*NFR-[0-9]+\.\*\*' "$REQ") NFR, $(grep -cE '^### AC-[0-9]+' "$REQ") AC"
exit $fail
