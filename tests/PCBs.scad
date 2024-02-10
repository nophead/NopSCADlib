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
include <../vitamins/pcbs.scad>

use <../utils/layout.scad>

function spacing(p) = let(w = pcb_width(p)) w < 22 ? w + 3 : w + 7;

module pcbs() {
    layout([for(p = pcbs) spacing(p)], 0)
        translate([0, pcb_length(pcbs[$i]) / 2])
            rotate(90)
                pcb_assembly(pcbs[$i], 5 + $i, 3);

    translate([0, 65])
        layout([for(p = tiny_pcbs) pcb_length(p)], 3)
            translate([0, -pcb_width(tiny_pcbs[$i]) / 2])
                 pcb_assembly(tiny_pcbs[$i], 5 + $i, 3);

    translate([0, 120])
        layout([for(p = perfboards) pcb_length(p)], 10)
            translate([0, -pcb_width(perfboards[$i]) / 2])
                pcb_assembly(perfboards[$i], 5 + $i, 3);

    translate([0, 125])
        layout([for(p = big_pcbs) spacing(p)], 0)
            translate([0, pcb_length(big_pcbs[$i]) / 2])
                rotate(90)
                    pcb_assembly(big_pcbs[$i], 5 + $i, 3);

    for(p = pcbs_not_shown)
        hidden()
            pcb(p);
}
if($preview)
    let($show_threads = false)
        pcbs();
