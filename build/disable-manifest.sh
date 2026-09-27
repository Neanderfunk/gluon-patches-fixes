#!/bin/bash
#
# image-customization.lua: disable_manifest() - ein Geraet bekommt seine
# Images, erscheint aber nicht im Autoupdater-Manifest. Einzelheiten im
# Patchkopf.
#
# Phase pre-update: Der Patch aendert nur Gluons scripts/ und docs/, die
# "make update" nicht anfasst. Spaeter waere zu spaet - schon "make clean"
# wertet image-customization.lua aus, und ein Aufruf von disable_manifest()
# scheitert dann mit "attempt to call global 'disable_manifest'".
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "image-customization: disable_manifest()"

apply_patch "$PATCH_DIR/disable-manifest.patch" \
  "scripts/generate_manifest.lua" \
  'no_manifest'
