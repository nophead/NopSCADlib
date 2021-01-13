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
// Green terminal blocks
//

//                                            f        b                               b    y    y
//                                   h        h    f   h    b     s      f             o    o    o
//                       p     d     e        e    d   e    d     c      r             x    f    f     t
//                       i     e     i        i    e   i    e     r      o   b    b         f    f     u
//                       t     p     g  t     g    p   g    p     e      n   o    o    s    s    s     b
//                       c     t     h  o     h    t   h    t     w      t   x    x    b    e    t     e
//                       h     h     t  p     t    h   t    h     r      t   w    h         t    2     h
//
gt_2p54 = ["gt_2p54", 2.54,  6.6,   10, 3,    6, 0.4,  6.4, 1,    1,    0.2, 2,   2,   2,   0,   0,    0];
gt_3p5  = ["gt_3p5",  3.5,   7.3,  8.5, 4,    5, 0.4,  4,   0,    1.35, 0.4, 1.8, 2,   2,   0,   0,    0];
gt_5p08 = ["gt_5p08", 5.08,  7.9,   10, 5.0,  7, 0.0,  6.8, 1.45, 1.95, 0.5, 4.0, 5.4, 0.5, 0,   0,    0];
gt_6p35 = ["gt_6p35", 6.35, 12.6, 17.4, 6.8, 12, 0.4, 11,   2,    2.7,  0.8, 3.4, 4.2, 2,   1.8, 1.1, 21.4];
gt_5x11 = ["gt_5x11",    5,    8,   11, 5,    7, 0.4,  7,   1.5,  1.5,  1,   2.5, 6,   0,   0,   0,    0];
gt_5x17 = ["gt_5x17",    5,   10,   17, 5,   11, 0.4,  9,   2,    1.5,  1,   3,   6,   0,   0,   0,    0];

green_terminals = [gt_2p54, gt_3p5, gt_5p08, gt_6p35, gt_5x11, gt_5x17];

use <green_terminal.scad>
