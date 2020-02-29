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
include <springs.scad>
//
//                      w     h     t    t     t   p            n
//                      i     e     h    a     a   o            e
//                      d     i     i    b     b   s            g
//                      t     g     c
//                      h     h     k    w     h   h    d  d    h    s
//                            t     n                   1  2         p
//                                  e                                r
//                                  s                                i
//                                  s                                n
//                                                                   g
bcontact = ["bcontact", 9.33, 9.75, 0.4, 2.86, 6, [1.6, 3, 5], [4.5, batt_spring]];

//                                                                    l     d     n   p    p    c                  L                       U  c
//                                                                    e     i     e   o    o    o                  E                       S  o
//                                                                    n     a     g   s    s    l                  D                       B  n
//                                                                    g     m                   o                                             t
//                                                                    t     e     d   d    h    u                                             a
//                                                                          t                   r                                             c
//                                                                          e                                                                 t
//                                                                          r
LUMINTOP  = ["LUMINTOP",  "Cell LUMINTOP 18650 LION with charger",    70.7, 18.4, 13, 5,   1,   "white",          [[3.32, 5], [3.32, -5]], 4, bcontact];
S25R18650 = ["S25R18650", "Cell Samsung 25R 18650 LION",              65,   18.3, 13, 10,  0,   "MediumSeaGreen", [],                      0, bcontact];
AACELL    = ["AACELL",    "Cell AA",                                  50.5, 14.5, 11, 5.5, 1,   "grey",           [],                      0, bcontact];
AAACELL   = ["AAACELL",   "Cell AAA",                                 44.5, 10.5,  8, 3.8, 0.8, "grey",           [],                      0, bcontact];
CCELL     = ["CCELL",     "Cell C",                                   50,   26.2, 20, 7.5, 1.5, "brown",          [],                      0, bcontact];
DCELL     = ["DCELL",     "Cell D",                                   61.5, 34.2, 22, 8.2, 2.4, "brown",          [],                      0, bcontact];

batteries = [AAACELL, AACELL, CCELL, DCELL, LUMINTOP, S25R18650];

use <battery.scad>
