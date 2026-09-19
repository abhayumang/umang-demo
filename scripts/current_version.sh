#!/usr/bin/env bash
# Usage: current_version.sh <dept-id>
# Department par abhi chal raha version (health endpoint se). Kuch deployed na ho to khali.
DEPT="$1"
curl -s -m 3 "http://${DEPT}:8080/umang/health" 2>/dev/null | jq -r '.version // empty' 2>/dev/null || true
