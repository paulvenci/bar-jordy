import { defineStore } from 'pinia'
import type { Producto, ItemCarrito } from '@/types/database.types'
import { useConfiguracionStore } from './configuracion'

interface CartState {
    cart: ItemCarrito[]
    activeTableId: string | null
    activeTableNumber: number | null
    activeClientName: string | null
    activeVentaId: string | null
}

export const useCartStore = defineStore('cart', {
    state: (): CartState => ({
        cart: [],
        activeTableId: null,
        activeTableNumber: null,
        activeClientName: null,
        activeVentaId: null
    }),

    getters: {
        /**
         * Calcula totales del carrito
         * Asume que precio de venta incluye IVA
         * Net = Total / 1.19, IVA = Total - Net
         */
        cartTotals: (state) => {
            const configStore = useConfiguracionStore()
            const total = state.cart.reduce((sum, item) => sum + (item.precioUnitario * item.cantidad), 0)
            const ivaRate = configStore.porcentajeIVA / 100 || 0.19
            const neto = Math.round(total / (1 + ivaRate))
            const iva = total - neto

            return { neto, iva, total }
        },

        /**
         * Cantidad total de items en el carrito
         */
        itemCount: (state) => {
            return state.cart.reduce((count, item) => count + item.cantidad, 0)
        },

        /**
         * Verifica si hay una mesa activa
         */
        hasActiveTable: (state) => !!state.activeTableId,

        /**
         * Verifica si el carrito está vacío
         */
        isEmpty: (state) => state.cart.length === 0
    },

    actions: {
        /**
         * Establece la mesa activa
         */
        setActiveTable(id: string | null, number: number | null, clientName: string | null = null) {
            this.activeTableId = id
            this.activeTableNumber = number
            this.activeClientName = clientName
            this.activeVentaId = null
            if (id) {
                this.clearCart()
            }
        },

        /**
         * Establece el cliente activo
         */
        setActiveClient(clientName: string | null, ventaId: string | null = null) {
            this.activeClientName = clientName
            this.activeVentaId = ventaId
            this.clearCart()
        },

        /**
         * Agrega un producto al carrito
         */
        addToCart(product: Producto) {
            const existingItem = this.cart.find(item => item.productoId === product.id)

            if (existingItem) {
                existingItem.cantidad++
            } else {
                this.cart.push({
                    productoId: product.id,
                    nombre: product.nombre,
                    cantidad: 1,
                    precioUnitario: product.valor_venta,
                    costo: product.valor_costo,
                    stock: product.stock_actual,
                    foto: product.foto,
                    descripcion: product.descripcion
                })
            }
        },

        /**
         * Elimina un producto del carrito
         */
        removeFromCart(productId: string) {
            const index = this.cart.findIndex(item => item.productoId === productId)
            if (index > -1) {
                this.cart.splice(index, 1)
            }
        },

        /**
         * Actualiza la cantidad de un producto
         */
        updateQuantity(productId: string, quantity: number) {
            const item = this.cart.find(i => i.productoId === productId)
            if (item) {
                if (quantity > 0) {
                    item.cantidad = quantity
                } else {
                    this.removeFromCart(productId)
                }
            }
        },

        /**
         * Limpia el carrito
         */
        clearCart() {
            this.cart = []
        },

        /**
         * Carga items en el carrito (para órdenes pendientes)
         */
        loadItems(items: ItemCarrito[]) {
            this.cart = items
        },

        /**
         * Resetea todo el estado del carrito
         */
        reset() {
            this.cart = []
            this.activeTableId = null
            this.activeTableNumber = null
            this.activeClientName = null
            this.activeVentaId = null
        }
    }
})
