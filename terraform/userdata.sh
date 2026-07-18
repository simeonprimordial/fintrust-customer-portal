#!/bin/bash
set -euo pipefail

# Restrict permissions on every file created by this script.
umask 077

# Install and start Docker.
dnf install -y docker python3
systemctl enable --now docker

get_secret_value() {
  local secret_id="$1"
  local value=""

  # IAM role and network access can take a short time to become available
  # during first boot, so retry without ever printing the secret value.
  for _ in $(seq 1 12); do
    if value=$(aws secretsmanager get-secret-value \
      --region "${aws_region}" \
      --secret-id "$secret_id" \
      --query SecretString \
      --output text 2>/dev/null); then
      printf '%s' "$value"
      return 0
    fi

    sleep 10
  done

  echo "Unable to retrieve required secret: $secret_id" >&2
  return 1
}

# RDS stores its managed master credential as a JSON secret containing
# username and password. The Flask secret is stored as a plaintext value.
DB_SECRET_JSON=$(get_secret_value "${db_secret_arn}")
APP_SECRET_VALUE=$(get_secret_value "${app_secret_arn}")

DB_USERNAME=$(DB_SECRET_JSON="$DB_SECRET_JSON" python3 -c \
  'import json, os; print(json.loads(os.environ["DB_SECRET_JSON"])["username"])')
DB_PASSWORD=$(DB_SECRET_JSON="$DB_SECRET_JSON" python3 -c \
  'import json, os; print(json.loads(os.environ["DB_SECRET_JSON"])["password"])')

if [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ] || [ -z "$APP_SECRET_VALUE" ]; then
  echo "A required application secret was empty." >&2
  exit 1
fi

# Authenticate to the ECR registry host using the instance role, then pull the
# image from the complete repository URL.
ECR_REGISTRY=$(printf '%s' "${ecr_repo}" | cut -d/ -f1)

aws ecr get-login-password --region "${aws_region}" \
  | docker login \
      --username AWS \
      --password-stdin "$ECR_REGISTRY"

docker pull "${ecr_repo}:latest"

# Write a root-readable-only environment file for the container.
install -d -m 700 /opt/fintrust
install -m 600 /dev/null /opt/fintrust/.env

{
  printf 'DB_HOST=%s\n' "${db_host}"
  printf 'DB_PORT=%s\n' "3306"
  printf 'DB_NAME=%s\n' "${db_name}"
  printf 'DB_USERNAME=%s\n' "$DB_USERNAME"
  printf 'DB_PASSWORD=%s\n' "$DB_PASSWORD"
  printf 'SECRET_KEY=%s\n' "$APP_SECRET_VALUE"
} > /opt/fintrust/.env

# Remove secret material from the bootstrap shell environment as soon as the
# protected environment file has been created.
unset DB_SECRET_JSON DB_PASSWORD APP_SECRET_VALUE

# Replace any previous container and start the current application image.
docker rm -f fintrust-app >/dev/null 2>&1 || true

docker run -d \
  --name fintrust-app \
  --restart unless-stopped \
  --env-file /opt/fintrust/.env \
  -p 5000:5000 \
  "${ecr_repo}:latest"
