import { useVentasStore } from '@/stores/ventas'
import { useProductosStore } from '@/stores/productos'
import { supabase } from '@/lib/supabase'
import { formatCurrency } from '@/utils/formatters'
import { generateGeminiResponse } from '@/services/gemini'
import { generateGroqResponse } from '@/services/groq'

export interface Insight {
    icon: string
    title: string
    description: string
    tag: string
    priority: 'high' | 'medium' | 'low'
}

export interface AIResponse {
    text: string
    data?: any
    type: 'text' | 'chart' | 'list'
}

export const useAIEngine = () => {
    const ventasStore = useVentasStore()
    const productosStore = useProductosStore()

    // --- Helper Functions ---

    const getTopSellingProducts = (limit: number = 1) => {
        const itemMap = new Map<string, { count: number, name: string }>()

        ventasStore.ventasHoy.forEach(venta => {
            if (venta.estado === 'COMPLETADA' && venta.items) {
                venta.items.forEach(item => {
                    const id = item.producto_id
                    const current = itemMap.get(id) || { count: 0, name: item.nombre_producto || 'Producto' }
                    current.count += item.cantidad
                    itemMap.set(id, current)
                })
            }
        })

        const sorted = Array.from(itemMap.values()).sort((a, b) => b.count - a.count)
        return sorted.slice(0, limit)
    }

    const getLowStockProducts = () => {
        return productosStore.productos
            .filter(p => p.activo && p.stock_actual <= p.stock_minimo)
            .sort((a, b) => a.stock_actual - b.stock_actual)
            .slice(0, 5) // Top 5 critical
    }

    const getSalesStats = () => {
        // Usar los getters del store si están disponibles, o calcular manual
        const revenue = ventasStore.totalRecaudadoHoy
        const count = ventasStore.totalVentasHoy
        return { revenue, count }
    }

    // Profit metrics: ganancia, margen, producto más/menos rentable
    const getProfitMetrics = () => {
        const todaySales = ventasStore.ventasHoy.filter(v => v.estado === 'COMPLETADA' && v.items)
        if (todaySales.length === 0) return null

        let totalRevenue = 0
        let totalCost = 0
        const productMargins = new Map<string, { revenue: number, cost: number, qty: number }>()

        for (const venta of todaySales) {
            for (const item of venta.items!) {
                totalRevenue += item.precio_unitario * item.cantidad
                totalCost += item.costo * item.cantidad
                const entry = productMargins.get(item.nombre_producto) || { revenue: 0, cost: 0, qty: 0 }
                entry.revenue += item.precio_unitario * item.cantidad
                entry.cost += item.costo * item.cantidad
                entry.qty += item.cantidad
                productMargins.set(item.nombre_producto, entry)
            }
        }

        const totalProfit = totalRevenue - totalCost
        const marginPct = totalRevenue > 0 ? Math.round((totalProfit / totalRevenue) * 100) : 0

        // Best/worst margin products
        const productList = Array.from(productMargins.entries())
            .map(([name, { revenue, cost, qty }]) => ({
                name, profit: revenue - cost,
                margin: revenue > 0 ? Math.round(((revenue - cost) / revenue) * 100) : 0,
                qty
            }))
            .filter(p => p.qty >= 2) // at least 2 units sold

        const bestMargin = [...productList].sort((a, b) => b.margin - a.margin).slice(0, 3)
        const worstMargin = [...productList].sort((a, b) => a.margin - b.margin).slice(0, 3)
        const topProfit = [...productList].sort((a, b) => b.profit - a.profit).slice(0, 3)

        return {
            totalProfit,
            marginPct,
            bestMargin: bestMargin.map(p => `${p.name} (${p.margin}% margen, ${formatCurrency(p.profit)} ganancia)`).join(', '),
            worstMargin: worstMargin.map(p => `${p.name} (${p.margin}% margen)`).join(', '),
            topProfit: topProfit.map(p => `${p.name} (${formatCurrency(p.profit)})`).join(', ')
        }
    }

    // Average ticket size
    const getAverageTicket = () => {
        const completed = ventasStore.ventasHoy.filter(v => v.estado === 'COMPLETADA')
        if (completed.length === 0) return 0
        const total = completed.reduce((sum, v) => sum + v.total, 0)
        return Math.round(total / completed.length)
    }

    // Peak hours distribution
    const getPeakHours = () => {
        const todaySales = getTodayLocalSales()
        if (todaySales.length === 0) return 'Sin ventas aún.'

        const hourMap = new Map<number, { count: number, revenue: number }>()
        for (const sale of todaySales) {
            const hour = new Date(sale.fecha).getHours()
            const entry = hourMap.get(hour) || { count: 0, revenue: 0 }
            entry.count++
            entry.revenue += sale.total
            hourMap.set(hour, entry)
        }

        return Array.from(hourMap.entries())
            .sort((a, b) => a[0] - b[0])
            .map(([hour, { count, revenue }]) => `${hour}:00-${hour + 1}:00 → ${count} ventas, ${formatCurrency(revenue)}`)
            .join('\n                ')
    }

    // Payment method breakdown
    const getPaymentBreakdown = () => {
        const completed = ventasStore.ventasHoy.filter(v => v.estado === 'COMPLETADA')
        if (completed.length === 0) return 'Sin ventas.'

        const methods = new Map<string, { count: number, revenue: number }>()
        for (const sale of completed) {
            const method = sale.metodo_pago || 'SIN ESPECIFICAR'
            const entry = methods.get(method) || { count: 0, revenue: 0 }
            entry.count++
            entry.revenue += sale.total
            methods.set(method, entry)
        }

        const total = completed.length
        return Array.from(methods.entries())
            .sort((a, b) => b[1].revenue - a[1].revenue)
            .map(([method, { count, revenue }]) => `${method}: ${count} ventas (${Math.round(count / total * 100)}%), ${formatCurrency(revenue)}`)
            .join('\n                ')
    }

    // Cancelled/voided sales info
    const getCancelledSalesInfo = () => {
        const cancelled = ventasStore.ventasHoy.filter(v => v.estado === 'CANCELADA' || v.estado === 'ANULADA' as any)
        if (cancelled.length === 0) return 'Ninguna venta anulada hoy.'

        const totalLost = cancelled.reduce((sum, v) => sum + v.total, 0)
        return `${cancelled.length} ventas anuladas hoy por un total de ${formatCurrency(totalLost)}.`
    }

    // Catalog overview
    const getCatalogInfo = () => {
        const productos = productosStore.productos
        const activos = productos.filter(p => p.activo)
        const totalStock = activos.reduce((sum, p) => sum + p.stock_actual, 0)
        return `${activos.length} productos activos, ${totalStock} unidades en inventario total.`
    }

    // --- Main Insight Generation ---

    const generateDashboardInsights = (): Insight[] => {
        const topProduct = getTopSellingProducts(1)[0]
        const lowStock = getLowStockProducts()
        const { revenue, count } = getSalesStats()

        const insights: Insight[] = []

        // 1. Ritmo de Ventas
        if (count > 0) {
            insights.push({
                icon: '💰',
                title: 'Ritmo de Ventas',
                description: `Hoy llevas ${count} ventas por un total de ${formatCurrency(revenue)}.`,
                tag: 'Finanzas',
                priority: revenue > 100000 ? 'high' : 'medium'
            })
        } else {
            insights.push({
                icon: '💤',
                title: 'Sin Movimiento',
                description: 'Aún no hay ventas registradas hoy. ¡Es hora de activar el local!',
                tag: 'Estado',
                priority: 'low'
            })
        }

        // 2. Producto Estrella
        if (topProduct) {
            insights.push({
                icon: '🔥',
                title: 'Producto Estrella',
                description: `"${topProduct.name}" lidera hoy con ${topProduct.count} unidades vendidas.`,
                tag: 'Tendencia',
                priority: 'high'
            })
        }

        // 3. Alerta de Stock
        if (lowStock.length > 0) {
            const names = lowStock.slice(0, 2).map(p => p.nombre).join(', ')
            const more = lowStock.length > 2 ? ` y ${lowStock.length - 2} más` : ''
            insights.push({
                icon: '⚠️',
                title: 'Stock Crítico',
                description: `Quedan pocas unidades de: ${names}${more}. Revisa el inventario.`,
                tag: 'Inventario',
                priority: 'high'
            })
        } else {
            insights.push({
                icon: '✅',
                title: 'Salud de Inventario',
                description: 'Todos tus productos tienen stock suficiente por ahora.',
                tag: 'Inventario',
                priority: 'low'
            })
        }

        // 4. Proyección Horaria (Estimación simple)
        const hour = new Date().getHours()
        let prediction = ''
        if (hour < 12) prediction = 'Se espera mayor flujo a partir de las 13:00 hrs (Almuerzo).'
        else if (hour < 19) prediction = 'Prepárate para el Happy Hour a partir de las 19:00 hrs.'
        else if (hour < 23) prediction = 'Cierre de día aproximándose. Revisa stock para mañana.'
        else prediction = 'Jornada finalizada. Buen trabajo.'

        insights.push({
            icon: '🔮',
            title: 'Proyección',
            description: prediction,
            tag: 'Futuro',
            priority: 'medium'
        })

        return insights
    }


    // Helper: Get only today's sales in LOCAL timezone, sorted chronologically
    const getTodayLocalSales = () => {
        const now = new Date()
        const todayLocal = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`

        return ventasStore.ventasHoy
            .filter(v => {
                if (v.estado !== 'COMPLETADA') return false
                // Convert stored date to local date and compare
                const saleDate = new Date(v.fecha)
                const saleLocalDate = `${saleDate.getFullYear()}-${String(saleDate.getMonth() + 1).padStart(2, '0')}-${String(saleDate.getDate()).padStart(2, '0')}`
                return saleLocalDate === todayLocal
            })
            .sort((a, b) => new Date(a.fecha).getTime() - new Date(b.fecha).getTime()) // Sort by actual time
    }

    // Helper: Format a date to local time HH:MM
    const toLocalTime = (fecha: string) => {
        const d = new Date(fecha)
        return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
    }

    const getSalesDetails = () => {
        const ventas = getTodayLocalSales()
        if (ventas.length === 0) return null
        return { first: ventas[0], last: ventas[ventas.length - 1] }
    }

    const getRecentSalesLog = (limit: number = 30) => {
        const ventas = getTodayLocalSales()
        if (ventas.length === 0) return 'Sin ventas.'

        return ventas.slice(0, limit).map((v, i) => {
            const time = toLocalTime(v.fecha)
            const items = v.items?.map(it => `${it.cantidad}x ${it.nombre_producto}`).join(', ') || 'Varios'
            return `${i + 1}. [${time}] $${v.total} (${items})`
        }).join('\n                ')
    }

    // Get today's top sellers from ventasStore
    const getTopSellersToday = async (): Promise<string> => {
        try {
            const now = new Date()
            const todayStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
            const startOfDay = new Date(`${todayStr}T00:00:00`).toISOString()
            const endOfDay = new Date(`${todayStr}T23:59:59`).toISOString()

            const { data, error } = await supabase
                .from('ventas')
                .select('total, vendedor:usuarios!ventas_vendedor_id_fkey(nombre)')
                .gte('fecha', startOfDay)
                .lte('fecha', endOfDay)
                .eq('estado', 'COMPLETADA')

            if (error || !data || data.length === 0) return 'Sin datos de vendedores hoy.'

            const sellers = new Map<string, { count: number, revenue: number }>()
            for (const sale of data) {
                const sellerName = (Array.isArray(sale.vendedor) ? sale.vendedor[0]?.nombre : (sale.vendedor as any)?.nombre) || 'Sin asignar'
                const entry = sellers.get(sellerName) || { count: 0, revenue: 0 }
                entry.count++
                entry.revenue += sale.total
                sellers.set(sellerName, entry)
            }

            return Array.from(sellers.entries())
                .sort((a, b) => b[1].revenue - a[1].revenue)
                .map(([name, { count, revenue }], i) => `${i + 1}. ${name}: ${count} ventas, ${formatCurrency(revenue)}`)
                .join('\n                ')
        } catch (err) {
            return 'Error al obtener vendedores.'
        }
    }

    // Fetch historical data from Supabase (last 6 months) — monthly + day-of-week + sellers
    const getHistoricalSummary = async (): Promise<{ monthly: string, byDayOfWeek: string, sellers: string }> => {
        const empty = { monthly: 'Sin datos históricos disponibles.', byDayOfWeek: 'Sin datos.', sellers: 'Sin datos.' }
        try {
            const now = new Date()
            const sixMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 6, 1)
            const startDate = sixMonthsAgo.toISOString()

            const { data, error } = await supabase
                .from('ventas')
                .select('fecha, total, vendedor:usuarios!ventas_vendedor_id_fkey(nombre), items:items_venta(nombre_producto, cantidad)')
                .gte('fecha', startDate)
                .eq('estado', 'COMPLETADA')
                .order('fecha', { ascending: true })

            if (error || !data || data.length === 0) return empty

            // --- Monthly grouping with products ---
            const monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
            const months = new Map<string, {
                count: number,
                revenue: number,
                products: Map<string, number>
            }>()

            // --- Day-of-week grouping ---
            const dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
            const dayStats = new Map<string, { totalRevenue: number, totalCount: number, daysSet: Set<string> }>()
            for (const name of dayNames) {
                dayStats.set(name, { totalRevenue: 0, totalCount: 0, daysSet: new Set() })
            }

            // --- Seller aggregation (overall) ---
            const sellerStats = new Map<string, { count: number, revenue: number }>()

            for (const sale of data) {
                const d = new Date(sale.fecha)

                // Monthly
                const monthKey = `${monthNames[d.getMonth()]} ${d.getFullYear()}`
                const mEntry = months.get(monthKey) || { count: 0, revenue: 0, products: new Map() }
                mEntry.count++
                mEntry.revenue += sale.total
                if (sale.items && Array.isArray(sale.items)) {
                    for (const item of sale.items) {
                        const current = mEntry.products.get(item.nombre_producto) || 0
                        mEntry.products.set(item.nombre_producto, current + item.cantidad)
                    }
                }
                months.set(monthKey, mEntry)

                // Day of week
                const dayName = dayNames[d.getDay()]
                const dEntry = dayStats.get(dayName)!
                dEntry.totalRevenue += sale.total
                dEntry.totalCount++
                dEntry.daysSet.add(d.toDateString())

                // Seller
                const sellerName = (Array.isArray(sale.vendedor) ? sale.vendedor[0]?.nombre : (sale.vendedor as any)?.nombre) || 'Sin asignar'
                const sEntry = sellerStats.get(sellerName) || { count: 0, revenue: 0 }
                sEntry.count++
                sEntry.revenue += sale.total
                sellerStats.set(sellerName, sEntry)
            }

            // Format monthly
            const monthly = Array.from(months.entries())
                .map(([month, { count, revenue, products }]) => {
                    const topProducts = Array.from(products.entries())
                        .sort((a, b) => b[1] - a[1])
                        .map(([name, qty], i) => `  ${i + 1}. ${name} (${qty} un.)`)
                        .join('\n                ')
                    return `- ${month}: ${count} ventas, ${formatCurrency(revenue)}\n                  Productos vendidos:\n                ${topProducts}`
                })
                .join('\n                ')

            // Format day-of-week averages
            const byDayOfWeek = dayNames
                .map(dayName => {
                    const d = dayStats.get(dayName)!
                    if (d.daysSet.size === 0) return `- ${dayName}: Sin datos`
                    const avgRevenue = Math.round(d.totalRevenue / d.daysSet.size)
                    const avgCount = Math.round(d.totalCount / d.daysSet.size)
                    return `- ${dayName}: promedio ${avgCount} ventas, ${formatCurrency(avgRevenue)} (basado en ${d.daysSet.size} días)`
                })
                .join('\n                ')

            // Format sellers ranking (overall)
            const sellers = Array.from(sellerStats.entries())
                .sort((a, b) => b[1].revenue - a[1].revenue)
                .map(([name, { count, revenue }], i) => `${i + 1}. ${name}: ${count} ventas, ${formatCurrency(revenue)}`)
                .join('\n                ')

            return { monthly, byDayOfWeek, sellers }
        } catch (err) {
            console.error('Error fetching historical data:', err)
            return empty
        }
    }

    const getApiKey = () => localStorage.getItem('gemini_api_key')?.replace(/["']/g, '').trim()
    const setApiKey = (key: string) => localStorage.setItem('gemini_api_key', key)

    // --- Chat Logic ---
    const processQuery = async (query: string): Promise<AIResponse> => {
        // Normalize: Lowercase and limit accents (e.g. vendí -> vendi)
        // Also fix common typos: hot -> hoy
        const q = query.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/\bhot\b/g, 'hoy')
        const apiKey = getApiKey()
        const queryWords = q.split(' ').length

        // Greeting (always local, fast)
        if (q.includes('hola') || q.includes('buenas')) {
            return { text: '¡Hola! Soy tu asistente de Bar Gordy. Pregúntame sobre ventas, productos o stock.', type: 'text' }
        }

        // Capabilities (always local)
        if (q.includes('puedes hacer') || q.includes('ayuda')) {
            return {
                text: 'Puedo analizar tus datos en tiempo real. Intenta preguntar:\n- "¿Cuánto vendí hoy?"\n- "¿Cuál es el producto más vendido?"\n- "¿Cómo está el stock?"',
                type: 'text'
            }
        }

        // AI-FIRST GATE: If we have an API key and the query is complex (>4 words),
        // skip local keyword matching entirely and let AI handle it.
        // This prevents keywords like "vendido" from incorrectly triggering local intents.
        const useAIForComplexQuery = apiKey && queryWords > 4

        if (!useAIForComplexQuery) {
            // --- LOCAL INTENTS (only for simple, direct queries) ---

            // Intent: Top Product
            if (q.includes('mejor') || q.includes('mas vendido') || q.includes('top') || q.includes('rank') || q.includes('popul') || q.includes('estrella')) {
                const topProducts = getTopSellingProducts(3)
                if (topProducts.length > 0) {
                    const list = topProducts.map((p, i) => `${i + 1}. **${p.name}** (${p.count} un.)`).join('\n')
                    return {
                        text: `🏆 **Top 3 Productos de hoy:**\n${list}`,
                        type: 'text'
                    }
                } else {
                    return { text: 'Aún no hay suficientes ventas hoy para generar un ranking.', type: 'text' }
                }
            }

            // Intent: Specific Sales Details (First/Last)
            if (q.includes('primera') || q.includes('ultima') || q.includes('ultimo') || q.includes('primer')) {
                const details = getSalesDetails()
                if (!details) return { text: 'Aún no hay ventas registradas hoy.', type: 'text' }

                if (q.includes('primera') || q.includes('primer')) {
                    const time = toLocalTime(details.first!.fecha)
                    return {
                        text: `🥇 La **primera venta** fue a las ${time} hrs por ${formatCurrency(details.first!.total)}.`,
                        type: 'text'
                    }
                }
                if (q.includes('ultima') || q.includes('ultimo')) {
                    const time = toLocalTime(details.last!.fecha)
                    return {
                        text: `🕒 La **última venta** fue a las ${time} hrs por ${formatCurrency(details.last!.total)}.`,
                        type: 'text'
                    }
                }
            }

            // Intent: Sales / Finanzas
            if (q.includes('vendi') || q.includes('venta') || q.includes('ganancia') || q.includes('plata') || q.includes('caja') || q.includes('recaudado')) {
                const { revenue, count } = getSalesStats()
                return {
                    text: `Hoy has realizado **${count} ventas**, recaudando un total de **${formatCurrency(revenue)}**.`,
                    type: 'text'
                }
            }

            // Intent: Stock
            if (q.includes('stock') || q.includes('falta') || q.includes('poco') || q.includes('inventario') || q.includes('quedan')) {
                const low = getLowStockProducts()
                if (low.length > 0) {
                    const list = low.map(p => `• ${p.nombre} (${p.stock_actual} unid.)`).join('\n')
                    return {
                        text: `⚠️ **Atención**: Encontré ${low.length} productos con stock bajo:\n${list}`,
                        type: 'text'
                    }
                }
                return { text: '✅ El inventario está saludable. No hay alertas de stock crítico.', type: 'text' }
            }
        }

        // Default -> Try AI (Groq first, then Gemini)
        if (apiKey) {
            const { revenue, count } = getSalesStats()
            const top = getTopSellingProducts(3).map(p => `${p.name} (${p.count})`).join(', ')
            const low = getLowStockProducts().map(p => `${p.nombre} (${p.stock_actual})`).join(', ')
            const recentLog = getRecentSalesLog(30)
            const sellersToday = await getTopSellersToday()
            const historico = await getHistoricalSummary()

            // New metrics
            const profit = getProfitMetrics()
            const avgTicket = getAverageTicket()
            const peakHours = getPeakHours()
            const paymentMethods = getPaymentBreakdown()
            const cancelledInfo = getCancelledSalesInfo()
            const catalogInfo = getCatalogInfo()

            const dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
            const now = new Date()
            const tomorrow = new Date(now)
            tomorrow.setDate(tomorrow.getDate() + 1)
            const tomorrowDay = dayNames[tomorrow.getDay()]

            const profitSection = profit ? `
                RENTABILIDAD HOY:
                - Ganancia bruta: ${formatCurrency(profit.totalProfit)} (margen del ${profit.marginPct}%)
                - Productos más rentables (por margen %): ${profit.bestMargin || 'N/A'}
                - Productos menos rentables (por margen %): ${profit.worstMargin || 'N/A'}
                - Productos que más ganancia generan ($): ${profit.topProfit || 'N/A'}
            ` : `
                RENTABILIDAD HOY: Sin datos aún.
            `

            const context = `
                FECHA ACTUAL: ${now.toLocaleDateString('es-CL', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}.
                Hora actual: ${now.toLocaleTimeString('es-CL')}.
                MAÑANA ES: ${tomorrowDay}.

                === MÉTRICAS DEL DÍA (HOY) ===

                RESUMEN: ${count} ventas por ${formatCurrency(revenue)}.
                TICKET PROMEDIO: ${formatCurrency(avgTicket)}.

                RANKING DE PRODUCTOS HOY (por unidades):
                ${top || 'Sin ventas aún'}.

                VENDEDORES HOY (ranking por recaudación):
                ${sellersToday}
                ${profitSection}
                DISTRIBUCIÓN POR HORA (horarios pico):
                ${peakHours}

                MÉTODOS DE PAGO HOY:
                ${paymentMethods}

                VENTAS ANULADAS: ${cancelledInfo}

                STOCK BAJO (productos en riesgo de agotarse):
                ${low || 'Ninguno'}.

                CATÁLOGO: ${catalogInfo}

                LOG DE VENTAS DE HOY (cronológico, Venta #1 = primera del día):
                ${recentLog}

                === DATOS HISTÓRICOS (últimos 6 meses) ===

                PROMEDIOS POR DÍA DE LA SEMANA:
                ${historico.byDayOfWeek}

                RANKING DE VENDEDORES ACUMULADO:
                ${historico.sellers}

                DETALLE MENSUAL (ventas, ingresos y productos por mes):
                ${historico.monthly}
            `

            try {
                // Try Groq first (free, fast, no regional restrictions)
                const groqText = await generateGroqResponse(apiKey, query, context)
                if (groqText) {
                    return { text: groqText, type: 'text' }
                }
                // Fallback to Gemini
                const geminiText = await generateGeminiResponse(apiKey, query, context)
                if (geminiText) {
                    return { text: geminiText, type: 'text' }
                }
                return {
                    text: '⚠️ **La IA no respondió.**\nPosibles causas:\n- API Key inválida.\n- Cuota excedida.\n- Error de conexión.',
                    type: 'text'
                }
            } catch (error) {
                return { text: `❌ **Error de IA**: ${error}`, type: 'text' }
            }
        }

        return {
            text: '🤔 No estoy seguro de entender esa pregunta. Intenta preguntarme sobre **ventas**, **productos** o **stock**. (Si tienes una API Key de Gemini, agrégala para que sea más inteligente).',
            type: 'text'
        }
    }

    return {
        generateDashboardInsights,
        processQuery,
        setApiKey,
        getApiKey
    }
}
