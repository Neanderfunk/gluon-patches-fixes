#!/bin/bash
#
# ar71xx-tiny: Upgrade-Helfer fuer Boardfamilien ohne tiny-Geraet (allnet,
# dir825, merakinand, openmesh) aus dem Image nehmen, ~6 KiB Flash.
# Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "base-files: fremde Upgrade-Helfer aus ar71xx/tiny"

enter_dir openwrt

apply_patch "$PATCH_DIR/upgrade-helpers-tiny.patch" \
  "package/base-files/Makefile" \
  "filter ar71xx/tiny"
