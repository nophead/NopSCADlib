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


//                   type      w,  t,  boss,        pitch, screw dia
80ST_faceplate = [ "80ST",     80, 8,  [70, 34, 3], 63.63, 6 ];

//                   type,    dia, len, key length, width, depth
Shaft_19mm_keyed = [ "keyed", 19,  35, [25, 6, 3.5] ];

//                      Code,                   Description,                    Cap,         Length, Shaft,         Faceplate
Lichuan_M01330_80ST = [ "Lichuan_M01330_80ST", "Lichuan LCMT07L02NB-80M01330B", [70, 3, 38], 123, Shaft_19mm_keyed, 80ST_faceplate ];
Lichuan_M02430_80ST = [ "Lichuan_M02430_80ST", "Lichuan LCMT07L02NB-80M02430B", [70, 3, 38], 150, Shaft_19mm_keyed, 80ST_faceplate ];
Lichuan_M03530_80ST = [ "Lichuan_M03530_80ST", "Lichuan LCMT07L02NB-80M03530B", [70, 3, 38], 178, Shaft_19mm_keyed, 80ST_faceplate ];
Lichuan_M04030_80ST = [ "Lichuan_M04030_80ST", "Lichuan LCMT07L02NB-80M04030B", [70, 3, 38], 190, Shaft_19mm_keyed, 80ST_faceplate ];

servo_motors = [Lichuan_M01330_80ST, Lichuan_M02430_80ST, Lichuan_M03530_80ST, Lichuan_M04030_80ST];

use <servo_motor.scad>
