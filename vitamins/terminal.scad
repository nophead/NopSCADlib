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

//! Terminal blocks for power supplies and PCBs.

include <../core.scad>

function terminal_block_pitch(type)   = type[0];    //! Pitch between screws
function terminal_block_divider(type) = type[1];    //! Width of the dividers
function terminal_block_height(type)  = type[2];    //! Height of the dividers
function terminal_block_depth(type)   = type[3];    //! Total depth
function terminal_block_height2(type) = type[4];    //! Height under the contacts
function terminal_block_depth2(type)  = type[5];    //! Depth of contact well

function terminal_block_length(type, ways) = terminal_block_pitch(type) * ways + terminal_block_divider(type); //! Total length of terminal block

module terminal_block(type, ways) { //! Draw a power supply terminal block
    tl = terminal_block_length(type, ways);
    depth = terminal_block_depth(type);
    depth2 = terminal_block_depth2(type);
    div = terminal_block_divider(type);
    h = terminal_block_height(type);
    h2 = terminal_block_height2(type);
    pitch = terminal_block_pitch(type);
    back_wall = depth - depth2;
    contact_depth = depth2 - back_wall;
    contact_width = pitch - div;
    contact_h = 0.4;
    washer_t = 1.2;
    translate([0, -tl]) {
        color(grey(20)) {
            cube([depth, tl, h2]);

            translate([depth2, 0])
                cube([depth - depth2, tl, h]);

            for(i = [0 : ways])
                translate([0, i * pitch + div])
                    rotate([90, 0, 0])
                        linear_extrude(div)
                            hull() {
                                r = 2;
                                square([depth, eps]);

                                translate([depth - eps, 0])
                                    square([eps, h]);

                                translate([r, h - r])
                                    circle4n(r);
                            }
        }
        color("silver")
            for(i = [0 : ways - 1]) translate([0, i * pitch + div, h2]) {
                translate([back_wall, 1])
                    cube([contact_depth, contact_width - 2, contact_h]);

                translate([back_wall + contact_depth / 2 - contact_width / 2, 0])
                    cube([contact_width, contact_width, contact_h + washer_t]);

                translate([back_wall + contact_depth / 2, contact_width / 2, contact_h + washer_t])
                    not_on_bom() no_explode()
                        screw(M3_pan_screw, 8);
            }
    }
}
