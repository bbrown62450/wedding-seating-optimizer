#!/usr/bin/env bash
# Proves docs/requirements.md follows docs/ambiguity-checklist.md.
# Usage: scripts/check-requirements.sh [requirements.md] [decisions.md]
set -u
REQ="${1:-docs/requirements.md}"
DEC="${2:-docs/decisions.md}"
fail=0
ok()   { echo "PASS: $1"; }
bad()  { echo "FAIL: $1"; fail=1; }

# Body = everything except section 5 (definitions) and quoted lines (> ...).
body() {
  awk '
    /^## 5\./ { skip=1; next }
    /^## /    { skip=0 }
    skip      { next }
    /^>/      { next }
    { print }
  ' "$REQ"
}

# 1. Banned relative or open-ended words (lowercase, whole word).
BANNED='\b(near|away|far|adjacent|shortly|sufficient|insufficient|likely|such as|including|appropriate|appropriately|explicitly|explicit|silently|quickly|large|small|etc)\b'
hits=$(body | grep -nE "$BANNED" || true)
if [ -z "$hits" ]; then ok "no banned words outside section 5"; else bad "banned words:"; echo "$hits"; fi

# 2. "the user" / "authorized user" replaced by roles.
hits=$(body | grep -nEi '\b(the user|authorized user|authorized users|an authorized)\b' || true)
if [ -z "$hits" ]; then ok "actors named by role"; else bad "unnamed actors:"; echo "$hits"; fi

# 3. Every FR/NFR has a Verify by line before the next requirement or heading.
missing=$(awk '
  /^\*\*(FR|NFR)-[0-9]+\.\*\*/ { if (open != "") print open; open=$1; next }
  /^Verify by:/               { open=""; next }
  /^## /                       { if (open != "") print open; open="" }
  END                          { if (open != "") print open }
' "$REQ")
if [ -z "$missing" ]; then ok "every FR/NFR has a Verify by line"; else bad "requirements without Verify by:"; echo "$missing"; fi

# 4. No Proposed tags.
hits=$(grep -n 'Proposed' "$REQ" || true)
if [ -z "$hits" ]; then ok "no Proposed tags"; else bad "Proposed tags remain:"; echo "$hits"; fi

# 5. Every cited decision id exists in decisions.md.
missing=""
for id in $(grep -oE 'D-[0-9]{2}' "$REQ" | sort -u); do
  grep -q "^| $id |" "$DEC" || missing="$missing $id"
done
if [ -z "$missing" ]; then ok "every cited decision exists"; else bad "unknown decision ids:$missing"; fi

# 6. No em dashes.
hits=$(grep -n '—' "$REQ" || true)
if [ -z "$hits" ]; then ok "no em dashes"; else bad "em dashes:"; echo "$hits"; fi

# 7. Requirement count report (informational).
echo "INFO: $(grep -cE '^\*\*FR-[0-9]+\.\*\*' "$REQ") FR, $(grep -cE '^\*\*NFR-[0-9]+\.\*\*' "$REQ") NFR, $(grep -cE '^### AC-[0-9]+' "$REQ") AC"

exit $fail
