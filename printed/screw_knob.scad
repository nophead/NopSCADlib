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
//! Knob with embedded hex head screw.
//
include <../core.scad>
use <../utils/hanging_hole.scad>

knob_wall = 2;
function knob_nut_trap_depth(screw) = round_to_layer(screw_head_height(screw));
knob_stem_h = 6;
knob_thickness = 4;
knob_r = 8;
knob_wave = 1;
knob_waves = 5;
knob_height = knob_stem_h + knob_thickness;
function knob_height() = knob_height;

module screw_knob(screw) { //! Generate the STL for a knob to fit the specified hex screw
    knob_stem_r = nut_trap_radius(screw_nut(screw)) + knob_wall;

    function wave(a) = knob_r + sin(a * knob_waves) * knob_wave;

    stl(str("screw_knob_M", screw_radius(screw) * 20))
        union() {
            render() difference() {
                cylinder(r = knob_stem_r, h = knob_thickness + knob_stem_h);

                hanging_hole(knob_nut_trap_depth(screw), screw_clearance_radius(screw))
                    rotate(45)
                        circle(r = nut_trap_radius(screw_nut(screw)), $fn = 6);
            }
            linear_extrude(knob_thickness, convexity = 3)
                difference() {
                    polygon(points = [for(a = [0 : 359]) [wave(a) * sin(a), wave(a) * cos(a)]]);

                    circle(knob_stem_r - eps);
                }
        }
}

//! Place the screw through the printed part
module screw_knob_assembly(screw, length) //! Assembly with the screw in place
assembly(str("screw_knob_M", 20 * screw_radius(screw), "_", length), ngb = true) {
    translate_z(knob_height)
        vflip()
            stl_colour(pp1_colour) screw_knob(screw);

    translate_z(knob_height - knob_nut_trap_depth(screw))
        rotate(-45)
            screw(screw, length);
}

module screw_knob_M30_stl() screw_knob(M3_hex_screw);
module screw_knob_M40_stl() screw_knob(M4_hex_screw);

//! * Press the M3 x 16 hex screw into the knob
module screw_knob_M30_16_assembly() screw_knob_assembly(M3_hex_screw, 16);

//! * Press the M4 x 16 hex screw into the knob
module screw_knob_M40_16_assembly() screw_knob_assembly(M4_hex_screw, 16);
