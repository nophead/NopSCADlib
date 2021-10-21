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
//! Cylindrical and ring magnets.
//

//                          name,                     od,        id,        h,         r
MAG8x4x4p2 = ["MAG8x4x4p2", "Magnet",                 8,         4.2,       4,         0.5];
MAG484     = ["MAG484",     "Magnet",                 inch(1/4), inch(1/8), inch(1/4), 0.5];
MAG5x8     = ["MAG5x8",     "Magnet",                 8,         0,         5,         0.5];
MAGRE6x2p5 = ["MAGRE6x2p5", "Radial encoder magnet",  6,         0,         2.5,       0.5];

magnets = [MAG8x4x4p2, MAG484, MAG5x8, MAGRE6x2p5];

use <magnet.scad>
