#!/bin/bash

#===============================================================================
# Test Suite - Docker Provisioning en Debian 12
# Valida instalación de Docker, configuraciones y conectividad
#===============================================================================

set -euo pipefail

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

#===============================================================================
# Funciones de test
#===============================================================================

test_start() {
    ((TESTS_TOTAL++))
    echo -n -e "${BLUE}[TEST $TESTS_TOTAL]${NC} $1... "
}

test_pass() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}✓ PASS${NC}"
}

test_fail() {
    ((TESTS_FAILED++))
    echo -e "${RED}✗ FAIL${NC}"
    [ -n "${1:-}" ] && echo -e "${RED}  Razón: $1${NC}"
}

#===============================================================================
# Tests de Sistema Operativo
#===============================================================================

test_os_debian() {
    test_start "Verificar que es Debian"
    if [ -f /etc/debian_version ]; then
        test_pass
    else
        test_fail "No es Debian"
    fi
}

test_os_version() {
    test_start "Verificar versión de Debian >= 12"
    if [ -f /etc/debian_version ]; then
        local version=$(cat /etc/debian_version | cut -d'.' -f1)
        if [ "$version" -ge 12 ]; then
            test_pass
        else
            test_fail "Versión de Debian: $version (requerida >= 12)"
        fi
    else
        test_fail "No se pudo determinar versión"
    fi
}

#===============================================================================
# Tests de Docker
#===============================================================================

test_docker_installed() {
    test_start "Verificar instalación de Docker"
    if command -v docker &> /dev/null; then
        test_pass
    else
        test_fail "Docker no está instalado"
    fi
}

test_docker_version() {
    test_start "Verificar versión de Docker >= 20.10"
    if command -v docker &> /dev/null; then
        local version=$(docker version --format '{{.Server.Version}}' 2>/dev/null | cut -d'.' -f1,2)
        if (( $(echo "$version >= 20.10" | bc -l) )); then
            test_pass
        else
            test_fail "Versión de Docker: $version (requerida >= 20.10)"
        fi
    else
        test_fail "Docker no disponible"
    fi
}

test_docker_running() {
    test_start "Verificar que Docker daemon está corriendo"
    if docker info &> /dev/null; then
        test_pass
    else
        test_fail "Docker daemon no está corriendo"
    fi
}

test_docker_compose() {
    test_start "Verificar Docker Compose instalado"
    if docker compose version &> /dev/null; then
        test_pass
    elif command -v docker-compose &> /dev/null; then
        test_pass
    else
        test_fail "Docker Compose no está instalado"
    fi
}

test_docker_permissions() {
    test_start "Verificar permisos de Docker para usuario actual"
    if docker ps &> /dev/null; then
        test_pass
    else
        test_fail "Usuario no tiene permisos para ejecutar Docker"
    fi
}

#===============================================================================
# Tests de Networking
#===============================================================================

test_docker_network() {
    test_start "Verificar que Docker puede crear redes"
    local test_network="test_network_$$"
    if docker network create "$test_network" &> /dev/null; then
        docker network rm "$test_network" &> /dev/null
        test_pass
    else
        test_fail "No se puede crear red Docker"
    fi
}

test_docker_bridge() {
    test_start "Verificar red bridge de Docker"
    if docker network ls | grep -q bridge; then
        test_pass
    else
        test_fail "Red bridge no disponible"
    fi
}

test_internet_connectivity() {
    test_start "Verificar conectividad a internet"
    if curl -s --max-time 5 https://www.google.com > /dev/null; then
        test_pass
    else
        test_fail "Sin conectividad a internet"
    fi
}

test_docker_hub_connectivity() {
    test_start "Verificar conectividad a Docker Hub"
    if curl -s --max-time 5 https://hub.docker.com > /dev/null; then
        test_pass
    else
        test_fail "No se puede conectar a Docker Hub"
    fi
}

#===============================================================================
# Tests de Puertos
#===============================================================================

test_port_3000() {
    test_start "Verificar puerto 3000 disponible"
    if ! netstat -tuln 2>/dev/null | grep -q ":3000 " && ! ss -tuln 2>/dev/null | grep -q ":3000 "; then
        test_pass
    else
        test_fail "Puerto 3000 ya está en uso"
    fi
}

test_port_3306() {
    test_start "Verificar puerto 3306 disponible"
    if ! netstat -tuln 2>/dev/null | grep -q ":3306 " && ! ss -tuln 2>/dev/null | grep -q ":3306 "; then
        test_pass
    else
        test_fail "Puerto 3306 ya está en uso"
    fi
}

test_port_8080() {
    test_start "Verificar puerto 8080 disponible"
    if ! netstat -tuln 2>/dev/null | grep -q ":8080 " && ! ss -tuln 2>/dev/null | grep -q ":8080 "; then
        test_pass
    else
        test_fail "Puerto 8080 ya está en uso"
    fi
}

#===============================================================================
# Tests de Volúmenes
#===============================================================================

