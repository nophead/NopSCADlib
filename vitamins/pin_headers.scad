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

//                               p     p     b    p     p       b         s    b                 b    p      r     r
//                               i     i     e    i     i       a         o    o                 o    i      a     a
//                               t     n     l    n     n       s         c    x                 x    n
//                               c           o                  e         k                                  b     h
//                               h     l     w    w     c                      s                 t    y
//                                                              c         h    z                             o
//                                                                                                           f
2p54header    = ["2p54header",   2.54, 11.6, 3.2, 0.66, "gold", grey(20), 8.5, [0,   0,    8.7], 2.4, 0,     0,    0  ];
jst_xh_header = ["jst_xh_header",2.5,  10,   3.4, 0.64, "gold", grey(90), 0,   [4.9, 5.75, 7],   0.8, 0.525, 0.6,  6.1];
jst_ph_header = ["jst_ph_header",2.0,   9,   3.4, 0.64, silver, grey(90), 0,   [3.9, 4.5,  6],   0.6, 0.55,  0.25, 4.8];

pin_headers = [ 2p54header ];

use <pin_header.scad>
