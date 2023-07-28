//
// NopSCADlib Copyright Chris Palmer 2020
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


module axials() {
    pcb = PERF60x40;
    pcb(pcb);
    $solder = pcb_solder(pcb);

    pcb_grid(pcb, 0, 2)
        rotate(90)
            wire_link(0.8, inch(0.4));

    pcb_grid(pcb, 1, 1.5)
        rotate(90)
            wire_link(0.8, inch(0.3), 0.75, sleeve = [1.5, "red"]);

    pcb_grid(pcb, 0, 7)
        wire_link(0.8, 0, 5);

    for(i = [0 : len(ax_resistors) - 1]) {
        x = 2 * i + 3 + len(ax_diodes);
        pcb_grid(pcb, x, 1 + [0, 0.5, 1.5][i])
            rotate(90)
                ax_res(ax_resistors[i], [1000, 47000, 8200][i], 5);

        pcb_grid(pcb, x, 6.5)
            rotate(-90)
                ax_res(ax_resistors[i], [2200, 39000, 8250][i], 1, inch(0.1));
    }

    d_values = ["1N4148", "1N4007"];
    for(i = [0 : len(ax_diodes) - 1]) {
        pcb_grid(pcb, i + 2, 1 + [0, 0.5, 1.5][i])
            rotate(90)
                ax_diode(ax_diodes[i], d_values[i]);

        pcb_grid(pcb, i + 2, 6.5)
            rotate(-90)
                ax_diode(ax_diodes[i], d_values[i], inch(0.1));
    }
}

if($preview)
    axials();
