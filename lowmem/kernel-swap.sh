#!/bin/bash
#
# Kernel-Swap (fuer zram) auf ath79-generic, ramips-mt76x8 und ramips-mt7620
# wieder an. Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "targets: KERNEL_SWAP auf den Targets mit 64-MB-Geraeten"

apply_patch "$PATCH_DIR/kernel-swap.patch" \
  "targets/ath79-generic" \
  "config('KERNEL_SWAP', true)"
