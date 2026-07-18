# Security Guide

## Secret-management model

This project does not accept database passwords through Terraform variables and does not embed secret values in EC2 launch-template user data.

- Amazon RDS generates and stores the database master credential in AWS Secrets Manager by using `manage_master_user_password = true`.
- The Flask `SECRET_KEY` is stored in a separate, pre-existing Secrets Manager secret.
- EC2 retrieves both values at boot through its instance role.
- The EC2 inline policy permits `secretsmanager:GetSecretValue` only for those two secret ARNs.
- The generated `/opt/fintrust/.env` file is owned by root with mode `0600`.

## Create the Flask application secret

Create a strong plaintext secret before running Terraform:

```bash
APP_SECRET=$(python -c "import secrets; print(secrets.token_hex(32))")

aws secretsmanager create-secret \
  --name fintrust/dev/flask-secret \
  --description "Flask session signing key for FinTrust" \
  --secret-string "$APP_SECRET" \
  --region us-east-1

unset APP_SECRET
```

Copy the returned ARN into a local `terraform/terraform.tfvars` file as `app_secret_arn`. Use `terraform/terraform.tfvars.example` as the template. Never commit the real variable file.

## ECR repository configuration

Set `ecr_repository_url` in `terraform/terraform.tfvars` to the full private ECR repository URL. The repository URL is an identifier, not a credential.

## Credential rotation after repository exposure

A database password previously committed to this repository must be treated as compromised even after it is removed from the latest branch. If that value was ever used:

1. Rotate or replace the affected RDS credential immediately.
2. Confirm no other service reused the same value.
3. Review CloudTrail, RDS authentication logs, and application logs for unexpected activity.
4. Consider removing the value from Git history with a dedicated history-rewrite tool, then coordinate the forced update with every repository clone.

## Customer-managed KMS keys

The included IAM policy is sufficient when the secrets use the default AWS Secrets Manager encryption key. When using a customer-managed KMS key, add a narrowly scoped `kms:Decrypt` permission for that key to the EC2 role.

## Reporting a vulnerability

Do not open a public issue containing credentials or exploit details. Contact the repository owner privately and rotate any exposed credential before further investigation.
