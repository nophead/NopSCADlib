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

include <../vitamins/screws.scad>

module screws()
for(y = [0 : len(screw_lists) -1])
    for(x = [0 : len(screw_lists[y]) -1]) {
        screw = screw_lists[y][x];
        if(screw) {
             length = screw_max_thread(screw)
                    ? screw_longer_than(screw_max_thread(screw) + 5)
                    : screw_head_type(screw) == hs_grub ? 6 : 30;
            translate([x * 20, y * 20])
                screw(screw, length);
        }
    }

if($preview)
    screws();
