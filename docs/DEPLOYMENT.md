# Ayuda Venezuela — Deployment & the one remaining step

**Status (2026-06-27):** the site is **built, deployed, healthy, and public**. `https://ayudavenezuela.lat` and `https://www.ayudavenezuela.lat` both return **HTTP 200** through Cloudflare.

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

## Cloudflare tunnel public hostnames

These **two** public hostnames are configured on tunnel `50bc217a…`, pointing at the same HTTP service as the other apps:

| Hostname | Service |
|---|---|
| `ayudavenezuela.lat` | `http://localhost:80` |
| `www.ayudavenezuela.lat` | `http://localhost:80` |

If either hostname ever starts returning a tunnel 404 again, check Zero Trust → **Networks → Tunnels** → tunnel `50bc217a…` → **Public Hostnames** and restore the entries above. The DNS CNAMEs should remain proxied to `50bc217a-876d-4df2-8940-0ae75e55a294.cfargotunnel.com`.

## Caching and capacity

The Astro site is static. nginx caches immutable `/_astro/` assets for one year, images for seven days, and HTML with `Cache-Control: public, max-age=60, s-maxage=300` so Cloudflare can absorb bursts while still picking up emergency edits quickly.

## Verify

```bash
curl -sI https://ayudavenezuela.lat        # expect HTTP/2 200
```
Then load `https://ayudavenezuela.lat` — Spanish resource hub with emergency numbers, find-people, pets, hospitals, safety, donations, mental-health, and the supplies board.

## Updating content later
Edit `src/data/{site,resources,supplies}.json`, commit to `main`, and redeploy the Coolify app (push or trigger a deploy). Research citations live in `docs/SOURCES.md`.
