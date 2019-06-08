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
include <screws.scad>
include <spades.scad>

fused_spades = [[spade6p4, 14,  -7,  0, 0],
                [spade6p4, 14,   7,  0, 0],
                [spade6p4, 14,   0, 11, 0],
                [spade4p8, 8.5, -7, -9, 90],
                [spade4p8, 8.5,  7, -9, 90]];

inlet_spades = [[spade6p4, 9, -7,  -5.5, 0],
                [spade6p4, 9,  7,  -5.5, 0],
                [spade6p4, 9,  0,   5.5, 0]];
//
//                                    p                    s                p   s     s     s  b   b     b  b    f   f   f  f    w   d   s            m
//                                    a                    c                i   l     l     l  e   e     e  e    l   l   l  l    i   e   p            a
//                                    r                    r                t   o     o     o  z   z     z  z    a   a   a  a    d   p   a            l
//                                    t                    e                c   t     t     t  e   e     e  e    n   n   n  n    t   t   d            e
//                                                         w                h                  l   l     l  l    g   g   g  g    h   h   e
//                                                                              w     h     r                    e   e   e  e            s
//                                                                                             w   h     r  t
//                                                                                                               w   h   r  t
//
IEC_fused_inlet = ["IEC_fused_inlet", "IEC fused inlet",   M3_cs_cap_screw, 36, 27.3, 31.2, 3, 28, 31,   2, 2.5, 30, 33, 4, 2.5, 44, 21, fused_spades, false ];
IEC_inlet       = ["IEC_inlet",       "IEC inlet",         M3_cs_cap_screw, 40, 28.2, 20.2, 3, 28, 20.5, 4, 2.5, 37, 23, 1, 2.5, 48, 14, inlet_spades, false ];
IEC_inlet_atx   = ["IEC_inlet_atx",   "IEC inlet for ATX", M3_cs_cap_screw, 40, 27.0, 19.0, 3, 30, 22,   2, 2.0, 30, 22, 2, 4.0, 50, 13, inlet_spades, false ];
IEC_outlet      = ["IEC_outlet",      "IEC outlet",        M3_cs_cap_screw, 40, 32,   24,   3, 28, 20.5, 2, 0.0, 29, 29, 2, 2.9, 50, 23, inlet_spades, true ];

iecs = [IEC_inlet, IEC_inlet_atx, IEC_fused_inlet, IEC_outlet];
use <iec.scad>
