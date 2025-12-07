# Guía de Deployment - DALINTEX Stock en Debian 12

Guía paso a paso para deployar DALINTEX Stock Management System en Debian 12 (Bookworm).

## 📋 Pre-requisitos

### Sistema Base

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar herramientas básicas
sudo apt install -y \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https
```

## 🐳 Instalación de Docker en Debian 12

### Método Oficial (Recomendado)

```bash
# 1. Remover versiones antiguas
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# 2. Agregar repositorio de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Verificar instalación
docker --version
docker compose version

# 5. Agregar usuario actual al grupo docker
sudo usermod -aG docker $USER

# 6. Aplicar cambios (requerirás hacer logout/login o reiniciar)
newgrp docker

# 7. Probar Docker
docker run hello-world
```

### Habilitar Docker en arranque

```bash
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
```

## 🔧 Configuración del Sistema

### 1. Firewall (UFW)

```bash
# Instalar UFW si no está
sudo apt install -y ufw

# Configurar reglas
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Permitir SSH (IMPORTANTE: antes de habilitar!)
sudo ufw allow 22/tcp

# Permitir puertos de la aplicación
sudo ufw allow 3000/tcp comment 'DALINTEX App'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Habilitar firewall
sudo ufw enable

# Verificar estado
sudo ufw status verbose
```

### 2. Configurar límites del sistema

```bash
# Aumentar límites para Docker
sudo tee /etc/security/limits.d/99-docker.conf > /dev/null <<EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF

# Aplicar sysctl para Docker
sudo tee /etc/sysctl.d/99-docker.conf > /dev/null <<EOF
vm.max_map_count=262144
fs.file-max=2097152
EOF

sudo sysctl -p /etc/sysctl.d/99-docker.conf
```

## 📦 Deployment de DALINTEX Stock

### 1. Clonar el Repositorio

```bash
# Crear directorio para la aplicación
sudo mkdir -p /opt/dalintex-stock
sudo chown $USER:$USER /opt/dalintex-stock

# Clonar proyecto
cd /opt/dalintex-stock
git clone git@github.com:juandamianpajares/dalintex-stock.git .

# O si usas HTTPS
git clone https://github.com/juandamianpajares/dalintex-stock.git .
```

### 2. Configurar Variables de Entorno

```bash
# Copiar ejemplo
cp .env.example .env

# Editar configuración
nano .env

# IMPORTANTE: Cambiar las siguientes variables en producción:
# - MYSQL_ROOT_PASSWORD (generar con: openssl rand -base64 32)
# - MYSQL_PASSWORD (generar con: openssl rand -base64 32)
# - JWT_SECRET (generar con: openssl rand -base64 32)
# - NEXTAUTH_SECRET (generar con: openssl rand -base64 32)
```

Configuración mínima para producción:

```env
# Base de Datos
MYSQL_ROOT_PASSWORD=<CAMBIAR_CONTRASEÑA_SEGURA>
MYSQL_DATABASE=dalintex_stock_prod
MYSQL_USER=dalintex_prod
MYSQL_PASSWORD=<CAMBIAR_CONTRASEÑA_SEGURA>
MYSQL_PORT=3306

# Aplicación
NODE_ENV=production
APP_PORT=3000
NEXT_PUBLIC_APP_URL=https://tu-dominio.com
NEXT_PUBLIC_API_URL=https://tu-dominio.com/api

# Seguridad
JWT_SECRET=<GENERAR_CON_OPENSSL>
NEXTAUTH_SECRET=<GENERAR_CON_OPENSSL>
NEXTAUTH_URL=https://tu-dominio.com
```

### 3. Build y Start

```bash
# Build de las imágenes
docker compose -f docker-compose.yml build

# Iniciar servicios
docker compose -f docker-compose.yml up -d

# Verificar que estén corriendo
docker compose -f docker-compose.yml ps

# Ver logs
docker compose -f docker-compose.yml logs -f
```

### 4. Verificar Deployment

```bash
# Esperar 30-60 segundos para que inicien los servicios

