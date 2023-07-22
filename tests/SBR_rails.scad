//
// NopSCADlib Copyright Chris Palmer 2023
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
include <../vitamins/sbr_rails.scad>

use <../utils/layout.scad>
use <../vitamins/bearing_block.scad>

length = 200;
sheet = 3;

module sbr_rails()
    layout([for(r = sbr_rails) sbr_rail_base_width(r)], 10)
        rotate([90, 180,0]) {
            rail = sbr_rails[$i];
            sbr_rail(rail, length);
            carriage = sbr_rail_carriage(rail);
            screw = sbr_rail_screw(rail);

            sbr_bearing_block_assembly(carriage, sheet);

            sbr_screw_positions(rail, length)
                explode(20)
                    rotate([90,0,0])
                        screw(sbr_rail_screw(rail), 18);

         }

if($preview)
    sbr_rails();
