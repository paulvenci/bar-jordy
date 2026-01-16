<template>
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50" @click.self="$emit('close')">
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
      <!-- Header -->
      <div class="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-4">
        <h2 class="text-xl font-bold flex items-center gap-2">
          🍽️ Mesa {{ mesaNumber }}
        </h2>
        <p class="text-blue-100 text-sm mt-1">Selecciona o agrega un cliente</p>
      </div>

      <!-- Clientes existentes -->
      <div class="p-4 max-h-64 overflow-y-auto">
        <div v-if="loading" class="text-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p class="text-gray-500 mt-2">Cargando...</p>
        </div>

        <div v-else-if="clientes.length === 0" class="text-center py-8 text-gray-500">
          <span class="text-4xl block mb-2">👥</span>
          <p>No hay clientes en esta mesa</p>
          <p class="text-sm">Agrega el primer cliente abajo</p>
        </div>

        <div v-else class="space-y-2">
          <button
            v-for="cliente in clientes"
            :key="cliente.ventaId"
            @click="selectClient(cliente)"
            class="w-full p-3 rounded-xl border-2 border-gray-200 dark:border-gray-600 hover:border-blue-500 hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-all flex items-center justify-between group"
          >
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center text-blue-600 font-bold">
                {{ getInitials(cliente.nombre) }}
              </div>
              <div class="text-left">
                <p class="font-medium text-gray-800 dark:text-white">{{ cliente.nombre }}</p>
                <p class="text-xs text-gray-500">{{ cliente.itemCount }} productos</p>
              </div>
            </div>
            <div class="text-right">
              <p class="font-bold text-gray-800 dark:text-white">${{ cliente.total.toLocaleString() }}</p>
              <span class="text-xs text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity">Seleccionar →</span>
            </div>
          </button>
        </div>
      </div>

      <!-- Agregar nuevo cliente -->
      <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50">
        <div class="flex gap-2">
          <input
            v-model="nuevoCliente"
            @keyup.enter="addNewClient"
            type="text"
            placeholder="Nombre del cliente..."
            class="flex-1 px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 dark:bg-gray-700 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            autofocus
          />
          <button
            @click="addNewClient"
            :disabled="!nuevoCliente.trim()"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            ➕ Agregar
          </button>
        </div>
      </div>

      <!-- Footer -->
      <div class="p-4 border-t border-gray-200 dark:border-gray-700 flex justify-end">
        <button
          @click="$emit('close')"
          class="px-4 py-2 text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-white transition-colors"
        >
          Cancelar
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { usePOSStore } from '@/stores/pos'

interface Cliente {
  nombre: string
  ventaId: string
  total: number
  itemCount: number
}

const props = defineProps<{
  mesaId: string
  mesaNumber: number
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'select', cliente: Cliente | null, isNew: boolean): void
}>()

const posStore = usePOSStore()
const loading = ref(true)
const clientes = ref<Cliente[]>([])
const nuevoCliente = ref('')

onMounted(async () => {
  clientes.value = await posStore.getClientesMesa(props.mesaId)
  loading.value = false
})

const getInitials = (name: string) => {
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const selectClient = (cliente: Cliente) => {
  emit('select', cliente, false)
}

const addNewClient = () => {
  if (!nuevoCliente.value.trim()) return
  emit('select', { nombre: nuevoCliente.value.trim(), ventaId: '', total: 0, itemCount: 0 }, true)
}
</script>
