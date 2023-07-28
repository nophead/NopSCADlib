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

use <../utils/layout.scad>
use <../vitamins/veroboard.scad>

z_cable_ways = 20;

z_vb = ["z_vb", "z_bed_terminal", 5, z_cable_ways / 2 + 12, inch(0.1), false, M3_dome_screw,
        [[2,2],[2,-3]], [], [4, 5, 7, 9],
        [
            [3,   z_cable_ways / 4 + 5.5, 0,  "term254", z_cable_ways / 2,     [1, 3]],
            [0.5, z_cable_ways / 4 + 5.5, 90, "transition", z_cable_ways / 2,  [1, 3]],
        ],
     ];

module veroboard_test() translate([vero_length(z_vb) / 2, vero_width(z_vb) / 2]) {
    vflip()
        veroboard_assembly(z_vb);

    translate([30, 0])
        rotate(180)
            veroboard_fastened_assembly(z_vb, 12, 3);
}

if($preview)
    veroboard_test();
