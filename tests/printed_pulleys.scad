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

n = len(pulleys) - 1;
half = floor((n - 1) / 2);
split = n - half;
pulleys1 = [for(i = [0 : split - 1]) pulleys[i]];
pulleys2 = [for(i = [split : n - 1]) pulleys[i]];

max_d = max([for(p = concat(pulleys1, pulleys2)) pulley_flange_dia(p)]);

module do_list(list, show_metal) {
    layout([for (p = list) max_d]) let(p = list[$i]) {
        rotate(-145)
            if($preview)
                printed_pulley_assembly(p);
            else
                printed_pulley(p);

        if(show_metal)
            not_on_bom()
                translate([0, 60])
                    rotate(-145)
                        pulley_assembly(p);
    }
}

module printed_pulley_test(show_metal = false) {
    translate([0, 10])
        do_list(pulleys1, show_metal);

    translate([0, -10])
        do_list(pulleys2, show_metal);

    translate([split * (max_d + 5), 0])
        do_list([pulleys[n]], show_metal);
}

if($preview)
    printed_pulley_test(true);
else
    printed_pulley_test();
