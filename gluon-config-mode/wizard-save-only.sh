#!/bin/bash
#
# Config-Mode-Wizard: Knopf "Speichern" ohne Neustart und Warnung beim
# Verlassen mit ungespeicherten Eingaben. Einzelheiten im Patchkopf.
#
# 2021.1: Patch aus v2025.1.x, form.html an XHTML angepasst (Gluon 2021.1
# liefert die Seiten als application/xhtml+xml: <input ... />, sonst bricht
# der Browser die ganze Seite ab). Unterbau fuer wizard-save-lock.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "Config-Mode: Wizard mit 'Speichern' ohne Neustart"

apply_patch "$PATCH_DIR/wizard-save-only.patch" \
  "package/gluon-config-mode-core/luasrc/lib/gluon/config-mode/model/gluon-config-mode/wizard.lua" \
  'save-only=1'
