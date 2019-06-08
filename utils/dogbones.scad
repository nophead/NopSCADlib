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
include <../core.scad>

module dogbone_square(size, r = cnc_bit_r, center = true) //! Square with circles at the corners
{
    union() {
        square(size, center = center);

        if(r > 0) {
            origin = center ? [0, 0] : size / 2;
            offset = r / sqrt(2);

            for(x = [-1, 1], y = [-1, 1])
                translate(origin + [x * (size.x / 2 - offset), y * (size.y / 2 - offset)])
                    drill(r, 0);
        }
    }
}

module dogbone_rectangle(size, r = cnc_bit_r, center = true, xy_center = true) //! Rectangle with cylinders at the corners
{
    extrude_if(h = size.z, center = center)
        dogbone_square([size.x, size.y], r, xy_center);
}
