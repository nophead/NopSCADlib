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
// Washers
//
//                             s    d    t    s       s       s    s   p
//                             c    i    h    o       t       p    p   e
//                             r    a    i    f       a       r    r   n
//                             e    m    c    t       r       i    i   n
//                             w    e    k                    n    n   y
//                                  t    n            d       g    g
//                                  e    e            i                v
//                                  r    s            a       d    t   e
//                                       s                    i    h   r
//                                                            a    k
M3_penny_washer = ["M3_penny", 3,  12,   0.8, false,  5.8,  5.6, 1.0, true];
M4_penny_washer = ["M4_penny", 4,  14,   0.8, false,  7.9,  7.0, 1.2, true];
M5_penny_washer = ["M5_penny", 5,  20,   1.4, false,  9.0,  8.8, 1.6, true];
M6_penny_washer = ["M6_penny", 6,  26,   1.5, false, 10.6,  9.9, 1.6, true];
M8_penny_washer = ["M8_penny", 8,  30,   1.5, false, 13.8, 12.7, 2.0, true];

M2_washer       = ["M2",       2,   5,   0.3, false,  4.5,  4.4, 0.5, undef];
M2p5_washer     = ["M2p5",     2.5, 5.9, 0.5, false,  5.4,  5.1, 0.6, undef];
M3_washer       = ["M3",       3,   7,   0.5, false,  5.8,  5.6, 1.0, M3_penny_washer];
M3p5_washer     = ["M3p5",     3.5, 8,   0.5, false,  6.9,  6.2, 1.0, undef];
M4_washer       = ["M4",       4,   9,   0.8, false,  7.9,  7.0, 1.2, M4_penny_washer];
M5_washer       = ["M5",       5,  10,   1.0, false,  9.0,  8.8, 1.6, M5_penny_washer];
M6_washer       = ["M6",       6,  12.5, 1.5, false, 10.6,  9.9, 1.6, M6_penny_washer];
M8_washer       = ["M8",       8,  17,   1.6, false, 13.8, 12.7, 2.0, M8_penny_washer];
toggle_washer   = ["toggle",   6.1,12,   0.6, false, 10,      0,   0, undef];

M3_rubber_washer= ["M3_rubber",3,  10,   1.5, true,   5.8, M3_penny_washer];

washers = [M2_washer, M2p5_washer, M3_washer, M3p5_washer, M4_washer, M5_washer, M6_washer, M8_washer, M3_rubber_washer];

use <washer.scad>
