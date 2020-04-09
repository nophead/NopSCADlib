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

use <../vitamins/pcb.scad>

gt_5x17 = ["gt_5x17",    5,   10,   17, 5,   11, 0.4,  9,   2,1.5,     1,  3,   6,    0.5, 0,  0,   0];
gt_5x11 = ["gt_5x11",    5,    8,   11, 5,    7, 0.4,  7,   1.5,1.5,   1,2.5,   6,    0.5, 0,  0,   0];

TMC2130HeatSinkColor = "DeepSkyBlue";
TMC2130 = ["TMC2130", "TMC2130",
    20, 14, 1.6, 0, 3, 0, "white", false, [],
    [
        [  10,  1,  0, "-2p54header", 8, 1 ,undef, "blue" ],
        [  10, 13,  0, "-2p54header", 8, 1],
        [  12,  7,  0, "-chip", 6, 4, 1, grey20 ],
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
        [ 20, -15,  0, "trimpot10", true],

        [ 10,  10,   0, "2p54header", 4, 1],
        [ 25,  10,   0, "2p54header", 5, 1, undef, "blue" ],
        [ 10,  20,   0, "2p54boxhdr", 4, 2],
        [ 10,  30,   0, "2p54socket", 6, 1],
        [ 25,  30,   0, "2p54socket", 4, 1, undef, undef, undef, "red" ],
        [ 10,  40,   0, "chip", 10, 5, 1, grey20],
        [ 10,  60, 180, "rj45"],
        [  8,  80, 180, "usb_A"],
        [  8, 100, 180, "usb_Ax2"],
        [  3, 120, 180, "usb_uA"],
        [  8, 140, 180, "usb_B"],
        [ 10, 160,   0, "buzzer"],
        [ 25, 160,   0, "buzzer", 4.5, 8.5],
        [  8, 190, 180, "jack"],
        [  6, 200, 180, "barrel_jack"],
        [  5, 220, 180, "hdmi"],
        [  3, 235, 180, "mini_hdmi"],
        [  6, 175, 180, "uSD", [12, 11.5, 1.4]],

        [ 60,   3,   0, "flex"],
        [ 50,  15,   0, "flat_flex"],
        [ 60,  35,   0, "D_plug", DCONN9],

        [ 50,  50,   0, "molex_hdr", 2],
        [ 50,  60,   0, "jst_xh", 2],
        [ 50,  70, 180, "term254", 3],
        [ 60,  70, 180, "term254", 3, undef, grey20],
        [ 70,  70, 180, "gterm508",2, undef, "blue"],

        [ 50,  90, 180, "gterm35", 4, [1,2]],
        [ 63,  90, 180, "gterm35", 4, [1,2], "red"],
        [ 75,  90, 180, "gterm", gt_5x11, 3],
        [ 90,  90, 180, "gterm", gt_5x17, 3, [1], "red"],

        [ 55, 110, 180, "gterm635", 2],
        [ 75, 110, 180, "gterm635", 2, undef, "blue"],
        [ 90, 110, 180, "gterm", gt_5x17, 2, undef, grey20],

        [ 50, 130, 180, "term35", 4],
        [ 70, 130, 180, "term35", 3, "lime"],
        [ 60, 150,   0, "transition", 5],
        [ 60, 160,   0, "block", 10, 5, 8, "orange"],
        [ 60, 170,   0, "button_6mm"],
        [ 60, 185,   0, "microswitch", small_microswitch],
        [ 62, 200,   0, "pcb", 11, TMC2130 ],
        [ 62, 206,   0, "2p54socket", 8, 1 ],
        [ 62, 194,   0, "2p54socket", 8, 1, undef, undef, undef, "red" ],
        [ 60, 220,   0, "standoff",  5, 4.5, 12.5, 2.54],
        [ 60, 240,   0, "potentiometer"],
        [ 80, 240,   0, "potentiometer", 7, 8],
    ],
    // accessories
    []
];


if($preview)
    let($show_threads = true)
        pcb(test_pcb);
