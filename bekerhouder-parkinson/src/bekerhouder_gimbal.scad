// =====================================================================
//  Trillingsdempende bekerhouder - V4 "GIMBAL"
//  NLT - Technisch Ontwerpen | Bram, Ruben, Wander & Jelle
//
//  Upgrade van V3: een ECHTE gimbal met twee loodrechte draaiassen,
//  zodat de beker in ALLE richtingen waterpas blijft (anti-mors).
//    - Binnenring (klemt de beker) draait om de X-as t.o.v. de middenring
//    - Middenring draait om de Y-as t.o.v. het ergonomische handvat
//  Trilt de hand, dan kantelt het handvat; beide assen vangen dat op en
//  de beker blijft hangen.
//
//  Onderdelen (kies met 'part'):
//    "inner"    -> Binnenring (bekerklem)
//    "outer"    -> Middenring (gimbalring)
//    "handle"   -> Ergonomisch handvat met beugel
//    "plate"    -> alle 3 de printdelen naast elkaar
//    "assembly" / "product" / "exploded"
// =====================================================================

part = "assembly";
$fn = 96;

/* ---------------- BEKER / BINNENRING ---------------------------- */
cup_d   = 75;
liner_t = 3;
ir_i    = cup_d/2 + liner_t;     // 40.5  binnenradius
wall_i  = 5;
or_i    = ir_i + wall_i;          // 45.5  buitenradius binnenring
h_i     = 24;                     // hoogte binnenring

/* ---------------- MIDDENRING (gimbalring) ----------------------- */
gap     = 9;                      // speling voor kantelen
ir_o    = or_i + gap;             // 54.5
wall_o  = 5;
or_o    = ir_o + wall_o;          // 59.5
h_o     = 16;                     // iets lager zodat hij vrij kantelt

/* ---------------- HANDVAT-BEUGEL (hoepel) ----------------------- */
r_yoke  = 66;                     // binnenstraal beugel
wall_y  = 6;
or_y    = r_yoke + wall_y;        // 72
h_y     = 14;

/* ---------------- DRAAIPUNTEN (M4) ------------------------------ */
pin_d   = 4;
clr_d   = 4.4;                    // doorloopgat (vrij draaien)
tap_d   = 3.3;                    // gat om M4 in te tappen
lug_h   = 13;                     // hoogte van de oogjes

in_tip  = ir_o - 1;               // 53.5  tip binnenring-oog (as = X)
out_tip = r_yoke - 1.5;           // 64.5  tip middenring-trunnion (as = Y)

/* ---------------- HANDVAT: BEUGEL + LUSGREEP ------------------- */
grip_x     = 76;                  // verbindingspunt greep <-> beugel
peg_d2     = 8;                   // verbindingspen greep -> beugel
peg_len2   = 10;
peg_hole2  = 8.5;

// lusgreep: dikke ergonomische grijpbalk + dunnere veiligheidslus
loop_x      = 90;                 // vlak van de lus (X), ruim buiten beker/ringen
loop_yh     = 48;                 // halve breedte van de lus (Y)
loop_zt     = -30;                // hoogte van de dikke grijpbalk (Z)
loop_zb     = -150;               // onderkant lus (Z)
loop_r      = 9;                  // dunne veiligheidslus (18 mm)
grip_bar_r  = 16;                 // dikke ergonomische grijpbalk (32 mm)
loop_t      = 20;                 // dikte in X (vlakke kant -> printbaar)

// =====================================================================
//  HULPMODULES
// =====================================================================

// Ring gecentreerd op z = 0
module ring(ri, ro, h) {
    rotate_extrude()
        translate([ri, -h/2]) square([ro - ri, h]);
}

// Oogje (lug): afgeronde blok langs as 'axis' ("X" of "Y"),
// van straal r0 tot tip, met gat erdoor. ang = hoekpositie (graden).
module lug(ang, r0, tip, hole, hole_len, hole_from_out=true) {
    rotate([0,0,ang])
        translate([0,0,0]) {
            difference() {
                hull() {
                    translate([r0,   0, 0]) rotate([0,90,0])
                        cylinder(h=0.1, d=lug_h);
                    translate([tip,  0, 0]) rotate([0,90,0])
                        cylinder(h=0.1, d=lug_h);
                }
                // gat langs X (na de rotate is de lokale X de as-richting)
                if (hole_from_out)
                    translate([tip - hole_len, 0, 0]) rotate([0,90,0])
                        cylinder(h=hole_len+0.1, d=hole);
                else
                    translate([r0 - 0.1, 0, 0]) rotate([0,90,0])
                        cylinder(h=hole_len+0.1, d=hole);
            }
        }
}

