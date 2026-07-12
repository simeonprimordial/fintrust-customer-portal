# Architecture Decisions

## Project Overview

The FinTrust Customer Portal is a production-style cloud application deployed entirely on AWS using Infrastructure as Code (Terraform). The application is containerized with Docker, stored in Amazon ECR, and automatically deployed to EC2 instances managed by an Auto Scaling Group behind an Application Load Balancer.

---

# Architecture Decisions

## 1. Why Terraform?

Terraform was chosen to provision all AWS infrastructure because it provides:

- Infrastructure as Code (IaC)
- Repeatable deployments
- Version-controlled infrastructure
- Easy environment recreation
- Automated dependency management

Instead of manually creating AWS resources through the console, the entire infrastructure can be recreated with a single Terraform deployment.

---

## 2. Why a Custom VPC?

A custom Virtual Private Cloud (VPC) was created instead of using the default VPC to gain complete control over networking.

Benefits include:

- Network isolation
- Custom subnet design
- Explicit routing
- Better security boundaries
- Production-like architecture

---

## 3. Why Public and Private Subnets?

Resources were separated according to their exposure requirements.

### Public Subnets

Used for:

- Application Load Balancer
- NAT Gateway

These resources require internet connectivity.

### Private Application Subnets

Used for:

- EC2 instances

Application servers should never be directly exposed to the internet.

### Private Database Subnets

Used for:

- Amazon RDS

The database is isolated from public internet access.

---

## 4. Why an Application Load Balancer?

The Application Load Balancer (ALB) provides:

- Single entry point
- Health checks
- Traffic distribution
- High availability
- Integration with Auto Scaling

Only healthy instances receive application traffic.

---

## 5. Why Auto Scaling?

The Auto Scaling Group ensures application availability.

Benefits include:

- Automatic replacement of failed instances
- Elastic scaling
- High availability
- Simplified instance management

---

## 6. Why Docker?

Docker was used to package the Flask application together with all dependencies.

Benefits include:

- Consistent runtime
- Simplified deployments
- Environment portability
- Easy versioning
- Production-ready packaging

The same container image runs locally and in AWS.

---

## 7. Why Amazon ECR?

Amazon Elastic Container Registry stores the Docker images securely inside AWS.

Benefits include:

- Native AWS integration
- Secure image storage
- Versioned images
- IAM authentication
- Efficient image distribution

---

## 8. Why User Data?

EC2 User Data automates server bootstrapping.

Each new EC2 instance automatically:

- Installs Docker
- Authenticates with Amazon ECR
- Pulls the latest container image
- Creates the application environment file
- Starts the Docker container

This enables completely automated deployments.

---

## 9. Why Amazon RDS?

Amazon RDS provides a managed MySQL database.

Benefits include:

- Automated backups
- Managed patching
- Durable storage
- High reliability
- Managed database operations

---

## 10. Why SQLAlchemy?

SQLAlchemy provides an ORM layer between Flask and MySQL.

Benefits include:

- Cleaner database code
- Database abstraction
- Easier CRUD implementation
- Better maintainability

Connection pooling was configured using:

- pool_pre_ping
- pool_recycle

to improve reliability when communicating with Amazon RDS.

---

## 11. Why Environment Variables?

Sensitive configuration is stored using environment variables instead of hardcoding values.

This includes:

- Database host
- Database username
- Database password
- Secret key

This follows the Twelve-Factor App methodology.

---

## 12. Why Health Checks?

A dedicated `/health` endpoint was implemented.

The ALB uses this endpoint to determine whether an EC2 instance is healthy before routing traffic.

This provides safer deployments and improves availability.

---

# Future Improvements

Possible enhancements include:

- HTTPS using AWS Certificate Manager
- Route 53 custom domain
- AWS Secrets Manager
- CloudWatch dashboards
- CloudWatch alarms
- GitHub Actions CI/CD
- ECS deployment
- Kubernetes (Amazon EKS)
- Blue/Green deployments
- AWS WAF
- AWS CloudFront