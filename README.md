# APRO - Advanced Provisioning & Orchestration v3.0

Sistema integral de aprovisionamiento, configuración y gestión de infraestructura que abarca desde servidores en producción hasta estaciones de trabajo especializadas, con enfoque en seguridad, automatización y observabilidad.

## 🚀 Características

### Seguridad (Hardening)
- ✅ Hardening del kernel (sysctl)
- ✅ Configuración SSH hardened (solo claves, sin root)
- ✅ Firewall (UFW/Firewalld) con reglas restrictivas
- ✅ Fail2Ban para protección contra brute-force
- ✅ Actualizaciones automáticas de seguridad
- ✅ Sistema de auditoría (auditd)
- ✅ Límites del sistema optimizados

### Gestión de Proyectos
- ✅ Clonado automático desde GitHub
- ✅ Detección automática de tipo de proyecto (Docker/LAMP)
- ✅ Configuración de ambientes (dev/stage/prod)
- ✅ Generación automática de archivos .env
- ✅ Despliegue automático de contenedores Docker

### SSH y GitHub
- ✅ Generación automática de claves SSH (Ed25519)
- ✅ Configuración de SSH para GitHub
- ✅ Soporte para claves SSH proporcionadas
- ✅ Verificación de conectividad

## 📋 Requisitos

### Servidores
- **Debian** 11+ | **Ubuntu** 20.04 LTS+ | **Rocky Linux** 8/9 | **AlmaLinux** 8/9 | **Arch Linux**
- Usuario con privilegios sudo
- Conexión a Internet
- Mínimo 2GB RAM, 20GB disco

### Workstations
- **Arch Linux** (recomendado para escritorios)
- Mínimo 4GB RAM, 50GB disco
- GPU compatible (para gaming desktop)

## 🔧 Uso Básico

### Modo Interactivo

```bash
sudo bash provision.sh
```

El script mostrará un menú con las siguientes opciones:

1. **Instalación completa con hardening + proyecto** - Todo incluido
2. **Solo hardening de seguridad** - Sin instalación de aplicaciones
3. **Instalar LAMP local** - Apache, MariaDB, PHP
4. **Instalar Docker** - Docker Engine con hardening
5. **Configurar proyecto desde repositorio** - Clona y configura tu proyecto
6. **Configurar firewall** - Solo UFW/Firewalld
7. **Configurar SSH hardened** - Solo configuración SSH
8. **Configurar SSH para GitHub** - Solo claves SSH
9. **Salir**

### Modo Automático con Variables de Entorno

Para automatización completa, puedes pasar variables de entorno:

```bash
# Ejemplo completo: Instalación con hardening + proyecto
PROJECT_REPO_URL="git@github.com:usuario/repo.git" \
PROJECT_ENVIRONMENT="prod" \
PROJECT_DIR="/opt/mi-app" \
SSH_PORT=2222 \
FAIL2BAN_ENABLED=true \
AUTO_UPDATES_ENABLED=true \
sudo -E bash provision.sh
```

## 🌍 Variables de Entorno

### Configuración de Seguridad

| Variable | Descripción | Default |
|----------|-------------|---------|
| `SSH_PORT` | Puerto SSH personalizado | `22` |
| `FAIL2BAN_ENABLED` | Habilitar Fail2Ban | `true` |
| `AUTO_UPDATES_ENABLED` | Actualizaciones automáticas | `true` |

### Configuración del Proyecto

| Variable | Descripción | Default | Ejemplo |
|----------|-------------|---------|---------|
| `PROJECT_REPO_URL` | URL del repositorio Git | - | `git@github.com:user/repo.git` |
| `PROJECT_ENVIRONMENT` | Ambiente del proyecto | `dev` | `dev`, `stage`, `prod` |
| `PROJECT_TYPE` | Tipo de proyecto | Auto-detectado | `docker`, `lamp` |
| `PROJECT_DIR` | Directorio del proyecto | `/opt/app` | `/var/www/mi-app` |
| `SETUP_GITHUB_SSH` | Configurar SSH para GitHub | `true` | `true`, `false` |
| `SSH_KEY_PATH` | Ruta a clave SSH existente | - | `/home/user/.ssh/id_ed25519` |

## 📝 Ejemplos de Uso

### Ejemplo 1: Instalación Completa en Producción

```bash
# Servidor de producción con puerto SSH personalizado
PROJECT_REPO_URL="git@github.com:juandamianpajares/cotizador-laminas.git" \
PROJECT_ENVIRONMENT="prod" \
PROJECT_DIR="/opt/cotizador" \
SSH_PORT=2222 \
sudo -E bash provision.sh
# Selecciona opción 1 en el menú
```

