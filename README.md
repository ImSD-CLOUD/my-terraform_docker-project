# AWS ECS Fargate Deployment with Terraform & CI/CD

A fully automated, production-ready infrastructure for deploying containerized web applications on AWS ECS Fargate using Infrastructure as Code (Terraform) and CI/CD (GitHub Actions).

## 🏗️ Architecture Overview

This project implements a secure, highly available, multi-tier architecture on AWS:

- **Compute**: ECS Fargate containers running in private subnets across multiple availability zones
- **Load Balancing**: Application Load Balancer distributing traffic across containers
- **Networking**: Custom VPC with public/private subnet architecture, NAT Gateway, and Internet Gateway
- **Security**: VPC Endpoints for private AWS service access, Security Groups with least-privilege access
- **CI/CD**: Automated deployments via GitHub Actions with zero-downtime rolling updates

## 🎯 Key Features

- ✅ Infrastructure as Code using Terraform
- ✅ Containerized application deployment with Docker
- ✅ Automated CI/CD pipeline with GitHub Actions
- ✅ Multi-AZ deployment for high availability
- ✅ Private subnet architecture with NAT Gateway
- ✅ VPC Endpoints for secure AWS service communication
- ✅ Application Load Balancer with health checks
- ✅ CloudWatch logging and monitoring
- ✅ Remote state management with S3 backend

## 🛠️ Technologies Used

| Category | Technologies |
|----------|-------------|
| **Cloud Provider** | AWS (ECS, Fargate, VPC, ALB, ECR, CloudWatch) |
| **Infrastructure as Code** | Terraform |
| **Containerization** | Docker |
| **CI/CD** | GitHub Actions |
| **Version Control** | Git, GitHub |

## 📐 Architecture Diagram

```
                    Internet
                        │
                        ▼
                ┌───────────────┐
                │  Internet GW  │
                └───────────────┘
                        │
        ┌───────────────┴───────────────┐
        ▼                               ▼
┌──────────────────┐          ┌──────────────────┐
│  Public Subnet   │          │  Public Subnet   │
│   us-east-1b     │          │   us-east-1c     │
│                  │          │                  │
│  ┌───────────┐   │          │  ┌───────────┐   │
│  │    ALB    │◄──┼──────────┼─►│    ALB    │   │
│  └───────────┘   │          │  └───────────┘   │
│  ┌───────────┐   │          │                  │
│  │    NAT    │   │          │                  │
│  └───────────┘   │          │                  │
└────────┬─────────┘          └──────────────────┘
         │
         ▼
┌──────────────────┐          ┌──────────────────┐
│ Private Subnet   │          │ Private Subnet   │
│  us-east-1b      │          │  us-east-1c      │
│                  │          │                  │
│  ┌───────────┐   │          │  ┌───────────┐   │
│  │ ECS Task  │   │          │  │ ECS Task  │   │
│  └───────────┘   │          │  └───────────┘   │
│  VPC Endpoints   │          │  VPC Endpoints   │
└──────────────────┘          └──────────────────┘
```

