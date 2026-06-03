// =====================================================================
//  Trillingsdempende bekerhouder voor mensen met Parkinson
//  NLT - Technisch Ontwerpen  |  Bram, Ruben, Wander & Jelle
//
//  Ontwerp V3 (definitief): een 3D-geprinte ring in twee helften die
//  met een siliconen binnenrand om de beker klemt. Een handvat draait
//  via EEN bout vrij ten opzichte van de ring. Trilt de hand, dan
//  draait het handvat mee, maar de ring en beker blijven hangen.
//
//  Onderdelen (kies met de variabele 'part'):
//    "A"        -> Ring helft A (met vork/scharnierpunt voor handvat)
//    "B"        -> Ring helft B (vlak)
//    "handle"   -> Handvat met tong
//    "plate"    -> Alle 3 de printdelen naast elkaar (printplaat)
//    "assembly" -> Alles samengebouwd, met bout, siliconen en beker
//    "product"  -> Samengebouwd zonder beker (schone productfoto)
//    "exploded" -> Explosietekening: alle onderdelen uit elkaar
// =====================================================================

part = "assembly";          // wordt door render.sh overschreven met -D

$fn = 96;                    // rondingen-resolutie

/* ---------------- HOOFDMATEN (mm) -------------------------------- */
cup_d    = 75;              // nominale buitendiameter van de beker
liner_t  = 3;              // dikte siliconen binnenrand
wall     = 5;              // wanddikte van de PLA-ring
ring_h   = 26;             // hoogte van de ring

ring_ir  = cup_d/2 + liner_t;   // binnenradius ring   = 40.5
ring_or  = ring_ir + wall;      // buitenradius ring   = 45.5

/* ---------------- BOUT / SCHARNIER ------------------------------- */
bolt_d   = 5;              // M5 bout
hole_d   = 5.4;            // boutgat met speling

/* ---------------- VORK (yoke) OP HELFT A ------------------------- */
tongue_w = 8;              // dikte van de tong van het handvat (Y)
yoke_gap = tongue_w + 1.0; // ruimte tussen de twee vorktanden
lug_t    = 5;              // dikte van elke vorktand (Y)
pivot_x  = ring_or + 11;   // X-positie van de boutas
pivot_z  = ring_h/2;       // Z-positie van de boutas (halve hoogte)

/* ---------------- KLIK-PENNEN (verbinding helft A <-> B) --------- */
peg_d     = 5;             // diameter pen
peg_len   = 6;             // lengte pen
peg_hole  = 5.3;           // gat voor pen (speling)
peg_holed = 7;             // diepte gat
peg_r     = ring_ir + wall/2;   // pennen in het midden van de wand
peg_z1    = ring_h*0.30;
peg_z2    = ring_h*0.70;

/* ---------------- HANDVAT (greep) ------------------------------- */
grip_x   = pivot_x + 24;   // greep verder naar buiten -> handruimte
grip_r   = 14;             // greepstraal (~28 mm dik)
grip_top = [grip_x, 0, pivot_z + 4];
grip_bot = [grip_x, 0, pivot_z - 92];

// =====================================================================
//  HULPMODULES
// =====================================================================

// Halve buis (ring-helft) van hoek a0 over 180 graden
module half_tube(a0) {
    rotate([0,0,a0])
        rotate_extrude(angle = 180)
            translate([ring_ir, 0])
                square([wall, ring_h]);
}

// Een pen langs de X-as op de naad (sgn = +1 voor +Y, -1 voor -Y naad)
module peg_at(sgn, zz) {
    translate([0, sgn*peg_r, zz])
        rotate([0,90,0])                 // as langs X
            translate([0,0,-peg_len])    // steekt uit naar -X (in helft B)
                cylinder(h = peg_len + 0.2, d = peg_d);
}
module peghole_at(sgn, zz) {
    translate([0, sgn*peg_r, zz])
        rotate([0,90,0])
            translate([0,0,-peg_holed])
                cylinder(h = peg_holed + 0.1, d = peg_hole);
}

// Boutgat langs de Y-as door het scharnierpunt
module bolt_hole() {
    translate([pivot_x, 0, pivot_z])
        rotate([90,0,0])
            cylinder(h = 120, d = hole_d, center = true);
}

// Een vorktand (lug): afgeronde plaat, dikte lug_t langs Y,
// gecentreerd op y-offset yo
module lug(yo) {
    translate([0, yo, 0])
        hull() {
            translate([pivot_x, 0, pivot_z]) rotate([90,0,0])
                cylinder(h = lug_t, r = 8,  center = true);
            translate([ring_or-2, 0, pivot_z]) rotate([90,0,0])
                cylinder(h = lug_t, r = 11, center = true);
        }
}

