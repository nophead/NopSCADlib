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
include <../utils/core/core.scad>

include <../vitamins/extrusion_brackets.scad>
include <../vitamins/extrusions.scad>
include <../vitamins/washers.scad>
include <../vitamins/nuts.scad>

module extrusion_brackets(examples = false) {
    extrusion_inner_corner_bracket(E20_inner_corner_bracket);

    translate([30, 0])
        extrusion_inner_corner_bracket(E20_inner_corner_bracket, grub_screws = false);

    translate([60, 0])
        extrusion_corner_bracket_assembly(E20_corner_bracket);

    eWidth = extrusion_width(E2020);

    if(examples) {
        translate([20, 60, 10]) rotate([90, 0, 180]) {
            extrusion_inner_corner_bracket(E20_inner_corner_bracket);

            translate([-eWidth / 2, 0, 0])
                rotate([-90, 0, 0])
                    extrusion(E2020, 20, false);

            translate([-eWidth, -eWidth / 2, 0])
                rotate([0, 90, 0])
                    extrusion(E2020, 40, false);
        }

        translate([100, 60, 10]) rotate([90, 0, 180]) {
            extrusion_corner_bracket_assembly(E20_corner_bracket);

            translate([-eWidth / 2, 0, 0])
                rotate([-90, 0, 0])
                    extrusion(E2020, 30, false);

            translate([-eWidth, -eWidth / 2, 0])
                rotate([0, 90, 0])
                    extrusion(E2020, 50, false);
        }
    }
}

if($preview)
    extrusion_brackets(true);
