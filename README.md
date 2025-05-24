# Image Analysis Project with AWS Rekognition and Terraform

This project demonstrates an end-to-end serverless architecture for uploading images, analyzing them using Amazon Rekognition, and managing metadata using DynamoDB. It includes:

- AWS Lambda (Python)
- Amazon S3
- Amazon Rekognition
- DynamoDB
- API Gateway
- Static website frontend (HTML/JavaScript)
- Terraform for full infrastructure as code

---

## 📦 Project Structure

```
image-analysis-project/
├── lambda/                 # Lambda function in Python
│   ├── lambda_function.py
│   └── tests/
│       └── test_lambda.py
├── frontend/               # Static frontend (HTML/JS)
│   ├── index.html
│   └── app.js
├── terraform/              # Terraform infrastructure code
│   ├── main.tf
│   └── update_api_url.sh
├── terraform_intro_rekognition.pptx  # Presentation slides
└── README.md               # This file
```

---

## 🛠 Prerequisites

- **AWS CLI** configured with `aws configure`
- **Terraform** (v1.0 or newer)
- **Python 3.9+** with `pip`

### 🔽 Installing Terraform

Follow instructions at: https://developer.hashicorp.com/terraform/downloads

Example (for Linux):
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor |   sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg]   https://apt.releases.hashicorp.com $(lsb_release -cs) main" |   sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install terraform
```

---

## 🚀 Deployment Instructions

1. **Unzip the project** and open a terminal:
```bash
unzip image-analysis-project.zip
cd image-analysis-project/terraform
```

2. **Initialize and apply Terraform**:
### cd to the terraform folder where main.tf resides then do:
```bash
terraform init
terraform apply
```

3. **Update Frontend with API URL**:
### In linux\macos do chmod +x update_api_url.sh
```bash
./update_api_url.sh
```
### In windows either run  update_api_url.cmd in cmd prompt 
### or update_api_url.ps1 in powershell

This script replaces `REPLACE_WITH_API_URL` in `frontend/app.js` and uploads frontend files to S3.

---

## 🧪 Lambda Testing (Optional)

From the `lambda/` directory:
```bash
pip install pytest
pytest
```

---

## 🌐 Access Your Application

- API URL is printed by Terraform (`api_url`)
- Static website is at the S3 website output (`frontend_url`)
- Upload images through the web form, see AI analysis live

---

## 🧾 Notes

- Lambda analyzes each image and returns labels with confidence.
- Data is saved in S3 (`clientphotos`) and DynamoDB (`client` table).
- Rekognition supports faces, objects, and custom labels if needed.

---

Enjoy building with AWS + Terraform!
