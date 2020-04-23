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
//! Panel mounted digital meter modules
//

PZEM021   = ["PZEM021",  "Peacefair PZEM-021 AC digital multi-function meter", [84.6, 44.7, 24.4], [89.6, 49.6, 2.3], 1.5, [1, 1],   [51, 30, 5], [1.3, 10, 6], 15.5, 0];
PZEM001   = ["PZEM001",  "Peacefair PZEM-001 AC digital multi-function meter", [62  , 52.5, 24.4], [67,   57.5, 2.0], 1.5, [1, 1],   [36, 36, 0], [1.2, 10, 6], 15.5, 0];

DSN_VC288PCB = ["", "", 41, 21, 1, 0, 0, 0, "green", false, [],
      [ [ 5,  -3,   0, "jst_xh", 3],

      ],
      []];

DSN_VC288 = ["DSN_VC288","DSN-VC288 DC 100V 10A Voltmeter ammeter",            [45.3, 26,   17.4], [47.8, 28.8, 2.5], 0,   [1, 1.8], [36, 18, 2.5], [],            0, 2,
             DSN_VC288PCB, 5];

panel_meters = [DSN_VC288, PZEM021, PZEM001];

use <panel_meter.scad>
