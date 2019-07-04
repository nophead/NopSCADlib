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
Ethernet = ["Ethernet", "Duet Ethernet piggy back",
                                     33.8,  37.5,  1.6, 0,    2.54, 0, "#1D39AB",  false, [[27.1, -6.3], [7.5, -2.7], [21.3, -31.1]],
                                                                    [[10.7,  -13.1, 180, "rj45"],
                                                                     [7.75, -36.2,   0, "-2p54header", 6, 1],
                                                                     [7.75, -26.04,  0, "-2p54header", 6, 1],
                                                                     [27.1, -6.3,    0, "-standoff", 5, 4.5, 12.5, 2.54],
                                                                     [7.5, -2.70,    0, "-standoff", 5, 4.5, 12.5, 2.54],
                                                                     [21.3, -31.1,   0, "-standoff", 5, 4.5, 12.5, 2.54],
                                                                    ],
                                                                    []];
DuetE = ["DuetE", "Duet 2 Ethernet electronics",
                                     123,   100,   1.6, 0,    4.2,  0, "#2140BE",  false, [[-4, 4], [-4, -4], [4, -4],[4, 4]],
                                                                    [[ 18.5, -69.15, 0, "pcb", 5, Ethernet],
                                                                     [ 42.9, -3.2,   90, "molex_hdr", 4],
                                                                     [ 59.8, -3.2,   90, "molex_hdr", 4],
                                                                     [ 76.2, -3.2,   90, "molex_hdr", 4],
                                                                     [ 92.6, -3.2,   90, "molex_hdr", 4],
                                                                     [109.9, -3.2,   90, "molex_hdr", 4],
                                                                     [109.9, -9.6,   90, "molex_hdr", 4],

                                                                     [119.7, -31,     0, "molex_hdr", 3],
                                                                     [119.7, -88.6,   0, "molex_hdr", 2],

                                                                     [114.9, -75.1,   0, "gterm635",  2],
                                                                     [114.9, -43.5,   0, "gterm635",  2],

                                                                     [   39, -97,   -90, "molex_hdr", 4],
                                                                     [ 27.9, -97,   -90, "molex_hdr", 4],

                                                                     [ 83.7, -38.7, -90, "molex_hdr", 3],
                                                                     [ 74.3, -40.7, -90, "molex_hdr", 3],
                                                                     [ 64.0, -40.7, -90, "molex_hdr", 3],
                                                                     [ 54.0, -40.7, -90, "molex_hdr", 3],
                                                                     [ 44.1, -40.7, -90, "molex_hdr", 3],
                                                                     [ 35.0, -40.7, -90, "molex_hdr", 2],
                                                                     [ 28.9, -40.7, -90, "molex_hdr", 2],

                                                                     [103.0, -48.8, -90, "molex_hdr", 2],
                                                                     [ 97.0, -48.8, -90, "molex_hdr", 2],
                                                                     [ 90.3, -48.8, -90, "molex_hdr", 2],
                                                                     [ 84.1, -48.8, -90, "molex_hdr", 2],
                                                                     [ 77.9, -48.8, -90, "molex_hdr", 2],

                                                                     [105.2, -54.9,  0, "2p54header", 2, 1],
                                                                     [ 98.4, -54.9,  0, "2p54header", 2, 1],
                                                                     [ 90.2, -54.9,  0, "2p54header", 3, 1],
                                                                     [ 61.7, -83.1,  0, "2p54header", 5, 2],

                                                                     [ 29.5, -3.6,   90, "gterm35", 4],

                                                                     [ 45.0, -70.8,  45, "chip", 19, 19, 1.5],
                                                                     [ 34.6, -18.8,   0, "chip", 10, 10, 2],
                                                                     [ 53.2, -18.8,   0, "chip", 10, 10, 2],
                                                                     [ 71.8, -18.8,   0, "chip", 10, 10, 2],
                                                                     [ 90.4, -18.8,   0, "chip", 10, 10, 2],
                                                                     [109.9, -22.0,   0, "chip", 10, 10, 2],

                                                                     [105.8, -86.3,   0, "2p54boxhdr", 5, 2],
                                                                     [ 85.2, -86.3,   0, "2p54boxhdr", 5, 2],
                                                                     [ 79.9, -95.7, 180, "2p54boxhdr", 25, 2],

                                                                     [  2.0, -47.3, 180, "usb_uA"],
                                                                     [  8.4, -63.3, 180, "uSD", [15, 14.5, 2]],

                                                                     [  2.2,  -9.7,   0, "chip", inch(0.03), inch(0.06), 1, "red"],             // E1 heater
                                                                     [  2.2, -13.2,   0, "chip", inch(0.03), inch(0.06), 1, "red"],             // E0 heater
                                                                     [  2.2, -16.7,   0, "chip", inch(0.03), inch(0.06), 1, "blue"],            // Vin
                                                                     [  2.2, -20.2,   0, "chip", inch(0.03), inch(0.06), 1, "red"],             // 5V
                                                                     [  2.2, -24.0,   0, "chip", inch(0.03), inch(0.06), 1, "green"],           // 3.3V
                                                                     [  1.8, -41.8,  90, "chip", inch(0.03), inch(0.06), 1, "red"],             // USB
                                                                     [  2.3, -53.5,   0, "chip", inch(0.03), inch(0.06), 1, "red"],             // Diag
                                                                     [ 49.8,  -2.0,  90, "chip", inch(0.03), inch(0.06), 1, "red"],             // E1 stop
                                                                     [ 52.9,  -2.0,  90, "chip", inch(0.03), inch(0.06), 1, "red"],             // E0 stop
                                                                     [ 68.8,  -2.4,  90, "chip", inch(0.03), inch(0.06), 1, "red"],             // X stop
                                                                     [ 85.4,  -2.4,  90, "chip", inch(0.03), inch(0.06), 1, "red"],             // Y stop
                                                                     [101.6,  -1.8,  90, "chip", inch(0.03), inch(0.06), 1, "red"],             // Z stop
                                                                     [109.8, -58.8,   0, "chip", inch(0.03), inch(0.06), 1, "red"],             // Bed heater

                                                                     [ 2.3,  -37.2,   0, "chip", 3.6, 4.8, 2.0, "silver"],  // Reset switch
                                                                     [ 0.0,  -37.2,   0, "chip", 2.0, 2.6, 1.4, grey20],    // Reset button
                                                                    ],
                                                                    [": Micro SD card", ": Cat 5 patch cable 300mm"]];


