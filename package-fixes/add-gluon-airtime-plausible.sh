#!/bin/bash
#
# Legt den Paketpatch ab, den Gluon auf das Modul packages/gluon anwendet:
#   0100  respondd-module-airtime: busy/rx/tx groesser als active weglassen
#         (mt76 meldet untergelaufene Survey-Zaehler, die Karte zeigt sonst
#         Kanalauslastung weit ueber 100 %); Begruendung im Patchkopf
#
# Laeuft in der Phase pre-update: die Datei landet unter patches/packages/gluon
# im Gluon-Baum, und "make update" spielt sie ueber scripts/patch.sh per
# "git am" auf das Modul ein.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/package-fixes/add-gluon-airtime-plausible.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "Gluon-Paketpatch fuer make update bereitlegen (Airtime-Plausibilitaet)"

# 0100 liegt als fertiger git-am-Patch in diesem Verzeichnis. Eine
# vorhandene, aber veraltete Kopie (unversioniert, ueberlebt git reset) wird
# ersetzt.
AIRTIME_SRC="$PATCH_DIR/gluon-packages-airtime-plausible.patch"
AIRTIME_DST="patches/packages/gluon/0100-respondd-module-airtime-leave-out-busy-rx-tx-larger-than-active.patch"
[ -f "$AIRTIME_SRC" ] || patch_abort "$AIRTIME_SRC fehlt."
mkdir -p "$(dirname "$AIRTIME_DST")" || patch_abort "$(dirname "$AIRTIME_DST") liess sich nicht anlegen."
if [ -f "$AIRTIME_DST" ] && cmp -s "$AIRTIME_SRC" "$AIRTIME_DST"; then
  echo "  $AIRTIME_DST: liegt bereits im Baum."
else
  cp "$AIRTIME_SRC" "$AIRTIME_DST" || patch_abort "$AIRTIME_DST liess sich nicht anlegen."
  echo "  $AIRTIME_DST: kopiert."
fi
