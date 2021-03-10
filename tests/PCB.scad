//
// NopSCADlib Copyright Chris Palmer 2020
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
include <../core.scad>
include <../vitamins/microswitches.scad>
include <../vitamins/d_connectors.scad>
include <../vitamins/leds.scad>
include <../vitamins/axials.scad>
include <../vitamins/smds.scad>

use <../vitamins/pcb.scad>

gt_5x17 = ["gt_5x17",    5,   10,   17, 5,   11, 0.4,  9,   2,1.5,     1,  3,   6,    0.5, 0,  0,   0];
gt_5x11 = ["gt_5x11",    5,    8,   11, 5,    7, 0.4,  7,   1.5,1.5,   1,2.5,   6,    0.5, 0,  0,   0];

TMC2130HeatSinkColor = "DeepSkyBlue";
TMC2130 = ["TMC2130", "TMC2130",
    20, 14, 1.6, 0, 3, 0, "white", false, [],
    [
        [  10,  1,  0, "-2p54header", 8, 1 ,undef, "blue" ],
        [  10, 13,  0, "-2p54header", 8, 1],
        [  12,  7,  0, "-chip", 6, 4, 1, grey(20) ],
        // mock up a heat sink
        [  10,  7,  0, "block", 9, 9,  2, TMC2130HeatSinkColor ],
        [  10, 11,  0, "block", 9, 1, 11, TMC2130HeatSinkColor ],
        [  10,  9,  0, "block", 9, 1, 11, TMC2130HeatSinkColor ],
        [  10,  7,  0, "block", 9, 1, 11, TMC2130HeatSinkColor ],
        [  10,  5,  0, "block", 9, 1, 11, TMC2130HeatSinkColor ],
        [  10,  3,  0, "block", 9, 1, 11, TMC2130HeatSinkColor ],
    ],
    []
];

test_pcb = ["TestPCB", "Test PCB",
    100, 250, 1.6, // length, width, thickness
    3,      // Corner radius
    2.75,   // Mounting hole diameter
    5.5,    // Pad around mounting hole
    "green",// Color
    true,   // True if the parts should be separate BOM items
    // hole offsets
    [ [3, 3], [3, -3], [-3, 3], [-3, -3] ],
    // components
    [
        [ 20, -5, 180, "trimpot10"],
        [ 20, -15,  90, "trimpot10", true],
        [ 10,  2,   90, "smd_led", LED0805, "red"],
        [ 13,  2,   90, "smd_led", LED0603, "orange"],
        [ 16,  2,   90, "smd_res", RES1206, "1K"],
        [ 19,  2,   90, "smd_res", RES0805, "1K"],
        [ 22,  2,   90, "smd_res", RES0603, "1K"],
        [ 10,  10,   0, "2p54header", 4, 1],
        [ 25,  10,   0, "2p54header", 5, 1, false, "blue" ],
        [ 10,  20,   0, "2p54boxhdr", 4, 2],
        [ 10,  30,   0, "2p54socket", 6, 1],
        [ 25,  30,   0, "2p54socket", 4, 1, false, 0, false, "red" ],
        [ 10,  40,   0, "chip", 10, 5, 1, grey(20)],
        [  5,  50,   0, "led", LED3mm, "red"],
        [ 12,  50,   0, "led", LED5mm, "orange"],
        [ 25,  50,   0, "led", LED10mm, "yellow"],
        [ 10,  65, 180, "rj45"],
        [  8,  85, 180, "usb_A"],
        [  8, 105, 180, "usb_Ax2"],
        [  3, 140, 180, "usb_uA"],
        [  8, 155, 180, "usb_B"],
        [  8.5, 125, 180, "molex_usb_Ax2"],
        [ 25, 200,   0, "buzzer", 4.5, 8.5],
        [ 25, 218,   0, "buzzer"],
        [  8, 190, 180, "jack"],
        [  6, 200, 180, "barrel_jack"],
        [  5, 218, 180, "hdmi"],
        [  3, 235, 180, "mini_hdmi"],
        [  6, 175, 180, "uSD", [12, 11.5, 1.4]],

        [ 65,   9,   0, "link", inch(0.4)],
        [ 65,  12,   0, "ax_res", res1_8, 1000],
        [ 65,  17,   0, "ax_res", res1_4, 10000],
        [ 65,  22,   0, "ax_res", res1_2, 100000],

        [ 80,   9,   0, "link", inch(0.2), inch(0.4)],
        [ 80,  12,   0, "ax_res", res1_8, 1000000, 1, inch(0.1)],
        [ 80,  17,   0, "ax_res", res1_4, 100,     2, inch(0.1)],
        [ 80,  22,   0, "ax_res", res1_2, 10,     10, inch(0.2)],

        [ 60,   3,   0, "flex"],
        [ 50,  15, -90, "flat_flex"],
        [ 40,  15, -90, "flat_flex", true],
        [ 60,  35,   0, "D_plug", DCONN9],

        [ 50,  50,   0, "molex_hdr", 2],
        [ 50,  60,   0, "jst_xh", 2],
        [ 50,  70, 180, "term254", 3],
        [ 63,  70, 180, "term254", 3, undef, grey(20)],
        [ 75,  70, 180, "gterm508",2, undef, "blue"],

        [ 50,  90, 180, "gterm35", 4, [1,2]],
        [ 63,  90, 180, "gterm35", 4, [1,2], "red"],
        [ 75,  90, 180, "gterm", gt_5x11, 3],
        [ 90,  90, 180, "gterm", gt_5x17, 3, [1], "red"],

        [ 55, 110, 180, "gterm635", 2],
        [ 75, 110, 180, "gterm635", 2, undef, "blue"],
        [ 90, 110, 180, "gterm", gt_5x17, 2, undef, grey(20)],

        [ 50, 130, 180, "term35", 4],
        [ 70, 130, 180, "term35", 3, "lime"],
        [ 50, 150,   0, "transition", 5],
        [ 50, 160,   0, "block", 10, 5, 8, "orange"],
        [ 45, 170,   0, "button_6mm"],
        [ 55, 170,   0, "button_4p5mm"],
        [ 50, 185,   0, "microswitch", small_microswitch],
        [ 52, 200,   0, "pcb", 11, TMC2130 ],
        [ 80, 200,   0, "pdip", 24, "27C32", true, inch(0.6) ],
        [ 80, 170,   0, "pdip", 8, "NE555" ],
        [ 52, 206,   0, "2p54socket", 8, 1 ],
        [ 52, 194,   0, "2p54socket", 8, 1, false, 0, false, "red" ],
        [ 50, 220,   0, "standoff",  5, 4.5, 12.5, 2.54],
        [ 50, 240,   0, "potentiometer"],
        [ 75, 240,   0, "potentiometer", 7, 8],
    ],
    // accessories
    []
];


if($preview)
    let($show_threads = true)
        pcb(test_pcb);
