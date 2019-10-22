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
// Ring terminals
//
//                                        o    i     l  w      h    t  s              c
//                                        d    d     e  i      o    h  c              r
//                                                   n  d      l    i  r              i
//                                                   g  t      e    c  e              m
//                                                   t  h           k  w              p
//                                                   h
//
M3_ringterm       = ["M3_ringterm",       6,   3,   12, 3,   1.5, 0.2, M3_dome_screw, 0];
M3_ringterm_cs    = ["M3_ringterm_cs",    6,   3,   12, 3,   1.5, 0.2, M3_cap_screw,  0];
M3_ringterm_crimp = ["M3_ringterm_crimp", 5.5, 3,   13, 4.1, 0,   0.7, M3_dome_screw, 4.5];

ring_terminals = [M3_ringterm, M3_ringterm_cs, M3_ringterm_crimp];

use <ring_terminal.scad>
