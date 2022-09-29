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

include <../vitamins/leadnuts.scad>

module leadnuts()
    layout([for(n = leadnuts) leadnut_flange_dia(n)], 5)
        leadnut(leadnuts[$i]);

module leadnuthousings()
    layout([for(n = leadnuthousings) leadnuthousing_width(n)], 5) {
        rotate([0,0,270]) {
            leadnuthousing(leadnuthousings[$i]);
            explode(15)
                leadnuthousing_nut_position(leadnuthousings[$i])
                    leadnut(leadnuthousing_nut(leadnuthousings[$i]));
            explode(17 + leadnuthousing_nut_screw_length(leadnuthousings[$i]))
                translate_z(leadnuthousing_height(leadnuthousings[$i])/2)
                    leadnuthousing_nut_screw_positions(leadnuthousings[$i])
                        screw(leadnut_screw(
                            leadnuthousing_nut(leadnuthousings[$i])),
                            leadnuthousing_nut_screw_length(leadnuthousings[$i])
                        );
        }
    }

if($preview)
    let($show_threads = true) {
        leadnuts();
        translate([0,50,0])
            leadnuthousings();
    }
