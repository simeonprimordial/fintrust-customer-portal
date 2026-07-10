#!/bin/bash
set -euxo pipefail

# Log user data execution
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Update system
dnf update -y

# Install Docker
dnf install -y docker

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker
usermod -aG docker ec2-user

# Verify Docker installation
docker --version > /home/ec2-user/docker-version.txt

echo "User data completed successfully."