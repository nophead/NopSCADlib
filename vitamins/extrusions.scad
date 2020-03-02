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
// Extrusion
//
//                   W   H    d1   d2   s  cw   cwi    t  st  f
E1515  = [ "E1515", 15, 15,  2.5,   0,5.7,3.4,  5.7, 1.1,1.1, 0.5 ];
E2020  = [ "E2020", 20, 20,  4.2,   3,  8,  6, 12.0,   2,  2, 1 ];
E2040  = [ "E2040", 20, 40,  4.2,   3,  8,  6, 12.0,   2,  2, 1 ];
E2060  = [ "E2060", 20, 60,  4.2,   3,  8,  6, 12.0,   2,  2, 1 ];
E2080  = [ "E2080", 20, 80,  4.2,   3,  8,  6, 12.0,   2,  2, 1 ];
E3030  = [ "E3030", 30, 30,  6.8, 4.2, 12,  8, 16.5,   2,  2, 1 ];
E3060  = [ "E3060", 30, 60,  6.8, 4.2, 12,  8, 16.5,   2,  2, 1 ];
E4040  = [ "E4040", 40, 40, 10.5, 6.0, 15, 10, 20.0, 5.5,  3, 1 ];
E4080  = [ "E4080", 40, 80, 10.5, 6.0, 15, 10, 20.0, 5.5,  3, 1 ];

extrusions = [E1515,E2020,E2040,E2060,E2080,E3030,E3060,E4040,E4080];

use <extrusion.scad>

