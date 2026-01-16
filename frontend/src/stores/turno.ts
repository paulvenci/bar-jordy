import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import { useAuthStore } from './auth'

interface TurnoMesero {
    id: string
    usuario_id: string
    hora_inicio: string
    hora_fin: string | null
    total_efectivo: number
    total_tarjeta: number
    total_transferencia: number
    total_credito: number
    cantidad_ventas: number
    estado: 'ABIERTO' | 'CERRADO'
    observaciones: string | null
    usuario?: {
        nombre: string
    }
}

interface ResumenTurno {
    total_efectivo: number
    total_tarjeta: number
    total_transferencia: number
    total_credito: number
    cantidad_ventas: number
    total_general: number
}

interface TurnoState {
    turnoActivo: TurnoMesero | null
    loading: boolean
    error: string | null
}

export const useTurnoStore = defineStore('turno', {
    state: (): TurnoState => ({
        turnoActivo: null,
        loading: false,
        error: null
    }),

    getters: {
        tieneTurnoAbierto: (state) => !!state.turnoActivo,

        horaInicioFormateada: (state) => {
            if (!state.turnoActivo) return ''
            const fecha = new Date(state.turnoActivo.hora_inicio)
            return fecha.toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })
        },

        duracionTurno: (state) => {
            if (!state.turnoActivo) return ''
            const inicio = new Date(state.turnoActivo.hora_inicio)
            const ahora = new Date()
            const diffMs = ahora.getTime() - inicio.getTime()
            const horas = Math.floor(diffMs / (1000 * 60 * 60))
            const minutos = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60))
            return `${horas}h ${minutos}m`
        }
    },

    actions: {
        /**
         * Obtiene el turno activo del usuario actual
         */
        async fetchTurnoActivo() {
            const authStore = useAuthStore()
            if (!authStore.usuario?.id) return

            this.loading = true
            try {
                const { data, error } = await supabase
                    .from('turnos_mesero')
                    .select('*')
                    .eq('usuario_id', authStore.usuario.id)
                    .eq('estado', 'ABIERTO')
                    .maybeSingle()

                if (error) throw error
                this.turnoActivo = data
            } catch (err: any) {
                console.error('Error al obtener turno activo:', err)
                this.error = err.message
            } finally {
                this.loading = false
            }
        },

        /**
         * Inicia un nuevo turno para el usuario actual
         */
        async iniciarTurno(): Promise<{ success: boolean, error?: string }> {
            const authStore = useAuthStore()
            if (!authStore.usuario?.id) {
                return { success: false, error: 'Usuario no autenticado' }
            }

            // Verificar si ya tiene turno abierto
            if (this.turnoActivo) {
                return { success: false, error: 'Ya tienes un turno abierto' }
            }

            this.loading = true
            try {
                const { data, error } = await supabase
                    .from('turnos_mesero')
                    .insert({
                        usuario_id: authStore.usuario.id,
                        hora_inicio: new Date().toISOString(),
                        estado: 'ABIERTO'
                    })
                    .select()
                    .single()

                if (error) throw error
                this.turnoActivo = data
                return { success: true }
            } catch (err: any) {
                console.error('Error al iniciar turno:', err)
                this.error = err.message
                return { success: false, error: err.message }
            } finally {
                this.loading = false
            }
        },

        /**
         * Calcula el resumen de ventas del turno actual
         */
        async calcularResumenTurno(): Promise<ResumenTurno> {
            if (!this.turnoActivo) {
                return {
                    total_efectivo: 0,
                    total_tarjeta: 0,
                    total_transferencia: 0,
                    total_credito: 0,
                    cantidad_ventas: 0,
                    total_general: 0
                }
            }

            try {
                const { data: ventas, error } = await supabase
                    .from('ventas')
                    .select('total, metodo_pago')
                    .eq('turno_id', this.turnoActivo.id)
                    .eq('estado', 'COMPLETADA')

                if (error) throw error

                const resumen: ResumenTurno = {
                    total_efectivo: 0,
                    total_tarjeta: 0,
                    total_transferencia: 0,
                    total_credito: 0,
                    cantidad_ventas: ventas?.length || 0,
                    total_general: 0
                }

                for (const venta of ventas || []) {
                    const total = Number(venta.total) || 0
                    switch (venta.metodo_pago) {
                        case 'EFECTIVO':
                            resumen.total_efectivo += total
                            break
                        case 'TARJETA':
                            resumen.total_tarjeta += total
                            break
                        case 'TRANSFERENCIA':
                            resumen.total_transferencia += total
                            break
                        case 'CREDITO':
                            resumen.total_credito += total
                            break
                    }
                    resumen.total_general += total
                }

                return resumen
            } catch (err) {
                console.error('Error al calcular resumen:', err)
                return {
                    total_efectivo: 0,
                    total_tarjeta: 0,
                    total_transferencia: 0,
                    total_credito: 0,
                    cantidad_ventas: 0,
                    total_general: 0
                }
            }
        },

        /**
         * Cierra el turno actual
         */
        async cerrarTurno(observaciones?: string): Promise<{ success: boolean, resumen?: ResumenTurno, error?: string }> {
            if (!this.turnoActivo) {
                return { success: false, error: 'No hay turno abierto' }
            }

            this.loading = true
            try {
                // Calcular resumen antes de cerrar
                const resumen = await this.calcularResumenTurno()

                // Actualizar turno con totales y cerrar
                const { error } = await supabase
                    .from('turnos_mesero')
                    .update({
                        hora_fin: new Date().toISOString(),
                        total_efectivo: resumen.total_efectivo,
                        total_tarjeta: resumen.total_tarjeta,
                        total_transferencia: resumen.total_transferencia,
                        total_credito: resumen.total_credito,
                        cantidad_ventas: resumen.cantidad_ventas,
                        estado: 'CERRADO',
                        observaciones: observaciones || null
                    })
                    .eq('id', this.turnoActivo.id)

                if (error) throw error

                this.turnoActivo = null
                return { success: true, resumen }
            } catch (err: any) {
                console.error('Error al cerrar turno:', err)
                this.error = err.message
                return { success: false, error: err.message }
            } finally {
                this.loading = false
            }
        }
    }
})
