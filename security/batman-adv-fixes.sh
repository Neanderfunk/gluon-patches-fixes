#!/bin/bash
#
# batman-adv 2024.3: vier Upstream-Fixes, die in OpenWrt routing openwrt-24.10
# (Stand 00619bc7, 0001-0101) noch fehlen. Keine CVE; alle greifen bei einer
# Race oder einer gescheiterten Allokation (RAM-Druck auf 64-MB-Geraeten):
#   0102 742a0e35  tt: nur den nachgeschlagenen Eintrag aus dem Hash entfernen
#   0103 d0ded7c5  bla: backbone lasttime nur bei geaendertem Backbone
#   0104 9c7a6f34  bla: kein Double Free nach gescheiterter backbone_hash-Allokation
#   0105 745e4677  kein WARN_ON bei gescheiterter orig_ifinfo-Allokation
# Dieselben Dateien wie in v2021.1.x (batman-adv 2024.3 der Sackgasse).
# Geprueft am 04.10.2026: Tarball 2024.3 + routing 00619bc7 0001-0101 + diese
# vier + Gluons 2002-noflood, alles fuzz 0; Kompilierprobe gegen Linux 6.6.144
# x86_64 (installer/gluon, gcc 13.3.0), ohne Warnung, modpost ok.
# Faellt weg, sobald openwrt-24.10 die Fixes bringt (dann scheitert der
# Paketbau laut an doppelten Hunks).
#
# Phase post-update. Wird aus dem Gluon-Verzeichnis heraus aufgerufen.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SRC="$PATCH_DIR/packages/routing/batman-adv/patches"
DST="packages/routing/batman-adv/patches"

echo "batman-adv: vier Upstream-Fixes nach openwrt-24.10 (0102-0105)"

[ -d "$DST" ] || patch_abort "$DST gibt es nicht - passt der Pfad noch zum Baum?"
for f in "$SRC"/*.patch; do
  t="$DST/$(basename "$f")"
  if [ -f "$t" ] && cmp -s "$f" "$t"; then
    echo "  $t: liegt bereits im Baum."
  else
    [ -e "$t" ] && patch_abort "$t existiert mit anderem Inhalt - hat routing die Nummer belegt?"
    cp "$f" "$t" || patch_abort "$t liess sich nicht kopieren."
    echo "  $t: kopiert."
  fi
done
