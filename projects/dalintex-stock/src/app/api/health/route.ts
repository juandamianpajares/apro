import { NextResponse } from "next/server";

/**
 * Health Check Endpoint
 * Usado por Docker healthcheck y monitoring
 *
 * GET /api/health
 */
export async function GET() {
  try {
    // Verificar que la aplicación está funcionando
    const healthCheck = {
      status: "ok",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV,
      version: process.env.npm_package_version || "1.0.0",
      node_version: process.version,
    };

    // TODO: Agregar check de base de datos cuando esté configurado
    // const dbStatus = await checkDatabaseConnection();
    // healthCheck.database = dbStatus;

    return NextResponse.json(healthCheck, { status: 200 });
  } catch (error) {
    console.error("Health check failed:", error);

    return NextResponse.json(
      {
        status: "error",
        timestamp: new Date().toISOString(),
        error: error instanceof Error ? error.message : "Unknown error",
      },
      { status: 503 }
    );
  }
}

/**
 * Función auxiliar para verificar conexión a base de datos
 * Implementar cuando se configure Prisma/ORM
 */
async function checkDatabaseConnection(): Promise<{
  connected: boolean;
  latency?: number;
}> {
  try {
    const start = Date.now();

    // TODO: Implementar con Prisma
    // await prisma.$queryRaw`SELECT 1`;

    const latency = Date.now() - start;

    return {
      connected: true,
      latency,
    };
  } catch (error) {
    return {
      connected: false,
    };
  }
}
