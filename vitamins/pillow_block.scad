//
// NopSCADlib Copyright Chris Palmer 2020
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
//! KP pillow block bearings
//
include <../core.scad>

use <../utils/tube.scad>
use <washer.scad>
use <ball_bearing.scad>

kp_pillow_block_colour = grey(70);

function kp_diameter(type)        = type[1]; //! Rod hole diameter
function kp_hole_offset(type)     = type[2]; //! Rod hole offset
function kp_size(type)            = [type[3],type[8],type[5]]; //! Size of bracket
function kp_base_height(type)     = type[7]; //! Height of base containing the bolts
function kp_screw_separation(type) = type[4]; //! Separation of bolts in the base


module kp_pillow_block(type) { //! Draw the KP pillow block
    vitamin(str("kp_pillow_block(", type[0], "): ", type[0], " pillow block"));

    d = kp_diameter(type);
    H = kp_hole_offset(type);
    L = kp_size(type)[0];
    J = kp_screw_separation(type);
    A = kp_size(type)[2];// sizeZ, includes protruding center
    N = type[6];
    H1 = kp_base_height(type);
    H0 = kp_size(type)[1];
    K = type[9];
    S = type[10];
    b = type[11];
    bolthole_radius = type[12];

    $fa = fa; $fs = fs;
    color(kp_pillow_block_colour)
        translate([0, -H, 0]) {
            fillet = 1;
            squareSizeX = (L - H0) / 2 + fillet;
            rotate([-90, 0, 0])
                linear_extrude(H1)
                    difference() {
                        union() {
                            for(i = [-L / 2, L / 2 - squareSizeX])
                                translate([i, -A / 2])
                                    rounded_square([squareSizeX, A], fillet, center = false);
                        }
                        for(i = [-J / 2, J / 2])
                            translate([i, 0])
                                circle(r = bolthole_radius);
                    }

            translate_z(-A / 2) {
                for(x = [- L / 2 + squareSizeX - fillet, L / 2 - squareSizeX + fillet - 2])
                    translate([x, 0, 0])
                        cube([2, H, A]);
                translate([0 , H, 0])
                    tube(H0 / 2, b / 2, A, center = false);
            }
            stripThickness = 4;
            translate([-H0 / 2, 0, -stripThickness / 2])
                linear_extrude(stripThickness) difference() {
                    square([H0, H]);
                    translate([H0 / 2, H])
                        circle(b / 2);
                }
        }

    not_on_bom() no_explode()
        ball_bearing(type[13]);
}

module kp_pillow_block_hole_positions(type) { //! Place children at hole positions
    for(x = [-kp_screw_separation(type), kp_screw_separation(type)])
        translate([x / 2, kp_base_height(type) - kp_hole_offset(type), 0])
            rotate([-90,0,0])
                children();
}

module kp_pillow_block_assembly(type, part_thickness = 2, screw_type = M5_cap_screw, nut_type = undef) { //! Assembly with fasteners in place
    kp_pillow_block(type);

    screw_washer_thickness = washer_thickness(screw_washer(screw_type));
    nut_type = is_undef(nut_type) ? screw_nut(screw_type) : nut_type;
    nut_washer_type = nut_washer(nut_type);
    nut_washer_thickness = nut_washer_type ? washer_thickness(nut_washer_type) : 0;

    nut_offset = kp_base_height(type) + part_thickness;
    screw_length = screw_shorter_than(nut_offset + screw_washer_thickness +  nut_thickness(nut_type) + nut_washer_thickness);

    kp_pillow_block_hole_positions(type) {
        screw_and_washer(screw_type, screw_length);

        translate_z(-nut_offset)
            vflip()
                if(nut_washer_type)
                    nut_and_washer(nut_type);
                else
                    sliding_t_nut(nut_type);
    }
}
