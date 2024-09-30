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
    pcb = PERF70x50;
    $solder = pcb_solder(pcb);
    pcb(pcb);

    translate([0, pcb_width(pcb) + inch(0.2)]) {
        pcb(pcb);

        pcb_grid(pcb, 10, 12)
            rd_module(rd_modules[2], "12V 900ma");

        for(i = [0 : len(rd_electrolytics) - 1])
            pcb_grid(pcb, i * 3, 2)
                rotate(-90)
                    rd_electrolytic(rd_electrolytics[i], "220uF35V", z = 3, pitch = inch(0.2));

        for(i = [0 : len(rd_box_caps) - 1])
            pcb_grid(pcb, 20, i * 4)
                rd_box_cap(rd_box_caps[i], "X2 rated film capacitor", ["0.1uF 250V", "0.47uF 250V"][i]);


        for(i = [0 : len(rd_cm_chokes) - 1])
            pcb_grid(pcb, 10.5, 2)
                rd_cm_choke(rd_cm_chokes[i], "3.5mH");

        pcb_grid(pcb, 4, 2.5)
            rotate(90)
                rd_coil(rd_coils[0], "4.7uH");
    }


    for(i = [0 : len(rd_xtals) - 1])
        pcb_grid(pcb, [0.5, 1, 1.5, 9, 1][i], [4, 6, 10.5, 10.5, 16][i])
            rd_xtal(rd_xtals[i], value = rd_xtals[i][0], z = 1.5, pitch = [inch(0.1), inch(0.2), [inch(0.3), inch(0.3)], [inch(0.6), inch(0.3)], inch(0.2)][i]);

    pcb_grid(pcb, 8.5, 15.5)
        rd_module(rd_modules[0], "012-HSL3F");

    pcb_grid(pcb, 20 -0.4, 9)
        rotate(-90)
            rd_module(rd_modules[1], "12V 250ma");

    for(i = [0 : len(rd_discs) - 1])
        pcb_grid(pcb, 1 + 2.5 * i, 1) {
            disc = rd_discs[i];
            pitch = rd_disc_pitch(disc);
            dx = round(pitch.x / inch(0.1)) * inch(0.1);
            dy = round(pitch.y / inch(0.1)) * inch(0.1);

            rotate(90 - atan2(dy, dx))
                rd_disc(disc, pitch = norm([dy, dx]), z = 0.5, value = ["10nF", "470V", "1nF Y2"][i]);
        }

     for(i = [0 : len(rd_transistors) - 1])
        pcb_grid(pcb, 5 + 3 * i, 5)
            rotate(90)
                rd_transistor(rd_transistors[i], ["ZTX853", "BC337"][i], lead_positions = inch(0.1) * [[-1, 0], [0, -sign(i)], [1, 0]]);
}

if($preview)
    radials();
