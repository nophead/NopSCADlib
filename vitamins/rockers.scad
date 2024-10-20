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

micro_spades = [[spade3p5, 7.6, 0, 0,   0],
                [spade3p5, 7.6, 0, 5.1, 0]];

small_spades = [[spade4p8, 7.6, 0, 0,   0],
                [spade4p8, 7.6, 0, 7.1, 0]];

neon_spades  = [[spade4p8, 7.3, 0, -7, 0],
                [spade4p8, 7.3, 0,  7, 0]];

//
//                                   p                                 s   s      f     f   f    w     h     d     b    p    b
//                                   a                                 l   l      l     l   l    i     e     e     e    i    u
//                                   r                                 o   o      a     a   a    d     i     p     z    v    t
//                                   t                                 t   t      n     n   n    t     g     t     e    o    t
//                                                                                g     g   g    h     h     h     l    t    o
//                                                                     w   h      e     e   e          t                     n
//
//                                                                                w     h   t
//
micro_rocker   = ["micro_rocker",   "Rocker Switch 10x15",            8.8, 13.9,  10.5, 15, 1.5,  8.2, 14,   9.3,  2.0, 0.8, 3.0, micro_spades];
small_rocker   = ["small_rocker",   "Rocker Switch PRASA1-16F-BB0BW", 13,  19.25, 15,   21, 2,   12.8, 18.5, 11.8, 2.5, -1,  3.8, small_spades];
neon_indicator = ["neon_indicator", "Neon Indicator H8630FBNAL",      13,  19.25, 15,   21, 2,   12.8, 18.5, 12.5, 2.5, 0,   0.3, neon_spades];

rockers = [micro_rocker, small_rocker, neon_indicator];

use <rocker.scad>
