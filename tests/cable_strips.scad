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

use <../vitamins/cable_strip.scad>

module cable_strips() {
    depth = 50;
    rotate(-90)
        for(pos = [-100, 0, 100]) {
            bezier_cable_strip(ways = 20, depth = depth, length = 150, below = 100, extra = 10, pos = pos);

            translate([0, depth * 2])
                rotate([0, -90, 0])
                    cable_strip(ways =20, depth = depth / 2, travel = 100, extra = 30, pos = pos);


        }
}

if($preview)
    cable_strips();
