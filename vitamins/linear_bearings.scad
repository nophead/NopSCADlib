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
// Linear bearings
//
LM12UU = ["LM12UU", 30, 21, 12];
LM10UU = ["LM10UU", 29, 19, 10];
LM8UU  = ["LM8UU",  24, 15,  8];
LM6UU  = ["LM6UU",  19, 12,  6];
LM5UU  = ["LM5UU",  15, 10,  5];
LM4UU  = ["LM4UU",  12,  8,  4];
LM3UU  = ["LM3UU",  10,  7,  3];

linear_bearings = [LM3UU, LM4UU, LM5UU, LM6UU, LM8UU, LM10UU, LM12UU];

use <linear_bearing.scad>
