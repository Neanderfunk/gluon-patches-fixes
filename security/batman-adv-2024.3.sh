#!/bin/bash
#
# batman-adv und batctl 2024.3 statt 2019.2, mit den Fixes aus OpenWrt routing
# openwrt-24.10 (Entscheidung adorfer 04.10.2026, "Weg 2").
#
# Warum nicht 2019.2 mit Einzel-Backports: Den Multicast-Pakettyp von
# batman-adv 2024.0 nutzt ein Mesh nur, wenn ALLE Knoten ihn koennen
# (batman-adv be9b0169). Sackgassen-Knoten stehen in allen Domains und bekommen
# nie etwas Neueres als 2021.1; mit 2019.2 wuerden sie ihn ueberall dauerhaft
# abschalten. Dazu kommen die batman-adv-CVEs aus 2026 (u. a. -52916, -31659,
# -72226), die im offenen Mesh von aussen ausloesbar sind; 24.10 hat sie alle.
#
# Inhalt des Modulpatches (Einzelheiten im Kopf der Patchdatei):
#   - Basis Gluon-PR #3377 (Linus Luessing; so auch ffac/site v2021.1.x und
#     Freifunk Luebeck): 4.14-Compat-Reverts, noflood mark, multicast-router-Hack
#   - batman-adv/patches 0001-0101 unveraendert aus openwrt-24.10 (78bcc66),
#     0102-0105 Upstream-Fixes, die in 24.10 noch fehlen
#   - batctl 2024.3 (2019.2 ist gegen ein 2024.3-Modul nirgends erprobt)
#   Netlink-Nummern inkl. noflood sind gleich, libbatadv/respondd/Statusseite
#   brauchen keine Aenderung. Flash: etwa +1,4 KiB (2024.3 ohne sysfs/debugfs).
#
# Geprueft am 04.10.2026: git am auf den Modulzweig "patched" (routing 820bb60a
# plus Gluons 0001-0004), alle Paketpatches fuzz 0 auf den 2024.3-Tarball, Bau
# gegen Kernel 4.14.275 mit gcc 7.5.0. Nachweise in scratch/fixes-2021/batman-2024/.
#
# Phase pre-update: legt den Patch unter patches/packages/routing/ ab, "make
# update" spielt ihn per git am ein (wie tunneldigger-reinit-backoff.sh).
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SRC_PATCH="0101-batman-adv-batctl-update-to-2024.3-with-fixes-from-o.patch"
MODULE_DIR="patches/packages/routing"
TARGET="$MODULE_DIR/$SRC_PATCH"

echo "batman-adv/batctl 2024.3 mit Fixes aus openwrt-24.10 (Modulpatch)"

[ -f "$PATCH_DIR/$SRC_PATCH" ] || patch_abort "$SRC_PATCH fehlt in security/."
[ -d "$MODULE_DIR" ] || patch_abort "$MODULE_DIR fehlt - passt der Gluon-Baum noch?"

if [ -f "$TARGET" ] && cmp -s "$PATCH_DIR/$SRC_PATCH" "$TARGET"; then
  echo "  $TARGET: liegt bereits im Baum."
else
  cp "$PATCH_DIR/$SRC_PATCH" "$TARGET" || patch_abort "$TARGET liess sich nicht anlegen."
  chmod 644 "$TARGET"
  echo "  $TARGET: angelegt."
fi
