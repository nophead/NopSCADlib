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
include <fans.scad>
include <rockers.scad>
include <iecs.scad>
//
// Hole positions are looking from below / outside
//
// Face order is bottom, top, left, right, front, back.
//
// Meanwell RS-150-12
mw_terminals = [9.525, 1.5, 15, 17.8, 7, 15];

PD_150_12 =
    ["PD_150_12", "PD-150-12", 199, 98, 38, M3_pan_screw, M3_clearance_radius, false, 11, 4.5, [7, 11, mw_terminals],
        [
            [[[82.5, -40], [82.5, 40], [-37.5, -40], [-37.5, 40]], 1.5, []],
            [[],                                                   0.5, [], true],
            [[],                                                   0.5, [[[-49, -19], [-49, -11.5], [-40, -11.5], [-40, 5], [47.5, 5], [47.5, -19]]]],
            [[],                                                   1.5, [[[-49, -19], [-49, -6], [37.5, -6], [37.5, -12.5], [49, -12.5], [49, -19]]]],
            [[[-77.5, 1], [79.5, 9.5], [79.5, -9.5]],              1.5, []],
            [[],                                                   0.5, [], true],
        ],
        []
    ];

st_terminals = [9.666, 2, 13, 15, 8, 13.5];
S_250_48 =
    ["S_250_48", "S-250-48", 200, 110, 50, M3_pan_screw, M3_clearance_radius, false, 13, 5, [9, 11, st_terminals],
        [
            [[[-39, -45.5], [-39,  39.5], [86, -45.5], [86, 39.5]], 1.5, []],
            [[],                                                    0.5, [], true],
            [[],                                                    0.5, [[[-55, -25], [-55, -17], [-46, -17], [-46, 11], [53.5, 11], [53.5, -25]]]],
            [[],                                                    1.5, [[[-55, -25], [-55, -13], [43.5, -13], [43.5, -15], [55, -15], [55, -25]]]],
            [[[-79.5, 0], [78.5, 12.5], [78.5, -12.5]],             1.5, []],
            [[],                                                    0.5, [], true],
        ],
        []
    ];

// Single fan at back, wires exit opposite side from mains in
ATX500 =
    ["ATX500", "ATX500", 150, 140, 86, No632_pan_screw, 5/2, true, 0, 0, [],
        [
            [[], 0.8, []],
            [[], 0.8, []],
            [[], 0.8, []],
            [[], 0.8, []],
            [[[-69, -27], [-69,  37], [69,  37], [45, -37]], 0.8, [], false, [-25, 0, fan80x25], [45, -19.6, 180, IEC_inlet_atx], [45, 23, 90, small_rocker]],
            [[], 0.8, [], true],
        ],
        [": IEC mains lead"]
    ];

KY240W =
    ["KY240W", "KY-240W-12-L", 199, 110, 50, M3_cap_screw, M3_clearance_radius, false, 0, 0, [],
        [
            [[[ 199 / 2 - 12,  110 / 2 - 93],
            [ 199 / 2 - 12,  110 / 2 - 9 ],
            [ 199 / 2 - 138, 110 / 2 - 93],
            [ 199 / 2 - 138, 110 / 2 - 9 ]]]

        ],
        []
    ];

// This PSU, and ones very like it, are sold by LulzBot, and various sellers on eBay.
// The screw layout specified here uses the inner set of screw-mounts on the PSU, which are M4.
// The outer set don't appear to be M3, even though the datasheet claims they are.
S_300_12 = [
    "S_300_12",
    "S-300-12",// part name
    215, 115, 50,// length, width, height
    M4_cap_screw, M4_clearance_radius,// screw type and clearance
    false,// true if ATX style
    13,// terminals bay depth
    0,// heatsink bay depth
    [// terminals
        9,// count
        18,// y offset
        st_terminals
    ],
    // faces
    [
        [// f_bottom, bottom
            [// holes
                [215/2 - 32.5, 115/2 - 82.5], [215/2 - 32.5, 115/2 - 32.5], [215/2 - 182.5, 115/2 - 82.5], [215/2 - 182.5, 115/2 - 32.5]
            ],
            1.5,// thickness
            [],// cutouts
            false,// grill
            [],[],[],// fan, iec, rocker
            [// vents
                // [ [pos.x, pos.y, angle], [size.x, size.y], corner radius ]
                for(x = [0:21], y = [-1,1]) [ [-7*x+215/2-34, (115/2-5)*y, 0], [3, 25], 1.5 ]
            ]
        ],
        [// f_top, top
            [],// holes
            0.5,// thickness
            [],// coutouts
            false,// grill
            [215/2 - 47.5, 115/2 - 37.5, fan50x15],
            [],//iec
            [],//rocker
            [// vents
                for(x = [0:4], y = [-1,1]) [ [-7*x-215/2+48, 28*y, 0], [3, 25], 1.5 ]
            ]
        ],
        [// f_left, front (terminals) after rotation
            [],// holes
            0.5,// thickness
            [// cutouts
                [
                [-56, -25], [-56, -17],
                [-60, -17], [-60, 0],
                [115/2, 0], [115/2, -25]
                ]
            ],
            false,// grill
        ],
        [// f_right, back after rotation
            [], // holes
            1.5,// thickness
            [],// cutouts
            false,// grill
        ],
        [// f_front, right after rotation
            [// holes, offset from center
                [215/2 -  32.5,-15], [215/2 - 182.5,-15],
                [215/2 -  32.5, 10], [215/2 - 182.5, 10]
            ],
            1.5,// thickness
            [],// cutouts
            false,// grill
            [],[],[],// fan, iec, rocker
            [// vents
                for(x = [0 : 21]) [ [-7*x+215/2-34, -25, 0], [3, 10], 1.5 ],
                for(x = [0 :  1]) [ [-7*x, -1, 0], [3, 25], 1.5 ],
                for(x = [0 :  2]) [ [-7*x-215/2+20, -1, 0], [3, 25], 1.5 ],
            ]
        ],
        [// f_back, left after rotation
            [// holes, offset from center
                [215/2 - 32.5 - 13/2, 15], [215/2 - 182.5 - 13/2, 15]
            ],
            1.5,// thickness
            [],// cutouts
            false,// grill
            [],[],[],// fan, iec, rocker
            [// vents
                for(x = [0 : 21]) [ [-7*x+215/2-34-13/2, 25, 0], [3, 10], 1.5 ]
            ]
        ],
    ],
    // accessories to add to BOM
    []
];

External =
    ["External", "X Box", 0, 0, 0, false, false, false, 0, 0, [],
        [],
        [": IEC mains lead"]
    ];

psus = [PD_150_12, S_250_48, S_300_12, ATX500, KY240W];

use <psu.scad>
