# Get API URL from Terraform output
$API_URL = terraform output -raw api_url

if (-not $API_URL) {
    Write-Host "Could not find API Gateway URL from Terraform"
    exit 1
}

Write-Host "Found API URL: $API_URL"

# Replace REPLACE_WITH_API_URL in app.js
$appJsPath = "..\frontend\app.js"
(Get-Content $appJsPath) -replace "REPLACE_WITH_API_URL", $API_URL | Set-Content $appJsPath

Write-Host "Updated app.js"

# Get bucket name from frontend_url output
$FRONTEND_URL = terraform output -raw frontend_url
if (-not $FRONTEND_URL) {
    Write-Host "Could not find frontend_url"
    exit 1
}
if ($FRONTEND_URL -match "http://(.*?)\.s3-website") {
    $BUCKET_NAME = $matches[1]
} else {
    Write-Host "Could not extract bucket name"
    exit 1
}

Write-Host "Uploading files to bucket: $BUCKET_NAME"
aws s3 cp ..\frontend\index.html "s3://$BUCKET_NAME/index.html" --content-type text/html
aws s3 cp ..\frontend\app.js "s3://$BUCKET_NAME/app.js" --content-type application/javascript

Write-Host "Files uploaded successfully."