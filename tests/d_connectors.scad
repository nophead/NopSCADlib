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

include <../vitamins/d_connectors.scad>

module d_connectors()
    for(socket = [false, true])
        translate([socket ? len(d_connectors) * (d_flange_width(d_connectors[0]) + 10) : 0, 0])
            layout([for(d = d_connectors) d_flange_width(d)], 10) let(d = d_connectors[$i])
                rotate(90) {
                    d_plug(d, socket, pcb = $i == 2, idc = $i == 1);

                    if(socket)
                        translate_z(d_flange_thickness(d))
                            d_connector_holes(d)
                                d_pillar();
                }

if($preview)
    let($show_threads = true)
        d_connectors();
