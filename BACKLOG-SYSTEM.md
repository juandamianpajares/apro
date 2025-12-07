# 📋 Sistema de Backlog Automático - APRO

## 🎯 ¿Qué es esto?

Un sistema completo para **nunca perderte en tus proyectos**. Cuando creas un proyecto nuevo, automáticamente:

1. ✅ **Genera un backlog completo** de tareas de infraestructura
2. ✅ **Crea issues en GitHub** organizados y etiquetados
3. ✅ **Te da un roadmap claro** de qué hacer y en qué orden
4. ✅ **Facilita retomar después** de semanas/meses

---

## 🚀 Quick Start

### Crear Nuevo Proyecto CON Backlog Automático

```bash
# 1. Usar el switcher (¡lo hace todo automático!)
switch-project
# → Opción "n" para nuevo proyecto
# → Te pregunta si quieres backlog
# → ¡Listo! Backlog generado

# 2. Crear GitHub Project e issues
create-github-project
# → Crea repo en GitHub (si no existe)
# → Crea labels organizados
# → Crea issues desde el backlog
# → ¡Listo! Project en GitHub
```

### Agregar Backlog a Proyecto Existente

```bash
cd /path/to/tu/proyecto

# Generar backlog
generate-backlog

# Crear GitHub Project
create-github-project
```

---

## 🛠️ Herramientas Incluidas

### 1. `generate-backlog`

**Qué hace**: Genera backlog de infraestructura completo basado en el tipo de proyecto

**Uso**:
```bash
generate-backlog                  # En directorio actual
generate-backlog /path/to/project # En proyecto específico
```

**Detecta automáticamente**:
- ✅ Next.js → Backlog específico con Next.js 14, TypeScript, Docker, etc.
- ✅ Laravel → Backlog con PHP, Composer, Eloquent, Queues, etc.
- ✅ Generic → Backlog genérico para cualquier tipo de proyecto

**Genera**:
- `BACKLOG.md` - Backlog completo organizado por fases (100-300 tareas)
- `TODO.md` - Lista rápida para tareas del día a día

**Ejemplo de estructura generada**:

```
## Phase 1: Foundation (Sprint 1-2)
### Infrastructure Setup
- [ ] **Docker Setup**
  - [ ] Create Dockerfile for production
  - [ ] Create docker-compose.yml
  - [ ] Add health checks

### TypeScript & Configuration
- [ ] **TypeScript Configuration**
  - [ ] Configure tsconfig.json
  - [ ] Setup ESLint
  ...

## Phase 2: Database & Backend (Sprint 3-4)
...
```

---

### 2. `create-github-project`

**Qué hace**: Crea GitHub Project, repo (si no existe), labels e issues organizados

**Requisitos**:
- GitHub CLI (`gh`) instalado
- Autenticado en GitHub

**Instalación de `gh`**:
```bash
# Debian/Ubuntu
sudo apt install gh

# Arch
sudo pacman -S github-cli

# macOS
brew install gh

# Autenticar
gh auth login
```

**Uso**:
```bash
create-github-project                  # En directorio actual
create-github-project /path/to/project # En proyecto específico
```

**Lo que hace automáticamente**:

1. ✅ **Verifica/Crea repo en GitHub**
   - Si no es repo Git → lo inicializa
   - Si no tiene remote → crea repo en GitHub
   - Te pregunta si público o privado

2. ✅ **Crea labels organizados**
   - `infrastructure` - Azul
   - `database` - Verde
   - `security` - Rojo
   - `testing` - Verde claro
   - `ci-cd` - Naranja
   - `monitoring` - Amarillo
   - `documentation` - Azul claro
   - `phase-1`, `phase-2`, etc. - Gris

3. ✅ **Crea issues desde BACKLOG.md**
   - Parsea el backlog
   - Crea issues para tareas principales
   - Asigna labels automáticamente
   - Organiza por fases

4. ✅ **Te da links directos**
   - Link a issues: `https://github.com/user/repo/issues`
   - Link a projects: `https://github.com/user/repo/projects`

---

### 3. `switch-project` (Actualizado)

**Nueva funcionalidad**: Al crear proyecto nuevo, ofrece generar backlog automáticamente

