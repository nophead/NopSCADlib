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
//! A cover to go over the mains end of a PSU terminal strip to make it safe.
//! The stl and assembly must be given a name and parameterless wrappers for the stl and assembly added to the project.
//
include <../core.scad>
use <../vitamins/insert.scad>

use <../vitamins/wire.scad>
use <../vitamins/psu.scad>
use <../utils/round.scad>
use <../vitamins/terminal.scad>

wall = 1.8;
top = 1.5;
screw = M3_cap_screw;
insert = screw_insert(screw);
boss_r = insert_boss_radius(insert, wall);
counter_bore = 2;
rad = 2;
clearance = layer_height;
overlap = 6;

cable_tie_inset = wall + 4;

function psu_shroud_extent(type) = 15 + wall;                                   //! How far it extends beyond the PSU to clear the connections
function psu_shroud_wall(type) = wall;                                          //! The wall thickness
function psu_shroud_depth(type) =                                               //! Outside depth of the shroud
    psu_left_bay(type) + overlap + psu_shroud_extent(type);

function psu_shroud_width(type)  =                                              //! Outside width of the shroud
    let(terminals = psu_terminals(type))
        terminals ?
            let(y = terminals.y, tb = terminals.z)
                 wall + clearance / 2 + y + 3 * terminal_block_pitch(tb) + terminal_block_divider(tb) / 2 + wall / 2
        : psu_width(type) + 2 * wall + clearance;

function psu_shroud_height(type) = psu_height(type) + top + clearance;          //! Outside height
function psu_shroud_centre_y(type) =                                            //! Shroud centre relative to PSU centre
    psu_width(type) / 2 + clearance / 2 + wall - psu_shroud_width(type) / 2;

function psu_shroud_pitch(type)  = psu_shroud_width(type) - 2 * boss_r - eps;
function psu_shroud_screw(type)  = screw;                                       //! Screw used to fasten
function psu_shroud_cable_pitch(cable_d) = cable_d + 5;                        //! Pitch between cable entries

module psu_shroud_hole_positions(type)                                          //! Place children at the screw hole positions
    for($side = [-1, 1])
        translate([-psu_length(type) / 2 - boss_r - 1, psu_shroud_centre_y(type) + $side * psu_shroud_pitch(type) / 2])
            children();

module psu_shroud_cable_positions(type, cable_d, cables = 1)                    //! Place children at the cable tie positions
    for(i = [0 : 1 : cables - 1])
        translate([-psu_length(type) / 2 - psu_shroud_extent(type) + cable_tie_inset,
                   psu_shroud_centre_y(type) + (i - cables / 2 + 0.5) *  psu_shroud_cable_pitch(cable_d)])
            children();

module psu_shroud_holes(type, cable_d, cables = 1) {                            //! Drill the screw and ziptie holes
    psu_shroud_hole_positions(type)
        drill(screw_clearance_radius(screw), 0);

    psu_shroud_cable_positions(type, cable_d, cables)
        cable_tie_holes(cable_d / 2, h = 0);
}

module psu_shroud(type, cable_d, name, cables = 1) { //! Generate the STL file for a specified ssr and cable
    extent = psu_shroud_extent(type);
    depth = psu_shroud_depth(type);
    width = psu_shroud_width(type);
    height = psu_shroud_height(type);
    centre_x = -psu_length(type) / 2 -  psu_shroud_extent(type) + psu_shroud_depth(type) / 2;
    centre_y = psu_shroud_centre_y(type);
    terminal_clearance = 0.5;
    tb = psu_terminals(type).z;

    module shape() {
        difference() {
            round(or = wall / 2 - eps, ir = 0) difference() {
                rounded_square([depth, width], rad);

                rounded_square([depth - 2 * wall, width - 2 * wall], rad - wall);

                translate([depth / 2, 0])
                    square([2 * rad, width], center = true);

                translate([depth / 2, width / 2 - 5])
                    square([2 * (overlap + terminal_clearance), 10], center = true);
            }
            for(i = [0 : 1 : cables - 1])
                translate([0, (i - cables / 2 + 0.5) *  psu_shroud_cable_pitch(cable_d)])
                    square([depth + 1, cable_d], center = true);
        }
    }

    stl(str("psu_shroud_", name)) {
        // base and sides
        translate([centre_x, -centre_y]) {
            rounded_rectangle([depth - eps, width - eps, top], rad);

            linear_extrude(height)
                difference() {
                    shape();

                    translate([depth / 2, width / 2 - 5])
                        square([2 * (depth - extent + terminal_clearance), 10], center = true);
            }
            linear_extrude(height - terminal_block_height(tb) - psu_terminal_block_z(type) - terminal_clearance)
                shape();
        }
        // cable slots
        for(i = [0 : 1 : cables - 1])
            translate([centre_x - depth / 2 + wall / 2, -centre_y + (i - cables / 2 + 0.5) *  psu_shroud_cable_pitch(cable_d), height / 2])
                rotate([90, 0, 90])
                    linear_extrude(wall, center = true)
                        difference() {
                            square([cable_d + eps, height], center = true);

                            translate([0, height / 2])
                                    vertical_tearslot(h = 0, r = cable_d / 2, l = cable_d);
                    }
        // insert lugs
        mirror([0, 1, 0])
            psu_shroud_hole_positions(type)
                translate_z(height)
                    rotate($side * 90)
                        insert_lug(insert, wall, counter_bore);
     }
}

module psu_shroud_assembly(type, cable_d, name, cables = 1) //! The printed parts with inserts fitted
assembly(str("PSU_shroud_", name), ngb = true) {

    translate_z(psu_shroud_height(type))
        vflip()
            stl_colour(pp1_colour) psu_shroud(type, cable_d, name, cables);

    psu_shroud_hole_positions(type)
        vflip()
            insert(insert);
}

module psu_shroud_fastened_assembly(type, cable_d, thickness, name, cables = 1, screw = screw) //! Assembly with screws in place
{
    screw_length = screw_length(screw,thickness + counter_bore, 2, true);

    psu_shroud_assembly(type, cable_d, name, cables);

    translate_z(-thickness)
        psu_shroud_hole_positions(type)
            vflip()
                screw_and_washer(screw, screw_length, true);

    psu_shroud_cable_positions(type, cable_d, cables)
        cable_tie(cable_d / 2, thickness);
}
