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
// Crude representation of a bulldog clip
//
//                                 l   d   h  t     t     r    h
//                                 e   e   e  h     u     a    a
//                                 n   p   i  i     b     d    n
//                                 g   t   g  c     e     i    d
//                                 t   h   h  k           u    l
//                                 h                      s    e
//
small_bulldog = ["small_bulldog", 19, 12, 8, 0.25, 2.67, 1,   16];
large_bulldog = ["large_bulldog", 25, 15,12, 0.28, 3.00, 2.4, 20];

bulldogs = [small_bulldog, large_bulldog];

use <bulldog.scad>
