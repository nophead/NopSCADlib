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

include <../vitamins/spools.scad>

module spools()
    layout([for(s = spools) spool_height(s)], 100) let(s = spools[$i])
        rotate([90, 0, 90])
            spool(s, filament_depth =  spool_depth(s) / 2, filament_colour = [pp1_colour, pp2_colour, pp3_colour, pp4_colour][$i % 4], filament_d = $i ? 3 : 1.75);

if($preview)
    spools();
