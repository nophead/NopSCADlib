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
    assert(r < min(size.x, size.y) / 2);
    $fn = r2sides4n(r);
    offset(r) offset(-r) square(size, center = center);
}

module rounded_rectangle(size, r, center = false, xy_center = true) //! Like `cube()` but corners rounded in XY plane and separate centre options for xy and z.
{
    extrude_if(size.z, center = center)
        rounded_square([size.x, size.y], r, xy_center);
}

module rounded_cube_xy(size, r = 0, xy_center = false, z_center = false) //! Like `cube()` but corners rounded in XY plane and separate centre options for xy and z.
{
    extrude_if(size.z, center = z_center)
        rounded_square([size.x, size.y], r, xy_center);
}

module rounded_cube_xz(size, r = 0, xy_center = false, z_center = false) //! Like `cube()` but corners rounded in XZ plane and separate centre options for xy and z.
{
    translate([xy_center ? 0 : size.x / 2, xy_center ? 0 : size.y / 2, z_center ? 0 : size.z / 2])
        rotate([90, 0, 0])
            rounded_cube_xy([size.x, size.z, size.y], r, xy_center = true, z_center = true);
}

module rounded_cube_yz(size, r = 0, xy_center = false, z_center = false) //! Like `cube()` but corners rounded in YX plane and separate centre options for xy and z.
{
    translate([xy_center ? 0 : size.x / 2, xy_center ? 0 : size.y / 2, z_center ? 0 : size.z / 2])
        rotate([90, 0, 90])
            rounded_cube_xy([size.y, size.z, size.x], r, xy_center = true, z_center = true);
}
