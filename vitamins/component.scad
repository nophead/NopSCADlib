//
// NopSCADlib Copyright Chris Palmer 2018
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// This file is part of NopSCADlib.
//
// NopSCADlib is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.
//
// NopSCADlib is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with NopSCADlib.
// If not, see <https://www.gnu.org/licenses/>.
//

//
//! Various electronic components used in hot ends and heated beds.
//

//
// Resistor model for hot end
//
include <../core.scad>
include <tubings.scad>
include <spades.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/dogbones.scad>
use <../utils/sweep.scad>
use <../utils/rounded_polygon.scad>

function resistor_length(type)        = type[2]; //! Body length
function resistor_diameter(type)      = type[3]; //! Body diameter
function resistor_wire_diameter(type) = type[4]; //! Wire diameter
function resistor_wire_length(type)   = type[5]; //! Wire length from body
function resistor_hole(type)          = type[6]; //! Hole big enough to glue it into
function resistor_colour(type)        = type[7]; //! Body colour
function resistor_radial(type)        = type[8]; //! Radial gives bead thermistor style body
function resistor_sleeved(type)       = type[9]; //! Are the leads sleeved

splay_angle = 2; // radial lead splay angle

module resistor(type) { //! Draw specified type of resistor
    length = resistor_length(type);
    dia = resistor_diameter(type);

    $fa = fa; $fs = fs;
    vitamin(str("resistor(", type[0], "): ", type[1]));
    //
    // wires
    //
    color([0.7, 0.7, 0.7])
        if(resistor_radial(type))
            for(side= [-1,1])
                translate([side *  dia / 6, 0, length / 2])
                    rotate([0, splay_angle * side, 0])
                        cylinder(r = resistor_wire_diameter(type) / 2, h = resistor_wire_length(type), center = false, $fn = fn);
        else
            cylinder(r = resistor_wire_diameter(type) / 2, h = length + 2 * resistor_wire_length(type), center = true, $fn = fn);
    //
    // Sleeving
    //
    if(resistor_sleeved(type))
        color([0.5, 0.5, 1])
            if(resistor_radial(type))
                for(side= [-1, 1])
                    translate([side *  resistor_diameter(type) / 6, 0, length / 2]) {
                        rotate([0, splay_angle * side, 0])
                            cylinder(r = resistor_wire_diameter(type) / 2 + 0.1, h = resistor_wire_length(type) - 5, center = false, $fn = fn);                   }
    //
    // Body
    //
    color(resistor_colour(type))
        if(resistor_radial(type))
            hull() {
                translate_z(-length / 2 + dia / 2)
                    sphere(d = dia);

                cylinder(d = dia / 2, h = length / 2);
            }
        else
            rotate_extrude()
                for(y = [0, 1])
                    mirror([0, y])
                        rounded_corner(r = dia / 2, h = length / 2, r2 = dia / 10);
}

module sleeved_resistor(type, sleeving, bare = 5, heatshrink = false) { //! Draw a resistor with sleeved leads and option heatshrink
    resistor(type);
    sleeving_length = resistor_wire_length(type) - bare;

    $fa = fa; $fs = fs;

    for(side= [-1,1])
        if(resistor_radial(type)) {
            translate([side *  resistor_diameter(type) / 6, 0, 0])
                rotate([0, splay_angle * side, 0]) {
                    if(!resistor_sleeved(type))
                        translate_z(sleeving_length / 2 + resistor_length(type) / 2 + 20 * exploded())
                            tubing(sleeving, sleeving_length);

                    if(heatshrink)
                        translate_z(sleeving_length + resistor_length(type) / 2 + bare / 2 + 30 * exploded())
                            tubing(heatshrink);
                }
        }
        else {
            translate_z(side * (resistor_length(type) + sleeving_length + 40 * exploded()) / 2)
                tubing(sleeving, sleeving_length);

            if(heatshrink)
                translate_z(side * (resistor_length(type) /2  + sleeving_length + 30 * exploded()))
                    tubing(heatshrink);
        }
}

