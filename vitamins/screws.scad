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
// Screws
//
include <nuts.scad>

No2_pilot_radius = 1.7 / 2;       // self tapper into ABS
No4_pilot_radius = 2.0 / 2;       // wood screw into soft wood
No6_pilot_radius = 2.0 / 2;       // wood screw into soft wood
No8_pilot_radius = 2.5 / 2;

No2_clearance_radius = 2.5 / 2;
No4_clearance_radius = 3.5 / 2;
No6_clearance_radius = 4.0 / 2;
No8_clearance_radius = 4.5 / 2;

M2_tap_radius = 1.6 / 2;
M2_clearance_radius = 2.4 / 2;

M2p5_tap_radius = 2.05 / 2;
M2p5_clearance_radius= 2.8 / 2;   // M2.5

M3_tap_radius = 2.5 / 2;
M3_clearance_radius = 3.3 / 2;

M4_tap_radius = 3.3 / 2;
M4_clearance_radius = 2.2;

M5_tap_radius = 4.2 / 2;
M5_clearance_radius = 5.3 / 2;

M6_tap_radius = 5 / 2;
M6_clearance_radius = 6.4 / 2;

M8_tap_radius = 6.75 / 2;
M8_clearance_radius = 8.4 / 2;

//                        d                     h       d    h    h       s    s  m
//                        e                     e       i    e    e       o    o  a
//                        s                     a       a    a    a       c    c  x
//                        c                     d       m    d    d       k    k
//                        r                             e                 e    e  t
//                        i                     t       t    d    h       t    t  h
//                        p                     y       e    i    e               r
//                        t                     p       r    a    i       d    a  e
//                        i                     e            m    g       e    f  a
//                        o                                  e    h       p       d
//                        n                                  t    t       t
//                                                           e            h
//                                                           r
//
M2_cap_screw     = ["M2_cap", "M2 cap",         hs_cap,   2, 3.8, 2,    1.0, 1.5, 16,  M2_washer, M2_nut,   M2_tap_radius,    M2_clearance_radius];
M2p5_cap_screw   = ["M2p5_cap", "M2.5 cap",     hs_cap, 2.5, 4.5, 2.5,  1.1, 2.0, 17,M2p5_washer, M2p5_nut, M2p5_tap_radius,  M2p5_clearance_radius];
M3_cap_screw     = ["M3_cap", "M3 cap",         hs_cap,   3, 5.5, 3,    1.3, 2.5, 18,  M3_washer, M3_nut,   M3_tap_radius,    M3_clearance_radius];
M4_cap_screw     = ["M4_cap", "M4 cap",         hs_cap,   4, 7.0, 4,    2.0, 3.0, 20,  M4_washer, M4_nut,   M4_tap_radius,    M4_clearance_radius];
M5_cap_screw     = ["M5_cap", "M5 cap",         hs_cap,   5, 8.5, 5,    2.5, 4.0, 22,  M5_washer, M5_nut,   M5_tap_radius,    M5_clearance_radius];
M6_cap_screw     = ["M6_cap", "M6 cap",         hs_cap,   6, 10,  6,    3.3, 5.0, 24,  M6_washer, M6_nut,   M6_tap_radius,    M6_clearance_radius];
M8_cap_screw     = ["M8_cap", "M8 cap",         hs_cap,   8, 13,  8,    4.3, 6.0, 28,  M8_washer, M8_nut,   M8_tap_radius,    M8_clearance_radius];

M2_cs_cap_screw  = ["M2_cs_cap","M2 cs cap",    hs_cs_cap,2, 3.8, 0,    0.65,1.3, 16,  M2_washer, M2_nut,   M2_tap_radius,    M2_clearance_radius];
M3_cs_cap_screw  = ["M3_cs_cap","M3 cs cap",    hs_cs_cap,3, 6.0, 0,    1.05,2.0, 18,  M3_washer, M3_nut,   M3_tap_radius,    M3_clearance_radius];
M4_cs_cap_screw  = ["M4_cs_cap","M4 cs cap",    hs_cs_cap,4, 8.0, 0,    1.49,2.5, 20,  M4_washer, M4_nut,   M4_tap_radius,    M4_clearance_radius];
M5_cs_cap_screw  = ["M5_cs_cap","M5 cs cap",    hs_cs_cap,5,10.0, 0,    3.00,3.0, 22,  M5_washer, M5_nut,   M5_tap_radius,    M5_clearance_radius];
M6_cs_cap_screw  = ["M6_cs_cap","M6 cs cap",    hs_cs_cap,6,12.0, 0,    3.00,4.0, 24,  M6_washer, M6_nut,   M6_tap_radius,    M6_clearance_radius];

M2_dome_screw    = ["M2_dome", "M2 dome",       hs_dome,  2, 3.5, 1.3,  0.6, 1.3, 16,  M2_washer, M2_nut,   M2_tap_radius,    M2_clearance_radius];
M3_dome_screw    = ["M3_dome", "M3 dome",       hs_dome,  3, 5.7, 1.65, 1.04,2.0, 18,  M3_washer, M3_nut,   M3_tap_radius,    M3_clearance_radius];
M4_dome_screw    = ["M4_dome", "M4 dome",       hs_dome,  4, 7.6, 2.2,  1.3, 2.5, 20,  M4_washer, M4_nut,   M4_tap_radius,    M4_clearance_radius];
M5_dome_screw    = ["M5_dome", "M5 dome",       hs_dome,  5, 9.5, 2.75, 1.56,3.0, 22,  M5_washer, M5_nut,   M5_tap_radius,    M5_clearance_radius];

