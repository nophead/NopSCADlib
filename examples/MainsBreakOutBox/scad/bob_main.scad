//
//! 13A socket break out box with 4mm jacks to measure voltage and / or load current and earth leakage current.
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Top level model
//
$extrusion_width = 0.5;
$pp1_colour = "dimgrey";
$pp2_colour = [0.9, 0.9, 0.9];

include <NopSCADlib/lib.scad>
use <NopSCADlib/foot.scad>
include <NopSCADlib/vitamins/mains_sockets.scad>

echo(extrusion_width = extrusion_width, layer_height = layer_height);
wall = 2.5;

iec = IEC_inlet_atx;
socket = Contactum;


foot = [20, 8, 3, 1, M3_dome_screw, 10];

module foot_stl() foot(foot);

socket_depth = 13;

screw = mains_socket_screw(socket);
screw_clearance_radius = screw_clearance_radius(screw);

insert = screw_insert(screw);
insert_hole_radius = insert_hole_radius(insert);
insert_length = insert_length(insert);
insert_boss = mains_socket_insert_boss(socket);
screw_length = screw_longer_than(mains_socket_height(socket) + insert_length(insert));

iec_h = iec_slot_h(iec) + 1;

box_height = socket_depth + iec_h;
base_thickness = wall;
height = base_thickness + box_height;

iec_x = -mains_socket_width(socket) / 2;
iec_y = 0;
iec_z = base_thickness + iec_h / 2;

jack_pitch = 20;
jack_z = iec_z;

module foot_positions() {
    inset = wall + foot_diameter(foot) / 2;
    pitch = mains_socket_width(socket) / 2 - inset;

    for(x = [-1, 1], y = [-1, 1])
        translate([x * pitch, y * pitch])
            children();
}

module jack_hole() {
    intersection() {
        teardrop_plus(r = jack_4mm_shielded_hole_radius(), h = 50);

        cube([11, 100, 100], center = true);
    }
}

module socket_box_stl() {
    stl("socket_box");