function al_clad_length(type)      = type[1];   //! Body length
function al_clad_width(type)       = type[2];   //! Width including tabs
function al_clad_tab(type)         = type[3];   //! Tab width
function al_clad_hpitch(type)      = type[4];   //! Lengthways pitch between screw holes
function al_clad_vpitch(type)      = type[5];   //! Widthways pitch between screw holes
function al_clad_thickness(type)   = type[6];   //! Tab thickness
function al_clad_hole(type)        = type[7];   //! Hole diameter
function al_clad_clearance(type)   = type[8];   //! Clearance from screw hole centre to the body
function al_clad_height(type)      = type[9];   //! Body height
function al_clad_wire_length(type) = type[10];  //! Total length including wires

module al_clad_resistor_hole_positions(type) //! Position children at the screw holes of an aluminium clad resistor
    for(end = [-1, 1])
        translate([end * al_clad_hpitch(type) / 2, end * al_clad_vpitch(type) / 2, al_clad_thickness(type)])
            children();

module al_clad_resistor_holes(type, h = 100) //! Drill screw holes for an aluminium clad resistor
    al_clad_resistor_hole_positions(type)
        drill(screw_clearance_radius(al_clad_hole(type) > 3 ? M3_pan_screw : M2p5_pan_screw), h);

module al_clad_resistor(type, value, leads = true) { //! Draw an aluminium clad resistor
    vitamin(str("al_clad_resistor(", type[0], ", ", value, arg(leads, true, "leads"),
               "): Resistor aluminium clad ", type[0], " ", value));
    length = al_clad_length(type);
    width = al_clad_width(type);
    height = al_clad_height(type);
    tab = al_clad_tab(type);
    thickness = al_clad_thickness(type);
    terminal_h = 4;
    terminal_t = 1;
    terminal_l = 5;

    body = al_clad_vpitch(type) - 2 * al_clad_clearance(type);

    $fa = fa; $fs = fs;

    color("silver") {
        rotate([90, 0, 90])
            linear_extrude(length, center = true)
                hull() {
                    translate([0, al_clad_height(type) / 2])
                        intersection() {
                            square([body, al_clad_height(type)], center = true);

                            circle(body / 2 - eps);
                        }
                    translate([0, thickness / 2])
                        square([body, thickness], center = true);
                }
        linear_extrude(thickness)
            difference() {
                union()
                    for(end = [-1, 1])
                        translate([end * (length - tab) / 2, end * (width - width / 2) / 2])
                            square([tab, width / 2], center = true);

                al_clad_resistor_hole_positions(type)
                    circle(d = al_clad_hole(type));
            }
        if(leads) {
            translate_z(height / 2)
                rotate([0, 90, 0])
                    cylinder(r = 1, h = al_clad_wire_length(type) - 2 * terminal_l + eps, center = true);

            for(end = [-1, 1])
                translate([end * (al_clad_wire_length(type) - terminal_l) / 2, 0, height / 2])
                    rotate([90, 0, 0])
                        linear_extrude(terminal_t, center = true) difference() {
                            square([terminal_l, terminal_h], center = true);

                            circle(r = 1);
                        }
        }
    }
    color("black")
        translate_z(height / 2)
            rotate([0, 90, 0])
                cylinder(r = leads ? 3 : height / 2 - 2, h = length + eps, center = true);
}

module al_clad_resistor_assembly(type, value, sleeved = true, sleeving = HSHRNK32, sleeving_length = 15) { //! Draw aluminium clad resistor with optional sleaving, positions children at the screw positions
    al_clad_resistor(type, value);

    if(sleeved)
        for(end = [-1, 1])
            translate([end * (al_clad_length(type) + sleeving_length + 0) / 2, 0,  al_clad_height(type) / 2])
                rotate([0, 90, 0])
                    scale([1.5, 0.66, 1])
                        tubing(sleeving, sleeving_length);

    al_clad_resistor_hole_positions(type)
        children();
}

TO220_hole_y = 2.9; // Distance to hole from top of tab

