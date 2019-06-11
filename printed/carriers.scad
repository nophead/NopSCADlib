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
//! Adapts ESP12 module to 0.1" grid. See <https://hydraraptor.blogspot.com/2018/04/esp-12-module-breakout-adaptor.html>.
//
$extrusion_width = 0.5;

include <../core.scad>

module ESP12F_carrier_stl() { //! Generate the STL for an ESP12 carrier
    stl("ESP12F_carrier");
    pins = 8;
    pitch1 = 2;
    pitch2 = 2.54;
    hole = pitch1 - squeezed_wall;
    hole2 = pitch2 - 3 * extrusion_width;
    length1 = (pins - 1) * pitch1 + hole + squeezed_wall * 2;
    length2 = (pins - 1) * pitch2 + hole + squeezed_wall * 2;
    height = 3;

    wpitch1 = (pins - 1) * pitch1;
    wpitch2 = ceil(wpitch1 / 2.54) * 2.54;

    width1 = wpitch1 + hole + squeezed_wall * 2;
    width2 = wpitch2 + hole2 + squeezed_wall * 2;

    difference() {
        hull() {
            translate_z(height - eps / 2)
                cube([width1, length1, eps], center = true);

            translate_z(eps / 2)
                cube([width2, length2, eps], center = true);
        }

        for(side = [-1, 1])
            for(i = [0 : pins - 1])
                hull() {
                    translate([side * wpitch1 / 2, i * pitch1 - (pins - 1) * pitch1 / 2, height])
                        cube([hole, hole, eps], center = true);

                    translate([side * wpitch2 / 2, i * pitch2 - (pins - 1) * pitch2 / 2])
                        cube([hole2, hole2, eps], center = true);
                }
    }
}
