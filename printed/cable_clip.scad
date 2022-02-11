//
// NopSCADlib Copyright Chris Palmer 2022
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
//! Cable clips to order. Can be for one or two cables of different sizes.
//
include <../core.scad>
use <../vitamins/wire.scad>
use <../utils/fillet.scad>

wall = 2;

function cable_clip_width(screw) = max(wall + 2 * screw_clearance_radius(screw) + wall, washer_diameter(screw_washer(screw))); //! Width given the `screw`.
function cable_clip_height(cable) = cable_height(cable) + wall; //! Height given the `cable`.
function cable_clip_extent(screw, cable) = screw_clearance_radius(screw) + wall + cable_width(cable) + wall; //! How far it extends from the screw.
function cable_clip_offset(screw, cable) = screw_clearance_radius(screw) + wall + cable_width(cable) / 2; //! The offset of the cable from the screw

module single_cable_clip(screw, cable, h = 0) {
    screw_dia = 2 * screw_clearance_radius(screw);
    height = cable_clip_width(screw);
    depth = h ? h : cable_height(cable) + wall;
    w = cable_width(cable);
    width = wall + w + wall + screw_dia + wall;
    hole_x = wall + w + wall + screw_dia / 2;
    rad = min(wall + cable_wire_size(cable) / 2, depth / 2);
    r = extrusion_width - eps;
    translate([-hole_x, 0]) difference() {
        linear_extrude(height)
            difference() {
                hull() {
                    rounded_square([width, 1], r, center = false);

                    translate([width - 1, 0])
                        rounded_square([1, depth], r, center = false);

                    translate([rad, depth - rad])
                        circle(r = rad);
                }

                translate([wall + cable_width(cable) / 2, 0]) {
                    hull() {
                        for(p = cable_bundle_positions(cable))
                            translate(p)
                                circle(d = cable_wire_size(cable));

                        square([w, eps], center = true);
                    }
                    for(side = [-1, 1])
                        translate([side * w / 2, 0])
                            hflip(side < 0)
                                fillet(r = r, h = 0);
                }
            }

        translate([hole_x, depth / 2, height / 2])
            rotate([90,0,0])
                teardrop_plus(h = depth + 1, r = screw_dia / 2, center = true);
    }
}


module double_cable_clip(screw, cable1, cable2) {
    h = max(cable_clip_height(cable1), cable_clip_height(cable2));
    union() {
        single_cable_clip(screw, cable1, h);

        mirror([1,0,0]) single_cable_clip(screw, cable2, h);
    }
}

module cable_clip(screw, cable1, cable2 = 0) { //! Create the STL for a single cable or two cable clip
    function clip_str(screw) = str("cable_clip_", screw_radius(screw) * 20);
    function cable_str(cable) = str("_", cable_wires(cable), "_", round(cable_wire_size(cable) * 10));

    if(cable2) {
        stl(str(clip_str(screw), cable_str(cable1), cable_str(cable2)));

        double_cable_clip(screw, cable1, cable2);
    }
    else {
        stl(str(clip_str(screw), cable_str(cable1)));

        single_cable_clip(screw, cable1);
    }
}


module cable_clip_assembly(screw, thickness, cable1, cable2 = 0) { //! Cable clip with the fasteners
    height = max(cable_clip_height(cable1), cable2 ? cable_clip_height(cable2) : 0);

    stl_colour(pp1_colour) render()
        translate([0, cable_clip_width(screw) / 2]) rotate([90, 0, 0])
            cable_clip(screw, cable1, cable2);

    translate_z(height)
        screw_and_washer(screw, screw_length(screw, height + thickness, 2, nyloc = true));

    translate_z(-thickness)
        vflip()
            nut_and_washer(screw_nut(screw), true);
}
