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
//! Steel rods and studding with chamfered ends.
//
include <../core.scad>
include <springs.scad>

rod_colour = grey80;
studding_colour = grey70;

module rod(d , l) { //! Draw a smooth rod with specified length and diameter
    vitamin(str("rod(", d, ", ", l, "): Smooth rod ", d, "mm x ", l, "mm"));

    chamfer = d / 10;
    color(rod_colour)
        hull() {
            cylinder(d = d, h = l - 2 * chamfer, center = true);

            cylinder(d = d - 2 * chamfer, h = l, center = true);
        }
}

module studding(d , l, pitch = 0) { //! Draw a threaded rod with specified length, diameter and thread pitch. Thread not drawn if pitch is zero.
    vitamin(str("studding(", d, ", ", l,"): Threaded rod M", d, " x ", l, "mm"));

    guage = pitch * 0.75;
    if (pitch) {
        turnCount = l/pitch;
        thread  =  ["thread", d, guage, l, turnCount,  1, false, 0, studding_colour];
        translate_z(-l/2) comp_spring(thread, vitamin = false);
    }
    chamfer = d / 20;
    color(studding_colour)
        hull() {
            cylinder(d = d-guage/2, h = l - 2 * chamfer, center = true);

            cylinder(d = d-guage/2 - 2 * chamfer, h = l, center = true);
        }
}
