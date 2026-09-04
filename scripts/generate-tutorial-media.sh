#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
site_root="$(cd "${script_dir}/.." && pwd)"
compiler_root="${UTAB_COMPILER_ROOT:-${site_root}/../UniversalTabs}"
examples_dir="${site_root}/static/examples"

cd "${site_root}"

if [[ ! -f "${compiler_root}/Package.swift" ]]; then
  echo "error: UniversalTabs package not found at ${compiler_root}" >&2
  echo "Set UTAB_COMPILER_ROOT to the package directory." >&2
  exit 1
fi

swift build --package-path "${compiler_root}" --product utabc
swift build --package-path "${compiler_root}" --product utab-midi
bin_dir="$(swift build --package-path "${compiler_root}" --show-bin-path)"

for source in "${examples_dir}"/*.utab; do
  stem="${source%.utab}"
  json="${stem}.utab.json"
  midi="${stem}.mid"
  echo "Compiling ${source#"${site_root}/"}"
  "${bin_dir}/utabc" --emit utab-json -o "${json}" "${source}"
  echo "Converting ${json#"${site_root}/"}"
  "${bin_dir}/utab-midi" --strict "${json}" "${midi}"
done
