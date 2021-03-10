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

include <../vitamins/sheets.scad>
use <../vitamins/insert.scad>

use <../printed/box.scad>

box = box(screw = M3_dome_screw, wall = 3, sheets = DiBond, top_sheet = PMMA3, base_sheet = DiBond6, feet = true, size = [150, 100, 70]);

include <../printed/box_assembly.scad>

module box_assembly() _box_assembly(box);

module box_test() {
    translate_z(box_height(box) / 2 + box_bezel_height(box, true))
        box_assembly();

    rows = 3;
    cols = 3;
    gap = 30;

    x_pitch = (box_width(box) + 2 * box_outset(box)) / cols + gap;
    y_pitch = (box_depth(box) + 2 * box_outset(box)) / rows + gap;
    for(x = [0 : cols - 1], y = [0 : rows - 1])
        translate([(x - cols / 2) * x_pitch + gap / 2, (y - rows / 2) * y_pitch + gap / 2])
            color((x + y) % 2 ? pp1_colour : pp2_colour) box_bezel_section(box, true, rows, cols, x, y);

    translate([-cols / 2 * x_pitch - 20, 0])
        for(i = [0 : 2])
            translate([0, (i - 1) * 20, 0])
                color(i % 2 ? pp1_colour : pp2_colour) box_corner_profile_section(box, i, 3);
}

if($preview)
    box_test();
