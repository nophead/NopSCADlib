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

//                          p     p   b    p     p       b
//                          i     i   e    i     i       a
//                          t     n   l    n     n       s
//                          c         o                  e
//                          h     l   w    w     c
//                                                       c
//
2p54header = ["2p54header", 2.54, 12, 3.2, 0.66, "gold", grey20, 8.5];

pin_headers = [ 2p54header ];

use <pin_header.scad>
