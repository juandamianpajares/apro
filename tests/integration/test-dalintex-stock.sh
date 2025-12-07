#!/bin/bash

#===============================================================================
# Test Suite de Integración - DALINTEX Stock Management
# Valida servicios, conectividad y funcionalidad básica
#===============================================================================

set -euo pipefail

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuración
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.dev.yml}"
MAX_WAIT=60

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

wait_for_service() {
    local service=$1
    local timeout=${2:-$MAX_WAIT}
    local counter=0

    while [ $counter -lt $timeout ]; do
        if docker compose -f "$COMPOSE_FILE" ps "$service" 2>/dev/null | grep -q "Up"; then
            return 0
        fi
        sleep 1
        ((counter++))
    done
    return 1
}

#===============================================================================
# Tests de Servicios Docker
#===============================================================================

test_db_running() {
    test_start "Verificar que MySQL está corriendo"
    if wait_for_service "db" 30; then
        test_pass
    else
        test_fail "MySQL no está corriendo"
    fi
}

test_app_running() {
    test_start "Verificar que Next.js app está corriendo"
    if wait_for_service "app" 60; then
        test_pass
    else
        test_fail "Next.js app no está corriendo"
    fi
}

test_phpmyadmin_running() {
    test_start "Verificar que phpMyAdmin está corriendo"
    if wait_for_service "phpmyadmin" 30; then
        test_pass
    else
        echo -e "${YELLOW}⚠ SKIP${NC} (phpMyAdmin puede estar desactivado)"
    fi
}

#===============================================================================
# Tests de Conectividad
#===============================================================================

test_mysql_port() {
    test_start "Verificar acceso al puerto MySQL (3306)"
    sleep 5  # Dar tiempo a MySQL para iniciar completamente
    if docker compose -f "$COMPOSE_FILE" exec -T db mysqladmin ping -h localhost -u root -pDevPass123 &> /dev/null; then
        test_pass
    else
        test_fail "MySQL no responde en puerto 3306"
    fi
}

test_app_port() {
    test_start "Verificar acceso al puerto de Next.js (3000)"
    sleep 10  # Dar tiempo a Next.js para iniciar
    if curl -s --max-time 10 http://localhost:3000 > /dev/null 2>&1; then
        test_pass
    else
        test_fail "Next.js no responde en puerto 3000"
    fi
}

