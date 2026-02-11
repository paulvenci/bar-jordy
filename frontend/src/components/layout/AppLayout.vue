<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950 transition-colors duration-500">
    <AppHeader />
    <AppSidebar />
    <main 
      class="pt-16 px-2 pb-2 md:pt-20 md:px-8 md:pb-8 min-h-screen transition-all duration-300 ease-in-out"
      :class="uiStore.isSidebarCollapsed ? 'md:ml-20' : 'md:ml-64'"
    >
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
import AppHeader from './AppHeader.vue'
import AppSidebar from './AppSidebar.vue'
import { useUIStore } from '@/stores/ui'

const uiStore = useUIStore()
</script>
