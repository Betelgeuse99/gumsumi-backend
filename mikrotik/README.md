# Gumsumi router scripts (MikroTik L009UiGS-2HaxD, RouterOS 7.23.2)

All files are **time-based only**. Gumsumi plans have **no data caps**: no
`limit-bytes-*`, and `gumsumi-data-exhausted.rsc` was deliberately removed.

| File | Purpose |
|---|---|
| `gumsumi-install.rsc` | One-shot install: stores the four pollers as `/system script`, sets the WAT time zone, applies profiles + walled garden + schedulers, prints a verification block. |
| `gumsumi-provision-queue.rsc` | Polls `/api/mikrotik-queue-text` every 15s and creates hotspot users (profile = plan code, no byte limits). Marks an order processed **only after** the user is actually created. |
| `gumsumi-expire.rsc` | Every minute, removes users whose `expires_at` has passed and marks the order expired. |
| `gumsumi-kicker.rsc` | Every 3s, clears a stale session blocking a returning device (`shared-users=1`), keeping the MAC cookie for auto-login. |
| `gumsumi-pos-sync.rsc` | Every minute, posts the POS VLAN clients (ARP + DHCP host-name) to `/api/pos-sync` for the dashboard card. |
| `gumsumi-profiles.rsc` | Creates/updates profiles `24hr,3d,5d,7d,14d,30d`: 10M/5M (30d 10M/10M), `shared-users=1`, `keepalive-timeout=none`, MAC cookie = plan duration. |
| `gumsumi-walled-garden.rsc` | Allows Supabase, the public site, and **Squad + its CloudFront CNAME targets** before login. |
| `gumsumi-schedulers.rsc` | provision 15s · expire 1m · kicker 3s · pos-client-sync 1m. |

## Install order

1. Replace `REPLACE_WITH_MIKROTIK_API_KEY` in `gumsumi-provision-queue.rsc`,
   `gumsumi-expire.rsc` and `gumsumi-pos-sync.rsc` **in local copies only**.
   Never commit the real key.
2. Upload those three plus `gumsumi-kicker.rsc`, `gumsumi-profiles.rsc`,
   `gumsumi-walled-garden.rsc`, `gumsumi-schedulers.rsc` and
   `gumsumi-install.rsc` to the router root.
3. `/import file-name=gumsumi-install.rsc`
4. Verify:
   - `/system script print where name~"gumsumi|pos-client"` → `invalid=false`
   - `/system scheduler print where name~"gumsumi|pos-client"`
   - `/ip hotspot user profile print` → six profiles, no `limit-bytes-*`
   - `/ip hotspot walled-garden print` → `GSM|` entries
   - `/log print where message~"GUMSUMI|POS-SYNC"` → no `Fetch failed`

## Critical prerequisite: device-mode

This router ships in device-mode **`home`**, which sets **`fetch: no`**.
Every poller above uses `/tool fetch`, so they silently fail with
`failure: not allowed by device-mode` until fetch is enabled:

```
/system device-mode/update fetch=yes activation-timeout=10m
```

Then **unplug the power (cold reboot) within the timeout** — or briefly press
the reset/mode button. A soft reboot does not confirm the change. The device
reboots and the new mode applies. With no confirmation the update is
discarded, so this must be done with someone physically at the router.

## Cautions

- Do **not** install the old data-exhausted script or any `limit-bytes-*`:
  Gumsumi sells time, not gigabytes.
- The Alimu router needed `keepalive-timeout=none`; a 2-minute keepalive
  logged customers out on brief uplinks glitches. Keep it `none`.
- Squad checkout hosts resolve to CloudFront CNAMEs; `*.squadco.com` alone
  never matches in the walled garden. Keep the four
  `*.cloudfront.net` target entries.
- Do not retire MikroTicket until one injected order provisions end-to-end.
