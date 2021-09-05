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
use <extrusion.scad>

function extrusion_inner_corner_bracket_size(type)           = type[1]; //! Size of inner bracket
function extrusion_inner_corner_bracket_tnut(type)           = type[2]; //! The sliding t-nut it is based on
function extrusion_inner_corner_bracket_extrusion(type)      = type[3]; //! Default extrusion this bracket is for
function extrusion_inner_corner_bracket_screw_offsets(type)  = type[4]; //! Screw offsets from the ends

module extrusion_inner_corner_bracket(type, grub_screws = true, backwards = false, extrusion = undef) { //! Inner corner bracket for extrusion
    extrusion = is_undef(extrusion) ? extrusion_inner_corner_bracket_extrusion(type) : extrusion;
    vitamin(str("extrusion_inner_corner_bracket(", type[0], "): Extrusion inner corner bracket for ", extrusion[0]));

    size = extrusion_inner_corner_bracket_size(type);
    tnut = extrusion_inner_corner_bracket_tnut(type);
    screw_offsets = extrusion_inner_corner_bracket_screw_offsets(type);
    bottomTabOffset = 4;
    topTabOffset = 10;
    sizeBottom = [size.y - bottomTabOffset, nut_square_width(tnut), size.z];
    sizeTop    = [size.x - topTabOffset,    nut_square_width(tnut), size.z];
    tab = t_nut_tab(tnut);
    tabSizeZ = nut_thickness(tnut);
    screw = find_screw(hs_grub, nut_size(tnut));
    holeRadius = screw_pilot_hole(screw);
    depth = (extrusion_width(extrusion) - extrusion_center_square(extrusion)) / 2;

    offset = extrusion_tab_thickness(extrusion) + tabSizeZ;
    offset2 = extrusion_tab_thickness(extrusion) - nut_thickness(tnut, true) + nut_thickness(tnut);
    translate([backwards ? offset2 : -offset,  -offset])
        rotate([-90, 0, 0]) {
            color("silver") {
                translate([(size.y + bottomTabOffset) / 2, 0, tabSizeZ])
                    rotate([0, 180, 0])
                        extrusionSlidingNut(sizeBottom, tab[0], tab[1], tabSizeZ, holeRadius, (bottomTabOffset - size.y) / 2 + screw_offsets.y);

                translate([tabSizeZ, 0, (size.x + topTabOffset) / 2])
                    rotate([0, -90, 0])
                        extrusionSlidingNut(sizeTop, tab[0], tab[0], tabSizeZ, holeRadius, -(topTabOffset - size.x) / 2 - screw_offsets.x);

                translate([0, -tab[1] / 2]) {
                    cube([bottomTabOffset, tab[1], size.z]);
                    cube([size.z, tab[1], topTabOffset]);
                }
            }
            if(grub_screws)
                not_on_bom() no_explode() {
                    screw_len = screw_shorter_than(depth);
                    gap = depth - screw_len;
                    screw_z = offset - gap;

                    rotate([0, -90, 180])
                        if(backwards)
                            translate([size.x - screw_offsets.x, 0, -offset2 + gap])
                                vflip()
                                    screw(screw, screw_len);
                        else
                            translate([size.x - screw_offsets.x, 0, screw_z])
                                screw(screw, screw_len);

                    translate([size.y - screw_offsets.y, 0, screw_z])
                        screw(screw, screw_len);
                }
        }
}

function extrusion_corner_bracket_size(type)             = type[1]; //! Size of bracket
function extrusion_corner_bracket_base_thickness(type)   = type[2]; //! Thickness of base of bracket
function extrusion_corner_bracket_side_thickness(type)   = type[3]; //! Thickness of side of bracket
function extrusion_corner_bracket_hole_offset(type)      = type[4]; //! Hole offset from corner
function extrusion_corner_bracket_tnut(type)             = type[5]; //! The sliding t-nut to use in the assembly
function extrusion_corner_bracket_extrusion(type)        = type[6]; //! Default extrusion this bracket is for

module extrusion_corner_bracket(type) { //! Corner bracket for extrusion
    vitamin(str("extrusion_corner_bracket(", type[0], "): Extrusion corner bracket ", type[1].z, "mm for ", extrusion_corner_bracket_extrusion(type)[0]));

    eSize = extrusion_corner_bracket_size(type).z;
    cbSize = extrusion_corner_bracket_size(type).x;
    baseThickness = extrusion_corner_bracket_base_thickness(type);
    hole_r = screw_clearance_radius(find_screw(hs_cap, nut_size(extrusion_corner_bracket_tnut(type))));

    module base() {
        linear_extrude(baseThickness)
            difference() {
                translate([0, -eSize / 2])
                    square([cbSize, eSize]);

                hull() {
                    translate([extrusion_corner_bracket_hole_offset(type) + 1.5, 0])
                        circle(hole_r);

                    translate([extrusion_corner_bracket_hole_offset(type) - 1.5, 0])
                        circle(hole_r);
                }
            }
    }

    color("silver") {
        rotate([90, 0, 90])
            base();

        translate([0, baseThickness])
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

module extrusion_corner_bracket_assembly(type, part_thickness = undef, screw_type = undef, nut_type = undef, max_screw_depth = undef, extrusion = undef) { //! Assembly with fasteners in place
    extrusion_corner_bracket(type);
    extrusion = is_undef(extrusion) ? extrusion_corner_bracket_extrusion(type) : extrusion;

    nut = is_undef(nut_type) ? extrusion_corner_bracket_tnut(type) : nut_type;
    screw = is_undef(screw_type) ? find_screw(hs_cap, nut_size(nut)) : screw_type;
    thickness = is_undef(part_thickness) ? extrusion_tab_thickness(extrusion) : part_thickness;
    depth = is_undef(max_screw_depth) ? (extrusion_width(extrusion) - extrusion_center_square(extrusion)) / 2 - eps : max_screw_depth;

    screw_washer_thickness = washer_thickness(screw_washer(screw));
    nut_washer_type = nut_washer(nut);
    nut_washer_thickness = nut_washer_type ? washer_thickness(nut_washer_type) : 0;

    nut_offset = extrusion_corner_bracket_base_thickness(type) + thickness;
    screw_length = depth ? screw_shorter_than(extrusion_corner_bracket_base_thickness(type) + screw_washer_thickness + depth)
                         : screw_longer_than(nut_offset + screw_washer_thickness + nut_washer_thickness + nut_thickness(nut));

    extrusion_corner_bracket_hole_positions(type) {
        screw_and_washer(screw, screw_length);
        translate_z(-nut_offset)
            vflip()
                if(nut_washer_type)
                    nut_and_washer(nut);
                else
                    rotate(90)
                        sliding_t_nut(nut);
    }
}
