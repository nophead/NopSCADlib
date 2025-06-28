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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/extrusions.scad>

gap = 10;

module extrusions()
    layout([for(e = extrusions) is_list(e[0]) ? extrusion_width(e[0]) : extrusion_width(e)], gap)
        let(e = extrusions[$i])
            if(is_list(e[0])) {
                list = e;
                heights = [for(e = list) extrusion_height(e)];
                l = len(heights) - 1;
                offset = (heights * [for(i = [0 : l]) 1] + l * gap) / 2;
                translate([0, -offset])
                    rotate(90)
                        layout(heights, gap)
                            rotate(-90)
                                extrusion(list[$i], 80);
            }
            else
                extrusion(e, 80);

if ($preview)
    extrusions();
