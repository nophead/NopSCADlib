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



test_pcb = ["TestPCB", "Test PCB",
    40, 420, 1.6, // length, width, thickness
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
        [ 20,  10,  0, "2p54header", 3, 1, undef, "blue" ],
        [ 10,  20,  0, "2p54boxhdr", 2, 1],
        [ 10,  30,  0, "2p54socket", 2, 1],
        [ 20,  30,  0, "2p54socket", 3, 1, undef, undef, undef, "red" ],
        [ 10,  40,  0, "chip", 5, 10, 1, grey20],             // E2 stop
        [ 10,  60,  0, "rj45"],
        [ 10,  80,  0, "usb_Ax2"],
        [ 10, 100,  0, "usb_uA"],
        [ 10, 120,  0, "usb_B"],
        [ 10, 140,  0, "buzzer"],
        [ 10, 155,  0, "jack"],
        [ 10, 165,  0, "barrel_jack"],
        [ 10, 180,  0, "hdmi"],
        [ 10, 200,  0, "mini_hdmi"],
        [ 10, 210,  0, "flex"],
        [ 10, 225,  0, "flat_flex"],
        [ 10, 240,  0, "D_plug", DCONN9],
        [ 10, 255,  0, "molex_hdr", 2],
        [ 10, 265,  0, "jst_xh", 2],
        [ 10, 275,  0, "term254", 3],
        [ 10, 290,  0, "gterm35", 4],
        [ 10, 310,  0, "gterm635", 2],
        [ 10, 330,  0, "term35", 4],
        [ 10, 345,  0, "transition", 5],
        [ 10, 355,  0, "block", 10,5, 8],
        [ 10, 365,  0, "button_6mm"],
        [ 10, 375,  0, "microswitch", small_microswitch],
        //[ 10, 360,  0, "pcb"],
        [ 10, 390,  0, "standoff",  5, 4.5, 12.5, 2.54],
        [ 10, 400,  0, "uSD", [12, 11.5, 1.4]],
    ],
    // accesories
    []
];


if($preview)
    pcb(test_pcb);