test_docker_volumes() {
    test_start "Verificar que Docker puede crear volúmenes"
    local test_volume="test_volume_$$"
    if docker volume create "$test_volume" &> /dev/null; then
        docker volume rm "$test_volume" &> /dev/null
        test_pass
    else
        test_fail "No se puede crear volumen Docker"
    fi
}

test_volume_permissions() {
    test_start "Verificar permisos de volúmenes"
    local test_volume="test_volume_$$"
    docker volume create "$test_volume" &> /dev/null
    if docker run --rm -v "$test_volume":/data alpine sh -c "echo test > /data/test.txt" &> /dev/null; then
        docker volume rm "$test_volume" &> /dev/null
        test_pass
    else
        docker volume rm "$test_volume" &> /dev/null 2>&1 || true
        test_fail "No se puede escribir en volúmenes"
    fi
}

#===============================================================================
# Tests de Imágenes
#===============================================================================

test_pull_alpine() {
    test_start "Verificar que se pueden descargar imágenes (alpine)"
    if docker pull alpine:latest &> /dev/null; then
        test_pass
    else
        test_fail "No se puede descargar imagen alpine"
    fi
}

test_run_container() {
    test_start "Verificar que se pueden ejecutar contenedores"
    if docker run --rm alpine:latest echo "test" &> /dev/null; then
        test_pass
    else
        test_fail "No se puede ejecutar contenedor"
    fi
}

#===============================================================================
# Tests de Paquetes del Sistema
#===============================================================================

test_curl_installed() {
    test_start "Verificar instalación de curl"
    if command -v curl &> /dev/null; then
        test_pass
    else
        test_fail "curl no está instalado"
    fi
}

test_git_installed() {
    test_start "Verificar instalación de git"
    if command -v git &> /dev/null; then
        test_pass
    else
        test_fail "git no está instalado (recomendado)"
    fi
}

test_node_installed() {
    test_start "Verificar instalación de Node.js (opcional)"
    if command -v node &> /dev/null; then
        local version=$(node --version | sed 's/v//' | cut -d'.' -f1)
        if [ "$version" -ge 18 ]; then
            test_pass
        else
            test_fail "Node.js versión $version (requerida >= 18)"
        fi
    else
        echo -e "${YELLOW}⚠ SKIP${NC} (Node.js no requerido en host si se usa Docker)"
    fi
}

#===============================================================================
# Tests de Espacio en Disco
#===============================================================================

test_disk_space() {
    test_start "Verificar espacio en disco (>= 10GB disponibles)"
    local available=$(df / | tail -1 | awk '{print $4}')
    local available_gb=$((available / 1024 / 1024))
    if [ "$available_gb" -ge 10 ]; then
        test_pass
    else
        test_fail "Solo ${available_gb}GB disponibles (recomendado >= 10GB)"
    fi
}

#===============================================================================
# Tests de Memoria
#===============================================================================

test_memory() {
    test_start "Verificar memoria RAM (>= 2GB)"
    local total_mem=$(free -g | grep Mem | awk '{print $2}')
    if [ "$total_mem" -ge 2 ]; then
        test_pass
    else
        test_fail "Solo ${total_mem}GB de RAM (recomendado >= 2GB)"
    fi
}

#===============================================================================
# Main
#===============================================================================

main() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Test Suite - Docker Provisioning en Debian 12${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Tests de Sistema Operativo
    echo -e "${YELLOW}→ Tests de Sistema Operativo${NC}"
    test_os_debian
    test_os_version
    echo ""

    # Tests de Docker
    echo -e "${YELLOW}→ Tests de Docker${NC}"
    test_docker_installed
    test_docker_version
    test_docker_running
    test_docker_compose
    test_docker_permissions
    echo ""

    # Tests de Networking
    echo -e "${YELLOW}→ Tests de Networking${NC}"
    test_docker_network
    test_docker_bridge
    test_internet_connectivity
    test_docker_hub_connectivity
    echo ""

    # Tests de Puertos
    echo -e "${YELLOW}→ Tests de Puertos${NC}"
    test_port_3000
    test_port_3306
    test_port_8080
    echo ""

    # Tests de Volúmenes
    echo -e "${YELLOW}→ Tests de Volúmenes${NC}"
    test_docker_volumes
    test_volume_permissions
    echo ""

    # Tests de Imágenes
    echo -e "${YELLOW}→ Tests de Imágenes${NC}"
    test_pull_alpine
    test_run_container
    echo ""

    # Tests de Paquetes
    echo -e "${YELLOW}→ Tests de Paquetes del Sistema${NC}"
    test_curl_installed
    test_git_installed
    test_node_installed
    echo ""

    # Tests de Recursos
    echo -e "${YELLOW}→ Tests de Recursos del Sistema${NC}"
    test_disk_space
    test_memory
    echo ""

    # Resumen
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Resumen de Tests${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Total:  ${BLUE}$TESTS_TOTAL${NC}"
    echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓✓✓ Todos los tests pasaron exitosamente!${NC}"
        echo ""
        exit 0
    else
        echo -e "${RED}✗✗✗ Algunos tests fallaron. Revisa los errores arriba.${NC}"
        echo ""
        exit 1
    fi
}

# Ejecutar
main "$@"