Duex2 = ["Duex2", "Duex2 expansion board",
                                     123,   100,   1.6, 0,    4.2,  0, "#2140BE",  false, [[-4, 4], [-4, -4], [4, -4],[4, 4]],
                                                                   [ [ 79.8,  -4.3, 180, "2p54boxhdr", 25, 2],
                                                                     [ 27.8,  -3.0,   0, "2p54header", 10, 1],

                                                                     [ 45.7, -14.7,   0, "2p54header",  3, 1], // Endstop voltage select
                                                                     [ 34.8, -15.1,   0, "2p54header",  3, 2], // Fan voltage select
                                                                     [  4.8, -55.2,  90, "2p54header",  1, 2], // 12V EN
                                                                     [ 59.5, -30.3,   0, "2p54header",  3, 1], // 5V Aux select
                                                                     [ 31.6, -41.4,   0, "2p54header",  2, 5], // SPIO

                                                                     [  4.7, -11.8,  -90, "molex_hdr", 2], // Fan / LED 8
                                                                     [  4.9, -23.9,  -90, "molex_hdr", 2], // Fan / LED 7
                                                                     [ 12.0, -23.9,  -90, "molex_hdr", 2], // Fan / LED 6
                                                                     [ 19.7, -23.9,  -90, "molex_hdr", 2], // Fan / LED 5
                                                                     [ 27.3, -23.9,  -90, "molex_hdr", 2], // Fan / LED 4
                                                                     [ 34.9, -23.9,  -90, "molex_hdr", 2], // Fan / LED 3

                                                                     [ 44.3, -23.9,  -90, "molex_hdr", 3], // E6 stop
                                                                     [ 54.5, -23.9,  -90, "molex_hdr", 3], // E5 stop
                                                                     [ 64.6, -23.9,  -90, "molex_hdr", 3], // E4 stop
                                                                     [ 74.8, -23.9,  -90, "molex_hdr", 3], // E3 stop
                                                                     [ 84.9, -23.9,  -90, "molex_hdr", 3], // E2 stop

                                                                     [ 57.0, -46.8,  -90, "molex_hdr", 2], // E6 temp
                                                                     [ 64.6, -46.8,  -90, "molex_hdr", 2], // E5 temp
                                                                     [ 57.0, -36.6,  -90, "molex_hdr", 2], // E4 temp
                                                                     [ 64.6, -36.6,  -90, "molex_hdr", 2], // E3 temp
                                                                     [ 72.2, -36.6,  -90, "molex_hdr", 2], // E2 temp

                                                                     [ 26.5, -58.2,  -90, "molex_hdr", 3], // PWM_5
                                                                     [ 36.7, -58.2,  -90, "molex_hdr", 3], // PWM_4
                                                                     [ 46.8, -58.2,  -90, "molex_hdr", 3], // PWM_3
                                                                     [ 57.0, -58.2,  -90, "molex_hdr", 3], // PWM_2
                                                                     [ 67.2, -58.2,  -90, "molex_hdr", 3], // PWM_1

                                                                     [ 83.2, -18.3,   90, "chip", inch(0.03), inch(0.06), 1, "red"],             // E2 stop
                                                                     [ 74.5, -18.3,   90, "chip", inch(0.03), inch(0.06), 1, "red"],             // E3 stop
                                                                     [ 63.8, -18.7,   90, "chip", inch(0.03), inch(0.06), 1, "red"],             // E4 stop
                                                                     [ 54.7, -18.3,   90, "chip", inch(0.03), inch(0.06), 1, "red"],             // E5 stop
                                                                     [ 44.3, -18.4,   90, "chip", inch(0.03), inch(0.06), 1, "red"],             // E6 stop

                                                                     [112.4, -15.5,    0, "chip", inch(0.03), inch(0.06), 1, "red"],             // E2 heat
                                                                     [112.4, -22.9,    0, "chip", inch(0.03), inch(0.06), 1, "red"],             // E3 heat
                                                                     [112.4, -29.1,    0, "chip", inch(0.03), inch(0.06), 1, "red"],             // E4 heat
                                                                     [112.4, -36.1,    0, "chip", inch(0.03), inch(0.06), 1, "red"],             // E5 heat
                                                                     [112.4, -43.4,    0, "chip", inch(0.03), inch(0.06), 1, "red"],             // E6 heat

                                                                     [118.6, -30.3,   0, "gterm35",  10],   // Heaters
                                                                     [114.9, -56.5,   0, "gterm635",  2],   // VIN
                                                                     [119.6, -69.0,   0, "molex_hdr", 2],   // 5V AUX in
                                                                     [  4.5, -49.4,  90, "molex_hdr", 2],   // 12V

                                                                     [110.7, -81.2,   0, "chip", 10, 10, 2],
                                                                     [ 86.1, -81.2,   0, "chip", 10, 10, 2],

                                                                     [109.9, -96.8,  -90, "molex_hdr", 4],
                                                                     [ 86.1, -96.8,  -90, "molex_hdr", 4],



                                                                    ],
                                                                    []];