function TO220_size() = [10.2, 15, 4.4]; //! Size of a TO220
function TO220_thickness() = 1.5; //! Thickness of the tab of a TO220
function TO220_lead_pos(i, l) =  //! Position of ith lead end when length = l
    [i * inch(0.1), -TO220_size().y + TO220_hole_y - l, 1.9];

module  TO220(description, leads = 3, lead_length = 16) { //! Draw a TO220 package, use `description` to describe what it is
    s = TO220_size();
    inset = 1.5;
    hole = 3.3;
    lead_t = 0.4;
    lead_w = 0.7;
    lead_w2 = 1.4;
    lead_l = 4.2;
    body = 8;

    vitamin(str("TO220(\"", description, "\"", arg(leads, 3, "leads"), "): ", description));

    $fa = fa; $fs = fs;

    translate([0, -s.y + TO220_hole_y]) {
        color("silver")
            linear_extrude(TO220_thickness())
                difference() {
                    translate([-s.x / 2, inset])
                        square([s.x, s.y - inset]);

                    translate([0, s.y - TO220_hole_y])
                        circle(d = hole);

                    for(side = [-1, 1])
                        translate([side * s.x / 2, 0])
                            square([inset * 2, body * 2], center = true);
                }

        color("dimgrey")
            translate([-s.x / 2, 0, eps])
                cube([s.x, body, s.z]);
    }

    color(silver)
        for(i = [-1 : 1])
            if(i || leads == 3) {
                translate(TO220_lead_pos(i, lead_length / 2))
                    cube([lead_w, lead_length, lead_t], center = true);

                translate(TO220_lead_pos(i, lead_l / 2))
                    cube([lead_w2, lead_l, lead_t], center = true);
            }

    translate_z(TO220_thickness())
        children();
}

function TO247_size() = [15.7, 20.82, 4.82, 5.58, 2.5, 3.8]; //! Body dimensions of a T247, hole offset, lead height and lead wide length

module  TO247(description, lead_length = 20) { //! Draw a TO247 package, use `description` to describe what it is
    size =  TO247_size();
    hole_y = size[3];
    lead_height = size[4];
    lead_l = size[5];
    metal = [12.81, 13.08, 1.5];
    metal_y_offset = 1.35;
    hole = 3.5;
    metal_hole = 6.85;
    lead_t = 0.61;
    lead_w2 = 2.5;
    lead_w = 1.25;
    lead_pitch = 5.56;

    vitamin(str("TO247(\"", description, "\"): ", description));

    $fa = fa; $fs = fs;

    module body_shape()
        difference() {
            translate([-size.x / 2, 0])
                square([size.x, size.y]);

            translate([0, size.y - hole_y])
                circle(d = hole);
        }

    translate([0, -size.y + hole_y]) {
        color("silver") {
            linear_extrude(metal.z)
                difference() {
                    translate([-metal.x / 2, size.y - metal.y - metal_y_offset])
                        square([metal.x, metal.y]);

                    translate([0, size.y - hole_y])
                        circle(d = metal_hole);
                }

            translate_z(lead_height)
                linear_extrude(lead_t)
                    intersection() {
                        for(i = [-1 : 1]) {
                            length = is_list(lead_length) ? lead_length[i + 1] : lead_length;
                            translate([lead_pitch * i, -length / 2, lead_height])
                                square([lead_w, length], center = true);

                            translate([lead_pitch * i, -lead_l / 2, lead_height])
                                square([lead_w2, lead_l], center = true);
                        }
                        square([2 * lead_pitch + lead_w, 100], center = true);
                    }
        }

        color("dimgrey")
            translate_z(eps) {
                linear_extrude(metal.z - 2 * eps)
                    body_shape();

                linear_extrude(size.z)
                    difference() {
                        body_shape();

                        for(side = [-1, 1])
                            translate([side * size.x / 2, size.y - hole_y])
                                circle(d = 5);
                    }

            }
    }
    translate_z(size.z)
        children();
}

