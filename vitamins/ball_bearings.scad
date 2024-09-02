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


//          name     id od   w    colour       or    ir    fd     fw
BBSMR95  = ["SMR95", 5,  9,  2.5, "silver",    0.5,  0.7,   0,    0];  // SMR95 ball bearing for FlexDrive extruder
BB624    = ["624",   4,  13, 5,   "blue",      1.2,  1.2,   0,    0];  // 624 ball bearing for idlers
BB686    = ["686",   6,  13, 5,   "silver",    0.9,  0.7,   0,    0];
BB696    = ["696",   6,  16, 5,   "silver",    1.8,  1.3,   0,    0];
BB608    = ["608",   8,  22, 7,   "black",     1.4,  2.0,   0,    0];  // 608 bearings for wades
BB6200   = ["6200",  10, 30, 9,   "black",     2.3,  3.6,   0,    0];  // 6200 bearings for KP pillow blocks
BB6201   = ["6201",  12, 32, 10,  "black",     2.4,  3.7,   0,    0];  // 6201 bearings for KP pillow blocks
BB6808   = ["6808",  40, 52, 7,   "black",     1.5,  1.6,   0,    0];
BBMR63   = ["MR63",  3,  6,  2.5, "silver",    0.5,  0.5,   0,    0];
BBMR83   = ["MR83",  3,  8,  3,   "silver",    0.5,  0.5,   0,    0];
BBMR85   = ["MR85",  5,  8,  2.5, "silver",    0.5,  0.5,   0,    0];
BBMR93   = ["MR93",  3,  9,  4,   "silver",    0.5,  0.5,   0,    0];
BBMR95   = ["MR95",  5,  9,  3,   "silver",    0.5,  0.5,   0,    0];
BBF623   = ["F623",  3,  10, 4,   "black",     0.6,  0.7,  11.5,  1];
BBF693   = ["F693",  3,  8,  3,   "silver",    0.5,  0.7,  9.5,   0.7];
BBF625   = ["F625",  5,  16, 5,   "silver",    1.0,  1.0,  18,    1];
BBF695   = ["F695",  5,  13, 4,   "silver",    1.0,  1.0,  15,    1];

ball_bearings = [BBF625, BBF693, BBF623, BBF695, BBMR63, BBMR83, BBMR85, BBMR93, BBMR95, BBSMR95, BB624, BB686, BB696, BB608, BB6200, BB6201, BB6808];

use <ball_bearing.scad>
