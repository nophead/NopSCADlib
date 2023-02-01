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
include <../vitamins/pcbs.scad>

module radials() {
    pcb = PERF60x40;
    pcb(pcb);

    for(i = [0 : len(rd_xtals) - 1])
        pcb_grid(pcb, [0.5, 1, 1.5, 9, 1][i], [0, 2, 6.5, 6.5, 11][i])
            rd_xtal(rd_xtals[i], value = rd_xtals[i][0], z = 1.5, pitch = [inch(0.1), inch(0.2), [inch(0.3), inch(0.3)], [inch(0.6), inch(0.3)], inch(0.2)][i]);
}

if($preview)
    radials();
