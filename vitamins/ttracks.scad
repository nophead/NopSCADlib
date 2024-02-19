//
// NopSCADlib Copyright Chris Palmer 2024
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
include <../core.scad>

use <screw.scad>

// Bolts                                                                             HL,   HW,  HT, Thread M
ttrack_bolt_M6       = [ "ttrack_bolt_M6",       "T-Track Bolt M6",                  18,   12, 2.5,  6 ];
ttrack_bolt_M6_small = [ "ttrack_bolt_M6_small", "T-Track Bolt M6 with small head",  18,   11, 2.5,  6 ];
ttrack_bolt_M8       = [ "ttrack_bolt_M8",       "T-Track Bolt M8",                22.5, 12.6,   3,  8 ];

// Inserts
//                                                                                                      TW,  W,   H,  SH, Thread M
ttrack_insert_mitre_30_M6 = [ "TTrack_insert_Miter30_M6", "T-Track insert, Miter track 30mm, M6 thread", 19, 23, 7.8, 4.8, 6 ];
ttrack_insert_mitre_30_M8 = [ "TTrack_insert_Miter30_M8", "T-Track insert, Miter track 30mm, M8 thread", 19, 23, 7.8, 4.8, 8 ];

//
// Tracks
// Width, Depth, Opening, Slot width, slot height, Top thickness, Screw pitch
//                                                          W     D     O     SW     SH    TT    Sp
ttrack_universal_19mm    = [ "ttrack_universal_19mm",      19,  9.5,  9.5,  14.2,   3.3,   2.4,  75, M3_cs_cap_screw, ttrack_bolt_M8 ];
ttrack_universal_19mm_A  = [ "ttrack_universal_19mm_A",  18.7, 12.5,  8.3,    12,   7.3,   3.5,  75, M3_cs_cap_screw, ttrack_bolt_M6 ];
ttrack_universal_19mm_B  = [ "ttrack_universal_19mm_B",    19,  9.5,  6.6,  11.3,     4,   2.5,  75, M3_cs_cap_screw, ttrack_bolt_M6_small ];

ttrack_mitre_30mm   = [ "ttrack_mitre_30mm",    30,   12.8, 19.3,  23.6,   3.1,   5.4,  75, M4_cs_cap_screw, ttrack_insert_mitre_30_M6 ];
ttrack_mitre_36mm   = [ "ttrack_mitre_36mm",    36,   13.5,   19,  23.5,   3.6,   3.6,  75, M4_cs_cap_screw ];




ttracks = [ ttrack_universal_19mm, ttrack_universal_19mm_A, ttrack_universal_19mm_B, ttrack_mitre_30mm, ttrack_mitre_36mm];
ttrack_bolts = [ ttrack_bolt_M6, ttrack_bolt_M6_small, ttrack_bolt_M8 ];
ttrack_inserts = [ ttrack_insert_mitre_30_M6, ttrack_insert_mitre_30_M8 ];


use <ttrack.scad>
