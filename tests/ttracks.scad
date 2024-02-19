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
include <../utils/core/core.scad>
use <../utils/layout.scad>
use <../utils/maths.scad>

include <../vitamins/ttracks.scad>

module ttracks() {
    colours = [ "LightSlateGray", "red", "blue", "LightSlateGray", "LightSlateGray" ];
    gap = 8;
    widths = [for(t = ttracks) ttrack_width(t)];
    translate([0, 60])
        layout(widths, gap) {
            ttrack(ttracks[$i], 120, colours[$i]);

            if($i < len(ttrack_bolts))
                translate([0, -80])
                    ttrack_bolt(ttrack_bolts[$i], 30);

            let(i = $i - len(ttrack_bolts))
                if(i >= 0 && i < len(ttrack_inserts))
                    translate([0, -85])
                        rotate(90)
                            ttrack_insert(ttrack_inserts[i], 30, colour=colours[i]);
        }

    x = sumv(widths) + len(ttracks) * gap + ttrack_width(ttrack_universal_19mm) / 2;
    translate([x, 20]) {
        ttrack_assembly(ttrack_universal_19mm, 200);
        ttrack_place_bolt(ttrack_universal_19mm, 50)
            ttrack_bolt(ttrack_fixture(ttrack_universal_19mm), 30);

        ttrack_place_bolt(ttrack_universal_19mm, -60)
            ttrack_bolt(ttrack_fixture(ttrack_universal_19mm), 30);
    }

    x2 = x + ttrack_width(ttrack_universal_19mm) / 2 + gap + ttrack_width(ttrack_mitre_30mm) / 2;
    translate([x2, 20]) {
        ttrack_assembly(ttrack_mitre_30mm, 200);

        ttrack_place_insert(ttrack_mitre_30mm, 50)
            ttrack_insert(ttrack_fixture(ttrack_mitre_30mm), 30, 1, "red");

        ttrack_place_insert(ttrack_mitre_30mm, -60) {
            ttrack_insert(ttrack_fixture(ttrack_mitre_30mm), 60, 2, "red");
            ttrack_insert_hole_positions(ttrack_fixture(ttrack_mitre_30mm), 60, 2)
                translate_z(8)
                    screw(M6_hex_screw, 15);
        }
    }

}

if($preview)
    let($show_threads = true)
        ttracks();
