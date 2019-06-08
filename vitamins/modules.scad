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
// Random modules
//

//
//           p                                   l   w   h     s              s  h  h
//           a                                   e   i   e     c              c  o  o
//           r                                   n   d   i     r              r  l  l
//           t                                   g   t   g     e              e  e  e
//                                               h   h   h     w              w     s
//                                                       t                       d
//                                                                            z
//
drok_buck = ["drok_buck", "Drok buck converter", 50, 25, 20.5, M4_dome_screw, 2, 4, [[-21, 0], [21, 0]]];

modules = [drok_buck];

use <module.scad>
