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

include <../vitamins/belts.scad>
include <../vitamins/screws.scad>
include <../vitamins/inserts.scad>
include <../vitamins/pulleys.scad>
use <../utils/layout.scad>

module belt_test() {
    p1 = [75,  -50];
    p2 = [-75, -50];
    p3 = [-75, 100];
    p4 = [75,  100];

    p5 = [75  - pulley_pr(GT2x20ob_pulley) - pulley_pr(GT2x16_plain_idler),  -pulley_pr(GT2x16_plain_idler)];
    p6 = [-75 + pulley_pr(GT2x20ob_pulley) + pulley_pr(GT2x16_plain_idler),  -pulley_pr(GT2x16_plain_idler)];

    translate(p1) pulley_assembly(GT2x20ob_pulley);
    translate(p2) pulley_assembly(GT2x20ob_pulley);
    translate(p3) pulley_assembly(GT2x20_toothed_idler);
    translate(p4) pulley_assembly(GT2x20_toothed_idler);

    translate(p5) {
        pulley = GT2x16_plain_idler;
        screw = find_screw(hs_cs_cap, pulley_bore(pulley));
        insert = screw_insert(screw);

        pulley_assembly(pulley);
        translate_z(pulley_height(pulley) + pulley_offset(pulley) + screw_head_depth(screw, pulley_bore(pulley)))
            screw(screw, 20);

        translate_z(pulley_offset(pulley) - insert_length(insert))
            vflip()
                insert(insert);

    }
    translate(p6) pulley_assembly(GT2x16_plain_idler);

    path = [ [p1.x, p1.y, pulley_pr(GT2x20ob_pulley)],
             [p5.x, p5.y, -pulley_pr(GT2x16_plain_idler)],
             [p6.x, p6.y, -pulley_pr(GT2x16_plain_idler)],
             [p2.x, p2.y, pulley_pr(GT2x20ob_pulley)],
             [p3.x, p3.y, pulley_pr(GT2x20ob_pulley)],
             [p4.x, p4.y, pulley_pr(GT2x20ob_pulley)]
           ];
    belt = GT2x6;
    belt(belt, path, 80, [0,  belt_pitch_height(belt) - belt_thickness(belt) / 2]);

    translate([-25, 0])
        layout([for(b = belts) belt_width(b)], 10)
            rotate([0, 90, 0])
                belt(belts[$i], [[0, 0, 20], [0, 1, 20]]);
}

if($preview)
    belt_test();
