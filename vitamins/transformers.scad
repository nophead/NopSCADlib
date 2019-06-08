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
//                                                                       w    d   h    x   y   s             f  f    f   l   l    b  b   b   b
//                                                                       i    e   e    p   p   c             o  o    o   a   a    o  o   o   o
//                                                                       d    p   i    i   i   r             o  o    o   m   m    b  b   b   b
//                                                                       t    t   g    t   t   e             t  t    t
//                                                                       h    h   h    c   c   w                         d   h    o  w   h   r
//                                                                                t    h   h                 t  w    d   e   e    f  i   e   a
//                                                                                                           h  i    e   p   i    f  d   i   d
//                                                                                                           i  d    p   t   g    s  t   g   i
//                                                                                                           c  t    t   h   h    e  h   h   u
//                                                                                                           k  h    h       t    t      t   s
//
CCM300 = ["CCM300", "Carroll & Meynell CCM300/230 isolation",            120, 88, 120, 90, 68, M5_pan_screw, 2, 111, 86, 42, 106, 6, 79, 62, 8];
SMALLTX= ["SMALLTX", "Small mains",                                       38, 32, 33,  47, 0,  M3_pan_screw,.8, 58,  12, 16,  33, 0, 25, 20, 2];

transformers = [SMALLTX, CCM300];

use <transformer.scad>
