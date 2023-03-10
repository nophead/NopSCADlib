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

//
// Tubing and sleeving
//                                Description                OD        ID  Colour
PVC64         = ["PVC64",         "PVC aquarium tubing",      6,        4, [0.8, 0.8, 0.8, 0.75 ]];
PVC85         = ["PVC85",         "PVC aquarium tubing",      8,        5, [0.8, 0.8, 0.8, 0.75 ]];
NEOP85        = ["NEOP85",        "Neoprene tubing",          8,        5, [0.2,0.2,0.2]];
PTFE07        = ["PTFE07",        "PTFE sleeving",            1.2,   0.71, [0.95, 0.95, 0.95, 0.9]];
PTFE20        = ["PTFE20",        "PTFE sleeving",            2.6,      2, [0.95, 0.95, 0.95, 0.9]];
PTFE2_4       = ["PTFE2_4",       "PTFE tubing",              4,        2, [0.95, 0.95, 0.95, 0.9]];
PTFE2_3       = ["PTFE2_3",       "PTFE tubing",              3,        2, [0.95, 0.95, 0.95, 0.9]];
PTFE4_6       = ["PTFE4_6",       "PTFE tubing",              6,        4, [0.95, 0.95, 0.95, 0.9]];
PF7           = ["PF7",           "PTFE tubing",              46/10, 3.84, [0.95, 0.95, 0.95, 0.9]];
HSHRNK16      = ["HSHRNK16",      "Heatshrink sleeving",      2.0,    1.6, "grey"];
HSHRNK24      = ["HSHRNK24",      "Heatshrink sleeving",      2.8,    2.4, "grey"];
HSHRNK32      = ["HSHRNK32",      "Heatshrink sleeving",      3.6,    3.2, "grey"];
HSHRNK64      = ["HSHRNK64",      "Heatshrink sleeving",      6.8,    6.4, "grey"];
HSHRNK100     = ["HSHRNK100",     "Heatshrink sleeving",     10.4,   10.0,  [0.2,0.2,0.2]];
STFE4_3p2_CLR = ["STFE4_3p2_CLR", "PTFE heatshrink sleeving", 3.7,    3.2,  [0.95, 0.95, 0.95, 0.5]];
STFE4_6p4_CLR = ["STFE4_6p4_CLR", "PTFE heatshrink sleeving", 7.0,    6.4,  [0.95, 0.95, 0.95, 0.5]];
CARBONFIBER10 = ["CBNFIB10",      "Carbon fiber",            10.0,    8.0,  [0.3,0.3,0.3]];

tubings = [PVC64, PVC85, NEOP85, PTFE07, PTFE20, PF7, PTFE2_3, PTFE2_4, PTFE4_6, HSHRNK16, HSHRNK24, HSHRNK64, HSHRNK100, STFE4_3p2_CLR, STFE4_6p4_CLR, CARBONFIBER10];

use <tubing.scad>
