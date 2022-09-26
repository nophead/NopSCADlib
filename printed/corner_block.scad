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
//!
//! Specific fasteners can be omitted by setting a side's thickness to 0 and the block omitted by setting `show_block` to false.
//! This allows the block and one set of fasteners to be on one assembly and the other fasteners on the mating assemblies.
//!
//! Star washers can be omitted by setting `star_washers` to false.
//!
//! A 2screw_block is a thinner version with two screws and two mating surfaces. It can be used as an alternative to fixing blocks when
//! high lateral rigidity is not required.
//
include <../core.scad>
use <../vitamins/insert.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/maths.scad>

def_screw = M3_cap_screw;
wall = 3;
overshoot = 2;      // how far screw can overshoot the insert

function corner_block_screw() = def_screw; //! Default screw type

function corner_block_hole_offset(screw = def_screw, short_insert = false) = //! Hole offset from the edge
    let(insert = screw_insert(screw, short_insert))
        insert_length(insert) + max(overshoot + screw_clearance_radius(screw), insert_hole_radius(insert)) + 1;

function corner_block_width(screw = def_screw, short_insert = false) = //! Block width, depth and height
    corner_block_hole_offset(screw, short_insert) + insert_outer_d(screw_insert(screw, short_insert)) / 2 + wall;

function corner_block_v_hole(screw = def_screw, short_insert = false) = //! Transform to bottom hole
    let(offset = corner_block_hole_offset(screw, short_insert))
        translate([offset, offset]) * rotate([180, 0, 0]);

function corner_block_h_holes(screw = def_screw, short_insert = false) = //! List of transforms to side holes
    let(offset = corner_block_hole_offset(screw, short_insert))
        [translate([offset, 0,      offset])                * rotate([90, 0,   0]),
         translate([0,      offset, offset - layer_height]) * rotate([90, 0, -90])];

function corner_block_holes(screw, short_insert = false) =  //! List of transforms to all holes
    concat([corner_block_v_hole(screw, short_insert)], corner_block_h_holes(screw, short_insert));

module corner_block_v_hole(screw = def_screw, short_insert = false) //! Place children at the bottom screw hole
    multmatrix(corner_block_v_hole(screw, short_insert))
        children();

module corner_block_h_holes(screw = def_screw, index = undef, short_insert = false) //! Place children at the side screw holes
    for(p = !is_undef(index) ? [corner_block_h_holes(screw, short_insert)[index]] : corner_block_h_holes(screw, short_insert))
        multmatrix(p)
            children();

module corner_block_holes(screw = def_screw, short_insert = false) //! Place children at all the holes
    for(p = corner_block_holes(screw, short_insert))
        multmatrix(p)
            children();

module corner_block(screw = def_screw, name = false, short_insert = false) { //! Generate the STL for a printed corner block
    r = 1;
    cb_width = corner_block_width(screw, short_insert);
    cb_height = cb_width;
    cb_depth = cb_width;
    insert = screw_insert(screw, short_insert);
    corner_rad = insert_outer_d(insert) / 2 + wall;
    offset = corner_block_hole_offset(screw, short_insert);

    stl(name ? name : str("corner_block", "_M", screw_radius(screw) * 20, short_insert ? "_s": ""))
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
            corner_block_v_hole(screw, short_insert)
                insert_hole(insert, overshoot);

            corner_block_h_holes(screw, short_insert = short_insert)
                insert_hole(insert, overshoot, true);

            children();
        }
}

module corner_block_assembly(screw = def_screw, name = false, short_insert = false) //! The printed block with inserts
assembly(name ? name : str("corner_block_M", 20 * screw_radius(screw), short_insert ? "_s": ""), ngb = true) {
    insert = screw_insert(screw, short_insert);

    stl_colour(name ? pp2_colour : pp1_colour)
        render() corner_block(screw, name, short_insert) children();

    corner_block_h_holes(screw, short_insert = short_insert)
        insert(insert);

    corner_block_v_hole(screw, short_insert)
        insert(insert);
}

