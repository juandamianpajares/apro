# 🚀 APRO - Comienza Aquí

**¡Bienvenido al proyecto APRO v3.0!**

Este es tu punto de partida para entender y usar el sistema de aprovisionamiento y orquestación.

---

## 📖 ¿Qué es APRO?

**APRO** (Advanced Provisioning & Orchestration) es un sistema completo para:

- ✅ Aprovisionar servidores Linux con seguridad hardened
- ✅ Automatizar configuración con Ansible
- ✅ Monitorear infraestructura (Prometheus + Grafana)
- ✅ Respaldar datos automáticamente (Borg Backup)
- ✅ Provisionar workstations especializadas

---

## 🎯 ¿Qué Puedo Hacer Hoy?

### Opción 1: Provisionar un Servidor (Rápido)

```bash
# Clonar el repositorio
git clone https://github.com/juandamianpajares/apro.git
cd apro

# Ejecutar script de provisión
sudo bash provision.sh
```

El script te guiará con un menú interactivo.

**Soporta:**
- Debian 11+
- Ubuntu 20.04 LTS+
- Rocky Linux 8/9 ⭐
- AlmaLinux 8/9 ⭐
- Arch Linux

### Opción 2: Usar Ansible (Recomendado para Producción)

```bash
# Instalar Ansible
sudo apt install ansible    # Debian/Ubuntu
sudo dnf install ansible    # Rocky/RHEL
sudo pacman -S ansible      # Arch

# Configurar inventario
cd ansible
cp inventories/production/hosts.yml.example inventories/production/hosts.yml
nano inventories/production/hosts.yml  # Editar con tus servidores

# Ejecutar playbook
ansible-playbook playbooks/site.yml
```

---

## 📚 Documentación Esencial

### Para Empezar

1. **[README.md](../README.md)** - Inicio rápido y características
2. **[QUICKSTART.md](QUICKSTART.md)** - Tutorial paso a paso
3. **Este archivo** - Guía de inicio

### Para Entender el Proyecto

1. **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Visión general completa
2. **[APRO_ARCHITECTURE.md](APRO_ARCHITECTURE.md)** - Arquitectura detallada con diagramas
3. **[ACTIVITY_DIAGRAMS.md](ACTIVITY_DIAGRAMS.md)** - Diagramas de flujo

### Para Planificar

1. **[ROADMAP.md](ROADMAP.md)** - Roadmap completo del proyecto
2. **[SESSION_SUMMARY.md](SESSION_SUMMARY.md)** - Resumen del trabajo realizado

---

## 🏗️ Estructura del Proyecto

```
apro/
├── provision.sh              # Script de bootstrap
├── ansible/                  # Automatización
│   ├── playbooks/           # Playbooks principales
│   ├── roles/               # Roles (common, hardening, etc.)
│   └── inventories/         # Inventarios de hosts
├── terraform/               # IaC para cloud (futuro)
├── docker/                  # Stacks Docker
└── docs/                    # Documentación completa
```

---

## 🎓 Casos de Uso

### 1. Soy Desarrollador - Quiero un Servidor para mi App

```bash
# Opción A: Script rápido
PROJECT_REPO_URL="git@github.com:usuario/mi-app.git" \
PROJECT_ENVIRONMENT="dev" \
sudo -E bash provision.sh

# Opción B: Ansible
# 1. Agregar tu servidor a inventories/production/hosts.yml
# 2. Ejecutar: ansible-playbook playbooks/site.yml --limit mi-servidor
```

**Resultado:**
- Servidor actualizado y hardenizado
- Docker instalado y configurado
- Tu aplicación clonada y corriendo
- Firewall y Fail2Ban activos

### 2. Soy SysAdmin - Necesito Hardening de Seguridad

```bash
ansible-playbook playbooks/site.yml --tags hardening
```

**Aplica:**
- 30+ parámetros de kernel hardening
- SSH hardened (solo claves, sin root)
- Firewall configurado
- Fail2Ban anti brute-force
- SELinux/AppArmor
- Auditd logging

### 3. Quiero Monitorear mis Servidores

```bash
# Próximamente en Sprint 3-4
ansible-playbook playbooks/monitoring.yml
```

**Instalará:**
- Prometheus (métricas)
- Grafana (visualización)
- Loki (logs)
- Dashboards predefinidos

### 4. Necesito una Workstation para DevOps

```bash
# Próximamente en Sprint 9-10
ansible-playbook playbooks/workstation-devops.yml
```

**Instalará:**
- Arch Linux + GNOME/KDE
- Docker + Kubernetes
- Terraform + Ansible
- VSCode + JetBrains
- Terminal tools completo

---

## 🔐 Seguridad por Defecto

APRO implementa seguridad desde el primer día:

✅ **CIS Benchmarks Level 1**
✅ **Kernel Hardening** - 30+ parámetros
✅ **SSH Hardening** - Solo claves, cifrado moderno
✅ **Firewall** - UFW/Firewalld
✅ **Fail2Ban** - Anti brute-force
✅ **MAC** - SELinux/AppArmor
✅ **Audit** - Logging de eventos

---

## 🆘 Necesito Ayuda

### Preguntas Frecuentes

**¿Funciona en Rocky Linux 9?**
✅ Sí! Totalmente soportado desde v3.0

**¿Puedo usar esto en producción?**
✅ Sí, con precaución. Revisa las configuraciones primero.

**¿Dónde están los backups?**
📋 En desarrollo (Sprint 5-6). Por ahora usa tu solución actual.

**¿Soporta Kubernetes?**
📋 Planeado para Sprint 15+

### Troubleshooting

Ver: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Reporte de Bugs

GitHub Issues: https://github.com/juandamianpajares/apro/issues

---

## 📊 Estado del Proyecto

| Componente | Estado |
|------------|--------|
| provision.sh | ✅ Listo |
| Ansible - Common | ✅ Listo |
| Ansible - Hardening | ✅ Listo |
| Ansible - Docker | 🔄 En Desarrollo |
| Monitoring Stack | 📋 Sprint 3-4 |
| Backup System | 📋 Sprint 5-6 |
| Terraform | 📋 Sprint 7-8 |
| Workstations | 📋 Sprint 9-14 |

---

## 🚀 Próximos Pasos

### Hoy

1. ✅ Leer este documento
2. ✅ Ejecutar `provision.sh` en una VM de prueba
3. ✅ Revisar el [README.md](../README.md)

### Esta Semana

1. Configurar Ansible con tu inventario
2. Probar playbooks en entorno de desarrollo
3. Leer la [Arquitectura](APRO_ARCHITECTURE.md)

### Este Mes

1. Implementar en staging
2. Configurar monitoreo (cuando esté listo)
3. Contribuir al proyecto 😊

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas!

1. Fork el proyecto
2. Crea una branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📞 Contacto

- **GitHub**: [@juandamianpajares](https://github.com/juandamianpajares)
- **Issues**: https://github.com/juandamianpajares/apro/issues
- **Email**: juandamianpajares@example.com

---

## 🎉 ¡Listo para Empezar!

Ya tienes todo lo necesario para comenzar. Elige tu camino:

- 🚀 **Rápido**: Ejecuta `provision.sh`
- 🎯 **Profesional**: Usa Ansible
- 📚 **Explorador**: Lee la documentación completa

**¡Buena suerte con tu infraestructura!** 🎊

---

**Versión**: 1.0.0
**Fecha**: 2025-01-15
**Proyecto**: APRO v3.0
