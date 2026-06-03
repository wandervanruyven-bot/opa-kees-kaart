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

/* ---------------- ERGONOMISCH HANDVAT --------------------------- */
grip_x  = or_y + 16;              // ~88
grip_top_z = -6;
grip_bot_z = -100;

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

// ---- Ergonomisch handvat met beugel ----------------------------
module handle() {
    difference() {
        union() {
            // beugel: 180 graden hoepel over de +X helft (-Y .. +X .. +Y)
            rotate([0,0,-90])
                rotate_extrude(angle=180)
                    translate([r_yoke, -h_y/2]) square([wall_y, h_y]);
            // ergonomische greep onder de +X kant van de beugel
            grip();
        }
        // doorloopgaten op de Y-as (in de uiteinden van de beugel)
        thru_hole( 90, clr_d);
        thru_hole(270, clr_d);
    }
}

// ergonomische greep: gebogen capsule met vingergroeven + duimsteun
module grip() {
    difference() {
        hull() {
            translate([r_yoke+2, 0, 0])        sphere(8);
            translate([grip_x,   0, grip_top_z]) sphere(14);
            translate([grip_x+3, 0, grip_bot_z]) sphere(15);
        }
        // vingergroeven aan de buitenzijde
        for (z = [-26, -45, -64, -83])
            translate([grip_x + 16, 0, z]) sphere(6.5);
        // duimsteun bovenaan, kant van de beker
        translate([grip_x - 13, 0, -16]) scale([1,1,1.4]) sphere(8);
    }
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
else if (part == "plate") {
    translate([-95, -65, h_i/2]) inner_ring();
    translate([-95,  65, h_o/2]) outer_ring();
    translate([ 95,   0, 0])     handle();
}
else if (part == "product") product();
else if (part == "exploded") {
    color("#2e7d32") translate([0,0,-34]) inner_ring();
    color([0.9,0.4,0.2]) translate([0,0,-34]) liner();
    color("#fb8c00") outer_ring();
    color("#1565c0") translate([48,0,0]) handle();
    %translate([0,0,78]) ghost_cup();
}
else {   // assembly
    translate([0,0,-66]) ghost_cup();
    product();
}
