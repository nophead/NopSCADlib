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
include <../core.scad>

include <../vitamins/extrusions.scad>
include <../vitamins/extrusion_brackets.scad>
include <../vitamins/washers.scad>
include <../vitamins/nuts.scad>

module inner_bracket_test(bracket, backwards = false)
    rotate([90, 0, 180]) {
        extrusion = extrusion_inner_corner_bracket_extrusion(bracket);
        eWidth = extrusion_width(extrusion);
        size = extrusion_inner_corner_bracket_size(bracket);
        tnut = extrusion_inner_corner_bracket_tnut(bracket);

        translate([backwards ? -eWidth : 0, 0])
            extrusion_inner_corner_bracket(bracket, backwards = backwards);

        translate([-eWidth / 2, 0])
            rotate([-90, 0, 0])
                extrusion(extrusion, size.x - nut_thickness(tnut) - extrusion_tab_thickness(extrusion), false, cornerHole = eWidth > 20);

        translate([-eWidth, -eWidth / 2])
            rotate([0, 90, 0])
                extrusion(extrusion, eWidth + size.y - nut_thickness(tnut) - extrusion_tab_thickness(extrusion), false, cornerHole = eWidth > 20);
    }


module bracket_test(bracket)
    rotate([90, 0, 180]) {
        extrusion = extrusion_corner_bracket_extrusion(bracket);
        eWidth = extrusion_width(extrusion);
        size = extrusion_corner_bracket_size(bracket);

        extrusion_corner_bracket_assembly(bracket);

        translate([-eWidth / 2, 0])
            rotate([-90, 0, 0])
                extrusion(extrusion, size.y, false, cornerHole = eWidth > 20);

        translate([-eWidth, -eWidth / 2])
            rotate([0, 90, 0])
                extrusion(extrusion, eWidth + size.x, false, cornerHole = eWidth > 20);
    }


module extrusion_brackets(examples = false) {
    extrusion_inner_corner_bracket(E20_inner_corner_bracket);

    translate([30, 0])
        extrusion_inner_corner_bracket(E20_inner_corner_bracket, grub_screws = false);

    translate([60, 0])
        extrusion_corner_bracket_assembly(E20_corner_bracket);

    translate([110, 0])
         extrusion_inner_corner_bracket(E40_inner_corner_bracket);

    translate([140, 0])
        extrusion_corner_bracket_assembly(E40_corner_bracket);

    if(examples) {
        translate([20, 50, 10])
            inner_bracket_test(E20_inner_corner_bracket, true);

        translate([20, 80, 10])
            inner_bracket_test(E20_inner_corner_bracket);

        translate([20, 120, 10])
            bracket_test(E20_corner_bracket);

        translate([100, 70, 10])
            inner_bracket_test(E40_inner_corner_bracket);

        translate([100, 130, 10])
            bracket_test(E40_corner_bracket);
    }
}

if($preview)
    let($show_threads = true)
        extrusion_brackets(true);