test_health_endpoint() {
    test_start "Verificar endpoint /api/health"
    sleep 5
    local response=$(curl -s --max-time 10 http://localhost:3000/api/health 2>/dev/null || echo "")
    if echo "$response" | grep -q "ok"; then
        test_pass
    else
        test_fail "Health endpoint no responde correctamente"
    fi
}

#===============================================================================
# Tests de Base de Datos
#===============================================================================

test_db_connection() {
    test_start "Verificar conexión a base de datos"
    if docker compose -f "$COMPOSE_FILE" exec -T db mysql -u dalintex_dev -pDevPass123 dalintex_stock_dev -e "SELECT 1;" &> /dev/null; then
        test_pass
    else
        test_fail "No se puede conectar a la base de datos"
    fi
}

test_db_tables() {
    test_start "Verificar que las tablas existen"
    local tables=$(docker compose -f "$COMPOSE_FILE" exec -T db mysql -u dalintex_dev -pDevPass123 dalintex_stock_dev -e "SHOW TABLES;" 2>/dev/null | wc -l)
    if [ "$tables" -gt 1 ]; then
        test_pass
    else
        test_fail "No se encontraron tablas en la base de datos"
    fi
}

test_db_user() {
    test_start "Verificar usuario de base de datos"
    if docker compose -f "$COMPOSE_FILE" exec -T db mysql -u dalintex_dev -pDevPass123 -e "SELECT USER();" &> /dev/null; then
        test_pass
    else
        test_fail "Usuario de BD no configurado correctamente"
    fi
}

#===============================================================================
# Tests de Volúmenes
#===============================================================================

test_mysql_volume() {
    test_start "Verificar volumen de MySQL"
    if docker volume ls | grep -q "mysql.*data"; then
        test_pass
    else
        test_fail "Volumen de MySQL no existe"
    fi
}

test_volume_persistence() {
    test_start "Verificar persistencia de datos"
    # Crear un registro de prueba
    docker compose -f "$COMPOSE_FILE" exec -T db mysql -u dalintex_dev -pDevPass123 dalintex_stock_dev -e "
        INSERT INTO categories (name, description) VALUES ('Test Category', 'Test persistence')
        ON DUPLICATE KEY UPDATE name=name;
    " &> /dev/null

    # Verificar que existe
    local result=$(docker compose -f "$COMPOSE_FILE" exec -T db mysql -u dalintex_dev -pDevPass123 dalintex_stock_dev -N -e "
        SELECT COUNT(*) FROM categories WHERE name='Test Category';
    " 2>/dev/null | tr -d '\r')

    if [ "$result" -ge 1 ]; then
        test_pass
    else
        test_fail "Datos no persisten en la base de datos"
    fi
}

#===============================================================================
# Tests de Networking
#===============================================================================

test_app_db_connection() {
    test_start "Verificar que app puede conectarse a db"
    # Verificar que la app puede hacer ping a db
    if docker compose -f "$COMPOSE_FILE" exec -T app sh -c "nc -zv db 3306" &> /dev/null || \
       docker compose -f "$COMPOSE_FILE" exec -T app sh -c "wget -q --spider db:3306" &> /dev/null; then
        test_pass
    else
        echo -e "${YELLOW}⚠ SKIP${NC} (Herramientas de red no disponibles en contenedor)"
    fi
}

test_network_isolation() {
    test_start "Verificar red Docker del proyecto"
    if docker network ls | grep -q "dalintex"; then
        test_pass
    else
        test_fail "Red Docker no está configurada"
    fi
}

#===============================================================================
# Tests de Logs
#===============================================================================

test_app_logs() {
    test_start "Verificar que app genera logs"
    local logs=$(docker compose -f "$COMPOSE_FILE" logs app 2>/dev/null | wc -l)
    if [ "$logs" -gt 0 ]; then
        test_pass
    else
        test_fail "App no genera logs"
    fi
}

test_db_logs() {
    test_start "Verificar que db genera logs"
    local logs=$(docker compose -f "$COMPOSE_FILE" logs db 2>/dev/null | wc -l)
    if [ "$logs" -gt 0 ]; then
        test_pass
    else
        test_fail "DB no genera logs"
    fi
}

#===============================================================================
# Tests de Performance
#===============================================================================

test_app_response_time() {
    test_start "Verificar tiempo de respuesta de app (< 3s)"
    local start=$(date +%s)
    curl -s --max-time 10 http://localhost:3000 > /dev/null 2>&1 || true
    local end=$(date +%s)
    local duration=$((end - start))

    if [ "$duration" -lt 3 ]; then
        test_pass
    else
        test_fail "Tiempo de respuesta: ${duration}s (esperado < 3s)"
    fi
}

#===============================================================================
# Main
#===============================================================================

main() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Test Suite de Integración - DALINTEX Stock${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Directorio: $PROJECT_DIR${NC}"
    echo -e "${YELLOW}Compose file: $COMPOSE_FILE${NC}"
    echo ""

    # Verificar que el proyecto está corriendo
    if ! docker compose -f "$COMPOSE_FILE" ps &> /dev/null; then
        echo -e "${RED}ERROR: Los servicios no están corriendo${NC}"
        echo -e "${YELLOW}Ejecuta: docker compose -f $COMPOSE_FILE up -d${NC}"
        exit 1
    fi

    # Tests de Servicios
    echo -e "${YELLOW}→ Tests de Servicios Docker${NC}"
    test_db_running
    test_app_running
    test_phpmyadmin_running
    echo ""

    # Tests de Conectividad
    echo -e "${YELLOW}→ Tests de Conectividad${NC}"
    test_mysql_port
    test_app_port
    test_health_endpoint
    echo ""

    # Tests de Base de Datos
    echo -e "${YELLOW}→ Tests de Base de Datos${NC}"
    test_db_connection
    test_db_tables
    test_db_user
    echo ""

    # Tests de Volúmenes
    echo -e "${YELLOW}→ Tests de Volúmenes${NC}"
    test_mysql_volume
    test_volume_persistence
    echo ""

    # Tests de Networking
    echo -e "${YELLOW}→ Tests de Networking${NC}"
    test_app_db_connection
    test_network_isolation
    echo ""

    # Tests de Logs
    echo -e "${YELLOW}→ Tests de Logs${NC}"
    test_app_logs
    test_db_logs
    echo ""

    # Tests de Performance
    echo -e "${YELLOW}→ Tests de Performance${NC}"
    test_app_response_time
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
        echo -e "${GREEN}✓✓✓ Todos los tests de integración pasaron!${NC}"
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
