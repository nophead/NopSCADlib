//
// NopSCADlib Copyright Niclas Hedhman 2018
// niclas@hedhman.org
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


//                     Code, Description, w, t1, t2, h,   dia, flange_dia 
M80ST = [ "M80ST", "80ST standard mount", 80, 6, 3, 63.63, 6, 70 ];

//                 Code, Description, 
Shaft_19mm_keyed = ["19mm_keyed", "19mm Shaft with key", "keyed", 19, 35, [6, 3.5], 25 ];

//                      Code,                     Description,                Diameter, Length, Mount, Shaft
Lichuan_M01330_80ST = [ "LCMT07L02NB_80M01330B", "Lichuan LCMT07L02NB-80M01330B",90,123, Shaft_19mm_keyed, M80ST ];
Lichuan_M02430_80ST = [ "LCMT07L02NB_80M02430B", "Lichuan LCMT07L02NB-80M02430B",90,150, Shaft_19mm_keyed, M80ST ];
Lichuan_M03530_80ST = [ "LCMT07L02NB_80M03530B", "Lichuan LCMT07L02NB-80M03530B",90,178, Shaft_19mm_keyed, M80ST ];
Lichuan_M04030_80ST = [ "LCMT07L02NB_80M04030B", "Lichuan LCMT07L02NB-80M04030B",90,190, Shaft_19mm_keyed, M80ST ];

//                          Code, Description
servos = [Lichuan_M01330_80ST,Lichuan_M02430_80ST,Lichuan_M03530_80ST,Lichuan_M04030_80ST];

use <servo.scad>
