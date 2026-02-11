<template>
  <div class="h-full flex flex-col bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden">
    <!-- Header -->
    <div class="p-2 md:p-4 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900 flex justify-between items-center">
      <h3 class="font-bold text-sm md:text-lg text-gray-900 dark:text-white">Ticket</h3>
      <button 
        @click="$emit('clear')"
        class="text-xs text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 font-medium"
        v-if="cart.length > 0"
      >
        Limpiar Carrito
      </button>
    </div>

    <!-- Cart Items -->
    <div class="flex-1 overflow-y-auto p-2 space-y-2 pb-14 md:pb-4 scrollbar-thin">
      <div v-if="cart.length === 0" class="h-full flex flex-col items-center justify-center text-gray-400">
        <span class="text-2xl md:text-3xl mb-1">🛒</span>
        <p class="text-xs md:text-sm">Carrito vacío</p>
      </div>

      <div 
        v-for="item in cart" 
        :key="item.productoId"
        class="group flex items-center gap-2 p-2 bg-gray-50 dark:bg-gray-700/50 rounded-lg border border-gray-100 dark:border-gray-600 hover:border-blue-200 dark:hover:border-blue-700 transition-colors shadow-sm"
      >
        <!-- 1. Imagen Compacta (40px) -->
        <div class="h-10 w-10 flex-shrink-0 bg-gray-200 dark:bg-gray-600 rounded-md overflow-hidden border border-gray-200 dark:border-gray-500 relative">
            <img 
                v-if="item.foto" 
                :src="item.foto" 
                class="h-full w-full object-cover"
            />
            <div v-else class="h-full w-full flex items-center justify-center text-gray-400 text-lg">
                🍹
            </div>
        </div>

        <!-- 2. Info (Nombre + Precio Unitario) -->
        <div class="flex-1 min-w-0">
            <p class="text-xs md:text-sm font-bold text-gray-900 dark:text-white leading-tight truncate">
                {{ item.nombre }}
            </p>
            <p class="text-[10px] text-gray-500 dark:text-gray-400 mt-0.5">
                ${{ formatNumber(item.precioUnitario) }} c/u
            </p>
        </div>

        <!-- 3. Controles Cantidad Compactos -->
        <div class="flex items-center bg-white dark:bg-gray-800 rounded border border-gray-300 dark:border-gray-600 shadow-sm overflow-hidden h-7">
            <button 
                @click="$emit('update-quantity', item.productoId, item.cantidad - 1)"
                class="w-6 h-full flex items-center justify-center text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 font-bold active:bg-gray-200 transition-colors"
                :class="{'text-red-500 hover:bg-red-50': item.cantidad === 1}"
            >
                {{ item.cantidad === 1 ? '×' : '-' }}
            </button>
            <span class="w-6 text-center text-xs md:text-sm font-bold text-gray-900 dark:text-white select-none">{{ item.cantidad }}</span>
            <button 
                @click="$emit('update-quantity', item.productoId, item.cantidad + 1)"
                class="w-6 h-full flex items-center justify-center text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 font-bold active:bg-gray-200 transition-colors"
            >
                +
            </button>
        </div>

        <!-- 4. Total Item -->
        <div class="text-right min-w-[3.5rem]">
            <p class="text-sm font-bold text-gray-900 dark:text-white">
                ${{ formatNumber(item.precioUnitario * item.cantidad) }}
            </p>
        </div>

        <!-- 5. Delete (Hover only usually, but always visible for mobile/touch) -->
        <button 
            @click="$emit('remove', item.productoId)"
            class="text-gray-400 hover:text-red-500 p-1 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
        >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
        </button>
      </div>
    </div>

    <!-- Footer: Totals & Action -->
    <div class="p-2 md:p-4 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 space-y-1.5 md:space-y-3">
      <div class="grid grid-cols-2 gap-x-4 gap-y-0.5 text-[10px] md:text-sm text-gray-600 dark:text-gray-400">
        <div class="flex justify-between">
            <span>Neto:</span>
            <span>${{ formatNumber(totals.neto) }}</span>
        </div>
        <div class="flex justify-between">
            <span>IVA:</span>
            <span>${{ formatNumber(totals.iva) }}</span>
        </div>
      </div>
      
      <div class="flex justify-between text-sm md:text-xl font-bold text-gray-900 dark:text-white pt-1 md:pt-2 border-t border-gray-200 dark:border-gray-700">
          <span>Total</span>
          <span>${{ formatNumber(totals.total) }}</span>
      </div>

      <button
        @click="$emit('checkout')"
        :disabled="cart.length === 0"
        class="w-full py-2 md:py-3 px-3 md:px-4 bg-primary-600 hover:bg-primary-700 disabled:bg-gray-400 disabled:cursor-not-allowed text-white text-sm md:text-lg font-bold rounded-lg shadow transition-colors flex justify-center items-center gap-1.5 md:gap-2"
      >
        <span>💰</span> Cobrar ${{ formatNumber(totals.total) }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { ItemCarrito } from '@/types/database.types'

defineProps<{
  cart: ItemCarrito[]
  totals: { neto: number, iva: number, total: number }
}>()

defineEmits<{
  (e: 'update-quantity', id: string, quantity: number): void
  (e: 'remove', id: string): void
  (e: 'clear'): void
  (e: 'checkout'): void
}>()

const formatNumber = (num: number) => {
  return new Intl.NumberFormat('es-CL').format(num)
}
</script>
