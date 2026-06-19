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

/* ---------------- DRAAIPUNTEN (M4 + vastgeklemde moer) --------- */
pin_d   = 4;
clr_d   = 4.4;                    // doorloopgat (vrij draaien)
tap_d   = 3.3;                    // (oud) gat om M4 in te tappen
lug_h   = 18;                     // hoogte van de oogjes (dikker -> sterker)
nut_af  = 7.4;                    // sleutelwijdte M4-moer (alleen weergave)
nut_thk = 5.2;                    // dikte M4-moer (alleen weergave)

in_tip  = ir_o - 1;               // 53.5  tip binnenring-oog (as = X)
out_tip = r_yoke - 1.5;           // 64.5  tip middenring-trunnion (as = Y)

/* ---------------- HANDVAT: BEUGEL + LUSGREEP ------------------- */
grip_x     = 76;                  // verbindingspunt greep <-> beugel
peg_d2     = 11;                  // dikke verbindingspen greep -> beugel
peg_len2   = 12;
peg_hole2  = 11.4;
xbolt_d    = 3.4;                 // dwarsbout M3 (greep vastzetten in beugel)
xbolt_z    = -1;                  // hoogte van de dwarsbout

// ergonomisch handvat: een vloeiend gebogen greep (mok-stijl) waar de
// hand / 4 vingers doorheen gaan, met een dikkere gevormde grijpzijde.
loop_t      = 20;                 // dikte in Y (vlakke kant -> printbaar)
// middellijn van het handvat in het XZ-vlak: [x, z, straal]
handle_path = [
    [ 73,   -6,  9],   // 0  hals (bij de beugel)
    [ 92,  -15, 10],   // 1
    [103,  -34, 12],   // 2  grijpzijde (dik)
    [106,  -60, 13],   // 3
    [106,  -88, 13],   // 4
    [100, -110, 12],   // 5
    [ 84, -124, 10],   // 6
    [ 64, -126,  9],   // 7  onderkant
    [ 52, -112,  8],   // 8
    [ 50,  -84,  8],   // 9  binnenzijde (bekerkant, dun = "guard")
    [ 52,  -56,  8],   // 10
    [ 62,  -32,  8],   // 11
];

// vloeiende kromme door de punten (Catmull-Rom), gesloten lus
function cr(a,b,c,d,t) =
    0.5*( 2*b + (c-a)*t + (2*a-5*b+4*c-d)*t*t + (3*b-3*c+d-a)*t*t*t );
N_h = len(handle_path);
sub_h = 6;
smooth_path = [ for (i=[0:N_h-1], j=[0:sub_h-1])
    let( p0=handle_path[(i-1+N_h)%N_h], p1=handle_path[i],
         p2=handle_path[(i+1)%N_h],     p3=handle_path[(i+2)%N_h], t=j/sub_h )
    [ cr(p0[0],p1[0],p2[0],p3[0],t),
      cr(p0[1],p1[1],p2[1],p3[1],t),
      max(6, cr(p0[2],p1[2],p2[2],p3[2],t)) ] ];

// =====================================================================
//  HULPMODULES
// =====================================================================

// Ring gecentreerd op z = 0
module ring(ri, ro, h) {
    rotate_extrude()
        translate([ri, -h/2]) square([ro - ri, h]);
}

// Oogje (lug) op hoek 'ang', van straal r0 tot tip.
// Doorlopend boutgat (clearance d=clr_d). Bevestiging: M4-bout van buiten,
// M4-zelfborgende moer aan de binnenkant vasthouden met een tang.
module lug(ang, r0, tip) {
    rotate([0,0,ang])
        difference() {
            hull() {
                translate([r0,   0, 0]) rotate([0,90,0]) cylinder(h=0.1, d=lug_h);
                translate([tip,  0, 0]) rotate([0,90,0]) cylinder(h=0.1, d=lug_h);
            }
            // doorlopend boutgat langs de as
            translate([r0-1, 0, 0]) rotate([0,90,0]) cylinder(h=tip-r0+2, d=clr_d);
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
            // twee oogjes op de X-as (+X en -X), met boutgat + moer-sleuf
            lug(  0, or_i-2, in_tip);
            lug(180, or_i-2, in_tip);
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
            // trunnions op de Y-as (+Y en -Y), met boutgat + moer-sleuf
            lug( 90, or_o-2, out_tip);
            lug(270, or_o-2, out_tip);
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
        // gat voor de dikke pen van de greep
        translate([grip_x, 0, -h_y/2 - 0.1]) cylinder(d=peg_hole2, h=peg_len2+1);
        // dwarsbout-gat (M3) door het pad + de pen -> greep mechanisch vast
        translate([grip_x, 0, xbolt_z]) rotate([90,0,0])
            cylinder(h=40, d=xbolt_d, center=true);
    }
}

// ---- Handvat: LUSGREEP (de hand past door de lus) --------------
//  De lus is rond om te grijpen, maar plat in de X-richting, zodat
//  hij plat op de bed kan printen (zie 'plate' voor de printstand).

