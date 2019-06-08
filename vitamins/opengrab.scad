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
//! Nicodrone OpenGrab V3 electro-permananet magnet, see <https://nicadrone.com/products/epm-v3>.
//!
//! A permanent magnet that can be magnatized and de-magnatized electronically.
//
include <../core.scad>

pitch = 33.8;
width = 40;
depth = 18;
magnet = 4.3;
pcb = 0.8;
pillar = 6;
target = 1;
pole_w = 2;
pole_l = 36;
poles = 15;

module opengrab_hole_positions()    //! Position children at the screw positions
    for(x = [-1, 1], y = [-1, 1])
        translate([x * pitch / 2, y * pitch / 2, 0])
            children();


function opengrab_width() = width;              //! Module width
function opengrab_depth() = depth;              //! Module height
function opengrab_target_thickness() = target;  //! Target sheet thickness

module opengrab() { //! Draw OpenGrab module
    vitamin("opengrab(): OpenGrab V3 electro permanent magnet");

    color("grey")
        translate_z(magnet / 2 + eps)
            cube([width, width, magnet - eps], center = true);

    color(grey80) {
        gap = (width - poles * pole_w + 3 * eps) / (poles - 1);
        pitch = pole_w + gap;
        for(i = [0 : poles - 1])
            translate([(i - floor(poles / 2)) * pitch - eps, 0, 0.5])
                cube([pole_w, pole_l, 1], center = true);
    }

    color("darkgreen")
        translate_z(depth - pillar - pcb / 2)
            cube([width, width, pcb], center = true);

    color(brass)
        translate_z(1)
            opengrab_hole_positions()
                linear_extrude(height = depth - 1)
                    difference() {
                            circle(d = 4.7 / cos(30), $fn = 6);

                            circle(r = 3/2);
                    }
}

module opengrab_target() { //! Draw OpenGrab target
    vitamin("opengrab_target(): OpenGrab  silicon steel target plate");

     color(grey80)
        linear_extrude(height = target)
            difference() {
                square([width, width], center = true);

                opengrab_hole_positions()
                    circle(d = 3.2);

                for(side = [-1, 1])
                    translate([side * (width / 2 - 3.5), 0])
                        circle(d = 4);
        }
}
