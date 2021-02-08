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
//! Adapts ESP12 modules and various small PCBs to 0.1" grid. See <https://hydraraptor.blogspot.com/2018/04/esp-12-module-breakout-adaptor.html>.
//
$extrusion_width = 0.5;

include <../utils/core/core.scad>

function carrier_height() = 3; //! Height of PCB carrier

module ESP12F_carrier_stl() { //! Generate the STL for an ESP12 carrier
    pins = 8;
    pitch1 = 2;
    pitch2 = 2.54;
    hole = pitch1 - squeezed_wall;
    hole2 = pitch2 - 3 * extrusion_width;
    length1 = (pins - 1) * pitch1 + hole + squeezed_wall * 2;
    length2 = (pins - 1) * pitch2 + hole + squeezed_wall * 2;
    height = carrier_height();

    wpitch1 = (pins - 1) * pitch1;
    wpitch2 = ceil(wpitch1 / 2.54) * 2.54;

    width1 = wpitch1 + hole + squeezed_wall * 2;
    width2 = wpitch2 + hole2 + squeezed_wall * 2;

    stl("ESP12F_carrier")
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

module TP4056_carrier_stl() { //! Generate the STL for an TP4056 carrier, two required
    pitch = 2.54;
    outer_pitch = 13.9;
    inner_pitch = 7.54;
    hole = pitch - 3 * extrusion_width;
    pins = 6;
    length1 = outer_pitch + hole + squeezed_wall * 2;
    length2 = (pins - 1) * pitch + hole + squeezed_wall * 2;
    height = carrier_height();

    width = hole + squeezed_wall * 2;
    spacing = inch(0.9);

    stl("TP4056_carrier")
        difference() {
            hull() {
                translate_z(height - eps / 2)
                    cube([width, length1, eps], center = true);

                translate_z(eps / 2)
                    cube([width, length2, eps], center = true);
            }

            for(i = [0 : pins - 1])
                let(x = [-outer_pitch / 2, - inner_pitch / 2, 0, 0, inner_pitch / 2, outer_pitch / 2][i])
                    if(x)
                        hull() {
                            translate([0, x, height])
                                cube([hole, hole, eps], center = true);

                            translate([0, i * pitch - (pins - 1) * pitch / 2])
                                cube([hole, hole, eps], center = true);
                        }
        }
}

module MT3608_carrier_stl() { //! Generate the STL for an MT3608 carrier, two required
    pcb_width = 17;
    w_pitch_top = 6.81;
    w_pitch_bot = inch(0.3);
    l_pitch_top = 30.855;
    l_pitch_bot = inch(1.2);
    hole = 1;
    height = carrier_height();
    wall = 2 * extrusion_width;
    width = hole + 2 * wall;
    offset = (l_pitch_top - l_pitch_bot) / 2;

    stl("MT3608_carrier")
        difference() {
            hull() {
                translate([offset, 0, height - eps / 2])
                    rounded_rectangle([width, pcb_width - 2, eps], 1, true);

                translate_z(eps / 2)
                    rounded_rectangle([width, pcb_width - 2, eps], 1, true);
            }
            for(side = [-1, 1])
                hull() {
                    translate([offset, side * w_pitch_top / 2, height])
                        cube([hole, hole, eps], center = true);

                    translate([0, side * w_pitch_bot / 2])
                        cube([hole, hole, eps], center = true);
                }
        }
}
