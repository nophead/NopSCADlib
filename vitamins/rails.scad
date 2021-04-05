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

//
// Rails
//
//                Wr  Hr  Emin    P   D    d    h                                       go    gw
MGN5 = [ "MGN5",   5,  3.6,  5,   15, 3.6, 2.4, 0.8, M2_cs_cap_screw, M2_cs_cap_screw,  1,    1 ]; // Screw holes too small for M2 heads
MGN7 = [ "MGN7",   7,  5,    5,   15, 4.3, 2.4, 2.6, M2_cap_screw,    M2_cs_cap_screw,  1.5,  1.5 ];
MGN9 = [ "MGN9",   9,  6,    5,   20, 6.0, 3.5, 3.5, M3_cap_screw,    M3_cs_cap_screw,  1.5,  1.5 ];
MGN12 =[ "MGN12", 12,  8,  7.5,   25, 6.0, 3.5, 4.5, M3_cap_screw,    M3_cs_cap_screw,  2.25, 2.75];
MGN15 =[ "MGN15", 15, 10,   10,   40, 6.0, 3.5, 5.0, M3_cap_screw,    M3_cs_cap_screw,  2.5,  2.75 ];
SSR15= [ "SSR15", 15, 12.5, 10,   60, 7.5, 4.5, 5.3, M4_cap_screw,    M4_cs_cap_screw,  2.5,  2.75 ];
//
// Carriages
//
//                           L     L1    W   H   H1   C    B
MGN5C_carriage  = ["MGN5C",  16,    9.6, 12,  6, 1.5, 0,   8, M2_cap_screw, MGN5 ];
MGN7C_carriage  = ["MGN7C",  23,   14.3, 17,  8, 1.5, 8,  12, M2_cap_screw, MGN7 ];
MGN7H_carriage  = ["MGN7H",  30.8, 21.8, 17,  8, 1.5,13,  12, M2_cap_screw, MGN7 ];
MGN9C_carriage  = ["MGN9C",  29.7, 20.8, 20, 10, 2,  10,  15, M3_cap_screw, MGN9 ];
MGN9H_carriage  = ["MGN9H",  39.9, 29.9, 20, 10, 2,  16,  15, M3_cap_screw, MGN9 ];
MGN12C_carriage = ["MGN12C", 34.7, 21.7, 27, 13, 3,  15,  20, M3_cap_screw, MGN12 ];
MGN12H_carriage = ["MGN12H", 45.4, 32.4, 27, 13, 3,  20,  20, M3_cap_screw, MGN12 ];
MGN15C_carriage = ["MGN15C", 43.3, 27.7, 32, 16, 4,  20,  25, M3_cap_screw, MGN15 ];
SSR15_carriage  = ["SSR15",  40.3, 23.3, 34, 24, 4.5, 0,  26, M4_cap_screw, SSR15 ];

rails = [MGN5, MGN7, MGN9, MGN12, MGN15, SSR15];

carriages = [MGN5C_carriage, MGN7C_carriage, MGN7H_carriage, MGN9C_carriage, MGN9H_carriage, MGN12C_carriage, MGN12H_carriage, MGN12H_carriage, MGN15C_carriage, SSR15_carriage];

use <rail.scad>
