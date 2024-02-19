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
// Threaded inserts
//
//                     l    o    h    s    b     r    r    r
//                     e    u    o    c    a     i    i    i
//                     n    t    l    r    r     n    n    n
//                     g    e    e    e    r     g    g    g
//                     t    r         w    e     1    2    3
//                     h         d         l
//                          d         d          h    d    d
//                                         d
//
F1BM2   = [ "F1BM2",   4.0, 3.6, 3.2, 2,   3.0,  1.0, 3.4, 3.1 ];
F1BM2p5 = [ "F1BM2p5", 5.8, 4.6, 4.0, 2.5, 3.65, 1.6, 4.4, 3.9 ];
F1BM3   = [ "F1BM3",   5.8, 4.6, 4.0, 3,   3.65, 1.6, 4.4, 3.9 ];
F1BM4   = [ "F1BM4",   8.2, 6.3, 5.6, 4,   5.15, 2.3, 6.0, 5.55 ];

CNCKM2p5 =[ "CNCKM2p5",4.0, 4.6, 4.0, 2.5, 3.65, 1.0, 4.4, 3.9 ];
CNCKM3 =  [ "CNCKM3",  3.0, 4.6, 4.0, 3,   3.65, 0.7, 4.4, 3.9 ];
CNCKM4 =  [ "CNCKM4",  4.0, 6.3, 5.6, 4,   5.15, 1.0, 6.0, 5.55];
CNCKM5 =  [ "CNCKM5",  5.8, 7.1, 6.4, 5,   6.0,  1.6, 6.8, 6.33];

// Measurements according to DIN 7965
//
// If you want to add an additional length, it should be sufficient copy one with the same
// M size and change the name (2x) and the first number column (l), all others are dependent
// on the M size.
//                        l,   d2,   d5,  d,   d3,   h,     d3,   d3, P1 (h),    z
M3x8    = [  "M3x8",      8,    6,    5,  3,   4.5,  0.5,  4.5,  4.5,      2,  0.6];
M4x10   = [  "M4x10",    10,    8,  6.5,  4,   5.5,  0.5,  5.5,  5.5,    2.5,  0.6];
M5x12   = [  "M5x12",    12,   10,  8.5,  5,   7.5,  0.5,  7.5,  7.5,    3.5,  0.8];
M6x15   = [  "M6x15",    15,   12, 10.5,  6,   9.5,  0.5,  9.5,  9.5,      4,    1];
M8x18   = [  "M8x18",    18,   16, 14.5,  8,  12.5,  0.5, 12.5, 12.5,      5,    1];
M10x25  = [ "M10x25",    25, 18.5,   17, 10,    15,  0.5,   15,   15,      5,  1.6];
M12x30  = [ "M12x30",    30,   22,   20, 12,    18,  0.5,   18,   18,      5,  1.6];
M16x30  = [ "M16x30",    30,   25, 22.5, 16,  20.5,  0.5, 20.5, 20.5,      5,  1.6];

inserts =       [ F1BM2, F1BM2p5,  F1BM3,  F1BM4,  CNCKM5 ];
short_inserts = [ F1BM2, CNCKM2p5, CNCKM3, CNCKM4, CNCKM5 ];
threaded_inserts = [ M3x8, M4x10, M5x12, M6x15, M8x18, M10x25, M12x30, M16x30 ];

use <insert.scad>
