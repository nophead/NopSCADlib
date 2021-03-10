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
// Nylon pillars
//
//                                                  n            t  h   o          i          o  i   o         i         b   t
//                                                  a            h  e   d          d          f  f
//                                                  m            r  i                         n  n   c         c         t   t
//                                                  e            e  g                                o         o         h   h
//                                                               a  h                                l         l         r   r
//                                                               d  t                                o         o         e   e
//                                                                                                   u         u         a   a
//                                                               d                                   r         r         d   d
//
M2x16_brass_pillar     = ["M2x16_brass_pillar",     "nurled",    2, 16, 3.17,      3.17,       0, 0, brass,     brass,    3,-3];
M3x13_hex_pillar       = ["M3x13_hex_pillar",       "hex",       3, 13, 5/cos(30), 5/cos(30),  6, 6, "silver",  silver,  -6, 6];
M3x20_hex_pillar       = ["M3x20_hex_pillar",       "hex",       3, 20, 5/cos(30), 5/cos(30),  6, 6, "silver",  silver,  -8, 8];
M3x20_nylon_pillar     = ["M3x20_nylon_pillar",     "nylon",     3, 20, 8,         5/cos(30),  0, 6, "white",   brass,   -6, 6];
M4x17_nylon_pillar     = ["M4x17_nylon_pillar",     "nylon",     4, 20, 8,         5/cos(30),  0, 6, "white",   brass,   -6, 6];
M3x20_nylon_hex_pillar = ["M3x20_nylon_hex_pillar", "hex nylon", 3, 20, 8/cos(30), 8/cos(30),  6, 6,  grey(20),   grey(20),  -6, 6];
M3x10_nylon_hex_pillar = ["M3x10_nylon_hex_pillar", "hex nylon", 3, 10,5.5/cos(30),5.5/cos(30),6, 6,  grey(20),   grey(20),  -6, 6];


pillars = [M2x16_brass_pillar, M3x13_hex_pillar, M3x20_hex_pillar, M3x20_nylon_pillar, M4x17_nylon_pillar, M3x10_nylon_hex_pillar, M3x20_nylon_hex_pillar];

use <pillar.scad>
