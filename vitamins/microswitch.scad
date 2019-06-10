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
//! Used for limit switches.
//
include <../core.scad>

microswitch_contact_color        =  brass;

function microswitch_thickness(type) = type[2];     //! Body thickness
function microswitch_width(type)     = type[3];     //! Body width
function microswitch_length(type)    = type[4];     //! Body length
function microswitch_radius(type)    = type[5];     //! Body corner radius
function microswitch_hole_d(type)    = type[6];     //! Screw hole diameter
function microswitch_holes(type)     = type[7];     //! Hole positions
function microswitch_button_w(type)  = type[8];     //! Button width
function microswitch_button_t(type)  = type[9];     //! Button thickness
function microswitch_button_pos(type)= type[10];    //! Button position
function microswitch_legs(type)      = type[11];    //! Leg positions
function microswitch_leg(type)       = type[12];    //! Leg types
function microswitch_body_clr(type)  = type[13];    //! Body colour
function microswitch_button_clr(type)= type[14];    //! Button colour

function microswitch_lower_extent(type) = let(leg = microswitch_leg(type)) min([for(pos = microswitch_legs(type)) pos.y - leg.y / 2]); //! How far legs extend downwards
function microswitch_right_extent(type) = let(leg = microswitch_leg(type)) max([microswitch_length(type) / 2, for(pos = microswitch_legs(type)) pos.x + leg.x / 2]); //! How far legs extend right

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
        linear_extrude(height = microswitch_thickness(type), center = true)
            difference() {    // main body
                rounded_square([microswitch_length(type), microswitch_width(type)], microswitch_radius(type));

                microswitch_hole_positions(type)
                    circle(d = microswitch_hole_d(type));
            }

    color(microswitch_button_clr(type))                          // orange button
        translate(microswitch_button_pos(type) - [0, d / 2])
            linear_extrude(height = microswitch_button_w(type), center = true)
                hull() {
                    circle(d = d);

                    translate([0, -3])
                        circle(d = d);
                }

    color(microswitch_contact_color)                            // yellow contacts
        for(pos = microswitch_legs(type))
            translate(pos) {
                leg = microswitch_leg(type);
                vertical = leg.y > leg.x;

                if(vertical)
                    rotate([0, 90, 0])
                        linear_extrude(height = leg.x, center = true)
                            difference() {
                                square([leg.z, leg.y], center = true);

                                if(leg[3])
                                    translate(leg[4])
                                        circle(d = leg[3]);
                            }
                else
                    rotate([90, 0, 0])
                        linear_extrude(height = leg.y, center = true)
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
