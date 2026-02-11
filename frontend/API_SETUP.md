# Cómo Configurar la IA del Asistente Gordy

El asistente soporta **dos proveedores de IA**. Recomendamos **Groq** porque es gratis, rápido y funciona sin restricciones regionales.

---

## Opción 1: Groq (Recomendado ⚡)
Groq es gratuito y extremadamente rápido. Usa modelos como Llama 3.3 y Mixtral.

1.  Ve a **[console.groq.com/keys](https://console.groq.com/keys)**.
2.  Crea una cuenta (gratis, solo necesitas email).
3.  Haz clic en **"Create API Key"**.
4.  Ponle un nombre (ej: "Bar Gordy") y crea la clave.
5.  Copia la clave (empieza con `gsk_...`).
6.  Pégala en el Chat de Gordy (⚙️).

> **Nota:** Groq tiene un tier gratuito muy generoso (14,400 requests/día).

---

## Opción 2: Google Gemini 🤖
Si prefieres usar Gemini (requiere proyecto de Google Cloud).

1.  Ve a **[Google AI Studio](https://aistudio.google.com/app/apikey)**.
2.  Haz clic en **"Create API key"**.
3.  Selecciona **"Create API key in a new project"**.
4.  Copia la clave (empieza con `AIza...`).
5.  Pégala en el Chat de Gordy (⚙️).

---

## Verificar tu clave
Ejecuta en la terminal (desde `frontend/`):
```
node test_api.mjs "TU_CLAVE_AQUI"
```
El script detecta automáticamente si es clave de Groq o Gemini.
