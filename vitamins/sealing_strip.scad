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
//! Sealing strip from B&Q used to seal around the door of 3D printers.
//
include <../utils/core/core.scad>

use <../utils/rounded_polygon.scad>

r = 0.5;
h = 4;
h2 = 2;
h3 = 3;
w = 10;
w2 = 7;
w3 = 3;

profile = [
    [ -w / 2 + r, r,  r],
    [ -w / 2 + r / 2, 2 * r + 0.1, -0.1],
    [-w2 / 2, h - r,  r],
    [-w3 / 2, h2 + r,-r],
    [      0, h3 - r, r],
    [ w3 / 2, h2 + r,-r],
    [ w2 / 2, h - r,  r],
    [  w / 2 - r / 2, 2 * r + 0.1, -0.1],
    [  w / 2 - r, r,  r],
];

module sealing_strip(length) { //! Draw specified length of sealing strip
    vitamin(str("sealing_strip(", length, "): Sealing strip 10mm x 4mm x ", length, "mm"));
    rotate([90, 0, 90])
        color("Sienna")
            linear_extrude(length, center = true)
                rounded_polygon(profile);
}
