; Zone file for home.example.com (internal split DNS)
; Replace hostnames and IP addresses to match your environment.

$TTL    604800
@       IN      SOA     ns1.example.lan. admin.example.lan. (
                         2025090801 ; Serial (YYYYMMDDNN format)
                         604800     ; Refresh (1 week)
                         86400      ; Retry (1 day)
                         2419200    ; Expire (4 weeks)
                         604800 )   ; Negative Cache TTL (1 week)

; Name servers for this internal subdomain
@       IN      NS      ns1.example.lan.

; Example host records (placeholders)
nas             IN      A       192.0.2.10     ; TODO
pve             IN      A       192.0.2.11     ; TODO
pbs             IN      A       192.0.2.12     ; TODO
unifi           IN      A       192.0.2.13     ; TODO
usw24           IN      A       192.0.2.14     ; TODO
usw16           IN      A       192.0.2.15     ; TODO
ap              IN      A       192.0.2.16     ; TODO
idrac           IN      A       192.0.2.17     ; TODO
udm             IN      A       192.0.2.18     ; TODO
plex            IN      A       192.0.2.19     ; TODO
dashboard       IN      A       192.0.2.20     ; TODO
unvr            IN      A       192.0.2.21     ; TODO
cyberchef       IN      A       192.0.2.22     ; TODO
kuma            IN      A       192.0.2.23     ; TODO
ha              IN      A       192.0.2.31     ; TODO
homebridge      IN      A       192.0.2.32     ; TODO
homey           IN      A       192.0.2.33     ; TODO

; Aliases (CNAMEs)
proxmox         IN      CNAME   pve.home.example.com.
kibana          IN      CNAME   dashboard.home.example.com.

