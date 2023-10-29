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

include <../vitamins/ball_bearings.scad>


module do_bearings(list) {
    diameters = [for(b = list) bb_diameter(b)];
    max = max(diameters);
    layout(diameters) let(b = list[$i])
        //translate([0, (max - bb_diameter(b)) / 2])
            ball_bearing(list[$i])
                if (bb_width(list[$i]) >= 5)
                    bearing_ball(3);
}

module ball_bearings() {
    small_bearings = [for(b = ball_bearings) if(bb_diameter(b) <= 13) b];
    big_bearings = [for(b = ball_bearings) if(!in(small_bearings, b)) b];

    translate([0, 0])
        do_bearings(big_bearings);

    translate([0, -25])
        do_bearings(small_bearings);
}

if($preview)
    ball_bearings();
