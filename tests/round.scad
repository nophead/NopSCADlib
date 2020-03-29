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
use <../utils/round.scad>

module shape()
    difference() {
        square(40, center = true);

        square([20, 20], center = true);
    }

module rounds() {
    linear_extrude(eps)
        round(or = 4, ir = 2)
            shape();


    translate([50, 0])
        round_3D(or = 4, ir = 2, chamfer_base = true, $fn = 16)
            linear_extrude(40, center = true)
                shape();
}

rounds();
