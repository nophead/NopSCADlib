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
use <../printed/ribbon_clamp.scad>
use <../vitamins/wire.scad>

ways = [8, 20];
screws = [M2_dome_screw, M3_cap_screw];

module ribbon_clamps()
    for(i = [0 : len(screws) - 1])
        translate([ribbon_clamp_length(ways[i]) / 2, i * 30])
            if($preview) {
                ribbon_clamp_fastened_assembly(ways[i], 3, screws[i]);

                ribbon_cable(ways[i], 100);
            }
            else
                ribbon_clamp(ways[i], screws[i]);

ribbon_clamps();
