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

include <../vitamins/screws.scad>

module nuts() {
    for(nyloc = [false, true])
        translate([0, nyloc ? 20 : 0])
            layout([for(n = nuts) 2 * nut_radius(n)], 5)
                nut(nuts[$i], nyloc);

    translate([0, 40])
        layout([for(n = nuts) 2 * nut_radius(n)], 5) let(n = nuts[$i]) {
            if(n == M3_nut)
                nut(n, brass = true);

            if(n == M2p5_nut)
                nut(n, nylon = true);

            if(n == M4_nut)
                rotate(-45)
                    wingnut(M4_wingnut);

            if(n == M6_nut)
                nut_and_washer(M6_half_nut, false);

            if(n == M8_nut)
                #nut_trap(M8_cap_screw, n, h = 30);
        }
}

if($preview)
    nuts();
