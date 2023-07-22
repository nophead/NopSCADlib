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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/linear_bearings.scad>

module linear_bearings() {
    layout([for(b = linear_bearings) 2 * bearing_radius(b)]) {
        translate([0, 30])
            linear_bearing(linear_bearings[$i]);

        translate([0, 60])
            linear_bearing(long_linear_bearings[$i]);
    }
    layout([for(b = open_linear_bearings) 2 * bearing_radius(b)])
        translate([105, 0])
            linear_bearing(open_linear_bearings[$i]);
}

if($preview)
    linear_bearings();
