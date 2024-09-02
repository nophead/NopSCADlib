//
// NopSCADlib Copyright Chris Palmer 2024
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
RE_m5_bearing    = ["RE_m5_bearing",   5,  16, 8, 6,   brass,    5, 8, 11.11,  33, 21, 41,  2.0,  2.0,   0,    0];  // uxcell M5x0.8 Right Hand Thread, Self-Lubricating Joint Rod Ends

rod_ends= [ RE_m5_bearing];

use<rod_end.scad>
