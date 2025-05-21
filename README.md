# 🚀 Terraform: Remote Backend Setup (AWS)

### Purpose: In a professional Terraform setup, it’s common to separate:

- **A project solely for provisioning a remote backend as foundational infrastructure (S3 backend bucket for storing the .tfstate-file, DynamoDB table for locking).**
    
- **The main working projects: use that infrastructure as backend, but do not manage it themselves.**
    
📦 This way, the backend resources aren't destroyed accidentally when cleaning up or modifying main infrastructure.

    
This project demonstrates exactly that. It sets up the necessary AWS infrastructure to support a **remote Terraform backend** with:

- ✅ Remote state storage in an **S3 bucket**
- ✅ State locking and consistency via a **DynamoDB table**

It is the first foundational step in creating Terraform projects that are **safe, scalable, and team-friendly**.

---

## 📚 What I Learned

This project is part of my Terraform learning journey with the goal of becoming job-ready in a professional cloud infrastructure environment. Key takeaways:

- The importance of managing Terraform **state centrally**
- How to enable **state locking** to avoid conflicting changes
- How to structure Terraform code **modularly and cleanly**
- Hands-on practice with:
  - S3 versioning and lifecycle protection
  - DynamoDB as a locking mechanism
  - Variable files and `terraform.tfvars`
  - Safe tear-down

---

## 🛠️ What This Project Creates

| Resource                      | Purpose                                       |
|-------------------------------|-----------------------------------------------|
| `aws_s3_bucket`               | Stores Terraform state files                  |
| `aws_s3_bucket_versioning`    | Enables versioning for state history/backup   |
| `aws_dynamodb_table`          | Provides state locking to avoid race conditions |

---

## 🧰 Usage

### 1. Clone the Project

```bash
git clone https://github.com/janphilippgutt/aws-backend-setup.git
cd aws-backend-setup
```

### 2. Create terraform.tfvars

Create a `terraform.tfvars` file with your values:

```bash
bucket_name     = "your-unique-tfstate-bucket"
lock_table_name = "terraform-lock-table"
```
🔒 The S3 bucket name must be globally unique.

### 3. Initialize & Apply

```bash
terraform init
terraform apply
```
Terraform will provision the bucket and table in your AWS account

## 🧩 Project Files


| File               | Purpose                                             |
|--------------------|-----------------------------------------------------|
| `main.tf`          | Defines resources (S3 + DynamoDB)                   |
| `variables.tf`     | Declares required input variables                   |
| `outputs.tf`       | Provided outputs: S3-bucket-id, DynamoDB-table-name |
| `terraform.tfvars` | User-defined variable values                        |
| `README.md`        | This documentation                                  |

## 🔁 How to Use This in Other Projects

Once the infrastructure is created, point your Terraform projects to this backend:

```bash
terraform {
  backend "s3" {
    bucket         = "your-unique-tfstate-bucket"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock-table"
  }
}

```
💡 **Personal learning:** This is the point where the S3 bucket and DynamoDB lock table become integrated. Although they were created independently during the initial terraform apply, they now work together as part of the remote backend configuration.

Then run:

```bash
terraform init
```
🧠 This migrates the state to the remote backend for that project.

## 🚫 Safe Defaults

The S3 bucket includes:

    prevent_destroy = true — protects the state from accidental deletion

    Versioning — keeps historical copies of your state

The DynamoDB table uses PAY_PER_REQUEST, suitable for Free Tier usage and small workloads.

## ✅ Prerequisites

    AWS CLI configured (aws configure)

    Terraform installed (terraform -v)

    Valid AWS credentials with S3 and DynamoDB permissions

    terraform.tfvars file with the required values

## 🔧 Teardown Instructions

    Note: The Terraform backend (S3 bucket and DynamoDB table) is intentionally designed to be persistent. If you still wish to delete these resources (e.g. for cleanup or testing), follow this step-by-step process to avoid state locking and S3 bucket deletion errors.

⚠️ Important Constraints

    Terraform state is stored inside the S3 bucket you're trying to delete.

    AWS S3 buckets must be empty before they can be destroyed.

    The S3 bucket is protected from deletion via prevent_destroy = true.

## 🧼 Safe Teardown Steps
### 1. Disable S3 Bucket Protection

Open main.tf and remove or comment out the lifecycle block inside the S3 bucket resource:

```bash
# main.tf

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  # Comment out or delete the following:
  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "bootstrap"
  }
}

```

Run the command to apply the change:

```bash
terraform apply
```
### 2. Manually Empty the S3 Bucket

Terraform cannot remove a non-empty bucket. You must clear it manually:

Option A: AWS Console

    Go to S3 in the AWS Console

    Select your bucket

    Click “Empty”

    Confirm deletion of all objects

Option B: AWS CLI

```bash
aws s3 rm s3://<your-bucket-name> --recursive
```
### 3. Run Terraform Destroy

With protection removed and the bucket empty:

```bash
terraform destroy
```
This will remove the S3 bucket, DynamoDB table, and all associated resources.

### 💡 Recommendation

In real-world infrastructure, the backend is considered foundational and is rarely destroyed. In this learning environment, teardown can be useful for clean state management and testing.


## 📜 License

MIT — Free to use and adapt.