#!/usr/bin/env bash
# Fetch the latest HL7 FHIR IG Publisher JAR.
set -euo pipefail
mkdir -p input-cache
echo "[pub]    fetching latest IG Publisher JAR"
curl -L -o input-cache/publisher.jar \
  "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"
echo "[OK]     input-cache/publisher.jar updated"
