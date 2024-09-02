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
include <washers.scad>
//
// Nuts
//
M2_nut_trap_depth = 1.75;
M2p5_nut_trap_depth = 2.5;
M3_nut_trap_depth = 3;
M4_nut_trap_depth = 4;
M5_nut_depth = 4;
M6_nut_depth = 5;
M8_nut_depth = 6.5;

//                                      s    d    t    n     w              t                  t  d    d
//                                      c    i    h    y     a              r                  h  o    o
//                                      r    a    i    l     s              a                  r  m    m
//                                      e    m    c    o     h              p                  e  e    e
//                                      w    e    k    c     e                                 d
//                                           t    n          r              d                     h    t
//                                           e    e    t                    e                  p  e    h
//                                           r    s    h                    p                  i  i    r
//                                                s    k                    t                  t  g    e
//                                                                          h                  c  h    a
//                                                                                             h  t    d
M2_nut      =      ["M2_nut",           2,   4.9, 1.6, 2.4,  M2_washer,     M2_nut_trap_depth, 0];
M2p5_nut    =      ["M2p5_nut",         2.5, 5.8, 2.2, 3.8,  M2p5_washer, M2p5_nut_trap_depth, 0];
M3_nut      =      ["M3_nut",           3,   6.4, 2.4, 4,    M3_washer,     M3_nut_trap_depth, 0, [6,   5.40]];
M4_nut      =      ["M4_nut",           4,   8.1, 3.2, 5,    M4_washer,     M4_nut_trap_depth, 0, [8,   5.74]];
M5_nut      =      ["M5_nut",           5,   9.2, 4,   6.25, M5_washer,     M5_nut_depth,      0, [10,  7.79]];
M6_nut      =      ["M6_nut",           6,  11.5, 5,   8,    M6_washer,     M6_nut_depth,      0, [12,  8.29]];
M6_half_nut =      ["M6_half_nut",      6,  11.5, 3,   8,    M6_washer,     3,                 0];
M8_nut      =      ["M8_nut",           8,  15,   6.5, 8,    M8_washer,     M8_nut_depth,      0, [15, 11.35]];
toggle_nut  =      ["toggle_nut",       6.1, 9.2, 1.5, 1.5,  M6_washer,     1.5,               inch(1/40)];

M4_wingnut  =      ["M4_wingnut",       4,  10,   3.75,8,    M4_washer,     0, 22,   10, 6, 3];

M4_weld_nut  =     ["M4_weld_nut",      4,  5.3,  6.3, 8,    M4_washer,     0, 18,   0.8,]; // Base diameter and thickness
M6_weld_nut  =     ["M6_weld_nut",      6,  7.7,  7.9, 8,    M6_washer,     0, 19.1, 1.2,];

//                                                                              sx  ty1 ty2 hammer
M3_sliding_t_nut = ["M3_sliding_t_nut", 3,   6,   3.0, 4.0,  false,         0,  10,  10,  6, false];
M4_sliding_t_nut = ["M4_sliding_t_nut", 4,   6,   3.7, 4.7,  false,         0,  11,  10,  6, false];
M5_sliding_t_nut = ["M5_sliding_t_nut", 5,   6,   3.7, 4.7,  false,         0,  11,  10,  7, false];
M6_sliding_t_nut = ["M6_sliding_t_nut", 6,   8,   6.6, 8.5,  false,         0,  16,  18.6,8,2, false];
M8_sliding_ball_t_nut = ["M8_sliding_ball_t_nut",
                                        8,   8,   6.7, 7.6,  false,         0,  22,  13.5,  0, false];

M3_hammer_nut =    ["M3_hammer_nut",    3,   6,   2.75,4.0,  false,         0, 5.5,  10,  6, true];
M4_hammer_nut =    ["M4_hammer_nut",    4,   6,   3.25,4.5,  false,         0, 5.5,  10,  6, true];

// DIN 562 (thin) square nuts
//                                                s    w    h
//                                                c    i    e
//                                                r    d    i
//                                                e    t    g
//                                                w    h    h
//                                                          t
//
M3nS_thin_nut    =      ["M3nS_thin_nut",         3, 5.5, 1.8];
M4nS_thin_nut    =      ["M4nS_thin_nut",         4,   7, 2.2];
M5nS_thin_nut    =      ["M5nS_thin_nut",         5,   8, 2.7];
M6nS_thin_nut    =      ["M6nS_thin_nut",         6,  10, 3.2];
M8nS_thin_nut    =      ["M8nS_thin_nut",         8,  13,   4];

nuts = [M2_nut, M2p5_nut, M3_nut, M4_nut, M5_nut, M6_nut, M8_nut];

use <nut.scad>
