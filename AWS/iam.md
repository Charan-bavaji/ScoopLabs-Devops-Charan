# AWS Assignment: Identity and Access Management (IAM)

## Detailed Description
Identity and Access Management (IAM) is the AWS service used to control **who** can access your AWS account and **what** they are allowed to do. It lets you create users, groups, and roles, and attach policies that define their exact permissions.

---

## Concept Task: Principle of Least Privilege

**What it means**
The Principle of Least Privilege (PoLP) says that a user, application, or system should be given only the exact permissions it needs to do its job — nothing more, nothing less.

**Why it matters**
- Reduces the damage if credentials are leaked or stolen (an attacker only gets limited access).
- Reduces the chance of accidental mistakes, like someone deleting a resource they weren't supposed to touch.
- Makes audits and troubleshooting easier, since each user's access clearly maps to their role.
- Is a core requirement in most security compliance standards (SOC 2, ISO 27001, etc.).

**How it's applied in AWS IAM**
- Instead of giving a user `AdministratorAccess`, you attach only the specific policy they need (e.g. `AmazonS3ReadOnlyAccess` if they only need to view S3 data).
- Permissions are added gradually as needed, rather than granting broad access "just in case."
- AWS provides IAM Access Analyzer to review and tighten permissions that are broader than necessary.

**Example**
A developer who only needs to check files in an S3 bucket should get an IAM policy that allows `s3:GetObject` and `s3:ListBucket` — not full S3 access, and definitely not access to EC2, IAM, or billing.

---

## Hands-on Task: Create an IAM User with Read-Only S3 Access

**Goal:** Create an IAM user with programmatic access and attach a policy that only allows read access to S3.

### Steps
1. Go to the **IAM Console** → **Users** → **Create user**.
2. Enter a username (e.g. `s3-readonly-user`).
3. Under access type, select **Programmatic access** (generates an Access Key ID + Secret Access Key — no console password needed).
4. On the permissions step, choose **Attach policies directly**.
5. Search for and select **AmazonS3ReadOnlyAccess** (AWS managed policy).
6. Review and create the user.
7. Download or securely save the **Access Key ID** and **Secret Access Key** shown on the confirmation page (shown only once).
8. Go to the user's **Permissions** tab to confirm only `AmazonS3ReadOnlyAccess` is attached.
9. (Optional verification) Configure the AWS CLI with these credentials (`aws configure`) and confirm:
   - `aws s3 ls` works (read access succeeds)
   - `aws s3 cp somefile.txt s3://your-bucket/` fails with an Access Denied error (write access is blocked, proving least privilege is working)

---

## Submission Requirements

