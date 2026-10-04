#!/bin/bash
#
# Sicherheits-Backports fuer Userspace-Pakete der Sackgasse (Gluon 2021.1,
# OpenWrt 19.07). Recherche: router-werkstatt docs/recherche-19.07/ (04.10.2026).
#
#   uhttpd 100        Header-Anzahl und -Bytes je Request begrenzen (GHSA-vhx4-
#                     3p5q-m59q): Statusseite sonst per Speicher-DoS aus dem
#                     Client-Netz und Mesh
#   dnsmasq 0124-0126 EDNS-Default 1232 (CVE-2023-28450), 0125 kappt die
#                     weitergereichte Groesse; 0126 allein schneidet in 2.80
#                     grosse Antworten ohne TC-Bit ab, nur als Dreierreihe nehmen
#   uclient 100/101   state-change-Timeout beim Trennen, Content-Length und
#                     Chunk-Groessen pruefen
#   odhcp6c 100       Advertise-IA Overread (WAN), von Hand angepasst
#   busybox 540       udhcpc DHCP_SUBNET-Laenge (CVE-2019-5747)
#   ubus 100-102      ubusd Pattern-Laengen und Event-ACL (CVE-2025-62526)
#   autoupdater 100/101  uclient: early returns, Segfault nach abgebrochenem
#                     HTTP-Request (Gluon-packages 5521926, e4bd7a4)
#   sse-multiplex 100 Pipe-FD-Leck der Statusseite (Gluon-packages 04d2b6f)
#
# Die Patchdateien liegen unter userspace-backports/ in derselben Pfadstruktur
# wie im Gluon-Baum (openwrt/... und packages/gluon/...) und werden in die
# patches/-Verzeichnisse der Pakete kopiert, die es ggf. erst anlegt. Jede Datei
# traegt Original-Commit und Backport-Vermerk im Kopf. Geprueft am 04.10.2026:
# patch --fuzz=0 in Bau-Reihenfolge gegen die echten Quellstaende, Paketbau
# mit gcc 7.5.0/musl (Nachweise in scratch/fixes-2021/userspace/).
#
# Phase post-update: make update setzt openwrt/ und packages/* zurueck.
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SRC="$PATCH_DIR/userspace-backports"

echo "Sicherheits-Backports Userspace (uhttpd, dnsmasq, uclient, odhcp6c, busybox, ubus, autoupdater, sse-multiplex)"

while read -r rel; do
  dir="$(dirname "$rel")"
  pkg="$(dirname "$dir")"
  [ -d "$pkg" ] || patch_abort "Paket $pkg gibt es nicht - passt der Pfad noch zum Baum?"
  mkdir -p "$dir" || patch_abort "$dir liess sich nicht anlegen."
  if [ -f "$rel" ] && cmp -s "$SRC/$rel" "$rel"; then
    echo "  $rel: liegt bereits im Baum."
  else
    cp "$SRC/$rel" "$rel" || patch_abort "$rel liess sich nicht kopieren."
    echo "  $rel: kopiert."
  fi
done < <(cd "$SRC" && find . -type f -name '*.patch' | sed 's|^\./||' | sort)
