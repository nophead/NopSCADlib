//
// NopSCADlib Copyright Chris Palmer 2019
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
//! Geared tin can steppers
//
//                                          d   h   r    m           p  l    l     h  o   b    b  s    f   s   f      b                       b               w
//                                          i   e   a    o           i  u    u     o  f   o    o  h    l   h   l      u                       u               i
//                                          a   i   d    t           t  g    g     l  f   s    s  a    a   a   a      l                       l               r
//                                              g   i    o           c             e  s   s    s  f    t   f   t      g                       g               e
//                                              h   u    r           h  w    t        e           t        t          e                       e
//                                              t   s                              d  t   d    h       w       l                              2               d
//                                                       d   h  r                                 d        l          w   d       h   z       w     d     h
28BYJ_48  = ["28BYJ_48",  "28BYJ-48 5V",   28, 19,  1, [ 0,  0, 0], 35, 7, 0.85, 4.2, 8,  9, 1.5, 5,-3.0, 10,  6, [14.7, 17,   16.5,  0], [17.7, 15.5, 13.8], 1,  [["yellow", "orange", "red", "pink", "blue"]] ];
35BYGHJ75 = ["35BYGHJ75", "35BYGHJ75 0.4A",37, 37, -2, [35, 22, 1], 27, 0,    0, 3.0, 7, 12, 3.0, 5, 4.5, 17, 10, [ 7.7, 20.7, 9.25, 21], [   0,    0,    0], 1.3,[["brown", "red"], ["yellow", "green"]] ];

geared_steppers = [28BYJ_48, 35BYGHJ75];

use <geared_stepper.scad>
