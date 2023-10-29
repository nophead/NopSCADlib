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
//                              w     h    w    r    b    b   r     c      c      c     c    c
//                              i     e    a    i    u    u   a     a      a      a     a    a
//                              d     i    l    v    t    t         p      p      p     p    p
//                              t     g    l    i             z
//                              h     h         t    d    h         f      d      h     s    f
//                                                                  d                   t    h
button_12mm  = ["button_12mm",  12,  4.0, 0.8, 1.5, 6.8, 4.3, 7,    12.86, 11.44, 8.15, 2.7, 1.4];
button_6mm   = ["button_6mm",   6,   4.0, 0.2, 1.0, 3.5, 5.0, 4.05, 0];
button_6mm_7 = ["button_6mm_7", 6,   4.0, 0.2, 1.0, 3.5, 7.0, 4.05, 0];
button_4p5mm = ["button_4p5mm", 4.5, 3.1, 0.1, 0.9, 2.4, 4.5, 3,    0];

buttons = [button_4p5mm, button_6mm, button_6mm_7, button_12mm];

use <button.scad>
