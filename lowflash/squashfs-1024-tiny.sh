#!/bin/bash
#
# ar71xx-tiny: squashfs mit 1024-KiB-Bloecken statt 256 KiB, spart auf den
# 4-MB-Geraeten rund 73 KiB Flash. Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "targets: ar71xx-tiny mit 1024-KiB-squashfs-Bloecken"

apply_patch "$PATCH_DIR/squashfs-1024-tiny.patch" \
  "targets/ar71xx-tiny" \
  "config('TARGET_SQUASHFS_BLOCK_SIZE', 1024)"
