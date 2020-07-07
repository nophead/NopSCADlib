//
// NopSCADlib Copyright Chris Palmer 2020
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
use <../utils/gears.scad>

// left gear teeth
z1 = 39; // [7 : 1 : 99]

// Right gear teeth
z2 = 7; // [7 : 1 : 99]

//  Modulus
m = 2.0; // [0.1 : 0.1 : 5.0]

// Pressure angle
pa = 20; // [14.5, 20, 22.5, 25]

$show_numbers = false;

module gears() {
    color(pp1_colour)
        rotate(-$t * 360)
            linear_extrude(eps, center = true, convexity = z1)
                difference() {
                    involute_gear_profile(m, z1, pa);

                    circle(r = m * z1 / 10);
                }

    color(pp2_colour)
        translate([centre_distance(m, z1, z2, pa), 0])
            rotate(180 + 180 / z2 + $t * 360 * z1 / z2)
               linear_extrude(eps, center = true, convexity = z2)
                    difference() {
                         involute_gear_profile(m, z2, pa);

                         circle(r = m * z2 / 10);
                    }

    z3 = floor((z1 + z2) / PI);
    angle = -$t * 360 + 90 - floor(z1 / 4) * 360 / z1; // Line up the rack 1/4 turn around the gear
    pitch = m * PI;
    color(pp3_colour)
        translate([(angle % ((z3 / z1) * 360)) / 360 * z1 * pitch, -centre_distance(m, z1, 0, pa)])
            linear_extrude(eps, center = true)
                involute_rack_profile(m, z3, 3 * m, pa);
}

rotate(is_undef($bom) ? 0 : [70, 0, 315])
    gears();
