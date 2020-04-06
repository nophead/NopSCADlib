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

include <../vitamins/light_strips.scad>

module light_strips()
    layout([for(s = light_strips) light_strip_width(s)], 10)
        rotate(90) let(light = light_strips[$i], segs = light_strip_segments(light, 260), d = light_strip_clip_depth(light)) {
            light_strip(light, segs);

            for(end = [-1, 1])
                translate([end * (light_strip_cut_length(light, segs) / 2 - d / 2), 0])
                    rotate([90, 0, 90])
                        stl_colour(pp1_colour) render()
                            translate_z(-d / 2)
                                light_strip_clip(light);
        }

if($preview)
    light_strips();
