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
//! UK 13A sockets at the moment.
//
include <../core.scad>
include <ring_terminals.scad>
use <insert.scad>

function mains_socket_width(type)  = type[1]; //! Width at the base
function mains_socket_depth(type)  = type[2]; //! Depth at the base
function mains_socket_top_w(type)  = type[3]; //! Width at the top, might be tapered
function mains_socket_top_d(type)  = type[4]; //! Depth at the top, might be tapered
function mains_socket_corner(type) = type[5]; //! Corner radius
function mains_socket_height(type) = type[6]; //! Height
function mains_socket_t(type)      = type[7]; //! Plastic thickness
function mains_socket_offset(type) = type[8]; //! Offset of the socket from the centre
function mains_socket_pitch(type)  = type[9]; //! Screw hole pitch
function mains_socket_screw(type)  = M3_cs_cap_screw;  //! Screw type

earth = M3_ringterm;
earth_screw = ringterm_screw(earth);
insert_wall = 3;

function mains_socket_insert_boss(type) = 2 * (insert_hole_radius(screw_insert(mains_socket_screw(type))) + insert_wall);

module face_plate(type)
    rounded_square([mains_socket_width(type), mains_socket_depth(type)], mains_socket_corner(type));

module mains_socket_hole_positions(type) //! Position children at the screw holes
    for(side = [-1, 1])
        translate([side *  mains_socket_pitch(type) / 2, 0])
            children();

module mains_socket_earth_position(type) {  //! Position of earth terminal for DiBond panel
    inset = mains_socket_t(type) + washer_diameter(screw_washer(earth_screw)) / 2 + 1;

    translate([-mains_socket_width(type) / 2 + inset, -mains_socket_depth(type) / 2 + inset])
        children();
}

module mains_socket_holes(type, h = 0) { //! Panel cutout
    mains_socket_hole_positions(type)
        drill(screw_clearance_radius(mains_socket_screw(type)), h);

    extrude_if(h)
        offset(cnc_bit_r) offset(-cnc_bit_r) difference() {
            offset(-7) face_plate(type);

            for(side = [-1, 1])
                hull()
                    for(x = [1, 2])
                        translate([side * mains_socket_pitch(type) / x, 0])
                            circle(4.5);

            mains_socket_earth_position(type)
                circle(d = washer_diameter(screw_washer(earth_screw)) + 2);
        }

    mains_socket_earth_position(type)
        drill(screw_clearance_radius(earth_screw), h);
}

module mains_socket(type) { //! Draw specified 13A socket
    offset = mains_socket_offset(type);
    screw = mains_socket_screw(type);
    height =  mains_socket_height(type);

    vitamin(str("mains_socket(", type[0], "): Mains socket 13A", offset.x || offset.y ? ", switched" : ""));

    color("white") render() difference() {
        hull() {
            linear_extrude(eps)
                face_plate(type);

            linear_extrude(height)
                offset(-(mains_socket_width(type) - mains_socket_top_w(type)) / 2)
                    face_plate(type);
        }
        // Holes for pins
        translate([offset.x, offset.y, mains_socket_height(type)]) {
            for(side = [-1, 1])
                translate([side * 11.1, -11.1])
                    cube([7, 4.5, 8], center = true);

            translate([0, 11.1])
                cube([4.5, 8.5, 8], center = true);
        }
        // Hollow out the back
        difference() {
            linear_extrude(height - mains_socket_t(type))
                offset(-mains_socket_t(type))
                    face_plate(type);

            cube(50, center = true);
        }
        // Screw holes
        mains_socket_hole_positions(type) {
            cylinder(r = screw_clearance_radius(screw), h = 100, center = true);

            translate_z(height)
                screw_countersink(screw, drilled = false);
        }
    }
}
