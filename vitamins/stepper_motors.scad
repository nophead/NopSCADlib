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
// NEMA stepper motor model
//

//                                   corner  body    boss    boss          shaft
//                     side, length, radius, radius, radius, depth, shaft, length, holes
NEMA17  = ["NEMA17",   42.3, 47,     53.6/2, 25,     11,     2,     5,     24,     31 ];
NEMA17M = ["NEMA17M",  42.3, 40,     53.6/2, 25,     11,     2,     5,     20,     31 ];
NEMA17M8= ["NEMA17M8", 42.3, 40,     53.6/2, 25,     11,     2,     8,     280,    31 ];
NEMA17S = ["NEMA17S",  42.3, 34,     53.6/2, 25,     11,     2,     5,     24,     31 ];
NEMA16  = ["NEMA16",   39.5, 19.2,   50.6/2, 50.6/2, 11,     2,     5,     12,     31 ];
NEMA14  = ["NEMA14",   35.2, 36,     46.4/2, 21,     11,     2,     5,     21,     26 ];
NEMA23  = ["NEMA23",   56.4, 51.2,   75.7/2, 35,   38.1/2, 1.6,   6.35,  24,     47.1 ];

stepper_motors = [NEMA14, NEMA16, NEMA17S, NEMA17M, NEMA17, NEMA23];

use <stepper_motor.scad>
