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


inserts =       [ F1BM2, F1BM2p5,  F1BM3,  F1BM4,  CNCKM5 ];
short_inserts = [ F1BM2, CNCKM2p5, CNCKM3, CNCKM4, CNCKM5 ];

use <insert.scad>
