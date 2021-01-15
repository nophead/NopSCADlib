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

module globals() {
    linear_extrude(eps) {
        semi_circle(r = 10);

        translate([30, 0])
            ellipse(15, 7);

        translate([50, 0])
            right_triangle(10, 20, 0);
    }
    assert(slice("ABCD")    == "ABCD");
    assert(slice("ABCD", 1) == "BCD");
    assert(slice("ABCD", 2) == "CD");
    assert(slice("ABCD", 3) == "D");
    assert(slice("ABCD", 4) == "");
    assert(slice("ABCD", 1, -1) == "BC");
    assert(slice("ABCD", 2, -1) == "C");
    assert(slice("ABCD", 3, -1) == "");
    assert(slice("ABCD", 4, -1) == "");
    assert(slice("ABCD", 0, -1) == "ABC");
    assert(slice("ABCD", 0, -2) == "AB");
    assert(slice("ABCD", 0, -3) == "A");
    assert(slice("ABCD", 0, -4) == "");
    assert(slice("ABCD", 0,  0) == "");
    assert(slice("ABCD", 0,  1) == "A");
    assert(slice("ABCD", 0,  2) == "AB");
    assert(slice("ABCD", 0,  3) == "ABC");
}

rotate([70, 0, 315]) globals();
