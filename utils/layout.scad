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

//
//! Layout objects in a line with equal gaps given a vector of their widths.
//
include <../global_defs.scad>

function layout_offset(widths, i, gap = 2) = //! Calculate the offset for the `i`th item
    i == 0 ? widths[0] / 2
           : layout_offset(widths, i - 1, gap) + widths[i - 1] / 2 + gap + widths[i] / 2;

module layout(widths, gap = 2, no_offset = false) //! Layout children passing `$i`
    translate([no_offset ? -widths[0] / 2 : 0, 0])
        for($i = [0 : 1 : len(widths) - 1])
            translate([layout_offset(widths, $i, gap), 0])
                children();
