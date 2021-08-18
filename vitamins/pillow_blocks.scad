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

//
//! KP pillow block bearings
//

include <ball_bearings.scad>

//                      d   H   L   J   A    N  H1  H0     K  S  b   bolthole             bearing
KP08_15 = ["KP08_15",   8, 15, 55, 42, 13, 4.5,  5, 29,  0.0, 0, 22, M4_clearance_radius, BB608];
KP08_18 = ["KP08_18",   8, 18, 55, 42, 13, 4.5,  5, 29,  0.0, 0, 22, M4_clearance_radius, BB608];
KP000 =   ["KP000",    10, 18, 67, 53, 16, 7.0,  6, 35, 14.0, 4, 30, M6_clearance_radius, BB6200];
KP001 =   ["KP001",    12, 19, 71, 56, 16, 7.0,  6, 38, 14.5, 4, 32, M6_clearance_radius, BB6201];

kp_pillow_blocks = [KP08_15, KP08_18, KP000, KP001];

use <pillow_block.scad>
