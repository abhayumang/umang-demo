#!/usr/bin/env bash
# Apne laptop par chalaiye (Git Bash / WSL / Mac terminal):  bash scripts/status.sh
# Demo me isse dikhega ki kaun sa department kaun se version par hai.
printf "%-10s %-12s %s\n" "DEPT" "VERSION" "STATUS"
for i in 1 2 3 4 5 6; do
  port=$((8080 + i))
  dept=$(printf "dept-%02d" "$i")
  out=$(curl -s -m 3 -w '\n%{http_code}' "http://localhost:${port}/umang/health" 2>/dev/null || true)
  code=$(echo "$out" | tail -n1)
  body=$(echo "$out" | sed '$d')
  if [ "$code" = "200" ] || [ "$code" = "500" ]; then
    v=$(echo "$body" | sed -E 's/.*"version":"([^"]*)".*/\1/')
    s=$(echo "$body" | sed -E 's/.*"status":"([^"]*)".*/\1/')
    printf "%-10s %-12s %s\n" "$dept" "$v" "$s"
  else
    printf "%-10s %-12s %s\n" "$dept" "-" "NOT DEPLOYED"
  fi
done