### Ejemplo 2: Solo Configurar Proyecto Existente

```bash
# Ya tienes el servidor configurado, solo quieres deployar
PROJECT_REPO_URL="git@github.com:user/repo.git" \
PROJECT_ENVIRONMENT="dev" \
PROJECT_DIR="/home/user/mi-proyecto" \
sudo -E bash provision.sh
# Selecciona opción 5 en el menú
```

### Ejemplo 3: Usar Clave SSH Existente

```bash
# Si ya tienes una clave SSH que quieres usar
SSH_KEY_PATH="/ruta/a/tu/clave/id_ed25519" \
PROJECT_REPO_URL="git@github.com:user/repo.git" \
sudo -E bash provision.sh
# Selecciona opción 8 o 5
```

### Ejemplo 4: Solo Hardening (Sin Proyecto)

```bash
# Solo aplicar hardening de seguridad
SSH_PORT=2222 \
FAIL2BAN_ENABLED=true \
sudo -E bash provision.sh
# Selecciona opción 2
```

## 🐳 Proyectos Docker

Para proyectos Docker, el script:

1. Detecta automáticamente si existe `docker-compose.yml` o `docker-compose.dev.yml`
2. Instala Docker si no está presente
3. Crea archivo `.env` según el ambiente seleccionado
4. Selecciona el archivo docker-compose correcto:
   - `dev` → `docker-compose.dev.yml`
   - `stage` → `docker-compose.stage.yml`
   - `prod` → `docker-compose.prod.yml` o `docker-compose.yml`
5. Construye e inicia los contenedores
6. Configura el firewall para los puertos necesarios

### Archivos .env Generados

#### Desarrollo
```env
NODE_ENV=development
MYSQL_ROOT_PASSWORD=DevPass123
MYSQL_DATABASE=cotizador_laminas
MYSQL_USER=juan
MYSQL_PASSWORD=DevPass123
MYSQL_PORT=3306
APP_PORT=3000
PHPMYADMIN_PORT=8080
```

#### Producción
```env
NODE_ENV=production
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
MYSQL_DATABASE=cotizador_laminas
MYSQL_USER=appuser
MYSQL_PASSWORD=$(openssl rand -base64 32)
MYSQL_PORT=3306
APP_PORT=3000
PHPMYADMIN_PORT=8080
```

## 🔒 Configuración de SSH

### Claves SSH Generadas Automáticamente

