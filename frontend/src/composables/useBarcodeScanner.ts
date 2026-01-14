import { ref, watch, computed } from 'vue'

// Estado reactivo compartido globalmente
const isActive = ref(false)
const isPaused = ref(false)

// Cargar estado inicial desde localStorage
const savedState = localStorage.getItem('barcodeScannerActive')
if (savedState) {
    isActive.value = savedState === 'true'
}

// Guardar en localStorage cuando cambie
watch(isActive, (newValue) => {
    localStorage.setItem('barcodeScannerActive', newValue.toString())
})

export function useBarcodeScanner() {
    const toggle = () => {
        isActive.value = !isActive.value
    }

    const pause = () => {
        isPaused.value = true
    }

    const resume = () => {
        isPaused.value = false
    }

    // Estado efectivo: activo y no pausado
    const isEffectivelyActive = computed(() => isActive.value && !isPaused.value)

    return {
        isActive,
        isPaused,
        isEffectivelyActive,
        toggle,
        pause,
        resume
    }
}
