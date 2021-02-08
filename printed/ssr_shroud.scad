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
//! A cover to go over the mains end of an SSR to make it safe to be touched.
//! The STL and assembly must be given a name and parameterless wrappers for the stl and assembly added to the project.
//
include <../core.scad>
use <../vitamins/insert.scad>

use <../vitamins/wire.scad>
use <../vitamins/ssr.scad>
use <../utils/round.scad>

wall = 1.8;
top = 1.5;
screw = M3_cap_screw;
insert = screw_insert(screw);
boss_r = insert_boss_radius(insert, wall);
counter_bore = 2;
rad = 3;
clearance = layer_height;

function ssr_shroud_pitch(type) = ssr_width(type) + 2 * wall - 2 * boss_r - eps;
function ssr_shroud_screw(type) = screw;                                    //! Screw used to fasten
function ssr_shroud_extent(type, cable_d) = 2 * boss_r + 1 + cable_d + rad; //! How far it extends beyond the SSR
function ssr_shroud_width(type) = ssr_width(type) + 2 * wall + clearance;   //! Outside width of shroud
function ssr_shroud_height(type) = ssr_height(type) + top + clearance;      //! Outside height
function ssr_shroud_cable_x(type, cable_d) =  -ssr_length(type) / 2 - 2 * boss_r - 1 - cable_d / 2; //! Position of cable entry holes

module ssr_shroud_hole_positions(type)                                      //! Place children at the screw hole positions
    for($side = [-1, 1])
        translate([-ssr_length(type) / 2 -boss_r, $side * ssr_shroud_pitch(type) / 2])
            vflip()
                children();

module ssr_shroud_holes(type, cable_d) { //! Drill the screw and ziptie holes
    ssr_shroud_hole_positions(type)
        drill(screw_clearance_radius(screw), 0);

    for(side = [-1, 1])
        translate([ssr_shroud_cable_x(type, cable_d), side * (ssr_width(type) / 2 - 2 * boss_r)])
            rotate(-90)
                cable_tie_holes(cable_d / 2, h = 0);
}

module ssr_shroud(type, cable_d, name) {    //! Generate the STL file for a specified ssr and cable
    width = ssr_shroud_width(type);
    depth = ssr_length(type) / 3 + ssr_shroud_extent(type, cable_d);
    height = ssr_shroud_height(type);
    cable_x = ssr_shroud_cable_x(type, cable_d);
    center_x = -ssr_length(type) / 6 - depth / 2;


    stl(str("ssr_shroud_", name)) {
        // base and sides
        translate([center_x, 0]) {
            rounded_rectangle([depth - eps, width - eps, top], rad);

            linear_extrude(height) difference() {
                round(or = wall / 2 - eps, ir = 0) difference() {
                    rounded_square([depth, width], rad);

                    rounded_square([depth - 2 * wall, width - 2 * wall], rad - wall);

                    translate([depth / 2, 0])
                        square([2 * rad, width], center = true);

                }
                translate([cable_x - center_x, 0])
                    square([cable_d, width + 1], center = true);
            }
        }
        // cable slots
        for(side = [-1, 1])
            translate([cable_x, side * (width / 2 - wall / 2), height / 2])
                rotate([90, 0, 0])
                    linear_extrude(wall, center = true)
                        difference() {
                            square([cable_d + eps, height], center = true);

                            translate([0, height / 2])
                                vertical_tearslot(h = 0, r = cable_d / 2, l = cable_d);
                        }
        // insert boss
        ssr_shroud_hole_positions(type)
            vflip()
                translate_z(height)
                    rotate($side * 90)
                        insert_lug(insert, wall, counter_bore);
    }
}

module ssr_shroud_assembly(type, cable_d, name) //! The printed parts with inserts fitted
assembly(str("SSR_shroud_", name), ngb = true) {

    translate_z(ssr_shroud_height(type))
        vflip()
            stl_colour(pp1_colour) ssr_shroud(type, cable_d, name);

    ssr_shroud_hole_positions(type)
        insert(insert);
}

module ssr_shroud_fastened_assembly(type, cable_d, thickness, name) //! Assembly with screws in place
{
    screw_length = screw_length(screw, thickness + counter_bore, 2, true);

    ssr_shroud_assembly(type, cable_d, name);

    translate_z(-thickness)
        ssr_shroud_hole_positions(type)
            screw_and_washer(screw, screw_length, true);

    for(side = [-1, 1])
        translate([ssr_shroud_cable_x(type, cable_d), side * (ssr_width(type) / 2 - 2 * boss_r)]) {
            rotate(-90)
                cable_tie(cable_d / 2, thickness);

            *translate_z(cable_d / 2)
                rotate([90, 0, 0])
                    stl_colour(grey(20))
                        cylinder(d = cable_d, h = 20, center = true);
        }
}
