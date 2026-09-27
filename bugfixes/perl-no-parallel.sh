#!/bin/bash
#
# perl im packages-Feed seriell bauen. Parallel scheitert der Bau bei vielen
# Kernen sporadisch an einer Race Condition (openwrt/packages#8238); Gluon
# v2023.2.x hatte dafuer denselben Patch, Gluon 2025.1 patcht den
# packages-Feed nicht mehr. perl kommt ueber Gluons ALL_NONSHARED in jeden
# Bau, auch ohne dass ein Geraet es auswaehlt. Einzelheiten im Patchkopf.
#
# Modulpatch fuer "git am": liegt unter patches/packages/packages/ im
# Gluon-Baum, "make update" spielt ihn ein (scripts/patch.sh). Deshalb Phase
# pre-update.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

SRC_PATCH="0001-perl-don-t-build-in-parallel.patch"
MODULE_DIR="patches/packages/packages"
TARGET="$MODULE_DIR/$SRC_PATCH"

echo "perl: nicht parallel bauen (Modulpatch)"

[ -f "$PATCH_DIR/$SRC_PATCH" ] || patch_abort "$SRC_PATCH fehlt in patches/."
# Gluon 2025.1 legt das Verzeichnis selbst nicht mehr an.
mkdir -p "$MODULE_DIR" || patch_abort "$MODULE_DIR liess sich nicht anlegen."

# Eine vorhandene, aber veraltete Kopie (unversioniert, ueberlebt git reset)
# wird ersetzt.
if [ -f "$TARGET" ] && cmp -s "$PATCH_DIR/$SRC_PATCH" "$TARGET"; then
  echo "  $TARGET: liegt bereits im Baum."
else
  cp "$PATCH_DIR/$SRC_PATCH" "$TARGET" || patch_abort "$TARGET liess sich nicht anlegen."
  chmod 644 "$TARGET"
  echo "  $TARGET: angelegt."
fi
