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

include <../utils/core/core.scad>

module rounded_rectangles() {
    linear_extrude(eps)
        rounded_square([30, 20], 3);

    translate([40, 0])
        rounded_rectangle([30, 20, 10], 3);

    translate([80, 0])
        rounded_cube_xy([30, 20, 10], 3);

    translate([120, 0])
        rounded_cube_xz([30, 20, 10], 3);

    translate([160, 0])
        rounded_cube_yz([30, 20, 10], 3);
}

rounded_rectangles();
