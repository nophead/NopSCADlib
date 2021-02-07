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
include <microswitches.scad>
include <d_connectors.scad>
include <leds.scad>
include <axials.scad>
include <smds.scad>
include <green_terminals.scad>

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
                                                                     [ 0.0,  -37.2,   0, "chip", 2.0, 2.6, 1.4, grey(20)],    // Reset button
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

Duex5 = ["Duex5", "Duex5 expansion board",
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

BTT_SKR_MINI_E3_V2_0 = [
    "BTT_SKR_MINI_E3_V2_0", "BigTreeTech SKR Mini E3 v2.0",
    100.75, 70.25, 1.6, // size
    1, // corner radius
    3, // mounting hole diameter
    5, // pad around mounting hole
    grey(30), // color
    false, // true if parts should be separate BOM items
    [ // hole positions
        for (i = [ [0, 0], [62.15, 0] ])
            (i + [20.3, -2.89]),
        for (i = [ [0, -34.98], [31.80, -37.63], [95.68, -64.47] ])
            (i + [2.535, -2.89])
    ],
    [ // components
        // cpu
        [ 55,   33,     0, "chip", 10, 10,   1,   grey(15) ],
        // driver chips
        for (x = [10.5, 30.5, 50.5, 70.5])
            [ x, -17.5,  0, "chip",  5,  5, 1, grey(15) ],
        // mock up heat sinks over the chips
        for (x = [10.5, 30.5, 50.5, 70.5])
            [ x, -17.5,  0, "block",  9, 8.5,  2, "DeepSkyBlue" ],
        for(x = [10.5, 30.5, 50.5, 70.5], y = [-4,-2,0,2,4])
            [ x, -17.5 + y,  0, "block",  9, 0.75, 11, "DeepSkyBlue" ],
        // heat dissipation for drivers under board
        [ 43,  -17.5,   0, "-block", 85, 8, 0.1, gold ],

        // heated bed
        [ 26,   16,     0, "chip",    9.5, 8.5, 4,   grey(15) ],
        [ 27,   19,     0, "-block", 13,  14,   0.1, gold ],
        // hotend
        [ 37,   14,     0, "chip",    6,   6,   2.5, grey(15) ],
        [ 40,   16,     0, "-block", 10,   8,   0.1, gold ],

        // voltage regulator heat dissipation
        [ 12,   28.5,   0, "-block", 11,   7,   0.1, gold ],

        // terminals
        [  5.25, 5.3, 180, "gterm", gt_5x17, 2, undef, grey(20) ],
        [ 18.1,  5.1, -90, "gterm", gt_5x17, 2, undef, grey(20) ],
        [ 29.3,  5.1, -90, "gterm", gt_5x17, 2, undef, grey(20) ],
        [ 40.5,  5.1, -90, "gterm", gt_5x11, 2, undef, grey(20) ],
        // SD and USB
        [  -3, -(22.27 + 29.92)/2, 0, "usb_uA" ],
        [  -8, -( 2.13 + 17.17)/2, 0, "uSD", [17.17 - 2.13, 16, 2] ],
        // EXP
        [  -4.5, 17,   -90, "2p54boxhdr", 5, 2 ],
        // TFT
        [  66.1,  21.7,  0, "2p54header", 5, 1 ],
        // FAN0
        [  50.25,  3.8,  0, "jst_xh", 2, false, grey(20) ],
        // FAN1
        [  49.9,  16.1,  0, "jst_xh", 2, false, grey(20) ],
        // PS-ON
        [  58.1,  16.1,  0, "jst_xh", 2, false, grey(20) ],
        // PWR-DET
        [  67.5,  16.0,  0, "jst_xh", 3, false, grey(20) ],
        // E0-STOP
        [  78.2,  16.0,  0, "jst_xh", 3, false, grey(20) ],
        // Z-PROBE
        [  87.2,  20.5, -90,"jst_xh", 5, false, grey(20) ],
        // NEO Pixel
        [  78.2,  27.1,  0, "jst_xh", 3, false, grey(20) ],
        // end stops
        [  58.60,  3.8,  0, "jst_xh", 2, false, grey(20) ],
        [  66.70,  3.8,  0, "jst_xh", 2, false, grey(20) ],
        [  74.90,  3.8,  0, "jst_xh", 2, false, grey(20) ],
        // thermistors
        [  83.00,  3.8,  0, "jst_xh", 2, false, grey(20) ],
        [  91.10,  3.8,  0, "jst_xh", 2, false, grey(20) ],
        // motor connections
        [  10.15, -4.2,  0, "jst_xh", 4, false, grey(20) ],
        [  30.35, -4.2,  0, "jst_xh", 4, false, grey(20) ],
        [  43.90, -4.2,  0, "jst_xh", 4, false, grey(20) ],
        [  57.25, -4.2,  0, "jst_xh", 4, false, grey(20) ],
        [  70.75, -4.2,  0, "jst_xh", 4, false, grey(20) ],
        // motor jumpers
        [  20.6,  44.1,  0, "2p54header", 2, 1 ],
        [  39.6,  44.2,  0, "2p54header", 2, 1 ],
        [  60.1,  44.1,  0, "2p54header", 2, 1 ],
        [  80.3,  44.1,  0, "2p54header", 2, 1 ],
        // SWD
        [  43.9,  39.2,  0, "2p54header", 1, 5 ],
        // SPI
        [  -3.1,  31.9,  0, "2p54header", 2, 3 ],
        // PWR-1
        [  -12.8, 30.3,  0, "2p54header", 3, 1 ],
        // VOUT
        [  -14.0, 34.4,  0, "2p54header", 2, 2 ],
        // VIN
        [  17.3,  19.6,  0, "2p54header", 2, 2 ],
    ],
    [] // accessories
];

BTT_SKR_E3_TURBO = [
    "BTT_SKR_E3_TURBO", "BigTreeTech SKR E3 Turbo",
    102, 90.25, 1.6, // size
    1, // corner radius
    3.5, // mounting hole diameter
    5, // pad around mounting hole
    grey(30), // color
    false, // true if parts should be separate BOM items
    [ // hole positions
        for ( i=[ [0, 0], [62.15, 0.25] ])
            (i + [21.6, -13.3]),
        for( i=[ [0, -34.98 ], [31.80, -37.62 ], [95.68, -64.47] ])
            (i + [3.75, -13.25])
    ],
    [ // components
        // cpu
        [  62.8,   42.5,   0, "chip", 14, 14,   1,   grey(15) ],
        // driver chips
        for (x = [8.5, 27.5, 43.2, 58.5, 74])
            [x, -20, 0, "chip",  5,  5, 1, grey(15)],
        // mock up heat sinks over the chips
        for (x = [8.5, 27.5, 43.2, 58.5, 74])
            [x, -20,  0, "chip",  9, 8.5,  2, "DeepSkyBlue" ],
        for (x = [8.5, 27.5, 43.2, 58.5, 74], y = [-4,-2,0,2,4])
            [x, -20 + y,  0, "chip",  9, 0.75, 11, "DeepSkyBlue" ],
        // heat dissipation for drivers under board
        [ 43,     -21,     0, "-block", 85,   8,   0.1, gold ],
        // hotend and heated bed
        [ 25.5,    20,     0, "chip",   10,   8.5, 4,   grey(15) ],
        [ 25.5,    20,     0, "-block", 11,   11,  0.1, gold ],
        [ 36.25,   16.75,  0, "chip",    6.5, 6,   2.5, grey(15) ],
        [ 36.25,   17,     0, "-block",  7.5, 7.5, 0.1, gold ],
        [ 44.25,   16.75,  0, "chip",    6.5, 6,   2.5, grey(15) ],
        [ 44.25,   17,     0, "-block",  7.5, 7.5, 0.1, gold ],
        // voltage regulator
        [ 15.1,    44.2,   0, "chip",    4,   5,   2,   grey(15) ],
        [ 12.1,    44.2,   0, "-block", 10,  10,   0.1, gold ],

        // terminals
        [   5.25,  5.3, 180, "gterm", gt_5x17, 2, undef, grey(20) ],
        [  16.25,  5.4, -90, "gterm", gt_5x17, 2, undef, grey(20) ],
        [  26.25,  5.4, -90, "gterm", gt_5x17, 2, undef, grey(20) ],
        [  36.1,   6.7, -90, "gterm", gt_5x11, 2, undef, "lightgreen" ],
        [  45.0,   6.7, -90, "gterm", gt_5x11, 2, undef, "lightgreen" ],
        [  -3, -(32.27 + 39.92)/2, 0, "usb_uA" ],
        [  -8, -(12.13 + 27.17)/2, 0, "uSD", [17.17 - 2.13, 16, 2] ],
        [ -22.2,   51.6,   0, "button_6mm" ],
        // EXP
        [  -4.45,  27.2, -90, "2p54boxhdr", 5, 2 ],
        // AUX-2
        [  -3.4,   42.5, -90, "2p54header", 4, 2 ],
        // TFT
        [  73.7,   21,     0, "2p54header", 5, 1 ],
        // FAN0
        [  52.1,   15.3, 180, "jst_xh", 2, false, grey(20) ],
        // FAN1
        [  60.1,  15.3,  180, "jst_xh", 2, false, grey(20) ],
        // PS-ON
        [  67.9,  15.3,  180, "jst_xh", 2, false, grey(20) ],
        // E0-STOP
        [  77.1,  15.3,  180, "jst_xh", 3, false, grey(20) ],
        // E1-STOP
        [  87.5,  15.3,  180, "jst_xh", 3, false, grey(20) ],
        // Z-PROBE
        [  85.05,  34.6, 180, "jst_xh", 5, false, grey(20) ],
        // NEO Pixel
        [  77,     26.8, 180, "jst_xh", 3, false, grey(20) ],
        // PWR-DET
        [  87.7,   26.8, 180, "jst_xh", 3, false, grey(20) ],
        // FAN2
        [  52.1,    3.8,   0, "2p54header", 1, 2],
        // end stops and thermistors
        for (x = [58.5 : 7.9 : 98.1])
            [x,  3.7,  180, "jst_xh", 2, false, grey(20)],
        // motor connections
        for (x = [7, 27.1, 47.3, 67.5, 87.9])
            [x, -3.9,  0, "jst_xh", 4, false, grey(20)],
        [47.3, -10.4,  0, "jst_xh", 4, false, grey(20)], // second Z connector
        // motor jumpers
        for (x = [9.4, 26.4, 42.5, 58.7, 75.3])
            [x, -33.7,  0, "2p54header", 2, 1],
        // SWD
        [  45.4,   35.7,   0, "2p54header", 5, 1 ],
        // USB power jumber
        [ -12.6,   40.3,   0, "2p54header", 3, 1 ],
        // VOUT
        [ -13.9,   44.5,   0, "2p54header", 2, 2 ],
        // VIN
        [  18.6,   29.8,   0, "2p54header", 2, 2 ],
    ],
    [] // accessories
];

TMC2130 = [
    "TMC2130", "TMC2130",
    20, 14, 1.6, // size
    0, 0, 0, // corner radius, mounting hole diameter, pad around mounting hole
    grey(95), // colour
    false, // true if parts should be separate BOM items
    [], // hole positions
    [
        [  10,  1,  0, "-2p54header", 8, 1 ],
        [  10, 13,  0, "-2p54header", 8, 1 ],
        [  12,  7,  0, "-chip", 6, 4, 1, grey(20) ],
        // mock up a heat sink
        [  10,  7,  0, "block", 9, 8.5, 2, "DeepSkyBlue" ],
        for (y = [-4,-2,0,2,4]) [ 10, 7 + y,  0, "block", 9, 0.75, 11, "DeepSkyBlue" ],
    ],
    []
];

BTT_SKR_V1_4_TURBO = [
    "BTT_SKR_V1_4_TURBO", "BigTreeTech SKR v1.4 Turbo",
    110, 85, 1.6, // size
    1, // corner radius
    3, // mounting hole diameter
    4, // pad around mounting hole
    grey(30), // colour
    false, // true if parts should be separate BOM items
    [ // hole positions
        [-4, 4], [-4, -4], [4, -4], [4, 4]
    ],
    [ // components
        [  (29.15+31.5)/2,  8, -90, "usb_B" ],
        [  (46.9+51.55)/2,  7, -90, "uSD", [14, 14, 2] ],
        [ 105,   13,     0, "button_6mm" ],
        [  58,   43,     0, "chip", 15, 15, 1, grey(20) ],
        // ESP-01 socket
        [  69.8,  4,     0, "2p54socket", 4, 2 ],
        // terminals
        [   5.3, 13.2, 180, "gterm", gt_5x17, 2, undef, grey(20)],
        [   5.3, 25.8, 180, "gterm", gt_5x17, 2, undef, grey(20)],
        [   5.3, 37.2, 180, "gterm", gt_5x11, 2, undef, grey(20)],
        [   5.3, 47.2, 180, "gterm", gt_5x11, 2, undef, grey(20)],

        [   2.8, 56.7, -90, "jst_xh", 2, false, grey(20) ],
        [  10.9, 56.7,  90, "jst_xh", 2, false, grey(20) ],
        [  82,    4,     0, "jst_xh", 2, false, grey(20) ],
        [  90,    4,     0, "jst_xh", 2, false, grey(20) ],
        [  98,    4,     0, "jst_xh", 2, false, grey(20) ],

        [  87.7, 29.0, -90, "jst_xh", 3, false, grey(20) ],
        [  87.7, 39.5, -90, "jst_xh", 3, false, grey(20) ],
        [  87.7, 50.1, -90, "jst_xh", 3, false, grey(20) ],
        [  95.3, 29.0, -90, "jst_xh", 3, false, grey(20) ],
        [  95.3, 39.5, -90, "jst_xh", 3, false, grey(20) ],
        [  95.3, 50.1, -90, "jst_xh", 3, false, grey(20) ],

        [  85.7, 18.2, 180, "jst_xh", 3, false, grey(20) ],
        [  94.9, 18.2, 180, "jst_xh", 2, false, grey(20) ],
        [  77.2, 19.6, -90, "jst_xh", 3, false, grey(20) ],
        [  69.8, 11.0,   0, "jst_xh", 5, false, grey(20) ],

        [  69.0, 19.2,   0,  "2p54header", 4, 1 ],
        [  57.8, 18.0,   0,  "2p54header", 3, 2 ],
        [  28.0, 19.7,   0,  "2p54header", 2, 2 ],

        [  37.6, 28.8,   0,  "2p54header", 1, 3, undef, "red" ],
        [  77.8, 27.5,   0,  "2p54header", 2, 2 ],
        [  81.8, 26.4,   0,  "2p54header", 1, 3, undef, "red" ],
        [  43.8, 42.8,   0,  "2p54header", 1, 5 ],

        // EXP1 & EXP2
        [  -6.6, 29.4,  90, "2p54boxhdr", 5, 2 ],
        [  -6.6, 50.4,  90, "2p54boxhdr", 5, 2 ],

        // motor axes connections
        [  11.2, -3.75, 180, "jst_xh", 2, false, grey(20) ],
        [  21.8, -3.75, 180, "jst_xh", 4, false, grey(20) ],
        [  35.0, -3.75, 180, "jst_xh", 4, false, grey(20) ],
        [  48.2, -3.75, 180, "jst_xh", 4, false, grey(20) ],
        [  61.4, -3.75, 180, "jst_xh", 4, false, grey(20) ],
        [  74.7, -3.75, 180, "jst_xh", 4, false, grey(20) ],
        [  87.9, -3.75, 180, "jst_xh", 4, false, grey(20) ],
        [  98.5, -3.75, 180, "jst_xh", 2, false, grey(20) ],

        // stepper drivers
        [  11.5, 62.5,  0, "2p54socket", 8, 1, undef, undef, undef, "red" ],
        [  11.5, 75.2,  0, "2p54socket", 8, 1 ],
        [   2.6, 66.3, 90, "2p54socket", 2, 1, undef, undef, undef, "red" ],
        [  11.5, 68.85, 0, "pcb", 11, TMC2130 ],

        [  33.1, 62.5,  0, "2p54socket", 8, 1, undef, undef, undef, "red" ],
        [  33.1, 75.2,  0, "2p54socket", 8, 1 ],
        [  24.2, 66.3, 90, "2p54socket", 2, 1, undef, undef, undef, "red" ],
        [  33.1, 68.85, 0, "pcb", 11, TMC2130 ],

        [  54.8, 62.5,  0, "2p54socket", 8, 1, undef, undef, undef, "red" ],
        [  54.8, 75.2,  0, "2p54socket", 8, 1 ],
        [  45.9, 66.3, 90, "2p54socket", 2, 1, undef, undef, undef, "red" ],
        [  54.8, 68.85, 0, "pcb", 11, TMC2130 ],

        [  76.4, 62.5,  0, "2p54socket", 8, 1, undef, undef, undef, "red" ],
        [  76.4, 75.2,  0, "2p54socket", 8, 1 ],
        [  67.5, 66.3, 90, "2p54socket", 2, 1, undef, undef, undef, "red" ],
        [  76.4, 68.85, 0, "pcb", 11, TMC2130 ],

        [  98.1, 62.5,  0, "2p54socket", 8, 1, undef, undef, undef, "red" ],
        [  98.1, 75.2,  0, "2p54socket", 8, 1 ],
        [  89.2, 66.3, 90, "2p54socket", 2, 1, undef, undef, undef, "red" ],

        // closed loop pins
        [  24.4, 57.5,  0, "2p54header", 6, 1 ],
        [  40.6, 57.5,  0, "2p54header", 6, 1 ],
        [  56.7, 57.5,  0, "2p54header", 6, 1 ],
        [  72.9, 57.5,  0, "2p54header", 6, 1 ],
        [  89.1, 57.5,  0, "2p54header", 6, 1 ],
    ],
    [] // accessories
];

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
    [": Micro SD card"],
    [32.5 - 9.5 * 2.54, 52.5 - 1.27, 20, 2]];

