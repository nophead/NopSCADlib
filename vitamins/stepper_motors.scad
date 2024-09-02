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

//                                              corner  body    boss    boss          shaft               cap         thread black  end    shaft    shaft
//                                side, length, radius, radius, radius, depth, shaft, length,      holes, heights,    dia,   caps,  conn,  length2, bore
NEMA8_30      = ["NEMA8_30",        20, 30,       30/2, 20,    7.5,   1.6,     4,      6,          16,    [8,     8], 2,     true,  true,  0,       0];
NEMA8_30BH    = ["NEMA8_30BH",      20, 30,       30/2, 20,    7.5,   1.6,     5,     12,          16,    [8,     8], 2,     true,  true,  7,       2.8];
NEMA17_47     = ["NEMA17_47",     42.3, 47,     53.6/2, 25,     11,     2,     5,     24,          31,    [11.5,  9], 3,     false, false, 0,       0];
NEMA17_47L80  = ["NEMA17_47L80",  42.3, 47,     53.6/2, 25,     11,     2,     5,     80,          31,    [11.5,  9], 3,     false, true,  0,       0];
NEMA17_40     = ["NEMA17_40",     42.3, 40,     53.6/2, 25,     11,     2,     5,     20,          31,    [12.5, 11], 3,     false, false, 0,       0];
NEMA17_40L280 = ["NEMA17_40L280", 42.3, 40,     53.6/2, 25,     11,     2,     8,     [280, 8, 4], 31,    [12.5, 11], 3,     false, false, 0,       0];
NEMA17_34     = ["NEMA17_34",     42.3, 34,     53.6/2, 25,     11,     2,     5,     24,          31,    [8,     8], 3,     false, false, 0,       0];
NEMA17_27     = ["NEMA17_27",     42.3, 26.5,   53.6/2, 25,     11,     2,     5,     26.5,        31,    [10,    8], 3,     false, false, 0,       0];
NEMA16_19     = ["NEMA16_19",     39.5, 19.2,   50.6/2, 50.6/2, 11,     2,     5,     12,          31,    [8,     8], 3,     false, false, 0,       0];
NEMA14_36     = ["NEMA14_36",     35.2, 36,     46.4/2, 21,     11,     2,     5,     21,          26,    [8,     8], 3,     false, false, 0,       0];
NEMA23_51     = ["NEMA23_51",     56.4, 51.2,   75.7/2, 35,   38.1/2, 1.6,   6.35,    24,        47.1,    [8,     8], 3,     false, false, 0,       0];

stepper_motors = [NEMA8_30, NEMA8_30BH, NEMA14_36, NEMA16_19, NEMA17_27, NEMA17_34, NEMA17_40, NEMA17_47,NEMA17_47L80, NEMA23_51];
small_steppers = [];

use <stepper_motor.scad>
