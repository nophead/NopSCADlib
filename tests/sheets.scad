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

include <../vitamins/sheets.scad>
include <../vitamins/screws.scad>

width = 30;
2d = true;

module sheets() {
    rows = 2;
    n = ceil(len(sheets) / rows);
    w = width + 5;
    for(y = [0 : rows - 1], x = [0 : n - 1], s = y * n + x)
        if(s < len(sheets))
            translate([width / 2 + x * w, y * w])
                let(sheet = sheets[s], w = sheet_is_woven(sheet) ? width : undef)
                if(2d)
                    render_2D_sheet(sheet, w = w, d = w)
                        difference() {
                            sheet_2D(sheet, width, width, 2);

                            circle(3);
                        }
                else
                    render_sheet(sheet, w = w, d = w)
                        difference() {
                            sheet(sheet, width, width, 2);

                            translate_z(sheet_thickness(sheet) / 2)
                                screw_countersink(M3_cs_cap_screw);
                        }
}

if($preview)
    sheets();
