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
include <../vitamins/radials.scad>
include <../vitamins/smds.scad>
include <../vitamins/7_segments.scad>
include <../vitamins/potentiometers.scad>

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

test_pcb = ["test_pcb", "Test PCB",
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
        [ 20, -5,  180, "trimpot10"],
        [ 20, -18,  90, "trimpot10", true],
        [ 19,  2,   90, "smd_led", LED1206, "blue"],
        [ 16,  2,   90, "smd_led", LED0805, "red"],
        [ 13,  2,   90, "smd_led", LED0603, "orange"],
        [ 10,  2,  -90, "smd_res", L2012C, "1u"],
        [ 19,  6,  -90, "smd_res", RES1206, "1M"],
        [ 16,  6,  -90, "smd_res", RES0805, "1K"],
        [ 13,  6,  -90, "smd_res", RES0603, "100"],
        [ 10,  6,  -90, "smd_res", RES0502, "10"],
        [  7,  6,  -90, "smd_res", RES0402, "1"],
        [ 19, 10,   90, "smd_cap", CAP1206, 1.5, "1uF"],
        [ 16, 10,   90, "smd_cap", CAP0805, 1.0, "100nF"],
        [ 13, 10,   90, "smd_cap", CAP0603, 0.7, "10nF"],
        [ 10, 10,   90, "smd_cap", CAP0502, 0.6, "10nF"],
        [  7, 10,   90, "smd_cap", CAP0402, 0.5, "10nF"],
        [ 19, 16,  -90, "smd_tant", TANT_C, "107C"],
        [ 13, 16,  -90, "smd_tant", TANT_B, "106A"],
        [  7, 16,  -90, "smd_tant", TANT_A, "105e"],
        [ 32,  3,  -90, "smd_diode",DO214AC, "SS34"],
        [ 26,  2,  -90, "smd_pot", TC33X1, "10K"],
        [ 26,  6,  -90, "smd_coax",U_FL_R_SMT_1],
        [  8, 23,    0, "smd_250V_fuse", OMT250, "2A 250V"],

        [ 26, 10,  -90, "smd_sot", SOT23, "2N7000"],
        [ 28, 16,  -90, "smd_sot", SOT223, "LM117"],

        [ 30, 30,  -90, "smd_qfp", QFP50P1200X1200X160_64N, "ATSAM4S4BA"],

        [ 45,  35,   0, "2p54header", 4, 1],
        [ 60,  35,   0, "2p54header", 5, 1, false, "blue" ],
        [ 60,  40, 180, "2p54header", 5, 1, false, undef, true],
        [ 80,  33,   0, "2p54boxhdr", 4, 2],
        [ 80,  40,   0, "2p54boxhdr", 4, 2, false, true, true],
        [ 45,  30,   0, "2p54socket", 4, 1, false, 0, false, "red" ],
        [ 60,  30,   0, "2p54socket", 6, 1],

        [ 59,  60, 180, "led", LED3mm, "red"],
        [ 66,  60, 180, "led", LED5mm, "orange"],
        [ 77,  60, 180, "led", LED8mm, "blue"],
        [ 90,  60, 180, "led", LED10mm, "yellow"],
        [ 10,  35, 180, "rj45"],
        [  7,  50, 180, "usb_vAx1"],
        [  8,  65, 180, "usb_A"],
        [  8, 105, 180, "usb_Ax2"],
        [  7,  85, 180, "molex_usb_Ax1"],
        [ 8.5,125, 180, "molex_usb_Ax2"],
        [  3, 138, 180, "usb_uA"],
        [ 4.6,148, 180, "usb_miniA"],
        [ 3.7,158, 180, "usb_C"],
        [  8, 170, 180, "usb_B"],
        [  6, 184, 180, "uSD", [12, 11.5, 1.4]],
        [  8, 196, 180, "jack"],
        [  6, 206, 180, "barrel_jack"],
        [  5, 220, 180, "hdmi"],
        [  3, 235, 180, "mini_hdmi"],
        [ 38, 190, -90, "text", 25, 4, "Silkscreen", "Liberation Sans:style=Bold"],
        [ 25, 205,   0, "buzzer", 4.5, 8.5],
        [ 25, 220,   0, "buzzer"],

        [ 45,   1,   0, "link", inch(0.4), 0.75, undef, undef, [1.5, "red"]], // Sleeved link
        [ 45,   3,   0, "link", inch(0.4)], // Flat link
        [ 45,   6,   0, "ax_diode", DO_41, "1N4007"],
        [ 45,  10,   0, "ax_diode", DO_35, "1N4148"],
        [ 45,  14,   0, "ax_res", res1_8, 1000],
        [ 45,  18,   0, "ax_res", res1_4, 10000],
        [ 45,  22,   0, "ax_res", res1_2, 100000],
        [ 35,  22,   0, "vero_pin"],
        [ 35,  17,   0, "vero_pin", true],
        [ 35,   8, 180, "rd_transistor", TO92, "78L05", undef,  undef, "Regulator"],
        [ 35,  13, 180, "rd_transistor", E_LINE, "ZTX853"],
        [ 25, 190,   0, "rd_electrolytic", ECAP8x11, "220uF35V"],
        [ 25, 180,  90, "rd_disc",  ERZV07D471, "471"],
        [ 25, 170,  90, "rd_disc", 6p4mm_disc, "100n"],
        [ 30, 170,  90, "rd_disc", 10mm_disc, "1nF Y2"],
        [ 90, 135, -90, "rd_module", HF33F, "012-HSL-3F"],
        [ 35,   3,   0, "link", 0, 5], // Vertical wire

        [ 60,   3,   0, "link", inch(0.2), inch(0.4)], // Raised link
        [ 60,   6,   0, "ax_diode", DO_41, "1N4007", inch(0.1)],
        [ 60,  10,   0, "ax_diode", DO_35, "1N4148", inch(0.1)],

        [ 60,  14,   0, "ax_res", res1_8, 1000000, 1, inch(0.1)],
        [ 60,  18,   0, "ax_res", res1_4, 100,     2, inch(0.1)],
        [ 60,  22,   0, "ax_res", res1_2, 10,     10, inch(0.2)],

        [ 33,  110, -90, "rd_xtal", HC49,    "4MHz" ],
        [ 28,  110, -90, "rd_xtal", HC49_4H, "10MHz" ],
        [ 28,  102, -90, "rd_xtal", C_002RX, "60KHz", 3, inch(0.1) ],

        [ 30,  130,-90, "rd_xtal", ACT1100, "40MHz", 0.5 ],
        [ 30,  150,-90, "rd_xtal", ACT1700, "80MHz", 0.5 ],

        [ 93,  230,-90, "rd_box_cap", BOXC18x10x16, "X2 rated film capacitor", "0.47uF 250V" ],
        [ 93,  210,-90, "rd_box_cap", BOXC18x5x11,  "X2 rated film capacitor", "0.1uF 250V" ],

        [ 77,  15, -90, "flex"],
        [ 95,  15, -90, "flat_flex"],
        [ 87,  15, -90, "flat_flex", true],

        [ 47,  55,   0, "molex_hdr", 2],
        [ 51,  48,   0, "molex_hdr", 2, 1],
        [ 51,  41,   0, "molex_hdr", 2, -1],
        [ 45,  65,   0, "jst_xh", 2],
        [ 54,  65,   0, "jst_ph", 2],
        [ 61,  65,   0, "jst_zh", 2],

        [ 50,  75, 180, "term254", 3],
        [ 63,  75, 180, "term254", 3, undef, grey(20)],
        [ 75,  75, 180, "gterm508",2, undef, "blue"],

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
        [ 76, 210,   0, "pdip", 24, "27C32", true, inch(0.6) ],
        [ 80, 180,   0, "pdip", 8, "NE555" ],
        [ 71, 180,   0, "smd_inductor", IND2525, "4R7"],

        [ 87, 166, -90, "smd_soic", SOIC18, "PIC18F88"],
        [ 78, 166, -90, "smd_soic", SOIC14, "74HC00"],
        [ 71, 166, -90, "smd_soic", SOIC16, "ICL323"],
        [ 64, 166, -90, "smd_soic", SOIC8, "M34063"],
        [ 70, 150,   0, "chip", 10, 5, 1, grey(20)],

        [ 90, 140, -90, "relay", HF33F, "012-HSL-3F"],


        [ 52, 206,   0, "2p54socket", 8, 1 ],
        [ 52, 194,   0, "2p54socket", 8, 1, false, 0, false, "red" ],
        [ 55, 220,   0, "standoff",  5, 4.5, 12.5, 2.54],
        [ 60, 240,   0, "potentiometer"],
        [ 75, 240,   0, "potentiometer", KY_040_encoder, 8],
        [ 40, 235, -90, "rd_cm_choke", ATX_CM_CHOKE, "3.5mH"],
        [ 40, 217,   0, "rd_coil", IND16x10, "4.7uH"],
        [ 30,  85, -90, "7seg", WT5011BSR, 2],
        [ 30,  55, -90, "D_plug", DCONN9],
    ],
    // accessories
    []
];


if($preview)
    let($show_threads = true, $solder = pcb_solder(test_pcb))
        pcb(test_pcb);
