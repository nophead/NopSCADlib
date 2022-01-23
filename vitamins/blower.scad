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
//! Note that blower_exit() and blower_exit_offset() are for the inside of the exit for square blowers but the outside for spiral blowers.
//
include <../utils/core/core.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/quadrant.scad>
use <screw.scad>

function blower_length(type)      = type[2]; //! Length of enclosing rectangle
function blower_width(type)       = type[3]; //! Width of enclosing rectangle
function blower_depth(type)       = type[4]; //! Height
function blower_size(type)        = [blower_length(type), blower_width(type), blower_depth(type)]; //! Size
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
function blower_wall_left(type)   = type[15]; //! Left side wall thickness
function blower_wall_right(type)  = type[17]; //! Right wall thickness (for square fans)

function blower_casing_is_square(type) = blower_depth(type) < 15; //! True for square radial fans, false for spiral shape radial blowers
function blower_exit_offset(type) =   //! Offset of exit's centre from the edge
    blower_casing_is_square(type) ? len(blower_screw_holes(type)) > 2 ? blower_length(type) / 2
                                                                      : blower_wall_left(type) + blower_exit(type) / 2
                                  : blower_exit(type) / 2;
fan_colour = grey(20);

module blower_fan(type, casing_is_square) {
    module squarish(s, n) {
        polygon([
            for(i = [0 : n]) [i * s.x / n,  s.y + (i % 2) * eps],
            for(i = [0 : n]) [s.x - i * s.x / n, (i % 2) * eps],
        ]);
    }

    depth = blower_depth(type);
    blade_ir = blower_hub(type) / 2 + 0.5; // slight gap between main part of blades and hub
    blade_len = casing_is_square
        ? (blower_bore(type) - 1) / 2 - blade_ir // fan constrained by bore hole
        : blower_width(type) - blower_axis(type).x- blower_wall(type) - blade_ir; // fan extends to casing
    blade_thickness = 0.75;
    blade_count = 25;

    base_offset = 1;
    translate([blower_axis(type).x, blower_axis(type).y, blower_base(type) + base_offset])
        linear_extrude(blower_hub_height(type) - 0.5 - blower_base(type) - base_offset, center = false, convexity = 4, twist = -30, slices = round(depth / 2))
            for(i = [0 : blade_count - 1])
                rotate((360 * i) / blade_count)
                    translate([blade_ir, -blade_thickness / 2])
                        squarish([blade_len, blade_thickness], round(blade_len / 2));
}

module blower_square(type) { //! Draw a square blower
    width = blower_width(type);
    depth = blower_depth(type);
    wall_left = blower_wall_left(type);
    wall_right = blower_wall_right(type);
    hole_count = len(blower_screw_holes(type));
    hole_pitch = (blower_screw_holes(type)[1].x - blower_screw_holes(type)[0].x) / 2;
    corner_radius = width / 2 - hole_pitch;
    corner_inset = (width - blower_exit(type) - wall_left - wall_right) / (hole_count == 2 ? 1 : 2);

    module inset_corners()
        translate([width / 2, width / 2])
            for(i = hole_count == 2 ? [1, 3] : [0 : 3])
                rotate(i * 90)
                    translate([-width / 2 - eps, -width/ 2 - eps])
                        quadrant(corner_inset, corner_inset - corner_radius);

    module square_inset_corners(remove_center = false)
        difference() {
            //overall outside
            rounded_square([width, width], corner_radius, center = false);

            if (remove_center) {
                // cut out the inside, leaving the corners
                translate([hole_count == 2 ? wall_left : corner_inset + wall_left, -eps])
                    square([blower_exit(type), width / 2], center = false);

                translate(blower_axis(type))
                    circle(d = blower_bore(type) + 1);
            } else {
                // cut out the bore for the fan
                translate(blower_axis(type))
                    circle(d = blower_bore(type));
            }
            inset_corners();
        }

    base_height = blower_base(type);
    linear_extrude(base_height)
        difference () {
            rounded_square([width, width], corner_radius, center = false);
            blower_hole_positions(type)
                circle(d = blower_screw_hole(type));
        }

    // add the lugs which may be higher than the base
    linear_extrude(blower_lug(type))
        difference () {
            intersection() {
                rounded_square([width, width], corner_radius, center = false);
                inset_corners();
            }
            blower_hole_positions(type)
                circle(d = blower_screw_hole(type));
        }

    translate_z(base_height)
        linear_extrude(depth - base_height)
            square_inset_corners(remove_center = true);

    translate_z(depth - base_height)
        linear_extrude(blower_top(type))
            square_inset_corners();
}

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

    is_square = blower_casing_is_square(type); // Description starts with square!
    color(fan_colour) {
        if (is_square) {
            blower_square(type);
        } else {
            // screw lugs
            linear_extrude(blower_lug(type), center = false)
                for(hole = blower_screw_holes(type))
                    difference() {
                        hull() {
                            translate(hole)
                                circle(d = blower_screw_hole(type) + 2 * blower_wall(type));

                            translate(blower_axis(type))
                                circle(d = blower_screw_hole(type) + 2 * blower_wall(type) + 7);
                        }
                        translate(hole)
                            circle(d = blower_screw_hole(type));

                        shape(true);
                }

            *%square([length, width]);

            // base
            linear_extrude(blower_base(type))
                difference() {
                    shape();

                    translate(concat(blower_axis(type), [blower_base(type)]))
                        circle(d = 2);
            }

            // sides
            linear_extrude(depth)
                difference() {
                    shape();

                    offset(-blower_wall(type))
                        shape(true);
            }

            // top
            translate_z(depth -blower_top(type))
                linear_extrude(blower_top(type))
                    difference() {
                        shape();

                        translate(concat(blower_axis(type), [blower_base(type)]))
                            circle(d = blower_bore(type));
                }
        }
        // rotor
        translate(concat(blower_axis(type), [blower_base(type) + 1]))
            rounded_cylinder(r = blower_hub(type) / 2, h = blower_hub_height(type) - blower_base(type) - 1, r2 = 1);

        blower_fan(type, is_square);
    }
    *translate([blower_exit(type) / 2 + blower_exit_offset(type), 0])
        rotate(180)
            #cube([blower_exit(type), 30, depth]);
}

module blower_hole_positions(type) //! Translate children to screw hole positions
    for(hole = blower_screw_holes(type))
        translate(hole)
            children();
