/**
 * Test script para verificar API Keys de Groq y Gemini
 * Ejecutar: node test_api.mjs TU_CLAVE_API
 */
const apiKey = process.argv[2];

if (!apiKey) {
    console.error("❌ Error: Debes ejecutarlo así:");
    console.error("node test_api.mjs TU_CLAVE_API_AQUI");
    process.exit(1);
}

console.log(`🔍 Probando clave: ${apiKey.substring(0, 10)}...`);

async function testGroq() {
    console.log("\n=== PROBANDO GROQ ===");
    const models = ["llama-3.3-70b-versatile", "llama-3.1-8b-instant", "mixtral-8x7b-32768"];

    for (const model of models) {
        try {
            console.log(`📡 Intentando Groq: ${model}...`);
            const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${apiKey}`
                },
                body: JSON.stringify({
                    model,
                    messages: [{ role: "user", content: "Di 'Hola Mundo'" }],
                    max_tokens: 50
                })
            });

            if (!response.ok) {
                const err = await response.text();
                console.error(`❌ Falló ${model} (${response.status}):`, err.substring(0, 120));
                continue;
            }

            const data = await response.json();
            const text = data.choices?.[0]?.message?.content;
            console.log(`✅ ¡ÉXITO! ${model} respondió: "${text?.trim()}"`);
            console.log("👉 Tu clave de Groq funciona correctamente.");
            return true;
        } catch (error) {
            console.error(`❌ Error ${model}:`, error.message);
        }
    }
    return false;
}

async function testGemini() {
    console.log("\n=== PROBANDO GEMINI ===");
    const { GoogleGenerativeAI } = await import("@google/generative-ai");
    const genAI = new GoogleGenerativeAI(apiKey);
    const models = ["gemini-1.5-flash", "gemini-pro"];

    for (const modelName of models) {
        try {
            console.log(`📡 Intentando Gemini: ${modelName}...`);
            const model = genAI.getGenerativeModel({ model: modelName });
            const result = await model.generateContent("Di 'Hola Mundo'");
            const text = result.response.text();
            console.log(`✅ ¡ÉXITO! ${modelName} respondió: "${text?.trim()}"`);
            return true;
        } catch (error) {
            console.error(`❌ Falló ${modelName}:`, error.message?.substring(0, 100));
        }
    }
    return false;
}

async function main() {
    // Detect key type
    if (apiKey.startsWith("gsk_")) {
        console.log("🔑 Detectada clave de Groq");
        const ok = await testGroq();
        if (!ok) console.log("\n💀 Groq falló. Verifica tu clave en https://console.groq.com/keys");
    } else if (apiKey.startsWith("AIza")) {
        console.log("🔑 Detectada clave de Gemini");
        const ok = await testGemini();
        if (!ok) {
            console.log("\n💀 Gemini falló. Probando con Groq por si acaso...");
            await testGroq();
        }
    } else {
        console.log("🔑 Tipo de clave desconocido, probando ambos...");
        const groqOk = await testGroq();
        if (!groqOk) await testGemini();
    }
}

main();
