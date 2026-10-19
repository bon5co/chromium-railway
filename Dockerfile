# Chromium web desktop (jlesage/chromium) wrapped for Railway: no blank required
# fields, no published-known credential, honours Railway's injected $PORT, the
# profile persists on the volume at the real /config, and the Chrome DevTools
# Protocol (CDP) endpoint is on so an AI agent can drive the browser.
#
# Pinned by digest: jlesage/chromium, Chromium 152.0.7977.82.
FROM jlesage/chromium@sha256:e42de7469bce122b8a69d4f62101850ece45c41ed7ed952f2b506f99947093ae

# Baked defaults. templateGenerate drops literal defaultValues (they publish as
# blank required fields), so every value that is not a per-deploy secret is set
# here rather than as a template variable. A user-set variable still wins.
ENV APP_NAME="Chromium" \
    ENABLE_CJK_FONT=1 \
    WEB_AUDIO=1 \
    WEB_FILE_MANAGER=1 \
    WEB_AUTHENTICATION=1 \
    WEB_AUTHENTICATION_ALLOW_INSECURE=1 \
    WEB_AUTHENTICATION_USERNAME=admin \
    CHROMIUM_REMOTE_DEBUGGING=1 \
    CHROMIUM_REMOTE_DEBUGGING_PORT=9222

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

# jlesage sets no ENTRYPOINT and CMD ["/init"] (its s6 supervisor). Prepend a thin
# entrypoint that maps $PORT and validates credentials, then exec /init.
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["/init"]

# Replace jlesage's socat forwarder on :9222 with an nginx shim that fixes the
# Host-header check (see cdp-proxy.conf). The service stays disabled unless
# CHROMIUM_REMOTE_DEBUGGING=1, exactly like the stock one.
COPY cdp-proxy.conf /etc/cdp-proxy.conf
COPY cdp-run /etc/services.d/remote_debugging/run
RUN chmod +x /etc/services.d/remote_debugging/run
