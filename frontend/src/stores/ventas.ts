import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import type { Venta } from '@/types/database.types'

interface VentasState {
    ventasHoy: Venta[]
    loading: boolean
}

export const useVentasStore = defineStore('ventas', {
    state: (): VentasState => ({
        ventasHoy: [],
        loading: false
    }),

    getters: {
        totalVentasHoy: (state) => state.ventasHoy.length,

        gananciaHoy: (state) => {
            return state.ventasHoy.reduce((total, venta) => {
                if (venta.estado === 'COMPLETADA' && venta.items) {
                    const gananciaVenta = venta.items.reduce((sum, item) => {
                        const gananciaItem = (item.precio_unitario - item.costo) * item.cantidad
                        return sum + gananciaItem
                    }, 0)
                    return total + gananciaVenta
                }
                return total
            }, 0)
        },

        totalRecaudadoHoy: (state) => {
            return state.ventasHoy
                .filter(v => v.estado === 'COMPLETADA')
                .reduce((sum, v) => sum + v.total, 0)
        }
    },

    actions: {
        async fetchVentasHoy() {
            this.loading = true
            try {
                const now = new Date()
                // Build local date boundaries and convert to UTC for Supabase
                const year = now.getFullYear()
                const month = String(now.getMonth() + 1).padStart(2, '0')
                const day = String(now.getDate()).padStart(2, '0')
                const todayStr = `${year}-${month}-${day}`

                // Convert local midnight/end-of-day to UTC
                const startOfDay = new Date(`${todayStr}T00:00:00`).toISOString()
                const endOfDay = new Date(`${todayStr}T23:59:59`).toISOString()

                const { data, error } = await supabase
                    .from('ventas')
                    .select(`
            *,
            items:items_venta(*)
          `)
                    .gte('fecha', startOfDay)
                    .lte('fecha', endOfDay)
                    .eq('estado', 'COMPLETADA')

                if (error) throw error
                this.ventasHoy = data || []
            } catch (err) {
                console.error('Error al cargar ventas de hoy:', err)
            } finally {
                this.loading = false
            }
        }
    }
})
