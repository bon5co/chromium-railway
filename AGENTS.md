# Chromium on Railway: agent guide

You deployed (or were handed) a headed Chromium with a web desktop and a CDP
endpoint. Use it as a real browser with a persistent profile.

## Contract

| Item | Value |
| --- | --- |
| Web desktop (public) | `https://$RAILWAY_PUBLIC_DOMAIN/`, HTTP-layer login |
| Web user | `admin` |
| Web login variable | `WEB_AUTHENTICATION_PASSWORD` (generated, stable across redeploys) |
| CDP endpoint (private only) | `http://<service>.railway.internal:9222` |
| CDP version probe | `GET /json/version` (no auth, private network only) |
| Profile volume | `/config` |
| Healthcheck | none (every public path answers 302 to the login page by design) |

CDP has no authentication. It is **not** exposed publicly: only a service in the
same Railway project can reach it. Never add a public domain that targets 9222.

## Drive it from a sibling service

Playwright (Python):

```python
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b = p.chromium.connect_over_cdp("http://chromium.railway.internal:9222")
    page = b.contexts[0].new_page()
    page.goto("https://example.com")
    print(page.title())
```

Puppeteer:

```js
const browser = await puppeteer.connect({ browserURL: "http://chromium.railway.internal:9222" });
```

Raw probe (replace `chromium` with the service name):

```bash
curl -s http://chromium.railway.internal:9222/json/version
```

## Rules of use

- Reuse `b.contexts[0]`: that is the persistent profile, so logins you make stay.
- Do not call `browser.close()`; it kills the desktop's only browser. Close pages instead.
- A human can watch and take over at the public URL (log in with the web login above).
- Downloads land in `/config/Downloads` and are reachable through the web file manager.
- Budget roughly 1 GB RAM per few tabs; scale the service if pages crash.
- If the service name is not `chromium`, the private host is `$RAILWAY_PRIVATE_DOMAIN`.
