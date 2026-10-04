#!/bin/bash
#
# Legt den Paketpatch ab, den Gluon auf das Modul packages/gluon anwendet:
#   0101  autoupdater: feindliche Manifest-Antworten sofort abbrechen statt
#         aussitzen (ueberlange Zeile, endlose Antwort, zu viele Signaturen,
#         Muellzeilen einmal statt je Zeile melden); Begruendung im Patchkopf
#
# STANDARDMAESSIG NICHT AKTIV: steht in apply.sh auskommentiert (adorfer
# 04.10.2026: vorbereiten und bauen, aber nicht in die Builds). Der
# Autoupdater ist die Lifeline der Flotte; scharf erst nach Test am Geraet
# und ausdruecklicher Freigabe.
#
# Laeuft in der Phase pre-update: die Datei landet unter patches/packages/gluon
# im Gluon-Baum, und "make update" spielt sie ueber scripts/patch.sh per
# "git am" auf das Modul ein.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/package-fixes/add-gluon-autoupdater-hardening.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "Gluon-Paketpatch fuer make update bereitlegen (Autoupdater-Haertung)"

AU_SRC="$PATCH_DIR/gluon-packages-autoupdater-reject-hostile-manifest.patch"
AU_DST="patches/packages/gluon/0101-autoupdater-stop-reading-hostile-manifest-responses.patch"
[ -f "$AU_SRC" ] || patch_abort "$AU_SRC fehlt."
mkdir -p "$(dirname "$AU_DST")" || patch_abort "$(dirname "$AU_DST") liess sich nicht anlegen."
if [ -f "$AU_DST" ] && cmp -s "$AU_SRC" "$AU_DST"; then
  echo "  $AU_DST: liegt bereits im Baum."
else
  cp "$AU_SRC" "$AU_DST" || patch_abort "$AU_DST liess sich nicht anlegen."
  echo "  $AU_DST: kopiert."
fi
