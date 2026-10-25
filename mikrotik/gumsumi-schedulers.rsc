/system scheduler remove [find name="t1"]
/system scheduler remove [find name="t4"]
/system scheduler remove [find name="gumsumi-provision"]
/system scheduler remove [find name="gumsumi-expire"]
/system scheduler remove [find name="gumsumi-kicker"]
/system scheduler remove [find name="gumsumi-data-exhausted"]
/system scheduler add name="gumsumi-provision" interval=15s on-event="/system script run gumsumi-provision"
/system scheduler add name="gumsumi-expire" interval=1m on-event="/system script run gumsumi-expire"
/system scheduler add name="gumsumi-kicker" interval=3s on-event="/system script run gumsumi-kicker"
/system scheduler add name="gumsumi-data-exhausted" interval=1m on-event="/system script run gumsumi-data-exhausted"
