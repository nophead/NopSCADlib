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
// Hot end descriptions
//
//                        s       p                    l    i    d      i l  c           s g    g     d   d              d a   d a
//                        t       a                    e    n    i      n e  o           c r    r     u   u              u t   u t
//                        y       r                    n    s    a      s n  l           r o    o     c   c              c     c
//                        l       t                    g    e           u g  o           e o    o     t   t              t n   t f
//                        e                            t    t           l t  u           w v    v                          o     a
//                                                     h                a h  r             e    e     r   o              h z   h n
//                                                                      t                p            a   f              e z   e
//                                                                      o                i d    w     d   f              i l   i
//                                                                      r                t i    i     i   s              g e   g
//                                                                                       c a    d     u   e              h     h
//                                                                                       h      t     s   t              t     t
//                                                                                              h
//
JHeadMk5  = ["JHeadMk5", "jhead","JHead MK5",         51.2,  4.75,16,    40, grey(20),   12,    4.64, 13, [0, 2.38, -5], 20,   20];
E3Dv5     = ["E3Dv5",     "e3d", "E3D V5 direct",       70,  3.7, 16,  50.1, "silver",   12,    6,    15, [1, 5,  -4.5], 14.5, 28];
E3Dv6     = ["E3Dv6",     "e3d", "E3D V6 direct",       62,  3.7, 16,  42.7, "silver",   12,    6,    15, [1, 5,  -4.5], 14,   21];
E3D_clone = ["E3D_clone", "e3d", "E3D clone aliexpress",66,  6.8, 16,    46, "silver",   12,    5.6,  15, [1, 5,  -4.5], 14.5, 21];

hot_ends = [JHeadMk5, E3Dv5, E3Dv6, E3D_clone];

use <hot_end.scad>
