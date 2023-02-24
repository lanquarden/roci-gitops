# Network setup

WIP documenting home network setup

## virtual IP adresses

MetalLB has a configured pool of `192.168.1.15-192.168.1.39`

| IP Address   | Hostname               | Description                 |
|--------------|------------------------|-----------------------------|
|`192.168.1.10`| roci.lanquarden.com    | kube-vip IP for HA k8s api  |
|`192.168.1.15`| \*.k.lanquarden.com    | cluster ingress             |
|`192.168.1.16`| adguard.lanquarden.com | adguard dns server/filter   |
|`192.168.1.17`| unifi.lanquarden.com   | unifi controller            |
|`192.168.1.18`| syslog.lanquarden.com  | loki remote syslog listener |
|`192.168.1.19`| mqtt.lanquarden.com    | vernemq MQTT broker         |
|`192.168.1.20`| hass.lanquarden.com    | homeassistant               |
|`192.168.1.21`|                        | bittorrent                  |
|`192.168.1.22`|                        | minecraft proxy             |

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
