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
use <../utils/layout.scad>

include <../vitamins/kp_pillow_blocks.scad>
include <../vitamins/nuts.scad>

module kp_pillow_blocks() {
    screws = [M4_cap_screw, M5_cap_screw, M5_cap_screw];
    nuts = [M4_sliding_t_nut, M5_sliding_t_nut, M5_nut];
    layout([for(k = kp_pillow_blocks) 2 * kp_size(k)[1]])
        kp_pillow_block_assembly(kp_pillow_blocks[$i], screw_type = screws[$i], nut_type = nuts[$i]);
}

if($preview)
    kp_pillow_blocks();

