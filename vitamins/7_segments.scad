//
// NopSCADlib Copyright Chris Palmer 2021
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
//! 7 Segment displays
//

WT5011BSR = ["WT5011BSR", [12.7, 19, 8.2], [7.2, 12.7, 1.2, 10], [5, 2], [inch(0.1), inch(0.6), 0.4]];

7_segments = [ WT5011BSR ];

use <7_segment.scad>
