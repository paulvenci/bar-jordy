<template>
  <div class="bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
    <!-- Tabla -->
    <div class="overflow-x-auto">
      <table class="w-full divide-y divide-gray-200 dark:divide-gray-700 table-fixed">
        <thead class="bg-gray-50 dark:bg-gray-700">
          <tr>
            <th scope="col" class="w-[35%] px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-600" @click="toggleSort('nombre')">
              Producto
              <span v-if="sortField === 'nombre'" class="ml-1">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th scope="col" class="w-[10%] px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-600" @click="toggleSort('codigo')">
              Código
              <span v-if="sortField === 'codigo'" class="ml-1">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th scope="col" class="w-[12%] px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Categoría
            </th>
            <th scope="col" class="w-[8%] px-4 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Tipo
            </th>
            <th scope="col" class="w-[10%] px-4 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-600" @click="toggleSort('valor_venta')">
              Precio
              <span v-if="sortField === 'valor_venta'" class="ml-1">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th scope="col" class="w-[8%] px-4 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-600" @click="toggleSort('stock_actual')">
              Stock
              <span v-if="sortField === 'stock_actual'" class="ml-1">{{ sortDir === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th scope="col" class="w-[17%] px-4 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
              Acciones
            </th>
          </tr>
        </thead>
        <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
          <tr v-if="loading" class="animate-pulse">
            <td colspan="7" class="px-4 py-4 text-center text-sm text-gray-500 dark:text-gray-400">
              Cargando productos...
            </td>
          </tr>
          <tr v-else-if="paginatedProducts.length === 0">
            <td colspan="7" class="px-4 py-4 text-center text-sm text-gray-500 dark:text-gray-400">
              No se encontraron productos.
            </td>
          </tr>
          <tr v-for="product in paginatedProducts" :key="product.id" class="hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
            <td class="px-4 py-3">
              <div class="flex items-center min-w-0">
                <div class="h-10 w-10 flex-shrink-0">
                  <img v-if="product.foto" class="h-10 w-10 rounded-full object-cover" :src="product.foto" alt="" />
                  <div v-else class="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-500">
                     📷
                  </div>
                </div>
                <div class="ml-3 min-w-0 flex-1">
                  <div class="text-sm font-medium text-gray-900 dark:text-white truncate" :title="product.nombre">{{ product.nombre }}</div>
                  <div v-if="product.descripcion" class="text-xs text-gray-500 dark:text-gray-400 truncate" :title="product.descripcion">
                    {{ product.descripcion }}
                  </div>
                </div>
              </div>
            </td>
            <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400 truncate" :title="product.codigo">
              {{ product.codigo }}
            </td>
            <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">
              <span v-if="product.categoria" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200 truncate max-w-full" :title="product.categoria.nombre">
                {{ product.categoria.nombre }}
              </span>
              <span v-else class="text-gray-400">-</span>
            </td>
            <td class="px-4 py-3 text-sm">
              <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full"
                :class="product.tipo_producto === 'SIMPLE' 
                  ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' 
                  : 'bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200'">
                {{ product.tipo_producto === 'SIMPLE' ? 'S' : 'C' }}
              </span>
            </td>
            <td class="px-4 py-3 text-sm text-right font-medium text-gray-900 dark:text-white">
              {{ formatCurrency(product.valor_venta) }}
            </td>
            <td class="px-4 py-3 text-sm text-right font-bold">
              <span :class="getStockClass(product)">
                {{ calculateProductStock(product) }}
              </span>
            </td>
            <td class="px-4 py-3 text-right text-sm font-medium">
              <button @click="$emit('edit', product)" class="text-primary-600 hover:text-primary-900 dark:text-primary-400 dark:hover:text-primary-300 mr-2">
                ✏️
              </button>
              <button @click="$emit('delete', product)" class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300">
                🗑️
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Paginación -->
    <div class="px-4 py-3 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between">
      <div class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
        <span>Mostrar:</span>
        <select v-model="pageSize" class="rounded border-gray-300 dark:border-gray-600 dark:bg-gray-700 text-sm py-1">
          <option :value="10">10</option>
          <option :value="25">25</option>
          <option :value="50">50</option>
          <option :value="100">100</option>
        </select>
        <span>de {{ sortedProducts.length }} productos</span>
      </div>
      
      <div class="flex items-center gap-1">
        <button 
          @click="currentPage = 1" 
          :disabled="currentPage === 1"
          class="px-2 py-1 rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 dark:hover:bg-gray-700"
        >
          ««
        </button>
        <button 
          @click="currentPage--" 
          :disabled="currentPage === 1"
          class="px-2 py-1 rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 dark:hover:bg-gray-700"
        >
          «
        </button>
        
        <span class="px-3 py-1 text-sm text-gray-600 dark:text-gray-400">
          {{ currentPage }} / {{ totalPages }}
        </span>
        
        <button 
          @click="currentPage++" 
          :disabled="currentPage === totalPages"
          class="px-2 py-1 rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 dark:hover:bg-gray-700"
        >
          »
        </button>
        <button 
          @click="currentPage = totalPages" 
          :disabled="currentPage === totalPages"
          class="px-2 py-1 rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 dark:hover:bg-gray-700"
        >
          »»
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { Producto, Categoria } from '@/types/database.types'
import { formatCurrency } from '@/utils/formatters'
import { calculateProductStock } from '@/utils/inventory'

const props = defineProps<{
  products: Producto[]
  categories: Categoria[]
  loading: boolean
}>()

defineEmits<{
  (e: 'edit', product: Producto): void
  (e: 'delete', product: Producto): void
  (e: 'toggle-status', product: Producto): void
}>()

// Ordenamiento
const sortField = ref<string>('nombre')
const sortDir = ref<'asc' | 'desc'>('asc')

const toggleSort = (field: string) => {
  if (sortField.value === field) {
    sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortField.value = field
    sortDir.value = 'asc'
  }
}

const sortedProducts = computed(() => {
  const sorted = [...props.products].sort((a, b) => {
    let valA = a[sortField.value as keyof Producto]
    let valB = b[sortField.value as keyof Producto]
    
    if (sortField.value === 'stock_actual') {
      valA = calculateProductStock(a)
      valB = calculateProductStock(b)
    }
    
    if (valA == null) return 1
    if (valB == null) return -1
    
    if (typeof valA === 'string') valA = valA.toLowerCase()
    if (typeof valB === 'string') valB = valB.toLowerCase()
    
    if (valA < valB) return sortDir.value === 'asc' ? -1 : 1
    if (valA > valB) return sortDir.value === 'asc' ? 1 : -1
    return 0
  })
  return sorted
})

// Paginación
const currentPage = ref(1)
const pageSize = ref(25)

const totalPages = computed(() => Math.max(1, Math.ceil(sortedProducts.value.length / pageSize.value)))

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return sortedProducts.value.slice(start, start + pageSize.value)
})

// Reset página cuando cambian los productos o el tamaño de página
watch([() => props.products, pageSize], () => {
  currentPage.value = 1
})

const getStockClass = (product: Producto) => {
  const stock = calculateProductStock(product)
  if (stock <= 0) return 'text-red-600'
  if (stock <= product.stock_minimo) return 'text-yellow-600'
  return 'text-gray-900 dark:text-white'
}
</script>
