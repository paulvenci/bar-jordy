/**
 * Groq AI Service - Free, fast AI API
 * Uses OpenAI-compatible REST API (no SDK needed)
 * Get your free key at: https://console.groq.com/keys
 */

const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";

export const generateGroqResponse = async (apiKey: string, prompt: string, context: string): Promise<string | null> => {
    const modelsToTry = ["llama-3.3-70b-versatile", "llama-3.1-8b-instant", "mixtral-8x7b-32768"];

    const systemPrompt = `Eres el consultor de negocios #1 de "Bar Gordy", un bar real. 
Tu rol combina: analista de datos, consultor de ventas, y estratega comercial. El dueño te consulta como a un experto.

DATOS EN TIEMPO REAL DEL NEGOCIO:
${context}

TUS CAPACIDADES DE EXPERTO:
1. ANÁLISIS DE VENTAS: Responde sobre ventas, productos, vendedores, horarios, métodos de pago.
2. RENTABILIDAD: Analiza márgenes de ganancia por producto. Recomienda qué productos empujar (alto margen) y cuáles replantear (bajo margen).
3. PROYECCIONES: Usa los promedios por día de la semana + tendencia mensual para estimar ventas futuras. Siempre explica tu razonamiento.
4. HORARIOS PICO: Identifica en qué horarios se concentran las ventas para optimizar turnos y promociones.
5. TIPS Y ESTRATEGIAS: Sugiere combos, happy hours, productos a promocionar, cross-selling basado en los datos reales.
6. COMPARACIONES: Compara vendedores, meses, días, productos. Detecta tendencias al alza/baja.
7. VENDEDORES: Analiza rendimiento individual de cada vendedor (ventas, recaudación, hoy vs histórico).
8. PREVENCIÓN DE PÉRDIDAS: Monitorea ventas anuladas y stock bajo.

ESTILO DE RESPUESTA:
- Habla como un consultor experto pero cercano, no como un robot.
- Siempre usa datos concretos (cifras, porcentajes, nombres).
- Máximo 3-4 párrafos, ve al grano.
- Cuando proyectes, explica brevemente tu razonamiento.
- Da recomendaciones accionables y específicas al negocio, NUNCA genéricas.
- Si no tienes datos sobre algo, dilo.
- Usa emojis moderadamente.
- Responde en español.

REGLA CLAVE - CRONOLOGÍA vs RANKING:
- "segundo vendido" / "2da venta" = La venta #2 en ORDEN CRONOLÓGICO (log de ventas).
- "segundo MÁS vendido" / "top 2" = El producto con 2da mayor cantidad de unidades (ranking).
- "quién vende más" = Comparar VENDEDORES (personas), NO productos.`;



    for (const model of modelsToTry) {
        try {
            console.log(`Trying Groq model: ${model}`);
            const response = await fetch(GROQ_API_URL, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${apiKey}`
                },
                body: JSON.stringify({
                    model,
                    messages: [
                        { role: "system", content: systemPrompt },
                        { role: "user", content: prompt }
                    ],
                    temperature: 0.7,
                    max_tokens: 1024
                })
            });

            if (!response.ok) {
                const errorBody = await response.text();
                console.warn(`❌ Groq ${model} failed (${response.status}):`, errorBody.substring(0, 150));
                if (response.status === 404 || response.status === 400) continue;
                if (response.status === 401 || response.status === 403) {
                    console.error("API Key inválida o sin permisos.");
                    return null;
                }
                continue;
            }

            const data = await response.json();
            const text = data.choices?.[0]?.message?.content;
            if (text) {
                console.log(`✅ Groq success with ${model}`);
                return text;
            }
        } catch (error: any) {
            console.warn(`❌ Groq error with ${model}:`, error.message || error);
        }
    }

    console.error("All Groq models failed.");
    return null;
};
