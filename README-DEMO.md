# Configuración de Entorno de Demo - Bar Gordy

Este directorio contiene scripts automatizados para clonar el proyecto Bar Gordy a un entorno de demo con datos de producción congelados.

## 🎯 Objetivo

Crear una copia completa del proyecto para hacer demos sin afectar:
- El código del proyecto original
- La base de datos de producción
- Las configuraciones de producción

## 📋 Requisitos Previos

- ✅ Node.js instalado
- ✅ Docker Desktop instalado y **corriendo**
- ✅ Supabase CLI instalado (`npm install -g supabase`)
- ✅ PostgreSQL client (psql) instalado (opcional, para snapshot de datos)

## 🚀 Proceso de Configuración

### Opción A: Configuración Automática (Recomendado)

Ejecuta los scripts en orden:

```powershell
# 1. Clonar el proyecto
.\1-clonar-proyecto-demo.ps1

# 2. Capturar datos de producción (opcional pero recomendado)
.\2-capturar-datos-produccion.ps1

# 3. Configurar todo automáticamente
cd ..\bar-gordy-demo
..\bar gordy\3-configurar-demo.ps1
```

### Opción B: Configuración Manual

Sigue la guía detallada en: [`docs/DEMO_SETUP.md`](docs/DEMO_SETUP.md)

## 📁 Scripts Disponibles

### 1️⃣ `1-clonar-proyecto-demo.ps1`
**Qué hace:**
- Copia el proyecto a `d:\Electrosun\bar-gordy-demo`
- Excluye `node_modules`, `.git`, `dist`, y archivos `.env`
- Usa `robocopy` para copia eficiente

**Duración:** ~1-2 minutos

### 2️⃣ `2-capturar-datos-produccion.ps1`
**Qué hace:**
- Crea un template SQL para exportar datos
- Genera instrucciones para capturar datos reales
- Guarda snapshot en `supabase/snapshots/snapshot-2026-02-03.sql`

**Duración:** ~5-10 minutos (incluye exportación manual)

**Nota:** Requiere acceso a Supabase Studio de producción

### 3️⃣ `3-configurar-demo.ps1`
**Qué hace:**
- Inicializa Supabase local
- Crea archivo `.env.local` con credenciales locales
- Aplica migraciones de base de datos
- Carga snapshot de datos (si existe)
- Crea usuario administrador de demo
- Instala dependencias de Node.js

**Duración:** ~5-15 minutos (primera vez descarga imágenes Docker)

## 🎮 Uso del Entorno de Demo

### Iniciar la aplicación

```powershell
cd "d:\Electrosun\bar-gordy-demo\frontend"
npm run dev
```

### Credenciales de acceso

- **Email:** `demo@bargordy.local`
- **PIN:** `1234`

### URLs de acceso

- **Aplicación:** http://localhost:5173
- **Supabase Studio:** http://localhost:54323
- **API Local:** http://localhost:54321

## 🔄 Resetear Demo Entre Presentaciones

Para volver a un estado limpio:

```powershell
cd "d:\Electrosun\bar-gordy-demo"

# Resetear base de datos
supabase db reset

# Recargar snapshot de datos
$env:PGPASSWORD = "postgres"
psql -h localhost -p 54322 -U postgres -d postgres -f "..\bar gordy\supabase\snapshots\snapshot-2026-02-03.sql"
```

## 📊 Captura de Datos de Producción

### Método 1: Desde Supabase Dashboard (Más fácil)

1. Abre tu Supabase Dashboard de producción
2. Ve a **Database** → **Backups**
3. Crea un backup manual
4. Descarga el archivo `.sql`
5. Guárdalo como: `supabase/snapshots/snapshot-2026-02-03.sql`

### Método 2: Usando pg_dump (Avanzado)

```powershell
# Obtén la cadena de conexión desde Supabase Dashboard
pg_dump "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres" `
  --data-only `
  --inserts `
  --exclude-table-data="auth.*" `
  --exclude-table-data="storage.*" `
  > supabase/snapshots/snapshot-2026-02-03.sql
```

### Método 3: Exportación Manual de Tablas

Ejecuta en SQL Editor de Supabase Studio y guarda los resultados:

```sql
-- Exportar últimos 30 días de ventas
COPY (
  SELECT * FROM ventas 
  WHERE fecha >= '2026-01-04'
) TO STDOUT WITH CSV HEADER;

-- Exportar productos
COPY productos TO STDOUT WITH CSV HEADER;

-- Exportar categorías
COPY categorias TO STDOUT WITH CSV HEADER;
```

## 🛠️ Solución de Problemas

### Docker no está corriendo
```powershell
# Verifica que Docker Desktop esté abierto
docker --version
```

### Puerto 54321 ya en uso
```powershell
# Detén otras instancias de Supabase
supabase stop --no-backup
```

### Error al instalar dependencias
```powershell
# Limpia caché de npm
npm cache clean --force
cd "d:\Electrosun\bar-gordy-demo\frontend"
npm install
```

### Supabase no inicia
```powershell
# Verifica el estado
supabase status

# Reinicia completamente
supabase stop
supabase start
```

## 📝 Notas Importantes

- ✅ El entorno de demo es **completamente independiente** de producción
- ✅ Los datos están **congelados a la fecha 2026-02-03**
- ✅ Puedes resetear la base de datos cuantas veces quieras
- ✅ No afecta el proyecto original en `d:\Electrosun\bar gordy`
- ⚠️ No uses este entorno para desarrollo real, solo para demos

## 📚 Documentación Adicional

- [Guía Completa de Setup](docs/DEMO_SETUP.md)
- [Guía de Staging](docs/STAGING_SETUP.md)
- [Documentación de Supabase CLI](https://supabase.com/docs/guides/cli)

---

**Fecha de creación:** 2026-02-03  
**Versión del proyecto:** 1.3.1
