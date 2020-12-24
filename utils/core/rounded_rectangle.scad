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
//! Rectangle with rounded corners.
//
module rounded_square(size, r, center = true) //! Like `square()` but with with rounded corners
{
    $fn = r2sides4n(r);
    offset(r) offset(-r) square(size, center = center);
}

module rounded_rectangle(size, r, center = true, xy_center = true) //! Like `cube()` but corners rounded in XY plane and separate centre options for xy and z.
{
    linear_extrude(size.z, center = center)
        rounded_square([size.x, size.y], r, xy_center);
}

module rounded_rectangle_xz(size, r, center = true, xy_center = true) //! Like `cube()` but corners rounded in XZ plane and separate centre options for xy and z.
{
    translate([xy_center ? 0 : size.x / 2, xy_center ? 0 : size.y / 2, center ? 0 : size.z / 2])
        rotate([90, 0, 0])
            rounded_rectangle([size.x, size.z, size.y], r, center = true, xy_center = true);
}

module rounded_rectangle_yz(size, r, center = true, xy_center = true) //! Like `cube()` but corners rounded in YX plane and separate centre options for xy and z.
{
    translate([xy_center ? 0 : size.x / 2, xy_center ? 0 : size.y / 2, center ? 0 : size.z / 2])
        rotate([90, 0, 90])
            rounded_rectangle([size.y, size.z, size.x], r, center = true, xy_center = true);
}
