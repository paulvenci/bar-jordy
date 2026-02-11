<template>
  <div class="bg-slate-900 border border-slate-800 rounded-3xl p-6 shadow-2xl relative overflow-hidden group">
    <!-- Pulse decoration -->
    <div class="absolute -top-10 -right-10 w-40 h-40 bg-primary-600/10 rounded-full blur-3xl group-hover:bg-primary-600/20 transition-all duration-700"></div>

    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-3">
        <div class="w-12 h-12 bg-primary-600/20 rounded-2xl flex items-center justify-center text-2xl shadow-inner border border-primary-500/20">
          🧠
        </div>
        <div>
          <h2 class="text-xl font-black text-white uppercase tracking-tighter italic">Estrategia IA</h2>
          <p class="text-[10px] font-black text-slate-500 uppercase tracking-widest">Análisis predictivo de ventas</p>
        </div>
      </div>
      <div class="flex items-center gap-2 px-3 py-1 bg-slate-950 border border-slate-800 rounded-full">
        <span class="w-1.5 h-1.5 rounded-full bg-blue-500 animate-pulse"></span>
        <span class="text-[9px] font-black text-slate-400 uppercase tracking-widest">Motor Activo</span>
      </div>
    </div>

    <div v-if="loading" class="py-12 flex flex-col items-center justify-center space-y-4">
       <div class="w-10 h-10 border-2 border-slate-800 border-t-primary-500 rounded-full animate-spin"></div>
       <p class="text-[10px] font-black text-slate-500 uppercase tracking-widest animate-pulse">Procesando histórico...</p>
    </div>

    <div v-else class="space-y-6">
      <!-- Recommendations Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div v-for="(insight, index) in insights" :key="index" 
          class="p-5 bg-slate-950/50 rounded-2xl border border-slate-800 hover:border-slate-700 transition-all cursor-default group/card"
        >
          <div class="flex items-start gap-4">
            <div class="text-2xl mt-1 group-hover/card:scale-125 transition-transform duration-500">{{ insight.icon }}</div>
            <div class="space-y-1">
              <p class="text-xs font-black text-white uppercase tracking-tight">{{ insight.title }}</p>
              <p class="text-xs text-slate-400 leading-relaxed">{{ insight.description }}</p>
              <div class="pt-2 flex items-center gap-2">
                 <span class="text-[9px] font-black px-1.5 py-0.5 rounded bg-slate-800 text-primary-400 uppercase tracking-widest">{{ insight.tag }}</span>
                 <span v-if="insight.priority === 'high'" class="text-[9px] font-black px-1.5 py-0.5 rounded bg-red-500/10 text-red-500 uppercase tracking-widest">Prioridad Alta</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Actionable Tip / Chat Entry -->
      <div class="bg-primary-600 p-4 rounded-2xl flex items-center justify-between shadow-lg shadow-primary-900/30">
        <div class="flex items-center gap-3">
          <span class="text-2xl">🤖</span>
          <div>
             <p class="text-xs font-bold text-white leading-tight">Asistente Inteligente</p>
             <p class="text-[10px] text-primary-100 opacity-90">Pregúntame sobre ventas, stock o proyecciones.</p>
          </div>
        </div>
        <button 
          @click="showChat = true"
          class="bg-white/20 hover:bg-white/30 text-white px-3 py-2 rounded-xl transition-all flex items-center gap-2"
        >
          <span class="text-xs font-bold">Chatear</span>
          <span class="text-sm">→</span>
        </button>
      </div>
    </div>
    
    <AIChat :is-open="showChat" @close="showChat = false" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAIEngine, type Insight } from '@/utils/ai-insights/engine'
import AIChat from './AIChat.vue'

const engine = useAIEngine()

const loading = ref(true)
const insights = ref<Insight[]>([])
const showChat = ref(false)

onMounted(async () => {
  // Simular pequeña carga para efecto visual
  await new Promise(resolve => setTimeout(resolve, 800))
  
  insights.value = engine.generateDashboardInsights()
  loading.value = false
})
</script>
