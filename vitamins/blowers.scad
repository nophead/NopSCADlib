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
//                                                    l     w   d   b    s              h   a            s    s
//                                                    e     i   e   o    c              u   x            c    c
//                                                    n     d   p   r    r              b   i            r    r
//                                                    g     t   t   e    e                  s            e    w
//                                                    t     h   h        w              d                w    w
//                                                    h                                                  h    s
RB5015 = ["RB5015", "Blower Runda RB5015",           51.3, 51, 15, 31.5, M4_cap_screw, 26, [27.3, 25.4], 4.5, [[4.3, 45.4], [47.3,7.4]], 20, 14, 1.5, 1.3, 1.2, 15];
PE4020 = ["PE4020", "Blower Pengda Technology 4020", 40,   40, 20, 27.5, M3_cap_screw, 22, [21.5, 20  ], 3.2, [[37,3],[3,37],[37,37]], 29.3, 17, 1.7, 1.2, 1.3, 13];
BL40x10 =["R4010", "Square radial 4010",             40,   40,9.5, 27,   M2_cap_screw, 16, [24,   20  ], 2.4, [[2,2,1.5],[38,2,1.5],[2,38,1.5],[38,38,1.5]], 28, 9.5, 1.5, 1.5, 1.3,  0];

blowers = [BL40x10, PE4020, RB5015];

use <blower.scad>
