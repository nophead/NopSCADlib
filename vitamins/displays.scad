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

HDMI5PCB = ["", "",  121.11, 77.93, 1.65, 0, 2.2, 0, "mediumblue", false, [[4.6, 4.9], [4.6, -3.73], [97.69, -3.73], [97.69, 4.9]],
    [[ 47.245,-2.5, 90, "usb_uA"],
     [-53.14, -4.4, 90, "hdmi"],
     [ 53.7,  40.6,  0, "chip",       14, 14, 1],
     [ 59.8,  25.2,  0, "2p54socket", 13, 2, false, 13.71],
     [ 59.8,  10.12, 0, "2p54header", 13, 2, true],
    ],
    []];

HDMI5 = ["HDMI5", "HDMI display 5\"", 121, 76, 2.85, HDMI5PCB,
          [0, 0, 1.9],                              // pcb offst
          [[-54,   -30.225], [54, 34.575, 0.5]],    // aperture
          [[-58.7, -34],     [58.7, 36.25, 1]],     // touch screen
          2,                                        // thread length
          [[-2.5, -39], [10.5, -33]],               // clearance need for the ts ribbon
        ];

LCD1602APCB = ["", "", 80, 36, 1.65, 0, 2.9, 5, "green", false, [[-2.5, -2.5], [-2.5, 2.5], [2.5, 2.5], [2.5, -2.5]],
      [ [-27.05, - 2.5, 0, "2p54header", 16, 1]
      ],
      []];

LCD1602A = ["LCD1602A", "LCD display 1602A", 71.3, 24.3, 7.0, LCD1602APCB,
          [0, 0, 0],                             // pcb offst
          [[-64.5 / 2, -14.5 / 2], [64.5 / 2, 14.5 / 2, 0.6]],              // aperture
          [],                                       // touch screen
          0,                                        // thread length
          [],                                       // clearance need for the ts ribbon
        ];

LCDS7282BPCB = ["", "", 85, 36, 1.65, 0, 2.56, 0, "green", false, [[-2.5, -2.5], [-2.5, 2.5], [2.5, 2.5], [2.5, -2.5]],
      [ [3.5, 18, 0, "2p54header", 2, 7]
      ],
      []];

LCDS7282B = ["LCDS7282B", "LCD display S-7282B", 73.6, 28.7, 9.6, LCDS7282BPCB,
          [-2.5, 0, 0],                             // pcb offst
          [[-64.5 / 2, -14.5 / 2], [64.5 / 2, 14.5 / 2, 0.6]],              // aperture
          [],                                       // touch screen
          0,                                        // thread length
          [],                                       // clearance need for the ts ribbon
        ];

SSD1963_4p3PCB = ["", "", 120, 74, 1.65, 3, 3, 0, "mediumblue", false, [[3, 3], [-3, 3], [-3, -3], [3, -3]],
    [ [2.75 + 1.27, 37, 90, "2p54header", 20, 2]
    ],
    []];

SSD1963_4p3 = ["SSD1963_4p3", "LCD display SSD1963 4.3\"", 105.5, 67.2, 3.4, SSD1963_4p3PCB,
        [0, 0, 0],
        [[-50, -26.5], [50, 31.5, 0.5]],
        [[-105.5 / 2, -65 / 2 + 1], [105.5 / 2, 65 / 2 + 1, 1]],
        0,
        [[0, -34.5], [12, -31.5]],
        ];


/* Dimensions taken from:
https://github.com/bigtreetech/BIGTREETECH-TFT35-V3.0/blob/master/Hardware/TFT35%20V3.0-SIZE-TOP.pdf
and
https://github.com/bigtreetech/BIGTREETECH-TFT35-V3.0/blob/master/Hardware/TFT35%20V3.0-SIZE-BOT.pdf
*/

BigTreeTech_TFT35v3_0_PCB = ["", "",
    110, 55.77, 1.6, // size
     0, // corner radius
     3, // mounting hole diameter
     0, // pad around mounting hole
    "green", // color
    false, // true if parts should be separate BOM items
    [ // hole positions
         [-3.12, 3.17], [-3.12, -3.17], [3.12, -3.17], [3.12, 3.17]
    ],
    [ // components
        [                 9, -( 8.46 + 17.45)/2,    0, "-buzzer", 5, 9 ],
        [                 9, -(23.76 + 34.94)/2,    0, "-potentiometer" ],
        [  (6.84 + 12.85)/2, -(45.73 + 51.73)/2,    0, "-button_6mm" ],
        [               102,  (15.57 + 42.07)/2,    0, "uSD", [26.5, 16, 3] ],
        [                 8, -( 6.76 + 18.76)/2,  180, "usb_A" ],
        [                23,  (23.32 + 33.64)/2,   90, "2p54socket", 4, 2 ], // ESP-8266

        [ 16.5, 5.9,    0, "2p54boxhdr", 5, 2 ],
        [ 36.5, 5.9,    0, "2p54boxhdr", 5, 2 ],
        [ 56.5, 5.9,    0, "2p54boxhdr", 5, 2 ],
        [ 82.5,   4,    0, "jst_xh", 5 ],
        [ 26.5, 52.8, 180, "jst_xh", 2 ],
        [ 39.5, 52.8, 180, "jst_xh", 3 ],
        [ 52.5, 52.8, 180, "jst_xh", 3 ],
        [ 65.5, 52.8, 180, "jst_xh", 3 ],
        [ 78.5, 52.8, 180, "jst_xh", 3 ],
        [ 94.5, 52.8, 180, "jst_xh", 5 ],
        [ 97,    4,     0, "chip", 9, 3.5, 1, grey(20) ],
    ],
    [] // accessories
];

BigTreeTech_TFT35v3_0 = ["BigTreeTech_TFT35v3_0", "BigTreeTech TFT35 v3.0",
    84.5, 54.5, 4,                      // size
    BigTreeTech_TFT35v3_0_PCB,          // pcb
    [7 - (110 - 84.5)/2, 0, 0],         // pcb offset from center
    [[-40, -26.5], [41.5, 26.5, 0.5]],  // aperture
    [],                                 // touch screen position and size
    0,                                  // length that studs protrude from the PCB holes
    [],                                 // keep out region for ribbon cable
];


displays = [HDMI5, SSD1963_4p3, BigTreeTech_TFT35v3_0, LCD1602A, LCDS7282B];

use <display.scad>
