#!/usr/bin/env bash
# Rendert previews (PNG) en exporteert printbare STL-bestanden.
set -e
cd "$(dirname "$0")"
SCAD=src/bekerhouder.scad
CAM="0,0,0,62,0,28,0"          # 3/4 aanzicht
SIZE="1100,850"

render_png () {  # $1=part $2=outfile $3=camera
  xvfb-run -a openscad -o "img/$2.png" \
    --projection=perspective --camera="$3" --viewall --autocenter \
    --imgsize=$SIZE -D "part=\"$1\"" "$SCAD"
}

export_stl () { # $1=part $2=outfile
  xvfb-run -a openscad --export-format binstl -o "stl/$2.stl" \
    -D "part=\"$1\"" "$SCAD"
}

echo ">> PNG previews"
render_png A        ring_helft_A   "$CAM"
render_png B        ring_helft_B   "$CAM"
render_png handle   handvat        "$CAM"
render_png plate    printplaat     "0,0,0,90,0,0,0"
render_png assembly assemblage     "$CAM"
render_png product  product        "$CAM"
render_png exploded explosietekening "$CAM"

echo ">> STL export (printbaar / Tinkercad)"
export_stl A      ring_helft_A
export_stl B      ring_helft_B
export_stl handle handvat
export_stl plate  printplaat_compleet

echo ">> Overzichtsblad voor het verslag"
montage \
  img/assemblage.png img/product.png img/explosietekening.png \
  img/ring_helft_A.png img/ring_helft_B.png img/handvat.png \
  -tile 3x2 -geometry 520x400+8+8 -background white \
  -title "Trillingsdempende bekerhouder - V3 (Bram, Ruben, Wander & Jelle)" \
  img/overzicht.png

echo ">> Klaar"
ls -la img stl
