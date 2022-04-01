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
use <../utils/layout.scad>

use <../printed/screw_knob.scad>

knobs = [
    M3_hex_screw,
    M4_hex_screw,
    screw_knob(M5_hex_screw, flange_r = 12, flange_t = 6, stem_h = 2, waves = 6),
    screw_knob(M6_hex_screw, flange_r = 15, flange_t = 6, solid = false, stem_h = 2, waves = 6, wall = 1.6, fluted = true),
];

module do_screw_knob(knob) {
    if($preview)
        screw_knob_assembly(knob, 16);
    else
        screw_knob(knob);
}

module screw_knobs()
    layout([for(k = knobs) 2 * screw_knob_flange_r(k)], 10)
        do_screw_knob(knobs[$i]);

screw_knobs();
