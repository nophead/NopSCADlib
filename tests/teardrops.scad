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

include <../core.scad>

module teardrops() {
    color(pp1_colour)
        rotate([90, 0, -45])
            linear_extrude(height = 3)
                difference() {
                    square(40);

                    translate([10, 10])
                        teardrop(h = 0, r = 3);

                    translate([10, 20])
                        teardrop_plus(h = 0, r = 3);

                    translate([20, 30])
                        tearslot(h = 0, r = 3, w = 10);

                    translate([30, 15])
                        vertical_tearslot(h = 0, r =3, l = 10);

                    translate([20, 10])
                        semi_teardrop(h = 0, r = 3);
                }
}

teardrops();
