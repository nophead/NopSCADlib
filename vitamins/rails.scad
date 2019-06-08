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
// Carriages
//
//                 L     L1    W   H   H1   C   B
MGN5_carriage  = [ 16,   9.6,  12, 6,  1.5, 0,  8 , M2_cap_screw ];
MGN7_carriage  = [ 23,   14.3, 17, 8,  1.5, 8,  12, M2_cap_screw ];
MGN9_carriage  = [ 29.7, 20.8, 20, 10, 2,   10, 15, M3_cap_screw ];
MGN12_carriage = [ 34.7, 21.7, 27, 13, 3,   15, 20, M3_cap_screw ];
MGN15_carriage = [ 43.3, 27.7, 32, 16, 4,   20, 25, M3_cap_screw ];
SSR15_carriage = [ 40.3, 23.3, 34, 24, 4.5, 0,  26, M4_cap_screw ];
//
// Rails
//
//
//                Wr  Hr   E    P   D    d    h
MGN5 = [ "MGN5",  5,  3.6, 5,   15, 3.5, 2.4, 0.8, M2_cs_cap_screw, MGN5_carriage, M2_cs_cap_screw ]; // Screw holes too small for M2 heads
MGN7 = [ "MGN7",  7,  5,   5,   15, 4.3, 2.4, 2.6, M2_cap_screw,    MGN7_carriage, M2_cs_cap_screw ];
MGN9 = [ "MGN9",  9,  6,   7.5, 20, 6.0, 3.5, 3.5, M3_cap_screw,    MGN9_carriage, M3_cs_cap_screw ];
MGN12= [ "MGN12", 12, 8,   10,  25, 6.0, 3.5, 4.5, M3_cap_screw,   MGN12_carriage, M3_cs_cap_screw ];
MGN15= [ "MGN15", 15, 10,  10,  40, 6.0, 3.5, 5.0, M3_cap_screw,   MGN15_carriage, M3_cs_cap_screw ];
SSR15= [ "SSR15", 15, 12.5,10,  60, 7.5, 4.5, 5.3, M4_cap_screw,   SSR15_carriage, M4_cs_cap_screw ];

rails = [MGN5, MGN7, MGN9, MGN15, SSR15];

use <rail.scad>