RPI4 = ["RPI4", "Raspberry Pi 4", 85, 56, 1.4, 3, 2.75, 6, "green", false, [[3.5, 3.5], [61.5, 3.5], [61.5, -3.5], [3.5, -3.5]], [
    [32.5, -3.5, 0, "2p54header", 20, 2],
    [-6.5, 9, 0, "usb_Ax2"],
    [-6.5, 27, 0, "usb_Ax2"],
    [-8.5, 45.75, 0, "rj45"],

    [ 4, 28, 90, "flex"],
    [11.2, 3.675 - 1.6, -90, "usb_C"],
    [ 26,  2.5, -90, "micro_hdmi"],
    [39.5, 2.5, -90, "micro_hdmi"],
    [46.5, 11.5, -90, "flex"],
    [ 54, 6, -90, "jack"],

    [ 29.25, 32.5, 0, "chip", 14, 14, 2.4],
    [ 60, -22.3, 0, "chip", 9, 9, 0.6],
    [7.75, 28, 180, "-uSD", [12, 11.5, 1.28]]
    ], [": Micro SD card"], [32.5 - 9.5 * 2.54, 52.5 - 1.27, 20, 2]
];

RPI0 =  ["RPI0", "Raspberry Pi Zero",     65,    30,    1.4, 3,    2.75, 6, "green", false, [[3.5, 3.5], [-3.5, 3.5], [-3.5, -3.5], [3.5, -3.5]],
    [//[32.5, -3.5,   0, "2p54header", 20, 2],
     [25.5,  13,      0, "chip",       12, 12, 1.2],
     [12.4,  3.4,   -90, "mini_hdmi"],
     [54,    2,     -90, "usb_uA"],
     [41.4,  2,     -90, "usb_uA"],
     [7.25,  16.7,  180, "uSD", [12, 11.5, 1.4]],
     [-1.3,    15,  -90, "flat_flex"],
    ],
    [": Micro SD card"],
    [32.5 - 9.5 * 2.54, 26.5 - 1.27, 20, 2]];