module fastened_corner_block_assembly(thickness, screw = def_screw, thickness_below = undef, thickness_side2 = undef, name = false, show_block = true, star_washers = true, short_insert = false) { //! Printed block with all fasteners
    thickness2 = !is_undef(thickness_below) ? thickness_below : thickness;
    thickness3 = !is_undef(thickness_side2) ? thickness_side2 : thickness;
    insert = screw_insert(screw, short_insert);
    function screw_len(t) = screw_length(screw, t + overshoot, star_washers ? 2 : 1, insert);
    screw_length = screw_len(thickness);
    screw_length2 = screw_len(thickness2);
    screw_length3 = screw_len(thickness3);

    if(show_block)
        corner_block_assembly(screw, name, short_insert) children();

    if(thickness)
        corner_block_h_holes(screw, 0, short_insert)
            translate_z(thickness)
                screw_and_washer(screw, screw_length, star_washers);

    if(thickness3)
        corner_block_h_holes(screw, 1, short_insert)
            translate_z(thickness3)
                screw_and_washer(screw, screw_length3, star_washers);

    if(thickness2)
        corner_block_v_hole(screw, short_insert)
            translate_z(thickness2)
                screw_and_washer(screw, screw_length2, star_washers);
}

module corner_block_M20_stl() corner_block(M2_cap_screw);
module corner_block_M25_stl() corner_block(M2p5_cap_screw);
module corner_block_M30_stl() corner_block(M3_cap_screw);
module corner_block_M40_stl() corner_block(M4_cap_screw);
module corner_block_M20_s_stl() corner_block(M2_cap_screw, short_insert = true);
module corner_block_M25_s_stl() corner_block(M2p5_cap_screw, short_insert = true);
module corner_block_M30_s_stl() corner_block(M3_cap_screw, short_insert = true);
module corner_block_M40_s_stl() corner_block(M4_cap_screw, short_insert = true);
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

//
//! 1. Lay the blocks out and place an M2 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M20_s_assembly() corner_block_assembly(M2_cap_screw, short_insert = true);

//
//! 1. Lay the blocks out and place an M2.5 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M25_s_assembly() corner_block_assembly(M2p5_cap_screw, short_insert = true);

//
//! 1. Lay the blocks out and place an M3 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M30_s_assembly() corner_block_assembly(M3_cap_screw, short_insert = true);

//
//! 1. Lay the blocks out and place an M4 insert in each upward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other two flat sides and repeat.
//
module corner_block_M40_s_assembly() corner_block_assembly(M4_cap_screw, short_insert = true);


function 2screw_block_width(screw = def_screw, short_insert = false) = //! 2 screw block width is narrower, height and depth are as corner_block
    insert_outer_d(screw_insert(screw, short_insert)) + 2 * wall;

function 2screw_block_v_hole(screw = def_screw, short_insert = false) = translate([0, corner_block_hole_offset(screw, short_insert)]) * rotate([180, 0, 0]); //! Transform to bottom hole
function 2screw_block_h_hole(screw = def_screw, short_insert = false) = translate([0, 0, corner_block_hole_offset(screw, short_insert)]) * rotate([90, 0, 0]); //! Transform to front hole
function 2screw_block_holes(screw, short_insert = false) = concat([2screw_block_v_hole(screw, short_insert)], [2screw_block_h_hole(screw, short_insert)]); //! List of transforms to both holes

module 2screw_block_v_hole(screw = def_screw, short_insert = false) //! Place children at the bottom screw hole
    multmatrix(2screw_block_v_hole(screw, short_insert))
        children();

module 2screw_block_h_hole(screw = def_screw, short_insert = false) //! Place children at the front screw hole
    multmatrix(2screw_block_h_hole(screw, short_insert))
        children();

module 2screw_block_holes(screw = def_screw, short_insert = false) //! Place children at both screw holes
    for(p = 2screw_block_holes(screw, short_insert))
        multmatrix(p)
            children();