    difference() {
        linear_extrude(height = height, convexity = 5)
            face_plate(socket);

        difference() {
            translate_z(base_thickness)
                linear_extrude(height = height, convexity = 5)
                     offset(-wall) face_plate(socket);

            z = height + mains_socket_height(socket) - screw_length - wall;
            for(side = [-1, 1])
                difference() {
                    hull()
                        for(x = [1, 2])
                            translate([side * mains_socket_pitch(socket) / x, 0, 0])
                                cylinder(d = insert_boss, h = 100);
                    hull() {
                        translate([side * mains_socket_pitch(socket) / 2, 0, 0])
                            cylinder(d = insert_boss - 4 * extrusion_width, h = z);

                        translate([side * (mains_socket_width(socket) / 2 - wall - 1), 0, z / 2])
                            cube([2, insert_boss - 4 * extrusion_width, z], center = true);
                    }
                    w = show_supports() ? 1 : 20;
                    translate([side * (mains_socket_width(socket) / 2 - wall - w/ 2), 0, z / 2])
                        cube([w, insert_boss + 1, z], center = true);
                }
        }
        //
        // Socket holes
        //
        translate_z(height)
            mains_socket_hole_positions(socket) {
                poly_cylinder(r = screw_clearance_radius, h = 2 * (screw_length - mains_socket_height(socket)) + 2, center = true);

                poly_cylinder(r = insert_hole_radius, h = 2 * insert_length, center = true);
            }
        //
        // IEC holes
        //
        difference() {
            translate([iec_x, iec_y, iec_z])
                rotate([90, 0, -90])
                    iec_holes(iec);

                linear_extrude(height = height, convexity = 5)
                     offset(-wall) face_plate(socket);
        }
        //
        // Jack holes
        //
        for(x = [-1, 0, 1])
            translate([x * jack_pitch, -mains_socket_width(socket) / 2, jack_z])
                rotate([90, 0, 0])
                    jack_hole();

        for(x = [-1, 1])
            translate([x * jack_pitch / 2, mains_socket_width(socket) / 2, jack_z])
                rotate([90, 0, 0])
                    jack_hole();
        //
        // Feet holes
        //
        foot_positions()
            poly_cylinder(r = screw_clearance_radius(foot_screw(foot)), h = 100, center = true);
    }
}
//
//! 1. Remove the support material from under the insert lugs.
//! 2. Place the inserts into the holes in the lugs and press home with a soldering iron with a conical bit heated to 200&deg;C.
//
module base_assembly()
assembly("base") {
    color(pp1_colour) render() /*clip(ymax = 0)*/ socket_box_stl();

    mains_socket_hole_positions(socket)
        translate_z(height)
            insert(insert);
}
//
//! * Attach the four feet using 10mm M3 dome screws, washers above and below and nyloc nuts
//
module feet_assembly()
assembly("feet") {
    base_assembly();

    foot_positions()
        foot_assembly(base_thickness, foot);
}
//
//! 1. Solder wires to the IEC terminals and cover the joints with heatshrink sleeving.
//!     * Use wire rated for 13A, e.g. 1.5mm<sup>2</sup>, the easiest source is stripping 13A rated flex.
//!     * Attach one green & yellow to the earth, one blue to neutral and two brown to the live. The second brown one can be thinner because it is only for voltage measurement.
//!     * The earth, neutral and thin live wires should be long enough to protrude through the appropriate 4mm jack holes far enough to be able to strip and solder them to the jacks.
//!     * The thick brown needs to be long enough to reach the socket.
//! 1. Attach the IEC inlet using two 12mm M3 countersunk cap screws, washers and nyloc nuts on the back.
//
module mains_in_assembly() pose([ 35.40, 0.00, 144.20 ], [ -13.10, 0.00, 13.75 ])
assembly("mains_in") {
    feet_assembly();

    wire("green & yellow", 30, 150, 0.25);
    wire("blue",  30, 150, 0.25);
    wire("brown", 30, 150, 0.25);
    wire("brown", 7, 150);
    for(i = [1:3])
        hidden() tubing(HSHRNK32);

    translate([iec_x, iec_y, iec_z])
        rotate([90, 0, -90])
            iec_assembly(iec, wall);

}
//
//! ![inside](docs/inside_small.jpg)
//!
//! 1. Put the blue wire from the IEC inlet through the bottom left jack hole, strip it, add heatshrink sleeving and solder it to one of the blue jack sockets.
//! 1. Put the green & yellow wire through the top left jack hole, add heatshrink sleeving and solder it to one of the green jack sockets.
//! 1. Put the thin brown wire the bottom right jack hole, add heatshrink sleeving and solder it to the brown jack socket.
//! 1. Shrink the heatshrink and screw in the three jack sockets.
//! 1. Solder a 13A green & yellow wire to the remaining green jack socket, long enough to reach the 13A socket. Add heashrink and fit it to the top right jack hole.
//! 1. Solder a 13A blue wire to the remaining blue jack socket, long enough to reach the 13A socket. Add heatshrink and fit to the bottom middle jack hole.
//! 1. Crimp appropriate ferrules to the three wires and connect them to the 13A socket.
//! 1. Screw the socket onto the top of the case using two 20mm M3 countersunk cap screws.
//
module main_assembly()
assembly("main") {
    wire("green & yellow", 30, 150, 0.25);
    wire("blue",  30, 150, 0.25);
    for(i = [1:5])
        hidden() tubing(HSHRNK32);

    for(i = [1:3])
        vitamin(": Ferrule for 1.5mm^2 wire");

    echo(screw_length = screw_length);

    mains_in_assembly();

    explode(50, true) {
        translate_z(height)
             mains_socket(socket);

        mains_socket_hole_positions(socket)
            translate_z(height + mains_socket_height(socket))
                screw(screw, screw_length);
    }

    for(x = [-1, 0, 1])
        translate([x * jack_pitch, -mains_socket_width(socket) / 2, jack_z])
            rotate([90, 0, 0])
                jack_4mm_shielded(["blue", "blue", "brown"][x + 1], wall, ["royalblue", "royalblue", "sienna"][x + 1]);

        for(x = [-1, 1])
            translate([x * jack_pitch / 2, mains_socket_width(socket) / 2, jack_z])
                rotate([90, 0, 180])
                    jack_4mm_shielded("green", wall);
}


if($preview)
    main_assembly();
else
    socket_box_stl();
