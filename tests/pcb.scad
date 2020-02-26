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
include <../core.scad>

use <../vitamins/pcb.scad>
include <../vitamins/microswitches.scad>
include <../vitamins/d_connectors.scad>

gt_5x17 = ["gt_5x17",    5,   10,   17, 5,   11, 0.4,  9,   2,1.5,     1,  3,   6,     0,  0,   0];
gt_5x11 = ["gt_5x11",    5,    8,   11, 5,    7, 0.4,  7,   1.5,1.5,   1,2.5,   6,     0,  0,   0];

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
    50, 500, 1.6, // length, width, thickness
    3,      // Corner radius
    2.75,   // Mounting hole diameter
    6,      // Pad around mounting hole
    "green",// Color
    false,  // True if the parts should be separate BOM items
    // hole offsets
    [ [3, 3], [3, -3], [-3, 3], [-3, -3] ],
    // components
    [
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
        [ 10, 175,   0, "potentiometer"],
        [ 30, 175,   0, "potentiometer", 7, 8],
        [  8, 190, 180, "jack"],
        [  6, 200, 180, "barrel_jack"],
        [  5, 220, 180, "hdmi"],
        [  3, 240, 180, "mini_hdmi"],
        [ 10, 250,   0, "flex"],
        [ 10, 265,   0, "flat_flex"],
        [ 10, 280,   0, "D_plug", DCONN9],
        [ 10, 300,   0, "molex_hdr", 2],
        [ 10, 310,   0, "jst_xh", 2],
        [ 10, 320, 180, "term254", 3],
        [ 20, 320, 180, "term254", 3, undef, grey20],
        [ 10, 340, 180, "gterm35", 4, [1,2]],
        [ 20, 340, 180, "gterm35", 4, [1,2], "red"],
        [ 30, 340, 180, "gterm", gt_5x11, 3],
        [ 10, 360, 180, "gterm635", 2],
        [ 25, 360, 180, "gterm635", 2, undef, "blue"],
        [ 40, 360, 180, "gterm", gt_5x17, 2, undef, grey20],
        [ 40, 340, 180, "gterm", gt_5x17, 3, [1], "red"],
        [ 10, 380, 180, "term35", 4],
        [ 20, 380, 180, "term35", 3, "lime"],
        [ 10, 400,   0, "transition", 5],
        [ 10, 410,   0, "block", 10, 5, 8, "orange"],
        [ 10, 420,   0, "button_6mm"],
        [ 10, 435,   0, "microswitch", small_microswitch],
        [ 12, 450,   0, "pcb", 11, TMC2130 ],
        [ 12, 456,   0, "2p54socket", 8, 1 ],
        [ 12, 444,   0, "2p54socket", 8, 1, undef, undef, undef, "red" ],
        [ 10, 470,   0, "standoff",  5, 4.5, 12.5, 2.54],
        [  6, 480, 180, "uSD", [12, 11.5, 1.4]],
    ],
    // accessories
    []
];


if($preview)
    let($show_threads = true)
        pcb(test_pcb);

