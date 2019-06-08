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
//! Models of radial blowers.
//
include <../core.scad>
use <../utils/rounded_cylinder.scad>

function blower_length(type)      = type[2]; //! Length of enclosing rectangle
function blower_width(type)       = type[3]; //! Width of enclosing rectangle
function blower_depth(type)       = type[4]; //! Height
function blower_bore(type)        = type[5]; //! The air intake hole diameter
function blower_screw(type)       = type[6]; //! The type of screws needed
function blower_hub(type)         = type[7]; //! Rotor hub diameter
function blower_axis(type)        = type[8]; //! XY coordinates of the axle
function blower_screw_hole(type)  = type[9]; //! Screw hole diameter
function blower_screw_holes(type) = type[10]; //! List of XY coordinates of the screw holes
function blower_exit(type)        = type[11]; //! The width of the exit port
function blower_hub_height(type)  = type[12]; //! Height of the rotor
function blower_base(type)        = type[13]; //! Thickness of the base
function blower_top(type)         = type[14]; //! Thickness of the top
function blower_wall(type)        = type[15]; //! Side wall thickness
function blower_lug(type)         = type[16]; //! Height of the lugs

fan_colour = grey20;

module blower(type) { //! Draw specified blower
    length = blower_length(type);
    width = blower_width(type);
    depth = blower_depth(type);
    screw = blower_screw(type);

    r1 = blower_axis(type)[0];
    r2 = width - blower_axis(type)[1];
    r3 = length - blower_axis(type)[0];
    function radius(a) = a < 90 ? r1 * exp(a * ln(r2 / r1) / 90)
                                : r2 * exp((a - 90) * ln(r3 / r2) / 90);
    function spiral(a) = let(r = radius(a)) [-r * cos(a), r * sin(a)];

    module shape(inside = false)
        union() {
            hull() {
                translate(blower_axis(type))
                    polygon([for(a = [0 : 1 : 360]) spiral(a)]);

                if(blower_exit(type) > length / 2)
                    square([blower_exit(type), 1]);
            }
            offset = inside ? 5 : 0;
            translate([0, -offset])
                square([blower_exit(type), blower_axis(type)[1] + offset]);
        }

    vitamin(str("blower(", type[0], "): ", type[1]));

    color(fan_colour) {
        // screw lugs
        linear_extrude(height = blower_lug(type), center = false)
            for(hole = blower_screw_holes(type))
                difference() {
                    hull() {
                        translate(hole)
                            circle(d = blower_screw_hole(type) + 2 * blower_wall(type));

                        translate(blower_axis(type))
                            circle(d = blower_screw_hole(type) + 2 * blower_wall(type) + 7);
                    }
                    circle(d = blower_screw_hole(type));

                    shape(true);
               }
        // rotor
        translate(concat(blower_axis(type), [blower_base(type) + 1]))
            rounded_cylinder(r = blower_hub(type) / 2, h = blower_hub_height(type) - blower_base(type) - 1, r2 = 1);

        *%square([length, width]);

        // base
        linear_extrude(height = blower_base(type))
            difference() {
                shape();

                translate(concat(blower_axis(type), [blower_base(type)]))
                    circle(d = 2);
           }
        // sides
        linear_extrude(height = depth)
            difference() {
                shape();

                offset(-blower_wall(type))
                    shape(true);
           }

        // top
        translate_z(depth -blower_top(type))
            linear_extrude(height = blower_top(type))
                difference() {
                    shape();

                    translate(concat(blower_axis(type), [blower_base(type)]))
                        circle(d = blower_bore(type));
               }
    }
}

module blower_hole_positions(type) //! Translate children to screw hole positions
    for(hole = blower_screw_holes(type))
        translate(hole)
            children();
