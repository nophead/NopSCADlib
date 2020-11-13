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
//! Shaft couplings
//
include <../core.scad>
use <../utils/tube.scad>

function sc_length(type)       = type[1]; //! Coupling length
function sc_diameter(type)     = type[2]; //! Coupling outer diameter
function sc_diameter1(type)    = type[3]; //! Diameter of smaller shaft
function sc_diameter2(type)    = type[4]; //! Diameter of larger shaft

module shaft_coupling(type, colour = "silver") { //! Draw the shaft coupling
    vitamin(str("shaft_coupling(", type[0], "): Shaft coupling ", type[0]));

    length = sc_length(type);
    radius = sc_diameter(type) / 2;
    r1 = sc_diameter1(type) / 2;
    r2 = sc_diameter2(type) / 2;

    grub_length = 3;
    module grub_screw_positions() {
        grub_offset_z = 5;
        for(z = [-length / 2 + grub_offset_z, length / 2 - grub_offset_z])
            translate_z(z)
                for(a = [0, 90])
                    rotate([-90, 0, a])
                        translate_z(radius + 1)
                            children();
    }

    color(colour) {
        render(convexity=2) difference() {
            union() {
                translate_z(-length / 2)
                    tube(radius, r1, length / 2, false);

                tube(radius, r2, length / 2, false);
            }
            grub_screw_positions()
                rotate([180, 0, 0])
                    cylinder(r = screw_radius(M3_grub_screw), h = 5);
        }
    }

    grub_screw_positions()
        not_on_bom() screw(M3_grub_screw, grub_length);
}
