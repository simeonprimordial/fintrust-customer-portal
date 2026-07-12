# Troubleshooting Guide

This document records the issues encountered during the development and deployment of the FinTrust Customer Portal together with their solutions.

---

# Issue 1

## Application Load Balancer returned 502 Bad Gateway

### Symptoms

- ALB DNS opened successfully.
- Browser returned:

502 Bad Gateway

### Cause

The EC2 User Data only installed Docker.

The application container was never started.

### Solution

Updated User Data to:

- Authenticate with Amazon ECR
- Pull the latest Docker image
- Create the application `.env`
- Start the Docker container

Result:

The ALB successfully routed traffic to the application.

---

# Issue 2

## Target Group Instances Unhealthy

### Symptoms

Target Group continuously reported:

Unhealthy

Auto Scaling repeatedly terminated and recreated EC2 instances.

### Cause

The Target Group was configured to send traffic to port 80 while the Flask application was listening on port 5000.

### Solution

Updated:

- Target Group port → 5000
- EC2 Security Group → allow TCP 5000
- Health Check endpoint → `/health`

Result:

All instances became healthy.

---

# Issue 3

## Local Docker Container Could Not Connect to RDS

### Symptoms

Customer pages returned errors locally.

Docker logs showed MySQL connection timeouts.

### Cause

Amazon RDS was deployed inside private subnets.

The local development machine could not directly access the database.

### Solution

Validated the application locally using a local database and verified RDS connectivity from EC2 instances inside the VPC.

---

# Issue 4

## SQLAlchemy Connection Errors

### Symptoms

The application intermittently failed when accessing the database.

### Cause

Idle MySQL connections became stale.

### Solution

Configured SQLAlchemy connection pooling:

```python
SQLALCHEMY_ENGINE_OPTIONS = {
    "pool_pre_ping": True,
    "pool_recycle": 280,
}
```

Result:

Stable database connectivity.

---

# Issue 5

## Environment Variables Not Loaded

### Symptoms

Application attempted to connect using invalid or missing database values.

### Cause

Environment variables were not correctly passed to the application.

### Solution

Created the `.env` file during EC2 bootstrapping and configured Flask to load values from environment variables.

---

# Issue 6

## Docker Image Changes Not Reflected

### Symptoms

Application changes did not appear after editing the source code.

### Cause

Docker images are immutable.

Existing EC2 instances continued running the previous image.

### Solution

Deployment workflow:

1. Build Docker image
2. Push image to Amazon ECR
3. Refresh Auto Scaling instances
4. New instances pull the updated image

---

# Issue 7

## Session Manager Could Not Connect

### Symptoms

EC2 instances did not appear under AWS Systems Manager Session Manager.

### Investigation

Verified:

- IAM role attachment
- NAT Gateway
- Private route tables
- Launch Template configuration

Although Session Manager remained unavailable during this project, deployment and application functionality were successfully validated through the Application Load Balancer.

Future improvements include adding VPC Interface Endpoints for AWS Systems Manager to enable private management without relying on internet connectivity.

---

# Lessons Learned

This project reinforced several important cloud engineering concepts:

- Infrastructure and application issues often occur together.
- Health checks are essential for reliable load balancing.
- Docker images must be rebuilt and redeployed after application changes.
- Auto Scaling launches new infrastructure but does not update running containers.
- Environment variables are the preferred method for application configuration.
- Managed services such as Amazon RDS simplify database administration while requiring proper network design.
- Infrastructure as Code makes deployments repeatable and easier to troubleshoot.

---

# Final Outcome

The completed solution includes:

- Terraform Infrastructure as Code
- Custom VPC
- Public and Private Subnets
- NAT Gateway
- Application Load Balancer
- Auto Scaling Group
- Launch Template
- Amazon RDS MySQL
- Dockerized Flask Application
- Amazon ECR
- Environment-based configuration
- Automated EC2 bootstrapping
- Health checks
- CRUD Customer Portal