module 2screw_block(screw = def_screw, name = false, short_insert = false) { //! Generate the STL for a printed 2screw block
    r = 1;
    cb_width = 2screw_block_width(screw, short_insert);
    cb_height = corner_block_width(screw, short_insert);
    cb_depth = cb_height;
    insert = screw_insert(screw, short_insert);
    corner_rad = insert_outer_d(insert) / 2 + wall;
    offset = corner_block_hole_offset(screw, short_insert);

    stl(name ? name : str("2screw_block", "_M", screw_radius(screw) * 20, short_insert ? "_s" : ""))
        difference() {
            hull()  {
                translate([-cb_width / 2 + r, r])
                    cylinder(r = r, h = 1);

                translate([cb_width / 2 - r, r])
                    cylinder(r = r, h = 1);

                translate([0, offset, offset])
                    sphere(corner_rad);

                translate([0, offset])
                    cylinder(r = corner_rad, h = 1);

                translate([0, r, offset])
                    rotate([-90, 0, 180])
                        rounded_cylinder(r = corner_rad, h = r, r2 = r);
            }
            2screw_block_v_hole(screw, short_insert)
                insert_hole(insert, overshoot);

            2screw_block_h_hole(screw, short_insert)
                insert_hole(insert, overshoot, true);

            children();
        }
}

module 2screw_block_assembly(screw = def_screw, name = false, short_insert = false) //! The printed block with inserts
assembly(name ? name : str("2screw_block_M", 20 * screw_radius(screw), short_insert ? "_s" :""), ngb = true) {
    insert = screw_insert(screw, short_insert);

    stl_colour(name ? pp2_colour : pp1_colour)
        render() 2screw_block(screw, name, short_insert) children();

    2screw_block_holes(screw, short_insert)
        insert(insert);
}

module fastened_2screw_block_assembly(thickness, screw = def_screw, thickness_below = undef, name = false, show_block = true, star_washers = true, short_insert = false) { //! Printed block with fasteners
    thickness2 = !is_undef(thickness_below) ? thickness_below : thickness;
    insert = screw_insert(screw, short_insert);
    function screw_len(t) = screw_length(screw, t + overshoot, star_washers ? 2 : 1, insert);
    screw_length = screw_len(thickness);
    screw_length2 = screw_len(thickness2);

    if(show_block)
        2screw_block_assembly(screw, name, short_insert) children();

    if(thickness)
        2screw_block_h_hole(screw, short_insert)
            translate_z(thickness)
                screw_and_washer(screw, screw_length, star_washers);

    if(thickness2)
        2screw_block_v_hole(screw, short_insert)
            translate_z(thickness2)
                screw_and_washer(screw, screw_length2, star_washers);
}
module 2screw_block_M20_stl() 2screw_block(M2_cap_screw);
module 2screw_block_M25_stl() 2screw_block(M2p5_cap_screw);
module 2screw_block_M30_stl() 2screw_block(M3_cap_screw);
module 2screw_block_M40_stl() 2screw_block(M4_cap_screw);

module 2screw_block_M20_s_stl() 2screw_block(M2_cap_screw, short_insert = true);
module 2screw_block_M25_s_stl() 2screw_block(M2p5_cap_screw, short_insert = true);
module 2screw_block_M30_s_stl() 2screw_block(M3_cap_screw, short_insert = true);
module 2screw_block_M40_s_stl() 2screw_block(M4_cap_screw, short_insert = true);
//
//! 1. Lay the blocks out and place an M2 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M20_assembly() 2screw_block_assembly(M2_cap_screw);

//
//! 1. Lay the blocks out and place an M2 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M20_s_assembly() 2screw_block_assembly(M2_cap_screw, short_insert = true);

//
//! 1. Lay the blocks out and place an M2.5 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M25_assembly() 2screw_block_assembly(M2p5_cap_screw);

//
//! 1. Lay the blocks out and place an M2.5 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M25_s_assembly() 2screw_block_assembly(M2p5_cap_screw, short_insert = true);

//
//! 1. Lay the blocks out and place an M3 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M30_assembly() 2screw_block_assembly(M3_cap_screw);

//
//! 1. Lay the blocks out and place an M3 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M30_s_assembly() 2screw_block_assembly(M3_cap_screw, short_insert = true);

//
//! 1. Lay the blocks out and place an M4 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M40_assembly() 2screw_block_assembly(M4_cap_screw);

//
//! 1. Lay the blocks out and place an M4 insert in the forward facing hole.
//! 1. Push them home with a soldering iron with a conical bit heated to 200&deg;C.
//! When removing the iron it helps to twist it a little anti-clockwise to release it from the thread.
//! 1. Lay the blocks on each of their other flat side and repeat.
//
module 2screw_block_M40_s_assembly() 2screw_block_assembly(M4_cap_screw, short_insert = true);
