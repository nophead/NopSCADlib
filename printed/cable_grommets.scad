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
//! Printed cable grommets for passing cables through panels avoiding sharp edges and in the case
//! of conductive panels, an extra layer of insulation.
//
include <../utils/core/core.scad>
use <../vitamins/cable_strip.scad>

base = 1.25;
slot_height = round_to_layer(1.27) + layer_height;
wall = 1.6;
overlap = 1.5;
height = base + slot_height + wall + overlap;
rad = wall + overlap;
clearance = 0.1;

module ribbon_grommet_hole(ways, h = 50, expand = true) { //! Generate a hole for a ribbon grommet
    length = ribbon_clamp_slot(ways) + 2 * wall;
    rad = cnc_bit_r;
    height = base + slot_height + wall;
    extrude_if(h)
        offset(expand ? clearance : 0)
            hull() {
                translate([-length / 2, 0])
                    square([length, base]);

                for(end = [-1, 1])
                    translate([end * (length / 2 - rad), height - rad])
                        drill(rad, 0);
            }
}

module ribbon_grommet(ways, thickness) { //! Generate the STL for a printed ribbon grommet

    width = 2 * (wall + clearance) + thickness;
    slot_length = ribbon_clamp_slot(ways);
    length = slot_length + 2 * wall + 2 * overlap;

    stl(str("ribbon_grommet_", ways, "_", thickness))
        rotate([90, 0, 0])
            union() {
                for(side = [-1, 1])
                    translate_z(side * (width - wall) / 2)
                        linear_extrude(wall, center = true, convexity = 5)
                            difference() {
                                hull() {
                                    translate([-length / 2, 0])
                                        square([length, base]);

                                    for(end = [-1, 1])
                                        translate([end * (length / 2 - rad), height - rad])
                                            semi_circle(rad);
                                }
                                translate([-slot_length / 2, base])
                                    square([slot_length, slot_height]);
                            }

                linear_extrude(width -1, center = true)
                    difference() {
                        ribbon_grommet_hole(ways, expand = false, h = 0);

                        translate([-slot_length / 2, base])
                            square([slot_length, slot_height]);
                    }
            }
}

module round_grommet_top(diameter, thickness, od = undef) { //! Generate the STL for a round grommet top half
    chamfer = layer_height;
    h = wall + thickness + wall;
    r1 = diameter / 2;
    r2 = od == undef ? corrected_radius(r1) + wall : od / 2;
    r3 = r2 + overlap;
    r0 = r1 + 1;
    stl(str("round_grommet_top_", round(diameter * 10), "_", thickness))
        union() {
            rotate_extrude()
                polygon([
                    [r0, 0],
                    [r3 - chamfer, 0],
                    [r3, chamfer],
                    [r3, wall],
                    [r2, wall],
                    [r2, h - chamfer],
                    [r2 - chamfer, h],
                    [r0, h],
                ]);

            render() difference() {
                cylinder(r = r0 + eps, h = h);

                poly_cylinder(r = r1, h = 100, center = true);
            }
        }
}

module round_grommet_bottom(diameter, od = undef) { //! Generate the STL for a round grommet bottom half
    chamfer = layer_height;
    r1 = diameter / 2;
    r2 = od == undef ? corrected_radius(r1) + wall : od / 2;
    r3 = r2 + max(overlap, wall + chamfer);
    stl(str("round_grommet_bottom_", round(diameter * 10)))
        rotate_extrude()
            polygon([
                [r2, chamfer],
                [r2 + chamfer, 0],
                [r3, 0],
                [r3, wall - chamfer],
                [r3 - chamfer, wall],
                [r2, wall],
            ]);
}

module round_grommet_hole(diameter, h = 100) //! Make a hole for a round grommet
    drill(corrected_radius(diameter / 2) + wall + clearance, h);

module round_grommet_assembly(diameter, thickness, od = undef) {
    stl_colour(pp1_colour)
        translate_z(wall)
            vflip()
                round_grommet_top(diameter, thickness, od);

    stl_colour(pp2_colour)
        translate_z(-thickness)
            vflip()
                round_grommet_bottom(diameter, od);
}

module mouse_grommet_hole(r, h = 50, z = undef, expand = wall + clearance) //! Make a hole for a mouse grommet
    extrude_if(h)
        hull(){
            R = r + expand;
            translate([0, z == undef ? R : z])
                if(expand)
                    semi_circle(R);
                else
                    semi_teardrop(r = R, h = 0);

            translate([-R, 0])
                square([2 * R, eps]);
        }

function mouse_grommet_offset(r) = r + wall; //! Offset of the wire from the ground
function mouse_grommet_length(r) = 2 * r + 2 * wall + 2 * overlap; //! Length of grommet given r

module mouse_grommet(r, thickness) { //! Make the STL for a mouse grommet

    width = 2 * (wall + clearance) + thickness;

    stl(str("mouse_grommet_", r * 20, "_", thickness))
        rotate([90, 0, 0])
            union() {
                for(side = [-1, 1])
                    translate_z(side * (width - wall) / 2)
                        linear_extrude(wall, center = true)
                            difference() {
                                mouse_grommet_hole(r, z = r + wall, h = 0, expand = wall + overlap);

                            translate([0, wall])
                                mouse_grommet_hole(r, h = 0, expand = 0);
                        }
                linear_extrude(width - 1, center = true)
                    difference() {
                        mouse_grommet_hole(r, h = 0, z = r + wall, expand = wall);

                        translate([0, wall])
                            mouse_grommet_hole(r, h = 0, expand = 0);
                    }
            }
}

module mouse_grommet_assembly(r, thickness)
    stl_colour(pp1_colour)
        rotate([-90, 0, 0])
            mouse_grommet(r, thickness);

module ribbon_grommet_20_3_stl() ribbon_grommet(20, 3);
module mouse_grommet_30_3_stl() mouse_grommet(1.5, 3);
module mouse_grommet_40_3_stl() mouse_grommet(2, 3);
module mouse_grommet_50_3_stl() mouse_grommet(2.5, 3);
module mouse_grommet_60_3_stl() mouse_grommet(3, 3);

module round_grommet_bottom_30_stl() round_grommet_bottom(3);
module round_grommet_bottom_40_stl() round_grommet_bottom(4);
module round_grommet_bottom_50_stl() round_grommet_bottom(5);
module round_grommet_bottom_60_stl() round_grommet_bottom(6);

module round_grommet_top_30_3_stl() round_grommet_top(3, 3);
module round_grommet_top_40_3_stl() round_grommet_top(4, 3);
module round_grommet_top_50_3_stl() round_grommet_top(5, 3);
module round_grommet_top_60_3_stl() round_grommet_top(6, 3);
