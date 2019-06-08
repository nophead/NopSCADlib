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
//                     p                                l   w   h   b    h  p   s
//                     a                                e   i   e   a    o  i   l
//                     r                                n   d   i   s    l  t   o
//                     t                                g   t   g   e    e  c   t
//                                                      t   h   h           h
//                                                      h           t    d      w
//
SSR10DA = [ "SSR10DA", "Robodigg 10A",                  58, 45, 33, 2.5, 5, 47, 9  ];
SSR25DA = [ "SSR25DA", "Fotek 25A",                     63, 45, 23, 4.6, 5, 47, 10 ];

ssrs = [SSR25DA, SSR10DA];

use <ssr.scad>