Duex5 = ["Duex5", "Duex5 expasnion board",
                                     123,   100,   1.6, 0,    4.2,  0, "#2140BE",  false, [[-4, 4], [-4, -4], [4, -4],[4, 4]],
                                                                   concat(Duex2[11], [
                                                                     [ 61.5, -81.2,   0, "chip", 10, 10, 2],
                                                                     [ 36.9, -81.2,   0, "chip", 10, 10, 2],
                                                                     [ 12.3, -81.2,   0, "chip", 10, 10, 2],

                                                                     [ 61.5, -96.4,  -90, "molex_hdr", 4],
                                                                     [ 36.9, -96.4,  -90, "molex_hdr", 4],
                                                                     [ 14.3, -96.4,  -90, "molex_hdr", 4],

                                                                    ]),
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
     [7.75,  28,  180, "-uSD", [12, 11.5, 1.28]],
    ],
    [": Micro SD card"]];

ArduinoUno3 = ["ArduinoUno3", "Arduino Uno R3", 68.58, 53.34, 1.6, 0, 3.3, 0, "#2140BE", false, [[15.24, 50.8],[66.04, 35.56],[66.04, 7.62],[13.97, 2.54]],
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

Keyes5p1 = ["Keyes5p1", "Keyes5.1 Arduino Uno expansion board", 68.58, 53.34, 1.6, 0, 3.3, 0, "#2140BE", false, [[15.24, 50.8],[66.04, 35.56],[66.04, 7.62],[13.97, 2.54]],
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

pcbs = [ExtruderPCB, PI_IO, RPI3, ArduinoUno3, Keyes5p1, PERF80x20, PERF70x50, PERF70x30, PERF60x40, PERF74x51, PSU12V1A, DuetE, Duex2, Duex5, Melzi];

use <pcb.scad>
