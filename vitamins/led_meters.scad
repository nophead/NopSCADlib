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

//                          display size   offset   pcb size              lug size offset hole pitch and size
led_meter  = ["led_meter",  [22.72, 10.14, 6.3], 0, [22.72, 11.04, 0.96], [30, 4.2],  0,  26, 2.2 / 2, false];
led_ameter = ["led_ameter", [22.72, 14.05, 7.3], 1, [27.5,  18.6,   1.2], [35, 6.25], 1,  29, 3.0 / 2, [15.5, 1.5, 7.75]];

led_meters = [led_meter, led_ameter];

use <led_meter.scad>
