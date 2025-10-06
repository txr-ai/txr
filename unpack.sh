#!/usr/bin/env bash
#
# verify_and_unpack.sh — Unzip, validate SHA-256 checksums, and emit conformance for out_* suites.
#
# Usage:
#   ./verify_and_unpack.sh [ZIP_PATH]
#
# Behavior:
#   1) If ZIP_PATH omitted, uses first *.zip in CWD. Deflates into CWD (overwrites existing).
#   2) Validates every SHA256SUMS.txt (depth ≤2) with sha256sum -c.
#   3) Searches for {out_pass,out_fail,out_ablation}/conformance.xml (depth ≤3) and prints:
#        - out_pass → PASS
#        - out_fail → PASS
#        - out_ablation → FAIL (and prints that suite’s <failure message> text)
#   4) Prints summaries and exits non-zero iff any checksum fails.
#
# Requirements: unzip, sha256sum
#chgmod +x unpack.sh
set -euo pipefail

err() { printf "ERROR: %s\n" "$*" >&2; }
info() { printf "[*] %s\n" "$*"; }
ok() { printf "[OK] %s\n" "$*"; }

have_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! have_cmd unzip; then err "unzip is required"; exit 127; fi
if ! have_cmd sha256sum; then err "sha256sum is required"; exit 127; fi

ZIP_PATH="${1:-}"
if [[ -z "${ZIP_PATH}" ]]; then
  shopt -s nullglob; zips=( *.zip ); shopt -u nullglob
  if (( ${#zips[@]} == 0 )); then err "No ZIP provided and no *.zip in CWD."; exit 2; fi
  ZIP_PATH="${zips[0]}"
fi
[[ -f "$ZIP_PATH" ]] || { err "ZIP not found: $ZIP_PATH"; exit 2; }

info "Using ZIP: $ZIP_PATH"
info "Deflating into: $(pwd)"
unzip -o "$ZIP_PATH" >/dev/null

mapfile -d '' sums_files < <(find . -maxdepth 2 -type f -name "SHA256SUMS.txt" -print0 || true)
fail_count=0; pass_count=0; declare -a results
cwd="$(pwd)"

if (( ${#sums_files[@]} )); then
  declare -A seen_dirs; folders=()
  for f in "${sums_files[@]}"; do
    d="$(cd "$(dirname "$f")" && pwd)"
    [[ "${seen_dirs[$d]:-}" ]] && continue
    seen_dirs[$d]=1; folders+=( "$d" )
  done
  if [[ -f "$cwd/SHA256SUMS.txt" ]]; then
    tmp=("$cwd"); for d in "${folders[@]}"; do [[ "$d" == "$cwd" ]] && continue; tmp+=( "$d" ); done
    folders=("${tmp[@]}")
  fi

  info "Found ${#folders[@]} folder(s) with SHA256SUMS.txt"
  for dir in "${folders[@]}"; do
    rel="${dir/#$cwd\//}"; [[ "$rel" == "$dir" ]] && rel="$dir"; [[ "$rel" == "$cwd" ]] && rel="."
    echo; echo "===== CHECKSUM VALIDATION START: ${rel} ====="
    pushd "$dir" >/dev/null
    if sha256sum -c "SHA256SUMS.txt" --quiet; then
      echo "==== CONFORMANCE: PASS (${rel}) ===="
      ok "All checksums match in ${rel}."
      ((pass_count++)); results+=( "PASS\t${rel}" )
    else
      echo "==== CONFORMANCE: FAIL (${rel}) ===="
      err "Checksum mismatches in ${rel}. Details:"
      sha256sum -c "SHA256SUMS.txt" || true
      ((fail_count++)); results+=( "FAIL\t${rel}" )
    fi
    popd >/dev/null
    echo "=====  CHECKSUM VALIDATION END: ${rel}  ====="
  done
else
  info "No SHA256SUMS.txt found (depth ≤2); skipping checksum validation."
fi

echo; echo "===== SUITE CONFORMANCE ====="

extract_failure_message() {
  local file="$1"
  local msg
  msg="$(grep -oP '(?i)<failure[^>]*\bmessage="\K[^"]+' "$file" 2>/dev/null | head -n1 || true)"
  if [[ -z "${msg:-}" ]]; then
    msg="$(perl -0777 -ne 'if (/<failure[^>]*>(.*?)<\/failure>/si){ $x=$1; $x=~s/\s+/ /g; print $x; }' "$file" 2>/dev/null | head -n1 || true)"
  fi
  printf "%s" "${msg:-}"
}

declare -A expected=( ["out_pass"]="PASS" ["out_fail"]="PASS" ["out_ablation"]="FAIL" )
declare -A found_paths

while IFS= read -r -d '' p; do
  base="$(basename "$(dirname "$p")")"
  case "$base" in
    out_pass|out_fail|out_ablation)
      found_paths["$base"]="$p"
      ;;
  esac
done < <(find . -maxdepth 3 -type f -name "conformance.xml" -print0 2>/dev/null)

for key in out_pass out_fail out_ablation; do
  if [[ -n "${found_paths[$key]:-}" ]]; then
    p="${found_paths[$key]}"
    echo "Suite: ${key}"
    if [[ "$key" == "out_ablation" ]]; then
      echo "==== CONFORMANCE: FAIL (${key}) ===="
      msg="$(extract_failure_message "$p")"
      if [[ -n "$msg" ]]; then
        echo "Reason: $msg"
      else
        echo "Reason: (no <failure message> found in XML)"
      fi
    else
      echo "==== CONFORMANCE: PASS (${key}) ===="
    fi
  else
    echo "Suite: ${key} — conformance.xml not found (skipped)"
  fi
done

echo "===== END SUITE CONFORMANCE ====="

echo
echo "========== CHECKSUM SUMMARY =========="
printf "Checksum folders: %d | Passed: %d | Failed: %d\n" "${#results[@]}" "$pass_count" "$fail_count"
if (( ${#results[@]} )); then
  printf "%-6s  %s\n" "RESULT" "FOLDER"
  for r in "${results[@]}"; do IFS=$'\t' read -r status where <<<"$r"; printf "%-6s  %s\n" "$status" "$where"; done
fi
echo "======================================"

(( fail_count > 0 )) && exit 4 || exit 0
