<template>
  <AppLayout>
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
       <div class="flex items-center gap-3 mb-6">
         <span class="text-3xl">💰</span>
         <h1 class="text-xl font-bold text-gray-900 dark:text-white">Cierre de Caja</h1>
       </div>
       
       <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
         <CashRegisterCloseReport />
       </div>
    </div>
  </AppLayout>
</template>

<script setup lang="ts">
import AppLayout from '@/components/layout/AppLayout.vue'
import CashRegisterCloseReport from '@/components/reports/CashRegisterCloseReport.vue'
</script>
