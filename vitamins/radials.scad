//
// NopSCADlib Copyright Chris Palmer 2023
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
//! Radial components for PCBs.
//

// Crystals
HC49    = ["HC49",    [10.5, 3.7, 13.5],    [0.475, 0.6], 4.88, 0.45];
HC49_4H = ["HC49_4H", [10.5, 3.7,  3.5],    [0.475, 0.6], 4.88, 0.43];
C_002RX = ["C_002RX", [ 2.0,   0,    6],    false,         0.7,  0.2];
ACT1700 = ["ACT1700", [10.8, 10.8, 5.3, 1], [1,     0.6], [ inch(0.3), inch(0.3)], 0.45 ];
ACT1100 = ["ACT1100", [20.4, 10.8, 5.3, 1], [1,     0.6], [ inch(0.6), inch(0.3)], 0.45 ];

rd_xtals = [C_002RX, HC49_4H, ACT1700, ACT1100, HC49];

use <radial.scad>
