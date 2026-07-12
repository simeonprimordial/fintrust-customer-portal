#!/bin/bash
set -eux

# Update packages
dnf update -y

# Install Docker
dnf install -y docker

# Enable Docker
systemctl enable docker
systemctl start docker

# Login to Amazon ECR
aws ecr get-login-password --region ${aws_region} \
| docker login \
--username AWS \
--password-stdin ${ecr_repo}

# Pull latest image
docker pull ${ecr_repo}:latest

# Create application directory
mkdir -p /opt/fintrust

# Create environment file
cat > /opt/fintrust/.env <<EOF
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}
SECRET_KEY=${secret_key}
EOF

# Give networking a moment
sleep 20

# Run container
docker rm -f fintrust-app || true

docker run -d \
  --name fintrust-app \
  --restart unless-stopped \
  --env-file /opt/fintrust/.env \
  -p 5000:5000 \
  ${ecr_repo}:latest