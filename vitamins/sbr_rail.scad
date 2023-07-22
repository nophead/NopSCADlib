//
// NopSCADlib Copyright Chris Palmer 2023
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
//! SBR rails
//!
//! The rails are drawn from the center of the rod.
//! `sbr_rail_center_height(type)` can be used to determine where the bottom of the rail is.
//
include <../utils/core/core.scad>
use <bearing_block.scad>
use <linear_bearing.scad>
use <rod.scad>
use <screw.scad>

function sbr_rail_diameter(type)        = type[1]; //! Diameter of the rod
function sbr_rail_center_height(type)   = type[2]; //! Height of the center above the bottom of the rail
function sbr_rail_base_width(type)      = type[3]; //! Width of the rail base
function sbr_rail_carriage(type)        = type[5]; //! Carriage to use with this rail
function sbr_rail_screw(type)           = type[7]; //! Screw to fasten this rail

module sbr_rail(type , l) { //! Draw an SBR rail
    base_colour = grey(70);
    screw_colour = grey(10);
    d = sbr_rail_diameter(type);
    h = sbr_rail_center_height(type);
    B = sbr_rail_base_width(type);
    T = type[4];
    C = type[8];
    S2 = sbr_rail_screw(type);

    S3 = type[9];   // Screw that fastens the rod to the base
    S3L = type[10]; // length of that screw

    h1 = open_bearing_width(sbr_bearing(sbr_rail_carriage(type)));

    vitamin(str("sbr_rail(", d, ", ", l, "): SBR", d, " rail, length ", l, "mm"));

    not_on_bom()
        no_explode()
            rod(d, l, center=true);

    base = (h1/2 + C/2) /2;  // guess, not clear from drawings

    color(base_colour)
        difference() {
            linear_extrude(l - 5, center=true, convexity=2)
                translate([0,h-(T/2),0])
                    polygon([
                        [-h1/2, -T/2],
                        [-h1/2 - T/2, T/2],
                        [-B/2, T/2],
                        [-B/2, -T/2],
                        [-base, -T/2],
                        [-d/4, -h+(d/2)],
                        [d/4, -h+(d/2)],
                        [base, -T/2],
                        [B/2, -T/2],
                        [B/2, T/2],
                        [h1/2 + T/2, T/2],
                        [h1/2, -T/2],
                    ]);
            sbr_screw_locations(type, l)
                translate([0,h-T+0.01,0])
                    rotate([90,0,0])
                        cylinder(r=screw_clearance_radius(S3), h=S3L, center=true);
            sbr_screw_positions(type, l)
                translate([0,T/2,0])
                    rotate([90,0,0])
                        cylinder(r=screw_clearance_radius(S2), h=T+0.1, center=true);

        }

    not_on_bom()
        no_explode()
            color(screw_colour)
                sbr_screw_locations(type, l)
                    translate([0,h-T,0])
                        rotate([270,0,0])
                            screw(S3, S3L);
}

module sbr_screw_locations(type, l) { //! Linear locations of screws
    P = type[6];

    count = floor(l / P);
    first = (l - count * P)/2;
    N = first == 0 ? P/2 : first;  // we don't want screws right on the edge

    for (x = [N:P:l])
        translate([0,0,l/2 - x])
            children();
}

module sbr_screw_positions(type, l) { //! Screw positions
    h = type[2];
    T = type[4];
    C = type[8];
    S2 = sbr_rail_screw(type);

    for (x = [-C/2, C/2])
        translate([x,h-T, 0])
            sbr_screw_locations(type, l)
                children();


}
