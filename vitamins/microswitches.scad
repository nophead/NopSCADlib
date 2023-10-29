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
// Microswitches
//
small_leg  = [0.9,  3.3, 0.4, 0];
medium_leg = [0.5,  3.9, 3.2, 1.6, [0, -0.5]];
large_leg  = [11.4, 0.8, 6.3, 1.8, [1.7, 0]];
//                                                               t    w     l     r  h     h                               b     b    b             o     f     l                                                l           b         b
//                                                               h    i     e     a  o     o                               u     u    u             p     p     e                                                e           o         u
//                                                               i    d     n     d  l     l                               t     t    t                         g                                                g           d         t
//                                                               c    t     g     i  e     e                               t     t    t             t     m                                                                  y         t
//                                                               k    h     t     u                                        o     o    o             o     a     p                                                t                     o
//                                                               n          h     s  d     p                               n     n    n             l     x     o                                                y           c         n
//                                                               e                   i     o                                                                    s                                                p           l
//                                                               s                   a     s                               w     t    p                         n                                                e           r         c
//                                                               n                         n                                          o                         s                                                                      l
//                                                                                         s                                          s                                                                                                r
small_microswitch  = ["small_microswitch", "DM1-00P-110-3",      5.8, 6.5,  12.8, 0, 2,    [[-3.25, -1.65], [3.25, -1.65]], 2.9, 1.2, [-1.95, 3.75], 0.2, 0.55, [[-5.08, -4.9], [0,    -4.9],  [5.08, -4.9]  ], small_leg,  grey(20), "white"  ];
medium_microswitch = ["medium_microswitch","SS-01 or SS-5GL",    6.4, 10.2, 19.8, 1, 2.35, [[-4.8,  -2.6 ], [4.7,  -2.6 ]], 3.2, 2,   [-2.8,  5.8 ], 0.5, 1.00, [[-8.05, -7.05], [0.75, -7.05], [8.05, -7.05] ], medium_leg, grey(20), "burlywood" ];
large_microswitch  = ["large_microswitch", "Saia G3 low force", 10.4, 15.9, 28.0, 2, 3.1,  [[-11.1, -5.15], [11.2,  5.15]], 4,   2.75,[-9.1,  9.55], 0.3, 1.2,  [[19.7,   2.19], [19.7, -3.45], [8.3, -10.45] ], large_leg,  "ivory",  "white" ]; //G3M1T1PUL

microswitches = [small_microswitch, medium_microswitch, large_microswitch];

use <microswitch.scad>
