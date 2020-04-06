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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/inserts.scad>

module inserts() {

    for(i = [0: len(inserts) -1])
        translate([10 * i, 0])
            insert(inserts[i]);

    stl_colour(pp1_colour)
        translate([len(inserts) * 10, 0]) {
            insert_lug(inserts[0], 2, 1);

            translate([10, 0])
                insert_boss(inserts[0], z = 10, wall = 2);
        }
}

if($preview)
    let($show_threads = true)
        inserts();
