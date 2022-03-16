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
use <../printed/corner_block.scad>

screws = [M2_cap_screw, M2p5_pan_screw, M3_dome_screw, M4_dome_screw];

module do_corner_block(screw)
    if($preview) {
        fastened_corner_block_assembly(3, screw = screw);

        translate([0, 30])
            fastened_2screw_block_assembly(3, screw = screw);
    }
    else {
        corner_block(screw);

        translate([0, 30])
            2screw_block(screw);
    }
module corner_blocks()
    for(i = [0 : len(screws) - 1])
        translate([i * 30, 0])
            do_corner_block(screws[i]);

corner_blocks();
