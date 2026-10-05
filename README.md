# Gluon-Patches: Fehlerbehebungen

*Patches for Gluon v2025.1.x / OpenWrt 24.10 that fix system behaviour
independent of the device: relief for 64 MB devices, boot stalls, tunneldigger
retries, config-mode wizard, two package patches, and disable_manifest() for
image-customization.lua. Used by Freifunk im
Neanderland (Neanderfunk). Each script can be used on its own; `apply.sh`
applies all of them in order.*

Korrekturen am Systemverhalten, unabhängig vom Gerät. Nichts davon hängt an
den Paketen oder der Site-Konfiguration von Neanderfunk.

Die Zweige folgen Gluon: **dieser Zweig `v2021.1.x` passt zu Gluon v2021.1.x
(OpenWrt 19.07, Kernel 4.14)** und dient der Sackgasse für 4/32-Geräte
(FirmwareConfigs `v2021.x`, Plan dort in `docs/ueberarbeitung-2026.md`);
`v2025.1.x` und `v2023.2.x` passen zu den jeweiligen Gluon-Zweigen.

## Anwenden

Alles auf einmal, aus dem Gluon-Verzeichnis:

```
cd gluon
<dieses Repo>/apply.sh pre-update
make update
<dieses Repo>/apply.sh post-update
```

`pre-update` legt Dateien unter `patches/packages` im Gluon-Baum ab, die
`make update` per `git am` auf die Paket-Module einspielt, und ändert Gluons
eigene Skripte, die schon vor den post-update-Patches gebraucht werden
(`build/disable-manifest.sh`: ein `make clean` wertet `image-customization.lua`
bereits aus). Alles andere läuft danach, weil `make update` die Module neu
aufsetzt.

Einzeln: das Skript samt seiner Patchdateien und `lib-patch.sh` kopieren,
Struktur `<gruppe>/…` und `lib-patch.sh` eine Ebene darüber beibehalten, und
aus dem Gluon-Verzeichnis aufrufen, etwa `cd gluon && <repo>/lowmem/sysctl-no-watermark-boost-64mb.sh`.
Die Skripte sind idempotent: Ist ein Patch schon drin, melden sie das und
machen weiter. Scheitert einer, brechen sie mit Fehler ab.

## Inhalt

| Skript | Phase | Zweck | Herkunft, Ende |
| --- | --- | --- | --- |
| `bugfixes/tunneldigger-reinit-backoff.sh` | pre-update | tunneldigger: Reinit mit Pause, kein modprobe für ein fehlendes mesh-vpn (Knoten mit VPN an, aber ohne WAN). In 2021.1 liegt tunneldigger im Gluon-Paketfeed, der Modulpatch geht deshalb nach `patches/packages/gluon` | Port aus `v2025.1.x`/`v2023.2.x`; Quelle 8995046 gleich, Quellpatch passt mit fuzz 0; `git am` auf packages `9f4be8aa` (Pin von Gluon `3181e496`) geprüft |
| `lowflash/squashfs-1024-tiny.sh` | post-update | ar71xx-tiny: squashfs-Blöcke 1024 statt 256 KiB, rund 73 KiB weniger Rootfs (am WR841N-v9-Rootfs gemessen); Preis grob 3 MB RAM (Fragment-Cache), RAM ist auf 4/32 weniger knapp als Flash (adorfer) | eigen, OpenWrt-19.07-Vorgabe für SMALL_FLASH |
| `lowflash/zram-lzo-only.sh` | post-update | `kmod-zram` hängt nur noch an `kmod-lib-lzo`: lz4 lag ungenutzt im Image (zram nimmt lzo), ~13 KiB weniger Rootfs. RAM-Druck am Testgerät beobachten | eigen, Freigabe adorfer 04.10.2026 |
| `lowflash/upgrade-helpers-tiny.sh` | post-update | base-files: `allnet.sh`, `dir825.sh`, `merakinand.sh`, `openmesh.sh` nur in ar71xx/tiny weglassen; kein tiny-Board ruft sie auf (Abgleich platform.sh gegen Gluons tiny-Liste), ~6 KiB | eigen, Auftrag adorfer 04.10.2026 |
| `security/batman-adv-2024.3.sh` | pre-update | Modulpatch für packages/routing: batman-adv und batctl 2024.3 (Basis Gluon-PR #3377 mit 4.14-Compat und noflood) plus alle batman-adv-Patches aus openwrt-24.10 und vier weitere Upstream-Fixes; deckt alle batman-adv-CVEs bis 03.10.2026. Grund: Sackgassen-Knoten mit 2019.2 würden den Multicast-Pakettyp (ab 2024.0, nur wenn alle Knoten ihn können) in jeder Domain abschalten. Etwa +1,4 KiB | Entscheidung adorfer 04.10.2026; git am auf Modulzweig, fuzz 0, Bau gegen 4.14.275 |
| `security/userspace-backports.sh` | post-update | Sicherheits-Backports als Paketpatches: uhttpd Header-Grenze (GHSA-vhx4-3p5q-m59q), dnsmasq EDNS 1232 als Dreierreihe (CVE-2023-28450; 0126 allein schneidet in 2.80 Antworten ab), uclient, odhcp6c, busybox udhcpc (CVE-2019-5747), ubusd (CVE-2025-62526), Gluon-autoupdater (5521926, e4bd7a4), sse-multiplex FD-Leck (04d2b6f). Zusammen etwa +0,3 KiB | Recherche router-werkstatt `docs/recherche-19.07/`; fuzz 0 gegen die echten Quellstände, Paketbau gcc 7.5.0 |
| `gluon-config-mode/wizard-save-only.sh` | post-update | Wizard: Knopf "Speichern" ohne Neustart, Warnung bei ungespeicherten Eingaben. Unterbau für wizard-save-lock | Patch aus v2025.1.x, form.html für 2021.1-XHTML angepasst (`<input ... />`) |
| `gluon-config-mode/wizard-save-lock.sh` | post-update | Wizard: nur ein "Speichern & Neustarten" gleichzeitig. Doppeltipp startete zwei gluon-reconfigure, Hostname "OpenWrt"/Zeitzone UTC | unverändert aus v2025.1.x; Abgleich der Packages-Session 04.10.2026 |
| `lowmem/limit-wireless-buffers.sh` | post-update | fq_memory_limit gestaffelt wie Gluon 2025.1 (8f38662f) plus unser 2-MB-Deckel; für ≤32 MB 256 KiB wie 2021.1 (128 KiB brachte in der A/B-Messung 04./05.10. weniger Durchsatz bei gleichem RAM-Minimum). Auch per `iw … set txq memory_limit` | Entscheidung adorfer 04.10.2026 (WLAN-Puffer kleiner) |

Weitere Backports für die Sackgasse (dnsmasq CVE-2026-2291, Autoupdater-
und uclient-Fixes) folgen hier.
