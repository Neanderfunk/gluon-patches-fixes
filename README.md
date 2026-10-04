# Gluon-Patches: Fehlerbehebungen

*Patches for Gluon v2025.1.x / OpenWrt 24.10 that fix system behaviour
independent of the device: relief for 64 MB devices, boot stalls, tunneldigger
retries, config-mode wizard, two package patches, and disable_manifest() for
image-customization.lua. Used by Freifunk im
Neanderland (Neanderfunk). Each script can be used on its own; `apply.sh`
applies all of them in order.*

Korrekturen am Systemverhalten, unabhängig vom Gerät. Nichts davon hängt an
den Paketen oder der Site-Konfiguration von Neanderfunk.

Die Zweige folgen Gluon: dieser Zweig `v2025.1.x` passt zu Gluon v2025.1.x
(OpenWrt 24.10, Kernel 6.6); `v2023.2.x` zu Gluon v2023.2.x (OpenWrt 23.05,
Kernel 5.15).

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
| `package-fixes/add-gluon-airtime-plausible.sh` | pre-update | respondd-module-airtime: busy/rx/tx größer als active weglassen (mt76 meldet untergelaufene Survey-Zähler, Karten zeigen sonst Kanalauslastung weit über 100 %) | |
| `package-fixes/add-gluon-autoupdater-hardening.sh` | pre-update | **nicht aktiv, in `apply.sh` auskommentiert.** Autoupdater: feindliche Manifest-Antworten sofort abbrechen statt bis zum Timeout (300 s) aussitzen: überlange Zeile, Antwort über 1 MiB, mehr als 64 Signaturen; Müllzeilen im Signaturbereich einmal je Lauf melden statt je Zeile. Gültige Manifeste unverändert | Vorlage neanderfunk-nodeplacer-dev `fdc3b58`/`09ec610`; upstream main und unser Pin (packages `43eb729`) haben die Stellen unverändert, kein Upstream-Fix (Stand 04.10.2026). Gebaut für mipsel_24kc (+384 Byte), am Gerät noch nicht getestet |
| `bugfixes/tunneldigger-reinit-backoff.sh` | pre-update | tunneldigger: Reinit mit Pause, kein modprobe für ein fehlendes mesh-vpn (Client aus dem packages-Feed, unverändert 2021-03-08) | |
| `bugfixes/perl-no-parallel.sh` | pre-update | perl im packages-Feed seriell bauen: parallel scheitert es sporadisch an einer Race Condition (openwrt/packages#8238), kommt über `ALL_NONSHARED` in jeden Bau | Patch aus Gluon v2023.2.x (Martin Weinelt), für 24.10 neu erzeugt; entfällt, wenn upstream seriell baut |
| `lowmem/limit-wireless-buffers.sh` | post-update | WLAN-Puffer auch oberhalb 128 MB auf 2 MB deckeln (8f38662f ist in 2025.1 enthalten, übrig bleibt unsere Abweichung) | |
| `lowmem/sysctl-no-watermark-boost-64mb.sh` | post-update | kein Watermark-Boost auf 64-MB-Geräten | |
| `lowmem/kernel-swap.sh` | post-update | `KERNEL_SWAP` auf ath79-generic, ramips-mt76x8, ramips-mt7620 wieder an (Gluon 2025.1 schaltet ihn in `targets/generic` ab, zram-swap lief ins Leere) | |
| `bugfixes/sysctl-firmware-no-sysfs-fallback.sh` | post-update | kein sysfs-Fallback für fehlende Firmware (sonst 60 s Boot-Stillstand) | |
| `lowmem/sysctl-64m-min-free.sh` | post-update | Gluons 64-MB-sysctl wirksam machen (Fix c6ac8914 fehlt in 2025.1) und dabei **ohne** `vm.min_free_kbytes=2048` (bricht ath10k unter WLAN-Last) | Fix aus Gluon c6ac8914 |
| `gluon-config-mode/wizard-save-only.sh` | post-update | Wizard mit „Speichern“ ohne Neustart, Warnung beim Verlassen | |
| `gluon-config-mode/wizard-save-lock.sh` | post-update | nur ein „Speichern & Neustarten“ gleichzeitig | |
| `gluon-config-mode/outdoor-schalter.sh` | post-update | Outdoor-Schalter unabhängig von `preserve_channels` | |
| `gluon-config-mode/wifi-txpower-save.sh` | post-update | Sendeleistung aus den Erweiterten Einstellungen kommt wirklich in `/etc/config/wireless` (`uci:save('wireless')` vor `gluon-reconfigure`, committet von 998-commit) | Fehler aus Gluon 2025.1: dort wird nur noch gluon committet; upstream main/v2025.1.x noch offen (Stand 03.10.2026); am WDR3600 nachgestellt und mit Patch validiert |
| `lowmem/state-check-shell.sh` | post-update | gluon-state-check als Shell statt Lua | |
| `lowmem/tunneldigger-watchdog-shell.sh` | post-update | tunneldigger-watchdog als Shell statt Lua; seit 2025.1 im Paket `ff-mesh-vpn-tunneldigger` der community-packages | |
| `bugfixes/wired-hop-penalty.sh` | post-update | Kabel-Mesh: `gluon_wired` meldet `hop_penalty` nicht als Option an, die Hop-Penalty am Kabel bleibt sonst immer 0 (WLAN und VPN nicht betroffen) | Fehler aus Gluon 0c30629 (PR #3454, Merge 9143b02): der PR meldet die Option nur in `gluon_mesh` an; kein Backport, sondern die fehlende Zeile. Upstream noch offen (main/v2025.1.x/next, Stand 02.10.2026); entfällt, wenn Gluon die Option anmeldet |
| `security/uhttpd-header-limit.sh` | post-update | uhttpd: höchstens 100 Header / 16 KiB je Request, sonst 431. Ohne Grenze Speicher-DoS über Port 80 aus Client-Netz und Mesh, ohne Anmeldung (GHSA-vhx4-3p5q-m59q) | openwrt/uhttpd `f6c2fcfa` unverändert als Paketpatch 0018; in openwrt-25.12 und main enthalten, in 24.10 nicht (Stand 04.10.2026). Entfällt, wenn 24.10 nachzieht |
| `build/disable-manifest.sh` | pre-update | `disable_manifest()` in image-customization.lua: Images bauen, aber nicht ins Autoupdater-Manifest (EdgeRouter X bis zur Migration: sonst laedt ein ERX auf 2023.2 stuendlich ein Image mit fremdem Compat-Level) | |
| `bugfixes/dnsmasq-no-dnssec.sh` | pre-update | dnsmasq-full ohne DNSSEC: spart `libnettle8` und `libgmp10`, rund 460 KB squashfs und damit ebenso viel Overlay auf 8-MB-NOR-Geräten | Gluon schaltet die übrigen dnsmasq-full-Optionen schon ab, DNSSEC nicht |

## Abhängigkeiten

* `gluon-config-mode/wizard-save-lock.sh` setzt `wizard-save-only.sh` voraus.
* `gluon-config-mode/wifi-txpower-save.sh` setzt `outdoor-schalter.sh` voraus (gleiche Datei).
* pre-update-Skripte wirken nur, wenn danach `make update` läuft.
* `lowmem/tunneldigger-watchdog-shell.sh` braucht die
  [community-packages](https://github.com/freifunk-gluon/community-packages)
  als Site-Feed (Paket `ff-mesh-vpn-tunneldigger`), unter beliebigem Namen.
* Die übrigen Skripte sind voneinander unabhängig.

## Entfernt

Gegenüber `v2023.2.x` (27.09.2026): `package-fixes/add-ffac-package-patches.sh`
mit `ffac-packages.patch`. Das Paket `ffac-mt7915-maxinactivity` gibt es unter
2025.1 nicht mehr (die ffac-Pakete sind in die community-packages gewandert,
dort liegt nur `ffac-mt7915-hotfix`).

## Herkunft und Lizenz

Herausgelöst aus Neanderfunk/FirmwareConfigs (bis September 2026
Neanderfunk/firmware), Stand `851194f217a7fb165d101ed9c7b12a2597a9029e`,
Verzeichnis `patches/`. Die Geschichte der einzelnen Dateien steht dort.
`package-fixes/add-gluon-airtime-plausible.sh` ist der Airtime-Teil des dortigen
`build/add-gluon-package-patches.sh`.

`lib-patch.sh` ist eine Kopie; jedes Patch-Repo trägt seine eigene, damit es
allein nutzbar bleibt.

Skripte (`apply.sh`, `lib-patch.sh`, `*/*.sh`): BSD-3-Clause, siehe
`LICENSE`. Patchdateien stehen unter der Lizenz des Projekts, das sie
ändern: Gluon BSD-2-Clause, OpenWrt, die Paketfeeds und Linux in der Regel
GPL-2.0.
