# Auditoría del homelab (noviembre 2026)

Auditoría completa de **solo lectura**: no se cambió nada durante la revisión. Se relevaron hardware, sistema, red, contenedores, backups y monitoreo, y de ahí salió un plan priorizado.

## Lo que estaba bien

- **Superficie expuesta mínima:** ningún panel de administración accesible desde Internet; todo por Tailscale.
- **Firewall efectivo:** el filtro en `DOCKER-USER` con política DROP funciona, aunque Docker se saltee UFW.
- **SSH** solo con clave y fail2ban activo.
- **Backups en dos destinos**, cifrados, más dumps de base de datos aparte.
- **Monitoreo en varias capas:** servicios, discos, host y heartbeat externo.

## Hallazgos

| Prioridad | Hallazgo | Riesgo |
|---|---|---|
| Alta | Imágenes en `:latest` sin proceso de actualización; el escaneo con Trivy mostró CVEs | Vulnerabilidades conocidas sin parchear |
| Alta | Algunos secretos en texto plano dentro de compose y scripts | Filtración si se comparte un archivo |
| Alta | Passphrase de Duplicati guardada solo en el propio server | Si se pierde el server, los backups no se pueden descifrar |
| Media | Duplicati sin aviso de fallo y sin restore probado | Backups que fallan en silencio |
| Media | Prometheus sin reglas de alerta | Las métricas se ven pero no avisan |
| Baja | Logs sin rotación; cAdvisor con consumo alto | Disco y RAM |
| Baja | Sin UPS ni RAID | Un corte de luz o un disco caído = downtime |

## Plan

1. Guardar la passphrase de Duplicati fuera del server y activar avisos de fallo.
2. Pasar los secretos a `.env`, fuera de control de versiones.
3. Fijar versiones de imágenes y actualizar con un proceso definido (Trivy antes y después).
4. Hacer una prueba de restore real y repetirla periódicamente.
5. Reglas de alerta en Prometheus, rotación de logs y ajuste de cAdvisor.
6. Hardware: UPS y ampliación a 32 GB de RAM.

## Conclusiones de capacidad

- El equipo está bien para uso doméstico y de laboratorio.
- **No es apto para hostear servicios de clientes:** no tiene redundancia de disco, ni UPS, ni la seguridad para multi-tenant.
