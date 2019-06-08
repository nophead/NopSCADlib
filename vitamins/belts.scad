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
// Belt model
//
//             p     w  t     t     p
//             i     i  h     o     i
//             t     d  i     o     t
//             c     t  c     t     c
//             h     h  k     h     h line from tooth base
//
T5x6 =  ["T",  5,    6, 2.2,  1.2,  0.5];
T5x10 = ["T",  5,   10, 2.2,  1.2,  0.5];
T2p5x6 =["T",  2.5,  6, 1.7,  0.7,  0.3];
GT2x6 = ["GT", 2.0,  6, 1.38, 0.75, 0.254];

belts = [T5x6, T5x10, T2p5x6, GT2x6];
use <belt.scad>
