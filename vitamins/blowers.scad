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

RB5015 = ["RM5015", "Blower Runda RB5015",           51.3, 51, 15, 31.5, M4_cap_screw, 26, [27.3, 25.4], 4.5, [[4.3, 45.4], [47.3,7.4]], 20, 14, 1.5, 1.3, 1.2, 15];
PE4020 = ["PE4020", "Blower Pengda Technology 4020", 40,   40, 20, 27.5, M3_cap_screw, 22, [21.5, 20  ], 3.2, [[37,3],[3,37],[37,37]], 29.3, 17, 1.7, 1.2, 1.3, 13];

blowers = [PE4020, RB5015];

use <blower.scad>
