@echo off
setlocal enabledelayedexpansion

echo [sushi]  compiling FSH -^> fsh-generated/
call sushi . --require-latest
if errorlevel 1 goto :err

if not exist input-cache\publisher.jar (
    echo [FATAL] IG Publisher JAR missing; run _updatePublisher.bat
    exit /b 1
)

echo [pub]    running HL7 FHIR IG Publisher
java -Xmx4g -jar input-cache\publisher.jar publisher -ig sushi-config.yaml
if errorlevel 1 goto :err

echo [OK]     output\index.html ready
exit /b 0

:err
echo [FAIL]   build failed
exit /b 1
