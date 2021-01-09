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

include <../core.scad>
include <../vitamins/pulleys.scad>
include <../printed/printed_pulleys.scad>
use <../utils/layout.scad>


module PrintedPulley_test() {
    layout([for (p = pulleys) pulley_flange_dia(p)]) {
        rotate(-135)
            printed_pulley_assembly(pulleys[$i]);
        translate([0, 20, 0])
            rotate(45)
                pulley_assembly(pulleys[$i]);
    }
}

if ($preview)
    PrintedPulley_test();
