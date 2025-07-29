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
// Extrusion brackets
//
include <../core.scad>
include <screws.scad>

E20_inner_corner_bracket = ["E20_inner_corner_bracket", [26, 25, 4.7], M4_sliding_t_nut, E2020t, [7, 6]];
E40_inner_corner_bracket = ["E40_inner_corner_bracket", [38, 31, 8.5], M6_sliding_t_nut, E4040t, [13, 10]];

E20_corner_bracket = ["E20_corner_bracket", [28, 28, 20], 2, 3, 19.5, M4_sliding_t_nut, E2020t];
E40_corner_bracket = ["E40_corner_bracket", [40, 40, 35], 2, 3, 19.5, M8_sliding_ball_t_nut, E4040t];

//sh is horizontal positions of the screw holes, expressed in %/100 of the nut arm
//sv is vertical positions of the screw holes, expressed in %/100 of the nut arm
//                                                                                          screw          nd  nt  nnt  nsx   nty1  nty2 sh           sv
extrusion_corner_bracket_3D_2020 = ["extrusion_corner_bracket_3D_2020", 20,   5,   13, 2.5, M4_grub_screw, 6, 3.5, 5,   15.5, 10,   6,  [0.5],        [0.5]];
extrusion_corner_bracket_3D_3030 = ["extrusion_corner_bracket_3D_3030", 29.6, 6.2, 22, 2.5, M6_grub_screw, 8, 4.2, 6.2, 24.9, 16,   11, [0.25, 0.75], [0.65]];
extrusion_corner_bracket_3D_4040 = ["extrusion_corner_bracket_3D_4040", 40,   9.5, 25, 2.5, M6_grub_screw, 8, 5,   9.5, 34.0, 19.5, 14, [0.25, 0.75], [0.65]];

extrusion_corner_bracket_3Ds = [extrusion_corner_bracket_3D_2020, extrusion_corner_bracket_3D_3030, extrusion_corner_bracket_3D_4040];

use <extrusion_bracket.scad>
