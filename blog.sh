#!/bin/bash
set -ueo pipefail

scriptDir=$(dirname $0)
file="$scriptDir/draft.md"

if [ ! -e $file ]; then
  cat >"$file" << EOT
+++
date = "____DATE____"
draft = true
title = ""
+++
EOT
fi

vim "$file"

if grep '^draft = true$' "$file" >/dev/null 2>&1; then
  echo "Saved draft"
else
  echo "publish!"
  now=$(date -u "+%Y-%m-%dT%H:%M:%S")
  sed -i -e "s/____DATE____/$now/" "$file"
  year=$(date '+%Y')
  outdir="$scriptDir/content/blog/$(date '+%Y')"
  if [ ! -d "$outdir" ]; then
    mkdir -p "$outdir"
  fi
  outfile="$(date -u '+%m%d%H%M%S').md"
  mv "$file" "$outdir/$outfile"
  git add "$outdir/$outfile"
  git commit -m "blogpost: $now"
  git push origin main
fi