# Verificar health endpoint
curl http://localhost:3000/api/health

# Deberías ver algo como:
# {"status":"ok","timestamp":"2024-12-07T...", ...}
```

## 🔒 Seguridad Post-Deployment

### 1. Configurar SSL con Nginx y Let's Encrypt

```bash
# Instalar Nginx
sudo apt install -y nginx certbot python3-certbot-nginx

# Configurar Nginx como reverse proxy
sudo tee /etc/nginx/sites-available/dalintex <<EOF
server {
    listen 80;
    server_name tu-dominio.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/dalintex /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Obtener certificado SSL
sudo certbot --nginx -d tu-dominio.com

# Renovación automática
sudo systemctl enable certbot.timer
```

### 2. Configurar Backups Automáticos

```bash
# Crear script de backup
sudo tee /opt/dalintex-stock/backup.sh > /dev/null <<'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/dalintex"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup de base de datos
docker compose -f /opt/dalintex-stock/docker-compose.yml exec -T db \
    mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" dalintex_stock_prod \
    > "$BACKUP_DIR/db_backup_$DATE.sql"

# Comprimir
gzip "$BACKUP_DIR/db_backup_$DATE.sql"

# Mantener solo últimos 7 backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "Backup completado: db_backup_$DATE.sql.gz"
EOF

chmod +x /opt/dalintex-stock/backup.sh

# Agregar a crontab (backup diario a las 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/dalintex-stock/backup.sh >> /var/log/dalintex-backup.log 2>&1") | crontab -
```

### 3. Fail2Ban para protección SSH

```bash
# Instalar Fail2Ban
sudo apt install -y fail2ban

# Configurar
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo fail2ban-client status
```

## 📊 Monitoreo

### Ver Estado de Servicios

```bash
# Estado de contenedores
docker compose -f docker-compose.yml ps

# Logs en tiempo real
docker compose -f docker-compose.yml logs -f

# Uso de recursos
docker stats

# Espacio en disco
df -h
```

### Configurar Logs Persistentes

```bash
# Configurar log rotation para Docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker
```

## 🔄 Actualización del Sistema

### Update de la Aplicación

```bash
cd /opt/dalintex-stock

# Backup antes de actualizar
docker compose -f docker-compose.yml exec -T db \
    mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" dalintex_stock_prod \
    > backup_pre_update_$(date +%Y%m%d).sql

# Pull cambios
git pull origin main

# Rebuild y restart
docker compose -f docker-compose.yml build
docker compose -f docker-compose.yml up -d

# Verificar
docker compose -f docker-compose.yml ps
docker compose -f docker-compose.yml logs -f
```

### Update de Docker

```bash
sudo apt update
sudo apt upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 🆘 Troubleshooting

### Servicios no inician

```bash
# Ver logs detallados
docker compose -f docker-compose.yml logs

# Verificar puertos
sudo netstat -tlnp | grep -E ':(3000|3306|8080)'

# Verificar recursos
free -h
df -h
```

### Error de permisos

```bash
# Verificar ownership
sudo chown -R $USER:$USER /opt/dalintex-stock

# Verificar permisos de Docker
docker ps
# Si falla: sudo usermod -aG docker $USER
# Luego: logout y login
```

### MySQL no conecta

```bash
# Ver logs de MySQL
docker compose -f docker-compose.yml logs db

# Verificar que esté healthy
docker compose -f docker-compose.yml ps db

# Probar conexión manual
docker compose -f docker-compose.yml exec db mysql -u root -p
```

## 📞 Soporte

Para problemas o preguntas:

1. Revisar logs: `docker compose logs`
2. Ejecutar tests: `bash /path/to/apro/tests/integration/test-dalintex-stock.sh`
3. Contactar al equipo de desarrollo

---

**Nota**: Esta guía asume un servidor Debian 12 limpio. Para servidores existentes, adaptar según sea necesario.
