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
//! Door hinges to hang an acrylic sheet door on a 3D printer, default 6mm thick.
//!
//! The screws are tapped into the acrylic.
//! Rubber door [sealing strip](#sealing_strip) is used to make it airtight and a [door_latch](#door_latch) holds it closed.
//
include <../core.scad>

width = 18;
thickness = 4;
rad = 3;
dia = 12;

pin_screw = M3_cap_screw;
screw = M3_dome_screw;
stat_screw = M4_dome_screw;

stat_width = 15;
stat_length = 34;
stat_clearance = 0.75;

function door_hinge_pin_x() = -dia / 2;                     //! X offset of the hinge pin
function door_hinge_pin_y() = -dia / 2 - stat_clearance;    //! Y offset of the hinge pin
function door_hinge_screw() = screw;                        //! Screw type used for hinge pin
function door_hinge_stat_screw() = stat_screw;              //! Screw use to fasten the stationary part
function door_hinge_stat_width() = stat_width;              //! Width of the stationary part
function door_hinge_stat_length() = stat_length;            //! Length of the stationary part

module door_hinge_hole_positions(dir = 0) {                 //! Position children at the door hole positions
    hole_pitch = width - 10;

    for(side = [-1, 1])
        translate([width / 2 + side * hole_pitch / 2, -dir * width / 2 -side * hole_pitch / 2])
            children();
}

module door_hinge(door_thickness) {                         //! Generates STL for the moving part of the hinge

    hole_pitch = width - 10;

    stl(str("door_hinge_", door_thickness))
        union() {
            rotate([90, 0, 0])
                linear_extrude(width, center = true)
                    difference() {
                        hull() {
                            translate([dia / 2, thickness + door_thickness / 2])
                                intersection() {
                                    rotate(180)
                                        teardrop(r = dia / 2, h = 0, truncate = false);

                                    square([dia + 1, 2 * thickness + door_thickness], center = true);
                                }

                                square([1, thickness + door_thickness]);
                        }
                        translate([dia / 2, thickness + door_thickness / 2])
                            teardrop_plus(r = screw_clearance_radius(pin_screw), h = 0);
                    }
            linear_extrude(thickness)
                difference() {
                    hull() {
                        translate([0, -width / 2])
                            square([1, width]);

                        for(side = [-1, 1])
                            translate([-width + rad, side * (width / 2 - rad)])
                                circle4n(rad);
                    }
                    rotate(180)
                        vflip()
                            door_hinge_hole_positions()
                                poly_circle(screw_clearance_radius(screw));
                }
        }
}

module door_hinge_6_stl() door_hinge(6);

module door_hinge_stat_hole_positions(dir = 0) { //! Position children over the screws holes of the stationary part
    hole_pitch = dia + (stat_length - dia) / 2;

    for(side = [-1, 1])
        translate([side * hole_pitch / 2, dir * (stat_width / 2 + washer_thickness(screw_washer(pin_screw))), thickness])
            children();
}

module door_hinge_stat_stl() { //! Generates the STL for the stationary part
    stl("door_hinge_stat");

    union() {
        linear_extrude(thickness)
            difference() {
                rounded_square([stat_length, stat_width], rad);

                door_hinge_stat_hole_positions()
                    poly_circle(screw_clearance_radius(stat_screw));
            }

        rotate([90, 0, 0])
            linear_extrude(stat_width, center = true)
                difference() {
                    hull() {
                        translate([0, dia / 2 + stat_clearance])
                            circle(d = dia);

                        translate([0, 0.5])
                            square([dia, 1], center = true);
                    }
                    translate([0, dia / 2 + stat_clearance])
                        teardrop_plus(r = screw_clearance_radius(pin_screw), h = 0);
               }
    }
}

module door_hinge_assembly(top, door_thickness = 6) { //! The moving assembly that goes on the door
    dir = top ? -1 : 1;
    pin_x = door_hinge_pin_x();
    pin_y = door_hinge_pin_y();
    screw_length = screw_length(screw, thickness + door_thickness, 1);

    translate([0, pin_y - (thickness + door_thickness / 2), dir * width / 2]) {
        rotate([90, 0, 180])
            stl_colour(pp2_colour) door_hinge(door_thickness);

        rotate([90, 0, 0])
            door_hinge_hole_positions()
                screw_and_washer(screw, screw_length);
    }

    washer = screw_washer(pin_screw);
    wt = washer_thickness(washer);
    translate([pin_x, pin_y, top ? 0 : -wt])
        washer(washer);

    translate([pin_x, pin_y, top ? wt + stat_width : width])
        screw_and_washer(pin_screw, screw_length(pin_screw, width + stat_width, 2, longer = true));
}

module door_hinge_static_assembly(top, sheet_thickness = 3) { //! The stationary assembly
    dir = top ? -1 : 1;
    pin_x = door_hinge_pin_x();

    stat_screw_length = screw_length(stat_screw, thickness + sheet_thickness, 2, nyloc = true);

    translate([pin_x, 0, -dir * (stat_width / 2 + washer_thickness(screw_washer(pin_screw)))])
        rotate([90, 0, 0]) {
            stl_colour(pp1_colour) door_hinge_stat_stl();

            door_hinge_stat_hole_positions() {
                screw_and_washer(stat_screw, stat_screw_length);

                translate_z(-thickness - sheet_thickness)
                    vflip()
                        nut_and_washer(screw_nut(stat_screw), true);
            }
        }
}


module door_hinge_parts_stl() { //! Generates the STL for both parts of the hinge
    translate([2, width / 2 + 1])
        door_hinge_6_stl();

    translate([0, -stat_width / 2 - 1])
        door_hinge_stat_stl();
}
