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
include <smds.scad>

rpi_camera_v1_pcb = ["", "",  25, 24, 1, 0, 2.1, 0, "green", false, [[2, -2], [-2, -2], [2, 9.6], [-2, 9.6]],
    [
        [12,   3.25,  0, "-flat_flex", true],
        [-4.5, -5,    0, "smd_led", LED0603, "red"],
        [-5.5, -4,    0, "smd_res", RES0603, "1K2"],
    ],
    []];

rpi_camera_v1 = ["rpi_camera_v1", "Raspberry Pi camera V1", rpi_camera_v1_pcb, [0, 9.6 - 12],
    [
        [[8, 8, 3], 0],
        [[0, 0, 4], 7.5 / 2],
        [[0, 0, 5], 5.5 / 2, [1.5/2, 2/2, 0.5]],
    ],
    [0, 12 - 1.5 - 2.5], [8, 5, 1],
    [54, 41] // FOV
];

rpi_camera_v2_pcb = ["", "",  25, 23.862, 1, 2, 2.2, 0, "green", false, [[2, -2], [-2, -2], [2, -14.5], [-2, -14.5]],
    [
        [12.5,   2.75,  0, "-flat_flex", true],
    ],
    []];

rpi_camera_v2 = ["rpi_camera_v2", "Raspberry Pi camera V2", rpi_camera_v2_pcb, [0, 9.6 - 12],
    [
        [[8.5, 8.5, 3], 0],
        [[0, 0, 4], 7.5 / 2],
        [[0, 0, 5], 5.5 / 2, [1.5/2, 2/2, 0.5]],
    ],
    [-13.8 + 12.5, 23.862 / 2 - 4.7], [8.5, 4, 1],
    [62.2, 48.8] // FOV
];

rpi_camera_pcb = ["", "",  36, 36, 1.6, 0, 3.2, 0, "green", false, [[3.5, -3.5], [-3.5, -3.5], [3.5, 3.5], [-3.5, 3.5]],
    [
        [18,    4.25,  0, "-flat_flex", true],
        [-3.8, -7.8,  0, "smd_led", LED0805, "red"],
    ],
    []];

rpi_camera = ["rpi_camera", "Raspberry Pi focusable camera", rpi_camera_pcb, [0, 0],
    [
        [[13, 13, 3], 0],
        [[22,  4, 3], 2 - eps],
        [[0, 0, 8.5], 7],
        [[0, 0,  12], 6],
        [[0, 11, 4.3], 14 / 2, [8/2, 11/2, 1]],
    ],
    [0, 18 - 1.5 - 2.5], [8, 5, 1.6],
    [54, 41] // FOV
];

esp32_cam_x = 1; // Seems to vary as mine is offset but pictures on the web show it more centered.

ESP32_module =  ["", "", 18, 26, 0.8,   0, 0.7, [1.1, 1.1, 0, gold], grey(18), false, [
        for(x = [0,1], y = [0:13]) [x * 18, y * 1.27 + 1.4],       // Hole positions on the edge
        for(x = [0:9]) [18 / 2 + (x - 4.5) * 1.27, 0],

    ],
    [
        [18 / 2,        9.7 - 3.4 / 2 , 0, "block", 15.75, 17.6 - 3.4, 2.2, silver, false, 0.3, 0.3], // can
        [18 / 2 - 2.65, 9.7 ,           0, "block", 10.4,  17.6,       2.2, silver, false, 0.3, 0.3], // can
        [12.7, -6.5,  45, "smd_res", RES0502],
        [15.15, -8.3, -90, "smd_coax", U_FL_R_SMT_1],
        // Antenna
        let(x = [0.9, 3.2, 5.7, 8.1, 10.6, 12.8, 15, 15.2])
        each [
            for(i = [0, 5,6,7])  [x[i],                -2.8,  0, "block", 0.6,             4.8, 0.2, gold], // long verticals
            for(i = [1: 4])      [x[i],                -2.05, 0, "block", 0.6,             3.3, 0.2, gold], // short verticals
            for(i = [0, 2, 4,5])[(x[i] + x[i + 1]) / 2, -0.7, 0, "block", x[i + 1] - x[i], 0.6, 0.2, gold], // top horizontals
            for(i = [1, 3])     [(x[i] + x[i + 1]) / 2, -3.4, 0, "block", x[i + 1] - x[i], 0.6, 0.2, gold], // lower horizontals
        ]
     ],
];

