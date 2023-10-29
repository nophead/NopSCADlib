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
//! Used for limit switches. Currently only the button type is supported as the lever and roller types are less accurate.
//!
//! The origin of the switch is in the center of the body. `microswitch_button_pos()` is the offset to tip of the button at its operating point.
//!
//! The switch is drawn with the button at the nominal operation point. This actual trigger point can be plus or minus `microswitch_op_tol(type)`.
//!
//! When the button is released it comes out by a maximum of `microswitch_fp_max(type)` from the nominal operating point.
//
include <../utils/core/core.scad>

microswitch_contact_colour        =  brass;

function microswitch_thickness(type) = type[2];     //! Body thickness
function microswitch_width(type)     = type[3];     //! Body width
function microswitch_length(type)    = type[4];     //! Body length
function microswitch_radius(type)    = type[5];     //! Body corner radius
function microswitch_hole_d(type)    = type[6];     //! Screw hole diameter
function microswitch_holes(type)     = type[7];     //! Hole positions
function microswitch_button_w(type)  = type[8];     //! Button width
function microswitch_button_t(type)  = type[9];     //! Button thickness
function microswitch_button_pos(type)= type[10];    //! Button position at operating point
function microswitch_op_tol(type)    = type[11];    //! Operating position +/- tolerance
function microswitch_fp_max(type)    = type[12];    //! Free position maximum
function microswitch_legs(type)      = type[13];    //! Leg positions
function microswitch_leg(type)       = type[14];    //! Leg types
function microswitch_body_clr(type)  = type[15];    //! Body colour
function microswitch_button_clr(type)= type[16];    //! Button colour

function microswitch_lower_extent(type) = let(leg = microswitch_leg(type)) min([for(pos = microswitch_legs(type)) pos.y - leg.y / 2]); //! How far legs extend downwards
function microswitch_right_extent(type) = let(leg = microswitch_leg(type)) max([microswitch_length(type) / 2, for(pos = microswitch_legs(type)) pos.x + leg.x / 2]); //! How far legs extend right

function microswitch_size(type) = [microswitch_length(type), microswitch_width(type), microswitch_thickness(type)]; //! Body size

module microswitch_hole_positions(type) //! Place children at the hole positions
{
    for(hole = microswitch_holes(type))
        translate(hole)
            children();
}

module microswitch_wire_positions(type, skip = undef) { //! Place children at the leg hole positions
    leg = microswitch_leg(type);
    legs = microswitch_legs(type);
    for(i = [0 : len(legs) - 1])
        if(i != skip)
            let(pos = legs[i])
                translate(leg[3] ? pos + leg[4] : pos - [leg.x, leg.y] / 6)
                    children();
}

module microswitch(type) { //! Draw specified microswitch
    vitamin(str("microswitch(", type[0], "): Microswitch ", type[1]));
    d = microswitch_button_t(type);

    color(microswitch_body_clr(type))
        linear_extrude(microswitch_thickness(type), center = true)
            difference() {    // main body
                rounded_square([microswitch_length(type), microswitch_width(type)], microswitch_radius(type));

                microswitch_hole_positions(type)
                    circle(d = microswitch_hole_d(type));
            }

    color(microswitch_button_clr(type))                          // orange button
        translate(microswitch_button_pos(type) - [0, d / 2])
            linear_extrude(microswitch_button_w(type), center = true)
                hull() {
                    circle(d = d, $fn = fn);

                    translate([0, -3])
                        circle(d = d);
                }

    color(microswitch_contact_colour)                            // yellow contacts
        for(pos = microswitch_legs(type))
            translate(pos) {
                leg = microswitch_leg(type);
                vertical = leg.y > leg.x;

                if(vertical)
                    rotate([0, 90, 0])
                        linear_extrude(leg.x, center = true)
                            difference() {
                                square([leg.z, leg.y], center = true);

                                if(leg[3])
                                    translate(leg[4])
                                        circle(d = leg[3]);
                            }
                else
                    rotate([90, 0, 0])
                        linear_extrude(leg.y, center = true)
                            difference() {
                                square([leg.x, leg.z], center = true);

                                if(leg[3])
                                    translate(leg[4])
                                        circle(d = leg[3]);
                            }

                if(!vertical && pos.y < -microswitch_width(type) / 2) {
                    gap = -microswitch_width(type) / 2 - pos.y;
                    translate([-leg.x / 2 + leg.y / 2, gap / 2])
                        cube([leg.y, gap, leg.z], center = true);
                }
            }
}
