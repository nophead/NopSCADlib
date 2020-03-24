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
use <../utils/layout.scad>

include <../vitamins/circlips.scad>

module circlips(all = false)
    layout([for(c = circlips) circlip_d3(c)], 10, false) let(c = circlips[$i]) {
        gap = circlip_d3(c) + 2;

        internal_circlip(c, 1);

        if(all) {
            translate([0, gap])
                internal_circlip(c, 0);

            translate([0, 2 * gap])
                internal_circlip(c, -1);
        }
    }

if($preview)
    circlips(true);
