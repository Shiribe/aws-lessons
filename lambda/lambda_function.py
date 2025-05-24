import json
import boto3
import os
import uuid
from datetime import datetime
import base64
from email.parser import BytesParser
from email.policy import default

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
rekognition = boto3.client('rekognition')

BUCKET = os.environ['S3_BUCKET']
TABLE = os.environ['DDB_TABLE']

def lambda_handler(event, context):
    # Log the incoming event for debugging
    print("Event received:", json.dumps(event))
    body = event['body']
    is_base64 = event.get('isBase64Encoded', False)
    if is_base64:
        body = base64.b64decode(body)
    else:
        body = body.encode()

    content_type = event['headers'].get('Content-Type') or event['headers'].get('content-type')
    if not content_type:
        return {"statusCode": 400, "body": json.dumps({"error": "Missing Content-Type header"})}

    # Parse multipart form data using email.parser
    headers = f"Content-Type: {content_type}\r\n\r\n".encode()
    msg = BytesParser(policy=default).parsebytes(headers + body)

    client_id = None
    image_content = None

    for part in msg.iter_parts():
        content_disposition = part.get("Content-Disposition", "")
        if 'name="clientId"' in content_disposition:
            client_id = part.get_content().strip()
        elif 'name="image"' in content_disposition:
            image_content = part.get_payload(decode=True)

    if not client_id or not image_content:
        return {"statusCode": 400, "body": json.dumps({"error": "Missing data"})}

    filename = f"{client_id}/{uuid.uuid4()}.jpg"
    s3.put_object(Bucket=BUCKET, Key=filename, Body=image_content)

    table = dynamodb.Table(TABLE)
    table.put_item(Item={
        'ClientId': client_id,
        'ImagePath': filename,
        'Timestamp': datetime.utcnow().isoformat()
    })

    response = rekognition.detect_labels(
        Image={'S3Object': {'Bucket': BUCKET, 'Name': filename}},
        MaxLabels=10,
        MinConfidence=75
    )

    labels = response.get('Labels', [])
    # print the labels to the console
    print(labels)
    
    # Before returning the response
    response_body = {
        "labels": [
            {"name": label['Name'], "confidence": label['Confidence']}
            for label in labels
        ]
    }
    print("Returning response:", json.dumps(response_body))
    return {
        "statusCode": 200,
        "body": json.dumps(response_body),
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        }
    }