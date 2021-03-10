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

include <../vitamins/components.scad>

module resistors()
    layout([for(r = resistors) resistor_diameter(r)], 10)
        resistor(resistors[$i]);

module al_clad_resistors()
    layout([for(a = al_clad_resistors) al_clad_width(a)], 5, true)
        rotate(90)
            al_clad_resistor_assembly(al_clad_resistors[$i], 4.7)
                screw(al_clad_hole(al_clad_resistors[$i]) > 3 ? M3_pan_screw : M2p5_pan_screw, 16);

module thermal_cutouts()
    layout([for(t = thermal_cutouts) tc_length(t)], 5, true)
        thermal_cutout(thermal_cutouts[$i]);

module components() {
    resistors();

    translate([0, 50])
        TO220("Generic TO220 package");

    translate([40, 50])
        panel_USBA();

    translate([80, 50])
        fack2spm();

    translate([0,80])
        thermal_cutouts();

    translate([0, 130])
        al_clad_resistors();
}

if($preview)
    components();
