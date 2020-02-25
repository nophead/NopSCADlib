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
include <../core.scad>

use <../vitamins/extrusion_bracket.scad>
include <../vitamins/extrusions.scad>
include <../vitamins/washers.scad>
include <../vitamins/nuts.scad>

module extrusionBrackets() {
    extrusion20InnerCornerBracket();

    translate([30, 0])
        extrusion20InnerCornerBracket(grubScrews = false);

    translate([60, 0])
        extrusion20CornerBracket_assembly();

    eWidth = extrusion_width(E2020);

    translate([0, 60]) {
        extrusion20InnerCornerBracket();
        translate([-eWidth / 2, 0, 0])
            rotate([-90, 0, 0])
                extrusion(E2020, 20);
        translate([-eWidth, -eWidth / 2, 0])
            rotate([0, 90, 0])
                extrusion(E2020, 40);
    }

    translate([60, 60]) {
        extrusion20CornerBracket_assembly();
        translate([-eWidth / 2, 0, 0])
            rotate([-90, 0, 0])
                extrusion(E2020, 30);
        translate([-eWidth, -eWidth / 2, 0])
            rotate([0, 90, 0])
                extrusion(E2020, 50);
    }
}

if($preview)
    let($show_threads = true)
        extrusionBrackets();

