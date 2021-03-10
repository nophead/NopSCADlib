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
BBSMR95 =  ["SMR95", 5,  9,  2.5, "silver",    0.5, 0.7];  // SMR95 ball bearing for FlexDrive extruder
BB624   =  ["624",   4,  13, 5,   "blue",      1.2, 1.2];  // 624 ball bearing for idlers
BB608   =  ["608",   8,  22, 7,   "OrangeRed", 1.4, 2.0];  // 608 bearings for wades
BB6200   = ["6200",  10, 30, 9,   "black",     2.3, 3.6];  // 6200 bearings for KP pillow blocks
BB6201   = ["6201",  12, 32, 10,  "black",     2.4, 3.7];  // 6201 bearings for KP pillow blocks
BB6808   = ["6808",  40, 52, 7,   "black",     1.5, 1.6];
ball_bearings = [BBSMR95, BB624, BB608, BB6200, BB6201, BB6808];

use <ball_bearing.scad>
