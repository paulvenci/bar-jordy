# Guía: Configuración de Entorno de Demo

Esta guía te ayudará a crear una copia completa del proyecto Bar Gordy para hacer demos sin afectar el proyecto original.

## Requisitos Previos

- Node.js instalado
- Docker Desktop instalado y corriendo (para Supabase local)
- Supabase CLI instalado

## Paso 1: Clonar el Proyecto

### Opción A: Usando Git (Recomendado)

```bash
# Clonar a una nueva carpeta
git clone d:\Electrosun\bar-gordy d:\Electrosun\bar-gordy-demo

# O si tienes un repositorio remoto
git clone <URL_DEL_REPOSITORIO> d:\Electrosun\bar-gordy-demo
```

### Opción B: Copiar Carpeta Manualmente

```powershell
# Copiar toda la carpeta (excluye node_modules y .git si quieres empezar limpio)
xcopy "d:\Electrosun\bar gordy" "d:\Electrosun\bar-gordy-demo" /E /I /H /EXCLUDE:exclusiones.txt
```

## Paso 2: Configurar Supabase Local para Demo

```bash
cd "d:\Electrosun\bar-gordy-demo"

# Inicializar Supabase (si no existe la carpeta supabase/)
supabase init

# Iniciar Supabase local
supabase start
```

> **Nota**: La primera vez tomará unos minutos descargando las imágenes Docker.

Al terminar, guarda las credenciales que muestra:

```
API URL: http://localhost:54321
anon key: eyJhbGciOiJS...
service_role key: eyJhbGciOiJS...
Studio URL: http://localhost:54323
```

## Paso 3: Configurar Variables de Entorno

Crea el archivo `frontend/.env.local` (para desarrollo local de demo):

```env
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=<anon key que te mostró supabase start>
```

> **Importante**: Usa `.env.local` en lugar de `.env` para que no afecte el proyecto original.

## Paso 4: Aplicar Migraciones de Base de Datos

```bash
# Opción A: Automático (recomendado)
supabase db push

# Opción B: Manual desde Studio
# 1. Abre http://localhost:54323
# 2. Ve a SQL Editor
# 3. Ejecuta los archivos de supabase/migrations/ en orden
```

## Paso 5: Crear Usuario Administrador de Demo

En Supabase Studio (http://localhost:54323):

1. **Authentication → Users → Create User**
   - Email: `demo@bargordy.local`
   - Password: `demo1234`

2. **SQL Editor** - Ejecuta:

```sql
INSERT INTO usuarios (id, nombre, email, pin, activo, rol_id)
VALUES (
  (SELECT id FROM auth.users WHERE email = 'demo@bargordy.local'),
  'Usuario Demo',
  'demo@bargordy.local',
  '1234',
  true,
  (SELECT id FROM roles WHERE nombre = 'Administrador')
);
```

## Paso 6: Instalar Dependencias

```bash
cd frontend
npm install
```

## Paso 7: Ejecutar la Aplicación Demo

```bash
npm run dev
```

La aplicación estará disponible en: http://localhost:5173

**Credenciales de acceso:**
- Email: `demo@bargordy.local`
- PIN: `1234`

## Paso 8: Cargar Datos de Ejemplo (Opcional)

Para hacer demos más realistas, puedes cargar datos de ejemplo:

```sql
-- Insertar categorías de ejemplo
INSERT INTO categorias (nombre, color) VALUES
  ('Bebidas', '#3B82F6'),
  ('Comidas', '#10B981'),
  ('Postres', '#F59E0B');

-- Insertar productos de ejemplo
INSERT INTO productos (nombre, precio, stock, categoria_id, codigo_barras) VALUES
  ('Coca Cola', 150, 50, (SELECT id FROM categorias WHERE nombre = 'Bebidas'), '7790001001'),
  ('Hamburguesa', 500, 30, (SELECT id FROM categorias WHERE nombre = 'Comidas'), '7790002001'),
  ('Helado', 200, 20, (SELECT id FROM categorias WHERE nombre = 'Postres'), '7790003001');
```

## Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `supabase start` | Iniciar Supabase local |
| `supabase stop` | Detener Supabase local |
| `supabase status` | Ver estado y URLs |
| `supabase db reset` | Resetear base de datos (útil para demos) |
| `npm run dev` | Ejecutar app en modo desarrollo |

## Resetear Demo Entre Presentaciones

Para volver a un estado limpio entre demos:

```bash
# Resetear base de datos
supabase db reset

# Volver a crear usuario admin y datos de ejemplo
# (ejecutar los SQL del Paso 5 y Paso 8)
```

## Diferencias con Producción

- **Base de datos**: Local (no afecta producción)
- **URL**: http://localhost:5173 (en lugar del dominio de producción)
- **Datos**: Completamente separados
- **Usuarios**: Independientes del sistema de producción

## Solución de Problemas

### Docker no está corriendo
```bash
# Verifica que Docker Desktop esté abierto y corriendo
docker --version
```

### Puerto 54321 ya en uso
```bash
# Detén otras instancias de Supabase
supabase stop --no-backup
```

### Error al instalar dependencias
```bash
# Limpia caché de npm
npm cache clean --force
npm install
```

## Accesos Rápidos

- **App Demo**: http://localhost:5173
- **Supabase Studio**: http://localhost:54323
- **API Local**: http://localhost:54321

---

**¡Listo!** Ahora tienes un entorno de demo completamente funcional y aislado del proyecto original.
