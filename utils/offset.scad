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

//! 3D offset using `minkowski` with a `sphere`, so very slow if `$fn` is not kept small. The offset can be positive or negative.
//!
//! Can be used to round corners. Positive offsets will round convex corners, negative offsets round concave corners. To round both use [`round_3D()`](#round).
//!
//! If `chamfer_base` is true then the bottom edge is made suitable for 3D printing by chamfering when the angle gets shallower than 45 degrees.
include <../utils/core/core.scad>

module offset_3D(r, chamfer_base = false) { //! Offset 3D shape by specified radius `r`, positive or negative.
    module ball(r)
        if(chamfer_base)
            rotate_extrude()
                intersection() {
                    rotate(180)
                        teardrop(0, r);

                    translate([0, -r])
                        square([r, 2 * r]);
                }
        else
            sphere(r);

    if(r > 0)
        minkowski() {
            children();

            ball(r);
        }
    else
        if(r < 0)
            render() difference() {
                cube(inf / 2, center = true);

                minkowski() {
                    difference() {
                        cube(inf, center = true);

                        children();
                    }
                    ball(-r);
                }
            }
        else
            children();
}
