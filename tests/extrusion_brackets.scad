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

include <../vitamins/extrusion_brackets.scad>
include <../vitamins/extrusions.scad>
include <../vitamins/washers.scad>
include <../vitamins/nuts.scad>

module extrusion_brackets() {
    extrusion_inner_corner_bracket(E20_inner_corner_bracket);

    translate([30, 0])
        extrusion_inner_corner_bracket(E20_inner_corner_bracket, grub_screws = false);

    translate([60, 0])
        extrusion_corner_bracket_assembly(E20_corner_bracket);

    eWidth = extrusion_width(E2020);

    translate([0, 60]) {
        extrusion_inner_corner_bracket(E20_inner_corner_bracket);
        translate([-eWidth / 2, 0, 0])
            rotate([-90, 0, 0])
                extrusion(E2020, 20, center = false);
        translate([-eWidth, -eWidth / 2, 0])
            rotate([0, 90, 0])
                extrusion(E2020, 40, center = false);
    }

    translate([60, 60]) {
        extrusion_corner_bracket_assembly(E20_corner_bracket);
        translate([-eWidth / 2, 0, 0])
            rotate([-90, 0, 0])
                extrusion(E2020, 30, center = false);
        translate([-eWidth, -eWidth / 2, 0])
            rotate([0, 90, 0])
                extrusion(E2020, 50, center = false);
    }
}

if($preview)
    let($show_threads = true)
        extrusion_brackets();
