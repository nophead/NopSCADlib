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
//                                                    b   s     h   f     f    f    h  h    h        s             p   l  f  c
//                                                    o   h     e   l     l    l    o  o    o        c             i   e  l  o
//                                                    r   a     i   a     a    a    l  l    l        r             t   a  a  l
//                                                    e   n     g   n     n    n    e  e    e        e             c   d  t  o
//                                                        k     h   g     g    g    s                w             h         u
//                                                              t   e     e    e       d    p                                r
//
//                                                                  d     t    o
LSN8x2  = ["LSN8x2",  "Leadscrew nut 8 x 2",           8, 10.2, 15, 22,   3.5, 1.5, 4, 3.5, 8,       M3_cap_screw, 2,  2, 0, "dimgrey"];
LSN8x8  = ["LSN8x8",  "Leadscrew nut 8 x 8 RobotDigg", 8, 12.75,19, 25.4, 4.1, 0,   3, 3.5, 19.05/2, M3_cap_screw, 2,  8, 0, "dimgrey"];
SFU1610 = ["SFU1610", "Leadscrew nut for SFU1610",    16, 28, 42.5, 48,    10, 0,   6, 6,   38/2,    M6_cap_screw, 5, 10, 40, "#DFDAC5"];

leadnuts = [LSN8x2, LSN8x8, SFU1610];
//                                                  L   W   H   Hole    Mounting screws (top)             Nut      Nut mount screw
//                                                              Pos     Dist L Dist W Type             L            Length
LNHT8x2 = [ "LNHT8x2", "Lead Screw Nut Housing T8", 30, 34, 30, -1,     20,    24,    M4_cs_cap_screw, 15, LSN8x2,  15 ];
leadnuthousings = [LNHT8x2];

use <leadnut.scad>
