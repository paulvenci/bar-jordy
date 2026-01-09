# 🖨️ Guía: Modo Kiosco con Impresión Automática

## ¿Qué es el Modo Kiosco?

El modo kiosco convierte Chrome en una aplicación de pantalla completa que imprime automáticamente sin mostrar el diálogo de Windows.

**Ventajas:**
- ✅ Impresión directa sin diálogos
- ✅ Pantalla completa (ideal para TPV dedicado)
- ✅ Más rápido para cajeros
- ✅ Menos clics por venta

**Desventajas:**
- ❌ Chrome en pantalla completa (no puedes ver otras apps fácilmente)
- ❌ Imprime siempre a la impresora predeterminada
- ❌ Requiere configuración inicial

---

## Configuración Paso a Paso

### 1. Configurar Impresora Predeterminada

> **Importante:** El modo kiosco imprime a la impresora predeterminada de Windows.

1. Presiona `Win + I` para abrir Configuración
2. Ve a **Bluetooth y dispositivos** > **Impresoras y escáneres**
3. Encuentra tu impresora térmica
4. Click en ella y selecciona **"Establecer como predeterminada"**

![Configuración de impresora predeterminada](/C:/Users/paulv/.gemini/antigravity/brain/1e42e1b4-b52a-4f3a-a638-6964f3718c6d/manual_dashboard_overview_1767913868146.png)

### 2. Iniciar en Modo Kiosco

#### Opción A: Usar script automático (Recomendado)

1. Asegúrate de que el servidor está corriendo:
   ```bash
   cd "d:\Electrosun\bar gordy\frontend"
   npm run dev
   ```

2. Haz **doble click** en el archivo:
   ```
   lanzar-kiosco.bat
   ```

3. Chrome se abrirá en pantalla completa automáticamente

#### Opción B: Comando manual

1. Abre **Símbolo del sistema** (tecla Win + R, escribe `cmd`)

2. Ejecuta:
   ```bash
   "C:\Program Files\Google\Chrome\Application\chrome.exe" --kiosk --kiosk-printing --app=http://localhost:5173
   ```

### 3. Usar la Aplicación

- **Navegar:** Todo funciona igual que antes
- **Imprimir:** Al hacer click en "🖨️ Imprimir" en la boleta, se imprime automáticamente
- **Salir del modo kiosco:** Presiona `Alt + F4` o `Esc` (dependiendo de configuración)

---

## Parámetros del Modo Kiosco

| Parámetro | Función |
|-----------|---------|
| `--kiosk` | Pantalla completa sin barras |
| `--kiosk-printing` | Impresión automática sin diálogo |
| `--app=URL` | URL de la aplicación |

### Parámetros Opcionales Útiles

```bash
# Deshabilitar cierre accidental
--no-first-run

# Deshabilitar actualizaciones automáticas durante uso
--disable-background-networking

# Forzar idioma español
--lang=es

# Comando completo con extras:
chrome.exe --kiosk --kiosk-printing --no-first-run --lang=es --app=http://localhost:5173
```

---

## Salir del Modo Kiosco

### Método 1: Tecla de acceso rápido
- Presiona `Alt + F4`
- O presiona `Esc` (si está habilitado)

### Método 2: Administrador de tareas
1. Presiona `Ctrl + Shift + Esc`
2. Busca "Google Chrome"
3. Click derecho > "Finalizar tarea"

### Método 3: Cerrar desde taskbar (si visible)
- Click derecho en el ícono de Chrome en la barra de tareas
- "Cerrar ventana"

---

## Volver al Modo Normal

Si no te gusta el modo kiosco:

1. **Cierra Chrome** (Alt + F4)
2. **Abre Chrome normalmente:**
   - Doble click en el ícono de Chrome del escritorio
   - O desde el menú inicio
3. **Navega a:** `http://localhost:5173`
4. **¡Listo!** Volverás a ver el diálogo de impresión normal

> **Nota:** No necesitas desinstalar ni cambiar nada. El modo kiosco solo afecta cuando usas ese comando específico.

---

## Crear Acceso Directo en Escritorio

Para lanzar rápidamente en modo kiosco:

1. Click derecho en el escritorio > **Nuevo** > **Acceso directo**

2. En ubicación, pega:
   ```
   "C:\Program Files\Google\Chrome\Application\chrome.exe" --kiosk --kiosk-printing --app=http://localhost:5173
   ```

3. Nombre: **Bar Gordy POS - Modo Kiosco**

4. Click **Finalizar**

5. (Opcional) Click derecho en el acceso directo > **Propiedades** > **Cambiar icono** y elige un ícono de impresora

---

## Solución de Problemas

### ❌ "Chrome no se encuentra"

**Solución:** Chrome podría estar en otra ubicación. Prueba:

```bash
# Ubicación alternativa (x86)
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --kiosk --kiosk-printing --app=http://localhost:5173

# O busca manualmente:
# Win + R, luego busca chrome.exe
```

### ❌ "Imprime a impresora incorrecta"

**Solución:** Cambia la impresora predeterminada de Windows:
1. Configuración > Impresoras
2. Establece la térmica como predeterminada

### ❌ "No imprime automáticamente"

**Posibles causas:**
1. Falta el parámetro `--kiosk-printing`
2. La impresora no está configurada correctamente
3. Chrome necesita permisos (primera vez muestra diálogo para permitir)

**Solución:** La primera vez que uses modo kiosco, Chrome puede pedir permiso para imprimir. Acepta y marca "Recordar mi elección".

### ❌ "Quiero salir pero no puedo"

**Atajos de teclado:**
- `Alt + F4` - Cerrar aplicación
- `Ctrl + Shift + Esc` - Administrador de tareas
- `Ctrl + Alt + Supr` - Opciones de sistema

---

## Comparación: Normal vs Kiosco

| Característica | Modo Normal | Modo Kiosco |
|----------------|-------------|-------------|
| **Impresión** | Diálogo de Windows | Automática |
| **Pantalla** | Ventana normal | Pantalla completa |
| **Navegación** | Barra de direcciones visible | Sin barras |
| **Salir** | Click en X | Alt+F4 |
| **Uso** | General | TPV dedicado |
| **Configuración** | Ninguna | Impresora predeterminada |

---

## Recomendación

**Usa Modo Kiosco si:**
- ✅ Tienes un PC/tablet dedicado solo para el POS
- ✅ Quieres agilizar el proceso de venta
- ✅ Siempre imprimes en la misma impresora
- ✅ No necesitas acceso a otras aplicaciones simultáneamente

**Usa Modo Normal si:**
- ✅ Usas el mismo PC para otras tareas
- ✅ Tienes múltiples impresoras
- ✅ Necesitas flexibilidad
- ✅ Prefieres control manual sobre impresión

---

## Próximos Pasos

¿Te gustó el modo kiosco? Considera:

1. **Crear acceso directo** en el escritorio
2. **Configurar inicio automático** con Windows (opcional)
3. **Probar por unos días** antes de decidir

¿No te convenció? Simplemente vuelve al modo normal abriendo Chrome normalmente.

---

**Versión:** v1.1.0  
**Actualizado:** Enero 2026
