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
//! Rocker switch. Also used for neon indicator in the same form factor.
//
include <../utils/core/core.scad>
use <spade.scad>

function rocker_part(type)     = type[1];   //! Part description
function rocker_slot_w(type)   = type[2];   //! Panel slot width
function rocker_slot_h(type)   = type[3];   //! Panel slot height
function rocker_flange_w(type) = type[4];   //! Flange width
function rocker_flange_h(type) = type[5];   //! Flange height
function rocker_flange_t(type) = type[6];   //! Flange thickness
function rocker_width(type)    = type[7];   //! Body width
function rocker_height(type)   = type[8];   //! Body height
function rocker_depth(type)    = type[9];   //! Body depth
function rocker_bezel(type)    = type[10];  //! Bezel width
function rocker_pivot(type)    = type[11];  //! Pivot distance from the back of the flange
function rocker_button(type)   = type[12];  //! How far the button extends from the bezel
function rocker_spades(type)   = type[13];  //! Spade types and positions
function rocker_size(type)     = [rocker_width(type), rocker_height(type), rocker_depth(type)]; //! Width, height, and depth in a vector
function rocker_slot(type)     = [rocker_slot_w(type), rocker_slot_h(type)]; //! Rocker slot in a vector

module rocker(type, colour) { //! Draw the specified rocker switch
    vitamin(str("rocker(", type[0], "): ", rocker_part(type)));

    bezel = rocker_bezel(type);
    clearance = 0.2;
    rocker_w = rocker_flange_w(type) - 2 * bezel - clearance;
    rocker_h = rocker_flange_h(type) - 2 * bezel - clearance;
    rocker_r = sqrt(sqr(rocker_h / 2) + sqr(rocker_flange_t(type) - rocker_pivot(type)));
    y = rocker_button(type) + rocker_flange_t(type) - rocker_pivot(type);
    x = sqrt(sqr(rocker_r) - sqr(y));

    x2 = rocker_h /2 + x;
    y2 = rocker_button(type);
    rocker_r2 = (sqr(x2) + sqr(y2)) / (2 * y2);

    $fa = fa; $fs = $fs;
    explode(30) {
        color(grey(20)) {
            linear_extrude(rocker_flange_t(type))
                difference() {
                    rounded_square([rocker_flange_w(type), rocker_flange_h(type)], 0.5);

                    square([rocker_w + clearance, rocker_h + clearance], center = true);
                }

            translate_z(-rocker_depth(type))
                rounded_rectangle([rocker_width(type), rocker_height(type), rocker_depth(type) + eps], 0.5, center = false);
        }
        if(rocker_pivot(type))
            color(colour ? colour : grey(30))
                translate_z(rocker_pivot(type))
                    rotate([90, 0, 90])
                        linear_extrude(rocker_w, center = true)
                            difference() {
                                circle(rocker_r);

                                translate([rocker_h / 2, rocker_flange_t(type) + rocker_r2 - rocker_pivot(type)])
                                    circle(rocker_r2);

                            }

        else
            color(colour ? colour : "red") cube([rocker_w, rocker_h, 2 * (rocker_flange_t(type) + rocker_button(type))], center = true);

        for(spade = rocker_spades(type))
            translate([spade[2], spade[3], -rocker_depth(type)])
                rotate([180, 0, spade[4]])
                    spade(spade[0], spade[1]);
    }
}

module rocker_hole(type, h = 0, rounded = true) //! Make a hole to accept a rocker switch, by default 2D, set h for 3D
    extrude_if(h)
        rounded_square([rocker_slot_w(type), rocker_slot_h(type)], rounded ? 1 : 0, center = true);
