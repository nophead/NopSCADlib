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
l = 250; // [1: 1000]
x = 200; // [1: 1000]
y = 50; //[-500 : 500]

include <../utils/core/core.scad>
use <../utils/catenary.scad>
use <../utils/sweep.scad>
use <../utils/annotation.scad>

module catenaries() {
    //
    // catenary curve path from control points
    //
    curve = [for(p = catenary_points(l, x, y)) [p.x, p.y, 0]];
    //
    // Draw the curve
    //
    r = 0.5;
    sweep(curve, circle_points(r, $fn = 64));
    //
    // Minimum Z
    //
    min_z = catenary_points(l, x, y, 0);

    color("blue") {
        translate([min_z.x, min_z.y + r])
            rotate([-90, 0, 0])
                arrow();

        translate([min_z.x, min_z.y - r])
            rotate([90, 0, 0])
                arrow();
    }
}

if($preview)
    rotate(is_undef($bom) ? 0 : [70, 0, 315])
        catenaries();
