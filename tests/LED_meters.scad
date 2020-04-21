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
include <../utils/core/core.scad>
include <../utils/layout.scad>

include <../vitamins/led_meters.scad>

module led_meters()
    layout([for(m = led_meters) meter_bezel_length(m)], 5) let(m = led_meters[$i])
        if($preview) {
            hflip()
                meter(m, colour = "blue", value = "123");

            if(!$i)
                translate([0, meter_bezel_width(m)])
                    meter_assembly(m, value = "123");
        }
        else
            meter_bezel(m);

led_meters();
