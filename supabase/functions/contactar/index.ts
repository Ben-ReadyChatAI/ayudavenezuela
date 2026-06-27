// Ayuda Venezuela — "contactar" relay.
// Receives a message for an email-type classified, looks up the lister's PRIVATE
// email with the service-role key, and sends it via Resend. The email is never
// returned to the browser, so it stays hidden.
//
// Deploy to project deomqpstbqcjtfxrnwif. Required function secrets:
//   RESEND_API_KEY   — your Resend API key
//   RELAY_FROM       — a Resend-verified sender, e.g. "Ayuda Venezuela <avisos@tu-dominio-verificado>"
// (SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected automatically.)
// Deploy with verify_jwt = false (this is a public contact endpoint).

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method" }, 405);

  let payload: { id?: string; mensaje?: string; remitente?: string };
  try { payload = await req.json(); } catch { return json({ error: "json" }, 400); }

  const id = (payload.id ?? "").trim();
  const mensaje = (payload.mensaje ?? "").toString().trim();
  const remitente = (payload.remitente ?? "").toString().trim().slice(0, 200);

  if (!UUID.test(id)) return json({ error: "id" }, 400);
  if (mensaje.length < 2 || mensaje.length > 2000) return json({ error: "mensaje" }, 400);

  const SUPA = Deno.env.get("SUPABASE_URL");
  const SRK = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const RESEND = Deno.env.get("RESEND_API_KEY");
  const FROM = Deno.env.get("RELAY_FROM") ?? "Ayuda Venezuela <onboarding@resend.dev>";
  if (!SUPA || !SRK || !RESEND) return json({ error: "config" }, 500);

  // look up the listing with the service role (RLS bypassed)
  const lr = await fetch(
    `${SUPA}/rest/v1/clasificados?id=eq.${id}&select=titulo,email,contacto_tipo,status`,
    { headers: { apikey: SRK, Authorization: `Bearer ${SRK}` } },
  );
  if (!lr.ok) return json({ error: "lookup" }, 502);
  const rows = await lr.json();
  const row = rows?.[0];
  if (!row || row.status !== "publicado" || row.contacto_tipo !== "email" || !row.email) {
    return json({ error: "no-disponible" }, 404);
  }

  const subject = `Respuesta a tu aviso: ${row.titulo}`;
  const text =
    `Alguien respondió a tu aviso en Ayuda Venezuela.\n\n` +
    `Mensaje:\n${mensaje}\n\n` +
    `Contacto del interesado: ${remitente || "(no proporcionado)"}\n\n— ayudavenezuela.lat`;

  const body: Record<string, unknown> = { from: FROM, to: [row.email], subject, text };
  if (remitente.includes("@")) body.reply_to = remitente;

  const er = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!er.ok) return json({ error: "envio" }, 502);

  return json({ ok: true });
});
