//
// NopSCADlib Copyright Chris Palmer 2024
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

use <../utils/splines.scad>
use <../utils/sweep.scad>

points = [[0, 1.5], [2, 2], [3, 1], [4, -2], [5, 1], [6, 2], [7, 3]];

module splines() {
    cm_spline = catmull_rom_spline(points, 100 / len(points), 0.5);
    color("green") show_path(cm_spline, 0.01);

    cu_spline = cubic_spline(points, 100);
    color("blue") show_path(cu_spline, 0.01);

    for(p = points)
        translate(p) color("red")
            cylinder($fn = 64, r = 0.03, h = 0.02, center = true);
}

rotate([70, 0, 315]) splines();
