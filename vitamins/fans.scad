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

//          w     d   b   h      s              h     t    o   b  b    a
//          i     e   o   o      c              u     h    u   l  o    p
//          d     p   r   l      r              b     i    t   a  s    p
//          t     t   e   e      e                    c    e   d  s    e
//          h     h              w              d     k    r   e       r
//                        p                     i     n        s  d    t
//                        i                     a     e    d           u
//                        t                           s    i           r
//                        c                           s    a           e
//                        h
//
fan120x25= [120, 25, 116,52.5,  M4_dome_screw, 41,   4,  140, 9, 0,   137];
fan80x38 = [80,  38, 75, 35.75, M4_dome_screw, 40,   4.3, 84, 7, 0,   85];
fan80x25 = [80,  25, 75, 35.75, M4_dome_screw, 40,   4.3, 84, 7, 0,   85];
fan70x15 = [70,  15, 66, 30.75, M4_dome_screw, 29,   3.8, 70 ,7, 0,   undef];
fan60x25 = [60,  25, 57, 25,    M4_dome_screw, 31.5, 3.6, 64, 7, 0,   63];
fan60x15 = [60,  15, 57, 25,    M4_dome_screw, 29,   2.4, 60, 7, 7.7, 63];
fan50x15 = [50,  15, 48, 20,    M4_dome_screw, 25,  12.5,100, 7, 0,   undef];
fan40x11 = [40,  11, 37, 16,    M3_dome_screw, 25,   7.5,100, 9, 0,   undef];
fan30x10 = [30,  10, 27, 12,    M3_dome_screw, 17,   10, 100, 5, 0,   undef];
fan25x10 = [25.4,10, 24, 10,   M2p5_pan_screw, 16,   10, 100, 5, 0,   undef];
fan17x8  = [17,   8, 16, 6.75,  M2_cap_screw,  12.6,  8, 100, 7, 0,   undef];

fans = [fan17x8, fan25x10, fan30x10, fan40x11, fan50x15, fan60x15, fan60x25, fan70x15, fan80x25, fan80x38, fan120x25];

use <fan.scad>
