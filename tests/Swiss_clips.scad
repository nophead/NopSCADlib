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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/swiss_clips.scad>
include <../vitamins/sheets.scad>

glass = glass2;
bed = AL6;
gap = sheet_thickness(bed) + sheet_thickness(glass);

module swiss_clips()
    layout([for(s = swiss_clips) sclip_length(s)], 5, true)
        let(s = swiss_clips[$i]) {
            swiss_clip(s);

            translate([0, 20]) {
                swiss_clip(s, gap);

                translate([20, 0, -5])
                    render_2D_sheet(bed)
                        difference() {
                            sheet_2D(bed, 40, 20, 1);

                            translate([-20, 0])
                                swiss_clip_hole(s, gap);
                        }

                translate([20, 0, -1 + eps])
                    render_sheet(glass) sheet(glass, 40, 20, 1);
            }
    }

if($preview)
    swiss_clips();
