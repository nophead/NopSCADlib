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
use <../utils/layout.scad>

include <../vitamins/smds.scad>

module smds() {
    layout([for(r = smd_resistors) smd_res_size(r).x], 1)
        smd_resistor(smd_resistors[$i], ["1R0", "10M", "100K"][$i % 3]);

    translate([0, 3])
        layout([for(l = smd_leds) smd_led_size(l).x], 1)
            smd_led(smd_leds[$i], ["green", "blue", "red"][$i % 3]);
}

if($preview)
    smds();