```bash
switch-project
# → n (nuevo proyecto)
# → Nombre: mi-proyecto-increible
# → ¿Generar backlog de infraestructura? (Y/n): Y
# → ¡Backlog generado automáticamente!
```

---

## 📁 Archivos Generados

### BACKLOG.md

**Estructura**:
```markdown
# Proyecto - Infrastructure Backlog

## Phase 1: Foundation
### Infrastructure Setup
- [ ] **Tarea Principal**
  - [ ] Subtarea 1
  - [ ] Subtarea 2

### Git & Version Control
- [ ] **Configuración Git**
  ...

## Phase 2: Database & Backend
...

## Phase N: Monitoring & Observability
...

## Ongoing Tasks
- [ ] Dependency updates
- [ ] Security patches
...
```

**Beneficios**:
- ✅ Roadmap claro de 8-16 fases
- ✅ Organizado por sprints
- ✅ 100-300 tareas dependiendo del tipo
- ✅ Fácil de marcar como completado
- ✅ Referencias a documentación

### TODO.md

**Estructura**:
```markdown
# TODO - Quick Tasks

## 🔥 Urgente
- [ ]

## 📝 Esta Semana
- [ ]

## 💡 Ideas
- [ ]

## 🐛 Bugs
- [ ]
```

**Beneficios**:
- ✅ Rápido para tareas del día
- ✅ Separado del backlog grande
- ✅ Fácil de actualizar

---

## 🎨 Templates Disponibles

### 1. Next.js Template (`backlog-nextjs.md`)

**Fases incluidas**:
1. Foundation - Docker, TypeScript, Git
2. Database & Backend - Prisma, API Routes
3. Security & Auth - NextAuth.js, JWT
4. Testing - Jest, Playwright
5. CI/CD - GitHub Actions
6. Monitoring - Sentry, Logs
7. Frontend Infrastructure - Components, Performance
8. Documentation

**Total**: ~200 tareas organizadas

### 2. Laravel Template (`backlog-laravel.md`)

**Fases incluidas**:
1. Foundation - Docker, Laravel Setup
2. Database - Eloquent, Migrations
3. Security & Auth - Sanctum, Policies
4. Testing - PHPUnit, Dusk
5. CI/CD - GitHub Actions, Forge
6. Monitoring - Telescope, APM
7. API & Features - Resources, Queues
8. Documentation

**Total**: ~180 tareas organizadas

### 3. Generic Template (`backlog-generic.md`)

**Fases incluidas**:
1. Foundation
2. Core Infrastructure
3. Security
4. Testing
5. CI/CD
6. Monitoring
7. Documentation

**Total**: ~100 tareas organizadas

**Usado para**: Python, Go, Rust, proyectos custom

---

## 📊 Workflow Completo

### Escenario 1: Proyecto Nuevo desde Cero

```bash
# 1. Crear proyecto
sw                             # switch-project
# → n (nuevo)
# → Nombre: super-app
# → ¿Backlog? Y

# 2. Revisar backlog
cat BACKLOG.md

# 3. Crear GitHub Project
create-github-project
# → Autenticar si es necesario
# → Crear repo (público/privado)
# → Esperar...
# → ¡Issues creados!

# 4. Ver en GitHub
# Ir a: https://github.com/tu-user/super-app/issues

# 5. Crear GitHub Project manualmente
# Ir a: https://github.com/tu-user/super-app/projects
# → New Project
# → Add issues

# 6. ¡Empezar a trabajar!
```

### Escenario 2: Proyecto Existente sin Backlog

```bash
cd /path/to/proyecto-existente

# 1. Generar backlog
generate-backlog

# 2. Revisar
cat BACKLOG.md
cat TODO.md

# 3. Crear issues (opcional)
create-github-project

# 4. ¡Listo!
```

### Escenario 3: Retomar Proyecto Después de Meses

```bash
# 1. Cambiar a proyecto
sw                             # Seleccionar proyecto

# 2. Ver dónde estabas
cat BACKLOG.md                 # Ver progreso general
cat TODO.md                    # Ver tareas pendientes
git log -5 --oneline           # Ver últimos commits

# 3. Ver issues en GitHub
# Ir al repo → Issues
# Ver qué está pendiente

# 4. ¡Seguir trabajando sin perderte!
```

---

## 🎯 Mejores Prácticas

### 1. Usa BACKLOG.md para planificación

