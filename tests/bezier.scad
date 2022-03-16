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
use <../utils/bezier.scad>
use <../utils/sweep.scad>
use <../utils/annotation.scad>

function find_min_z(path, i = 1, best_i = 0) =
    i >= len(path) ? best_i
                   : find_min_z(path, i + 1, path[i].z < path[best_i].z ? i : best_i);

module beziers() {
    //
    // Make Bezier control points to give specified length
    //
    control_points = adjust_bezier_length([[0, 0, 100], [0, 0, 0], [200, 0, 20], [100, -100, 50]], 250);
    //
    // Draw control points
    //
    color("green")
        for(p = control_points)
            translate(p)
                sphere(1);
    //
    // Lines joining the control points
    //
    color("red")
        sweep(control_points, circle_points(0.5, $fn = 64));
    //
    // Bezier curve path from control points
    //
    curve = bezier_path(control_points);
    //
    // Draw the curve
    //
    sweep(curve, circle_points(2, $fn = 64));
    //
    // Length computed from control points
    //
    length = bezier_length(control_points);
    //
    // Length computed from curve
    //
    length2 = path_length(curve);
    assert(str(length) == str(length2), str(length, " ", length2));
    //
    // Minimum Z
    //
    min_z = bezier_min_z(control_points);
    i = find_min_z(curve);
    assert(str(min_z) == str(curve[i].z));

    color("blue") {
        translate(curve[i] + [0, 0, 2])
            arrow();

        translate(curve[i] - [0, 0, 2])
            vflip()
                arrow();
    }

    translate(control_points[1] - [0, 0, 2])
        label(str("bezier_length = ", length, ", bezier_min_z = ", bezier_min_z(curve)), valign = "top");

    path1 = [[20, 20,  0], [40, 20, 0]];
    path2 = [[70, 40, -5], [60, 40, 0]];

    color("green")
        for(p = concat(path1, path2))
            translate(p)
                sphere(1);

    color("orange")
        sweep(bezier_join(path1, path2, 10), circle_points(0.5, $fn = 64));
}

if($preview)
    beziers();
