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

displays = [HDMI5, SSD1963_4p3, LCD1602A];

use <display.scad>
