import { GoogleGenerativeAI } from "@google/generative-ai";

export const generateGeminiResponse = async (apiKey: string, prompt: string, context: string) => {
    const genAI = new GoogleGenerativeAI(apiKey);
    const modelsToTry = ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-pro"];
    const apiVersions = ["v1", "v1beta"];

    const fullPrompt = `
      Eres el asistente virtual operativo de "Bar Gordy".
      Tu objetivo es ayudar al dueño/encargado a tomar decisiones basadas en datos.
      
      CONTEXTO ACTUAL (DATOS EN TIEMPO REAL):
      ${context}

      INSTRUCCIONES:
      - Responde de forma concisa (máximo 2-3 párrafos).
      - Si te piden recomendaciones, bálalas en los datos provistos.
      - Si no tienes datos sobre algo, dilo honestamente.
      - Usa emojis para dar un tono amigable pero profesional.

      PREGUNTA DEL USUARIO:
      ${prompt}
    `;

    for (const version of apiVersions) {
        for (const modelName of modelsToTry) {
            try {
                console.log(`Trying Gemini: ${modelName} (${version})`);
                const model = genAI.getGenerativeModel(
                    { model: modelName },
                    { apiVersion: version }
                );
                const result = await model.generateContent(fullPrompt);
                const response = await result.response;
                console.log(`✅ Success with ${modelName} (${version})`);
                return response.text();
            } catch (error: any) {
                console.warn(`❌ Failed ${modelName} (${version}):`, error.message?.substring(0, 100) || error);
                if (error.message?.includes('404') || error.message?.includes('not found')) {
                    continue;
                }
            }
        }
    }

    console.error("All Gemini models and API versions failed.");
    return null;
}
