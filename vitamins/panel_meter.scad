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

//
//! Panel mounted digital meter modules
//!
//! Notes on the DSN_VC288:
//!
//! * The tabs aren't modelled because they can be fully retracted if the PCB is removed.
//! * The current connector isn't moddelled as it is awkwardly tall. I remove it and solder wires instead.
//
include <../utils/core/core.scad>

use <../utils/dogbones.scad>
use <pcb.scad>

function pmeter_size(type)      = type[2]; //! Body size including bezel height
function pmeter_bezel(type)     = type[3]; //! Bezel size
function pmeter_bezel_r(type)   = type[4]; //! Bezel radius
function pmeter_bevel(type)     = type[5]; //! Bezel bevel inset and start height
function pmeter_aperture(type)  = type[6]; //! Aperture length, width and bevel
function pmeter_tab(type)       = type[7]; //! Tab size
function pmeter_tab_z(type)     = type[8]; //! Tab vertical position
function pmeter_thickness(type) = type[9]; //! Wall thickness if not closed
function pmeter_pcb(type)       = type[10]; //! Optional PCB for open types
function pmeter_pcb_z(type)     = type[11]; //! Distance of PCB from the back

function pmeter_depth(type) = pmeter_size(type).z - pmeter_bezel(type).z; //! Depth below bezel

module panel_meter(type) { //! Draw panel mounted LCD meter module
    vitamin(str("panel_meter(", type[0], "): ", type[1]));
    size = pmeter_size(type);
    bezel = pmeter_bezel(type);
    bevel = pmeter_bevel(type);
    t = pmeter_thickness(type);
    r = pmeter_bezel_r(type);
    h = size.z - bezel.z;
    app = pmeter_aperture(type);
    tab = pmeter_tab(type);
    tab_z = pmeter_tab_z(type);
    pcb = pmeter_pcb(type);

    color("#94A7AB")
        cube([app.x, app.y, 3 * eps], center = true);

    color(grey30) union() {
        difference() {
            hull() {
                rounded_rectangle([bezel.x - 2 * bevel.x, bezel.y - 2 * bevel.x, bezel.z], r - bevel.x, center = false);
                rounded_rectangle([bezel.x, bezel.y, bevel[1]],r, center = false);
            }
            hull() {
                translate_z(bezel.z + eps) {
                    cube([app.x + app.z, app.y + app.z, eps], center = true);

                    cube([app.x, app.y, bezel.z * 2], center = true);
                }
            }
        }

        translate_z(-h)
            linear_extrude(h)
                difference() {
                    square([size.x, size.y], center = true);

                    if(t)
                        square([size.x - 2 * t, size.y - 2 * t], center = true);
                }

        if(tab)
            for(end = [-1, 1])
                translate([end * (size.x / 2 + tab.x / 2), 0, -size.z + tab_z])
                    rotate([0, end * 10, 0])
                        translate_z(tab.z / 2)
                            cube([tab.x, tab.y, tab.z], center = true);

    }
    if(pcb)
        vflip()
            translate_z(h - pcb_thickness(pcb) - pmeter_pcb_z(type))
                pcb(pcb);
}

module panel_meter_cutout(type, h = 0) { //! Make panel cutout
    size = pmeter_size(type);
    tab = pmeter_tab(type);
    extrude_if(h)
        offset(0.2) {
            dogbone_square([size.x, size.y]);

            if(tab)
                rounded_square([size.x + 2 * tab.x, tab.y + 2 * cnc_bit_r], r = cnc_bit_r, center = true);
        }
}
