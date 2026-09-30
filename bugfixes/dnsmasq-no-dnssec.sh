#!/bin/bash
#
# dnsmasq-full ohne DNSSEC: spart libnettle8 und libgmp10 (rund 460 KB im
# squashfs, also ebenso viel jffs2-Overlay auf NOR-Geraeten). Einzelheiten im
# Patchkopf.
#
# Aendert Gluons targets/generic, das "make update" nicht anfasst und das schon
# "make clean" auswertet; deshalb Phase pre-update.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "dnsmasq-full ohne DNSSEC"

apply_patch "$PATCH_DIR/dnsmasq-no-dnssec.patch" \
  "targets/generic" \
  'PACKAGE_dnsmasq_full_dnssec'