module multiwatt11(part_no, tail = 3) { //! Draw a MULTIWATT11 package
    A = 5;                  // Body thickness, name from datasheet
    B = 2.65;               // Lead offset from heatsink face
    C = 1.6;                // Metal tab thickness
    D = 1;                  // Straight section of leads before bend
    E = (0.49 + 0.55) / 2;  // Lead thickness
    F = (0.88 + 0.95) / 2;  // Lead width
    G = 1.7;                // Lead pitch
    H = 20;                 // Body width
    L2 = (17.4 +18.1) / 2;  // Height of hole above the PCB
    L3 = 17.5;              // Height from base to tab
    L4 = 10.7;              // height of plastic part
    L7 = (2.65 + 2.9) / 2;  // Distance of hole from the top
    M = 4.3;                // Back leads from heatsink
    M1 = 5.08;              // Back leass to front leads
    S = (1.9 + 2.6) / 2;    // Chamfer
    Dia = (3.65 + 3.85) / 2;// Hole diameter
    inset = 1;              // Metal inset from plastic
    draft = 7;              // 7 degree body draft angle
    leads = 11;             // Number of leads
    h = L2 + L7;            // Total height above PCB
    z = h - L3;             // Height of base above PCB
    dimple_d = 2.7;         // Half round dimples in the sides
    tab_h = L3 - L4;
    tan = tan(draft);
    lead_r = E;

    vitamin(str("multiwatt11(\"", part_no, "\"): MULTIWATT11 ", part_no));

    rotate([90, 0, 0]) {
        color(silver) {
            linear_extrude(C)
                union() {
                    translate([-H / 2 + inset, z + inset + 0.2])
                        square([H - 2 * inset, L4]);

                    difference() {
                        hull() {
                            translate([-H / 2, z + L4])
                                square([H, tab_h - S]);

                            translate([-H / 2 + S, z + L4])
                                square([H - 2 * S, tab_h]);
                        }
                        translate([0, h - L7])
                            circle(d = Dia);
                    }
                }
                $fs = fs;
                $fa = fa;
                M2 = M + M1;
                front_path = [for(p = rounded_polygon([
                                    [-B,            z,           0],
                                    [-B - lead_r,   z - D,        lead_r],
                                    [-M2 + lead_r,  h - L7 - L2, -lead_r],
                                    [-M2,           h - L7 - L2 - tail, 0],
                                ])) [0, p.y, -p.x]];

                back_path = [for(p = rounded_polygon([
                                    [-B,            z,           0],
                                    [-B - lead_r,   z - D,        lead_r],
                                    [-M + lead_r,   h - L7 - L2, -lead_r],
                                    [-M,            h - L7 - L2 - tail,  0],
                                ])) [0, p.y, -p.x]];
                profile = rectangle_points(F, E);
                for(i = [0 : leads - 1])
                    translate([(i - (leads - 1) / 2) * G, 0, -E / 2])
                        sweep((i % 2) ? back_path : front_path, profile);
            }

        color("dimgrey")
            difference() {
                s = B * tan;
                s2 = (A - B) * tan;
                hull() {
                    translate([-H / 2 - C * tan, z + s, eps])
                        cube([H + 2 * C * tan, L4 - s, eps]);

                    translate([-H / 2, z, B])
                        cube([H, eps, eps]);

                    translate([-H / 2 + s2, z + s2, A - eps])
                        cube([H - 2 * s2, L4 - (A - C) * tan, eps]);
                }
                for(side = [-1,1])
                    translate([side * (H / 2 + s2), z + 4.5, C - eps])
                        cylinder(d = dimple_d, h = A - C + 2 * eps);
            }

        color("white")
            translate([0, z + L4 / 2, A])
                linear_extrude(eps)
                    resize([H * 0.7, 0], auto = true)
                        text(part_no, halign = "center", valign = "center");


    }
}

panel_USBA_pitch = 30;

module panel_USBA_hole_positions() //! Place children at hole positions
    for(side = [-1, 1])
        translate([side * panel_USBA_pitch / 2, 0])
            children();

