# ScoopLabs AWS Assignment – S3 Basics: Bucket Policy & Public Access

## Concept Task: What is an S3 bucket policy?

An S3 bucket policy is a resource-based JSON policy attached directly to an S3 bucket. It defines who (which principal — a user, role, account, or `*` for everyone) can perform which actions (like `s3:GetObject`, `s3:PutObject`) on which resources (the bucket itself or specific objects/prefixes inside it), and under what conditions.

Unlike IAM policies (which are attached to users/roles and say "what can this identity do"), a bucket policy is attached to the bucket and says "who can access this bucket/object" — so it works even for requests that don't come from an IAM identity in your own account, such as anonymous public access or cross-account access.

Key points:
- Written in JSON, with `Effect` (Allow/Deny), `Principal`, `Action`, `Resource`, and optional `Condition`.
- Can grant public read access to specific objects (e.g., hosting a static file) by setting `Principal: "*"`.
- Works together with the bucket's "Block Public Access" settings — even if a policy allows public access, S3 will still block it if Block Public Access is enabled at the bucket or account level.
- Common use cases: static website hosting, public asset buckets, cross-account access, enforcing HTTPS-only access, restricting access by IP/VPC.

## Hands-on Task

**Goal:** Create an S3 bucket, upload a text file, and make that specific file publicly accessible via a URL.

### Steps performed

1. Created bucket `charans-bucket-2026` in region `ap-south-1` (Mumbai).
2. Uploaded a text file `hello.txt` (36.0 B) to the bucket root.
3. Disabled **Block all public access** on the bucket (required before any public policy can take effect).
4. Attached the following bucket policy to allow public read access to `hello.txt`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForHelloTxt",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::charans-bucket-2026/hello.txt"
    }
  ]
}
```

5. Verified access by opening the object's public URL directly in a browser:

```
https://charans-bucket-2026.s3.ap-south-1.amazonaws.com/hello.txt
```

*(Note: an initial attempt using a presigned URL failed with an `AccessDenied` / "Request has expired" error since the presigned URL was generated with only a 1-minute expiry. The bucket policy approach above was used instead for permanent public access, since presigned URLs are meant for temporary/private-object sharing, not permanent public access.)*

## Submission Requirements

- **Bucket policy used:** included above (`PublicReadForHelloTxt` statement, scoped to `hello.txt` only).
- **Screenshot of file accessed successfully via public browser URL:** *[to be added]*
