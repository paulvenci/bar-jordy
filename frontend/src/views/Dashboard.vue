<template>
  <AppLayout>
    <div class="max-w-7xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h1 class="text-2xl font-extrabold text-gray-900 dark:text-white tracking-tight">
            📊 Resumen General
          </h1>
          <p class="text-gray-500 dark:text-gray-400 mt-1 font-medium">
            Bienvenido de nuevo. Aquí tienes lo que está pasando hoy.
          </p>
        </div>
        <div class="flex items-center gap-2 text-sm font-medium text-gray-500 dark:text-gray-400 bg-white dark:bg-gray-800 px-4 py-2 rounded-full shadow-sm">
          <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
          Actualizado: {{ new Date().toLocaleTimeString() }}
        </div>
      </div>
      
      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-24">
        <div class="flex flex-col items-center">
          <div class="relative w-16 h-16">
            <div class="absolute inset-0 rounded-full border-4 border-primary-100 dark:border-primary-900/30"></div>
            <div class="absolute inset-0 rounded-full border-4 border-primary-600 border-t-transparent animate-spin"></div>
          </div>
          <p class="mt-4 text-gray-600 dark:text-gray-400 font-medium animate-pulse">Sincronizando datos...</p>
        </div>
      </div>

      <!-- Dashboard Content -->
      <div v-else class="space-y-8">
        <!-- KPIs Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <KPICard
            title="Productos"
            :value="totalProductos"
            icon="📦"
            format="number"
            subtitle="En catálogo activo"
          />
          
          <KPICard
            title="Stock Crítico"
            :value="productosStockBajo"
            icon="⚠️"
            format="number"
            :type="productosStockBajo > 0 ? 'danger' : 'success'"
            :alert="productosStockBajo > 0 ? `${productosStockBajo} por reponer` : undefined"
            :subtitle="productosStockBajo > 0 ? 'Atención inmediata' : 'Inventario sano'"
          />
          
          <KPICard
            title="Ventas Hoy"
            :value="ventasHoy"
            icon="📈"
            format="number"
            type="success"
            subtitle="Órdenes procesadas"
          />
          
          <KPICard
            title="Recaudación"
            :value="totalRecaudado"
            icon="💰"
            format="currency"
            type="success"
            :subtitle="`Meta diaria: ${formatCurrency(500000)}`"
          />
        </div>

        <!-- AI Strategy Section -->
        <AIInsights />

        <!-- Main Actions & Alerts -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Quick Actions Column -->
          <div class="lg:col-span-2 space-y-6">
             <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm overflow-hidden border border-gray-100 dark:border-gray-700">
              <div class="px-6 py-4 border-b border-gray-50 dark:border-gray-700/50 bg-gray-50/50 dark:bg-gray-800/50 flex items-center justify-between">
                <h2 class="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
                  🚀 Acciones Rápidas
                </h2>
              </div>
              <div class="p-6 grid grid-cols-1 sm:grid-cols-2 gap-4">
                <router-link
                  to="/pos"
                  class="flex items-center gap-4 p-4 bg-primary-50 dark:bg-primary-900/20 hover:bg-primary-100 dark:hover:bg-primary-900/30 rounded-xl transition-all duration-300 group ring-1 ring-primary-100 dark:ring-primary-900/50 hover:shadow-md"
                >
                  <div class="w-12 h-12 rounded-lg bg-primary-600 text-white flex items-center justify-center text-2xl shadow-lg transition-transform group-hover:scale-110">💵</div>
                  <div>
                    <p class="font-bold text-gray-900 dark:text-white">Nueva Venta</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">Ir al terminal de cobro</p>
                  </div>
                </router-link>

                <router-link
                  to="/mesas"
                  class="flex items-center gap-4 p-4 bg-secondary-50 dark:bg-secondary-900/20 hover:bg-secondary-100 dark:hover:bg-secondary-900/30 rounded-xl transition-all duration-300 group ring-1 ring-secondary-100 dark:ring-secondary-900/50 hover:shadow-md"
                >
                  <div class="w-12 h-12 rounded-lg bg-secondary-600 text-white flex items-center justify-center text-2xl shadow-lg transition-transform group-hover:scale-110">🍽️</div>
                  <div>
                    <p class="font-bold text-gray-900 dark:text-white">Gestión de Mesas</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">Ver estado del local</p>
                  </div>
                </router-link>

                <router-link
                  to="/productos"
                  class="flex items-center gap-4 p-4 bg-accent-50 dark:bg-accent-900/20 hover:bg-accent-100 dark:hover:bg-accent-900/30 rounded-xl transition-all duration-300 group ring-1 ring-accent-100 dark:ring-accent-900/50 hover:shadow-md"
                >
                  <div class="w-12 h-12 rounded-lg bg-accent-600 text-white flex items-center justify-center text-2xl shadow-lg transition-transform group-hover:scale-110">🛍️</div>
                  <div>
                    <p class="font-bold text-gray-900 dark:text-white">Catálogo</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">Editar productos/precios</p>
                  </div>
                </router-link>

                <router-link
                  to="/reportes"
                  class="flex items-center gap-4 p-4 bg-purple-50 dark:bg-purple-900/20 hover:bg-purple-100 dark:hover:bg-purple-900/30 rounded-xl transition-all duration-300 group ring-1 ring-purple-100 dark:ring-purple-900/50 hover:shadow-md"
                >
                  <div class="w-12 h-12 rounded-lg bg-purple-600 text-white flex items-center justify-center text-2xl shadow-lg transition-transform group-hover:scale-110">📈</div>
                  <div>
                    <p class="font-bold text-gray-900 dark:text-white">Estadísticas</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">Ver historial y cierres</p>
                  </div>
                </router-link>
              </div>
            </div>
          </div>

          <!-- Alerts/Stock Sidebar -->
          <div class="space-y-6">
            <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-sm border border-gray-100 dark:border-gray-700 overflow-hidden flex flex-col h-full">
              <div class="px-6 py-4 border-b border-gray-50 dark:border-gray-700/50 bg-gray-50/50 dark:bg-gray-800/50 flex items-center justify-between">
                 <h2 class="text-md font-bold text-gray-900 dark:text-white flex items-center gap-2">
                  ⚠️ Alertas de Reposición
                </h2>
              </div>
              
              <div class="flex-1 p-0">
                 <div v-if="productosConStockBajo.length === 0" class="flex flex-col items-center justify-center py-12 px-6 text-center">
                    <div class="w-16 h-16 bg-green-100 dark:bg-green-900/20 rounded-full flex items-center justify-center text-2xl mb-3">✅</div>
                    <p class="text-sm font-bold text-gray-800 dark:text-white">¡Todo al día!</p>
                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">No hay productos agotándose.</p>
                 </div>
                 
                 <ul v-else class="divide-y divide-gray-50 dark:divide-gray-700/50 max-h-[400px] overflow-auto">
                    <li v-for="producto in productosConStockBajo" :key="producto.id" class="p-4 hover:bg-gray-50 dark:hover:bg-gray-700/30 transition-colors">
                      <div class="flex justify-between items-start mb-1">
                        <p class="text-sm font-bold text-gray-900 dark:text-white truncate pr-2">{{ producto.nombre }}</p>
                        <span class="text-[10px] font-bold px-1.5 py-0.5 rounded bg-red-100 dark:bg-red-900/30 text-red-700">Stock Crítico</span>
                      </div>
                      <div class="flex items-center justify-between">
                         <p class="text-xs text-gray-500 dark:text-gray-400">Disponibilidad en barra</p>
                         <p class="text-sm font-mono font-bold text-red-600">{{ producto.stock_actual }} / {{ producto.stock_minimo }}</p>
                      </div>
                      <!-- ProgressBar simulation -->
                      <div class="mt-2 w-full h-1.5 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
                         <div class="h-full bg-red-500 rounded-full" :style="{ width: `${(producto.stock_actual / producto.stock_minimo) * 100}%` }"></div>
                      </div>
                    </li>
                 </ul>
              </div>
              
              <div v-if="productosConStockBajo.length > 0" class="p-4 border-t border-gray-50 dark:border-gray-700/50">
                 <router-link 
                   to="/inventario" 
                   class="w-full inline-flex items-center justify-center px-4 py-2 bg-gray-900 dark:bg-white dark:text-gray-900 text-white text-xs font-bold rounded-xl hover:opacity-90 transition-opacity"
                 >
                   Gestionar Inventario →
                 </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { storeToRefs } from 'pinia'
