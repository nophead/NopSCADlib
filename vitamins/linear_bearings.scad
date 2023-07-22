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
//                      L  od  id   gl    gd    gs   h1
LM16UU   = ["LM16UU",   37, 28, 16, 1.6, 27.0, 26.5];
LM16LUU  = ["LM16LUU",  70, 28, 16, 1.6, 27.0, 53.0];
LM16UUOP = ["LM16UUOP", 37, 28, 16, 1.6, 27.0, 26.5, 11];
LM12UU   = ["LM12UU",   30, 21, 12, 1.3, 20.0, 23.0];
LM12LUU  = ["LM12LUU",  57, 21, 12, 1.3, 20.0, 46.0];
LM10UU   = ["LM10UU",   29, 19, 10, 1.3, 18.0, 22.0];
LM10LUU  = ["LM10LUU",  55, 19, 10, 1.3, 18.0, 44.0];
LM8UU    = ["LM8UU",    24, 15,  8, 1.1, 14.3, 17.5];
LM8LUU   = ["LM8LUU",   45, 15,  8, 1.1, 14.3, 35.0];
LM6UU    = ["LM6UU",    19, 12,  6, 1.1, 11.5, 13.5];
LM6LUU   = ["LM6LUU",   35, 12,  6, 1.1, 11.5, 27.0];
LM5UU    = ["LM5UU",    15, 10,  5, 1.1,  9.5, 10.2];
LM5LUU   = ["LM5LUU",   28, 10,  5, 1.1,  9.5, 20.4];
LM4UU    = ["LM4UU",    12,  8,  4,   0,    0,    0];
LM4LUU   = ["LM4LUU",   23,  8,  4,   0,    0,    0];
LM3UU    = ["LM3UU",    10,  7,  3,   0,    0,    0];
LM3LUU   = ["LM3LUU",   19,  7,  3,   0,    0,    0];

linear_bearings      = [LM3UU,  LM4UU,  LM5UU,  LM6UU,  LM8UU,  LM10UU,  LM12UU,  LM16UU];
long_linear_bearings = [LM3LUU, LM4LUU, LM5LUU, LM6LUU, LM8LUU, LM10LUU, LM12LUU, LM16LUU];
open_linear_bearings = [LM16UUOP];

use <linear_bearing.scad>
