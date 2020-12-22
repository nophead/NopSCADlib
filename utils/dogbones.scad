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
//! When square holes are cut with a CNC bit they get rounded corners. If it is important that
//! a square cornered part fits in the hole then circles are placed in the corners making a bone shape.
//
include <../utils/core/core.scad>

module dogbone_square(size, r = cnc_bit_r, center = true, x_offset, y_offset) //! Square with circles at the corners, with optional offsets
{
    x_offset = is_undef(x_offset) ? r / sqrt(2) : x_offset;
    y_offset = is_undef(y_offset) ? r / sqrt(2) : y_offset;

    union() {
        square(size, center = center);

        if(r > 0) {
            origin = center ? [0, 0] : size / 2;

            for(x = [-1, 1], y = [-1, 1])
                translate(origin + [x * (size.x / 2 - x_offset), y * (size.y / 2 - y_offset)])
                    drill(r, 0);
        }
    }
}

module dogbone_rectangle(size, r = cnc_bit_r, center = true, xy_center = true, x_offset, y_offset) //! Rectangle with cylinders at the corners
{
    extrude_if(h = size.z, center = center)
        dogbone_square([size.x, size.y], r, xy_center, x_offset, y_offset);
}

module dogbone_rectangle_x(size, r = cnc_bit_r, center = true, xy_center = true) //! Rectangle with cylinders at the corners, offset in the x direction
{
    dogbone_rectangle(size = size, r = r, center = center, x_offset = 0, y_offset = r);
}

module dogbone_rectangle_y(size, r = cnc_bit_r, center = true, xy_center = true) //! Rectangle with cylinders at the corners, offset in the y direction
{
    dogbone_rectangle(size = size, r = r, center = center, x_offset = r, y_offset = 0);
}
