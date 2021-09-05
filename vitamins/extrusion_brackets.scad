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

E20_inner_corner_bracket  = [ "E20_inner_corner_bracket", [26, 25, 4.7], M4_sliding_t_nut, E2020t, [7,   6]];
E40_inner_corner_bracket  = [ "E40_inner_corner_bracket", [38, 31, 8.5], M6_sliding_t_nut, E4040t, [13, 10]];

E20_corner_bracket = [ "E20_corner_bracket", [28, 28, 20], 2, 3, 19.5, M4_sliding_t_nut,      E2020t];
E40_corner_bracket = [ "E40_corner_bracket", [40, 40, 35], 2, 3, 19.5, M8_sliding_ball_t_nut, E4040t];


use <extrusion_bracket.scad>
