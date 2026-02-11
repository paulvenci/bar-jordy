<template>
  <AppLayout>
    <div class="max-w-4xl mx-auto p-4 md:p-6 space-y-6">
      
      <!-- Header -->
      <div class="space-y-1">
        <h1 class="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
          <span>❓</span> Centro de Ayuda
        </h1>
        <p class="text-gray-500 dark:text-gray-400">
          Encuentra respuestas, guías y soporte para GestorBar
        </p>
      </div>

      <!-- Quick Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <!-- POS Card -->
        <router-link to="/" class="block group">
          <div class="bg-blue-50 dark:bg-blue-900/20 p-5 rounded-xl border border-blue-100 dark:border-blue-800 hover:border-blue-300 dark:hover:border-blue-600 transition-colors h-full">
            <div class="text-3xl mb-3 bg-blue-100 dark:bg-blue-800 w-12 h-12 flex items-center justify-center rounded-lg">🛒</div>
            <h3 class="font-bold text-lg text-blue-900 dark:text-blue-100 mb-2">Punto de Venta</h3>
            <p class="text-sm text-blue-700 dark:text-blue-300 leading-relaxed">
              Ir a la pantalla principal de ventas. Recuerda abrir turno antes de comenzar.
            </p>
          </div>
        </router-link>

        <!-- Inventory Card -->
        <router-link to="/inventario" class="block group">
          <div class="bg-green-50 dark:bg-green-900/20 p-5 rounded-xl border border-green-100 dark:border-green-800 hover:border-green-300 dark:hover:border-green-600 transition-colors h-full">
            <div class="text-3xl mb-3 bg-green-100 dark:bg-green-800 w-12 h-12 flex items-center justify-center rounded-lg">📦</div>
            <h3 class="font-bold text-lg text-green-900 dark:text-green-100 mb-2">Inventario</h3>
            <p class="text-sm text-green-700 dark:text-green-300 leading-relaxed">
              Gestiona productos, ajusta el stock y crea nuevas categorías.
            </p>
          </div>
        </router-link>

        <!-- Reports Card -->
        <router-link to="/reportes" class="block group">
          <div class="bg-purple-50 dark:bg-purple-900/20 p-5 rounded-xl border border-purple-100 dark:border-purple-800 hover:border-purple-300 dark:hover:border-purple-600 transition-colors h-full">
            <div class="text-3xl mb-3 bg-purple-100 dark:bg-purple-800 w-12 h-12 flex items-center justify-center rounded-lg">📊</div>
            <h3 class="font-bold text-lg text-purple-900 dark:text-purple-100 mb-2">Reportes</h3>
            <p class="text-sm text-purple-700 dark:text-purple-300 leading-relaxed">
              Revisa ventas diarias, cierres de caja y rendimiento histórico.
            </p>
          </div>
        </router-link>
      </div>

      <!-- FAQ Accordion -->
      <section class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 overflow-hidden">
        <div class="p-5 border-b border-gray-100 dark:border-gray-700 bg-gray-50 dark:bg-gray-800/50">
          <h2 class="font-bold text-lg text-gray-900 dark:text-white flex items-center gap-2">
            ℹ️ Preguntas Frecuentes
          </h2>
        </div>
        
        <div class="divide-y divide-gray-100 dark:divide-gray-700">
          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>¿Cómo cierro mi turno correctamente?</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-blue-500">
              <p>Ve al menú superior derecho (tu nombre) y selecciona <strong>"Cerrar Turno"</strong>. El sistema:</p>
              <ol class="list-decimal ml-4 mt-2 space-y-1">
                <li>Contará automáticamente las ventas del turno.</li>
                <li>Generará un resumen de recaudación (Efectivo/Tarjeta).</li>
                <li>Cerrará tu sesión operativa.</li>
              </ol>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>¿Cómo anulo una venta equivocada?</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-red-500">
              <p>Ve al menú <strong>Reportes > Ventas del Día</strong>:</p>
              <ol class="list-decimal ml-4 mt-2 space-y-1">
                <li>Busca la venta en el listado cronológico.</li>
                <li>Haz clic en el botón rojo <strong>"Anular"</strong> a la derecha.</li>
                <li>Ingresa el motivo (ej: "Error de digitación") y confirma con tu PIN de administrador.</li>
              </ol>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>El producto no aparece en el POS</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-orange-500">
              <p>Verifica dos cosas en el menú <strong>Inventario</strong>:</p>
              <ul class="list-disc ml-4 mt-2 space-y-1">
                <li>Que el producto tenga el estado <strong>"Activo"</strong> (switch verde).</li>
                <li>Que tenga stock disponible (si controlas stock).</li>
              </ul>
              <p class="mt-2 text-xs text-gray-500">Si es nuevo, usa el botón "+ Nuevo Producto" para crearlo.</p>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>¿Cómo dividir la cuenta de una mesa?</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-purple-500">
              <p>Al cobrar una mesa, selecciona <strong>"Pago Parcial / Dividir"</strong>. Podrás ingresar el monto exacto que paga cada persona y el método de pago (Efectivo/Tarjeta) por separado hasta completar el total.</p>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>¿Puedo cambiar un pedido de mesa?</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-indigo-500">
              <p>Sí. Ve a la sección <strong>Mesas</strong>, selecciona la mesa activa y podrás agregar más productos. Si necesitas borrar algo ya comandado, requerirás el PIN de administrador.</p>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>¿Cómo emitir boleta con RUT (Factura)?</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-green-500">
              <p>En la pantalla de cobro, antes de finalizar, haz clic en <strong>"Asignar Cliente"</strong>. Busca la empresa por RUT o nombre. Si no existe, créala ahí mismo. El ticket saldrá con los datos del cliente asignado.</p>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>¿Qué pasa si se corta internet?</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-red-500">
              <p>El sistema tiene <strong>Modo Offline</strong> básico. Puedes seguir vendiendo, pero los datos no se sincronizarán hasta que vuelva la conexión. Evita cerrar el navegador o recargar la página mientras estés sin internet.</p>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>Olvidé mi PIN de administrador</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-yellow-500">
              <p>Por seguridad, el PIN solo se puede restablecer desde la base de datos central o contactando a soporte técnico. No hay opción de "recuperar contraseña" en el POS por seguridad.</p>
            </div>
          </details>

          <details class="group p-5 cursor-pointer">
            <summary class="flex justify-between items-center font-medium text-gray-900 dark:text-gray-200 list-none hover:text-blue-600 transition-colors">
              <span>¿Cómo reimprimir un ticket?</span>
              <span class="transition-transform duration-200 group-open:rotate-180 text-gray-400">🔽</span>
            </summary>
            <div class="text-gray-600 dark:text-gray-400 mt-3 text-sm leading-relaxed pl-4 border-l-2 border-gray-500">
              <p>Ve a <strong>Reportes > Ventas del Día</strong>. Busca la venta y haz clic en el icono de impresora 🖨️ (si está disponible) o anota el número de venta para buscarlo en el historial detallado.</p>
            </div>
          </details>
        </div>
      </section>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Shortcuts -->
        <section class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-5">
          <h3 class="font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            ⌨️ Atajos Rápidos
          </h3>
          <ul class="space-y-3 text-sm">
            <li class="flex justify-between items-center border-b border-gray-50 dark:border-gray-700 pb-2">
              <span class="text-gray-600 dark:text-gray-400">Buscar producto</span>
              <div class="flex gap-1">
                <kbd class="px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded text-xs font-mono border border-gray-200 dark:border-gray-600">Ctrl</kbd>
                <span class="text-gray-400">+</span>
                <kbd class="px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded text-xs font-mono border border-gray-200 dark:border-gray-600">F</kbd>
              </div>
            </li>
            <li class="flex justify-between items-center border-b border-gray-50 dark:border-gray-700 pb-2">
              <span class="text-gray-600 dark:text-gray-400">Confirmar / Cobrar</span>
              <kbd class="px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded text-xs font-mono border border-gray-200 dark:border-gray-600">Enter</kbd>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-600 dark:text-gray-400">Cancelar / Volver</span>
              <kbd class="px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded text-xs font-mono border border-gray-200 dark:border-gray-600">Esc</kbd>
            </li>
          </ul>
        </section>

        <!-- System & Support -->
        <section class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-5">
          <h3 class="font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            🛠️ Sistema
          </h3>
          <div class="space-y-4 text-sm">
            <div class="flex items-center justify-between">
              <span class="text-gray-500">Versión Actual</span>
              <span class="font-mono bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-200 px-2 py-1 rounded text-xs font-bold">v1.3.0</span>
            </div>
            
            <div class="flex items-center justify-between">
              <span class="text-gray-500">Conexión</span>
              <span class="text-green-600 dark:text-green-400 font-bold flex items-center gap-1.5">
                <span class="relative flex h-2 w-2">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                </span>
                Online
              </span>
            </div>

            <div class="pt-4 mt-2 border-t border-gray-100 dark:border-gray-700 flex flex-col gap-2">
              <p class="text-gray-900 dark:text-white font-medium">¿Necesitas soporte técnico?</p>
              <div class="flex gap-2">
                <a href="#" class="flex-1 text-center py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors text-xs font-bold">
                  Documentación
                </a>
                <a href="#" class="flex-1 text-center py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors text-xs font-bold shadow-sm">
                  Contactar Admin
                </a>
              </div>
            </div>
          </div>
        </section>
      </div>

    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import AppLayout from '@/components/layout/AppLayout.vue'
</script>
