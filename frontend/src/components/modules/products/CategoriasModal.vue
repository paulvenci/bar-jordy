<template>
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50" @click.self="$emit('close')">
    <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden">
      <!-- Header -->
      <div class="bg-gradient-to-r from-purple-600 to-purple-700 text-white p-4">
        <h2 class="text-xl font-bold">📂 Gestión de Categorías</h2>
        <p class="text-purple-100 text-sm mt-1">Crear, editar y eliminar categorías</p>
      </div>

      <!-- Nueva categoría -->
      <div class="p-4 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50">
        <div class="flex gap-2">
          <input
            v-model="nuevaCategoria"
            @keyup.enter="crearCategoria"
            type="text"
            placeholder="Nombre de nueva categoría..."
            class="flex-1 px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 dark:bg-gray-700 focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          />
          <button
            @click="crearCategoria"
            :disabled="!nuevaCategoria.trim() || saving"
            class="px-4 py-2 bg-purple-600 text-white rounded-lg font-medium hover:bg-purple-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            ➕ Agregar
          </button>
        </div>
      </div>

      <!-- Lista de categorías -->
      <div class="p-4 max-h-80 overflow-y-auto">
        <div v-if="loading" class="text-center py-8">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600 mx-auto"></div>
        </div>

        <div v-else-if="categorias.length === 0" class="text-center py-8 text-gray-500">
          <span class="text-4xl block mb-2">📁</span>
          <p>No hay categorías creadas</p>
        </div>

        <div v-else class="space-y-2">
          <div
            v-for="cat in categorias"
            :key="cat.id"
            class="flex items-center justify-between p-3 rounded-lg border border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 group"
          >
            <!-- Modo edición -->
            <div v-if="editandoId === cat.id" class="flex-1 flex items-center gap-2">
              <input
                v-model="editandoNombre"
                @keyup.enter="guardarEdicion(cat.id)"
                @keyup.escape="cancelarEdicion"
                type="text"
                class="flex-1 px-3 py-1 rounded border border-purple-400 dark:bg-gray-600 focus:ring-2 focus:ring-purple-500"
                autofocus
              />
              <button @click="guardarEdicion(cat.id)" class="text-green-600 hover:text-green-800">✓</button>
              <button @click="cancelarEdicion" class="text-gray-500 hover:text-gray-700">✕</button>
            </div>
            
            <!-- Modo normal -->
            <template v-else>
              <span class="font-medium text-gray-800 dark:text-white">{{ cat.nombre }}</span>
              <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                <button
                  @click="iniciarEdicion(cat)"
                  class="p-1 text-blue-600 hover:text-blue-800 rounded"
                  title="Editar"
                >
                  ✏️
                </button>
                <button
                  @click="eliminarCategoria(cat)"
                  class="p-1 text-red-600 hover:text-red-800 rounded"
                  title="Eliminar"
                >
                  🗑️
                </button>
              </div>
            </template>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="p-4 border-t border-gray-200 dark:border-gray-700 flex justify-end">
        <button
          @click="$emit('close')"
          class="px-4 py-2 bg-gray-200 dark:bg-gray-600 text-gray-700 dark:text-gray-200 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-500 transition-colors"
        >
          Cerrar
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useProductosStore } from '@/stores/productos'
import type { Categoria } from '@/types/database.types'
import { supabase } from '@/lib/supabase'

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'update'): void
}>()

const productosStore = useProductosStore()
const { categorias } = storeToRefs(productosStore)

const loading = ref(false)
const saving = ref(false)
const nuevaCategoria = ref('')
const editandoId = ref<string | null>(null)
const editandoNombre = ref('')

onMounted(async () => {
  loading.value = true
  await productosStore.fetchCategorias()
  loading.value = false
})

const crearCategoria = async () => {
  if (!nuevaCategoria.value.trim()) return
  
  saving.value = true
  try {
    const { error } = await supabase
      .from('categorias')
      .insert({ nombre: nuevaCategoria.value.trim() })
    
    if (error) throw error
    
    nuevaCategoria.value = ''
    await productosStore.fetchCategorias()
    emit('update')
  } catch (err: any) {
    alert('Error al crear categoría: ' + err.message)
  } finally {
    saving.value = false
  }
}

const iniciarEdicion = (cat: Categoria) => {
  editandoId.value = cat.id
  editandoNombre.value = cat.nombre
}

const cancelarEdicion = () => {
  editandoId.value = null
  editandoNombre.value = ''
}

const guardarEdicion = async (id: string) => {
  if (!editandoNombre.value.trim()) return
  
  try {
    const { error } = await supabase
      .from('categorias')
      .update({ nombre: editandoNombre.value.trim() })
      .eq('id', id)
    
    if (error) throw error
    
    cancelarEdicion()
    await productosStore.fetchCategorias()
    emit('update')
  } catch (err: any) {
    alert('Error al actualizar categoría: ' + err.message)
  }
}

const eliminarCategoria = async (cat: Categoria) => {
  if (!confirm(`¿Eliminar la categoría "${cat.nombre}"? Los productos de esta categoría quedarán sin categoría.`)) return
  
  try {
    const { error } = await supabase
      .from('categorias')
      .delete()
      .eq('id', cat.id)
    
    if (error) throw error
    
    await productosStore.fetchCategorias()
    emit('update')
  } catch (err: any) {
    alert('Error al eliminar categoría: ' + err.message)
  }
}
</script>
