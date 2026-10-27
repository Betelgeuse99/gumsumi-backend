# =====================================================================
# Gumsumi International Concept - Scheduler set
# ---------------------------------------------------------------------
# Run AFTER the scripts are loaded into /system script:
#   gumsumi-provision, gumsumi-expire, gumsumi-kicker, pos-client-sync
#
# There is deliberately NO data-exhausted scheduler: Gumsumi plans have
# no data caps.
# =====================================================================

/system scheduler remove [find name="t1"]
/system scheduler remove [find name="t4"]
/system scheduler remove [find name="gumsumi-provision"]
/system scheduler remove [find name="gumsumi-expire"]
/system scheduler remove [find name="gumsumi-kicker"]
/system scheduler remove [find name="gumsumi-data-exhausted"]
/system scheduler remove [find name="pos-client-sync"]

/system scheduler add name="gumsumi-provision" interval=15s on-event="/system script run gumsumi-provision"
/system scheduler add name="gumsumi-expire"    interval=1m  on-event="/system script run gumsumi-expire"
/system scheduler add name="gumsumi-kicker"    interval=3s  on-event="/system script run gumsumi-kicker"
/system scheduler add name="pos-client-sync"   interval=1m  on-event="/system script run pos-client-sync"

:log info "GUMSUMI-PROV: schedulers installed (provision 15s, expire 1m, kicker 3s, pos-sync 1m)"
