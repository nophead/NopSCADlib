//
// NopSCADlib Copyright Chris Palmer 2019
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
//! Geared tin can steppers
//
include <../core.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/round.scad>

function gs_diameter(type)     = type[2]; //! Can diameter
function gs_height(type)       = type[3]; //! Can height
function gs_pitch(type)        = type[4]; //! Screw pitch
function gs_lug_w(type)        = type[5]; //! Screw lug width
function gs_lug_t(type)        = type[6]; //! Screw lug thickness
function gs_hole_d(type)       = type[7]; //! Screw hole diameter
function gs_offset(type)       = type[8]; //! Offset of the shaft from the centre of the can
function gs_boss_d(type)       = type[9]; //! Boss around the shaft diameter
function gs_boss_h(type)       = type[10]; //! Boss around the shaft height
function gs_shaft_d(type)      = type[11]; //! Shaft diameter
function gs_shaft_flat(type)   = type[12]; //! Shaft width across the flats
function gs_shaft_length(type) = type[13]; //! Shaft length
function gs_flat_length(type)  = type[14]; //! Shaft flat length
function gs_bulge_w(type)      = type[15]; //! Plastic bulge width
function gs_bulge_d(type)      = type[16]; //! Plastic bulge depth from centre
function gs_bulge_h(type)      = type[17]; //! Plastic bulge height
function gs_bulge2_w(type)     = type[18]; //! Plastic rear bulge width
function gs_bulge2_d(type)     = type[19]; //! Plastic rear bulge depth from centre
function gs_bulge2_h(type)     = type[20]; //! Plastic rear bulge height

module geared_stepper_screw_positions(type) //! Place children at the screw positions
    for(side = [-1, 1])
        translate([side * gs_pitch(type) / 2, -gs_offset(type)])
            children();

module geared_stepper(type) { //! Draw the specified geared stepper
    vitamin(str("geared_stepper(", type[0], "): Geared stepper - ", type[1]));

    radius = gs_diameter(type) / 2;
    height = gs_height(type);
    offset = gs_offset(type);
    color("silver") {
        translate([0, -offset])
            rounded_cylinder(r = radius, h = height, r2 = 1);

        cylinder(d = gs_boss_d(type), h = 2 * gs_boss_h(type), center = true);

        linear_extrude(height = gs_lug_t(type))
            difference() {
                hull()
                    geared_stepper_screw_positions(type)
                        circle(d = gs_lug_w(type));

                geared_stepper_screw_positions(type)
                    circle(d = gs_hole_d(type));
            }

        translate([0, -offset - radius, eps])
            cube([gs_bulge_w(type) - 2, 2 * (gs_bulge_d(type) - radius) - 2, 2 * eps], center = true);
    }
    vflip()
        color(brass) {
            d = gs_shaft_d(type);
            h = gs_shaft_length(type);
            linear_extrude(height = h)
                intersection() {
                    circle(d = d);

                    square([d + 1, gs_shaft_flat(type)], center = true);
                }

            cylinder(d = d, h = h - gs_flat_length(type));
        }

    color("skyblue") {
        h1 = gs_bulge_h(type);
        translate([0, - offset - radius, eps])
            rounded_rectangle([gs_bulge_w(type), 2 * (gs_bulge_d(type) - radius), h1], 0.5, center = false);

        h2 = gs_bulge2_h(type);
        translate([0, - offset, h1 + 1 - h2])
            linear_extrude(height = h2)
                round(0.5)
                    intersection() {
                        circle(gs_bulge2_d(type));

                        translate([0, -50])
                            square([gs_bulge2_w(type), 100], center = true);
                    }
    }

    translate_z(2.5)
        for(i = [0 : 4])
            translate([i - 2.5, 0])
                rotate([90, 0, 0])
                    color(["yellow", "orange", "red", "pink", "blue"][i])
                        cylinder(d = 1, h = radius + offset + 10);
}