El script genera claves Ed25519 (más seguras que RSA) con el formato:
```
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

### Configuración SSH Hardened

El script aplica las siguientes configuraciones de seguridad en `/etc/ssh/sshd_config`:

- ✅ Solo autenticación por clave pública
- ✅ PermitRootLogin deshabilitado
- ✅ Máximo 3 intentos de autenticación
- ✅ Algoritmos de cifrado modernos (ChaCha20, AES-GCM)
- ✅ Forwarding deshabilitado
- ✅ Timeouts configurados

### Agregar Clave a GitHub

El script muestra la clave pública y te guía:

1. Copia la clave pública mostrada en pantalla
2. Ve a https://github.com/settings/ssh/new
3. Pega la clave y asigna un título
4. El script verifica la conexión automáticamente

## 🛡️ Hardening Aplicado

### Kernel y Red

- Protección contra IP spoofing
- SYN flood protection
- ICMP redirects deshabilitados
- Source routing deshabilitado
- Martian packets logging
- TCP time-wait protection

### Sistema de Archivos

- Protección de enlaces simbólicos
- Protección de hardlinks
- Protección de FIFOs
- Core dumps limitados
- ASLR habilitado

### Firewall

**Políticas:**
- Deny all incoming (por defecto)
- Allow all outgoing
- Allow SSH (puerto configurable)
- Allow HTTP (80)
- Allow HTTPS (443)
- Rate limiting en SSH

### Fail2Ban

- Ban después de 3 intentos fallidos
- Tiempo de ban: 1-2 horas
- Protección contra SSH DDoS

## 📊 Reporte de Seguridad

Al finalizar, el script muestra un reporte con:

- Sistema operativo detectado
- Puerto SSH configurado
- Estado del firewall
- Estado de Fail2Ban
- Estado de Docker
- Tareas pendientes

## 🔧 Post-Instalación

### Tareas Recomendadas

1. **Si instalaste LAMP:**
   ```bash
   sudo mysql_secure_installation
   ```

2. **Verificar firewall:**
   ```bash
   sudo ufw status verbose
   ```

3. **Monitorear logs:**
   ```bash
   sudo journalctl -f
   sudo tail -f /var/log/fail2ban.log
   ```

4. **Verificar Docker (si aplica):**
   ```bash
   docker ps
   docker compose logs -f
   ```

5. **Cerrar sesión y volver a entrar** para aplicar cambios de grupo

## 🐛 Troubleshooting

### Error: "No se ha podido localizar el paquete"

El script maneja automáticamente paquetes que pueden no estar disponibles en todas las versiones. Los paquetes opcionales se saltan sin detener la ejecución.

### Error: Formato de archivo incorrecto

Si el archivo fue editado en Windows:
```bash
sed -i 's/\r$//' provision.sh
chmod +x provision.sh
```

### Error: Docker no se conecta

Después de instalar Docker, cierra sesión y vuelve a entrar:
```bash
logout
# O reinicia el servidor
sudo reboot
```

### SSH no permite conexión después del hardening

Si te quedas sin acceso SSH:
- Usa la consola del servidor (acceso físico o panel de control)
- Restaura el backup: `sudo cp /etc/ssh/sshd_config.bak.* /etc/ssh/sshd_config`
- Reinicia SSH: `sudo systemctl restart sshd`

## 📁 Estructura de Directorios

```
/opt/app/                    # Proyecto por defecto
/etc/sysctl.d/99-hardening.conf    # Hardening del kernel
/etc/security/limits.d/99-custom.conf  # Límites del sistema
/etc/ssh/sshd_config         # SSH hardened
/etc/fail2ban/jail.local     # Fail2Ban
/etc/docker/daemon.json      # Docker hardened
~/.ssh/                      # Claves SSH
~/.ssh/config                # Configuración SSH
```

## 🔄 Actualización del Script

Para actualizar el script:
```bash
git pull origin main
sed -i 's/\r$//' provision.sh
chmod +x provision.sh
```

## 📞 Soporte

- GitHub Issues: https://github.com/usuario/repo/issues
- Documentación: https://github.com/usuario/repo/wiki

## 📜 Licencia

Este script es de código abierto y puede ser usado libremente.

## ⚠️ Advertencias

- **Producción**: Revisa cuidadosamente las configuraciones antes de usar en producción
- **Backups**: El script crea backups automáticos de archivos críticos
- **Contraseñas**: En producción, usa contraseñas seguras generadas aleatoriamente
- **Firewall**: Asegúrate de mantener acceso SSH antes de habilitar el firewall

## 🎯 Roadmap

### ✅ Fase 1: Fundamentos (Completado)
- [x] Script provision.sh con multi-distro
- [x] Soporte Rocky Linux 8/9
- [x] Estructura base de Ansible
- [x] Documentación de arquitectura

### 🔄 Fase 2: Observabilidad (En Progreso)
- [ ] Stack Prometheus + Grafana
- [ ] Loki para logs centralizados
- [ ] Exporters para métricas
- [ ] Dashboards predefinidos
- [ ] Sistema de alertas

### 📋 Fase 3: Backup & Recovery
- [ ] Borg Backup para servidores
- [ ] Políticas de retención
- [ ] Backup verification
- [ ] Restore testing automatizado
- [ ] Offsite replication

### 📋 Fase 4: Terraform & Cloud
- [ ] Módulos base para AWS
- [ ] Soporte multi-cloud
- [ ] State management
- [ ] Integración con Ansible

### 📋 Fase 5: Workstations
- [ ] DevOps Workstation (Arch)
- [ ] Security Workstation (Kali/Arch)
- [ ] Gaming Desktop (SteamOS/Chimera)

Ver [ROADMAP completo](docs/ROADMAP.md) para más detalles.

## 📚 Documentación

### Documentos Principales
- [📖 Visión General del Proyecto](docs/PROJECT_OVERVIEW.md) - Alcance, objetivos y principios
- [🏗️ Arquitectura del Sistema](docs/APRO_ARCHITECTURE.md) - Diagramas y componentes
- [🗺️ Roadmap Detallado](docs/ROADMAP.md) - Planificación por sprints
- [📋 Quick Start](docs/QUICKSTART.md) - Guía de inicio rápido
- [🔧 Troubleshooting](docs/TROUBLESHOOTING.md) - Solución de problemas

### Ansible
- [📘 Guía de Ansible](ansible/README.md) - Cómo usar los playbooks
- [🎭 Roles Disponibles](ansible/roles/README.md) - Documentación de roles
- [📦 Inventarios](ansible/inventories/README.md) - Gestión de hosts

### Terraform (Próximamente)
- Módulos para AWS, Azure, GCP
- Ejemplos de uso
- Best practices

## 🛠️ Estructura del Proyecto

```
apro/
├── ansible/                    # Automatización con Ansible
│   ├── playbooks/             # Playbooks principales
│   ├── roles/                 # Roles reutilizables
│   │   ├── common/           # Configuración básica
│   │   ├── hardening/        # Seguridad
│   │   ├── docker/           # Contenedores
│   │   ├── monitoring/       # Observabilidad
│   │   └── backup/           # Respaldos
│   ├── inventories/          # Inventarios de hosts
│   └── group_vars/           # Variables globales
├── terraform/                 # Infraestructura como código
│   ├── modules/              # Módulos reutilizables
│   └── environments/         # dev/stage/prod
├── docker/                    # Stacks de Docker
│   └── monitoring/           # Prometheus, Grafana, Loki
├── scripts/                   # Scripts auxiliares
│   └── provision.sh          # Bootstrap inicial
└── docs/                      # Documentación
    ├── architecture/         # Arquitectura
    ├── diagrams/             # Diagramas
    └── runbooks/             # Guías operativas
