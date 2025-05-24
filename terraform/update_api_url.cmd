@echo off
REM Get API URL from Terraform output
for /f "delims=" %%A in ('terraform output -raw api_url') do set API_URL=%%A

if "%API_URL%"=="" (
    echo Could not find API Gateway URL from Terraform
    exit /b 1
)

echo Found API URL: %API_URL%

REM Replace REPLACE_WITH_API_URL in app.js
powershell -Command "(Get-Content ..\frontend\app.js) -replace 'REPLACE_WITH_API_URL', '%API_URL%' | Set-Content ..\frontend\app.js"

echo Updated app.js

REM Get bucket name from frontend_url output
for /f "delims=" %%B in ('terraform output -raw frontend_url') do set FRONTEND_URL=%%B
for /f "tokens=2 delims=/" %%C in ("%FRONTEND_URL%") do set BUCKET_PART=%%C
for /f "tokens=1 delims=." %%D in ("%BUCKET_PART%") do set BUCKET_NAME=%%D

if "%BUCKET_NAME%"=="" (
    echo Could not find bucket name
    exit /b 1
)

echo Uploading files to bucket: %BUCKET_NAME%
aws s3 cp ..\frontend\index.html s3://%BUCKET_NAME%/index.html --content-type text/html
aws s3 cp ..\frontend\app.js s3://%BUCKET_NAME%/app.js --content-type application/javascript

echo Files uploaded successfully.