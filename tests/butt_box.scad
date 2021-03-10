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

include <../printed/butt_box.scad>

$explode = 0;

box = bbox(screw = M3_dome_screw, sheets = DiBond, base_sheet = DiBond6, top_sheet = PMMA3, span = 250, size = [400, 300, 120]);

module bbox_assembly() _bbox_assembly(box);

module bbox_test() {
    translate_z(bbox_height(box) / 2)
        bbox_assembly();
}

if($preview)
    bbox_test();
else {
    gap = 2;
    bb = sheet_thickness(bbox_base_sheet(box));
    bt = sheet_thickness(bbox_top_sheet(box));
    h = bbox_height(box) + bb;
    h2 = h + bt;

    bbox_base_blank(box);

    translate([bbox_width(box) / 2 + gap + h / 2 - bb / 2, 0])
        rotate(90)
            bbox_right_blank(box);

    translate([-bbox_width(box) / 2 - gap - h / 2 + bb / 2, 0])
        rotate(-90)
            bbox_left_blank(box);

    translate([0, bbox_depth(box) / 2 + gap + h / 2 - bb / 2])
        rotate(180)
            bbox_back_blank(box);

    translate([0, -bbox_depth(box) / 2 - gap - h2 / 2 - (bt - bb) / 2])
        bbox_front_blank(box);

    translate([0, -bbox_depth(box) / 2 - gap - h2 - gap - bbox_depth(box) / 2 - sheet_thickness(bbox_sheets(box))])
        bbox_top_blank(box);
}