module panel_USBA_holes(h = 100) { //! Make holes for USBA connector
    corner_clearance = 2 * cnc_bit_r * (1 - 1 / sqrt(2));
    width = 5.5 + corner_clearance;
    length = 13 + corner_clearance;

    extrude_if(h) union() {
        rounded_square([length, width], r = cnc_bit_r);

        panel_USBA_hole_positions()
            drill(M3_clearance_radius, 0);
    }
}

module panel_USBA() { //! Draw a panel mount USBA connector
    vitamin("panel_USBA(): Socket USB A panel mount");

    width = 12;
    length = 40;
    length2 = 22;
    thickness = 5.5;
    height = 33;
    height2 = 27;
    lead_dia = 10;
    r1 = 1.5;
    r2 = 5;
    height3 = 9.5;
    length3 = 17.5;

    l = 17;
    w = 13.3;
    h = 5.7;
    flange_t = 0.4;
    h_flange_h = 0.8;
    h_flange_l = 11.2;

    v_flange_h = 0.8;
    v_flange_l = 3.8;
    tongue_w = 10;
    tongue_t = 1.3;

    $fa = fa; $fs = fs;

    vflip() {
        color("dimgrey")  {
            linear_extrude(thickness)
                difference() {
                    hull()
                        for(side = [-1, 1])
                            translate([side * (length / 2 - width / 2), 0])
                                circle(d = width);

                    square([length3, width + 1], center = true);

                    panel_USBA_hole_positions()
                        circle(M3_clearance_radius);
                }

            translate_z(height2)
                cylinder(d = lead_dia, h = height - height2);

            hull() {
                dx = (length2 / 2 - r2);
                dy = (width / 2 - r1);
                translate_z(l)
                    rounded_rectangle([length2, width, 1], r = r1);

                translate([-dx, -dy, height2 - r2])
                    rotate([90, 0, 0])
                        rounded_cylinder(r = r2, r2 = r1, h = r1);

                translate([dx, -dy, height2 - r2])
                    rotate([90, 0, 0])
                        rounded_cylinder(r = r2, r2 = r1, h = r1);

                translate([-dx, dy, height2 - r2])
                    rotate([-90, 0, 0])
                        rounded_cylinder(r = r2, r2 = r1, h = r1);

                translate([dx, dy, height2 - r2])
                    rotate([-90, 0, 0])
                        rounded_cylinder(r = r2, r2 = r1, h = r1);
            }

            translate_z(height3)
                linear_extrude(l - height3)
                    difference() {
                        rounded_square([length2, width], r = r1);

                        square([w - flange_t, h - flange_t], center = true);
                    }

            linear_extrude(height3)
                difference() {
                    rounded_square([length2, width], r = r1);

                    square([length3, width + 1], center = true);
                }
        }

        *cube([12, 4.5, 32], center = true);

        color("silver") {
            linear_extrude(l)
                difference() {
                    square([w, h], center = true);

                    square([w - 2 * flange_t, h - 2 * flange_t], center = true);
                }

            translate_z(l - flange_t / 2)
                cube([w, h, flange_t], center = true);

            linear_extrude(flange_t)
                difference() {
                    union() {
                        square([h_flange_l, h + 2 * h_flange_h], center = true);

                        square([w + 2 * v_flange_h, v_flange_l], center = true);
                    }
                    square([w - 2 * flange_t, h - 2 * flange_t], center = true);
                }
         }

         color("white")
            translate([0, h / 2 - 1 - tongue_t / 2, l / 2])
                cube([tongue_w, tongue_t, l], center = true);
    }
}

function tc_length(type)       = type[1];   //! Across the lugs
function tc_width(type)        = type[2];   //! Width of lugs
function tc_thickness(type)    = type[3];   //! Metal thickness
function tc_hole_dia(type)     = type[4];   //! Screw hole diameter
function tc_hole_pitch(type)   = type[5];   //! Screw hole pitch
function tc_body_length(type)  = type[6];   //! Plastic body length
function tc_body_width(type)   = type[7];   //! Plastic body width
function tc_body_height(type)  = type[8];   //! Plastic body height
function tc_body_inset(type)   = type[9];   //! How far metal is inset into the plastic body
function tc_spade_height(type) = type[10];  //! Terminal spade height measured from base
function tc_spade_pitch(type)  = type[11];  //! Terminal spade pitch

