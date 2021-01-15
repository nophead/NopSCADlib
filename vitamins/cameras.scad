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
    [0, 12 - 1.5 - 2.5], [8, 5, 1]
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
    [-13.8 + 12.5, 23.862 / 2 - 4.7], [8.5, 4, 1]
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
    [0, 18 - 1.5 - 2.5], [8, 5, 1.6]
];

cameras = [rpi_camera_v1, rpi_camera_v2, rpi_camera];

use <camera.scad>
