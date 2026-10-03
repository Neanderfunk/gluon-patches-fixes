#!/bin/bash
#
# Sendeleistung aus den Erweiterten Einstellungen wirklich speichern - siehe
# Kopf von wifi-txpower-save.patch. Setzt auf outdoor-schalter.sh auf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/gluon-config-mode/wifi-txpower-save.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "Gluon: Sendeleistung aus den Erweiterten Einstellungen speichern"

apply_patch "$PATCH_DIR/wifi-txpower-save.patch" \
  "package/gluon-web-wifi-config/luasrc/lib/gluon/config-mode/model/admin/wifi-config.lua" \
  "uci:save('wireless')"
