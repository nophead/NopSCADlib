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
module rounded_square(size, r, center = true) //! Like ```square()``` but with with rounded corners
{
    $fn = r2sides4n(r);
    offset(r) offset(-r) square(size, center = center);
}

module rounded_rectangle(size, r, center = true, xy_center = true) //! Like ```cube()``` but corners rounded in XY plane and separate centre options for xy and z.
{
    linear_extrude(height = size[2], center = center)
        rounded_square([size[0], size[1]], r, xy_center);
}
