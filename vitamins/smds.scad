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
//! SMD components
//

LED0603 = ["LED0603", [1.6, 0.8,  0.18], [1.0, 0.8,  0.42]];
LED0805 = ["LED0805", [2.0, 1.25, 0.46], [1.4, 1.25, 0.54]];

smd_leds = [LED0603, LED0805];

RES0603 = ["RES0603", [1.6, 0.8, 0.45], 0.3, 1/10];
RES0805 = ["RES0805", [2.0, 1.2, 0.45], 0.4, 1/8];
RES1206 = ["RES1206", [3.1, 1.6, 0.6],  0.5, 1/4];

smd_resistors = [RES0603, RES0805, RES1206];

use <smd.scad>