import AppLayout from '@/components/layout/AppLayout.vue'
import KPICard from '@/components/dashboard/KPICard.vue'
import AIInsights from '@/components/dashboard/AIInsights.vue'
import { useProductosStore } from '@/stores/productos'
import { useVentasStore } from '@/stores/ventas'
import { formatCurrency } from '@/utils/formatters'

const productosStore = useProductosStore()
const ventasStore = useVentasStore()

const { productosConStockBajo, productosActivos } = storeToRefs(productosStore)
const loading = ref(true)

const totalProductos = computed(() => productosActivos.value.length)
const productosStockBajo = computed(() => productosConStockBajo.value.length)
const ventasHoy = computed(() => ventasStore.totalVentasHoy)
const totalRecaudado = computed(() => ventasStore.totalRecaudadoHoy)

onMounted(async () => {
  loading.value = true
  try {
    const promises = []
    if (productosStore.productos.length === 0) {
      promises.push(productosStore.fetchProductos())
    }
    if (productosStore.categorias.length === 0) {
      promises.push(productosStore.fetchCategorias())
    }
    promises.push(ventasStore.fetchVentasHoy())
    await Promise.all(promises)
  } catch (error) {
    console.error('Error loading dashboard data:', error)
  } finally {
    loading.value = false
  }
})
</script>
