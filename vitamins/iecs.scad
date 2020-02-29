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
include <spades.scad>

fused_spades = [[spade4p8, 8.5,  7,  3, 90],
                [spade4p8, 8.5,  0,  7, 90],
                [spade4p8, 8.5,  5, -7, 90]];

fused_spades2 = [[spade6p4, 13,  -7,  0, 0],
                [spade6p4, 13,   7,  0, 0],
                [spade6p4, 13,   0, 11, 0],
                [spade4p8, 8.5, -7, -9, 90],
                [spade4p8, 8.5,  7, -9, 90]];

iec320c14FusedSwitchedSpades = [[spade4p8, 8.5,  7,  10, 0],
                                [spade4p8, 8.5,  0,  20, 0],
                                [spade4p8, 8.5,  9,  -2, 0]];

inlet_spades = [[spade6p4, 9, -7,  -5.5, 0],
                [spade6p4, 9,  7,  -5.5, 0],
                [spade6p4, 9,  0,   5.5, 0]];

atx_spades = [[spade3p5, 8, -7,  -3, 90],
              [spade3p5, 8,  7,  -3, 90],
              [spade3p5, 8,  0,   3, 90]];

outlet_spades = [[spade4p8ll, 8, -7,  -2, 90],
                 [spade4p8ll, 8,  7,  -2, 90],
                 [spade4p8ll, 8,  0,   2, 90]];

//
//                                    p                              s                p    b   b   b  b   b     b    b    b   f     f  f    f   w   d   s            m
//                                    a                              c                i    o   o   o  o   e     e    e    e   l     l  l    l   i   e   p            a
//                                    r                              r                t    d   d   d  d   z     z    z    z   a     a  a    a   d   p   a            l
//                                    t                              e                c    y   y   y  y   e     e    e    e   n     n  n    n   t   t   d            e
//                                                                   w                h                   l     l    l    l   g     g  g    g   h   h   e
//                                                                                         w   w   h  r                       e     e  e    e           s
//                                                                                             2          w     h    r    t
//                                                                                                                            w     h  r    t
IEC_fused_inlet = ["IEC_fused_inlet", "IEC fused inlet JR-101-1F",   M3_cs_cap_screw, 36, 27, 16, 31, 3, 28,   31,   2, 2.0, 30,   33, 4, 3.0, 44, 15, fused_spades,  false ];
IEC_fused_inlet2= ["IEC_fused_inlet2","IEC fused inlet old",         M3_cs_cap_screw, 36, 27, 14, 31, 3, 28,   31,   2, 2.5, 30,   33, 4, 2.5, 44, 18, fused_spades2, false ];
IEC_320_C14_switched_fused_inlet = ["IEC_switched_fused_inlet", "IEC320 C14 switched fused inlet module",
                                                                     M3_cs_cap_screw, 40,  27, 16,46.8,3,28,   48, 2.4, 1.0, 33,   57, 4, 3.0, 48,16.5, iec320c14FusedSwitchedSpades,  false ];
IEC_inlet       = ["IEC_inlet",       "IEC inlet",                   M3_cs_cap_screw, 40, 28, 18, 20, 3, 28,   20.5, 4, 2.5, 37,   23, 1, 2.5, 48, 14, inlet_spades,  false ];
IEC_inlet_atx   = ["IEC_inlet_atx",   "IEC inlet for ATX",           M3_cs_cap_screw, 40, 27, 18, 19, 3, 30.5, 22,   2, 2.0, 30.5, 22, 2, 4.0, 50, 15, atx_spades,    false ];
IEC_outlet      = ["IEC_outlet",      "IEC outlet RS 811-7193",      M3_cs_cap_screw, 40, 32, 18, 24, 3, 28,   20.5, 2, 0.0, 29,   29, 2, 2.8, 50, 23, outlet_spades, true ];

iecs = [IEC_inlet, IEC_inlet_atx, IEC_fused_inlet, IEC_fused_inlet2, IEC_320_C14_switched_fused_inlet, IEC_outlet];
use <iec.scad>
