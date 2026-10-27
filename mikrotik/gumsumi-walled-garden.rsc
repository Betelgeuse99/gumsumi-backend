# =====================================================================
# Gumsumi International Concept - Hotspot walled garden
# ---------------------------------------------------------------------
# Everything the customer's device must reach BEFORE login:
#   - the Gumsumi backend (Supabase edge function)
#   - Squad checkout (payment + popup + CloudFront assets)
#   - the public dashboard / success page hosts and their CDNs
#
# IMPORTANT (learned on Alimu, 2026-10-16):
# RouterOS matches the hotspot walled garden against the DNS name the
# client asked for - but pay/checkout/api-d/popup.squadco.com are CNAMEs
# to CloudFront, so `*.squadco.com` alone NEVER matches. The CloudFront
# target names must be allowed, or the Squad page stays blocked.
#
# Run once. Safe to re-run: previous "GSM|" entries are removed first.
# =====================================================================

# --- clean previous Gumsumi entries -----------------------------------
/ip hotspot walled-garden remove [find where comment~"^GSM\\|"]

# --- backend ----------------------------------------------------------
/ip hotspot walled-garden add action=allow dst-host="gpcqnsmdcosdulhyseqb.supabase.co" comment="GSM|backend-supabase"

# --- Squad (queried names) -------------------------------------------
/ip hotspot walled-garden add action=allow dst-host="pay.squadco.com"      comment="GSM|squad-pay"
/ip hotspot walled-garden add action=allow dst-host="checkout.squadco.com" comment="GSM|squad-checkout"
/ip hotspot walled-garden add action=allow dst-host="api-d.squadco.com"    comment="GSM|squad-api"
/ip hotspot walled-garden add action=allow dst-host="popup.squadco.com"    comment="GSM|squad-popup"
/ip hotspot walled-garden add action=allow dst-host="*.squadco.com"        comment="GSM|squad-any"

# --- Squad CloudFront CNAME targets (the ones that actually match) ----
/ip hotspot walled-garden add action=allow dst-host="d2qbzcud0iome0.cloudfront.net" comment="GSM|squad-pay-CF"
/ip hotspot walled-garden add action=allow dst-host="d1llxrzwx6cj4j.cloudfront.net" comment="GSM|squad-checkout-CF"
/ip hotspot walled-garden add action=allow dst-host="d3rjt8bbqr228g.cloudfront.net" comment="GSM|squad-api-CF"
/ip hotspot walled-garden add action=allow dst-host="d36rd54fgqrqy8.cloudfront.net" comment="GSM|squad-popup-CF"
/ip hotspot walled-garden add action=allow dst-host="*.cloudfront.net"              comment="GSM|squad-cdn-all"

# --- public site / success page --------------------------------------
/ip hotspot walled-garden add action=allow dst-host="gumsumi.dreamhatcher.ink"  comment="GSM|site"
/ip hotspot walled-garden add action=allow dst-host="betelgeuse99.github.io"    comment="GSM|site-ghpages"
/ip hotspot walled-garden add action=allow dst-host="cdnjs.cloudflare.com"      comment="GSM|site-cdnjs"
/ip hotspot walled-garden add action=allow dst-host="fonts.googleapis.com"      comment="GSM|site-fonts"
/ip hotspot walled-garden add action=allow dst-host="fonts.gstatic.com"         comment="GSM|site-fontfiles"

# --- optional: card 3-D Secure issuer pages --------------------------
# Only needed if real card payments must complete pre-login. Add the
# issuer(s) the site's customers actually use, then test with a card:
# /ip hotspot walled-garden add action=allow dst-host="*.mastercard.com" comment="GSM|3ds-mc"
# /ip hotspot walled-garden add action=allow dst-host="*.visa.com"       comment="GSM|3ds-visa"
# /ip hotspot walled-garden add action=allow dst-host="*.gtbank.com"     comment="GSM|3ds-gtb"
# /ip hotspot walled-garden add action=allow dst-host="*.zenithbank.com" comment="GSM|3ds-zenith"

:put "=== WALLED GARDEN ==="
/ip hotspot walled-garden print where comment~"^GSM\\|"
:log info "GUMSUMI-PROV: walled garden installed"
