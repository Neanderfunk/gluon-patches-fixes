#!/bin/bash
#
# tunneldigger-watchdog als Shell-Skript statt Lua: auf 64-MB-Geraeten kam
# die Lua-Laufzeit alle 5 Minuten vom Flash. Einzelheiten im Patchkopf.
#
# Wird aus dem Gluon-Verzeichnis heraus aufgerufen, so wie apply.sh es tut.

. "$(dirname "${BASH_SOURCE[0]}")/../lib-patch.sh"

echo "tunneldigger-watchdog: Shell statt Lua"

# Seit Gluon 2025.1 kommt tunneldigger als ff-mesh-vpn-tunneldigger aus den
# community-packages (Gluon #3109); der Watchdog dort ist byte-gleich mit dem
# frueheren aus Gluon. Das Paket liegt nach "make update" unter
# packages/<feedname>/, der Feedname kommt aus der site. Die Pfade im Patch
# sind deshalb relativ zum Paketverzeichnis.
PKG_DIRS=( packages/*/ff-mesh-vpn-tunneldigger )
[ -d "${PKG_DIRS[0]}" ] \
  || patch_abort "ff-mesh-vpn-tunneldigger nicht unter packages/*/ gefunden - ist der community-Feed in der site eingetragen?"
(( ${#PKG_DIRS[@]} == 1 )) \
  || patch_abort "ff-mesh-vpn-tunneldigger liegt mehrfach vor: ${PKG_DIRS[*]}"
enter_dir "${PKG_DIRS[0]}"

apply_patch "$PATCH_DIR/tunneldigger-watchdog-shell.patch" \
  "files/usr/bin/tunneldigger-watchdog"
[ ! -e "luasrc/usr/bin/tunneldigger-watchdog" ] \
  || patch_abort "Die Lua-Fassung von tunneldigger-watchdog ist noch da."
chmod 755 "files/usr/bin/tunneldigger-watchdog"
