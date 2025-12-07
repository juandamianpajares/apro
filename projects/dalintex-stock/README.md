# DALINTEX Stock Management System

Sistema completo de gestión de stock e inventario construido con Next.js 14, TypeScript, MySQL y Docker.

## 🚀 Quick Start

### Requisitos Previos

- **Sistema Operativo**: Debian 12+ / Ubuntu 20.04+ / Linux compatible
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Node.js**: 18+ (solo si vas a desarrollar sin Docker)
- **Espacio en disco**: Mínimo 10GB disponibles
- **Memoria RAM**: Mínimo 2GB

### Instalación Rápida

```bash
# 1. Clonar el repositorio
git clone git@github.com:juandamianpajares/dalintex-stock.git
cd dalintex-stock

# 2. Copiar variables de entorno
cp .env.example .env

# 3. (Opcional) Editar .env con tus configuraciones
nano .env

# 4. Iniciar con Docker (desarrollo)
docker compose -f docker-compose.dev.yml up -d

# 5. Esperar a que los servicios inicien (30-60 segundos)
docker compose -f docker-compose.dev.yml logs -f app

# 6. Acceder a la aplicación
# http://localhost:3000
```

## 📦 ¿Qué incluye?

### Servicios Docker

- **Next.js 14** (Puerto 3000): Aplicación frontend y API
- **MySQL 8.0** (Puerto 3306): Base de datos
- **phpMyAdmin** (Puerto 8080): Administración de BD (solo dev)
- **Redis** (Puerto 6379): Cache y sessions (opcional)
- **Mailhog** (Puerto 8025): Captura de emails en desarrollo

### Features Principales

- ✅ Gestión de productos con SKU y categorías
- ✅ Control de stock con movimientos (entrada/salida/ajustes)
- ✅ Gestión de proveedores y clientes
- ✅ Sistema de pedidos/órdenes
- ✅ Reportes y dashboard con métricas
- ✅ Exportación a PDF y Excel
- ✅ Alertas de stock bajo
- ✅ Autenticación y roles de usuario

## 🛠️ Comandos Útiles

### Desarrollo

```bash
# Iniciar servicios en modo desarrollo
docker compose -f docker-compose.dev.yml up -d

# Ver logs en tiempo real
docker compose -f docker-compose.dev.yml logs -f

# Ver logs de un servicio específico
docker compose -f docker-compose.dev.yml logs -f app

# Detener servicios
docker compose -f docker-compose.dev.yml down

# Reiniciar un servicio
docker compose -f docker-compose.dev.yml restart app

# Acceder a shell del contenedor de la app
docker compose -f docker-compose.dev.yml exec app sh

# Acceder a MySQL CLI
docker compose -f docker-compose.dev.yml exec db mysql -u dalintex_dev -pDevPass123 dalintex_stock_dev
```

### Producción

```bash
# Build para producción
docker compose -f docker-compose.yml build

# Iniciar en producción
docker compose -f docker-compose.yml up -d

# Ver estado de servicios
docker compose -f docker-compose.yml ps

# Ver uso de recursos
docker stats
```

### Base de Datos

```bash
# Crear backup de la base de datos
docker compose -f docker-compose.dev.yml exec db mysqldump -u root -pDevPass123 dalintex_stock_dev > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker compose -f docker-compose.dev.yml exec -T db mysql -u root -pDevPass123 dalintex_stock_dev < backup_20240101.sql

# Ejecutar script SQL
docker compose -f docker-compose.dev.yml exec -T db mysql -u dalintex_dev -pDevPass123 dalintex_stock_dev < mi_script.sql
```

### Tests

```bash
# Ejecutar tests dentro del contenedor
docker compose -f docker-compose.dev.yml exec app npm test

# Ejecutar tests con cobertura
docker compose -f docker-compose.dev.yml exec app npm run test:coverage

# Ejecutar tests en modo watch
docker compose -f docker-compose.dev.yml exec app npm run test:watch
```

## 📁 Estructura del Proyecto

```
dalintex-stock/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── api/               # API Routes
│   │   │   └── health/        # Health check endpoint
│   │   ├── (dashboard)/       # Dashboard routes
│   │   └── page.tsx           # Homepage
│   ├── components/            # React components
│   │   └── ui/                # UI components (shadcn/ui)
│   ├── lib/                   # Utilities y helpers
│   │   ├── hooks/             # Custom React hooks
│   │   │   └── use-api.ts    # Hook para llamadas API
│   │   └── utils.ts           # Funciones de utilidad
│   └── types/                 # TypeScript types
├── docker/
│   ├── mysql/
│   │   ├── init/              # Scripts de inicialización
│   │   │   ├── 01-init-db.sql # Creación de tablas
│   │   │   └── 02-seed-data.sql # Datos de ejemplo
│   │   └── conf.d/            # Configuración MySQL
│   └── scripts/               # Scripts auxiliares
├── public/                    # Assets estáticos
├── docker-compose.yml         # Docker Compose producción
├── docker-compose.dev.yml     # Docker Compose desarrollo
├── Dockerfile                 # Dockerfile producción
├── Dockerfile.dev             # Dockerfile desarrollo
├── next.config.js             # Configuración Next.js
├── tsconfig.json              # Configuración TypeScript
├── .env.example               # Variables de entorno ejemplo
└── package.json               # Dependencias npm
```

## 🔧 Configuración

