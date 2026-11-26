#!/bin/bash
#
# gluon-core: 64-MB-sysctl ohne vm.min_free_kbytes=2048 (bricht ath10k
# unter Last). Gluons wirksame Fassung (4820b0b0 = c6ac8914) ist seit dem
# Gluon-Pin ac283dfb im Baum; dieser Patch nimmt nur noch die min_free-Zeile
# heraus. Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut:
#   cd gluon && <dieses Repo>/lowmem/sysctl-64m-min-free.sh

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "gluon-core: sysctl fuer 64-MB-Geraete ohne min_free_kbytes=2048 (bleibt 8192)"

[ -f package/gluon-core/files/lib/gluon/sysctl/memory-64m.conf ] \
  || patch_abort "memory-64m.conf fehlt - Gluon vor 4820b0b0? Dann braucht es die alte Fassung dieses Patches."

apply_patch "$PATCH_DIR/sysctl-64m-min-free.patch"

