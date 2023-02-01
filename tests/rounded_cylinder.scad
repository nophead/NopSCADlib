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

include <../global_defs.scad>
use <../utils/rounded_cylinder.scad>


module rounded_cylinders() {
    linear_extrude(eps)
        rounded_corner(10, 20, 3, 5);

    translate([30, 10])
        rounded_cylinder(10, 20, 3, 5, 270);

    translate([65, 10])
        rounded_top_rectangle([30, 20, 5], 3, 2);
}

rounded_cylinders();
