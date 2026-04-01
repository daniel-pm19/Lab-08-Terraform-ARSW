# Lab #8 — Infraestructure as Code with Terraform (Azure)
**Course:** ARSW  
**Author:** Daniel Patiño Mejia

## Purpose
To modernize the Azure load balancing lab using Terraform to define, provision, and version the infrastructure. The goal is for students to design and deploy a reproducible, secure architecture that adheres to Infrastructure as a Community (IaC) best practices.

## Learning Objectives
1. Model Azure infrastructure with Terraform (providers, state, modules, and variables).

2. Deploy a high-availability architecture with a Load Balancer (L4) and 2+ Linux VMs.

3. Implement basic security hardening: NSG, SSH with a key, tags, and naming conventions.

4. Integrate a remote backend for the state in Azure Storage using state locking.

5. Automate plan/apply actions from GitHub Actions using OIDC authentication (without long secrets). 6. Validate operation (health probe, test page), monitor costs, and securely delete.

---

## Target Architecture
- **Resource Group** (e.g., `rg-lab8-<alias>`)
- **Virtual Network** with 2 subnets:

- `subnet-web`: VMs behind the **Azure Load Balancer (public)**

- `subnet-mgmt`: Bastion or hop (optional)
- **Network Security Group**: only allows **80/TCP** (HTTP) from the Internet to the Load Balancer and **22/TCP** (SSH) only from your public IP address.

- - Public **Load Balancer**:
  - Frontend public IP
  - Backend pool with 2+ VMs
  - **Health probe** (TCP/80 or HTTP)
  - **Load balancing rule** (80 → 80)
- **2+ Linux VMs** (Ubuntu LTS) with cloud-init/Custom Script Extension to install **nginx** and serve a page with **hostname**.
- **Azure Storage Account + Container** for Terraform **remote state** (with lock).
- **Tags**: `owner`, `course`, `env`, `expires`.

---

## Prerequisites
- Azure account/subscription (Azure for Students or equivalent).

- **Azure CLI** (`az`) and **Terraform >= 1.6** installed on your computer.

- Generated **SSH key** (e.g., `ssh-keygen -t ed25519`).

- **GitHub** account to run the Actions pipeline.

---

## Suggested Repository Structure
```

```` ├─ below/
│ ├─ main.tf
│ ├─ providers.tf
│ ├─ variables.tf
│ ├─ outputs.tf
│ ├─ backend.hcl.example
│ ├─ cloud-init.yaml
│ └─ send/
│ ├─ dev.tfvars
│ └─ prod.tfvars (optional)
├─ modules/
│ ├─ vnet/
│ │ ├─ main.tf
│ │ ├─ variables.tf
│ │ └─ outputs.tf
│ ├─ compute/
│ │ ├─ main.tf
│ │ ├─ variables.tf
│ │ └─ outputs.tf
│ └─ lb/
│ ├─ main.tf
│ ├─ variables.tf
│ └─ outputs.tf
└─ .github/workflows/terraform.yml
```

---
## Bootstrap for the remote backend
First, we create the **Resource Group**, **Storage Account**, and **Container** for the _state_:


![Bootstrap](./img/1.png)

This step encountered some problems because Microsoft.Storage was not registered as a provider for our Azure account, so we had to log in and enter the following commands:

![Issue](./img/2.png)

Login
![Issue2](./img/3.png)

Check and register:
![Issue3](./img/4.png)

![Issue4](./img/5.png)

After that, we tried entering the commands again:

![Bootstrap1](./img/6.png)
![Bootstrap2](./img/7.png)
![Bootstrap3](./img/8.png)

As we can see, it is created correctly. We continue entering the commands.

![Bootstrap4](./img/9.png)

Finally, we complete `infra/backend.hcl.example` with the created values ​​and rename it to `backend.hcl`.

![Bootstrap4](./img/10.png)

---

## Main Variables

In `infra/env/dev.tfvars` we modify the file with our data:

![MainVar](./img/17.png)

---

## Local Work Flux

We start following the next steps:
```bash
cd infra

# Azure Authentication
az login
az account show 
```

![Flux1](./img/3.png)

```bash
# Initialize Terraform with remote backend
terraform init -backend-config=backend.hcl
```

![Flux2](./img/11.png)

```bash
# Quick review
terraform fmt -recursive
terraform validate
```

![Flux3](./img/12.png)

```bash
# Plan with dev variables
terraform plan -var-file=env/dev.tfvars -out plan.tfplan
```

![Flux4](./img/13.png)
![Flux5](./img/14.png)

```bash
#Apply
terraform apply "plan.tfplan"
```

![Flux6](./img/15.png)

```bash
# Check the public LB (change to your IP)
curl http://$(terraform output -raw lb_public_ip)
```

**Expected outputs** (example):
- `lb_public_ip`
- `resource_group_name`
- `vm_names`

![Flux7](./img/16.png)


---

## GitHub Actions (CI/CD con OIDC)

For this part, we created the YAML file with the workflow; however, we couldn't proceed further because we lacked permissions to access the App Registrations functions. Nevertheless, we created the secrets on GitHub and uploaded the .yml file.

![Azure](./img/azure.png)

---

## Cleaning

After performing the procedure, we clean up the terraform using the following command:

```bash
terraform destroy -var-file=env/dev.tfvars
```

## Preguntas de reflexión
- ¿Por qué L4 LB vs Application Gateway (L7) en tu caso? ¿Qué cambiaría? 
  - R: Se usa un LB L4 y no un L7 debido a que este opera a nivel de capa de transporte y no analiza el contenido HTTP, lo que quiere decir que es mas simple y mas economico que uno de capa de aplicacion y pues para el laboratorio es mas que suficiente debido a que solo se necesita distribuir trafico HTTP. A su vez, este tiene menos complejidad a la hora de configurarlo. En comparacion con uno L7 es que este opera a nivel de aplicacion, lo que permite un routing basado en URL, terminacion TLS, mayor proteccion contra ataques ciberneticos. Lo ideal seria utilizarlo en caso de que hayan multiples aplicaciones detras del LB, seguridad avanzada y enrutamientos inteligentes.

- ¿Qué implicaciones de seguridad tiene exponer 22/TCP? ¿Cómo mitigarlas?

  Riesgos:
  - Ataques de fuerza bruta
  - Escaneo automático de bots
  - Intentos de acceso no autorizado
  - Posible explotación de vulnerabilidades del sistema

  Como mitigarlos?

  - Restringir el acceso a una unica IP
  - Autenticacion por SSH
  - Usar una VPN o una red privada
  - Monitoreo y registro de accesos
  - Desabilitar login con password y root login

- ¿Qué mejoras harías si esto fuera **producción**? (resiliencia, autoscaling, observabilidad).

  Resiliencia
  - Distribuir VMs en múltiples zonas
  - Health probes más robustos (HTTP y TCP)
  - Implementar failover automático
  - Backups y snapshots de VMs

  Autoscaling
  - Reemplazar VMs por VM Scale Set (VMSS)
  - Configurar escalado por CPU / requests y escalado automático
  - Integración con Load Balancer o Application Gateway

  Observabilidad
  - Azure Monitor + Log Analytics
  - Logs centralizados
  - Alertas
  - Dashboards (Azure Dashboard)