// Doorlopend gat langs een as op hoek 'ang', op straal-bereik, d=diameter
module thru_hole(ang, d) {
    rotate([0,0,ang])
        translate([0,0,0]) rotate([0,90,0])
            translate([0,0,-200]) cylinder(h=400, d=d);
}

// =====================================================================
//  PRINTDELEN
// =====================================================================

// ---- Binnenring: klemt de beker, draait om de X-as -------------
module inner_ring() {
    difference() {
        union() {
            ring(ir_i, or_i, h_i);
            // twee oogjes op de X-as (+X en -X), met tap-gat
            lug(  0, or_i-2, in_tip, tap_d, 11);
            lug(180, or_i-2, in_tip, tap_d, 11);
        }
    }
}

// ---- Middenring (gimbalring) -----------------------------------
//  - gaten op de X-as (doorloop) voor de bout naar de binnenring
//  - trunnions op de Y-as met tap-gat voor de bout naar het handvat
module outer_ring() {
    difference() {
        union() {
            ring(ir_o, or_o, h_o);
            // trunnions op de Y-as (+Y en -Y)
            lug( 90, or_o-2, out_tip, tap_d, 11);
            lug(270, or_o-2, out_tip, tap_d, 11);
        }
        // doorloopgaten op de X-as voor de binnenring-bout
        thru_hole(  0, clr_d);
        thru_hole(180, clr_d);
    }
}

// ---- Handvat: BEUGEL (printt plat op de bed) -------------------
module beugel() {
    difference() {
        union() {
            // 180 graden hoepel over de +X helft (-Y .. +X .. +Y)
            rotate([0,0,-90])
                rotate_extrude(angle=180)
                    translate([r_yoke, -h_y/2]) square([wall_y, h_y]);
            // verbindingspad voor de greep (vlakke onderkant -> printbaar)
            hull() {
                translate([(r_yoke+or_y)/2, 0, 0])
                    cube([wall_y, 16, h_y], center=true);
                translate([grip_x, 0, 0]) cylinder(d=24, h=h_y, center=true);
            }
        }
        // doorloopgaten op de Y-as (in de uiteinden van de beugel)
        thru_hole( 90, clr_d);
        thru_hole(270, clr_d);
        // gat voor het pennetje van de greep
        translate([grip_x, 0, -h_y/2 - 0.1]) cylinder(d=peg_hole2, h=peg_len2+1);
    }
}

// ---- Handvat: LUSGREEP (de hand past door de lus) --------------
//  De lus is rond om te grijpen, maar plat in de X-richting, zodat
//  hij plat op de bed kan printen (zie 'plate' voor de printstand).

// één balk van de lus tussen p1 en p2 met straal r (rond in YZ, vlak in X)
module loop_bar(p1, p2, r) {
    hull() {
        translate(p1) rotate([0,90,0]) cylinder(h=loop_t, r=r, center=true);
        translate(p2) rotate([0,90,0]) cylinder(h=loop_t, r=r, center=true);
    }
}

