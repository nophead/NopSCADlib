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
// Light dependent resistors.
//
small_ldr = ["small_ldr", "small", 5,   4.2, 2.0, 3.2, 2.5, 0.4];
large_ldr = ["large_ldr", "large", 9.2, 7.9, 2.0, 6.8, 4.5, 0.5];

ldrs = [small_ldr, large_ldr];

use <ldr.scad>
