//
// NopSCADlib Copyright Chris Palmer 2022
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
use <../printed/cable_clip.scad>
use <../vitamins/wire.scad>
use <../utils/layout.scad>

screw = M3_dome_screw;
sheet_thickness = 3;

cables = [
    [10, inch(0.05), true], 0, for(i = [1 : 9]) [i, 1.4], 0,  [1, 6], 0,
];

clips = [for(i = [0 : ceil(len(cables) / 2) - 1]) let(c1= cables[2 * i], c2 = cables[2 * i + 1]) [c1, c2]];

function use_insert(i) = in([0, 3], i);
function use_nut(i)    = in([4],    i);

clip_lengths = [for(i = [0 : len(clips) - 1])
    let(c = clips[i], c1 = c.x, c2 = c.y, ins = use_insert(i), nut = use_nut(i))
        cable_clip_extent(screw, c1, insert = ins, nut = nut) + (c2 ? cable_clip_extent(screw, c2, insert = ins, nut = nut) : cable_clip_width(screw, insert = ins, nut = nut) / 2)];

module cable_clips() {
    layout(clip_lengths, 3, true) let(cable1 = clips[$i].x, cable2 = clips[$i].y) {
        insert = use_insert($i);
        nut = use_nut($i);
        translate([cable_clip_extent(screw, cable1, insert = insert, nut = nut) - clip_lengths[$i] / 2, 0]) {
            if($preview) {
                cable_clip_assembly(screw, sheet_thickness, cable1, cable2, insert = insert, nut = nut, flip = $i == 1);

                for(j = [0 : 1])
                    let(cable = clips[$i][j])
                        if(cable)
                            let(positions = cable_bundle_positions(cable))
                                for(i = [0 : len(positions) - 1])
                                    let(p = positions[i])
                                        translate([p.x + [-1, 1][j] * cable_clip_offset(screw, cable, insert = insert, nut = nut), 0, p.y])
                                            rotate([90, 0, 0])
                                                color([grey(20), "blue", "red", "orange", "yellow", "green", "brown", "purple", "grey", "white"][i])
                                                    cylinder(d = cable_wire_size(cable), h = 30, center = true);
            }
            else
                cable_clip(screw, cable1, cable2, insert = insert);
        }
    }
}

cable_clips();
