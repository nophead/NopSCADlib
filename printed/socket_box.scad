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
//! UK 13A socket and printed backbox with earth terminal for the panel it is mounted on.
//
include <../core.scad>
include <../vitamins/mains_sockets.scad>
include <../vitamins/ring_terminals.scad>
use <../vitamins/insert.scad>

box_height = 19;
base_thickness = 2;
wall = 3.5;

cable_d = 7;
cable_z = cable_d / 2 + base_thickness + 1;
function cable_y(type) = -mains_socket_depth(type) / 2;
cable_x = 0;

earth = M3_ringterm;
earth_screw = ringterm_screw(earth);

height = base_thickness + box_height;
function socket_box_depth() = height; //! Outside depth of the backbox

module socket_box(type) { //! Generate STL of the backbox for the specified socket

    screw = mains_socket_screw(type);
    screw_clearance_radius = screw_clearance_radius(screw);

    insert = screw_insert(screw);
    insert_length = insert_length(insert);
    insert_boss = mains_socket_insert_boss(type);
    insert_hole_radius = insert_hole_radius(insert);

    stl(str("socket_box_",type[0]))
        difference() {
            linear_extrude(height, convexity = 5)
                face_plate(type);

            difference() {
                translate_z(base_thickness)
                    linear_extrude(height, convexity = 5)
                         offset(-wall) offset(1) face_plate(type);

                for(side = [-1, 1])
                    hull()
                        for(x = [1, 2])
                            translate([side * mains_socket_pitch(type) / x, 0])
                                cylinder(d = insert_boss, h = 100);
            }
            //
            // Socket holes
            //
            translate_z(height)
                mains_socket_hole_positions(type) {
                    poly_cylinder(r = screw_clearance_radius, h = 2 * box_height, center = true);

                    poly_cylinder(r = insert_hole_radius, h = 2 * insert_length, center = true);
                }
            //
            // Cable hole
            //
            translate([cable_x, cable_y(type), cable_z])
                rotate([90, 0, 0])
                    teardrop_plus(r = cable_d / 2, h = 30);
        }
}

module socket_box_MKLOGIC_stl() socket_box(MKLOGIC);
module socket_box_Contactum_stl() socket_box(Contactum);

module socket_box_assembly(type)  //! The box with inserts fitted
assembly(str("socket_box_", type[0])) {
    screw = mains_socket_screw(type);
    insert = screw_insert(screw);

    stl_colour(pp1_colour) render() socket_box(type);

    mains_socket_hole_positions(type)
        translate_z(height)
            insert(insert);

}

//! * Place two inserts into the holes in the lugs and press them home with a soldering iron with a tapered bit heated to 200&deg;C.
module socket_box_MKLOGIC_assembly() socket_box_assembly(MKLOGIC);

module socket_box_fastened_assembly(type, thickness) { //! The socket and backbox on each side of the specified panel thickness
    screw = mains_socket_screw(type);
    screw_length = screw_length(screw, mains_socket_height(type) + thickness, 0, true, longer = true);

    explode(-50)
        translate_z(-height - thickness)
            socket_box_assembly(type);

    explode(50, true) {
        mains_socket(type);

        mains_socket_hole_positions(type)
            translate_z(mains_socket_height(type))
                screw(screw, screw_length);
    }

    mains_socket_earth_position(type)
        rotate(-90)
            ring_terminal_assembly(earth, thickness);
}
