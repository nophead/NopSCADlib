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
//! Draw a 3D right triangle with rounded edges. Intended to be embedded in other parts. Can be optionally offset by the filleted amount.
//
include <../utils/core/core.scad>

module rounded_right_triangle(x, y, z, fillet, center = true, offset = false) { //! Draw a 3D right triangle with rounded edges.
    fillet = max(fillet, eps);
    size = [x + (offset ? 2 * fillet : 0), y + (offset ? 2 * fillet : 0), z];

    translate([offset ? -2 * fillet : 0, offset ? -2 * fillet : 0, center ? 0 : size.z / 2])
        hull() {
            translate([0, fillet, size.z / 2])
                rotate([90, 90, 0])
                    rounded_rectangle([size.z, 2 * fillet, eps], fillet - eps, xy_center = false);
            translate([0, size.y, size.z / 2])
                rotate([90, 90, 0])
                    rounded_rectangle([size.z, 2 * fillet, eps], fillet - eps, xy_center = false);
            translate([fillet, 0, size.z / 2])
                rotate([0, 90, 0])
                    rounded_rectangle([size.z, 2 * fillet, eps], fillet - eps, xy_center = false);
            translate([size.x, 0, size.z / 2])
                rotate([0, 90, 0])
                    rounded_rectangle([size.z, 2 * fillet, eps], fillet - eps, xy_center = false);
        }
}
