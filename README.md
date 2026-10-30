# chromium-railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/chromium-or-just-updated-remote-browser-?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

**Deploy on Railway:** [Chromium template](https://railway.com/deploy/chromium-or-just-updated-remote-browser-?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

A thin wrapper over [`jlesage/chromium`](https://github.com/jlesage/docker-chromium)
that makes it deploy correctly on [Railway](https://railway.com):

- **Honours Railway's injected `$PORT`.** jlesage's web server reads
  `WEB_LISTENING_PORT`; the entrypoint maps `$PORT` onto it.
- **No published-known credential.** Web authentication is on and the web and
  VNC secrets are generated per deploy; the container refuses to boot if either is empty.
- **Profile persists.** Mount the Railway volume at `/config` (logins, cookies,
  extensions, downloads survive a redeploy).
- **CDP works over Railway's private network.** Stock Chromium refuses any
  `Host` header that is not an IP or `localhost`, so a client dialling
  `chromium.railway.internal:9222` gets HTTP 500. `cdp-proxy.conf` (nginx)
  rewrites the Host header and the `webSocketDebuggerUrl` so Playwright and
  Puppeteer connect by hostname.

Pinned to `jlesage/chromium` digest `sha256:e42de74…` (Chromium 152.0.7977.82).
Published to `ghcr.io/bon5co/chromium-railway`. LLM agents: read [`AGENTS.md`](AGENTS.md).
