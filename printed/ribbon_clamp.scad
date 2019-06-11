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
//! Clamp for ribbon cable and polypropylene strip.
//
include <../core.scad>
include <../vitamins/screws.scad>
include <../vitamins/inserts.scad>
use <../vitamins/cable_strip.scad>

wall = 2;
min_wall = 2 * extrusion_width;
screw = M3_cap_screw;
insert = screw_insert(screw);
screw_depth = insert_length(insert) + 1;

function ribbon_clamp_hole_pitch(ways) = ribbon_clamp_slot(ways) + 2 * min_wall + 2 * corrected_radius(insert_hole_radius(insert)); //! Hole pitch
function ribbon_clamp_width() = 2 * (insert_hole_radius(insert) + 2); //! Width
function ribbon_clamp_length(ways) = ribbon_clamp_hole_pitch(ways) + ribbon_clamp_width(); //! Length given ways
function ribbon_clamp_height() = screw_depth + 1; //! Height

module ribbon_clamp_hole_positions(ways, side = undef) //! Place children at hole positions
    for(x = is_undef(side) ? [-1, 1] : side)
        translate([x * ribbon_clamp_hole_pitch(ways) / 2, 0])
            children();

module ribbon_clamp_holes(ways, h = 20) //! Drill screw holes
    ribbon_clamp_hole_positions(ways)
        drill(screw_clearance_radius(screw), h);

module ribbon_clamp(ways) { //! Generate STL for given number of ways
    stl(str("ribbon_clamp_", ways));

    pitch = ribbon_clamp_hole_pitch(ways);
    d = ribbon_clamp_width();
    h = ribbon_clamp_height();
    t = h - ribbon_clamp_slot_depth() - wall;

    difference() {
        union() {
            hull() {
                translate_z(h - t / 2)
                    cube([ribbon_clamp_hole_pitch(ways), d, t], center = true);

                translate_z(1)
                    cube([pitch, max(wall, d - 2 * (h - t)), 2], center = true);
            }
            ribbon_clamp_hole_positions(ways, -1)
                cylinder(d = d, h = h);

            ribbon_clamp_hole_positions(ways,  1)
                cylinder(d = d, h = h);

        }

        translate_z(h)
            cube([ribbon_clamp_slot(ways), d + 1, ribbon_clamp_slot_depth() * 2], center = true);

        ribbon_clamp_hole_positions(ways)
            translate_z(h)
                rotate(22.5)
                    insert_hole(insert, screw_depth - insert_length(insert));
    }
}

module ribbon_clamp_assembly(ways) pose([55, 180, 25])  //! Printed part with inserts in place
    assembly(str("ribbon_clamp_", ways)) {
    h = ribbon_clamp_height();

    color(pp1_colour) render()
        translate_z(h) vflip() ribbon_clamp(ways);

    ribbon_clamp_hole_positions(ways)
        vflip()
            insert(insert);
}

module ribbon_clamp_fastened_assembly(ways, thickness, screw = screw) { //! Clamp with fasteners in place
    tape_l = floor(ribbon_clamp_slot(ways));
    tape_width = 25;
    tape_thickness = 0.5;

    vitamin(str(": Tape self amalgamating silicone ",tape_l," x 25mm"));

    washer = screw_washer(screw);
    screw_length = screw_shorter_than(2 * washer_thickness(washer) + thickness + screw_depth);

    ribbon_clamp_assembly(ways);

    color("red") translate_z(tape_thickness / 2)
        cube([tape_l, tape_width, tape_thickness], center = true);

    ribbon_clamp_hole_positions(ways)
        vflip()
           translate_z(thickness)
                screw_and_washer(screw, screw_length, true);
}

module ribbon_clamp_20_stl() ribbon_clamp(20);

//! * Place inserts into the holes and press home with a soldering iron with a conical bit heated to 200&deg;C.
module ribbon_clamp_20_assembly() ribbon_clamp_assembly(20);
