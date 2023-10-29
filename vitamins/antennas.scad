//
// NopSCADlib Copyright Chris Palmer 2023
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
//! Wifi Antennas
//

//
//                                  d         l        t    b    s      s  h                       g              r                                 g
//                                  e         e        o    o    p      t  i                       r              i                                 a
//                                  s         n        p    t    l      r  n                       i              n                                 p
//                                  c         g                  i      a  g                       p              g
//                                            t        d    d    t      i  e                                      s
//                                            h                         g                          d    h  h2
//                                                                      h  postw pinz pind wr sw                  z      t    z
//                                                                      t
ESP201_antenna = ["ESP201_antenna", "ESP201", 108.5, 7.9, 9.5, 20.6, 20.6, [5.3, 26, 1.7, 8.5, 2], [10, 9, 6.5], [[97.6, 0.7, 0.6], [99, 0.7, 0.6]], 6.45];

antennas = [ ESP201_antenna ];

use <antenna.scad>
