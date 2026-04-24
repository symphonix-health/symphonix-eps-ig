@echo off
if not exist input-cache mkdir input-cache
echo [pub]    fetching latest IG Publisher JAR
curl -L -o input-cache\publisher.jar "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"
if errorlevel 1 exit /b 1
echo [OK]     input-cache\publisher.jar updated