module grip(solo=true) {
    // vier hoeken van de lus
    c1 = [loop_x,  loop_yh, loop_zt];
    c2 = [loop_x, -loop_yh, loop_zt];
    c3 = [loop_x, -loop_yh, loop_zb];
    c4 = [loop_x,  loop_yh, loop_zb];
    difference() {
        union() {
            // dikke ergonomische grijpbalk (bovenbalk), licht getailleerd
            hull() {
                translate(c1) rotate([0,90,0]) cylinder(h=loop_t, r=grip_bar_r-2, center=true);
                translate(c2) rotate([0,90,0]) cylinder(h=loop_t, r=grip_bar_r-2, center=true);
                translate([loop_x,0,loop_zt]) rotate([0,90,0]) cylinder(h=loop_t, r=grip_bar_r, center=true);
            }
            // dunnere veiligheidslus
            loop_bar(c2, c3, loop_r);
            loop_bar(c3, c4, loop_r);
            loop_bar(c4, c1, loop_r);
            // hals van de grijpbalk naar de beugel
            hull() {
                translate([loop_x, 0, loop_zt]) rotate([0,90,0])
                    cylinder(h=loop_t, r=grip_bar_r-3, center=true);
                translate([grip_x, 0, -h_y/2 + 1]) cylinder(d=20, h=2, center=true);
            }
            // pennetje in de beugel
            translate([grip_x, 0, -h_y/2 - 0.1]) cylinder(d=peg_d2, h=peg_len2);
        }
        // vingergroeven op de grijpbalk (onderkant), gespreid langs Y
        for (yy = [-31, -10.5, 10.5, 31])
            translate([loop_x, yy, loop_zt - grip_bar_r + 1])
                rotate([0,90,0]) cylinder(h=loop_t+2, r=4.5, center=true);
        // ondiepe duimsteun bovenop de grijpbalk
        translate([loop_x, 0, loop_zt + grip_bar_r + 1])
            scale([1.6,1,1]) sphere(8);
    }
}

// ---- Hand als grootte-referentie (alleen weergave) -------------
//  ~ realistische handpalm: 78 mm breed, 100 mm lang, 32 mm dik
module hand_ref() {
    color([0.95,0.8,0.7,0.6])
        translate([loop_x - 4, 0, loop_zt - 42])
            scale([16, 39, 46]) sphere(1);
}

// ---- Handvat als één geheel (alleen voor de weergaven) ----------
module handle() {
    beugel();
    grip(solo=false);
}

// =====================================================================
//  HULPVORMEN VOOR DE WEERGAVE (niet printen)
// =====================================================================
module liner() {
    rotate_extrude()
        translate([cup_d/2, -h_i/2]) square([liner_t, h_i]);
}

module ghost_cup() {
    color([0.6,0.8,1,0.20])
        difference() {
            cylinder(h=105, r1=cup_d/2-4, r2=cup_d/2, center=false);
            translate([0,0,3]) cylinder(h=105, r1=cup_d/2-7, r2=cup_d/2-3);
        }
}

// bout (kop + schacht) langs as op hoek ang, vanaf straal r_head
module bolt(ang, r_head, len) {
    rotate([0,0,ang]) color("#9a9a9a") {
        translate([r_head, 0, 0]) rotate([0,90,0]) cylinder(h=3, d=8, $fn=6);
        translate([r_head, 0, 0]) rotate([0,-90,0]) cylinder(h=len, d=pin_d);
    }
}

module all_bolts() {
    bolt(  0, or_o+2, 14);   // binnenring-as +X
    bolt(180, or_o+2, 14);   // binnenring-as -X
    bolt( 90, or_y+2, 14);   // middenring-as +Y
    bolt(270, or_y+2, 14);   // middenring-as -Y
}

module product() {
    color("#2e7d32") inner_ring();
    color("#fb8c00") outer_ring();
    color([0.9,0.4,0.2]) liner();
    color("#1565c0") handle();
    all_bolts();
}

// =====================================================================
//  KEUZE
// =====================================================================
if (part == "inner")      inner_ring();
else if (part == "outer") outer_ring();
else if (part == "handle") handle();
else if (part == "beugel") beugel();
else if (part == "grip")   translate([0,0,103]) rotate([0,90,0]) grip();   // printstand: lus plat
else if (part == "plate") {
    // alles in printstand: ringen rechtop, beugel plat, lusgreep plat
    translate([-120, -55, h_i/2]) inner_ring();
    translate([-120,  55, h_o/2]) outer_ring();
    translate([ -25,  60, h_y/2]) beugel();
    translate([  70, -65, 103]) rotate([0,90,0]) grip();
}
else if (part == "product") product();
else if (part == "exploded") {
    color("#2e7d32") translate([0,0,-34]) inner_ring();
    color([0.9,0.4,0.2]) translate([0,0,-34]) liner();
    color("#fb8c00") outer_ring();
    color("#1565c0") translate([60,0,0]) handle();
    %translate([0,0,78]) ghost_cup();
}
else if (part == "assembly_hand") {
    translate([0,0,-66]) ghost_cup();
    product();
    hand_ref();
}
else {   // assembly
    translate([0,0,-66]) ghost_cup();
    product();
}