EnviroPlus =  ["EnviroPlus", "Enviro+",     65,    30.6,    1.6, 3,    2.75, 6, "white", false, [[3.5, 3.8], [-3.5, 3.8], [-3.5, -3.8], [3.5, -3.8]],
    [[32.5, -3.8,   0, "-2p54socket", 20, 2, false, 5, true],
     [-15.5, 2.5,   0, "-chip", 15, 5, 3, "white"],
     [-14.25,16.25, 0, "chip", 27.5, 13.5, 1.5]
    ],
    [],
    [8, 1.5, 9, 1]];


ArduinoUno3 = ["ArduinoUno3", "Arduino Uno R3", 68.58, 53.34, 1.6, 0, 3.3, 0, "#2140BE", false, [[15.24, 50.8],[66.04, 35.56],[66.04, 7.62],[13.97, 2.54]],
    [[30.226, -2.54, 0, "2p54socket", 10, 1],
     [54.61,  -2.54, 0, "2p54socket", 8, 1],
     [36.83,   2.54, 0, "2p54socket", 8, 1],
     [57.15,   2.54, 0, "2p54socket", 6, 1],
     [64.91,  27.89, 0, "2p54header", 2, 3],
     [18.796, -7.00, 0, "2p54header", 3, 2],
     [ 6.5,   -3.5,  0, "button_6mm"],
     [4.7625,  7.62, 180,"barrel_jack"],
     [1.5875, 37.78, 180,"usb_B"],
     [46.99,  17,    270,"pdip", 28, "ATMEGA328", true],
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

ArduinoLeonardo = ["ArduinoLeonardo", "Arduino Leonardo", 68.58, 53.34, 1.6, 0, 3.3, 0, "#2140BE", false, [[15.24, 50.8],[66.04, 35.56],[66.04, 7.62],[13.97, 2.54]],
    [[30.226, -2.54, 0, "2p54socket", 10, 1],
     [54.61,  -2.54, 0, "2p54socket", 8, 1],
     [36.83,   2.54, 0, "2p54socket", 8, 1],
     [57.15,   2.54, 0, "2p54socket", 6, 1],
     [64.91,  27.89, 0, "2p54header", 2, 3],
     [ 6.5,   -3.5,  0, "button_6mm"],
     [4.7625,  7.62, 180, "barrel_jack"],
     [1.5875, 38.1,  180,"usb_uA"],
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

ZC_A0591 = ["ZC_A0591", "ZC-A0591 ULN2003 driver PCB", 35, 32, 1.6, 0, 2.5, 0, "green", false, [[2.25, 3.25], [-2.25, 3.25], [2.25, -3.25], [-2.25, -3.25] ],
    [ [ 11.725, 8.3,  -90, "jst_xh", 5],
      [ -6.5,  10,      0, "2p54header", 1, 4],
      [ 20.4,  -4.5,    0, "2p54header", 4, 1],
      [ 20.4,  11,  180, "pdip", 16, "ULN2803AN", true],
      [  5.5,  6,       0, "led", LED3mm, [1,1,1, 0.5]],
      [  5.5,  10.5,    0, "led", LED3mm, [1,1,1, 0.5]],
      [  5.5,  15,      0, "led", LED3mm, [1,1,1, 0.5]],
      [  5.5,  19.5,    0, "led", LED3mm, [1,1,1, 0.5]],
      for(i = [0 : 3]) [5.5 + inch(0.1) * i, -5.5, -90, "ax_res", res1_8, 510, 5, 5.5]

    ], [], [], [], M2p5_pan_screw];


MT3608 = ["MT3608", "MT3608 boost converter module",        37, 17, 1.2, 2, 1.5, [5, 3], "#2140BE", false, [[3.0725, 5.095], [3.0725, -5.095], [-3.0725, 5.095], [-3.0725, -5.095]],
    [ [-12.05 , -6.8, 180, "trimpot10"]
    ]];

TP4056 = ["TP4056", "TP4056 Li-lon Battery charger module", 26.2, 17.5, 1.0, 0, 1.0, [2.4, 2.4], "#2140BE", false,
    [[1.67, 1.8], [1.67, -1.8], [-1.67, 1.8], [-1.67, -1.8], [-1.67, -4.98], [-1.67, 4.98]],
    [ [  2, 17.5 / 2, 180, "usb_uA"],
      [  7, -2      ,   0, "smd_led", LED0805, "red"],
      [ 11, -2      ,   0, "smd_led", LED0805, "blue"],

    ]];

WD2002SJ = ["WD2002SJ", "WD2002SJ Buck Boost DC-DC converter", 78, 47, 1.6, 0, 3.2, 0, "#2140BE", false, [[4,4], [-4,4], [-4,-4], [4,-4]],
    [ [ 39,   -20.5,  0, "-chip", 63, 41, 3.4, "silver"],
      [ -4,    12,    0, "gterm508", 2, [], "blue"],
      [  4,    12,  180, "gterm508", 2, [], "blue"],
      [ -25.5, 3.1,   0, "trimpot10", true],
      [  30.5, 3.1,   0, "trimpot10", true],
      [  41.5, 3.1,   0, "trimpot10", true],
      [ -10.4, 1.4,   0, "smd_led", LED0805, "blue"],
      [  15.7, 2.7,   0, "smd_led", LED0805, "red"],
    ],
    []];

MP1584EN = ["MP1584EN", "MP1584EN 3A buck converter", 22, 17, 1.2, 0, 1, [2, 2], "green", false,
    [[1.75, 1.75], [1.75, -1.75], [-1.75, 1.75], [-1.75, -1.75], [-1.75, -4.4], [-1.75, 4.48], [1.75, -4.4], [1.75, 4.4]],
    []
];

PERF80x20 = ["PERF80x20", "Perfboard 80 x 20mm", 80, 20, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF70x50 = ["PERF70x50", "Perfboard 70 x 50mm", 70, 50, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF70x30 = ["PERF70x30", "Perfboard 70 x 30mm", 70, 30, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF60x40 = ["PERF60x40", "Perfboard 60 x 40mm", 60, 40, 1.6, 0, 2.3, 0, "green", true, [[2,2],[-2,2],[2,-2],[-2,-2]], [], [], [5.87, 3.49]];

PERF74x51 = ["PERF74x51", "Perfboard 74 x 51mm", 74, 51, 1.0, 0, 3.0, 0, "sienna", true, [[3.0, 3.5], [-3.0, 3.5], [3.0, -3.5], [-3.0, -3.5]], [], [], [9.5, 4.5]];

PSU12V1A = ["PSU12V1A", "PSU 12V 1A", 67, 31, 1.7, 0, 3.9, 0, "green", true, [[3.5, 3.5], [-3.5, 3.5], [-3.5, -3.5], [3.5, -3.5]], [], []];

RAMPSEndstop = ["RAMPSEndstop", "RAMPS Endstop Switch",
    40.0, 16.0, 1.6, 0.5, 2.54, 0, "red",  false,
    [
        [2, 2, false], [2, 13.5, false], [17, 13.5], [36, 13.5]
    ],
    [
        [ 11.6,  8,   -90, "jst_xh", 3, true, "white", "silver"],
        [ 26.5, 12.75,  0, "microswitch", small_microswitch],
        [ 27.5, 17.5,  15, "chip", 15, 0.5, 4.5, "silver"],
    ],
    []];

ESP_01 = [
    "ESP-01", "ESP-01",
    24.8, 14.6, 1, // size
    0, // corner radius
    0, // mounting hole diameter
    0, // pad around mounting hole
    grey(25), // color
    false, // true if parts should be separate BOM items
    [], // hole positions
    [ // components
        [   2.8,   -7.25, 0, "-2p54header", 2, 4 ],
        [ -14.55, -11.3,  0, "chip", 5.25, 5.25, 2.25, grey(15) ],
        [ -14,     -5.2,  0, "chip", 4.5,  4.75, 1.1,  grey(15) ],
        // antenna
        for (y = [ 2.8  : 2.3 : 7.4  ]) [ -0.7, -y,  0, "block", 0.7, 1.75, 0.1,  gold ],
        for (y = [ 4    : 2.3 : 10.6 ]) [ -4.3, -y,  0, "block", 0.7, 1.75, 0.1,  gold ],
        for (y = [ 3.4  : 2.3 : 10.1 ]) [ -2.5, -y,  0, "block", 4.3, 0.7,  0.1,  gold ],
        for (y = [ 4.55 : 2.3 : 11.2 ]) [ -2.5, -y,  0, "block", 4.3, 0.7,  0.1,  gold ],

        [ -0.7, -10.85,  0, "block", 0.7,3.75,  0.1,  gold ],
        [ -6.6,  -5.8,   0, "block", 0.7, 7.5,  0.1,  gold ],
        [ -4.8,  -2.3,   0, "block", 8.8, 0.7,  0.1,  gold ],
    ],
    [] // accessories
];

pcbs = [MP1584EN, TP4056, ESP_01, RAMPSEndstop, MT3608, PI_IO, ExtruderPCB, ZC_A0591, RPI0, EnviroPlus, ArduinoUno3, ArduinoLeonardo, WD2002SJ, RPI3, RPI4, BTT_SKR_MINI_E3_V2_0, BTT_SKR_E3_TURBO, BTT_SKR_V1_4_TURBO, DuetE, Duex5];

pcbs_not_shown = [Melzi, Duex2, PSU12V1A, Keyes5p1];

perfboards = [PERF74x51, PERF70x50, PERF60x40, PERF70x30, PERF80x20];

use <pcb.scad>
