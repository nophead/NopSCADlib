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

include <../vitamins/washers.scad>

function penny_diameter(w) = let(p = penny_washer(w)) washer_diameter(p ? p : w);

module washers()
    layout([for(w = washers) penny_diameter(w)], 2) let(w = washers[$i]) {
        star_washer(w);

        if(spring_washer_thickness(w))
            translate([0, 20])
                let($explode = 1)
                    spring_washer(w);

        translate([0, 40])
            washer(w);

        if(penny_washer(w))
            translate([0, 65])
                penny_washer(w);

        translate([0, 90])
            printed_washer(w);
    }

if($preview)
    washers();