// één "puck" (cilinder met as langs Y) op pad-punt p = [x, z, r]
module puck(p) {
    translate([p[0], 0, p[1]]) rotate([90,0,0])
        cylinder(h = loop_t, r = p[2], center = true);
}

module grip(solo=true) {
    n = len(smooth_path);
    difference() {
        union() {
            // vloeiende lus: hull tussen opeenvolgende (geinterpoleerde) punten
            for (i = [0:n-1])
                hull() { puck(smooth_path[i]); puck(smooth_path[(i+1)%n]); }
            // hals van het handvat naar de beugel
            hull() {
                puck(handle_path[0]);
                translate([grip_x, 0, -h_y/2 + 1]) cylinder(d=20, h=2, center=true);
            }
            // dikke pen in de beugel
            translate([grip_x, 0, -h_y/2 - 0.1]) cylinder(d=peg_d2, h=peg_len2);
        }
        // zachte vingergroeven op de grijpzijde, gespreid in Z
        for (z = [-48, -66, -84, -102])
            translate([94, 0, z]) rotate([90,0,0]) cylinder(h=loop_t+2, r=4, center=true);
        // dwarsbout-gat door de pen (lijnt uit met de beugel)
        translate([grip_x, 0, xbolt_z]) rotate([90,0,0])
            cylinder(h=40, d=xbolt_d, center=true);
    }
}

// ---- Hand als grootte-referentie (alleen weergave) -------------
//  ~ realistische handpalm: 78 mm breed, 100 mm lang, 32 mm dik
module hand_ref() {
    color([0.95,0.8,0.7,0.55])
        translate([86, 0, -72]) scale([23, 16, 40]) sphere(1);
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

// M4-bout (kop + schacht) + vastgeklemde moer, langs as op hoek ang
module bolt(ang, r_head, len, r_nut) {
    rotate([0,0,ang]) color("#8a8a8a") {
        translate([r_head, 0, 0]) rotate([0, 90,0]) cylinder(h=3.2, d=7.5);     // kop
        translate([r_head, 0, 0]) rotate([0,-90,0]) cylinder(h=len, d=pin_d);   // schacht
        translate([r_nut, 0, 0]) rotate([0,90,0])                               // moer
            cylinder(h=nut_thk, d=nut_af/cos(30), $fn=6, center=true);
    }
}

module all_bolts() {
    bolt(  0, or_o+2, 16, 47.6);   // binnenring-as +X
    bolt(180, or_o+2, 16, 47.6);   // binnenring-as -X
    bolt( 90, or_y+2, 16, 61.6);   // middenring-as +Y
    bolt(270, or_y+2, 16, 61.6);   // middenring-as -Y
    // dwarsbout M3 die de greep in de beugel vastzet (langs Y)
    color("#8a8a8a") translate([grip_x, 0, xbolt_z]) {
        translate([0, 13,0]) rotate([90,0,0])  cylinder(h=2.6, d=6);
        rotate([90,0,0]) translate([0,0,-13])  cylinder(h=26, d=3);
        translate([0,-13,0]) rotate([-90,0,0]) cylinder(h=2.4, d=6, $fn=6);
    }
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
else if (part == "grip")   translate([0,0,10]) rotate([90,0,0]) grip();   // printstand: plat
else if (part == "plate") {
    // alles in printstand: ringen rechtop, beugel plat, handvat plat
    translate([-120, -55, h_i/2]) inner_ring();
    translate([-120,  55, h_o/2]) outer_ring();
    translate([ -30,  60, h_y/2]) beugel();
    translate([  60, -70, 10]) rotate([90,0,0]) grip();
}
else if (part == "product") product();
else if (part == "exploded") {
    color("#2e7d32") translate([0,0,-44]) inner_ring();
    color([0.9,0.4,0.2]) translate([0,0,-44]) liner();
    color("#fb8c00") outer_ring();
    color("#1565c0") translate([108,0,0]) beugel();
    color("#1565c0") translate([208,0,0]) grip();
    // X-as: M4-bout + vastgeklemde moer in de binnenring-oogjes
    translate([ 24,0,-44]) bolt(  0, or_o+2, 16, 47.6);
    translate([-24,0,-44]) bolt(180, or_o+2, 16, 47.6);
    // Y-as: M4-bout + vastgeklemde moer in de middenring-trunnions
    translate([0, 24,0]) bolt( 90, or_o+4, 16, 61.6);
    translate([0,-24,0]) bolt(270, or_o+4, 16, 61.6);
    // M3 dwarsbout: zet de greep vast in de beugel
    color("#8a8a8a") translate([158, 0, xbolt_z]) rotate([90,0,0]) cylinder(h=30, d=3, center=true);
}
else if (part == "section") {
    // doorsnede: laat zien hoe de bout door de ring in de vastgeklemde moer grijpt
    difference() {
        product();
        translate([0, 210, 0]) cube([520,400,520], center=true);   // verwijder y>0
    }
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
