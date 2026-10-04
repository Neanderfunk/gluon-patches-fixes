#!/bin/bash
#
# kmod-zram nur mit lzo, ohne kmod-lib-lz4 (ungenutzt, ~13 KiB Flash).
# Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "kmod-zram: nur lzo, ohne lz4"

enter_dir openwrt

apply_patch "$PATCH_DIR/zram-lzo-only.patch" \
  "package/kernel/linux/modules/other.mk" \
  "DEPENDS:=+kmod-lib-lzo$"
