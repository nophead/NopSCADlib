//
// NopSCADlib Copyright Chris Palmer 2020
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

//! Brackets for joining extrusions at a corner.

include <../core.scad>

function extrusion_inner_corner_bracket_size(type)             = type[1]; //! Size of inner bracket

module extrusion_inner_corner_bracket(type, grub_screws = true) { //! Inner corner bracket for extrusion
    vitamin(str("extrusion_inner_corner_bracket(", type[0], ", ", grub_screws, "): Extrusion inner corner bracket ", type[1].z));

    size = extrusion_inner_corner_bracket_size(type);
    armLength = size.x;
    bottomTabOffset = 4;
    topTabOffset = 10;
    sizeBottom = [armLength - bottomTabOffset, 6, size.z];
    sizeTop = [armLength - topTabOffset, 6, size.z];
    tabSizeY1 = 10;
    tabSizeY2 = 6;
    tabSizeZ = 3.25;
    holeRadius = M4_tap_radius;

    translate([-size.z - 0.75, -size.z - 0.75, 0])
        rotate([-90, 0, 0]) {
            color("silver") {
                translate([(armLength + bottomTabOffset) / 2, 0, tabSizeZ])
                    rotate([0, 180, 0])
                        extrusionSlidingNut(sizeBottom, tabSizeY1, tabSizeY2, tabSizeZ, holeRadius, (bottomTabOffset - armLength) / 2 + 5);
                translate([tabSizeZ, 0, (armLength + topTabOffset) / 2])
                    rotate([0, -90, 0])
                        extrusionSlidingNut(sizeTop, tabSizeY1, tabSizeY2, tabSizeZ, holeRadius,-(topTabOffset - armLength) / 2 - 5);
                translate([0, -size.z / 2, 0]) {
                    cube([bottomTabOffset, size.z, size.z]);
                    cube([size.z, size.z, topTabOffset]);
                }
            }
            if(grub_screws)
                not_on_bom() no_explode() {
                    grubScrewLength = 6;
                    for(angle = [[0, 0, 0], [0, -90, 180]])
                        rotate(angle)
                            translate([armLength - 5, 0, size.z])
                                screw(M3_grub_screw, grubScrewLength);
                }
        }
}

function extrusion_corner_bracket_size(type)             = type[1]; //! Size of bracket
function extrusion_corner_bracket_base_thickness(type)   = type[2]; //! Thickness of base of bracket
function extrusion_corner_bracket_side_thickness(type)   = type[3]; //! Thickness of side of bracket
function extrusion_corner_bracket_hole_offset(type)      = type[4]; //! Hole offset from corner

module extrusion_corner_bracket(type) { //! Corner bracket for extrusion
    vitamin(str("extrusion_corner_bracket(", type[0], "): Extrusion corner bracket ", type[1].z));

    eSize = extrusion_corner_bracket_size(type).z;
    cbSize = extrusion_corner_bracket_size(type).x;
    baseThickness = extrusion_corner_bracket_base_thickness(type);

    module base() {
        linear_extrude(baseThickness)
            difference() {
                translate([0, -eSize / 2, 0])
                    square([cbSize, eSize]);
                hull() {
                    translate([extrusion_corner_bracket_hole_offset(type) + 1.5, 0, 0])
                        circle(r = M5_clearance_radius);
                    translate([extrusion_corner_bracket_hole_offset(type) - 1.5, 0, 0])
                        circle(r = M5_clearance_radius);
                }
            }
    }

    color("silver") {
        rotate([90, 0, 90])
            base();
        translate([0, baseThickness, 0])
            rotate([90, 0, 0])
                base();
        sideThickness = extrusion_corner_bracket_side_thickness(type);
        for(z = [-eSize / 2, eSize / 2 - sideThickness]) {
            translate_z(z) {
                right_triangle(cbSize, cbSize, sideThickness, center = false);
                cube([5, cbSize, sideThickness]);
                cube([cbSize, 5, sideThickness]);
            }
        }
    }
}

module extrusion_corner_bracket_hole_positions(type) { //! Place children at hole positions
    for(angle = [ [0, 90, 0], [-90, -90, 0] ])
        rotate(angle)
            translate([0, extrusion_corner_bracket_hole_offset(type), extrusion_corner_bracket_base_thickness(type)])
                children();
}

module extrusion_corner_bracket_assembly(type, part_thickness = 2, screw_type = M4_cap_screw, nut_type = M4_sliding_t_nut, max_screw_depth = 6) { //! Assembly with fasteners in place
    extrusion_corner_bracket(type);

    screw_washer_thickness = washer_thickness(screw_washer(screw_type));
    nut_washer_type = nut_washer(nut_type);
    nut_washer_thickness = nut_washer_type ? washer_thickness(nut_washer_type) : 0;

    nut_offset = extrusion_corner_bracket_base_thickness(type) + part_thickness;
    screw_length = max_screw_depth ? screw_shorter_than(extrusion_corner_bracket_base_thickness(type) + screw_washer_thickness + max_screw_depth)
                                   : screw_longer_than(nut_offset + screw_washer_thickness + nut_washer_thickness + nut_thickness(nut_type));

    extrusion_corner_bracket_hole_positions(type) {
        screw_and_washer(screw_type, screw_length);
        translate_z(-nut_offset)
            vflip()
                if(nut_washer_type)
                    nut_and_washer(nut_type);
                else
                    rotate(90)
                        sliding_t_nut(nut_type);
    }
}
