# Arquitectura del Sistema APRO

## Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Diagrama de Arquitectura Global](#diagrama-de-arquitectura-global)
3. [Componentes Principales](#componentes-principales)
4. [Flujos de Trabajo](#flujos-de-trabajo)
5. [Seguridad y Compliance](#seguridad-y-compliance)
6. [Escalabilidad](#escalabilidad)
7. [Disaster Recovery](#disaster-recovery)

## Visión General

APRO es un sistema de aprovisionamiento y orquestación multi-capa diseñado para gestionar infraestructura heterogénea desde servidores de producción hasta estaciones de trabajo especializadas.

### Principios Arquitectónicos

1. **Separación de Concerns**: Control plane separado del data plane
2. **Infrastructure as Code**: Todo versionado y reproducible
3. **Defense in Depth**: Múltiples capas de seguridad
4. **Observability First**: Logs, métricas y trazas desde el diseño
5. **Fail-Safe**: Degradación elegante ante fallas

## Diagrama de Arquitectura Global

```mermaid
graph TB
    subgraph "Control Plane"
        subgraph "Automation Layer"
            Git[Git Repository<br/>Source of Truth]
            CI[GitLab CI/CD<br/>Pipeline]
            Ansible[Ansible Tower<br/>Orchestration]
            TF[Terraform<br/>IaC]
        end

        subgraph "Security Layer"
            Vault[HashiCorp Vault<br/>Secrets Management]
            Scanner[Security Scanner<br/>Trivy/OpenSCAP]
        end

        subgraph "Observability Layer"
            Prom[Prometheus<br/>Metrics]
            Grafana[Grafana<br/>Visualization]
            Loki[Loki<br/>Logs]
            Tempo[Tempo<br/>Traces]
            Alert[Alertmanager<br/>Alerts]
        end
    end

    subgraph "Data Plane"
        subgraph "Production Servers"
            Rocky[Rocky Linux 9<br/>RHEL Compatible]
            Debian[Debian 12+<br/>Stable]
            Ubuntu[Ubuntu 22.04+<br/>LTS]
            Arch[Arch Linux<br/>Rolling]
        end

        subgraph "Development Workstations"
            DevWS[DevOps Workstation<br/>Arch + Tools]
            SecWS[Security Workstation<br/>Kali/Arch Hybrid]
            GameWS[Gaming Workstation<br/>SteamOS/Chimera]
        end

        subgraph "Application Layer"
            Docker[Docker Containers]
            K8s[Kubernetes Pods]
            Legacy[Legacy Apps]
        end
    end

    subgraph "Storage & Backup"
        Borg[Borg Backup<br/>Encrypted Incremental]
        S3[S3-Compatible<br/>Object Storage]
        NFS[NFS/CIFS<br/>Shared Storage]
    end

    Git --> CI
    CI --> Ansible
    CI --> TF
    Ansible --> Vault
    TF --> Vault

    Ansible --> Rocky
    Ansible --> Debian
    Ansible --> Ubuntu
    Ansible --> Arch
    Ansible --> DevWS
    Ansible --> SecWS
    Ansible --> GameWS

    Rocky --> Docker
    Debian --> Docker
    Ubuntu --> K8s

    Docker --> Prom
    K8s --> Prom
    Prom --> Grafana
    Loki --> Grafana
    Tempo --> Grafana
    Prom --> Alert

    Rocky --> Borg
    Debian --> Borg
    Ubuntu --> Borg
    Borg --> S3

    Scanner -.Security Scan.-> Rocky
    Scanner -.Security Scan.-> Debian

    style Git fill:#e1f5fe
    style Ansible fill:#f3e5f5
    style Rocky fill:#fff3e0
```

## Componentes Principales

### 1. Control Plane

#### 1.1 Automation Layer

**Git Repository**
- **Propósito**: Single source of truth para toda la configuración
- **Tecnología**: Git (GitHub/GitLab)
- **Contenido**:
  - Playbooks Ansible
  - Módulos Terraform
  - Scripts de provisión
  - Configuraciones
  - Documentación

**CI/CD Pipeline**
- **Propósito**: Automatizar testing, validation y deployment
- **Tecnología**: GitLab CI / GitHub Actions
- **Fases**:
  1. Lint y validación de sintaxis
  2. Tests de infraestructura (Molecule, Terratest)
  3. Security scanning
  4. Deployment automático
  5. Smoke tests post-deployment

**Ansible Tower/AWX**
- **Propósito**: Orquestación centralizada de configuración
- **Características**:
  - Inventario dinámico
  - Job scheduling
  - RBAC (Role-Based Access Control)
  - Audit logging
  - Credential management

**Terraform**
- **Propósito**: Provisión de infraestructura cloud
- **Alcance**:
  - VMs en cloud providers
  - Networking (VPC, subnets, security groups)
  - Storage (S3, EBS, etc)
  - Load balancers
  - DNS records

#### 1.2 Security Layer

**HashiCorp Vault**
- **Propósito**: Gestión centralizada de secretos
- **Capacidades**:
  - Dynamic secrets
  - Encryption as a service
  - PKI management
  - Secret rotation
  - Audit logging

**Security Scanners**
- **Trivy**: Vulnerabilidades en contenedores e IaC
- **OpenSCAP**: Compliance scanning (CIS, STIG)
- **Lynis**: Auditoría de sistemas Linux

#### 1.3 Observability Layer

**Prometheus**
- **Métricas**: CPU, RAM, disco, red, application metrics
- **Exporters**:
  - Node Exporter (métricas de host)
  - cAdvisor (métricas de contenedores)
  - Blackbox Exporter (probes)
  - Custom exporters

**Grafana**
- **Dashboards**:
  - Overview de infraestructura
  - Por servidor/servicio
  - Application performance
  - Security metrics
  - Business metrics

**Loki**
- **Logs centralizados**:
  - Syslog
  - Application logs
  - Audit logs
  - Container logs
- **Integración con Grafana para correlación**

**Alertmanager**
- **Alertas inteligentes**:
  - Agrupación de alertas
  - Silencing
  - Routing a múltiples receivers (email, Slack, PagerDuty)
  - Escalation policies

### 2. Data Plane

#### 2.1 Production Servers

**Rocky Linux 9**
- **Casos de uso**: Servidores enterprise que requieren RHEL compatibility
- **Características**:
  - Long-term support (10 años)
  - SELinux enforcing
  - Compatible con Red Hat ecosystem
  - Ideal para cargas críticas

**Debian 12+**
- **Casos de uso**: Servidores estables de propósito general
- **Características**:
  - Extremadamente estable
  - Gran repositorio de paquetes
  - Política de seguridad sólida
  - Bajo footprint

**Ubuntu 22.04 LTS+**
- **Casos de uso**: Servidores con necesidad de software reciente
- **Características**:
  - LTS support de 5 años
  - Hardware moderno bien soportado
  - Snaps para software adicional
  - Cloud-native features

**Arch Linux**
- **Casos de uso**: Laboratorios, desarrollo, testing
- **Características**:
  - Rolling release
  - Bleeding edge packages
  - AUR (Arch User Repository)
  - Máxima flexibilidad

#### 2.2 Development Workstations

**DevOps Workstation**
```
Base: Arch Linux
Desktop: GNOME/KDE/i3wm
Tools:
  - Docker + Docker Compose + Kubernetes
  - Terraform + Ansible + Packer
  - VSCode + JetBrains IDEs
  - Git + GitHub CLI
  - Terminal tools (tmux, zsh, fzf, ripgrep)
  - Cloud CLIs (aws, gcloud, az)
```

**Security Workstation**
```
Base: Arch Linux + Kali repos
Desktop: GNOME/Xfce
Tools:
  - Burp Suite Professional
  - Metasploit Framework
  - Nmap + Wireshark
  - SQLMap, Nikto, etc
  - Reverse engineering (Ghidra, radare2)
  - VM management (Vagrant, VirtualBox)
  - Report tools (CherryTree, Obsidian)
```

**Gaming Workstation**
```
Base: SteamOS/ChimeraOS (Arch-based)
Desktop: Gaming mode + Desktop mode (KDE)
Features:
  - Steam + Proton
  - Lutris + Wine
  - Epic Games (via Heroic)
  - Performance optimization
  - RGB control
  - Game streaming (Moonlight)
```

### 3. Storage & Backup

**Borg Backup**
- **Características**:
  - Deduplicación
  - Compresión
  - Cifrado
  - Verificación de integridad
- **Políticas**:
  - Diario: 7 días
  - Semanal: 4 semanas
  - Mensual: 6 meses
  - Anual: 2 años

**S3-Compatible Storage**
- **Providers**: AWS S3, MinIO, Backblaze B2
- **Uso**:
  - Terraform state
  - Borg repositories
  - Artifacts de CI/CD
  - Backups offsite

## Flujos de Trabajo

### Workflow 1: Provisión de Nuevo Servidor

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Git as Git Repo
    participant CI as CI/CD Pipeline
    participant Ansible as Ansible
    participant Vault as Vault
    participant Server as Target Server
    participant Monitor as Monitoring

    Dev->>Git: 1. Commit configuración
    Git->>CI: 2. Trigger pipeline
    CI->>CI: 3. Validar sintaxis
    CI->>CI: 4. Run tests
    CI->>CI: 5. Security scan
    CI->>Ansible: 6. Ejecutar playbook
    Ansible->>Vault: 7. Obtener secretos
    Vault-->>Ansible: 8. Secretos
    Ansible->>Server: 9. Provisionar
    Server->>Server: 10. Aplicar configuración
    Server->>Monitor: 11. Enviar métricas
    Monitor->>Dev: 12. Dashboard actualizado
    Ansible-->>CI: 13. Status
    CI-->>Dev: 14. Notificar éxito
```

### Workflow 2: Backup y Recovery

```mermaid
sequenceDiagram
    participant Cron as Cron Job
    participant Server as Server
    participant Borg as Borg
    participant S3 as S3 Storage
    participant Alert as Alerting
    participant Admin as Admin

    Cron->>Borg: 1. Trigger backup
    Borg->>Server: 2. Leer datos
    Borg->>Borg: 3. Deduplicar + Comprimir
    Borg->>Borg: 4. Cifrar
    Borg->>S3: 5. Upload incremental
    S3-->>Borg: 6. Confirmar
    Borg->>Borg: 7. Verificar integridad

    alt Backup exitoso
        Borg->>Alert: 8. Log success
    else Backup fallido
        Borg->>Alert: 8. Alerta crítica
        Alert->>Admin: 9. Notificar
    end

    Note over Admin,Server: --- Scenario de Recovery ---

    Admin->>Borg: 10. Solicitar restore
    Borg->>S3: 11. Download backup
    S3-->>Borg: 12. Datos cifrados
    Borg->>Borg: 13. Descifrar + Descomprimir
    Borg->>Server: 14. Restaurar archivos
    Server-->>Admin: 15. Recovery completado
```

### Workflow 3: Deployment de Aplicación

```mermaid
graph LR
    A[Código Nuevo] --> B[Git Push]
    B --> C[CI: Build]
    C --> D[CI: Test]
    D --> E[CI: Scan]
    E --> F{Tests Pass?}
    F -->|No| G[Notificar Desarrollador]
    F -->|Sí| H[Build Container Image]
    H --> I[Push to Registry]
    I --> J[Ansible: Deploy]
    J --> K[Rolling Update]
    K --> L[Health Check]
    L --> M{Healthy?}
    M -->|No| N[Rollback]
    M -->|Sí| O[Deployment Exitoso]
    N --> G
    O --> P[Monitoreo Continuo]

    style A fill:#a5d6a7
    style O fill:#81c784
    style G fill:#ef5350
    style N fill:#ff8a65
```

## Seguridad y Compliance

### Modelo de Seguridad en Capas

```mermaid
graph TB
    subgraph "Layer 1: Perimeter"
        FW[Firewall<br/>UFW/Firewalld]
        IPS[IPS/IDS<br/>Fail2Ban/Suricata]
    end

    subgraph "Layer 2: Network"
        VPN[VPN<br/>WireGuard]
        Segmentation[Network Segmentation<br/>VLANs]
    end

    subgraph "Layer 3: Host"
        Hardening[OS Hardening<br/>CIS Benchmarks]
        MAC[Mandatory Access Control<br/>SELinux/AppArmor]
        AuditD[Auditing<br/>auditd]
    end

    subgraph "Layer 4: Application"
        WAF[Web Application Firewall<br/>ModSecurity]
        Secrets[Secrets Management<br/>Vault]
        RBAC[Role-Based Access Control]
    end

    subgraph "Layer 5: Data"
        Encryption[Encryption at Rest<br/>LUKS/dm-crypt]
        TLS[Encryption in Transit<br/>TLS 1.3]
        Backup[Encrypted Backups<br/>Borg]
    end

    FW --> VPN
    IPS --> Segmentation
    VPN --> Hardening
    Segmentation --> MAC
    Hardening --> WAF
    MAC --> Secrets
    AuditD --> RBAC
    WAF --> Encryption
    Secrets --> TLS
    RBAC --> Backup

    style FW fill:#ffcdd2
    style WAF fill:#f8bbd0
    style Encryption fill:#e1bee7
```

### Compliance

#### CIS Benchmarks

Aplicamos los siguientes benchmarks de CIS:
- CIS Debian Linux 12 Benchmark (Level 1 Server)
- CIS Ubuntu Linux 22.04 LTS Benchmark (Level 1 Server)
- CIS Red Hat Enterprise Linux 9 Benchmark (Level 1 Server)
- CIS Docker Benchmark
- CIS Kubernetes Benchmark

#### Auditoría

```yaml
Audit Points:
  - User authentication events
  - Privileged command execution
  - File access (sensitive files)
  - Network connections
  - System calls (suspicious activity)
  - Configuration changes
  - Service start/stop

Retention:
  - Local: 30 días
  - Centralizado: 1 año
  - Archive: 7 años
```

## Escalabilidad

### Horizontal Scaling

```mermaid
graph LR
    LB[Load Balancer<br/>HAProxy/Nginx]

    subgraph "Web Tier"
        W1[Web Server 1]
        W2[Web Server 2]
        W3[Web Server 3]
        WN[Web Server N]
    end

    subgraph "App Tier"
        A1[App Server 1]
        A2[App Server 2]
        A3[App Server 3]
        AN[App Server N]
    end

    subgraph "Data Tier"
        DB1[(Primary DB)]
        DB2[(Replica 1)]
        DB3[(Replica 2)]
    end

    LB --> W1
    LB --> W2
    LB --> W3
    LB --> WN

    W1 --> A1
    W2 --> A2
    W3 --> A3
    WN --> AN

    A1 --> DB1
    A2 --> DB1
    A3 --> DB1
    AN --> DB1

    DB1 -.Replication.-> DB2
    DB1 -.Replication.-> DB3

    style LB fill:#4fc3f7
    style DB1 fill:#81c784
```

### Auto-Scaling (Cloud)

```yaml
Auto-Scaling Policy:
  Metric: CPU Utilization
  Target: 70%

  Scale Up:
    - Threshold: > 80% por 5 minutos
    - Action: Add 1 instance
    - Cooldown: 300 segundos

  Scale Down:
    - Threshold: < 30% por 10 minutos
    - Action: Remove 1 instance
    - Cooldown: 600 segundos

  Limits:
    - Min instances: 2
    - Max instances: 10
```

## Disaster Recovery

### RTO y RPO Targets

| Tier | Criticidad | RTO | RPO | Estrategia |
|------|------------|-----|-----|------------|
| 1 | Crítico | 15 min | 5 min | Hot standby + replicación síncrona |
| 2 | Importante | 1 hora | 15 min | Warm standby + replicación asíncrona |
| 3 | Normal | 4 horas | 1 hora | Cold standby + backups frecuentes |
| 4 | Bajo | 24 horas | 24 horas | Restore desde backup |

### Plan de Disaster Recovery

```mermaid
stateDiagram-v2
    [*] --> Normal: Sistema Operativo
    Normal --> Incidente: Falla Detectada
    Incidente --> Evaluación: Alerta Automática

    Evaluación --> Incidente_Menor: Severidad Baja
    Evaluación --> Incidente_Mayor: Severidad Alta
    Evaluación --> Desastre: Severidad Crítica

    Incidente_Menor --> Reparación: Auto-healing
    Reparación --> Normal: Resuelto

    Incidente_Mayor --> Escalación: Manual
    Escalación --> Mitigación: Plan B
    Mitigación --> Normal: Resuelto

    Desastre --> DR_Activado: Failover a DR Site
    DR_Activado --> Recuperación: Restore Services
    Recuperación --> Normal: Sistema Restaurado

    Desastre --> [*]: Data Loss (RPO exceeded)
```

### Backup Strategy

```yaml
Backup Tiers:

  Application Data:
    Type: Full + Incremental
    Schedule:
      - Full: Semanal (Domingo 2 AM)
      - Incremental: Diario (2 AM)
    Retention: 30 días local, 1 año offsite
    Encryption: AES-256
    Compression: zstd

  Databases:
    Type: Continuous + Point-in-Time
    Schedule:
      - WAL Archive: Cada 5 minutos
      - Full Backup: Diario (3 AM)
    Retention: 7 días PITR, 30 días full
    Encryption: AES-256

  System Configuration:
    Type: Git + Borg
    Schedule:
      - Git: On change
      - Borg: Diario (1 AM)
    Retention: Indefinido (Git), 90 días (Borg)

  Disaster Recovery:
    Type: Full System Image
    Schedule: Semanal (Sábado 11 PM)
    Retention: 4 imágenes (1 mes)
    Storage: Offsite S3
```

## Tecnologías y Versiones

| Componente | Tecnología | Versión | Notas |
|------------|-----------|---------|-------|
| OS Server | Rocky Linux | 9.x | Primary |
| OS Server | Debian | 12+ | Secondary |
| OS Desktop | Arch Linux | Rolling | Dev/Security |
| Orchestration | Ansible | 2.15+ | Con AWX |
| IaC | Terraform | 1.6+ | Multi-cloud |
| Containers | Docker | 24.x+ | Con Compose |
| Orchestration | Kubernetes | 1.28+ | Optional |
| Monitoring | Prometheus | 2.48+ | Metrics |
| Visualization | Grafana | 10.x+ | Dashboards |
| Logging | Loki | 2.9+ | Log aggregation |
| Backup | Borg | 1.4+ | Encrypted |
| Secrets | Vault | 1.15+ | Enterprise features |
| Firewall | UFW/Firewalld | Latest | OS dependent |
| Security | Fail2Ban | 1.0+ | Brute-force protection |

## Diagrama de Red

```mermaid
graph TB
    subgraph "DMZ"
        LB[Load Balancer<br/>Public IP]
        FW1[Firewall]
    end

    subgraph "Web Tier - 10.0.1.0/24"
        W1[Web 1<br/>10.0.1.10]
        W2[Web 2<br/>10.0.1.11]
    end

    subgraph "App Tier - 10.0.2.0/24"
        A1[App 1<br/>10.0.2.10]
        A2[App 2<br/>10.0.2.11]
    end

    subgraph "Data Tier - 10.0.3.0/24"
        DB1[(DB Primary<br/>10.0.3.10)]
        DB2[(DB Replica<br/>10.0.3.11)]
    end

    subgraph "Management - 10.0.254.0/24"
        Ansible[Ansible<br/>10.0.254.10]
        Monitor[Monitoring<br/>10.0.254.11]
        Backup[Backup<br/>10.0.254.12]
    end

    Internet((Internet)) --> LB
    LB --> FW1
    FW1 --> W1
    FW1 --> W2
    W1 --> A1
    W2 --> A2
    A1 --> DB1
    A2 --> DB1
    DB1 -.Replication.-> DB2

    Ansible -.Mgmt.-> W1
    Ansible -.Mgmt.-> A1
    Ansible -.Mgmt.-> DB1

    Monitor -.Scrape.-> W1
    Monitor -.Scrape.-> A1
    Monitor -.Scrape.-> DB1

    Backup -.Backup.-> DB1

    style DMZ fill:#ffebee
    style Web fill:#e3f2fd
    style App fill:#f3e5f5
    style Data fill:#e8f5e9
    style Management fill:#fff3e0
```

## Próximos Pasos

1. **Implementar Ansible roles** para cada componente
2. **Crear módulos Terraform** para AWS/Azure/GCP
3. **Configurar stack de monitoreo** (Prometheus + Grafana + Loki)
4. **Automatizar backups** con Borg
5. **Desarrollar playbooks para escritorios**
6. **Integrar CI/CD** con GitLab/GitHub Actions
7. **Documentar runbooks** operativos

---

**Documento vivo**: Esta arquitectura evolucionará según las necesidades del proyecto.
**Versión**: 1.0.0
**Fecha**: 2025-01-15
**Autor**: Juan Damian Pajares
