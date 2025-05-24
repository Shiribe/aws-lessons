#!/bin/bash

# שלוף את כתובת ה-API מתוך Terraform output
API_URL=$(terraform output -raw api_url)

if [ -z "$API_URL" ]; then
  echo "לא ניתן למצוא API Gateway URL מה-Terraform"
  exit 1
fi

echo "ה-API URL שנמצא: $API_URL"

# עדכן את app.js עם כתובת ה-API האמיתית
sed -i '' "s|REPLACE_WITH_API_URL|$API_URL|" ../frontend/app.js

echo "עודכן קובץ app.js"

# העלה את הקבצים המעודכנים ל-S3
BUCKET_NAME=$(terraform output -raw frontend_url | sed -E 's|http://(.*)\.s3-website.*|\1|')

if [ -z "$BUCKET_NAME" ]; then
  echo "לא נמצא שם bucket"
  exit 1
fi

echo "מעלה קבצים ל-bucket: $BUCKET_NAME"
aws s3 cp ../frontend/index.html s3://$BUCKET_NAME/index.html --content-type text/html
aws s3 cp ../frontend/app.js s3://$BUCKET_NAME/app.js --content-type application/javascript

echo "הקבצים הועלו בהצלחה."