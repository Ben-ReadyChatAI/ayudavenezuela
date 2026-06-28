# New Resources — for review before adding to the site

**Compiled:** 2026-06-27 · **Status:** PROPOSED, not wired into code. Approve here, then adapt into `src/data/resources.json`.

**How they were found:** four parallel research agents (international NGO/UN · shelters & reunification · safety & public health · diaspora/news/blood). Every URL was HTTP-checked with `curl -L` on 2026-06-27. Each entry in `proposed-resources.json` carries a `_review` block (http status, confidence, why, caveats).

**Selection rules applied** (same as the existing site): no crypto / gift-card / anonymous-wallet solicitation; identify the operator; flag PII/privacy risk; prefer Spanish-language and durable institutional URLs; quote any non-200 nuance instead of dropping the link.

---

## What's proposed (37 entries)

### New categories (suggested)
| Category | Count | Highlights |
|---|---|---|
| 🏠 Albergues y centros de acopio | 2 | Caracas Ayuda map, Central de Ayuda VE (fills the "no official shelter list" gap) |
| 👨‍👩‍👧 Reunificación familiar (CICR) | 3 | **ICRC RFL line 0422-799 4880 / centrocontactove@icrc.org** (strongest find), familylinks.icrc.org, Cruz Roja Colombiana |
| 📋 Seguridad sísmica y réplicas | 6 | Red Cross drop-cover-hold (ES), USGS event page + live map, FUNVISIS monitor |
| 🚰 Salud pública en la emergencia | 3 | PAHO Venezuela-2026 response, WASH, dead-body management |
| 🩸 Donar sangre | 3 | 7 Caracas centers list, Banco Municipal de Sangre, Cruz Roja VE |
| 🌎 Diáspora: enviar ayuda y remesas | 2 | Comité de Emergencia (audited 8-NGO), ZOOM/Western Union |
| 📰 Noticias verificadas y anti-rumores | 5 | Cocuyo Chequea, El Pitazo, Runrun, Cazadores de Fake News, Observatorio FN |

### Additions to existing categories
| Into | Count | What |
|---|---|---|
| 💚 Donar | 10 | UNICEF, Direct Relief, GlobalGiving, World Central Kitchen, CRS, Cáritas (ES), Save the Children, World Vision, IRC, Project HOPE |
| 🧠 Apoyo psicológico | 2 | WHO Psychological First Aid (ES PDF), IASC MHPSS guide |
| 🆘 Oficial / coordinación | 2 | UN OCHA Venezuela, MSF (info) |
| 🔎 Buscar personas (optional) | 1 | Facebook Safety Check (in-app feature) |

---

## Top picks (all HIGH confidence, verified)
1. **ICRC Restoring Family Links line** — 0422-799 4880 / centrocontactove@icrc.org. The single most authoritative reunification channel inside Venezuela. *(Confirm the email before publishing — one source.)*
2. **PAHO Venezuela-2026 response** + WASH + dead-body management — authoritative health guidance the site currently lacks.
3. **Blood donation** — concrete where-to-donate (7 Caracas centers) the site has no category for.
4. **International NGO appeals** — UNICEF, Direct Relief, GlobalGiving, WCK, CRS, Save the Children, World Vision, IRC, Project HOPE (all quake-specific pages).
5. **Anti-rumor desks** — Cocuyo Chequea, Cazadores de Fake News (directly counters the tsunami/blackout hoaxes circulating).

---

## Link-checker / publishing warnings
- **familylinks.icrc.org** → 403 to bots (live in browsers). Link the `icrc.org/.../venezuela` page instead if your checker is strict.
- **redcross.org, unicef, unhcr, crs** → 403 to bare `curl` (WAF), 200 with a browser User-Agent. Real pages.
- **FUNVISIS monitor** → **HTTP-only, no TLS.** Link out; do NOT iframe (mixed content on the HTTPS site).
- **Blood-donation center list** → drive dated **Jun 26–28**; re-confirm before publishing (Ministry may extend).
- **WCK** → use `wck.org/relief/caracas-venezuela-earthquakes-2026/`; the bare `/relief/venezuela-earthquake` 404s.

---

## Rejected / could NOT verify (deliberately excluded)
| Item | Reason |
|---|---|
| ICRC **Trace the Face** | Built for missing migrants in Europe, not domestic post-quake reunification — wrong tool. |
| **Google Person Finder** (VE 2026 repo) | No Venezuela-2026 repository exists; Google's role here was Android quake alerts, not Person Finder. |
| **WFP / PMA** donation page | No quake-specific appeal; `wfp.org/emergencies/venezuela-emergency` 404s. Only a "stands ready" statement. |
| **ACNUR/UNHCR Spanish** quake page | 404; Spanish donate redirects to a generic fund. Used the English UNHCR Venezuela emergency page. |
| **EsPaja** (espaja.com) | 403 to checks; could not confirm active quake content. Verify manually in a browser. |
| **observatoriodefakenews.com** | DNS did not resolve — only the X account `@ObservatorioFN` is verified. |
| **CriptoNoticias** "acopio" articles | Crypto-outlet framing risks steering users to crypto/wallet donations — against scam rules. |
| Generic netlify/vercel "ayuda" microsites, personal GoFundMes | Unverifiable / anonymous operators — the diaspora scam risk to avoid. |

### Optional cross-references (non-Venezuelan but high-quality quake debunks)
- Maldita.es — `https://maldita.es/desinfo/20260625/bulos-terremoto-sismo-venezuela/` (200)
- Factchequeado — `https://factchequeado.com/teexplicamos/20260626/terremotos-venezuela-desinformaciones-recomendaciones/` (200)

---

## To approve / adapt later
1. Review `proposed-resources.json`. Strike anything you don't want.
2. Decide which **new categories** to create vs. fold into existing ones.
3. Move chosen items into `src/data/resources.json` (drop the `_review`/`_meta`/`_note` keys — the build ignores them, but keep the data clean).
4. Add citations to `docs/SOURCES.md` to match the existing verification style.
5. Re-confirm the time-bound / single-source items flagged above before publish.
