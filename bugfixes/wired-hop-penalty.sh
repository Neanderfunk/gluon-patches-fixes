#!/bin/bash
#
# gluon_wired: hop_penalty als Protokoll-Option anmelden, damit die
# Hop-Penalty fuer Kabel-Mesh (gluon.iface_*.batadv_hop_penalty) bei
# batman-adv ankommt. Ohne den Patch bleibt sie am Kabel immer 0.
# Einzelheiten im Patchkopf.
#
# Aendert eine Datei aus Gluons eigenem package/, die "make update" nicht
# anfasst; Phase post-update.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "gluon_wired: hop_penalty als Option anmelden"

apply_patch "$PATCH_DIR/wired-hop-penalty.patch" \
  "package/gluon-core/files/lib/netifd/proto/gluon_wired.sh" \
  'proto_config_add_int hop_penalty'
