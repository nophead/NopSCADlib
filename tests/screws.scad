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

// Extra countersink depth
sink = 0; // [0 : 0.05: 1.0]

include <../core.scad>

module polysink_stl() {
    stl("polysink");

    cs_screws = [for(list = screw_lists, screw = list) if(screw_head_type(screw) == hs_cs_cap) screw];
    n = len(cs_screws);
    size = [n * 20, 20, 10];
    difference() {
        translate([-size.x / n / 2, $preview ? 0 : -size.y / 2])
            cube($preview ? [size.x, size.y / 2, size.z] : size);

        for(i = [0 : n - 1])
            let(s = cs_screws[i])
                translate([i * 20, 0]) {
                    translate_z(size.z)
                        screw_polysink(s, 2 * size.z + 1, sink = sink);

                    screw_polysink(s, 2 * size.z + 1, alt = true, sink = sink);
                }
    }
}

module screws() {
    for(y = [0 : len(screw_lists) -1])
        for(x = [0 : len(screw_lists[y]) -1]) {
            screw = screw_lists[y][x];
            if(screw) {
                 length = screw_head_type(screw) == hs_grub ? 6
                        : screw_radius(screw) <= 1.5 ? 10
                        : screw_max_thread(screw) ? screw_longer_than(screw_max_thread(screw) + 5)
                        : 30;
                translate([x * 20, y * 20])
                    screw(screw, length);
            }
        }
        translate([20, 40, -15])
            polysink_stl();
}

if($preview)
    let($show_threads = true)
        screws();
else
    polysink_stl();
