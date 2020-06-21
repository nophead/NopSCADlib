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
//                                                                   l   l   g  w     d    a     t    p
//                                                                   e   e   r  i     e    p     h    c
//                                                                   n   d   o  d     p    e     i    b
//                                                                   g   s   u  t     t    r     c
//                                                                   t       p  h     h    t     k    t
//                                                                   h                     u     n    h
//                                                                                         r     e    i
//                                                                                         e     s    c
//                                                                                               s    k
Rigid5050 = ["Rigid5050", "rigid SMD5050 low profile",              500, 36, 3, 14.4,   7, 10.4, 0.9, 1.2];
RIGID5050 = ["RIGID5050", "rigid SMD5050"            ,              500, 36, 3, 14.4, 8.6,  9.8, 0.8, 1.6];

light_strips = [Rigid5050,  RIGID5050,];

use <light_strip.scad>
