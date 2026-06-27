# Ayuda Venezuela — Deployment & the one remaining step

**Status (2026-06-27):** the site is **built, deployed, and healthy**, and serves **HTTP 200 at the origin**. The public URL `https://ayudavenezuela.lat` returns **404** for exactly one reason: the Cloudflare **Tunnel** that fronts the server has no *public-hostname* entry for this domain yet. Adding it is the only remaining task and needs **Cloudflare account-level access** (the automation only had zone/DNS scope).

## Architecture

```
visitor ──HTTPS──> Cloudflare edge ──Tunnel(50bc217a…)──> Caddy proxy (Chicago Host :80) ──> nginx container
            (proxied CNAME)        (per-hostname ingress)      (host-routes by domain)        (static Astro site)
```

- **Server:** "Chicago Host" (Coolify), no public IP — reached only via the Cloudflare Tunnel (and Tailscale `100.105.148.58` for management).
- **Tunnel:** `50bc217a-876d-4df2-8940-0ae75e55a294` — the same one serving `open-ocr.com`, `dev.opentranscription.io`, `staging.open-ocr.com`, etc. It routes **per hostname** (unknown hosts get a 404), so each new site needs its own entry.
- **Proxy:** Caddy (caddy-docker-proxy). Coolify generates the host-router labels from the app's domain.

## What is already done (no action needed)

- **Repo:** `github.com/Ben-ReadyChatAI/ayudavenezuela` (public, Dockerfile build).
- **Coolify:** project **AyudaVe**, app **AyudaVenezuela**, on Chicago Host — `running:healthy`, domain `http://ayudavenezuela.lat,http://www.ayudavenezuela.lat`.
- **DNS (Cloudflare):** `ayudavenezuela.lat` and `www` → proxied CNAME to `50bc217a-876d-4df2-8940-0ae75e55a294.cfargotunnel.com`. Email MX/SPF left intact.
- **Verified at origin:** `curl -H 'Host: ayudavenezuela.lat' http://100.105.148.58/` → `200` with the full site.

## The remaining step — add the tunnel public hostnames

Add **two** public hostnames to tunnel `50bc217a…`, pointing at the **same service the existing entries use** (e.g. copy `open-ocr.com`'s — it is `HTTP` → `localhost:80`):

| Hostname | Service |
|---|---|
| `ayudavenezuela.lat` | `http://localhost:80` |
| `www.ayudavenezuela.lat` | `http://localhost:80` |

### Option A — Cloudflare Zero Trust dashboard (manual)
Zero Trust → **Networks → Tunnels** → open the tunnel that serves `open-ocr.com` → **Public Hostnames** → **Add a public hostname** (twice, per the table above). The DNS CNAMEs already exist, so no DNS change is needed.

### Option B — Cloudflare API (needs a token with `Account · Cloudflare Tunnel · Edit`)
```bash
ACCOUNT_ID=<your account id>          # GET /client/v4/accounts
TUNNEL_ID=50bc217a-876d-4df2-8940-0ae75e55a294
# 1) read the current config, 2) append the two ingress rules BEFORE the final
#    catch-all (service: http_status:404), 3) PUT it back:
#    GET  /client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations
#    PUT  /client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations
# Each new rule: { "hostname": "ayudavenezuela.lat", "service": "http://localhost:80" }
```
> The repo automation can do Option B end-to-end once the token has the `Cloudflare Tunnel · Edit` permission — editing the existing token's permissions does **not** change its value.

## Verify

```bash
curl -sI https://ayudavenezuela.lat        # expect HTTP/2 200
```
Then load `https://ayudavenezuela.lat` — Spanish resource hub with emergency numbers, find-people, pets, hospitals, safety, donations, mental-health, and the supplies board.

## Updating content later
Edit `src/data/{site,resources,supplies}.json`, commit to `main`, and redeploy the Coolify app (push or trigger a deploy). Research citations live in `docs/SOURCES.md`.
