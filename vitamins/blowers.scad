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
//                                                   l     w   d   b     s              h   a            s    s                               e    h    b    t    w    l
//                                                   e     i   e   o     c              u   x            c    c                               x    u    a    o    a    u
//                                                   n     d   p   r     r              b   i            r    r                               i    b    s    p    l    g
//                                                   g     t   t   e     e                  s            e    e                               t         e         l
//                                                   t     h   h         w              d                w    w                                              t
//                                                   h                                                   h    s                                         t         t
RB5015 = ["RB5015", "Blower Runda RB5015",           51.3, 51, 15, 31.5, M4_cap_screw, 26, [27.3, 25.4], 4.5, [[4.3, 45.4], [47.3,7.4]],     20,   14,  1.5, 1.3, 1.2, 15];
PE4020 = ["PE4020", "Blower Pengda Technology 4020", 40,   40, 20, 27.5, M3_cap_screw, 22, [21.5, 20  ], 3.2, [[37,3],[3,37],[37,37]],       29.3, 17,  1.7, 1.2, 1.3, 13];
BL30x10 =["BL30x10","Square radial fan 3010",        30,   30,10.1,25,   M2_cap_screw, 16, [16,   15  ], 2.4, [[3,27],[27,3]],               21.2, 9.5, 1.1, 1.2, 2.5, 2.8, 0.9];
BL40x10 =["BL40x10","Square radial fan 4010",        40,   40,9.5, 27,   M2_cap_screw, 16, [24,   20  ], 2.4, [[2,2],[38,2],[2,38],[38,38]], 27.8, 9.5, 1.5, 1.5, 1.1, 1.5, 1.1];

blowers = [BL30x10, BL40x10, PE4020, RB5015];

use <blower.scad>
