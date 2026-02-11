<template>
  <div 
    class="premium-card relative overflow-hidden bg-white dark:bg-gray-800 rounded-2xl shadow-sm p-6 group"
    :class="[
      type === 'warning' ? 'border-l-4 border-yellow-500' : 
      type === 'success' ? 'border-l-4 border-green-500' : 
      type === 'danger' ? 'border-l-4 border-red-500' : 'border-l-4 border-primary-500'
    ]"
  >
    <!-- Background Decoration -->
    <div 
       class="absolute -right-4 -top-4 w-24 h-24 rounded-full opacity-5 transition-transform group-hover:scale-150 duration-700"
       :class="iconBgClass"
    ></div>

    <div class="relative z-10 flex items-center justify-between">
      <div class="flex-1">
        <p class="text-xs font-bold uppercase tracking-wider text-gray-500 dark:text-gray-400">
          {{ title }}
        </p>
        <p class="text-3xl font-extrabold mt-1 tracking-tight" :class="valueClass">
          {{ formattedValue }}
        </p>
        <p v-if="subtitle" class="text-xs text-gray-400 dark:text-gray-500 mt-1 font-medium italic">
          {{ subtitle }}
        </p>
      </div>
      
      <div 
        class="w-14 h-14 rounded-2xl flex items-center justify-center text-3xl shadow-inner transition-transform group-hover:rotate-12 duration-300"
        :class="iconContainerClass"
      >
        {{ icon }}
      </div>
    </div>
    
    <div v-if="alert" class="mt-4 pt-4 border-t border-gray-100 dark:border-gray-700/50">
      <div class="flex items-center gap-2 px-2 py-1 rounded-md bg-red-50 dark:bg-red-900/20">
        <span class="text-red-500 animate-pulse">●</span>
        <span class="text-xs font-bold text-red-600 dark:text-red-400">{{ alert }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  title: string
  value: number | string
  icon: string
  subtitle?: string
  alert?: string
  type?: 'default' | 'success' | 'warning' | 'danger'
  format?: 'number' | 'currency' | 'text'
}>()

const formattedValue = computed(() => {
  if (props.format === 'currency' && typeof props.value === 'number') {
    return new Intl.NumberFormat('es-CL', {
      style: 'currency',
      currency: 'CLP',
      minimumFractionDigits: 0
    }).format(props.value)
  }
  
  if (props.format === 'number' && typeof props.value === 'number') {
    return new Intl.NumberFormat('es-CL').format(props.value)
  }
  
  return props.value
})

const valueClass = computed(() => {
  switch (props.type) {
    case 'success': return 'text-green-600 dark:text-green-400'
    case 'warning': return 'text-yellow-600 dark:text-yellow-400'
    case 'danger': return 'text-red-600 dark:text-red-400'
    default: return 'text-gray-900 dark:text-white'
  }
})

const iconContainerClass = computed(() => {
  switch (props.type) {
    case 'success': return 'bg-green-50 dark:bg-green-900/20 text-green-600'
    case 'warning': return 'bg-yellow-50 dark:bg-yellow-900/20 text-yellow-600'
    case 'danger': return 'bg-red-50 dark:bg-red-900/20 text-red-600'
    default: return 'bg-primary-50 dark:bg-primary-900/20 text-primary-600'
  }
})

const iconBgClass = computed(() => {
  switch (props.type) {
    case 'success': return 'bg-green-500'
    case 'warning': return 'bg-yellow-500'
    case 'danger': return 'bg-red-500'
    default: return 'bg-primary-500'
  }
})
</script>
