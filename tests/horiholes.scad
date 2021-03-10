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
$layer_height = 0.25;
include <../utils/core/core.scad>
use <../utils/horiholes.scad>

show_disc = true;
use_horihole = true;
thickness = 6;
length = 60;
height = 20;
overlap_x = 15;
overlap_y = 10;

module hole_positions() {
    x0 = (length - 40) / 2;
    for($i = [0 : 4], $z = 5 + $i * layer_height / 5, $r = 3)
        translate([x0 + $i * 10, $z])
            children();

    for($i = [0 : 4], $z = 15 + $i * layer_height / 5, $r = 0.5 + $i / 2)
        translate([x0 + $i * 10, $z])
            children();
}

module horiholes_stl(t = thickness) {
    rotate([90, 0, 0])
        difference() {
            linear_extrude(t, center = true) {
                difference() {
                    square([length, height]);

                    hole_positions()
                        if(use_horihole)
                            horihole($r, $z);
                        else
                            teardrop_plus(h = 0, r = $r);
                }
            }
        }
    if(t == thickness)
        translate([length / 2, 0])
            rounded_rectangle([length + 2 * overlap_x, thickness + 2 * overlap_y, 2], 5, true);
}

module horiholes() {
    stl_colour(pp1_colour)
        rotate([-90, 0, 0])
            horiholes_stl(eps);

    if(show_disc)
        hole_positions()
            color(silver)
                cylinder(r = $r, h = eps, center = true, $fn = 360);

    hole_positions()
        color("blue")
            horicylinder(r = $r, z = $z, h = 2 * eps, center = true, $fn = 360);

    hole_positions()
        color("red")
            linear_extrude(3 * eps, center = true)
                intersection() {
                    difference() {
                        square(8, center = true);

                        horihole($r, $z);
                    }

                    circle($r, $fn = 360);
                }
}

if($preview)
    rotate(is_undef($bom) ? 0 : [70, 0, 315])
        horiholes();
else
    horiholes_stl();
