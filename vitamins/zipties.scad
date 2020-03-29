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

// [width, thickness, [latch_x, latch_y, latch_z], colour, tail]
small_ziptie = ["small_ziptie", 2.5, 1.0, [4.7, 4.25, 3.0], "white", 25];
ziptie_3mm   = ["ziptie_3mm",   3.0, 1.0, [5.4, 5.44, 4.5], "white", 25];
ziptie_3p6mm = ["ziptie_3p6mm", 3.6, 1.2, [6.4, 6.62, 4.7], "white", 25];

zipties = [small_ziptie, ziptie_3mm, ziptie_3p6mm];

use <ziptie.scad>
