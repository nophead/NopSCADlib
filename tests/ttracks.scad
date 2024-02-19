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

include <../vitamins/ttracks.scad>

module ttracks() {
    colours = [ "LightSlateGray", "red", "blue", "LightSlateGray", "LightSlateGray" ];

    for(i = [0: len(ttracks) -1])
        translate([(i < 4 ? 30 : 35) * i, 60])
            ttrack(ttracks[i], 120, colours[i]);

    for(i = [0: len(ttrack_bolts) -1])
        translate([30 * i, -15])
            ttrack_bolt(ttrack_bolts[i], 30);

    for(i = [0: len(ttrack_inserts) -1]) {
        translate([35 * (i + 3), -25])
            rotate([0,0,90])
                ttrack_insert(ttrack_inserts[i], 30, colour=colours[i]);
    }

    translate([-35,20,0]) {
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

    translate([-70,20,0]) {
        ttrack_assembly(ttrack_universal_19mm, 200);
        ttrack_place_bolt(ttrack_universal_19mm, 50)
            ttrack_bolt(ttrack_fixture(ttrack_universal_19mm), 30);

        ttrack_place_bolt(ttrack_universal_19mm, -60)
            ttrack_bolt(ttrack_fixture(ttrack_universal_19mm), 30);
    }

}

if($preview)
    let($show_threads = true)
        ttracks();
