#!/usr/bin/env bash
set -euo pipefail

FILE=".github/workflows/jsonschema.yaml"
VERSION=$(grep -oP 'YQ_VERSION:\s*\K\S+' "$FILE")

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

curl -sfL "https://github.com/mikefarah/yq/releases/download/${VERSION}/checksums" \
  -o "$WORKDIR/checksums"
curl -sfL "https://github.com/mikefarah/yq/releases/download/${VERSION}/checksums_hashes_order" \
  -o "$WORKDIR/checksums_hashes_order"

COL=$(awk '/^SHA-256$/{print NR+1; exit}' "$WORKDIR/checksums_hashes_order")
SHA=$(awk -v col="$COL" '/^yq_linux_amd64 /{print $col}' "$WORKDIR/checksums")

if [ -z "$SHA" ]; then
  echo "ERROR: could not extract SHA-256 for yq_linux_amd64 at ${VERSION}" >&2
  exit 1
fi

sed -i "s/^  YQ_SHA256: .*/  YQ_SHA256: ${SHA}/" "$FILE"
echo "Updated YQ_SHA256 to ${SHA} for ${VERSION}"
