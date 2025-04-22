//
// NopSCADlib Copyright Chris Palmer 2024
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

//
//! Generate storage bins compatible with Zack Freedman's Gridfinity design, see <https://www.youtube.com/watch?v=ra_9zU-mnl8&t=37s>
//!
//! Based on <https://gridfinity.xyz/specification>
//!
//! More examples [here](examples/Gridfinity).
//
include <../core.scad>
use <../utils/rounded_cylinder.scad>

pitch = 42;
z_step = 7;
width = 41.5;

foot_w = 37.2;
foot_h = 1.8;

lower_chamfer = 0.8;
upper_chamfer = 2.15;

corner_r  = 7.5 / 2;
foot_r    = 3.2 / 2;
chamfer_r = 1.6 / 2;

function gridfinity_bin(name, grid_x, grid_y, grid_z) = [name, [grid_x, grid_y, grid_z], lower_chamfer]; //! Constructor

function gridfinity_bin_name(type)          = type[0]; //! Name for the STL file
function gridfinity_bin_size(type)          = type[1]; //! Size in grid units

function gridfinity_base_z() = foot_h + lower_chamfer + upper_chamfer; //! height of base
function gridfinity_corner_r() = corner_r; //! Outside corner radius

function gridfinity_bin_size_mm(type) = //! Overall size of the bin
    let(s = gridfinity_bin_size(type))
        [(s.x - 1) * pitch + width, (s.y - 1) * pitch + width, s.z * z_step];

module gridfinity_bin(type) { //! Create a gridfinity bin, bits to cut out are passed as a child
    size = gridfinity_bin_size(type);
    w1 = width - 2 * (lower_chamfer + upper_chamfer);
    w2 = width - 2 * upper_chamfer;

    stl(gridfinity_bin_name(type)) {
        translate([-(size.x - 1) / 2 * pitch, -(size.y - 1) / 2 * pitch])
            for(x = [0 : size.x - 1], y = [0 : size.y - 1])
                translate([x * pitch, y * pitch]) {
                    hull() {
                        rounded_rectangle([w1, w1, eps], chamfer_r);

                        translate_z(lower_chamfer)
                            rounded_rectangle([w2, w2, foot_h + eps], foot_r);
                    }

                    hull() {
                        translate_z(lower_chamfer + foot_h)
                            rounded_rectangle([w2, w2, foot_h + eps], foot_r);

                        translate_z(lower_chamfer + foot_h + upper_chamfer)
                            rounded_rectangle([width, width, eps], corner_r);
                    }
                }

        difference() {
            base_z = gridfinity_base_z();
            translate_z(base_z)
                rounded_rectangle([(size.x - 1) * pitch + width, (size.y - 1) * pitch + width, size.z * z_step - base_z], corner_r);

            if($children)
                children(0);
        }
    }
}

module gridfinity_partition(type, cols = 1, rows = 1, wall = 1.6, iwall = squeezed_wall, bwall = 1, corner_r = 4) { //! Passed as child to hollow out specified partitions
    size = gridfinity_bin_size_mm(type);
    wx = (size.x - 2 * wall - (cols - 1) * iwall) / cols;
    wy = (size.y - 2 * wall - (rows - 1) * iwall) / rows;
    h = size.z - gridfinity_base_z() - bwall;

    for(x = [0 : cols - 1], y = [0 : rows - 1])
        translate([-size.x / 2 + wall + x * (wx + iwall) + wx / 2,
                   -size.y / 2 + wall + y * (wy + iwall) + wy / 2,
                   size.z + eps])
        vflip()
            rounded_top_rectangle([wx, wy, h + eps], corner_r, corner_r);
}
