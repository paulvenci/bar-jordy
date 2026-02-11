<template>
  <Transition name="fade">
    <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <!-- Backdrop -->
      <div class="absolute inset-0 bg-slate-900/80 backdrop-blur-sm" @click="close"></div>

      <!-- Chat Window -->
      <div class="relative w-full max-w-md bg-slate-900 text-white rounded-3xl shadow-2xl border border-slate-700 overflow-hidden flex flex-col h-[600px]">
        
        <!-- Header -->
        <div class="p-4 border-b border-slate-800 bg-slate-950 flex justify-between items-center">
          <div class="flex items-center gap-3">
             <div class="w-10 h-10 bg-primary-600 rounded-xl flex items-center justify-center text-xl shadow-lg shadow-primary-900/50">
               🤖
             </div>
             <div>
               <h3 class="font-bold text-lg">Asistente Gordy</h3>
               <p class="text-xs text-slate-400 flex items-center gap-1">
                 <span class="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse"></span>
                 En línea
               </p>
             </div>
          </div>
          <div class="flex items-center gap-2">
            <button @click="toggleConfig" class="text-slate-400 hover:text-white transition-colors p-2" title="Configurar IA">
              ⚙️
            </button>
            <button @click="close" class="text-slate-400 hover:text-white transition-colors p-2">
              ✕
            </button>
          </div>
        </div>

        <!-- Config Area -->
        <div v-if="isConfigOpen" class="bg-slate-950 p-4 border-b border-slate-800 animate-in slide-in-from-top-2">
            <label class="block text-xs text-slate-400 mb-1">API Key (Groq o Gemini)</label>
            <div class="flex gap-2">
                <input 
                    v-model="apiKeyInput"
                    type="password"
                    placeholder="Pegar API Key aquí..."
                    class="flex-1 bg-slate-900 border border-slate-700 rounded-lg px-3 py-1.5 text-xs text-white focus:border-primary-500 outline-none"
                />
                <button @click="saveApiKey" class="bg-primary-600 hover:bg-primary-500 text-white px-3 py-1.5 rounded-lg text-xs">
                    Guardar
                </button>
            </div>
            <p class="text-[10px] text-slate-500 mt-1">
                Recomendado: <a href="https://console.groq.com/keys" target="_blank" class="text-primary-400 hover:underline">Groq (gratis)</a> · También soporta <a href="https://aistudio.google.com/app/apikey" target="_blank" class="text-primary-400 hover:underline">Gemini</a>.
            </p>
        </div>

        <!-- Messages Area -->
        <div ref="messagesContainer" class="flex-1 overflow-y-auto p-4 space-y-4 bg-slate-900/50">
          <div v-if="messages.length === 0" class="text-center py-10 opacity-50">
             <p class="text-4xl mb-4">👋</p>
             <p class="text-sm">¡Hola! Pregúntame sobre ventas o stock.</p>
          </div>

          <div v-for="(msg, idx) in messages" :key="idx" 
               class="flex flex-col gap-1"
               :class="msg.role === 'user' ? 'items-end' : 'items-start'"
          >
             <div 
               class="max-w-[85%] px-4 py-2.5 rounded-2xl text-sm leading-relaxed whitespace-pre-line"
               :class="[
                 msg.role === 'user' 
                   ? 'bg-primary-600 text-white rounded-br-none shadow-lg shadow-primary-900/20' 
                   : 'bg-slate-800 text-slate-200 rounded-bl-none border border-slate-700'
               ]"
             >
               <!-- Markdown-like bold parsing simple -->
               <span v-html="parseMessage(msg.text)"></span>
             </div>
             <span class="text-[10px] text-slate-500 px-1">{{ msg.time }}</span>
          </div>

          <div v-if="isTyping" class="flex items-center gap-2 text-slate-500 text-xs px-4">
             <span class="w-1.5 h-1.5 bg-slate-500 rounded-full animate-bounce"></span>
             <span class="w-1.5 h-1.5 bg-slate-500 rounded-full animate-bounce delay-100"></span>
             <span class="w-1.5 h-1.5 bg-slate-500 rounded-full animate-bounce delay-200"></span>
          </div>
        </div>

        <!-- Input Area -->
        <div class="p-4 bg-slate-950 border-t border-slate-800">
           <form @submit.prevent="sendMessage" class="flex gap-2">
             <input 
               v-model="newMessage"
               ref="inputRef"
               type="text" 
               placeholder="Escribe tu pregunta..." 
               class="flex-1 bg-slate-900 border border-slate-700 rounded-xl px-4 py-3 text-sm focus:outline-none focus:border-primary-500 focus:ring-1 focus:ring-primary-500 transition-all text-white placeholder-slate-600"
             />
             <button 
               type="submit"
               :disabled="!newMessage.trim() || isTyping"
               class="bg-primary-600 hover:bg-primary-500 disabled:opacity-50 disabled:cursor-not-allowed text-white px-4 rounded-xl transition-all flex items-center justify-center"
             >
               Paper Plane Icon
               <span class="text-xl">➤</span>
             </button>
           </form>
           <div class="mt-3 flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
              <button @click="quickAsk('¿Cuánto vendí hoy?')" class="whitespace-nowrap px-3 py-1.5 bg-slate-800 hover:bg-slate-700 rounded-lg text-xs text-slate-300 transition-colors border border-slate-700">
                💰 Ventas hoy
              </button>
              <button @click="quickAsk('Producto más vendido')" class="whitespace-nowrap px-3 py-1.5 bg-slate-800 hover:bg-slate-700 rounded-lg text-xs text-slate-300 transition-colors border border-slate-700">
                🔥 Top producto
              </button>
              <button @click="quickAsk('¿Stock bajo?')" class="whitespace-nowrap px-3 py-1.5 bg-slate-800 hover:bg-slate-700 rounded-lg text-xs text-slate-300 transition-colors border border-slate-700">
                ⚠️ Stock crítico
              </button>
           </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup lang="ts">
