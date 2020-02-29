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

use <../vitamins/rod.scad>

module rods()
    layout([for(b = linear_bearings) 2 * bearing_radius(b)]) let(d = bearing_rod_dia(linear_bearings[$i])){

        rod(d, 80);

        translate([0, 30])
            studding(d, 80);

        if(d >= 6)
            translate([0, 60]) {
                starts = d > 6 ? 4 : 1;
                pitch = d > 14 ? 4
                               : d > 10 ? 3 : 2;
                let($show_threads = true)
                    leadscrew(d, 80, starts * pitch, starts);
            }
    }

if($preview)
    let($show_threads = true)
        rods();
