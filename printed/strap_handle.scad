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
//! Retracting strap handle. Print the strap with flexible filament. Shown with default dimensions but can
//! be fully customised by passing a list of properties.
//
include <../core.scad>
use <../vitamins/insert.scad>

strap = strap();

wall = 2;
clearance = 0.5;
step = 0.3;
overlap = 3;
panel_clearance = 0.25;
counterbore = 1;

function strap_width(type = strap)     = type[0]; //! Width of strap
function strap_thickness(type = strap) = type[1]; //! Thickness of strap
function strap_screw(type = strap)     = type[2]; //! Screw type
function strap_panel(type = strap)     = type[3]; //! Panel thickness
function strap_extension(type = strap) = type[4]; //! How much length of the strap that can pull out


function strap(width = 18, thickness = 2, screw = M3_pan_screw, panel_thickness = 3, extension = 25) = //! Construct a property list for a strap
 [ width, thickness, screw, panel_thickness, extension ];

function strap_insert(type) = screw_insert(strap_screw(type)); //! The insert type
function strap_key(type) = strap_panel(type) - panel_clearance;
function strap_height(type) = wall + max(insert_length(strap_insert(type)) - strap_key(type), strap_thickness(type) + clearance); //! Height of the ends
function strap_end_width(type = strap) = strap_width(type) + 2 * (wall + clearance); //! Width of the ends
function strap_boss_r(type) = wall + insert_hole_radius(strap_insert(type));

function strap_min_width(type) = (strap_width(type) - 2 * (strap_boss_r(type) + clearance)) / 2;

module strap_boss_shape(type)
    hull() {
        r = strap_boss_r(type);

        circle4n(r);

        translate([r / 2, 0])
            rounded_square([r, 2 * r], r = 1);
    }

module strap_screw_positions(length, type = strap) //! Place children at the screw positions
    for(end = [-1, 1])
        translate([end * (length / 2 - wall - 2 * clearance - strap_min_width(type) - strap_boss_r(type) - strap_extension(type) / 2), 0])
            rotate(end * 90 + 90)
                children();

module strap_holes(length, type = strap, h = 100) //! The panel cut outs
    extrude_if(h)
        strap_screw_positions(length, type)
            offset(cnc_bit_r + 0.05)
                offset(-step - cnc_bit_r)
                    strap_boss_shape(type);

module strap(length, type = strap) { //! Generate the STL for the rubber strap
    len = length - 2 * (wall + clearance);
    w = strap_width(type);

    stl("strap")
        linear_extrude(strap_thickness(type), convexity = 3)
            difference() {
                rounded_square([len, w], w / 2 - eps);

                for(end = [-1, 1])
                    translate([end * (len / 2 - strap_min_width(type) - strap_boss_r(type) - clearance), 0])
                        rotate(end * 90 + 90)
                            hull() {
                                offset(clearance)
                                    strap_boss_shape(type);

                                translate([strap_extension(type) / 2, 0])
                                    offset(clearance)
                                        strap_boss_shape(type);
                            }
            }
}

module strap_end(type = strap) { //! Generate the STL for end piece
    z1 = strap_height(type) - strap_thickness(type) - clearance;
    z2 = strap_height(type) + strap_key(type);
    r1 = strap_boss_r(type) - 1;

    module outer()
        hull() {
            translate([0, -strap_end_width(type) / 2])
                square([strap_boss_r(type) + overlap, strap_end_width(type)]);

            translate([-strap_extension(type) / 2, 0])
                circle(d = strap_end_width(type));
        }

    module with_hole()
        difference() {
            children();

            circle(r1);
        }

    stl("strap_end")
        union() {
            linear_extrude(z1)
                with_hole()
                    outer();

            translate_z(z1)
                linear_extrude(strap_height(type) - z1)
                    difference() {
                        outer();

                        hull() {
                            translate([0, -strap_width(type) / 2 - clearance])
                                square([strap_boss_r(type) + overlap, strap_width(type) + 2 * clearance]);

                            translate([-strap_extension(type) / 2, 0])
                                circle(d = strap_width(type) + 2 * clearance);
                        }
                    }

            linear_extrude(strap_height(type) - layer_height)
                with_hole()
                    strap_boss_shape(type);

            linear_extrude(z2)
                with_hole()
                     offset(cnc_bit_r)
                        offset(-step - cnc_bit_r)
                            strap_boss_shape(type);

            render() difference() {
                cylinder(r = r1 + eps, h = z2);

                translate_z(z2)
                    insert_hole(strap_insert(type), counterbore);
            }
        }
}
//
//! * Place the insert into the hole and push home with a soldering iron with a tapered bit heated to 200&deg;C.
//
module strap_end_assembly(type = strap)
assembly("strap_end", ngb = true) {
    stl_colour(pp1_colour)
        strap_end(type);

    translate_z(strap_height(type) + strap_key(type))
        insert(strap_insert(type));
}

module strap_assembly(length, type = strap) { //! Assembly with screws in place
    screw = strap_screw(type);
    penny = penny_washer(screw_washer(screw));

    screw_length = screw_length(screw, washer_thickness(penny) + panel_clearance + counterbore, 1, true);

    stl_colour(pp4_colour) strap(length, type);

    strap_screw_positions(length, type)
        translate_z(strap_height(type))
            vflip() {
                explode(-50) strap_end_assembly(type);

                translate_z(strap_height(type) + strap_panel(type))
                    screw_and_washer(screw, screw_length, true, true);
            }
}
