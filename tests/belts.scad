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

include <../vitamins/pulleys.scad>
use <../vitamins/insert.scad>
use <../utils/layout.scad>

module belt_test() {
    p2 = [-75, -50];
    p3 = [-75, 100];
    p4 = [ 75, 100];

    p5 = [ 75 + pulley_pr(GT2x20ob_pulley) - pulley_pr(GT2x16_plain_idler), +pulley_pr(GT2x16_plain_idler)];
    p6 = [-75 + pulley_pr(GT2x20ob_pulley) + pulley_pr(GT2x16_plain_idler), -pulley_pr(GT2x16_plain_idler)];

    module pulleys(flip = false) {
        translate(p2) rotate([0, flip ? 180 : 0, 0]) pulley_assembly(GT2x20ob_pulley);
        translate(p3) pulley_assembly(GT2x20_toothed_idler);
        translate(p4) pulley_assembly(GT2x20_toothed_idler);
        translate(p5) {
            pulley = GT2x16_toothed_idler;
            screw = find_screw(hs_cs_cap, pulley_bore(pulley));
            insert = screw_insert(screw);

            hflip(flip) {
                pulley_assembly(pulley);
                translate_z(pulley_height(pulley) + pulley_offset(pulley) + screw_head_depth(screw, pulley_bore(pulley)))
                    screw(screw, 20);

                translate_z(pulley_offset(pulley) - insert_length(insert))
                    vflip()
                        insert(insert);
            }
        }
        translate(p6) pulley_assembly(GT2x16_plain_idler);
    }

    path = [ [-40,  0, 0],
             [p6.x, p6.y, -pulley_pr(GT2x16_plain_idler)],
             [p2.x, p2.y, pulley_pr(GT2x20ob_pulley)],
             [p3.x, p3.y, pulley_pr(GT2x20ob_pulley)],
             [p4.x, p4.y, pulley_pr(GT2x20ob_pulley)],
             [p5.x, p5.y, pulley_pr(GT2x16_plain_idler)],
             [40,   0, 0],
           ];

    belt = GT2x6;
    belt(belt, path, open = true);
    pulleys();
    translate_z(20)
        hflip() {
            belt(belt, path, open = true, belt_colour = grey(90), tooth_colour = grey(50));
            pulleys(flip=true);
        }

    translate([-25, 0, 10])
        layout([for(b = belts) belt_width(b)], 10)
            rotate([0, 90, 0])
                belt(belts[$i], [[0, 0, 20], [0, 1, 20]], belt_colour = $i%2==0 ? grey(90) : grey(20), tooth_colour = $i%2==0 ? grey(70) : grey(50));

    // new example with open loop - this is a simplified example of the style used for example for the BLV 3D printer
    pulley = GT2x20ob_pulley;
    idler = GT2x16_plain_idler;
    corners = [[-75,-50],[75,100]];
    carriagepos = [0,0];
    carriagew = 80;

    points = [
        [carriagepos.x - carriagew / 2, carriagepos.y, 0],
        [corners[0].x + belt_pulley_pr(belt, pulley) + belt_pulley_pr(belt, idler), carriagepos.y - belt_pulley_pr(belt, idler), idler],
        [corners[0].x, corners[0].y, pulley],
        [corners[0].x, corners[1].y, idler],
        [corners[1].x, corners[1].y, idler],
        [corners[1].x, carriagepos.y + belt_pulley_pr(belt, idler), idler],
        [carriagepos.x + carriagew / 2, carriagepos.y, 0]
    ];
    translate_z(-30) {
        belt(belt, points, open=true, auto_twist=true);
        for (p = points)
            if (is_list(p.z))
                translate([p.x, p.y, 0])
                    pulley_assembly(p.z);
    }

}

if($preview)
    belt_test();