// =====================================================================
//  PRINTDELEN
// =====================================================================

// ---- Ring helft A : +X helft, met vork + uitstekende pennen ----
module ring_half_A() {
    difference() {
        union() {
            half_tube(-90);                          // dekt -90..+90 (+X kant)
            lug( (yoke_gap/2 + lug_t/2));            // vorktand +Y
            lug(-(yoke_gap/2 + lug_t/2));            // vorktand -Y
            // pennen op beide naden
            peg_at( 1, peg_z1); peg_at( 1, peg_z2);
            peg_at(-1, peg_z1); peg_at(-1, peg_z2);
        }
        bolt_hole();
    }
}

// ---- Ring helft B : -X helft, vlak, met gaten voor de pennen ----
module ring_half_B() {
    difference() {
        half_tube(90);                               // dekt 90..270 (-X kant)
        peghole_at( 1, peg_z1); peghole_at( 1, peg_z2);
        peghole_at(-1, peg_z1); peghole_at(-1, peg_z2);
    }
}

// ---- Handvat met tong ----
module handle() {
    difference() {
        union() {
            // tong (plat, dikte tongue_w) rond het scharnierpunt
            hull() {
                translate([pivot_x,0,pivot_z]) rotate([90,0,0])
                    cylinder(h = tongue_w, r = 9, center = true);
                translate(grip_top) sphere(grip_r*0.7);
            }
            // greep (capsule)
            hull() {
                translate(grip_top) sphere(grip_r);
                translate(grip_bot) sphere(grip_r);
            }
        }
        bolt_hole();
    }
}

// =====================================================================
//  HULPVORMEN VOOR DE ASSEMBLAGE-WEERGAVE (worden niet geprint)
// =====================================================================

// Siliconen binnenrand
module liner() {
    difference() {
        cylinder(h = ring_h, r = ring_ir);
        translate([0,0,-1]) cylinder(h = ring_h+2, r = cup_d/2);
    }
}

// Vereenvoudigde bout + moer + ringen
module bolt_assembly() {
    color("#9a9a9a") {
        translate([pivot_x, yoke_gap/2 + lug_t + 4, pivot_z]) rotate([90,0,0])
            cylinder(h = 2*(yoke_gap/2+lug_t+5), d = bolt_d);          // schroefdraad
        translate([pivot_x, yoke_gap/2 + lug_t + 6, pivot_z]) rotate([90,0,0])
            cylinder(h = 4, d = 9, $fn = 6);                            // kop
        translate([pivot_x, -(yoke_gap/2 + lug_t + 4), pivot_z]) rotate([90,0,0])
            cylinder(h = 4, d = 9, $fn = 6);                            // moer
    }
}

// Doorzichtige beker ter context
module ghost_cup() {
    color([0.6,0.8,1,0.20])
        difference() {
            cylinder(h = 105, r1 = cup_d/2 - 4, r2 = cup_d/2);
            translate([0,0,3]) cylinder(h = 105, r1 = cup_d/2-7, r2 = cup_d/2-3);
        }
}

// De drie gekleurde printdelen + siliconen, op hun plek (gedeelde basis)
module product(ax=0, bx=0, hx=0, liny=0) {
    translate([ ax,0,0]) color("#2e7d32") ring_half_A();
    translate([ bx,0,0]) color("#43a047") ring_half_B();
    translate([0,liny,0]) color([0.9,0.4,0.2]) liner();
    translate([ hx,0,0]) color("#1565c0") handle();
}

// =====================================================================
//  KEUZE / RENDER
// =====================================================================

if (part == "A") {
    ring_half_A();

} else if (part == "B") {
    ring_half_B();

} else if (part == "handle") {
    handle();

} else if (part == "plate") {
    // Drie delen naast elkaar voor de printplaat (bovenaanzicht)
    translate([-70,  35, 0]) ring_half_A();
    translate([-70, -35, 0]) ring_half_B();
    translate([ 60,   0, 0]) handle();

} else if (part == "product") {
    product();
    bolt_assembly();

} else if (part == "exploded") {
    // Onderdelen uit elkaar getrokken langs de montage-richting (X),
    // de bout langs zijn eigen as (Y).
    product(ax = 32, bx = -32, hx = 150, liny = 0);
    translate([0,55,0]) bolt_assembly();

} else {                       // "assembly"
    translate([0,0,-70]) ghost_cup();
    product();
    bolt_assembly();
}
