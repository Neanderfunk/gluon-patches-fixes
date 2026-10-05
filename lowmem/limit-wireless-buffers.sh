#!/bin/bash
#
# WLAN-Puffer (fq_memory_limit) nach RAM staffeln, fuer 32 MB 256 KiB.
# Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "WLAN-Puffer nach RAM staffeln (32 MB: 256 KiB)"

apply_patch "$PATCH_DIR/limit-wireless-buffers.patch" \
  "package/gluon-core/files/etc/hotplug.d/ieee80211/01-gluon-core-codel-memusage" \
  "LIMIT=262144"
