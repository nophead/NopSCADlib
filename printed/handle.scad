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
//! Printed handle that can be printed without needing support material due to its truncated teardrop profile.
//
include <../core.scad>
include <../vitamins/screws.scad>
include <../vitamins/inserts.scad>

dia = 18;
length = 90; // inside length
height = 30; // inside height
screw = M4_cap_screw;
insert = screw_insert(screw);

pitch = length + dia;

function handle_length() = pitch + dia;     //! Outside length
function handle_width() = dia;              //! The width, i.e. diameter
function handle_height() = height + dia;    //! Total height
function handle_screw() = screw;            //! The screw type

module handle_screw_positions() //! Position children at the screw positions
    for(end = [-1, 1])
        translate([end * pitch / 2, 0])
            children();

module handle_holes(h = 100) //! Drills holes for the screws
    handle_screw_positions()
        drill(screw_clearance_radius(screw), h);

module handle_stl() { //! generate the STL
    stl("handle");

    module end(end)
        translate([end * pitch / 2, 0])
            rotate_extrude()
                intersection() {
                    rotate(180)
                        teardrop(r = dia / 2, h = 0);

                    translate([0, - (dia + 1) / 2])
                        square([dia / 2 + 1, dia + 1]);
                }

    translate_z(dia / 2)
        union() {
            hull() {
                end(-1);

                end(1);
            }

            handle_screw_positions()
                render() difference() {
                    h =  height + dia / 2;
                    cylinder(d = dia, h = h);

                    translate_z(h)
                        insert_hole(insert, 6);
                }
        }
}
//
//! Place inserts in the bottom of the posts and push them home with a soldering iron with a conical bit heated to 200&deg;C.
//
module handle_assembly() pose([225, 0, 150], [0, 0, 14]) //! Printed part with inserts in place
assembly("handle") {
    translate_z(handle_height())
        color(pp1_colour) vflip() handle_stl();

    handle_screw_positions()
        vflip()
            insert(insert);
}

module handle_fastened_assembly(thickness) { //! Assembly with fasteners in place
    screw_length = screw_longer_than(thickness + insert_length(insert) + 2 * washer_thickness(screw_washer(screw)));

    handle_assembly();

    handle_screw_positions()
        vflip()
            translate_z(thickness)
                screw_and_washer(screw, screw_length, true);
}