module thermal_cutout_hole_positions(type) //! Place children at hole positions
    for(side = [-1, 1])
        translate([side * tc_hole_pitch(type) / 2, 0])
            children();

module thermal_cutout(type) { //! Draw specified thermal cutout
    vitamin(str("thermal_cutout(", type[0], "): Thermal cutout ", type[0]));

    w = tc_width(type);
    t = tc_thickness(type);
    h = tc_body_height(type);
    bw = tc_body_width(type);
    bl = tc_body_length(type);
    spade = spade6p4;

    $fa = fa; $fs = fs;

    color("silver") {
        linear_extrude(tc_thickness(type))
            difference() {
                hull()
                    for(side = [-1, 1])
                        translate([side *(tc_length(type) - w) / 2, 0])
                            circle(d = w);

                thermal_cutout_hole_positions(type)
                    circle(d = tc_hole_dia(type));
            }

        body_inset = tc_body_inset(type);
        translate_z((h - body_inset) / 2)
            cube([bl - 2 * body_inset, bw + 2 * eps, h - body_inset], center = true);
    }

    color("black")
        translate_z(h / 2 + eps)
            cube([bl, bw, h], center = true);

    for(side = [-1, 1])
        translate([side * tc_spade_pitch(type) / 2, 0, h])
            rotate(90)
                spade(spade, tc_spade_height(type) - h);

    translate_z(t)
        thermal_cutout_hole_positions(type)
            children();
}

function fack2spm_bezel_size() = [19.2, 35.5, 2.6, 2]; //! FACK2SPM Bezel dimensions

module fack2spm_hole_positions() //! Place children at the FACK2SPM mounting hole positions
    for(end = [-1, 1])
        translate([0, end * 28.96 / 2])
            children();

function fack2spm_screw() = M3_dome_screw; //! Screw type for FACK2SPM

module fack2spm_holes(h = 0) { //! Cut the holes for a FACK2SPM
    fack2spm_hole_positions()
        drill(screw_clearance_radius(fack2spm_screw()), h);

    dogbone_rectangle([17.15, 22.86, h]);
}

module fack2spm() { //! Draw a FACK2SPM Cat5E RJ45 shielded panel mount coupler
    vitamin("tuk_fack2spm(): TUK FACK2SPM Cat5E RJ45 shielded panel mount coupler");

    bezel = fack2spm_bezel_size();
    body   = [16.8, 22.8, 9.8];
    socket = [14.5, 16.1, 29.6];
    y_offset = -(19.45 - 16.3) / 2;
    plug = [12, 6.8, 10];
    plug_y = y_offset - socket.y / 2 + 4 + plug.y / 2;
    tab1 = [4, 3];
    tab2 = [6.3, 1.6];

    $fa = fa; $fs = fs;

    module socket()
        translate([0, y_offset])
            square([socket.x, socket.y], center = true);

    color("silver") {
        linear_extrude(bezel.z)
            difference() {
                rounded_square([bezel.x, bezel.y], bezel[3]);

                fack2spm_hole_positions()
                    circle(d = 3.15);

                socket();
            }

        translate_z(bezel.z - body.z)
            linear_extrude(body.z - eps)
                difference() {
                    square([body.x, body.y], center = true);

                    socket();
                }

        translate_z(bezel.z - socket.z)
            linear_extrude(socket.z - 0.1)
                difference() {
                    offset(-0.1) socket();

                    translate([0, plug_y]) {
                        square([plug.x, plug.y], center = true);

                        translate([0, -plug.y / 2]) {
                            square([tab1.x, 2 * tab1.y], center = true);

                            square([tab2.x, 2 * tab2.y], center = true);
                        }
                    }
                }

        translate([0, plug_y, -socket.z / 2])
            cube([plug.x, plug.y, socket.z - 2 * plug.z], center = true);
    }
}
