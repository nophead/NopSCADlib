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
include <../core.scad>
use <../utils/layout.scad>

include <../vitamins/linear_bearings.scad>

use <../vitamins/rod.scad>

module rods()
    layout([for(b = linear_bearings) 2 * bearing_radius(b)]) {

        rod(bearing_rod_dia(linear_bearings[$i]), 80);

        translate([0, 30])
            studding(bearing_rod_dia(linear_bearings[$i]), 80);

        if(bearing_rod_dia(linear_bearings[$i]) >=6)
            translate([0, 60])
                leadscrew(bearing_rod_dia(linear_bearings[$i]), 80);
    }

if($preview)
    rods();
