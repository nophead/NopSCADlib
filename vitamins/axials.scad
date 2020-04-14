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
//! Axial components
//

res1_8 = ["res1_8", 0.125, 3.3, 1.35, 1.7, 1,   0.33, "#FAE3AC"];
res1_4 = ["res1_4", 0.25,  5.7, 1.85, 2.3, 1.5, 0.55, "#FAE3AC"];
res1_2 = ["res1_2", 0.5,  10,   3.25, 3.7, 1.8, 0.70, "#FAE3AC"];

ax_resistors = [res1_8, res1_4, res1_2];

use <axial.scad>
