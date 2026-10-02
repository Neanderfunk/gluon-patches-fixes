#!/bin/bash
#
# apply.sh <pre-update|post-update>
#
# Wendet die Patches dieses Repos auf einen Gluon-Baum an, in fester
# Reihenfolge. Aufruf aus dem Gluon-Verzeichnis, einmal je Phase:
#
#   cd gluon
#   <dieses Repo>/apply.sh pre-update     vor  "make update"
#   make update
#   <dieses Repo>/apply.sh post-update    nach "make update"
#
# pre-update legt Dateien unter patches/openwrt oder patches/packages im
# Gluon-Baum ab, die "make update" per "git am" auf die Module einspielt.
# Alles andere, insbesondere jeder Patch am OpenWrt-Baum, gehoert nach
# post-update: "make update" setzt die Module neu auf.
#
# Bricht beim ersten fehlgeschlagenen Skript ab. Einzelne Skripte lassen sich
# genauso allein aufrufen; die Reihenfolge unten ist nur dort wichtig, wo die
# README eine Abhaengigkeit nennt.

set -o errexit -o nounset -o pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PRE_UPDATE=(
  package-fixes/add-gluon-airtime-plausible.sh  # respondd-module-airtime: unplausible Werte weglassen
  bugfixes/tunneldigger-reinit-backoff.sh       # tunneldigger: Reinit mit Pause, kein modprobe
  bugfixes/perl-no-parallel.sh                  # perl seriell bauen (Race Condition bei -j)
  build/disable-manifest.sh                     # image-customization: disable_manifest() (vor make clean noetig)
  bugfixes/dnsmasq-no-dnssec.sh                 # dnsmasq-full ohne DNSSEC (~460 KB weniger)
)

# Reihenfolge wie im Neanderfunk-Bau. Abhaengig ist nur wizard-save-lock von
# wizard-save-only.
POST_UPDATE=(
  lowmem/limit-wireless-buffers.sh              # WLAN-Puffer nach RAM (Backport Gluon 8f38662f)
  lowmem/sysctl-no-watermark-boost-64mb.sh      # kein Watermark-Boost auf 64-MB-Geraeten
  bugfixes/sysctl-firmware-no-sysfs-fallback.sh # kein 60-s-Boot-Stillstand bei fehlender Firmware
  lowmem/sysctl-64m-min-free.sh                 # kleinere Fragmentpuffer auf 64-MB-Geraeten
  lowmem/kernel-swap.sh                         # KERNEL_SWAP fuer zram auf Targets mit 64-MB-Geraeten
  gluon-config-mode/wizard-save-only.sh         # Wizard: Speichern ohne Neustart
  gluon-config-mode/wizard-save-lock.sh         # Wizard: nur ein Speichern gleichzeitig (nach save-only)
  gluon-config-mode/outdoor-schalter.sh         # Outdoor-Schalter unabhaengig von preserve_channels
  lowmem/state-check-shell.sh                   # gluon-state-check als Shell statt Lua
  lowmem/tunneldigger-watchdog-shell.sh         # tunneldigger-watchdog als Shell statt Lua
  bugfixes/wired-hop-penalty.sh                 # Kabel-Mesh: hop_penalty kommt bei batman-adv an
)

PHASE="${1:-}"
case "$PHASE" in
  pre-update)  LISTE=( "${PRE_UPDATE[@]}" ) ;;
  post-update) LISTE=( "${POST_UPDATE[@]}" ) ;;
  *)
    echo "Aufruf: $0 pre-update|post-update (aus dem Gluon-Verzeichnis)" >&2
    exit 2
    ;;
esac

if [ ! -f Makefile ] || [ ! -f modules ] || [ ! -d package ]; then
  echo "apply.sh: $(pwd) sieht nicht nach einem Gluon-Verzeichnis aus." >&2
  exit 2
fi

echo "$(basename "$REPO_DIR"): Phase $PHASE, ${#LISTE[@]} Skript(e)"
for SKRIPT in "${LISTE[@]}"; do
  [ -x "$REPO_DIR/$SKRIPT" ] || { echo "apply.sh: $SKRIPT fehlt oder ist nicht ausfuehrbar." >&2; exit 1; }
  echo "== $SKRIPT"
  # Subshell: ein cd im Skript (etwa nach openwrt) betrifft das naechste nicht.
  ( "$REPO_DIR/$SKRIPT" ) || { echo "apply.sh: $SKRIPT fehlgeschlagen." >&2; exit 1; }
done
