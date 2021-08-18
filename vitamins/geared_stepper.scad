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
include <../utils/core/core.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/round.scad>

function gs_diameter(type)     = type[2]; //! Can diameter
function gs_height(type)       = type[3]; //! Can height
function gs_radius(type)       = type[4]; //! Top - or bottom + corner radius
function gs_motor(type)        = type[5]; //! Motor diameter and height if separate from gearbox
function gs_pitch(type)        = type[6]; //! Screw pitch
function gs_lug_w(type)        = type[7]; //! Screw lug width
function gs_lug_t(type)        = type[8]; //! Screw lug thickness
function gs_hole_d(type)       = type[9]; //! Screw hole diameter
function gs_offset(type)       = type[10]; //! Offset of the shaft from the centre of the can
function gs_boss_d(type)       = type[11]; //! Boss around the shaft diameter
function gs_boss_h(type)       = type[12]; //! Boss around the shaft height
function gs_shaft_d(type)      = type[13]; //! Shaft diameter
function gs_shaft_flat(type)   = type[14]; //! Shaft width across the flats
function gs_shaft_length(type) = type[15]; //! Shaft length
function gs_flat_length(type)  = type[16]; //! Shaft flat length
function gs_bulge(type)        = type[17]; //! Plastic bulge width, depth, height, z offset
function gs_bulge2(type)       = type[18]; //! Plastic rear bulge width, depth, height
function gs_wire_d(type)       = type[19]; //! Wire diameter
function gs_wires(type)        = type[20]; //! Wire colours and grouping

module geared_stepper_screw_positions(type) //! Place children at the screw positions
    for(side = [-1, 1])
        translate([side * gs_pitch(type) / 2, -gs_offset(type)])
            children();

motor_colour = "#9BA2AC";
gearbox_colour = "#FFF7EE";

module geared_stepper(type) { //! Draw the specified geared stepper
    vitamin(str("geared_stepper(", type[0], "): Geared stepper - ", type[1]));

    radius = gs_diameter(type) / 2;
    motor = gs_motor(type);
    height = gs_height(type) - motor.y;
    offset = gs_offset(type);
    lug_t = gs_lug_t(type);
    bulge = gs_bulge(type);
    bulge_z = bulge[3];
    bulge2 = gs_bulge2(type);
    wires = gs_wires(type);

    // Gearbox
    color(motor.y ? gearbox_colour : motor_colour) {
        difference() {
            rad = gs_radius(type);
            translate([0, -offset])
                if(rad >= 0)
                    rounded_cylinder(r = radius, h = height, r2 = rad);
                else
                    translate_z(height)
                        vflip()
                            rounded_cylinder(r = radius, h = height, r2 = -rad);

            if(!lug_t)
                geared_stepper_screw_positions(type)
                    cylinder(d = gs_hole_d(type), h = 10, center = true);
        }

        cylinder(d = gs_boss_d(type), h = 2 * gs_boss_h(type), center = true);

        if(lug_t)
            linear_extrude(lug_t)
                difference() {
                    hull()
                        geared_stepper_screw_positions(type)
                            circle(d = gs_lug_w(type));

                    geared_stepper_screw_positions(type)
                        circle(d = gs_hole_d(type));
                }

        if(!bulge_z)
            translate([0, -offset - radius, eps])
                cube([bulge.x - 2, 2 * (bulge.y - radius) - 2, 2 * eps], center = true);
    }

    // Motor
    if(motor.y)
        color("#9BA2AC")
            translate([0, -offset, height])
                rotate_extrude()
                    union() {
                        r = motor.x / 2;
                        rad = motor[2];
                        square([r - rad, rad]);

                        translate([0, motor.y - rad])
                            square([r - rad, rad]);

                        hull()
                            for(y = [2 * rad, motor.y - 2 * rad])
                                translate([r - rad, y])
                                    circle(rad);
                    }

    // Shaft
    f = gs_shaft_flat(type);
    two_flats = f < 0;
    vflip()
        color(two_flats ? brass : gearbox_colour) {
            d = gs_shaft_d(type);
            h = gs_shaft_length(type);
            linear_extrude(h)
                intersection() {
                    circle(d = d);

                    translate([0, two_flats ? 0 : (f - d) / 2])
                        square([d + 1, abs(f)], center = true);
                }

            cylinder(d = d, h = h - gs_flat_length(type));
        }

    // Wire block
    color(bulge_z ? "white" : "skyblue") {
        translate([0, - offset - radius, eps + bulge[3]])
            rounded_rectangle([bulge.x, 2 * (bulge.y - radius), bulge.z], 0.5, center = false);

        if(bulge2.z)
            translate([0, - offset, bulge.z + 1 - bulge2.z])
                linear_extrude(bulge2.z)
                    round(0.5)
                        intersection() {
                            circle(bulge2.y);

                            translate([0, -50])
                                square([bulge2.x, 100], center = true);
                        }
    }

    wire_d = gs_wire_d(type);
    for(j = [0 : len(wires) - 1], i = [0 : len(wires[j]) - 1])
        translate([(i - len(wires[j]) / 2 + 0.5) * wire_d, 0, bulge_z + (j ? bulge.z - 2.5 : 2.5)])
            rotate([90, 0, 0])
                color(wires[j][i])
                    cylinder(d = wire_d, h = radius + offset + 10);
}
