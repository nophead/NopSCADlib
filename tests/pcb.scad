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

test_pcb = ["TestPCB", "Test PCB",
    50, 480, 1.6, // length, width, thickness
    3,      // Corner radius
    2.75,   // Mounting hole diameter
    6,      // Pad around mounting hole
    "green",// Color
    false,  // True if the parts should be separate BOM items
    // hole offsets
    [ [3, 3], [3, -3], [-3, 3], [-3, -3] ],
    // components
    [
        [ 10,  10,  0, "2p54header", 3, 1],
        [ 25,  10,  0, "2p54header", 3, 1, undef, "blue" ],
        [ 10,  20,  0, "2p54boxhdr", 2, 1],
        [ 10,  30,  0, "2p54socket", 2, 1],
        [ 25,  30,  0, "2p54socket", 3, 1, undef, undef, undef, "red" ],
        [ 10,  40,  0, "chip", 5, 10, 1, grey20],
        [ 10,  60,  0, "rj45"],
        [ 10,  80,  0, "usb_A"],
        [ 10, 100,  0, "usb_Ax2"],
        [ 10, 120,  0, "usb_uA"],
        [ 10, 140,  0, "usb_B"],
        [ 10, 160,  0, "buzzer"],
        [ 10, 175,  0, "potentiometer"],
        [ 10, 190,  0, "jack"],
        [ 10, 200,  0, "barrel_jack"],
        [ 10, 220,  0, "hdmi"],
        [ 10, 240,  0, "mini_hdmi"],
        [ 10, 250,  0, "flex"],
        [ 10, 265,  0, "flat_flex"],
        [ 10, 280,  0, "D_plug", DCONN9],
        [ 10, 300,  0, "molex_hdr", 2],
        [ 10, 310,  0, "jst_xh", 2],
        [ 10, 320,  0, "term254", 3],
        [ 10, 340,  0, "gterm35", 4, [1,2]],
        [ 25, 340,  0, "gterm", gt_5x11, 3],
        [ 10, 360,  0, "gterm635", 2],
        [ 25, 360,  0, "gterm", gt_5x17, 2, undef, grey20],
        [ 40, 360,  0, "gterm", gt_5x17, 3, [1], "red"],
        [ 10, 380,  0, "term35", 4],
        [ 10, 400,  0, "transition", 5],
        [ 10, 410,  0, "block", 10, 5, 8, "orange"],
        [ 10, 420,  0, "button_6mm"],
        [ 10, 435,  0, "microswitch", small_microswitch],
        //[ 10, 440,  0, "pcb"],
        [ 10, 450,  0, "standoff",  5, 4.5, 12.5, 2.54],
        [ 10, 460,  0, "uSD", [12, 11.5, 1.4]],
    ],
    // accesories
    []
];


if($preview)
    pcb(test_pcb);

