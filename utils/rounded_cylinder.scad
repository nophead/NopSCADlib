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
//! Cylinder with a rounded end.
//
include <../utils/core/core.scad>

module rounded_corner(r, h, r2, ir = 0) { //! 2D version
    assert(ir <= r - r2);

    translate([ir , 0])
        hull() {
            square([eps, h]);

            square([r - ir, eps]);

            translate([r - r2 - ir, h - r2])
                intersection() {
                    circle4n(r2, $fs = 0.2);

                    square(r2);
                }
        }
}

module rounded_cylinder(r, h, r2, ir = 0, angle = 360) //! Rounded cylinder given radius `r`, height `h`, optional internal radius `ir` and optional `angle`
{
    rotate_extrude(angle = angle)
        rounded_corner(r, h, r2, ir);
}
