#!/usr/bin/env bash
# One-shot build: SUSHI compiles FSH -> resources, then IG Publisher
# produces output/. Run _updatePublisher.sh first to fetch the JAR.
set -euo pipefail

echo "[sushi]  compiling FSH -> fsh-generated/"
sushi . --require-latest

if [ ! -f input-cache/publisher.jar ]; then
    echo "[FATAL] IG Publisher JAR missing; run ./_updatePublisher.sh" >&2
    exit 1
fi

echo "[pub]    running HL7 FHIR IG Publisher"
java -Xmx4g -jar input-cache/publisher.jar publisher -ig sushi-config.yaml

echo "[OK]     output/index.html ready"
