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
png assembly g_assemblage     "$CAM"
png product  g_product        "$CAM"
png exploded g_explosietekening "$CAM"
png inner    g_binnenring      "$CAM"
png outer    g_middenring      "$CAM"
png handle   g_handvat         "$CAM"
png plate    g_printplaat      "0,0,0,55,0,25,0"
png product  g_top             "0,0,0,0,0,0,0"

echo ">> STL export"
stl inner  gimbal_binnenring
stl outer  gimbal_middenring
stl handle gimbal_handvat
stl plate  gimbal_printplaat_compleet

echo ">> Overzichtsblad"
montage \
  img/g_assemblage.png img/g_product.png img/g_explosietekening.png \
  img/g_binnenring.png img/g_middenring.png img/g_handvat.png \
  -tile 3x2 -geometry 520x400+8+8 -background white \
  -title "Bekerhouder V4 - GIMBAL (2 draaiassen) - Bram, Ruben, Wander & Jelle" \
  img/g_overzicht.png

echo ">> Klaar"; ls -la stl/gimbal_* img/g_*.png