```

## 🚀 Quick Start

### 1. Provisionar un servidor con el script bash

```bash
# Clonar repositorio
git clone https://github.com/juandamianpajares/apro.git
cd apro

# Modo interactivo
sudo bash provision.sh

# Modo automático
PROJECT_REPO_URL="git@github.com:user/repo.git" \
PROJECT_ENVIRONMENT="prod" \
SSH_PORT=2222 \
sudo -E bash provision.sh
```

### 2. Usar Ansible (Recomendado)

```bash
# Instalar Ansible
sudo apt install ansible  # Debian/Ubuntu
sudo dnf install ansible  # Rocky/RHEL
sudo pacman -S ansible    # Arch

# Configurar inventario
cd ansible
cp inventories/production/hosts.yml.example inventories/production/hosts.yml
# Editar hosts.yml con tus servidores

# Ejecutar playbook completo
ansible-playbook playbooks/site.yml

# Ejecutar solo hardening
ansible-playbook playbooks/site.yml --tags hardening

# Provisionar solo servidores web
ansible-playbook playbooks/site.yml --limit web_servers
```

### 3. Provisionar workstation DevOps (Próximamente)

```bash
ansible-playbook playbooks/workstation-devops.yml
```

## 🔐 Seguridad

Este proyecto implementa:

- ✅ **CIS Benchmarks** - Level 1 Server
- ✅ **Kernel Hardening** - sysctl parameters
- ✅ **SSH Hardening** - Solo claves, sin root, cifrado moderno
- ✅ **Firewall** - UFW/Firewalld con reglas restrictivas
- ✅ **Fail2Ban** - Protección contra brute-force
- ✅ **SELinux/AppArmor** - Mandatory Access Control
- ✅ **Auditd** - Logging de eventos de seguridad
- ✅ **Automatic Updates** - Parches de seguridad automáticos

Ver [Security Guidelines](docs/SECURITY.md) para más detalles.

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una branch para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

## 📊 Estado del Proyecto

| Componente | Estado | Cobertura | Notas |
|------------|--------|-----------|-------|
| provision.sh | ✅ Estable | 100% | Multi-distro |
| Ansible Roles | 🔄 En Desarrollo | 60% | Core roles completos |
| Monitoring | 📋 Planeado | 0% | Sprint 3-4 |
| Backup | 📋 Planeado | 0% | Sprint 5-6 |
| Terraform | 📋 Planeado | 0% | Sprint 7-8 |
| Workstations | 📋 Planeado | 0% | Sprint 9-14 |

## 🌟 Casos de Uso

### 1. Startup Tech
- Aprovisionamiento rápido de servidores
- Infraestructura reproducible
- Costos controlados con automatización

### 2. Empresa Enterprise
- Compliance automático (CIS, ISO27001)
- Disaster recovery
- Multi-datacenter

### 3. Desarrollador Individual
- Dev environment consistente
- Workstation personalizada
- Lab de testing

### 4. Equipo de Seguridad
- Pentesting workstation
- Hardening automático
- Audit logging centralizado

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**Juan Damian Pajares**
- GitHub: [@juandamianpajares](https://github.com/juandamianpajares)
- Email: juandamianpajares@example.com

## 🙏 Agradecimientos

- Comunidad Open Source
- Ansible Community
- HashiCorp
- CIS Benchmarks
- Linux Foundation

---

**⭐ Si este proyecto te resulta útil, considera darle una estrella en GitHub!**

**Version**: 3.0.0
**Last Updated**: 2025-01-15
