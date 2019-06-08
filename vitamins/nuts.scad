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
// Nuts
//
M2_nut_trap_depth = 2.5;
M2p5_nut_trap_depth = 2.5;
M3_nut_trap_depth = 3;
M4_nut_trap_depth = 4;
M5_nut_depth = 4;
M6_nut_depth = 5;
M8_nut_depth = 6.5;

//                            s    r    t    n     w              t
//                            c    a    h    y     a              r
//                            r    d    i    l     s              a
//                            e    i    c    o     h              p
//                            w    u    k    c     e
//                                 s    n          r              d
//                                      e    t                    e
//                                      s    h                    p
//                                      s    k                    t
//                                                                h
//
M2_nut      = ["M2_nut",      2,   4.9, 1.6, 2.4,  M2_washer,     M2_nut_trap_depth];
M2p5_nut    = ["M2p5_nut",    2.5, 5.8, 2.2, 3.8,  M2p5_washer, M2p5_nut_trap_depth];
M3_nut      = ["M3_nut",      3,   6.4, 2.4, 4,    M3_washer,     M3_nut_trap_depth];
M4_nut      = ["M4_nut",      4,   8.1, 3.2, 5,    M4_washer,     M4_nut_trap_depth];
M5_nut      = ["M5_nut",      5,   9.2, 4,   6.25, M5_washer,     M5_nut_depth];
M6_nut      = ["M6_nut",      6,  11.5, 5,   8,    M6_washer,     M6_nut_depth];
M6_half_nut = ["M6_half_nut", 6,  11.5, 3,   8,    M6_washer,     3];
M8_nut      = ["M8_nut",      8,  15,   6.5, 8,    M8_washer,     M8_nut_depth];
toggle_nut  = ["toggle_nut",  6.1, 9.2, 1.5, 1.5,  M6_washer,     1.5];

M4_wingnut  = ["M4_wingnut",  4,  10,   3.75,8,    M4_washer,     0, 22, 10, 6, 3];

nuts = [M2_nut, M2p5_nut, M3_nut, M4_nut, M5_nut, M6_nut, M8_nut];

use <nut.scad>
