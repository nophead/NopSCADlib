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
//! Fixing block to mount two sheets at right angles using threaded inserts.
//! Defaults to M3 but other screw sizes can be specified provided they have inserts defined.
//!
//! See [butt_box](#Butt_box) for an example of usage.
//!
//! Note that the block with its inserts is defined as a sub assembly, but its fasteners get added to the parent assembly.
//
include <../core.scad>
include <../vitamins/screws.scad>
include <../vitamins/inserts.scad>
use <../utils/maths.scad>

def_screw = M3_cap_screw;
wall = 2.5;

function fixing_block_screw() = def_screw; //! Default screw type
function fixing_block_width(screw = def_screw) = 4 * wall + 3 * insert_outer_d(screw_insert(screw)); //! Width given screw size
function fixing_block_depth(screw = def_screw) = //! Depth given screw size
    let(insert = screw_insert(screw))
        max(insert_length(insert) + wall, insert_outer_d(insert) + 2 * wall);

function fixing_block_height(screw = def_screw) = fixing_block_depth(screw); //! Height given screw size, same as depth

function fixing_block_h_hole(screw = def_screw) = translate(fixing_block_depth(screw) / 2) * rotate([90, 0, 0]); //! Returns transform to position the horizontal screw
function fixing_block_v_holes(screw = def_screw) = //! Returns a list of transforms to position the vertical screws
    let(pitch =  2 * insert_outer_d(screw_insert(screw)) + 2 * wall, offset = fixing_block_depth(screw) / 2)
        [for(end = [-1, 1]) translate([end * pitch / 2, offset]) * rotate([180, 0, 0])];

function fixing_block_holes(screw) = concat([fixing_block_h_hole(screw)], fixing_block_v_holes(screw)); //! Returns a list of transforms to position all the screws

module fixing_block_h_hole(screw = def_screw) //! Position children on the horizontal hole
    multmatrix(fixing_block_h_hole(screw))
        children();

module fixing_block_v_holes(screw = def_screw) //! Position children on the vertical holes
    for(p = fixing_block_v_holes(screw))
        multmatrix(p)
            children();

module fixing_block_holes(screw = def_screw) //! Position children on all the holes
    for(p = fixing_block_holes(screw))
        multmatrix(p)
            children();

module fixing_block_h_hole_2D(screw = def_screw) //! Position 2D child on the horizontal hole
    translate([0, fixing_block_depth(screw) / 2])
        children();

module fixing_block(screw = def_screw) { //! Generate the STL
    stl(str("fixing_block_M", screw_radius(screw) * 20));
    r = 1;
    insert = screw_insert(screw);
    corner_rad = insert_outer_d(insert) / 2 + wall;
    fb_width = fixing_block_width(screw);
    fb_height = fixing_block_height(screw);
    fb_depth = fixing_block_depth(screw);

    difference() {
        union() {
            linear_extrude(height = fb_height, convexity = 5)
                difference() {
                    hull() {
                        for(side = [-1, 1]) {
                            translate([side * (fb_width / 2 - corner_rad), fb_depth - corner_rad])
                                circle4n(corner_rad);

                            translate([side * (fb_width / 2 - r), r])
                                circle4n(r);
                        }
                    }
                    fixing_block_v_holes(screw)
                        poly_circle(screw_clearance_radius(screw));
                }
        }
        translate_z(fb_height)
            fixing_block_v_holes(screw)
                insert_hole(insert);

        fixing_block_h_hole(screw)
            insert_hole(insert, 10, true);
    }
}

module fixing_block_assembly(screw = def_screw) pose([55, 180, 25], [0, 4.8, 4.8]) //! Printed part with the inserts inserted
assembly(str("fixing_block_M", 20 * screw_radius(screw))) {
    translate_z(fixing_block_height(screw))
        rotate([0, 180, 0])
            color(pp1_colour) render() fixing_block(screw);

    insert = screw_insert(screw);

    fixing_block_v_holes(screw)
        insert(insert);

    fixing_block_h_hole(screw)
        insert(insert);
}

module fastened_fixing_block_assembly(thickness, screw = def_screw, screw2 = undef, thickness2 = undef) { //! Assembly with fasteners in place
    module fb_screw(screw, thickness) {
        washer = screw_washer(screw);
        insert = screw_insert(screw);
        screw_length = screw_longer_than(2 * washer_thickness(washer) + thickness + insert_length(insert));

        translate_z(thickness)
            screw_and_washer(screw, screw_length, true);
    }

    no_pose() fixing_block_assembly(screw);

    fixing_block_v_holes(screw)
        fb_screw(screw, thickness2 ? thickness2 : thickness);

    fixing_block_h_hole(screw)
        fb_screw(screw2 ? screw2 : screw, thickness);
}

module fixing_block_M20_stl() fixing_block(M2_cap_screw);
module fixing_block_M25_stl() fixing_block(M2p5_cap_screw);
module fixing_block_M30_stl() fixing_block(M3_cap_screw);
module fixing_block_M40_stl() fixing_block(M4_cap_screw);

//
//! 1. Lay the blocks out with the two larger holes facing upwards.
//! 1. Place two M2 inserts into the two vertical holes of each block and push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on their backs and insert a third insert the same way.
//
module fixing_block_M20_assembly() fixing_block_assembly(M2_cap_screw);
//
//! 1. Lay the blocks out with the two larger holes facing upwards.
//! 1. Place two M2.5 inserts into the two vertical holes of each block and push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on their backs and insert a third insert the same way.
//
module fixing_block_M25_assembly() fixing_block_assembly(M2p5_cap_screw);
//
//! 1. Lay the blocks out with the two larger holes facing upwards.
//! 1. Place two M3 inserts into the two vertical holes of each block and push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on their backs and insert a third insert the same way.
//
module fixing_block_M30_assembly() fixing_block_assembly(M3_cap_screw);
//
//! 1. Lay the blocks out with the two larger holes facing upwards.
//! 1. Place two M4 inserts into the two vertical holes of each block and push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on their backs and insert a third insert the same way.
//
module fixing_block_M40_assembly() fixing_block_assembly(M4_cap_screw);
