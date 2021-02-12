# Network setup

USG-3P -> US-8-60W -> 2x UAP-AC-PRO

## virtual IP adresses

MetalLB has a configured pool of `192.168.0.1-192.168.0.40`

| IP Address   | Hostname               | Description                 |
|--------------|------------------------|-----------------------------|
|`192.168.1.10`| roci.lanquarden.com    | kube-vip IP for HA k8s api  |
|`192.168.0.1` | \*.k.lanquarden.com    | cluster ingress             |
|`192.168.0.2` | adguard.lanquarden.com | adguard dns server/filter   |
|`192.168.0.3` | unifi.lanquarden.com   | unifi controller            |
|`192.168.0.4` | syslog.lanquarden.com  | loki remote syslog listener |
|`192.168.0.5` | mqtt.lanquarden.com    | vernemq MQTT broker         |
|`192.168.0.6` | hass.lanquarden.com    | homeassistant               |
|`192.168.0.7` |                        | bittorrent                  |

## Unifi cli command reference

Dump config

```console
mca-ctrl -t dump-cfg
```

See BGP neighbors

```console
show ip bgp neighbor
```

See BGP routes

```console
show ip bgp
```