## 📂 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline configuration
├── app/
│   ├── Dockerfile              # Container image definition
│   └── index.html              # Web application
├── terraform/
│   ├── alb.tf                  # Application Load Balancer
│   ├── backend.tf              # S3 backend configuration
│   ├── ecs.tf                  # ECS cluster, task definition, service
│   ├── ecr.tf                  # Container registry
│   ├── internetgateway.tf      # Internet Gateway
│   ├── natgateway.tf           # NAT Gateway & Elastic IP
│   ├── routetables.tf          # Route tables & associations
│   ├── securitygroup.tf        # Security groups
│   ├── subnet.tf               # Public & private subnets
│   ├── vpc.tf                  # Virtual Private Cloud
│   ├── vpc_endpoints.tf        # VPC endpoints for AWS services
│   └── outputs.tf              # Terraform outputs
├── docs/
│   └── project-screenshots.pdf # Detailed documentation
└── README.md
```

## 🚀 Deployment Workflow

### Infrastructure Provisioning
1. **Terraform Init**: Initialize backend and download providers
2. **Terraform Apply**: Create all AWS resources (VPC, subnets, ALB, ECS, etc.)

### Application Deployment
3. **Docker Build**: Build container image from Dockerfile
4. **Push to ECR**: Upload image to Amazon Elastic Container Registry
5. **ECS Deploy**: Update task definition and trigger rolling deployment

### Continuous Deployment
- Every push to `main` branch triggers the full CI/CD pipeline
- Zero-downtime deployments with health checks
- Automated rollback on deployment failures

## 📋 Prerequisites

- AWS Account with appropriate permissions
- GitHub account
- Terraform installed locally (for manual operations)
- AWS CLI configured (optional)

## 🔧 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/ImSD-CLOUD/my-terraform_docker-project.git
cd my-terraform_docker-project
```

### 2. Configure AWS Credentials
Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Settings → Secrets and variables → Actions → New repository secret**

### 3. Create S3 Bucket for Terraform State
```bash
aws s3 mb s3://terraform-docker-state-bucket --region us-east-1
```

### 4. Deploy Infrastructure
Push to the `main` branch to trigger the automated deployment:
```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

### 5. Access Your Application
After deployment completes, get the ALB DNS name:
```bash
cd terraform
terraform output alb_dns_name
```

Visit `http://<alb-dns-name>` in your browser.

## 🔒 Security Features

- **Private Subnets**: ECS tasks run in private subnets with no direct internet access
- **VPC Endpoints**: Secure, private communication with ECR and CloudWatch
- **Security Groups**: Restrictive rules allowing only necessary traffic
- **IAM Roles**: Least-privilege permissions for ECS tasks
- **NAT Gateway**: Controlled outbound internet access for private resources

## 💰 Cost Optimization

Approximate monthly costs (us-east-1):
- NAT Gateway: ~$32
- ALB: ~$16
- VPC Endpoints: ~$29
- ECS Fargate (2 tasks): ~$7
- **Total: ~$85-95/month**

### To Reduce Costs:
- Remove VPC Endpoints and use NAT Gateway only
- Reduce to 1 ECS task
- Use public subnets (testing only)
- Destroy infrastructure when not in use: `terraform destroy`

## 📊 Monitoring & Logs

- **CloudWatch Logs**: Container logs available at `/ecs/app-task-definition`
- **ECS Service Events**: Deployment status and health check results
- **ALB Target Health**: Monitor target group health in AWS Console

## 🔄 Making Updates

### Update Application Code
1. Modify `app/index.html`
2. Commit and push to `main`
3. GitHub Actions automatically builds and deploys

### Update Infrastructure
1. Modify Terraform files
2. Commit and push to `main`
3. Terraform applies changes automatically

## 🧹 Cleanup

To destroy all resources and avoid charges:

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted. All resources will be deleted, but your code remains in GitHub.

## 📸 Documentation

For detailed screenshots and step-by-step workflow, see [Project Documentation](docs/project-screenshots.pdf)

## 🎓 Learning Outcomes

Through this project, I gained hands-on experience with:
- Designing cloud-native architectures on AWS
- Infrastructure as Code with Terraform
- Container orchestration with ECS Fargate
- Building automated CI/CD pipelines
- Implementing security best practices in cloud environments
- Managing stateful infrastructure deployments
- Cost optimization strategies for cloud resources

## 🤝 Contributing

This is a learning project, but suggestions and improvements are welcome! Feel free to open an issue or submit a pull request.

## 📝 License

This project is open source and available under the MIT License.

## 👤 Author

**Swarup Das**
- GitHub: [@ImSD-CLOUD](https://github.com/ImSD-CLOUD)
- LinkedIn: [Swarup Das](https://www.linkedin.com/in/swarup-das-17bb03202/)

---

⭐ If you found this project helpful, please consider giving it a star!
