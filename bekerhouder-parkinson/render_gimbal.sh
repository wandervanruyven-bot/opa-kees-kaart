#!/usr/bin/env bash
# Rendert previews (PNG) en exporteert STL's voor de GIMBAL-versie (V4).
set -e
cd "$(dirname "$0")"
SCAD=src/bekerhouder_gimbal.scad
CAM="0,0,0,62,0,28,0"
SIZE="1100,850"

png () { xvfb-run -a openscad -o "img/$2.png" --projection=perspective \
  --camera="$3" --viewall --autocenter --imgsize=$SIZE -D "part=\"$1\"" "$SCAD"; }
stl () { xvfb-run -a openscad --export-format binstl -o "stl/$2.stl" \
  -D "part=\"$1\"" "$SCAD"; }

echo ">> PNG previews"
png assembly      g_assemblage      "$CAM"
png assembly_hand g_hand            "0,0,0,68,0,30,0"
png product       g_product         "$CAM"
png exploded      g_explosietekening "$CAM"
png section       g_doorsnede       "0,0,0,80,0,12,0"
png inner         g_binnenring       "$CAM"
png outer         g_middenring       "$CAM"
png handle        g_handvat          "$CAM"
png beugel        g_beugel           "$CAM"
png grip          g_greep            "0,0,0,55,0,30,0"
png plate         g_printplaat       "0,0,0,55,0,25,0"
png product       g_top              "0,0,0,0,0,0,0"

echo ">> STL export"
stl inner  gimbal_binnenring
stl outer  gimbal_middenring
stl beugel gimbal_handvat_beugel
stl grip   gimbal_handvat_greep
stl handle gimbal_handvat_1geheel
stl plate  gimbal_printplaat_compleet

echo ">> Overzichtsblad"
montage \
  img/g_assemblage.png img/g_hand.png \
  img/g_binnenring.png img/g_middenring.png \
  img/g_beugel.png img/g_greep.png \
  -tile 2x3 -geometry 540x415+8+8 -background white \
  -title "Bekerhouder V4 - GIMBAL met lushandvat - Bram, Ruben, Wander & Jelle" \
  img/g_overzicht.png

echo ">> Klaar"; ls -la stl/gimbal_*
