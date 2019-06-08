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
//! Steel rods, with optional chamfer.
//
include <../core.scad>

rod_colour = grey80;

module rod(d , l) {
    vitamin(str("rod(", d, ", ", l, "): Smooth rod ", d, "mm x ", l, "mm"));

    chamfer = d / 10;
    color(rod_colour)
        hull() {
            cylinder(d = d, h = l - 2 * chamfer, center = true);

            cylinder(d = d - 2 * chamfer, h = l, center = true);
        }
}