ESP32_CAM_pcb = ["", "", 27, 40, 1.7, 2.5, 0, 0, grey(15), false, [],
    [
        [27 / 2, 26 / 2, 0, "-pcb", 0, ESP32_module],
        for(side = [-1, 1]) [side * inch(0.45) + 27 / 2, -(4.2 + inch(.35)), 0, "-2p54joiner", 1, 8],
        [ 27 / 2, -8, 90, "uSD", [14.85, 14.65, 1.8]],
        [ 27 / 2 + 1, 15, 0, "flat_flex", false],
        [ 27 / 2 + inch(0.45), 10.5, 0, "block", 3, 3, 0.8, grey(90)],
        [ 27 / 2 + inch(0.45), 10.5, 0, "block", 2.9, 2.9, 0.81, "yellow", true, 2.9 / 2 - eps],
        [ 27 / 2, 3,                 0, "text", 15, 2, "ESP32-CAM", "Liberation Sans:style=Bold"],
        [0.5, -(4.7 + inch(.35)), 90, "text", inch(0.75), 0.9, "IO4 IO2 IO14 IO15 IO13 IO12 GND  5V", "Liberation Sans:style=Bold"],
        [26.5, -(4.6 + inch(.35)), -90, "text", inch(0.77), 0.9, "3V3 1O16 IO0 GND VCC U0R U0T GND", "Liberation Sans:style=Bold"],
        [5.5, -3.3, 90, "-chip", 4,  3, 1.6, silver],   // Mock button surround
        [5.5, -3.3, 90, "-chip", 1.8,0, 2.0, grey(20)], // Mock button
       [10, -10.8, 0, "-smd_led", LED0603, "red"],
        [-6.5, -5,  0, "-smd_soic", SOIC8],
        [12.2, -4.5, 180, "-smd_sot", SOT223, "AMS1117"],
        [25.3, 14, 0,   "smd_sot", SOT23],
        [3.0,  14, 0,   "smd_sot", SOT23],
        [8,    20, 90,  "smd_sot", SOT23],
        [16,   20, 90,  "smd_sot", SOT23],
        [3.0,  11.5,0,  "smd_res", RES0502],
        [2.9,  10.3,0,  "smd_res", RES0502],
        [5.4,  20,  90, "smd_cap", CAP0603, 0.5],
        [11.5, 20,  90, "smd_cap", CAP0603, 0.5],
        [18.7, 20,  90, "smd_cap", CAP0603, 0.5],
        [19.9, 20,  90, "smd_cap", CAP0402, 0.3],
        for(i = [0, 1, 2, 4]) [7.6 + i * 1.09, 8.8, 90, "smd_res", RES0502],
        for(i = [0 : 3]) [-4.8, 20 + i * 1.09, 0, "smd_res", RES0502],
        for(i = [3, 5, 8]) [7.6 + i * 1.09, 8.8, 90, "smd_cap", CAP0502, 0.5],
        [-8.1, 23, 90, "smd_res", RES0502],
        [-9.2, 23, 90, "smd_res", RES0502],
        [-6.3, 23.3, 180, "text", 0.8, 0.7, "5V", "Liberation Sans:style=Bold"],
        [-6.5, 22.2, 180, "text", 1.2, 0.7, "3V3", "Liberation Sans:style=Bold"],
        [8, -3.3, 90, "-smd_cap", CAP0603, 0.5],
        [2, -2, 0, "-text", 2.3, 1, "RST", "Liberation Sans:style=Bold"],
        [10,-9.4, 0, "-text", 3.1, 1, "LED1", "Liberation Sans:style=Bold"],
        [12.4, -10.8, 0, "-smd_res", RES0502],
        [13.7, -9.4,  0, "-smd_cap", CAP0603, 0.5],
        [17.2,-9.4,   0, "-smd_cap", CAP0502, 0.4],
        [22.1, -10.8, 0, "-smd_res", RES0502],
        [16.9, -4.8, 90, "-smd_res", RES0502],
        [2.2,  9.0,  90, "-smd_cap", CAP0502, 0.4],
        [2.2, 11.6,  90, "-smd_cap", CAP0502, 0.4],
        [2.2, 14.2,  90, "-smd_res", RES0502],
        [5.9, -9.4,  90, "-smd_tant", TANT_B, "107A"],

     ],
    [],
    [(27 - inch(0.9)) / 2, 40 - 4.2 - inch(0.7), 2, 8, silver, inch(0.9), inch(0.1)], // 8x2 grid of holes
];

ESP32_CAM = ["ESP32_CAM", "ESP32-CAM Camera module", ESP32_CAM_pcb, [esp32_cam_x, pcb_width(ESP32_CAM_pcb) / 2 - 12, 1.8],
    [
        [[8, 8, 2.4], 0],
        [[0, 0, 4.2], 4],
        [[0, 0, 6.3], 3.5, [1, 1, 0.5]],
    ],
    [1, -4], [15, 2.2, 1],
    [41, 54] // FOV
];



cameras = [rpi_camera_v1, rpi_camera_v2, rpi_camera, ESP32_CAM];

use <camera.scad>
