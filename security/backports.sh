#!/bin/bash
#
# Sicherheits-Backports fuer Gluon v2023.2.x (OpenWrt 23.05, Kernel 5.15).
# Recherche: router-werkstatt docs/recherche-19.07/ (04.10.2026). Fuer 2023.2
# wird nicht mehr gebaut (adorfer), der Code liegt fuer den Fall bereit.
#
#   mac80211 900/901   Mesh-CSA NULL-Deref ueber Funk (CVE-2026-23279) und
#                      mesh_matches_local (CVE-2026-23396); 93e2d04a1888 ist in
#                      backports 6.1.145 schon drin
#   uhttpd 100         Header-Anzahl/-Bytes je Request begrenzen (f6c2fcfa,
#                      GHSA-vhx4-3p5q-m59q)
#   pending-5.15 985   l2tp: skb-Control-Buffer beim Senden leeren. Gluons
#                      eigener Patch liegt unter pending-6.6 und wird von 23.05
#                      (Kernel 5.15) nie angewendet
#   batman-adv 0100-0103  CVE-2026-31659, -52916 (+kernel-doc), -72226, wie
#                      openwrt-24.10 0014/0038/0040/0088
#
# Stand Gluon v2023.2.x 670b51ba (OpenWrt 33063b4ccf00, routing fa22ff1f).
# Geprueft am 04.10.2026: fuzz 0 in Bau-Reihenfolge, Kompilierprobe mips_24kc
# gcc 12.3, uhttpd-Lauftest (Nachweise in scratch/fixes-2023.2/).
#
# Phase post-update: make update setzt openwrt/ und packages/* zurueck.
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SRC="$PATCH_DIR/backports"

echo "Sicherheits-Backports 2023.2 (mac80211, uhttpd, l2tp, batman-adv)"

while read -r rel; do
  dir="$(dirname "$rel")"
  parent="$(dirname "$dir")"
  [ -d "$parent" ] || patch_abort "$parent gibt es nicht - passt der Pfad noch zum Baum?"
  mkdir -p "$dir" || patch_abort "$dir liess sich nicht anlegen."
  if [ -f "$rel" ] && cmp -s "$SRC/$rel" "$rel"; then
    echo "  $rel: liegt bereits im Baum."
  else
    cp "$SRC/$rel" "$rel" || patch_abort "$rel liess sich nicht kopieren."
    echo "  $rel: kopiert."
  fi
done < <(cd "$SRC" && find . -type f -name '*.patch' | sed 's|^\./||' | sort)
