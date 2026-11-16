#!/bin/bash
# Filtro de los puertos que publica Docker, en la cadena DOCKER-USER.
# En DOCKER-USER el paquete ya pasó por DNAT, así que se filtra por el puerto
# original del host con --ctorigdstport.
#
# Resultado: desde la LAN solo se ven DNS, Jellyfin y Homepage.
# Todo lo demás (paneles de admin) es accesible únicamente por Tailscale.
set -e
LAN_CIDR="192.168.1.0/24"   # ajustar a tu red
EXT_IFACE="eth0"            # interfaz física del server
LAN_PORTS="8096,8083,53"    # Jellyfin (teles por LAN) + Homepage + DNS (Pi-hole)

iptables -F DOCKER-USER
iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# desde la LAN, solo los puertos de uso doméstico
for p in ${LAN_PORTS//,/ }; do
    iptables -A DOCKER-USER -i "$EXT_IFACE" -s "$LAN_CIDR" -p tcp -m conntrack --ctorigdstport "$p" -j RETURN
done
# DNS de Pi-hole también por UDP
iptables -A DOCKER-USER -i "$EXT_IFACE" -s "$LAN_CIDR" -p udp -m conntrack --ctorigdstport 53 -j RETURN
iptables -A DOCKER-USER -i "$EXT_IFACE" -j DROP     # el resto de la LAN e Internet: afuera
iptables -A DOCKER-USER -j RETURN                   # tailscale0, loopback, contenedor→contenedor: pasa

ip6tables -F DOCKER-USER
ip6tables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A DOCKER-USER -i "$EXT_IFACE" -j DROP
ip6tables -A DOCKER-USER -j RETURN
