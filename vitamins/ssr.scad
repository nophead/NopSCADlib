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
//! Solid state relays.
//
include <../utils/core/core.scad>

function ssr_part(type)       = type[1]; //! Description
function ssr_length(type)     = type[2]; //! Length
function ssr_width(type)      = type[3]; //! Width
function ssr_height(type)     = type[4]; //! Height
function ssr_base_t(type)     = type[5]; //! Thickness of metal base
function ssr_hole_d(type)     = type[6]; //! Screw hole diameter
function ssr_hole_pitch(type) = type[7]; //! Difference between screw centres
function ssr_slot_w(type)     = type[8]; //! Width of the screw slot in the body

module ssr_hole_positions(type) //! Place children at the screw positions
    for(end = [-1, 1])
        translate([end * ssr_hole_pitch(type) / 2, 0])
            children();

module ssr(type) { //! Draw specified SSR
    vitamin(str("ssr(", type[0], "): Solid state relay ", ssr_part(type)));

    l = ssr_length(type);
    w = ssr_width(type);
    t = ssr_base_t(type);
    h = ssr_height(type);

    color("silver") linear_extrude(t) difference() {
        square([l, w], center = true);

        ssr_hole_positions(type)
            circle(d = ssr_hole_d(type));
    }
    color([242/255, 236/255, 220/255])
        translate_z(t)
            linear_extrude(h - t) difference() {
                square([l, w], center = true);

                for(end = [-1, 1])
                    hull() {
                        translate([end * ssr_hole_pitch(type) / 2, 0])
                            circle(d = ssr_slot_w(type));

                        translate([end * ssr_hole_pitch(type), 0])
                            circle(d = ssr_slot_w(type));
                    }
            }
}

use <screw.scad>
use <nut.scad>
use <washer.scad>

module ssr_assembly(type, screw, thickness) { //! Assembly with fasteners in place
    screw_length = screw_length(screw, thickness + ssr_base_t(type), 2, nyloc = true);

    ssr(type);

    ssr_hole_positions(type) {
        translate_z(ssr_base_t(type))
            nut_and_washer(screw_nut(screw), true);

        translate_z(-thickness)
            vflip()
                screw_and_washer(screw, screw_length);
    }
}
