//
// NopSCADlib Copyright Chris Palmer 2023
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
include <../vitamins/bearing_blocks.scad>

//
// SBR Rails
//

//                        d  h   B   T  carriage P    S2            C   S3            S3L
SBR16S     = ["SBR16S",  16, 25, 40, 5, SBR16UU, 150, M5_cap_screw, 30, M5_cap_screw, 18  ];

sbr_rails = [SBR16S];

use <sbr_rail.scad>
