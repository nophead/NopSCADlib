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
//! Door latch for 6mm acrylic door for 3D printer. See [door_hinge](#door_hinge).
//
include <../core.scad>
use <../utils/hanging_hole.scad>

length = 35;
width = 12;
height = 14.25;

thickness = 5;
rad = 3;

screw = M4_hex_screw;

function door_latch_screw() = screw; //! The screw used for the axle
function door_latch_offset() = width / 2 + 1; //! Offset of the axle from the door edge

nut_trap_depth = round_to_layer(screw_head_height(screw)) + 4 * layer_height;

module door_latch_stl() { //! Generates the STL for the printed part
    ridge = 4;

    stl("door_latch")
        difference() {
            union() {
                hull() {
                    rounded_rectangle([length, width, thickness - tan(30) * (width -  ridge) / 2], rad);

                    translate_z(thickness / 2)
                        cube([length, ridge, thickness], center = true);
                }

                cylinder(d = width, h = height);
            }
            hanging_hole(nut_trap_depth, screw_clearance_radius(screw))
                circle(r = nut_trap_radius(screw_nut(screw)), $fn = 6);
        }
}

module door_latch_assembly(sheet_thickness = 3) { //! The assembly for a specified sheet thickess
    washer = screw_washer(screw);
    nut = screw_nut(screw);

    screw_length = screw_length(screw, height - nut_trap_depth + sheet_thickness, 2, nyloc = true);

    translate([0, -height - washer_thickness(washer)])
        rotate([-90, 0, 0]) {
            stl_colour(pp1_colour) render() door_latch_stl();

            translate_z(nut_trap_depth)
                vflip()
                    screw(screw, screw_length);

            translate_z(height)
                washer(washer);

            translate_z(height + sheet_thickness + washer_thickness(washer))
                nut_and_washer(nut, true);
        }
}