```bash
# Marcar tareas completadas
# Antes:
- [ ] **Docker Setup**

# Después:
- [x] **Docker Setup**
```

### 2. Usa TODO.md para el día a día

```markdown
## 🔥 Urgente
- [x] Fix login bug
- [ ] Deploy hotfix

## 📝 Esta Semana
- [ ] Implementar API de usuarios
- [ ] Agregar tests
```

### 3. Revisa progreso regularmente

```bash
# Semanal
grep -c "\[x\]" BACKLOG.md     # Contar completadas
grep -c "\[ \]" BACKLOG.md     # Contar pendientes

# Calcular % completado
```

### 4. Actualiza issues en GitHub

- ✅ Cierra issues cuando completes tareas
- ✅ Agrega comentarios con progreso
- ✅ Referencia commits: `closes #123`

### 5. Personaliza templates

Los templates están en `/home/user/apro/cli/templates/`

Puedes:
- Agregar tareas específicas de tu stack
- Quitar secciones que no uses
- Crear templates custom

---

## 🔧 Troubleshooting

### "gh: command not found"

```bash
# Instalar GitHub CLI
sudo apt install gh          # Debian/Ubuntu
sudo pacman -S github-cli    # Arch
brew install gh              # macOS

# Autenticar
gh auth login
```

### "No se pudo crear el repo"

```bash
# Verificar autenticación
gh auth status

# Re-autenticar si es necesario
gh auth login
```

### "BACKLOG.md no se genera"

```bash
# Verificar que estás en un proyecto
ls package.json composer.json  # etc.

# Generar manualmente
generate-backlog

# Si falla, usar template genérico
cp /home/user/apro/cli/templates/backlog-generic.md ./BACKLOG.md
```

### "Issues no se crean correctamente"

```bash
# Verificar que BACKLOG.md existe
ls -la BACKLOG.md

# Verificar formato del backlog
head -50 BACKLOG.md

# Crear issues manualmente desde GitHub UI
```

---

## 📝 Personalización Avanzada

### Crear Template Custom

```bash
# 1. Copiar template existente
cp /home/user/apro/cli/templates/backlog-nextjs.md \
   /home/user/apro/cli/templates/backlog-mern.md

# 2. Editar
nano /home/user/apro/cli/templates/backlog-mern.md

# 3. Modificar generate-backlog para detectarlo
nano /home/user/apro/cli/generate-backlog
# Agregar lógica de detección
```

### Agregar Variables Custom

En templates puedes usar:
- `{{PROJECT_NAME}}` - Nombre del proyecto
- `{{DATE}}` - Fecha de generación
- `{{PROJECT_TYPE}}` - Tipo detectado
- `{{NEXT_VERSION}}` - Versión de Next.js (si aplica)
- `{{LARAVEL_VERSION}}` - Versión de Laravel (si aplica)

---

## ✅ Checklist de Setup

Antes de usar el sistema, verifica:

- [ ] GitHub CLI instalado (`gh --version`)
- [ ] Autenticado en GitHub (`gh auth status`)
- [ ] PATH configurado con `/home/user/apro/cli`
- [ ] Templates existen en `/home/user/apro/cli/templates/`
- [ ] Scripts son ejecutables (`chmod +x`)

---

## 🎉 Beneficios para Creativos Dispersos

### Antes (Sin Sistema)
- ❌ "¿Qué proyecto estaba haciendo?"
- ❌ "¿Por dónde iba?"
- ❌ "¿Qué falta hacer?"
- ❌ Perder días recordando contexto
- ❌ Proyectos a medias olvidados

### Ahora (Con Sistema)
- ✅ `switch-project` → Ver todos los proyectos
- ✅ `cat BACKLOG.md` → Ver roadmap completo
- ✅ `cat TODO.md` → Ver tareas inmediatas
- ✅ GitHub Issues → Ver progreso visual
- ✅ Retomar en 5 minutos, no días

---

## 📚 Más Recursos

- **Documentación completa**: `/home/user/apro/DALINTEX-STOCK-SETUP-COMPLETE.md`
- **Templates**: `/home/user/apro/cli/templates/`
- **Scripts**: `/home/user/apro/cli/`

---

**Version**: 1.0.0
**Creado**: 2024-12-07
**Autor**: Sistema APRO para creativos dispersos ❤️
