# =====================================================================
# Gumsumi International Concept - POS client sync (router -> dashboard)
# ---------------------------------------------------------------------
# Posts the POS clients currently visible on vlan-pos (dynamic ARP
# entries, enriched with DHCP host-name) to the dashboard every minute.
# The dashboard's "POS Clients" card reads it via /admin/api/stats.
#
# Requires: POS VLAN 20 on vlan-pos, dhcp server "pos-dhcp".
# >>> EDIT apiKey to match MIKROTIK_API_KEY in Supabase <<<
# =====================================================================

:local baseUrl "https://gpcqnsmdcosdulhyseqb.supabase.co/functions/v1/hotspot"
:local apiKey "REPLACE_WITH_MIKROTIK_API_KEY"
:local syncUrl "$baseUrl/api/pos-sync"

:local arr [:toarray ""]

# Force ARP resolution for known POS DHCP leases, even if the device ignores ICMP.
:foreach l in=[/ip dhcp-server lease find where server="pos-dhcp"] do={
  :if ([/ip dhcp-server lease get $l status] = "bound") do={
    :local ip [/ip dhcp-server lease get $l active-address]
    :if ([:len $ip] > 0) do={ :do { /ping $ip count=1 } on-error={} }
  }
}

# Currently present POS clients from the router ARP table on the POS VLAN.
:foreach a in=[/ip arp find where interface="vlan-pos"] do={
  :if ([/ip arp get $a dynamic]) do={
    :local ip [/ip arp get $a address]
    :if ($ip != "192.168.20.1") do={
      :local mac [/ip arp get $a mac-address]
      :local hn ""
      :local l [/ip dhcp-server lease find where active-address=$ip]
      :if ([:len $l] > 0) do={ :set hn [/ip dhcp-server lease get ($l->0) host-name] }
      :local r [:toarray ""]
      :set ($r->"mac") $mac
      :set ($r->"ip") $ip
      :set ($r->"hostname") $hn
      :local n [:len $arr]
      :set ($arr->$n) $r
    }
  }
}

:local p [:toarray ""]
:set ($p->"clients") $arr
:local body [:serialize to=json value=$p]
:do {
  /tool fetch url=("$syncUrl\?api_key=$apiKey") http-method=post http-data=$body \
    http-header-field="Content-Type: application/json" check-certificate=no keep-result=no
} on-error={ :log warning "POS-SYNC fetch failed" }