### Variables de Entorno

Las variables principales están en `.env`:

```env
# Base de Datos
DATABASE_URL=mysql://dalintex_dev:DevPass123@db:3306/dalintex_stock_dev
MYSQL_ROOT_PASSWORD=DevPass123
MYSQL_DATABASE=dalintex_stock_dev
MYSQL_USER=dalintex_dev
MYSQL_PASSWORD=DevPass123

# Aplicación
NODE_ENV=development
APP_PORT=3000
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Seguridad (cambiar en producción)
JWT_SECRET=dev-secret-key-change-in-production
```

Ver `.env.example` para todas las opciones disponibles.

### Puertos

| Servicio | Puerto | URL |
|----------|--------|-----|
| Next.js App | 3000 | http://localhost:3000 |
| MySQL | 3306 | localhost:3306 |
| phpMyAdmin | 8080 | http://localhost:8080 |
| Redis | 6379 | localhost:6379 |
| Mailhog UI | 8025 | http://localhost:8025 |

## 🧪 Testing

### Tests Automatizados

El proyecto incluye dos suites de tests:

#### 1. Tests de Provisioning (Debian 12)

Valida que el sistema está correctamente configurado:

```bash
# Ejecutar desde el directorio raíz del proyecto apro
bash tests/provisioning/test-docker-debian12.sh
```

Valida:
- ✅ Versión correcta de Debian
- ✅ Docker instalado y corriendo
- ✅ Puertos disponibles
- ✅ Conectividad de red
- ✅ Espacio en disco suficiente

#### 2. Tests de Integración

Valida que todos los servicios funcionan correctamente:

```bash
# Primero iniciar los servicios
docker compose -f docker-compose.dev.yml up -d

# Esperar 30-60 segundos y ejecutar tests
cd /path/to/dalintex-stock
PROJECT_DIR=$(pwd) bash /path/to/apro/tests/integration/test-dalintex-stock.sh
```

Valida:
- ✅ Todos los servicios corriendo
- ✅ Conectividad entre servicios
- ✅ Base de datos accesible
- ✅ API responde correctamente
- ✅ Persistencia de datos

## 🔍 Troubleshooting

### Error: "Module not found: Can't resolve '@/lib/utils'"

**Solución**: Asegúrate de copiar todos los archivos del proyecto, especialmente:
- `tsconfig.json` (con paths configurados)
- `src/lib/utils.ts`
- `src/lib/hooks/use-api.ts`

```bash
# Verificar que existen
ls -la tsconfig.json
ls -la src/lib/utils.ts
ls -la src/lib/hooks/use-api.ts
```

### Error: "Port 3000 already in use"

**Solución**: Cambiar el puerto en `.env` o detener el servicio que lo usa:

```bash
# Opción 1: Cambiar puerto
echo "APP_PORT=3001" >> .env

# Opción 2: Encontrar y detener proceso
sudo lsof -i :3000
sudo kill -9 <PID>
```

### Error: "Cannot connect to MySQL"

**Solución**: Esperar a que MySQL termine de iniciar:

```bash
# Ver logs de MySQL
docker compose -f docker-compose.dev.yml logs -f db

# Esperar a ver: "ready for connections"
# Luego reiniciar la app
docker compose -f docker-compose.dev.yml restart app
```

### Error: "Out of memory"

**Solución**: Aumentar memoria disponible para Docker:

```bash
# En Docker Desktop: Settings > Resources > Memory (mínimo 2GB)

# En Linux, verificar:
free -h

# Si es necesario, limpiar imágenes y contenedores viejos:
docker system prune -a --volumes
```

### Build muy lento en Docker

**Solución**: Usar caché de build y optimizar:

```bash
# Build con cache
docker compose -f docker-compose.dev.yml build

# Si sigue lento, limpiar y rebuild
docker compose -f docker-compose.dev.yml down -v
docker system prune -af
docker compose -f docker-compose.dev.yml build --no-cache
```

## 📚 Documentación Adicional

- [Arquitectura del Sistema](docs/ARCHITECTURE.md)
- [Guía de Deployment](docs/DEPLOYMENT.md)
- [API Documentation](docs/API.md)
- [Guía de Contribución](CONTRIBUTING.md)

## 🔐 Seguridad

### En Desarrollo

Las credenciales por defecto son:

- **MySQL Root**: `DevPass123`
- **MySQL User**: `dalintex_dev` / `DevPass123`
- **JWT Secret**: `dev-secret-key-change-in-production`

### En Producción

**IMPORTANTE**: Cambiar TODAS las credenciales antes de deployar:

```bash
# Generar contraseñas seguras
openssl rand -base64 32

# Actualizar .env con:
MYSQL_ROOT_PASSWORD=<contraseña-segura>
MYSQL_PASSWORD=<contraseña-segura>
JWT_SECRET=<secret-seguro>
NEXTAUTH_SECRET=<secret-seguro>
```

## 🤝 Contribuir

Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una branch (`git checkout -b feature/nueva-feature`)
3. Commit cambios (`git commit -m 'Agregar nueva feature'`)
4. Push a la branch (`git push origin feature/nueva-feature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es privado y propiedad de DALINTEX.

## 👨‍💻 Autor

**Juan Damian Pajares**
- GitHub: [@juandamianpajares](https://github.com/juandamianpajares)

---

**Version**: 1.0.0
**Last Updated**: 2024-12-07
