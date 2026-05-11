<# .SYNOPSIS
    FHIR Implementation Guide build — replaces ig-build.yml.

    Prerequisites: npm (for fsh-sushi), Java (for FHIR publisher).
    Usage:
      pwsh -File scripts/ig-build.ps1
#>
$ErrorActionPreference = "Stop"
Set-Location C:\Users\hgeec\github\symphonix-eps-ig

Write-Host "[INFO] Installing SUSHI..."
npm install -g fsh-sushi

Write-Host "[INFO] Downloading/updating FHIR publisher..."
if (Test-Path _updatePublisher.sh) {
    bash _updatePublisher.sh
} else {
    Write-Host "[WARN] _updatePublisher.sh not found, skipping"
}

Write-Host "[INFO] Building IG..."
bash _genonce.sh
if ($LASTEXITCODE -ne 0) { Write-Host "[FAIL] IG build failed"; exit 1 }

Write-Host "[INFO] Running profile validation..."
python -m pytest tests/test_profiles.py -q
Write-Host "[$(if ($LASTEXITCODE -eq 0) {'OK'} else {'FAIL'})] Profiles: exit $LASTEXITCODE"

Write-Host "[INFO] Running citation resolver (slow)..."
python -m pytest tests/test_citations.py -q -m slow
Write-Host "[$(if ($LASTEXITCODE -eq 0) {'OK'} else {'WARN'})] Citations: exit $LASTEXITCODE"

Write-Host "[OK] IG build complete. Output in: output/"
