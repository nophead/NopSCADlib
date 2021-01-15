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

//
//! Method to print holes in mid air. See <https://hydraraptor.blogspot.com/2014/03/buried-nuts-and-hanging-holes.html>
//
include <../utils/core/core.scad>

module hanging_hole(z, ir, h = 100, h2 = 100) { //! Hole radius `ir` hanging at the specified `z` value above a void who's shape is given by a 2D child
    module polyhole(r, h, n = 8) {
        if(h > 0)
            rotate(180 / n) {
                poly_cylinder(r = r, h = layer_height, sides = n);

                translate_z(layer_height)
                    if(2 * n <= sides(r))
                        polyhole(r - eps, h - layer_height, n * 2);
                    else
                        poly_cylinder(r - eps, h - layer_height);
            }
    }
    assert(z - layer_height * floor(z / layer_height) < eps, str(z));
    infill_angle = z % (2 * layer_height) ? -45 : 45;
    below = min(z + eps, h2);
    big = 1000;
    render(convexity = 3) translate_z(z)
        union() {
            translate_z(2 * layer_height)
                if(sides(ir) > 4)
                    polyhole(ir - eps, h - 2 * layer_height);
                else
                    poly_cylinder(ir, h - 2 * layer_height);

            difference() {
                translate_z(-below)
                    linear_extrude(below + 2 * layer_height)
                        children();

                rotate(infill_angle)
                    for(side = [-1, 1]) {
                        translate([side * (ir + big), 0, big + layer_height])
                            cube(2 * big, center = true);

                        translate([0, side * (ir + big), big])
                            cube(2 * big, center = true);

                    }
            }
        }
}
