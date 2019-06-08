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
//
//                                   l      w      t    r     h     l  c        b     h
//                                   e      i      h    a     o     a  o        o     o
//                                   n      d      i    d     l     n  l        m     l
//                                   g      t      c    i     e     d  o              e
//                                   t      h      k    u              u              s
//                                   h             n    s     d     d  r
//                                                 e
//                                                 s
//                                                 s
//
DuetW = ["DuetW", "Duet WiFi electronics",
                                     123,   100,   1.6, 0,    4.2,  0, "mediumblue",  false, [[119, 4], [119, 96], [4, 96],[4, 4]],
                                                                    [],
                                                                    []];

Melzi = ["Melzi", "Melzi electronics", 203.2, 49.53, 1.6, 3.81, 3.1,  6, "green", false, [[3.81,  3.81], [-3.81, 3.81], [-3.81, -3.81], [3.81, -3.81]],
                                                                    [],
                                                                    [": USB A to Mini B lead", ": Micro SD card"]];

RPI3 =  ["RPI3", "Raspberry Pi 3",     85,    56,    1.4, 3,    2.75, 6, "green", false, [[3.5, 3.5], [61.5, 3.5], [61.5, -3.5], [3.5, -3.5]],
    [[32.5, -3.5,   0, "2p54header", 20, 2],
     [27,   -24.6,  0, "chip",       14, 14, 1],
     [60,   -22.3,  0, "chip",       9, 9, 0.6],
     [-8.5,  10.25, 0, "rj45"],
     [-6.5,  29,    0, "usb_Ax2"],
     [-6.5,  47,    0, "usb_Ax2"],
     [53.5,   6,  -90, "jack"],
     [32,   4.4,  -90, "hdmi"],
     [10.6,   2,  -90, "usb_uA"],
     [3.6,   28,   90, "flex"],
     [45,    11.5,-90, "flex"],
    ],
    [": Micro SD card"]];

ArduinoUno3 = ["ArduinoUno3", "Arduino Uno R3", 68.58, 53.34, 1.6, 0, 3.3, 0, "mediumblue", false, [[15.24, 50.8],[66.04, 35.56],[66.04, 7.62],[13.97, 2.54]],
    [[30.226, -2.54, 0, "2p54socket", 10, 1],
     [54.61,  -2.54, 0, "2p54socket", 8, 1],
     [36.83,   2.54, 0, "2p54socket", 8, 1],
     [57.15,   2.54, 0, "2p54socket", 6, 1],
     [64.91,  27.89, 0, "2p54header", 2, 3],
     [18.796, -7.00, 0, "2p54header", 3, 2],
     [ 6.5,   -3.5,  0, "button_6mm"],
     [4.7625,  7.62, 180, "barrel_jack"],
     [1.5875, 37.7825,180,"usb_B"],
    ],
    [],[],
    inch([
     [-1.35, -1.05],
     [-1.35,  1.05],
     [ 1.19,  1.05],
     [ 1.25,  0.99],
     [ 1.25,  0.54],
     [ 1.35,  0.44],
     [ 1.35, -0.85],
     [ 1.25, -0.95],
     [ 1.25, -1.05],
    ]),
    M2p5_pan_screw
   ];

Keyes5p1 = ["Keyes5p1", "Keyes5.1 Arduino Uno expansion board", 68.58, 53.34, 1.6, 0, 3.3, 0, "mediumblue", false, [[15.24, 50.8],[66.04, 35.56],[66.04, 7.62],[13.97, 2.54]],
    [[30.226, -2.54, 0, "-2p54header", 10, 1],
     [54.61,  -2.54, 0, "-2p54header", 8, 1],
     [36.83,   2.54, 0, "-2p54header", 8, 1],
     [57.15,   2.54, 0, "-2p54header", 6, 1],
    ],
    [],[],
    inch([
     [-1.35, -1.05],
     [-1.35,  1.05],
     [ 1.19,  1.05],
     [ 1.25,  0.99],
     [ 1.25,  0.54],
     [ 1.35,  0.44],
     [ 1.35, -0.85],
     [ 1.25, -0.95],
     [ 1.25, -1.05],
    ]),
    M2p5_pan_screw
   ];


ExtruderPCB = ["ExtruderPCB", "Extruder connection PCB",
                                    33.02, 24.13, 1.6, 0,   0,   0, "green", true, [],
    [[3 * 1.27, 24.13 / 2, 90, "D_plug", DCONN15],
     [-(8.89 + 2.75 * 2.54),  2.5 * 1.27 + 24.13 / 2,  90, "molex_hdr", 3],
     [-(8.89 - 1.5  * 2.54), -3.5 * 1.27 + 24.13 / 2, -90, "molex_hdr", 2],
     [-(8.89 -        2.54),  2.5 * 1.27 + 24.13 / 2,  90, "term254",   4],
     [-(8.89 + 2    * 2.54), -3.5 * 1.27 + 24.13 / 2, -90, "term254",   4],
    ], []];

PI_IO = ["PI_IO", "PI_IO V2",       35.56, 25.4, 1.6, 0,    0,   0, "green", true, [],
    [[(3.015 - 2.7) * 25.4 - 3.5 /2, (4.5 - 3.685) * 25.4, 90, "term35", 2],
     [(3.46  - 2.7) * 25.4 - 3.5 /2, (4.5 - 3.69)  * 25.4, 90, "term35", 2],
     [(3.91  - 2.7) * 25.4 - 3.5 /2, (4.5 - 3.69)  * 25.4, 90, "term35", 2],
     [(3.4   - 2.7) * 25.4,          (4.5 - 4.15)  * 25.4,  0, "2p54socket", 13, 2, true],
    ], []];

PERF80x20 = ["PERF80x20", "Perfboard 80 x 20mm", 80, 20, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF70x50 = ["PERF70x50", "Perfboard 70 x 50mm", 70, 50, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF70x30 = ["PERF70x30", "Perfboard 70 x 30mm", 70, 30, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF60x40 = ["PERF60x40", "Perfboard 60 x 40mm", 60, 40, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF74x51 = ["PERF74x51", "Perfboard 74 x 51mm", 74, 51, 1.0, 0, 3.0, 0, "sienna", true, [[3.0, 3.5], [-3.0, 3.5], [3.0, -3.5], [-3.0, -3.5]], [], [], [9.5, 4.5]];

PSU12V1A = ["PSU12V1A", "PSU 12V 1A", 67, 31, 1.7, 0, 3.9, 0, "green", true, [[3.5, 3.5], [-3.5, 3.5], [-3.5, -3.5], [3.5, -3.5]], [], []];

pcbs = [ExtruderPCB, PI_IO, RPI3, ArduinoUno3, Keyes5p1, PERF80x20, PERF70x50, PERF70x30, PERF60x40, PERF74x51, PSU12V1A, DuetW, Melzi];

use <pcb.scad>
