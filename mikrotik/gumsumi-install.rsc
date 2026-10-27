# =====================================================================
# Gumsumi International Concept - one-shot router install
# ---------------------------------------------------------------------
# Run AFTER uploading to the router root:
#   gumsumi-provision-queue.rsc   (API key substituted)
#   gumsumi-expire.rsc            (API key substituted)
#   gumsumi-kicker.rsc
#   gumsumi-pos-sync.rsc          (API key substituted)
#   gumsumi-profiles.rsc
#   gumsumi-walled-garden.rsc
#   gumsumi-schedulers.rsc
#   gumsumi-install.rsc           (this file)
#
# Then:  /import file-name=gumsumi-install.rsc
#
# The install stores the four pollers as /system script entries, applies
# the profiles + walled garden + schedulers, sets the site time zone and
# removes the uploaded .rsc files. No data-cap script is installed.
# =====================================================================

:put "=== GUMSUMI INSTALL START ==="

# device-mode "home" disables /tool fetch. Without fetch the pollers can
# never reach Supabase. Fix (needs physical access):
#   /system device-mode/update fetch=yes activation-timeout=10m
#   then unplug the power (cold reboot) within the timeout.
:if ([/system device-mode get fetch] = false) do={
    :put "WARNING: device-mode fetch=no - provisioning/expiry/POS sync will fail until it is enabled"
}

# Site local time (WAT) so logs line up with the dashboard.
/system clock set time-zone-name=Africa/Lagos
:put ("time-zone=" . [/system clock get time-zone-name])

# --- replace the poller scripts --------------------------------------
:foreach n in={"gumsumi-provision";"gumsumi-expire";"gumsumi-kicker";"pos-client-sync"} do={
    :if ([:len [/system script find name=$n]] > 0) do={
        /system script remove [find name=$n]
    }
}

/system script add name="gumsumi-provision" policy=ftp,read,write,policy,test \
    source=[/file get [find name="gumsumi-provision-queue.rsc"] contents]
/system script add name="gumsumi-expire" policy=ftp,read,write,policy,test \
    source=[/file get [find name="gumsumi-expire.rsc"] contents]
/system script add name="gumsumi-kicker" policy=ftp,read,write,policy,test \
    source=[/file get [find name="gumsumi-kicker.rsc"] contents]
/system script add name="pos-client-sync" policy=ftp,read,write,policy,test \
    source=[/file get [find name="gumsumi-pos-sync.rsc"] contents]

:put "=== SCRIPTS ==="
/system script print where name~"gumsumi|pos-client"

# --- profiles, walled garden, schedulers -----------------------------
/import file-name=gumsumi-profiles.rsc
/import file-name=gumsumi-walled-garden.rsc
/import file-name=gumsumi-schedulers.rsc

# --- remove the uploaded deployment files ----------------------------
:do { /file remove [find name="gumsumi-provision-queue.rsc"] } on-error={}
:do { /file remove [find name="gumsumi-expire.rsc"] } on-error={}
:do { /file remove [find name="gumsumi-kicker.rsc"] } on-error={}
:do { /file remove [find name="gumsumi-pos-sync.rsc"] } on-error={}
:do { /file remove [find name="gumsumi-profiles.rsc"] } on-error={}
:do { /file remove [find name="gumsumi-walled-garden.rsc"] } on-error={}
:do { /file remove [find name="gumsumi-schedulers.rsc"] } on-error={}

:put "=== SCHEDULERS ==="
/system scheduler print where name~"gumsumi|pos-client"
:put "=== PROFILES ==="
:foreach p in={"24hr";"3d";"5d";"7d";"14d";"30d"} do={
    :put ($p . " session=" . [/ip hotspot user profile get [find name=$p] session-timeout] . \
          " rate=" . [/ip hotspot user profile get [find name=$p] rate-limit] . \
          " keepalive=" . [/ip hotspot user profile get [find name=$p] keepalive-timeout] . \
          " mac-cookie=" . [/ip hotspot user profile get [find name=$p] mac-cookie-timeout])
}
:put "=== GUMSUMI INSTALL DONE ==="
