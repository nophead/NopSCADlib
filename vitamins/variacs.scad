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
//
//                                                       d    h   b    b   s   s   s  p    s              d    d
//                                                       i    e   u    u   h   h   c  i    c              i    i
//                                                       a    i   l    l   a   a   r  t    r              a    a
//                                                       m    g   g    g   f   f   e  c    e              l    l
//                                                       e    h   e    e   t   t   w  h    w
//                                                       t                         s                      d    t
//                                                       e        d    w   d   l                          i    h
//                                                       r                                                a    k
//
RAVISTAT1F1  = ["RAVISTAT1F1",  "RAVISTAT 1F-1",        85,  75, 105, 32, 6,   22, 2, 14,  M4_pan_screw, 65,  0.5];
DURATRAKV5HM = ["DURATRAKV5HM", "DURATRAK V5HM",       125, 120, 148, 49, 9.6, 25, 3, 38.1,M5_pan_screw, 104, 1.66, 15.875, 2, 22];

variacs = [RAVISTAT1F1, DURATRAKV5HM];

use <variac.scad>
