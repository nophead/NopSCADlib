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
//! Corner brackets using threaded inserts for fastening three sheets together at right angles.
//! Defaults to M3 but other screws sizes can be specified provided they have inserts defined.
//!
//! See [butt_box](#Butt_box) for an example of usage.
//!
//! Note that the block with its inserts is defined as a sub assembly, but its fasteners get added to the parent assembly.
//
include <../core.scad>
include <../vitamins/screws.scad>
include <../vitamins/inserts.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/maths.scad>

def_screw = M3_cap_screw;
wall = 3;
overshoot = 2;      // how far screw can overshoot the insert

function corner_block_screw() = def_screw; //! Default screw type

function corner_block_hole_offset(screw = def_screw) = //! Hole offset from the edge
    let(insert = screw_insert(screw))
        insert_length(insert) + max(overshoot + screw_clearance_radius(screw), insert_hole_radius(insert)) + 1;

function corner_block_width(screw = def_screw) = //! Block width, depth and height
    corner_block_hole_offset(screw) + insert_outer_d(screw_insert(screw)) / 2 + wall;

function corner_block_v_hole(screw = def_screw) = let(offset = corner_block_hole_offset(screw)) translate([offset, offset]) * rotate([180, 0, 0]); //! Transform to bottom hole

function corner_block_h_holes(screw = def_screw) = //! List of transforms to side holes
    let(offset = corner_block_hole_offset(screw))
        [translate([offset, 0,      offset])                * rotate([90, 0,   0]),
         translate([0,      offset, offset - layer_height]) * rotate([90, 0, -90])];

function corner_block_holes(screw) = concat([corner_block_v_hole(screw)], corner_block_h_holes(screw)); //! List of transforms to all holes

module corner_block_v_hole(screw = def_screw) //! Place children at the bottom screw hole
    multmatrix(corner_block_v_hole(screw))
        children();

module corner_block_h_holes(screw = def_screw) //! Place children at the side screw holes
    for(p = corner_block_h_holes(screw))
        multmatrix(p)
            children();

module corner_block_holes(screw = def_screw) //! Place children at all the holes
    for(p = corner_block_holes(screw))
        multmatrix(p)
            children();

module corner_block(screw = def_screw, name = false) { //! Generate the STL for a printed corner block
    stl(name ? name : str("corner_block", "_M", screw_radius(screw) * 20));

    r = 1;
    cb_width = corner_block_width(screw);
    cb_height = cb_width;
    cb_depth = cb_width;
    insert = screw_insert(screw);
    corner_rad = insert_outer_d(insert) / 2 + wall;
    offset = corner_block_hole_offset(screw);
    difference() {
        hull()  {
            translate([r, r])
                rounded_cylinder(r = r, h = cb_height, r2 = r);

            translate([r, cb_depth - r])
                cylinder(r = r, h = cb_height - corner_rad);

            translate([cb_width - r, r])
                cylinder(r = r, h = cb_height - corner_rad);

            translate([offset, offset, offset])
                sphere(corner_rad);

            translate([offset, offset])
                cylinder(r = corner_rad, h = offset);

            translate([offset, r, offset])
                rotate([-90, 0, 180])
                    rounded_cylinder(r = corner_rad, h = r, r2 = r);

            translate([r, offset, offset])
                rotate([0, 90, 180])
                    rounded_cylinder(r = corner_rad, h = r, r2 = r);
        }
        corner_block_v_hole(screw)
            insert_hole(insert, overshoot);

        corner_block_h_holes(screw)
            insert_hole(insert, overshoot, true);

        children();
    }
}

module corner_block_assembly(screw = def_screw, name = false) //! The printed block with inserts
assembly(str("corner_block_M", 20 * screw_radius(screw))) {
    insert = screw_insert(screw);

    color(name ? pp2_colour : pp1_colour)
        render() corner_block(screw, name) children();

    corner_block_h_holes(screw)
        insert(insert);

    corner_block_v_hole(screw)
        insert(insert);
}

module fastened_corner_block_assembly(thickness, screw = def_screw, thickness_below = undef, name = false) { //! Printed block with all fasteners
    washer = screw_washer(screw);
    insert = screw_insert(screw);
    screw_length = screw_shorter_than(2 * washer_thickness(washer) + thickness + insert_length(insert) + overshoot);

    corner_block_assembly(screw, name) children();

    corner_block_h_holes(screw)
        translate_z(thickness)
            screw_and_washer(screw, screw_length, true);

    thickness2 = thickness_below ? thickness_below : thickness;
    screw_length2 = screw_shorter_than(2 * washer_thickness(washer) + thickness2 + insert_length(insert) + overshoot);
    corner_block_v_hole(screw)
        translate_z(thickness2)
            screw_and_washer(screw, screw_length2, true);
}

module corner_block_M20_stl() corner_block(M2_cap_screw);
module corner_block_M25_stl() corner_block(M2p5_cap_screw);
module corner_block_M30_stl() corner_block(M3_cap_screw);
module corner_block_M40_stl() corner_block(M4_cap_screw);
//
//! 1. Lay the blocks out and place an M2 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M20_assembly() corner_block_assembly(M2_cap_screw);

//
//! 1. Lay the blocks out and place an M2.5 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M25_assembly() corner_block_assembly(M2p5_cap_screw);

//
//! 1. Lay the blocks out and place an M3 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M30_assembly() corner_block_assembly(M3_cap_screw);

//
//! 1. Lay the blocks out and place an M4 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M40_assembly() corner_block_assembly(M4_cap_screw);
