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
//! SMD components
//

LED0603 = ["LED0603", [1.6, 0.8,  0.18], [1.0, 0.8,  0.42]];
LED0805 = ["LED0805", [2.0, 1.25, 0.46], [1.4, 1.25, 0.54]];
LED1206 = ["LED1206", [3.2, 1.6, 0.5], [2.0, 1.6, .6]];

smd_leds = [LED0603, LED0805, LED1206];

RES0402 = ["RES0402", [1.0, 0.5, 0.35], 0.2, 1/16];
RES0502 = ["RES0502", [1.3, 0.6, 0.38], 0.2, 1/20];
RES0603 = ["RES0603", [1.6, 0.8, 0.45], 0.3, 1/10];
RES0805 = ["RES0805", [2.0, 1.2, 0.45], 0.4, 1/8];
RES1206 = ["RES1206", [3.1, 1.6, 0.6],  0.5, 1/4];
L2012C  = ["L2012C",  [2.0, 1.25,0.9],  0.5, 0];

smd_resistors = [RES0402, RES0502, RES0603, RES0805, RES1206, L2012C];

CAP0402 = ["CAP0402", [1.0, 0.5], 0.2];
CAP0502 = ["CAP0502", [1.3, 0.6], 0.2];
CAP0603 = ["CAP0603", [1.6, 0.8], 0.3];
CAP0805 = ["CAP0805", [2.0, 1.2], 0.4];
CAP1206 = ["CAP1206", [3.1, 1.6], 0.5];
CAP1210 = ["CAP1210", [3.1, 2.5], 0.6];

smd_capacitors = [CAP0402, CAP0502, CAP0603, CAP0805, CAP1206, CAP1210];

SOT23  = ["SOT23",  [3,   1.4, 1.0], 0.05, 0.66, 1.9, 2.6, [0.4, 0.45, 0.15], 0.4];
SOT223 = ["SOT223", [6.5, 3.5, 1.6], 0.05, 0.89, 2.3, 7.0, [0.7, 0.95, 0.25], 3];

smd_sots = [SOT23, SOT223];

SOT23_6    = ["SOT23_6",  [3.0,  1.6,  1.05], 0.10, 0.20, 0.95, 2.8,   [0.40, .45, 0.125]];
TSOT23_8   = ["TSOT23_8", [3.0,  1.8,  0.9 ], 0.10, 0.20, 0.70, 3.0,   [0.31, .45, 0.17]];
SOIC8      = ["SOIC8",    [4.90, 3.90, 1.25], 0.10, 0.66, 1.27, 6.00,  [0.31, .50, 0.20]];
SOIC14     = ["SOIC14",   [8.70, 3.90, 1.25], 0.10, 0.66, 1.27, 6.00,  [0.31, .50, 0.20]];
SOIC16     = ["SOIC16",   [9.90, 3.90, 1.25], 0.10, 0.66, 1.27, 6.00,  [0.31, .50, 0.20]];
SOIC18     = ["SOIC18",   [11.40,7.50, 2.00], 0.10, 1.20, 1.27, 10.30, [0.31, .50, 0.20]];

smd_soics = [SOT23_6, TSOT23_8, SOIC8, SOIC14, SOIC16, SOIC18];

DO214AC = ["DO214AC", [4.0, 2.5, 2.0], 0.1, 1, [4.8, 1.2, 0.15, 2], grey(20)];

smd_diodes = [DO214AC];

TANT_A = ["TANT_A", [3.0, 1.6, 1.6], 0.1, 0.8,  [3.2, 1.2, 0.08, 1.1], ["#E9D769", "#E9B44A"]];
TANT_B = ["TANT_B", [3.3, 2.8, 1.9], 0.1, 0.95, [3.5, 2.2, 0.08, 1.4], ["#E9D769", "#E9B44A"]];
TANT_C = ["TANT_C", [5.8, 3.2, 2.6], 0.1, 1.3,  [6.0, 2.2, 0.08, 2.9], ["#E9D769", "#E9B44A"]];

smd_tants = [TANT_A, TANT_B, TANT_C];

IND2525 = ["IND2525", [6.75, 6.75, 2], 0.1, 1.75, [7.24, 3.2, 0.15, 4.4], grey(50)];
CDRH104 = ["CDRH104", [10.3, 10.3, 4.0], 0.1, 3.85, [10.5, 3.2, 0.15, 4.4], grey(50)];

smd_inductors = [IND2525, CDRH104];

TC33X1 = ["TC33X1", [3.0, 3.8, 0.5], [0.95, 0.9, 0.88, 1.5, 0.2, 0.75],[3.0, 0.1, 0.2, 1.2, 1.7, 1.2, 1, 0.5], [2.1, 0.5], 1.5];

smd_pots = [TC33X1];


U_FL_R_SMT_1 = ["U_FL_R_SMT_1", [2.6, 2.6, 0.35], 0.2, [2, 1.7, 1.25], [1.86, 0.09, 0.6], 0.5, [0.4, 1.8, 0.2], [0.6, 3.1, 0.2]];

smd_coaxs = [U_FL_R_SMT_1];

QFP50P1200X1200X160_64N = ["QFP50P1200X1200X160_64N", [10, 10, 1.6], 12, 64, 0.5, [1, 0.2, 0.1], [0.2, 0.6, 0.1, 0.1]];

smd_qfps = [ QFP50P1200X1200X160_64N ];

OMT250 = ["OMT250", [11, 4.6, 3.3], 0.15, [1.9,0.5, 2.7], [5.5, 4.6, 0.5]];

smd_250V_fuses = [OMT250];

use <smd.scad>
