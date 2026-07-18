# Security Migration Checklist

Complete these steps before applying the hardened Terraform configuration to an existing environment.

1. Rotate the database password that was previously committed to Git history.
2. Create the Flask application secret described in `SECURITY.md`.
3. Copy `terraform/terraform.tfvars.example` to the ignored `terraform/terraform.tfvars` file.
4. Set the real `ecr_repository_url` and `app_secret_arn` identifiers.
5. Run `terraform fmt -recursive`, `terraform init`, `terraform validate`, and `terraform plan`.
6. Review the plan carefully: changing from an explicit RDS password to `manage_master_user_password` updates credential management and may rotate the master credential.
7. Apply the plan and allow the Auto Scaling Group to replace or refresh instances so they retrieve the new secrets.
8. Verify target health, application login/session behavior, CRUD operations, and database connectivity.
9. Review CloudTrail and application logs for unexpected access associated with the formerly exposed credential.

Removing a value from the latest branch does not remove it from existing Git history or clones. Coordinate any later history rewrite separately because it requires a forced repository update.
