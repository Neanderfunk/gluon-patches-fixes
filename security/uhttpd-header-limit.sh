#!/bin/bash
#
# uhttpd: Header-Anzahl und -Bytes je Request begrenzen (openwrt/uhttpd
# f6c2fcfa, GHSA-vhx4-3p5q-m59q / CVE-2026-102338). Ohne Grenze haengt jede
# Headerzeile am Heap; eine einzige Verbindung ohne abschliessende Leerzeile
# kann den Knoten in den OOM treiben. Port 80 (Statusseite) ist ohne Anmeldung
# aus Client-Netz und Mesh erreichbar. Mit Fix: 100 Header / 16 KiB, sonst 431.
#
# Der Fix ist in OpenWrt main und openwrt-25.12, NICHT in openwrt-24.10 (uhttpd
# 7e64e8ba mit Paketpatches 0001-0017). 0018 ist f6c2fcfa unveraendert, passt
# ohne Versatz hinter 0017. Recherche: router-werkstatt docs/recherche-19.07/.
# Faellt weg, sobald OpenWrt 24.10 den Fix selbst mitbringt (dann scheitert
# der Paketbau laut an 0018).
#
# Phase post-update. Wird aus dem Gluon-Verzeichnis heraus aufgerufen.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SRC="$PATCH_DIR/openwrt"

echo "uhttpd: Header-Begrenzung je Request (f6c2fcfa)"

enter_dir openwrt

while read -r rel; do
  dir="$(dirname "$rel")"
  [ -d "$dir" ] || patch_abort "$dir gibt es nicht - passt der Pfad noch zum Baum?"
  if [ -f "$rel" ] && cmp -s "$SRC/$rel" "$rel"; then
    echo "  $rel: liegt bereits im Baum."
  else
    cp "$SRC/$rel" "$rel" || patch_abort "$rel liess sich nicht kopieren."
    echo "  $rel: kopiert."
  fi
done < <(cd "$SRC" && find . -type f -path '*uhttpd*' -name '*.patch' | sed 's|^\./||' | sort)
