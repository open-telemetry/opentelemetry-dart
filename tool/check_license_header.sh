#!/usr/bin/env bash
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

missing=$(git ls-files '*.dart' '*.sh' | while read -r f; do
  head -n 5 "$f" | grep -q 'Copyright The OpenTelemetry Authors' &&
    head -n 5 "$f" | grep -q 'SPDX-License-Identifier: Apache-2.0' ||
    echo "$f"
done)

if [ -n "$missing" ]; then
  echo "Missing license header:"
  echo "$missing"
  exit 1
fi
