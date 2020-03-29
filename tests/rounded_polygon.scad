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
use <../utils/rounded_polygon.scad>
use <../utils/annotation.scad>

r = 5;
h = 40;
h2 = 20;
h3 = 30;
w = 100;
w2 = 70;
w3 = 30;

profile = [
    [ -w / 2 + r, r,  r],
    [ -w / 2 + r / 2, 2 * r + eps, -eps],
    [-w2 / 2, h - r,  r],
    [-w3 / 2, h2 + r,-r],
    [      0, h3 - r, r],
    [ w3 / 2, h2 + r,-r],
    [ w2 / 2, h - r,  r],
    [  w / 2 - r / 2, 2 * r + eps, -eps],
    [  w / 2 - r, r,  r],
];

module rounded_polygons() {
    tangents = rounded_polygon_tangents(profile);
    length = rounded_polygon_length(profile, tangents);

    rotate([70, 0, 315])
        linear_extrude(eps)
            rounded_polygon(profile, tangents);

    translate([0, -10])
        label(str("perimeter length = ", length), valign = "top", halign = "right");

}

rounded_polygons();
