# =====================================================================
# Gumsumi International Concept - MikroTik Hotspot user-profiles
# ---------------------------------------------------------------------
# Paste once into the RouterOS terminal (or run via /import). Safe to
# re-run: it creates missing profiles and updates existing ones.
#
# Profile names MUST exactly match the plan codes the backend sends:
#   24hr, 3d, 5d, 7d, 14d, 30d
#
# Plans are TIME-BASED ONLY. No limit-bytes-* is set here or on the
# users (the provisioner creates users without byte limits).
#
# Rate limits follow the existing site: 10M down / 5M up, and the
# monthly plan gets 10M/10M.
#
# keepalive-timeout=none: on Alimu a 2m keepalive logged customers out
# during brief RF/uplink glitches. Do not set 2m here.
# mac-cookie-timeout matches each plan so auto-login survives the whole
# paid period.
# =====================================================================

:foreach p in={"24hr";"3d";"5d";"7d";"14d";"30d"} do={
    :if ([:len [/ip hotspot user profile find name=$p]] = 0) do={
        /ip hotspot user profile add name=$p
    }
}

# Daily - 24 hours
/ip hotspot user profile set [find name="24hr"] session-timeout=1d  rate-limit="10M/5M" \
    shared-users=1 keepalive-timeout=none add-mac-cookie=yes mac-cookie-timeout=1d status-autorefresh=1m
# 3-Day
/ip hotspot user profile set [find name="3d"]   session-timeout=3d  rate-limit="10M/5M" \
    shared-users=1 keepalive-timeout=none add-mac-cookie=yes mac-cookie-timeout=3d status-autorefresh=1m
# 5-Day
/ip hotspot user profile set [find name="5d"]   session-timeout=5d  rate-limit="10M/5M" \
    shared-users=1 keepalive-timeout=none add-mac-cookie=yes mac-cookie-timeout=5d status-autorefresh=1m
# Weekly
/ip hotspot user profile set [find name="7d"]   session-timeout=7d  rate-limit="10M/5M" \
    shared-users=1 keepalive-timeout=none add-mac-cookie=yes mac-cookie-timeout=7d status-autorefresh=1m
# 2-Week
/ip hotspot user profile set [find name="14d"]  session-timeout=14d rate-limit="10M/5M" \
    shared-users=1 keepalive-timeout=none add-mac-cookie=yes mac-cookie-timeout=14d status-autorefresh=1m
# Monthly
/ip hotspot user profile set [find name="30d"]  session-timeout=30d rate-limit="10M/10M" \
    shared-users=1 keepalive-timeout=none add-mac-cookie=yes mac-cookie-timeout=30d status-autorefresh=1m

:log info "GUMSUMI-PROV: hotspot profiles ready (24hr,3d,5d,7d,14d,30d)"
