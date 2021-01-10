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


module printed_pulley_test(show_metal = false) {
    layout([for (p = pulleys) pulley_flange_dia(p)]) let(p = pulleys[$i]) {
        rotate(-145)
            if($preview)
                printed_pulley_assembly(p);
            else
                printed_pulley(p);

        if(show_metal)
            not_on_bom()
                translate([0, 20])
                    rotate(-145)
                        pulley_assembly(p);
    }
}

if($preview)
    printed_pulley_test(true);
else
    printed_pulley_test();
