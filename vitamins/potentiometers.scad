//
// NopSCADlib Copyright Chris Palmer 2021
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
//! Potentiometers and rotary encoders
//                                    body     h     r     face               wafer                 gangs thread d  pitch       h     boss  h    spigot w, l, h  offset  shaft d flat d shaft h flat h colour neck   nut                  washer
imperial_pot_x2 = ["imperial_pot_x2", [24,     22.5, 1.5], [5.7, 15.33, 0.8], [20, 28, 1.6, true],  2,   inch(3/8), inch(1/32), 6.35, 13.6, 2.4, [1.12, 3.03, 2],    11, [6.27, 5.5, 44.3, 44.3, silver],   [0, 0],  [13.3, 2.4, brass],  [17.4, 0.8, grey(20), 9]];
imperial_pot    = ["imperial_pot",    [24,     12,   1.5], [5.7, 15.33, 0.8], [20, 28, 1.6, true],  1,   inch(3/8), inch(1/32), 6.35, 13.6, 2.4, [1.12, 3.03, 2],    11, [6.27, 5.5, 44.3, 44.3, grey(95)], [0, 0],  [13.3, 2.4, brass],  [17.4, 0.8, grey(20), 9]];
metric_pot      = ["metric_pot",      [23,     11,   1.0], [0, 15.33, 0.8],   [18, 27, 1.2, false], 1,   10,        0.75,       7.32, 13.9, 2.5, [1.12, 2.88, 1.26], 11, [6.27, 5.5, 43.8, 43.5, grey(50)], [0, 0],  [12.8, 2,   silver], [17.7, 0.8, grey(20), 10]];
KY_040_encoder  = ["KY_040_encoder",  [12, 12, 6.5,  1.0], false,             false,                1,    7,        0.75,       7,    0,    0,   [0.4,  2,     0.8],5.8, [6,    4.5, 13,   10,   grey(60)], [4, 0.5],[9.8,  2.2, silver], [11.5, 0.4, silver]];
BTT_encoder     = ["BTT_encoder",     [12, 11, 6,    0.5], false,             false,                1,    6,        0.8,        4.5,  0,    0,   false,               0, [5,    0.75, 9.5, 9,    silver],   [3, 0.5]];

potentiometers = [BTT_encoder, KY_040_encoder, metric_pot, imperial_pot, imperial_pot_x2];

use <potentiometer.scad>
