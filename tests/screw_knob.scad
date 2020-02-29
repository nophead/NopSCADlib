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

use <../printed/screw_knob.scad>

screws = [M3_hex_screw, M4_hex_screw];

module do_screw_knob(screw)
    if($preview)
        screw_knob_assembly(screw, 16);
    else
        screw_knob(screw);

module screw_knobs()
    for(i = [0 : len(screws) - 1])
        translate([i * 30, 0])
            do_screw_knob(screws[i]);

screw_knobs();
