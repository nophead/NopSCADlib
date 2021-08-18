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
//! SK shaft support brackets
//
include <../core.scad>
include <../utils/fillet.scad>

use <washer.scad>

sk_bracket_colour = grey(70);

function sk_diameter(type)        = type[1]; //! Rod hole diameter
function sk_hole_offset(type)     = type[2]; //! Rod hole offset
function sk_size(type)            = [type[4],type[6],type[5]]; //! Size of bracket
function sk_base_height(type)     = type[7]; //! Height of base containing the screws
function sk_screw_separation(type) = type[9]; //! Separation of screws in the base

module sk_bracket(type) { //! SK shaft support bracket
    vitamin(str("sk_bracket(", type[0], "): SK", sk_diameter(type), " shaft support bracket"));

    d = sk_diameter(type);
    h = sk_hole_offset(type);
    E = type[3];
    W = sk_size(type)[0];
    L = sk_size(type)[2];
    F = sk_size(type)[1];
    G = sk_base_height(type);
    P = type[8];
    B = sk_screw_separation(type);
    S = type[10];
    bolthole_radius = type[11];

    color(sk_bracket_colour) {
        translate([0 , -h, 0]) {
            fillet = 0.5;
            rotate([-90, 0, 0])
                linear_extrude(G)
                    difference() {
                        translate([-(W - 2*fillet) / 2, -L / 2, 0])
                            square([W - 2 * fillet, L]);
                        translate([-B / 2, 0])
                            circle(r = bolthole_radius);
                        translate([B / 2, 0])
                            circle(r = bolthole_radius);
                    }
            for(x = [W / 2 - 2 * fillet, -W / 2 + 2 * fillet])
                translate([x, G / 2, 0])
                    rounded_rectangle([4 * fillet, G, L], fillet, true);
        }

        translate([0, -h, -L /2])
            linear_extrude(L) {
                fillet = 0.75;
                difference() {
                    translate([-P / 2, 0])
                        rounded_square([P, F], fillet, center = false);
                    cut_width = 1;
                    translate([-cut_width / 2, h + cut_width])
                        square([cut_width, F - h]);
                    translate([0, h])
                        circle(d = d);
                }
                translate([P/2,G])
                    fillet(fillet, 0);
                translate([-P/2,G])
                    rotate(90)
                        fillet(fillet, 0);
            }
    }
    // Add the retaining bolt. No hole was cut, since it is only for display.
    color(grey(20))
        translate([P / 2 - screw_head_height(M3_cap_screw) / 2, (F - h + d / 2) / 2, 0])
            rotate([0,90,0])
                not_on_bom() no_explode()
                    screw(M3_cap_screw, P - screw_head_height(M3_cap_screw) / 2 + eps);
}

module sk_bracket_hole_positions(type) { //! Place children at hole positions
    for (x = [-sk_screw_separation(type), sk_screw_separation(type)])
        translate([x / 2, sk_base_height(type) - sk_hole_offset(type), 0])
            rotate([-90, 0, 0])
                children();
}

module sk_bracket_assembly(type, part_thickness = 2, screw_type = M5_cap_screw, nut_type = undef, max_screw_depth = 6) { //! Assembly with fasteners in place
    sk_bracket(type);

    screw_type = is_undef(screw_type) ? scs_screw(type) : screw_type;
    screw_washer_thickness = washer_thickness(screw_washer(screw_type));
    nut_type = is_undef(nut_type) ? screw_nut(screw_type) : nut_type;
    nut_washer_type = nut_washer(nut_type);
    nut_washer_thickness = nut_washer_type ? washer_thickness(nut_washer_type) : 0;

    nut_offset = sk_base_height(type) + part_thickness;
    screw_length = max_screw_depth ? screw_shorter_than(sk_base_height(type) + screw_washer_thickness + max_screw_depth)
                                   : screw_longer_than(nut_offset + screw_washer_thickness + nut_washer_thickness + nut_thickness(nut_type));
    sk_bracket_hole_positions(type) {
        screw_and_washer(screw_type, screw_length);
        translate_z(-nut_offset)
            vflip()
                if(nut_washer_type)
                    nut_and_washer(nut_type);
                else
                    sliding_t_nut(nut_type);
    }
}