M2p5_pan_screw   = ["M2p5_pan", "M2.5 pan",     hs_pan, 2.5, 4.7, 1.7,    0,   0, 0, M2p5_washer, M2p5_nut, M2p5_tap_radius,  M2p5_clearance_radius];
M3_pan_screw     = ["M3_pan", "M3 pan",         hs_pan,   3, 5.4, 2.0,    0,   0, 0,   M3_washer, M3_nut,   M3_tap_radius,    M3_clearance_radius];
M4_pan_screw     = ["M4_pan", "M4 pan",         hs_pan,   4, 7.8, 3.3,    0,   0, 0,   M4_washer, M4_nut,   M4_tap_radius,    M4_clearance_radius];
M5_pan_screw     = ["M5_pan", "M5 pan",         hs_pan,   5, 10,  3.95,   0,   0, 0,   M5_washer, M5_nut,   M5_tap_radius,    M5_clearance_radius];
M6_pan_screw     = ["M6_pan", "M6 pan",         hs_pan,   6, 12,  4.75,   0,   0, 0,   M6_washer, M6_nut,   M6_tap_radius,    M6_clearance_radius];
No632_pan_screw  = ["No632_pan", "6-32 pan",    hs_pan, 3.5, 6.9, 2.5,    0,   0, 0,   M4_washer, false,    No6_pilot_radius, No6_clearance_radius];

M3_hex_screw     = ["M3_hex", "M3 hex",         hs_hex,   3, 6.4, 2.125,  0,   0, 0,   M3_washer, M3_nut,   M3_tap_radius,    M3_clearance_radius];
M4_hex_screw     = ["M4_hex", "M4 hex",         hs_hex,   4, 8.1, 2.925,  0,   0, 0,   M4_washer, M4_nut,   M4_tap_radius,    M4_clearance_radius];
M5_hex_screw     = ["M5_hex", "M5 hex",         hs_hex,   5, 9.2, 3.65,   0,   0, 0,   M5_washer, M5_nut,   M5_tap_radius,    M5_clearance_radius];
M6_hex_screw     = ["M6_hex", "M6 hex",         hs_hex,   6,11.5, 4.15,   0,   0, 0,   M6_washer, M6_nut,   M6_tap_radius,    M6_clearance_radius];
M8_hex_screw     = ["M8_hex", "M8 hex",         hs_hex,   8, 15,  5.65,   0,   0, 22,  M8_washer, M8_nut,   M8_tap_radius,    M8_clearance_radius];

M3_low_cap_screw = ["M3_low_cap", "M3 low cap", hs_cap,   3, 5.5, 2,    1.5, 2.0, 18,  M3_washer, M3_nut,   M3_tap_radius,    M3_clearance_radius];

M3_grub_screw    = ["M3_grub", "M3 grub",       hs_grub,  3,   0, 0,    2.5, 1.5, 0,   M3_washer, M3_nut,   M3_tap_radius,    M3_clearance_radius];
M4_grub_screw    = ["M4_grub", "M4 grub",       hs_grub,  4,   0, 0,    2.4, 2.5, 0,   M4_washer, M4_nut,   M4_tap_radius,    M4_clearance_radius];

No2_screw        = ["No2", "No2 pan wood",      hs_pan, 2.2, 4.2, 1.7,    0,   0, 0, M2p5_washer, false,    No2_pilot_radius, No2_clearance_radius];
No4_screw        = ["No4", "No4 pan wood",      hs_pan, 3.0, 5.5, 2.0,    0,   0, 0 ,M3p5_washer, false,    No4_pilot_radius, No4_clearance_radius];
No6_screw        = ["No6", "No6 pan wood",      hs_pan, 3.5, 6.7, 2.2,    0,   0, 0 ,  M4_washer, false,    No6_pilot_radius, No6_clearance_radius];
No6_cs_screw     = ["No6_cs", "No6 cs wood",    hs_cs,  3.5, 7.0, 0,      0,   0, 0,   M4_washer, false,    No6_pilot_radius, No6_clearance_radius];
No8_screw        = ["No8", "No8 pan wood",      hs_pan, 4.2, 8.2, 3.05,   0,   0, 0 ,  M5_washer, false,    No8_pilot_radius, No8_clearance_radius];

screw_lists = [
[ M2_cap_screw,    M2p5_cap_screw, M3_cap_screw,    M4_cap_screw,    M5_cap_screw,    M6_cap_screw, M8_cap_screw],
[ 0,               0,              M3_low_cap_screw],
[ M2_cs_cap_screw, 0,              M3_cs_cap_screw, M4_cs_cap_screw, M5_cs_cap_screw, M6_cs_cap_screw],
[ M2_dome_screw,   0,              M3_dome_screw,   M4_dome_screw,   M5_dome_screw],
[ 0,               0,              M3_hex_screw,    M4_hex_screw,    M5_hex_screw,    M6_hex_screw, M8_hex_screw],
[ 0,               M2p5_pan_screw, M3_pan_screw,    M4_pan_screw,    M5_pan_screw,    M6_pan_screw, No632_pan_screw],
[ No2_screw,       0,              No4_screw,       No6_screw,       No8_screw,       No6_cs_screw],
[ 0,               0,              M3_grub_screw,   M4_grub_screw]
];

use <screw.scad>

screws = [for(list = screw_lists) each list];

function find_screw(type, size, i = 0) =
    i >= len(screws) ? undef
                     : screw_head_type(screws[i]) == type && screw_radius(screws[i]) == size / 2 ? screws[i]
                                                                                                 : find_screw(type, size, i + 1);

function alternate_screw(type, screw) =
    let(alt_screw = find_screw(type, screw_radius(screw) * 2))
        alt_screw ? alt_screw :screw;
