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
ACT1700 = ["ACT1700", [10.8, 10.8, 5.3, 1], [1,     0.6], inch([0.3, 0.3]), 0.45 ];
ACT1100 = ["ACT1100", [20.4, 10.8, 5.3, 1], [1,     0.6], inch([0.6, 0.3]), 0.45 ];

rd_xtals = [C_002RX, HC49_4H, ACT1700, ACT1100, HC49];

// Modules
HF33F     = ["HF33F",    "Relay", [20.5, 10.6, 15.7], 0.5, grey(20), [0.3,  0.8,  3.6], inch([ [-0.35, 0.15], [-0.35, -0.15], [0.35, -0.15], [0.05, -0.15] ]) ];
VCE03     = ["VCE03",    "PSU",   [40.6, 19.1, 19.1], 0.5, grey(20), [0.64, 0.64, 4.8], inch([ [-0.7,  0.04], [-0.5,   0.04], [0.6,   0.04], [0.7,   0.04] ]) ];
LDE10_20B = ["LDE10_20B","PSU",   [53.8, 28.8, 19.0], 0.5, grey(20), [1.0,  0,    6.0], inch([ [-0.9,  0.4],  [-0.9,   -0.4], [0.9,   0],    [0.9,    0.4] ]) ];

rd_modules = [HF33F, VCE03, LDE10_20B];

// Disks
ERZV07D471 = ["ERZV07D471", "Varistor",          [6.5, 5.0, 8.0], [4.75, 3.1], [0.6,  1.4], [grey(20),  grey(80)]];
6p4mm_disc = ["6p4mm_disc", "Ceramic capacitor", [6.5, 2.1, 7.8], [5.0,  0.9], [0.6,  0.8], ["#C5702D", grey(20)]];
10mm_disc  = ["10mm_disc",  "Ceramic capacitor", [10,  4.25, 12], [7.72, 0],   [0.64, 2.0], ["#BA9C16", grey(20)]];

rd_discs = [6p4mm_disc, ERZV07D471, 10mm_disc];

// Transistors
TO92 =   ["TO92",   [5.0, 3.9, 4.5], [grey(20), grey(80)], [0.48, 0.48], [[-1,0], [0,0], [1,0]] ];
E_LINE = ["E_LINE", [4.6, 2.3, 3.8], [grey(30), grey(80)], [0.45, 0.45], [[-1,0], [0,0], [1,0]] ];

rd_transistors = [ E_LINE, TO92];

// Electrolytic capacitors
ECAP8x11 = ["ECAP8x12", [8.2, 7.5, 12.5], 0.5, [2.4, 2.5], 0.5, inch(0.1), [grey(20), grey(60)]];

rd_electrolytics = [ECAP8x11];

// Boxed plastic film capacitors
BOXC18x5x11  = ["BOXC18x5x11",  [18,  5, 11, 0.25], 1.2, [8,  0.6, 0.4], [15, 0.6, 4.4], [grey(40), "LightYellow"]];
BOXC18x10x16 = ["BOXC18x10x16", [18, 10, 16, 0.25], 1.7, [12, 0.8, 0.4], [15, 0.8, 4.4], [grey(40), "LightYellow"]];

rd_box_caps = [BOXC18x5x11, BOXC18x10x16];

ATX_CM_CHOKE = ["ATX_CM_CHOKE", [17.4, 11.4, 9, 0.5], [2, 0.8], [11, 4.7, 0.8], [1, 2.4, 6.8], [inch(0.3), inch(0.4), 3, 0.65]];

rd_cm_chokes = [ATX_CM_CHOKE];

IND16x10 = ["IND16x10", [10, 6.7, 16, 10], [inch(0.5), 0.9, 3], grey(20), 10];

rd_coils = [IND16x10];

use <radial.scad>
