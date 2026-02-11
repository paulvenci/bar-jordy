<template>
  <AppLayout>
    <div class="h-full flex flex-col">
      <!-- Header -->
      <div class="flex justify-between items-center mb-6">
        <div>
          <h1 class="text-xl font-bold text-gray-800 dark:text-white flex items-center gap-2">
            🍽️ Gestión de Mesas
          </h1>
          <p class="text-gray-500 dark:text-gray-400 mt-1">Selecciona una mesa para tomar pedido</p>
        </div>
        
        <div class="flex gap-2">
            <div class="flex items-center gap-2 px-3 py-1 bg-white dark:bg-gray-800 rounded-lg shadow text-sm">
                <div class="w-4 h-4 rounded-full bg-green-500"></div>
                <span>Libre</span>
            </div>
             <div class="flex items-center gap-2 px-3 py-1 bg-white dark:bg-gray-800 rounded-lg shadow text-sm">
                <div class="w-4 h-4 rounded-full bg-red-500"></div>
                <span>Ocupada</span>
            </div>
            <button 
                @click="refreshTables" 
                class="p-2 bg-primary-100 text-primary-600 rounded-lg hover:bg-primary-200 transition-colors"
                title="Actualizar"
            >
                🔄
            </button>
        </div>
      </div>

      <!-- Grid de Mesas -->
      <div v-if="loading" class="flex-1 flex justify-center items-center">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
      
      <div v-else class="grid grid-cols-2md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
        <div 
            v-for="mesa in sortedTables" 
            :key="mesa.id"
            @click="handleTableClick(mesa)"
            class="relative group cursor-pointer transition-all duration-300 transform hover:scale-105"
        >
            <!-- Badge de clientes -->
            <div 
                v-if="(clientesPorMesa[mesa.id] ?? 0) > 0" 
                class="absolute -top-2 -right-2 bg-blue-600 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold z-10 shadow-lg"
            >
                {{ clientesPorMesa[mesa.id] ?? 0 }}
            </div>
            
            <div 
                class="aspect-square rounded-2xl shadow-md border-4 flex flex-col items-center justify-center p-4"
                :class="mesa.estado === 'LIBRE' 
                    ? 'bg-white dark:bg-gray-800 border-green-500 hover:shadow-green-500/30' 
                    : 'bg-red-50 dark:bg-red-900/20 border-red-500 hover:shadow-red-500/30'"
            >
                <div class="text-4xl mb-2">{{ getTableIcon(mesa.capacidad) }}</div>
                <h3 class="text-2xl font-bold text-gray-800 dark:text-white">Mesa {{ mesa.numero }}</h3>
                <p class="text-gray-500 dark:text-gray-400 text-sm mb-2">Capacidad: {{ mesa.capacidad }}p</p>
                
                <div v-if="mesa.estado === 'OCUPADA'" class="mt-2 px-3 py-1 bg-red-100 text-red-700 rounded-full text-xs font-bold uppercase tracking-wide">
                    {{ clientesPorMesa[mesa.id] || 0 }} cliente{{ clientesPorMesa[mesa.id] !== 1 ? 's' : '' }}
                </div>
                <div v-else class="mt-2 px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold uppercase tracking-wide">
                    Libre
                </div>
            </div>
        </div>
      </div>
    </div>

    <!-- Modal de Clientes -->
    <ClientesMesaModal
      v-if="showClientModal && selectedMesa"
      :mesa-id="selectedMesa.id"
      :mesa-number="selectedMesa.numero"
      @close="showClientModal = false"
      @select="handleClientSelect"
    />
  </AppLayout>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import AppLayout from '@/components/layout/AppLayout.vue'
import ClientesMesaModal from '@/components/modules/pos/ClientesMesaModal.vue'
import { useTablesStore } from '@/stores/tables'
import { usePOSStore } from '@/stores/pos'
import type { Mesa } from '@/types/database.types'

interface ClienteInfo {
  nombre: string
  ventaId: string
  total: number
  itemCount: number
}

const router = useRouter()
const tablesStore = useTablesStore()
const posStore = usePOSStore()
const { sortedTables, loading } = storeToRefs(tablesStore)

const showClientModal = ref(false)
const selectedMesa = ref<Mesa | null>(null)
const clientesPorMesa = reactive<Record<string, number>>({})

onMounted(async () => {
    await tablesStore.fetchTables()
    await loadClientCounts()
})

const loadClientCounts = async () => {
    for (const mesa of tablesStore.tables) {
        if (mesa.estado === 'OCUPADA') {
            const clientes = await posStore.getClientesMesa(mesa.id)
            clientesPorMesa[mesa.id] = clientes.length
        }
    }
}

const refreshTables = async () => {
    await tablesStore.fetchTables()
    await loadClientCounts()
}

const getTableIcon = (capacidad: number) => {
    if (capacidad <= 2) return '☕'
    if (capacidad <= 4) return '🍔'
    return '🍻'
}

const handleTableClick = async (mesa: Mesa) => {
    selectedMesa.value = mesa
    showClientModal.value = true
}

const handleClientSelect = async (cliente: ClienteInfo | null, isNew: boolean) => {
    if (!selectedMesa.value) return
    
    showClientModal.value = false
    
    // Configurar mesa y cliente activos
    posStore.setActiveTable(selectedMesa.value.id, selectedMesa.value.numero, cliente?.nombre || null)
    
    if (!isNew && cliente?.ventaId) {
        // Cliente existente - cargar su pedido
        posStore.setActiveClient(cliente.nombre, cliente.ventaId)
        await posStore.loadClientOrder(cliente.ventaId)
    } else if (isNew && cliente) {
        // Nuevo cliente - solo establecer nombre
        posStore.setActiveClient(cliente.nombre, null)
    }
    
    // Navegar al POS
    router.push('/pos')
}
</script>

