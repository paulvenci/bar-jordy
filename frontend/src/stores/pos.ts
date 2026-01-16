/**
 * POS Store - Composición
 * 
 * Este store actúa como fachada para mantener compatibilidad con el código existente.
 * Internamente delega a los stores especializados:
 * - cart.ts: Manejo del carrito
 * - order.ts: Manejo de órdenes (park, load, cancel)
 * - payment.ts: Procesamiento de pagos
 */
import { defineStore } from 'pinia'
import { useCartStore } from './cart'
import { useOrderStore } from './order'
import { usePaymentStore, type PaymentMethod } from './payment'
import type { Producto } from '@/types/database.types'

export const usePOSStore = defineStore('pos', {
    // Estado delegado a cart store
    state: () => ({
        // Mantenemos una referencia para compatibilidad
        // El estado real está en los stores especializados
    }),

    getters: {
        // Delegamos getters al cart store
        cart: () => {
            const cartStore = useCartStore()
            return cartStore.cart
        },
        cartTotals: () => {
            const cartStore = useCartStore()
            return cartStore.cartTotals
        },
        itemCount: () => {
            const cartStore = useCartStore()
            return cartStore.itemCount
        },
        activeTableId: () => {
            const cartStore = useCartStore()
            return cartStore.activeTableId
        },
        activeTableNumber: () => {
            const cartStore = useCartStore()
            return cartStore.activeTableNumber
        },
        activeClientName: () => {
            const cartStore = useCartStore()
            return cartStore.activeClientName
        },
        activeVentaId: () => {
            const cartStore = useCartStore()
            return cartStore.activeVentaId
        },
        loading: () => {
            const orderStore = useOrderStore()
            return orderStore.loading
        },
        processingSale: () => {
            const paymentStore = usePaymentStore()
            return paymentStore.processingSale
        },
        error: () => {
            const paymentStore = usePaymentStore()
            return paymentStore.error
        }
    },

    actions: {
        // === CART ACTIONS ===
        setActiveTable(id: string | null, number: number | null, clientName: string | null = null) {
            const cartStore = useCartStore()
            cartStore.setActiveTable(id, number, clientName)
        },

        setActiveClient(clientName: string | null, ventaId: string | null = null) {
            const cartStore = useCartStore()
            cartStore.setActiveClient(clientName, ventaId)
        },

        addToCart(product: Producto) {
            const cartStore = useCartStore()
            cartStore.addToCart(product)
        },

        removeFromCart(productId: string) {
            const cartStore = useCartStore()
            cartStore.removeFromCart(productId)
        },

        updateQuantity(productId: string, quantity: number) {
            const cartStore = useCartStore()
            cartStore.updateQuantity(productId, quantity)
        },

        clearCart() {
            const cartStore = useCartStore()
            cartStore.clearCart()
        },

        // === ORDER ACTIONS ===
        async getClientesMesa(mesaId: string) {
            const orderStore = useOrderStore()
            return orderStore.getClientesMesa(mesaId)
        },

        async loadOrder() {
            const orderStore = useOrderStore()
            return orderStore.loadOrder()
        },

        async loadClientOrder(ventaId: string) {
            const orderStore = useOrderStore()
            return orderStore.loadClientOrder(ventaId)
        },

        async parkOrder() {
            const orderStore = useOrderStore()
            return orderStore.parkOrder()
        },

        async cancelTableOrder() {
            const orderStore = useOrderStore()
            return orderStore.cancelTableOrder()
        },

        // === PAYMENT ACTIONS ===
        async processSale(paymentMethod: PaymentMethod, cliente?: string, discountAmount: number = 0) {
            const paymentStore = usePaymentStore()
            return paymentStore.processSale(paymentMethod, cliente, discountAmount)
        }
    }
})

// Re-exportar tipos para compatibilidad
export type { PaymentMethod }
