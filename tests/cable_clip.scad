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


sheet_thickness = 3;

cables = [
    [10, inch(0.05), true], 0, for(i = [1 : 9]) [i, 1.4], 0,  [1, 6], 0,
];

screw = M3_dome_screw;


module cable_clips() {
    for(i = [0 : ceil(len(cables) / 2) - 1]) {
        cable1 = cables[2 * i];
        cable2 = cables[2 * i + 1];
        translate([i * 21 + (!cable2 ? cable_clip_offset(screw, cable1) / 2 : 0), 0]) {
            insert = in([0, 3], i);
            if($preview) {
                cable_clip_assembly(screw, sheet_thickness, cable1, cable2, insert = insert, flip = i == 1);

                for(j = [0 : 1])
                    let(cable = cables[2 * i + j])
                        if(cable)
                            let(positions = cable_bundle_positions(cable))
                                for(i = [0 : len(positions) - 1])
                                    let(p = positions[i])
                                        translate([p.x + [-1, 1][j] * cable_clip_offset(screw, cable, insert = insert), 0, p.y])
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
