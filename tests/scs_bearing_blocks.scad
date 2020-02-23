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

include <../vitamins/scs_bearing_blocks.scad>

module scs_bearing_blocks()
    layout([for(s = scs_bearing_blocks) 2 * scs_size(s)[0]]) {
        part_thickness = 5;
        scs_bearing_block_assembly(scs_bearing_blocks[$i], part_thickness);

        if($i > 0) // skip $i==0, since no SCS6LUU long variant to match SCS6UU
            translate([0, 60])
                scs_bearing_block_assembly(scs_bearing_blocks_long[$i - 1], part_thickness);
    }

if($preview)
    scs_bearing_blocks();
