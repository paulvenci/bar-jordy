# 📖 Manual de Usuario - Bar Gordy POS v1.1.0

## Sistema de Punto de Venta para Restaurantes y Bares

---

## 📑 Índice

1. [Introducción](#introducción)
2. [Inicio de Sesión](#inicio-de-sesión)
3. [Panel Principal (Dashboard)](#panel-principal-dashboard)
4. [Caja Rápida (POS)](#caja-rápida-pos)
5. [Gestión de Mesas](#gestión-de-mesas)
6. [Gestión de Productos](#gestión-de-productos)
7. [Control de Inventario](#control-de-inventario)
8. [Reportes y Estadísticas](#reportes-y-estadísticas)
9. [Configuración](#configuración)
10. [Pistola Lectora de Código de Barras](#pistola-lectora-de-código-de-barras)
11. [Preguntas Frecuentes](#preguntas-frecuentes)

---

## Introducción

**Bar Gordy POS** es un sistema completo de punto de venta diseñado específicamente para restaurantes, bares y cafeterías. Ofrece gestión de ventas, inventario, mesas, reportes y más.

### Características Principales

- ✅ Caja rápida para ventas ágiles
- ✅ Gestión de mesas y comandas
- ✅ Control de inventario en tiempo real
- ✅ Reportes de ventas y estadísticas
- ✅ Modo offline con sincronización automática
- ✅ **Pistola lectora de código de barras** (v1.1.0)
- ✅ Interfaz intuitiva y moderna

### Requisitos del Sistema

- Navegador web moderno (Chrome, Firefox, Edge, Safari)
- Conexión a internet (modo offline disponible)
- Resolución mínima: 1024x768px
- Opcional: Pistola lectora USB/Bluetooth para escaneo de códigos

---

## Inicio de Sesión

![Pantalla de Login](file:///C:/Users/paulv/.gemini/antigravity/brain/1e42e1b4-b52a-4f3a-a638-6964f3718c6d/manual_login_screen.png)

### Métodos de Autenticación

El sistema ofrece dos métodos de inicio de sesión:

#### 1. Login con Email

1. Selecciona la pestaña **"Email"**
2. Ingresa tu correo electrónico
3. Ingresa tu contraseña
4. Haz clic en **"Iniciar Sesión"**

#### 2. Login con PIN (Recomendado para cajeros)

1. Selecciona la pestaña **"PIN"**
2. Ingresa tu PIN de 4 dígitos usando:
   - El teclado numérico en pantalla, o
   - Tu teclado físico
3. El sistema iniciará sesión automáticamente al completar los 4 dígitos

> **💡 Consejo:** El login con PIN es más rápido para el personal que opera la caja frecuentemente.

### Botones del Teclado Numérico

- **Números (1-9, 0):** Ingresar dígitos del PIN
- **Limpiar:** Borrar todos los dígitos ingresados
- **✓ (Checkmark):** Confirmar e iniciar sesión

---

## Panel Principal (Dashboard)

![Dashboard](file:///C:/Users/paulv/.gemini/antigravity/brain/1e42e1b4-b52a-4f3a-a638-6964f3718c6d/manual_dashboard_overview.png)

El Dashboard es la pantalla principal que muestra un resumen completo del negocio.

### Elementos del Dashboard

#### 1. Barra Superior

- **Logo y Nombre:** Bar Gordy
- **Versión:** v1.1.0
- **Indicador de Conexión:** 
  - 🟢 **ONLINE** - Conectado a internet
  - 🔴 **OFFLINE** - Sin conexión (datos en caché)
- **Pistola:** Toggle para activar/desactivar lector de códigos
- **Usuario:** Nombre del usuario actual
- **Botón Salir:** Cerrar sesión

#### 2. Menú Lateral

- 📊 **Dashboard** - Vista principal
- 💰 **Caja Rápida** - Ventas rápidas sin mesa
- 🪑 **Mesas** - Gestión de mesas y comandas
- 📦 **Productos** - Catálogo de productos
- 📋 **Inventario** - Control de stock
- 💵 **Ventas** - Historial de transacciones
- 📈 **Reportes** - Estadísticas y análisis
- ⚙️ **Configuración** - Ajustes del sistema

#### 3. Estadísticas del Día

4 tarjetas muestran métricas clave:

- **Ventas Totales:** Ingreso total del día
- **N° de Ventas:** Cantidad de transacciones
- **Mesas Activas:** Mesas ocupadas actualmente
- **Ticket Promedio:** Valor promedio por venta

#### 4. Gráficos

- **Gráfico de Línea:** Evolución de ventas por hora
- **Gráfico de Barras:** Productos más vendidos
- **Tabla de Ventas Recientes:** Últimas transacciones

---

## Caja Rápida (POS)

![Interfaz POS](file:///C:/Users/paulv/.gemini/antigravity/brain/1e42e1b4-b52a-4f3a-a638-6964f3718c6d/manual_pos_interface.png)

La Caja Rápida permite procesar ventas sin asignar mesa, ideal para despacho o ventas al paso.

### Estructura de la Pantalla

#### Panel Izquierdo: Productos

- **Barra de Búsqueda:** Buscar productos por nombre
- **Filtros de Categoría:** Filtrar por tipo (Bebidas, Comidas, etc.)
- **Grilla de Productos:** Cards con:
  - Imagen del producto
  - Nombre
  - Precio
  - Stock disponible (si está bajo, aparece en rojo)

#### Panel Derecho: Carrito

- **Lista de Items:** Productos agregados con:
  - Nombre y precio unitario
  - Controles de cantidad (+/-)
  - Botón eliminar (🗑️)
  - Subtotal por línea
- **Resumen de Totales:**
  - Subtotal
  - Descuentos (si aplican)
  - **Total a Pagar**
- **Botones de Acción:**
  - 🔵 **Procesar Venta** - Abrir modal de pago
  - ⚪ **Limpiar** - Vaciar carrito

### Flujo de Venta

1. **Buscar o seleccionar productos** del panel izquierdo
2. **Click en un producto** para agregarlo al carrito
3. **Ajustar cantidades** con los botones +/-
4. **Revisar el total** en el panel derecho
5. **Click en "Procesar Venta"**
6. **Seleccionar método de pago:**
   - 💵 Efectivo
   - 💳 Tarjeta de Débito
   - 💳 Tarjeta de Crédito
   - 📱 Transferencia
7. **Confirmar la venta**
8. **Imprimir boleta** (opcional)

> **💡 Consejo:** Usa la búsqueda para encontrar productos rápidamente escribiendo su nombre.

---

## Gestión de Mesas

### Vista de Mesas

La vista de mesas muestra el estado de todas las mesas del local:

- 🟢 **Verde:** Mesa disponible
- 🟡 **Amarillo:** Mesa ocupada con comanda
- 🔴 **Rojo:** Mesa con cuenta pendiente de pago

### Abrir Mesa

1. Click en una **mesa disponible** (verde)
2. Se abre el POS con el número de mesa asignado
3. Agregar productos a la comanda
4. Click en **"Guardar Comanda"** para registrar sin cobrar

### Administrar Mesa Activa

Desde una mesa ocupada puedes:

- ➕ **Agregar Items** - Añadir más productos
- 📌 **Guardar Comanda** - Actualizar pedido sin cobrar
- 💰 **Procesar Venta** - Cerrar cuenta y cobrar
- 🚫 **Liberar Mesa** - Cancelar y liberar (sin guardar)

### Comandas Guardadas

Las comandas se guardan automáticamente y permanecen hasta que:
- Se procesa el pago (cierra la cuenta)
- Se libera la mesa manualmente

---

## Gestión de Productos

![Gestión de Productos](file:///C:/Users/paulv/.gemini/antigravity/brain/1e42e1b4-b52a-4f3a-a638-6964f3718c6d/manual_products_management.png)

### Listar Productos

La vista de productos muestra:

- **Tabla con todos los productos**
- **Filtros:** Buscar por nombre o categoría
- **Columnas:** Imagen, Nombre, Categoría, Precio, Stock, Acciones

### Crear Nuevo Producto

1. Click en **"+ Nuevo Producto"**
2. Completar formulario:
   - **Nombre:** Nombre del producto
   - **Categoría:** Seleccionar del dropdown
   - **Precio:** Precio de venta (CLP)
   - **Código de Barras:** Código para pistola lectora (opcional)
   - **Stock Inicial:** Cantidad disponible
   - **Imagen:** Subir foto del producto (opcional)
   - **Descripción:** Detalles adicionales
3. Click en **"Guardar"**

### Editar Producto

1. Click en el **ícono lápiz** (✏️) en la fila del producto
2. Modificar campos necesarios
3. Click en **"Guardar"**

### Eliminar Producto

1. Click en el **ícono basura** (🗑️) en la fila del producto
2. Confirmar eliminación en el diálogo

> ⚠️ **Advertencia:** Eliminar un producto eliminará su historial de ventas. Se recomienda desactivarlo en lugar de eliminarlo.

---

## Control de Inventario

### Vista de Inventario

Muestra el estado actualizado del stock:

- **Lista de productos** con cantidad disponible
- **Alertas de stock bajo** (marcados en rojo/amarillo)
- **Historial de movimientos**

### Registrar Movimiento de Stock

#### Entrada de Mercadería

1. Ir a **Inventario** > **Nuevo Movimiento**
2. Seleccionar **"Entrada"**
3. Elegir producto
4. Ingresar cantidad
5. Motivo: "Compra", "Devolución", etc.
6. **Guardar**

#### Salida de Stock

1. Seleccionar **"Salida"**
2. Elegir producto  
3. Ingresar cantidad
4. Motivo: "Venta", "Merma", "Degustación", etc.
5. **Guardar**

> **💡 Nota:** Las ventas desde el POS ajustan el inventario automáticamente.

### Ajuste Manual

Para corregir diferencias de inventario:

1. Tipo: **"Ajuste"**
2. Ingresar cantidad correcta
3. Motivo: "Inventario físico", "Corrección", etc.

---

## Reportes y Estadísticas

### Reportes Disponibles

#### 1. Reporte de Ventas

- **Ventas por período:** Día, semana, mes, año
- **Filtros:** Rango de fechas personalizado
- **Métricas:** Total vendido, N° transacciones, ticket promedio
- **Exportar:** PDF, Excel

#### 2. Productos Más Vendidos

- **Top 10 productos** del período
- **Cantidad vendida** de cada uno
- **Ingresos generados** por producto
- **Gráfico de barras** visual

#### 3. Productos Sin Rotación

- **Productos sin ventas** en el período seleccionado
- **Identificar stock muerto**
- **Tomar decisiones** sobre discontinuar productos

#### 4. Reporte de Inventario

- **Stock actual** de todos los productos
- **Valor del inventario**
- **Productos con stock bajo**

### Generar Reporte

1. Ir a **Reportes**
2. Seleccionar tipo de reporte
3. Configurar filtros (fechas, categorías, etc.)
4. Click en **"Generar"**
5. Revisar datos en pantalla
6. **Exportar** si es necesario (PDF/Excel)

---

## Configuración

### Configuración General

- **Nombre del Negocio:** Aparece en boletas y reportes
- **RUT/ID Fiscal:** Datos legales
- **Dirección y Teléfono**
- **Logo:** Imagen corporativa

### Configuración de Impresión

- **Ancho de Papel:** 58mm o 80mm
- **Mensaje de Pie:** Texto al final de la boleta
- **Imprimir Logo:** Mostrar/ocultar logo en boletas

### Gestión de Usuarios

Solo para administradores:

- **Crear usuarios** nuevos
- **Asignar permisos** por rol
- **Cambiar PINs** de acceso rápido
- **Desactivar usuarios**

### Categorías de Productos

- **Crear nuevas categorías**
- **Editar categorías existentes**
- **Organizar jerarquías**

---

## Pistola Lectora de Código de Barras

### Activar Modo Pistola

![Barcode Scanner](file:///C:/Users/paulv/.gemini/antigravity/brain/1e42e1b4-b52a-4f3a-a638-6964f3718c6d/barcode_button_options.png)

1. En el **header** (barra superior), localiza el botón **"Pistola"**
2. Click en el botón para **activar** (se pone azul con texto "🔫 Pistola")
3. El modo queda activo hasta que lo desactives

### Usar la Pistola Lectora

Una vez activado el modo:

1. **Conecta tu pistola** USB o Bluetooth al dispositivo
2. En la pantalla de **Caja Rápida** o **Mesas**
3. **Escanea el código de barras** del producto
4. El producto se **agrega automáticamente** al carrito
5. Aparece una **notificación verde**: "✅ [Producto] agregado"

### Configurar Códigos de Barras

Para que un producto sea escaneable:

1. Ir a **Productos** > Editar producto
2. Completar campo **"Código de Barras"** con el código EAN/UPC
3. Guardar

### Errores Comunes

- **❌ Código no encontrado:**
  - Verifica que el código esté registrado en el sistema
  - Revisa que coincida exactamente con el del producto
- **Pistola no responde:**
  - Verifica la conexión USB/Bluetooth
  - Prueba en un editor de texto (debe escribir caracteres)

> **💡 Consejo:** Las pistolas USB/Bluetooth funcionan como un teclado, enviando el código + Enter automáticamente.

### Desactivar Modo Pistola

1. Click nuevamente en el botón **"Pistola"**
2. El botón vuelve a gris con texto "Pistola OFF"
3. Los escaneos ya no agregarán productos

---

## Preguntas Frecuentes

### ¿Cómo funciona el modo offline?

El sistema guarda las ventas localmente cuando no hay conexión. Al recuperar internet, sincroniza automáticamente todo.

### ¿Puedo usar el sistema en un tablet?

Sí, el sistema es responsive y funciona en tablets y teléfonos. Se recomienda resolución mínima de 1024x768px para mejor experiencia.

### ¿Cómo imprimo las boletas?

Usa el diálogo del navegador (Ctrl+P) después de procesar la venta, o configura una impresora térmica compatible.

### ¿Puedo personalizar las categorías?

Sí, desde **Configuración** > **Categorías** puedes crear, editar y eliminar categorías según tu negocio.

### ¿Cómo reseteo mi PIN?

Solo un administrador puede cambiar PINs desde **Configuración** > **Usuarios**.

### ¿Los reportes se pueden exportar?

Sí, todos los reportes tienen opciones para exportar a PDF o Excel.

### ¿Qué pistolas lectoras son compatibles?

Cualquier pistola USB o Bluetooth que emule un teclado (HID). No requiere drivers especiales.

###¿Cómo actualizo el sistema?

Las actualizaciones se despliegan automáticamente. Recarga la página (F5) para obtener la última versión.

---

## Soporte Técnico

### Información de la Versión

- **Versión Actual:** v1.1.0
- **Última Actualización:** Enero 2026
- **Novedades:** Pistola lectora de código de barras

### Contacto

Para soporte técnico o consultas:

- 📧 Email: soporte@bargordy.com
- 📱 Teléfono: [Tu teléfono]
- 🌐 Web: [Tu sitio web]

---

**© 2026 Bar Gordy POS - Todos los derechos reservados**
