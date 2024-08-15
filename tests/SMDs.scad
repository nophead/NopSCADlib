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
include <../utils/core/core.scad>
use <../utils/layout.scad>

include <../vitamins/smds.scad>

module smds() {
    layout([for(r = smd_resistors) smd_res_size(r).x], 1)
        smd_resistor(smd_resistors[$i], ["1R0", "10", "100", "10M", "100K", "10u"][$i % 6]);

    translate([0, 3])
        layout([for(l = smd_leds) smd_led_size(l).x], 1)
            smd_led(smd_leds[$i], ["green", "blue", "red"][$i % 3]);

    translate([0, 6])
        layout([for(c = smd_capacitors) smd_cap_size(c).x], 1)
            let(c = smd_capacitors[$i])
                smd_capacitor(c, smd_cap_size(c).y * 0.8);

    translate([0, 9])
        layout([for(t = smd_tants) smd_tant_leads(t).x], 1)
            let(t = smd_tants[$i])
                smd_tant(t, ["105e","106J", "107A"][$i]);

    translate([0, 12.5])
        layout([for(d = smd_diodes) smd_diode_leads(d).x], 1)
            let(d = smd_diodes[$i])
                smd_diode(d, ["SS34"][$i]);

    translate([0, 24])
        layout([for(s = smd_sots) smd_sot_size(s).x], 1)
            let(s = smd_sots[$i])
                smd_sot(s, ["2N7000", "FZT851"][$i]);

    translate([0, 18])
        layout([for(p = smd_pots) smd_pot_size(p).x], 1)
            let(p = smd_pots[$i])
                smd_pot(p, "10K");

    translate([6, 18])
        layout([for(c = smd_coaxs) smd_coax_base_size(c).x], 1)
            let(c = smd_coaxs[$i])
                smd_coax(c);

    translate([0, 31])
        layout([for(s = smd_soics) smd_soic_size(s).x], 1)
            let(s = smd_soics[$i])
                smd_soic(s, s[0]);

    translate([0, 36.5])
        layout([for(i = smd_250V_fuses) smd_250V_fuse_size(i).x], 1)
            let(i = smd_250V_fuses[$i])
                smd_250V_fuse(i, "2A 250V");

    translate([0, 45])
        layout([for(i = smd_inductors) smd_inductor_leads(i).x], 1)
            let(i = smd_inductors[$i])
                smd_inductor(i, ["4R7", "10R"][$i % 2]);

    translate([20, 6])
         layout([for(q = smd_qfps) smd_qfp_body_size(q).x], 3)
            let(q = smd_qfps[$i])
                smd_qfp(q, ["ATSAM4S4BA"][$i]);
}

if($preview)
    smds();
