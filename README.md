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
| `bugfixes/tunneldigger-reinit-backoff.sh` | pre-update | tunneldigger: Reinit mit Pause, kein modprobe für ein fehlendes mesh-vpn (Client aus dem packages-Feed, unverändert 2021-03-08) | |
| `bugfixes/perl-no-parallel.sh` | pre-update | perl im packages-Feed seriell bauen: parallel scheitert es sporadisch an einer Race Condition (openwrt/packages#8238), kommt über `ALL_NONSHARED` in jeden Bau | Patch aus Gluon v2023.2.x (Martin Weinelt), für 24.10 neu erzeugt; entfällt, wenn upstream seriell baut |
| `lowmem/limit-wireless-buffers.sh` | post-update | WLAN-Puffer auch oberhalb 128 MB auf 2 MB deckeln (8f38662f ist in 2025.1 enthalten, übrig bleibt unsere Abweichung) | |
| `lowmem/sysctl-no-watermark-boost-64mb.sh` | post-update | kein Watermark-Boost auf 64-MB-Geräten | |
| `bugfixes/sysctl-firmware-no-sysfs-fallback.sh` | post-update | kein sysfs-Fallback für fehlende Firmware (sonst 60 s Boot-Stillstand) | |
| `lowmem/sysctl-64m-min-free.sh` | post-update | Gluons 64-MB-sysctl wirksam machen (Fix c6ac8914 fehlt in 2025.1) und dabei **ohne** `vm.min_free_kbytes=2048` (bricht ath10k unter WLAN-Last) | Fix aus Gluon c6ac8914 |
| `gluon-config-mode/wizard-save-only.sh` | post-update | Wizard mit „Speichern“ ohne Neustart, Warnung beim Verlassen | |
| `gluon-config-mode/wizard-save-lock.sh` | post-update | nur ein „Speichern & Neustarten“ gleichzeitig | |
| `gluon-config-mode/outdoor-schalter.sh` | post-update | Outdoor-Schalter unabhängig von `preserve_channels` | |
| `lowmem/state-check-shell.sh` | post-update | gluon-state-check als Shell statt Lua | |
| `lowmem/tunneldigger-watchdog-shell.sh` | post-update | tunneldigger-watchdog als Shell statt Lua; seit 2025.1 im Paket `ff-mesh-vpn-tunneldigger` der community-packages | |
| `build/disable-manifest.sh` | pre-update | `disable_manifest()` in image-customization.lua: Images bauen, aber nicht ins Autoupdater-Manifest (EdgeRouter X bis zur Migration: sonst laedt ein ERX auf 2023.2 stuendlich ein Image mit fremdem Compat-Level) | |

## Abhängigkeiten

* `gluon-config-mode/wizard-save-lock.sh` setzt `wizard-save-only.sh` voraus.
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
