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
//! PCB mounted buttons. Can optionally have a coloured cap
//
include <../utils/core/core.scad>
use <../utils/rounded_cylinder.scad>

function square_button_width(type)        = type[1];  //! Width and depth of the base
function square_button_height(type)       = type[2];  //! Height of the base
function square_button_wall(type)         = type[3];  //! Offset of the metal part
function square_button_rivit(type)        = type[4];  //! Size of the corner rivets
function square_button_d(type)            = type[5];  //! Button diameter
function square_button_h(type)            = type[6];  //! Height of the button above the PCB
function square_button_cap_flange_d(type) = type[7];  //! Diameter of the flange of the cap
function square_button_cap_d(type)        = type[8];  //! Diameter of the body of the cap
function square_button_cap_h(type)        = type[9];  //! Height of the cap including the stem
function square_button_cap_stem(type)     = type[10]; //! Length of the cap stem
function square_button_cap_flange_h(type) = type[11]; //! Height of the cap flange

module square_button(type, colour = "yellow") { //! Draw square button with specified cap colour if it has a cap
    w = square_button_width(type);
    flange_d = square_button_cap_flange_d(type);
    vitamin(str("square_button(", type[0], flange_d ? str(", \"", colour, "\"") : "", "): Square button ", w, "mm",
        flange_d ? str(" with ", colour, " cap") : ""));
    h = square_button_height(type);
    wall = square_button_wall(type);
    rivit = square_button_rivit(type);
    pitch = (w/ 2 - wall - rivit * 0.75);
    stem = square_button_cap_stem(type);

    color(grey(20)) {
        rounded_rectangle([w, w, h - 0.5], r = wall);

        for(x = [-1, 1], y = [-1, 1])
            translate([x * pitch, y * pitch])
                cylinder(d = rivit, h = h);

        cylinder(d = square_button_d(type), h = square_button_h(type));
    }

    color("silver")
        translate_z(h - 0.5)
            rounded_rectangle([w - 2 * wall, w - 2 * wall, 0.2], r = wall, center = true);

    if(flange_d)
        translate_z(square_button_h(type))
            color(colour) rotate_extrude() {
                square([square_button_d(type) / 2, stem]);

                translate([0, stem]) {
                    square([flange_d / 2, square_button_cap_flange_h(type)]);

                    rounded_corner(r = square_button_cap_d(type) / 2, h = square_button_cap_h(type) - stem, r2 = 0.5);
                }
            }
}
