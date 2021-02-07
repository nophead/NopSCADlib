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
use <../utils/layout.scad>

include <../vitamins/blowers.scad>

module blowers()
    layout([for(b = blowers) blower_width(b)], 5, true) let(b = blowers[$i]){
        screw = blower_screw(b);
        h = blower_lug(b);

        blower(b);

        blower_hole_positions(b)
            translate_z(h)
                screw_and_washer(screw, screw_length(screw, h + 5, 1, longer = true));
    }

if($preview)
    blowers();
