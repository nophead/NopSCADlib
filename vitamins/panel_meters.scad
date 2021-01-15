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

//
//! Panel mounted digital meter modules
//
//                                                                            body size           bezel size,       radius, bevel aperture     tab           tab_z t
//            inner aperture offset    pcb         pcb z h
PZEM021   = ["PZEM021", "Peacefair PZEM-021 AC digital multi-function meter", [84.6, 44.7, 24.4], [89.6, 49.6, 2.3], 1.5, [1, 1], [51, 30, 5], [1.3, 10, 6], 15.5, 0];
PZEM001   = ["PZEM001", "Peacefair PZEM-001 AC digital multi-function meter", [62  , 52.5, 24.4], [67,   57.5, 2.0], 2.0, [1, 1], [61, 46,-3], [1.2, 10, 6], 15.5, 0,
             [36, 36, 1.9], [0, 0], false, 0, 0, [
                [[25,  8, 0], [0, 0, 2], 4, grey(90)],
                [[25, -8, 0], [0, 0, 2], 4, grey(90)],

            ]];

DSP5004PCB = ["", "", 68, 36, 1.6, 0, 0, 0, "green", false, [], [], []];
DSP5005   = ["DSP5005", "Ruideng DSP5005 Power supply module",                [71.6, 39.8, 25.0], [79,   43.0, 2.3], 2.0, 1,      [67, 32,-1], [2.0, 12, 9], 13.5, 1.5,
             [28, 27, 0.7], [-4.5, 0], DSP5004PCB, 10,   36, [
                [[ 22,  4, 2], [ 0,   0,  11], 6,    "silver"],
                [[ 22,  4, 5], [ 0,   0,   6], 6.5,  "silver"],
                [[ 22, -9, 0], [ 8,   6,   1], 2.99, "yellow"],
                [[-25, -9, 0], [ 6.5, 4.5, 1], 0.5,  "yellow"],
                [[-25,  0, 0], [ 6.5, 4.5, 1], 0.5,  "yellow"],
                [[-25,  9, 0], [ 6.5, 4.5, 1], 0.5,  "yellow"],
               ]];

DSN_VC288PCB = ["", "", 41, 21, 1, 0, 0, 0, "green", false, [], [[ 5,  -3.525,   0, "jst_xh", 3], ], []];

DSN_VC288 = ["DSN_VC288","DSN-VC288 DC 100V 10A Voltmeter ammeter",            [45.3, 26,   17.4], [47.8, 28.8, 2.5], 0,   [1, 1.8], [36, 18, 2.5], [],            0, 2,
              [], 0, DSN_VC288PCB, 5, 0];

panel_meters = [DSN_VC288, PZEM021, PZEM001, DSP5005];

use <panel_meter.scad>
