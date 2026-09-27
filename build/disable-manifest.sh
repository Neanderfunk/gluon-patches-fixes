#!/bin/bash
#
# image-customization.lua: disable_manifest() - ein Geraet bekommt seine
# Images, erscheint aber nicht im Autoupdater-Manifest. Einzelheiten im
# Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "image-customization: disable_manifest()"

apply_patch "$PATCH_DIR/disable-manifest.patch" \
  "scripts/generate_manifest.lua" \
  'no_manifest'