import { ref, nextTick, watch } from 'vue'
import { useAIEngine } from '@/utils/ai-insights/engine'

const props = defineProps<{
  isOpen: boolean
}>()

const emit = defineEmits(['close'])

const newMessage = ref('')
const messages = ref<{role: 'user' | 'assistant', text: string, time: string}[]>([])
const isTyping = ref(false)
const isConfigOpen = ref(false)
const apiKeyInput = ref('')
const messagesContainer = ref<HTMLElement | null>(null)
const inputRef = ref<HTMLInputElement | null>(null)

const engine = useAIEngine()

watch(() => props.isOpen, (val) => {
  if (val) {
     nextTick(() => inputRef.value?.focus())
     if (messages.value.length === 0) {
        // Initial greeting
         messages.value.push({
           role: 'assistant',
           text: '¡Hola! Soy el asistente inteligente de tu bar. Puedo responder preguntas sobre tus ventas y stock en tiempo real. ¿En qué te ayudo?',
           time: getCurrentTime()
         })
     }
  }
})

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

const getCurrentTime = () => {
  return new Date().toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })
}

const parseMessage = (text: string) => {
  // Simple bold parser
  return text.replace(/\*\*(.*?)\*\*/g, '<b>$1</b>').replace(/\n/g, '<br>')
}

const close = () => {
  emit('close')
}

const toggleConfig = () => {
    isConfigOpen.value = !isConfigOpen.value
}

const saveApiKey = () => {
    engine.setApiKey(apiKeyInput.value)
    isConfigOpen.value = false
    // Notify user?
    messages.value.push({
        role: 'assistant',
        text: '✅ API Key guardada. Ahora soy más inteligente gracias a Gemini.',
        time: getCurrentTime()
    })
    scrollToBottom()
}

const quickAsk = (text: string) => {
  newMessage.value = text
  sendMessage()
}

const sendMessage = async () => {
  if (!newMessage.value.trim()) return

  const text = newMessage.value
  newMessage.value = ''

  // User message
  messages.value.push({ role: 'user', text, time: getCurrentTime() })
  scrollToBottom()

  isTyping.value = true

  // Simulate AI delay -> Engine is async now
  // We can just await it directly, but maybe keep a small artificial delay if it's too fast?
  // Or just trust the async.
  
  try {
      const response = await engine.processQuery(text)
      messages.value.push({ 
        role: 'assistant', 
        text: response.text, 
        time: getCurrentTime() 
      })
  } catch (e) {
      messages.value.push({ 
        role: 'assistant', 
        text: '❌ Hubo un error al procesar tu mensaje.', 
        time: getCurrentTime() 
      })
  } finally {
      isTyping.value = false
      scrollToBottom()
  }
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
