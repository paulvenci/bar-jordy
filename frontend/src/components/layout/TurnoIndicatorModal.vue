<template>
  <div class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center z-[100] p-4 animate-in fade-in duration-300">
    <div 
      class="bg-slate-900 border border-slate-800 rounded-3xl shadow-2xl max-w-md w-full overflow-hidden animate-in zoom-in-95 duration-300"
      @click.stop
    >
      <div class="p-6 border-b border-slate-800 flex justify-between items-center">
        <h2 class="text-xl font-black text-white uppercase tracking-tighter">
          Finalizar Turno
        </h2>
        <button @click="$emit('close')" class="text-slate-500 hover:text-white transition-colors">
          ✕
        </button>
      </div>

      <div class="p-6 space-y-6">
        <!-- Loading State -->
        <div v-if="loadingResumen" class="py-12 text-center">
          <div class="w-12 h-12 border-4 border-primary-500/20 border-t-primary-500 rounded-full animate-spin mx-auto mb-4"></div>
          <p class="text-slate-400 font-bold animate-pulse uppercase text-[10px] tracking-widest">Calculando Resumen...</p>
        </div>

        <!-- Content -->
        <template v-else>
          <div class="grid grid-cols-2 gap-3">
            <div class="bg-slate-950/50 p-4 rounded-2xl border border-slate-800">
              <p class="text-[10px] font-black text-slate-500 uppercase mb-1">Efectivo</p>
              <p class="text-lg font-black text-green-400">{{ formatCurrency(resumen.total_efectivo) }}</p>
            </div>
            <div class="bg-slate-950/50 p-4 rounded-2xl border border-slate-800">
              <p class="text-[10px] font-black text-slate-500 uppercase mb-1">Tarjeta</p>
              <p class="text-lg font-black text-blue-400">{{ formatCurrency(resumen.total_tarjeta) }}</p>
            </div>
            <div class="bg-slate-950/50 p-4 rounded-2xl border border-slate-800">
              <p class="text-[10px] font-black text-slate-500 uppercase mb-1">Transferencia</p>
              <p class="text-lg font-black text-purple-400">{{ formatCurrency(resumen.total_transferencia) }}</p>
            </div>
            <div class="bg-slate-950/50 p-4 rounded-2xl border border-slate-800">
              <p class="text-[10px] font-black text-slate-500 uppercase mb-1">Crédito</p>
              <p class="text-lg font-black text-orange-400">{{ formatCurrency(resumen.total_credito) }}</p>
            </div>
          </div>

          <div class="bg-primary-600/10 p-5 rounded-2xl border border-primary-500/20 flex justify-between items-center">
            <div>
              <p class="text-[10px] font-black text-primary-400 uppercase">Total Recaudado</p>
              <p class="text-sm text-slate-400">{{ resumen.cantidad_ventas }} ventas realizadas</p>
            </div>
            <p class="text-3xl font-black text-white tracking-tighter">{{ formatCurrency(resumen.total_general) }}</p>
          </div>

          <div class="space-y-2">
            <label class="text-[10px] font-black text-slate-500 uppercase px-1">Observaciones Finales</label>
            <textarea
              v-model="observaciones"
              rows="3"
              class="w-full bg-slate-950 border border-slate-800 rounded-2xl p-4 text-white text-sm focus:ring-2 focus:ring-primary-500/50 outline-none transition-all resize-none"
              placeholder="¿Alguna novedad relevante en el turno?"
            ></textarea>
          </div>
        </template>
      </div>

      <div class="p-6 bg-slate-950/50 flex gap-3">
        <button
          @click="$emit('close')"
          class="flex-1 py-4 text-slate-400 font-black uppercase text-[10px] tracking-widest hover:text-white transition-all"
        >
          Cancelar
        </button>
        <button
          @click="confirmarCierreTurno"
          :disabled="turnoStore.loading"
          class="flex-[2] py-4 bg-red-600 hover:bg-red-500 disabled:opacity-50 text-white font-black uppercase text-[10px] tracking-widest rounded-2xl shadow-lg shadow-red-950/50 transition-all"
        >
          {{ turnoStore.loading ? 'Cerrando...' : 'Confirmar Cierre y Salir' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useTurnoStore } from '@/stores/turno'
import { formatCurrency } from '@/utils/formatters'

const emit = defineEmits(['close'])
const turnoStore = useTurnoStore()

const loadingResumen = ref(true)
const observaciones = ref('')
const resumen = ref({
  total_efectivo: 0,
  total_tarjeta: 0,
  total_transferencia: 0,
  total_credito: 0,
  cantidad_ventas: 0,
  total_general: 0
})

onMounted(async () => {
  resumen.value = await turnoStore.calcularResumenTurno()
  loadingResumen.value = false
})

const confirmarCierreTurno = async () => {
  const result = await turnoStore.cerrarTurno(observaciones.value)
  if (result.success) {
    emit('close')
    alert('Turno finalizado correctamente. ¡Buen descanso!')
  } else {
    alert('Error al cerrar turno: ' + result.error)
  }
}
</script>
