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
use <../utils/rounded_cylinder.scad>
use <pcb.scad>

function pmeter_size(type)        = type[2];  //! Body size including bezel height
function pmeter_bezel(type)       = type[3];  //! Bezel size
function pmeter_bezel_r(type)     = type[4];  //! Bezel radius
function pmeter_bevel(type)       = type[5];  //! Bezel bevel inset and start height or a radius
function pmeter_aperture(type)    = type[6];  //! Aperture length, width and bevel
function pmeter_tab(type)         = type[7];  //! Tab size
function pmeter_tab_z(type)       = type[8];  //! Tab vertical position
function pmeter_thickness(type)   = type[9];  //! Wall thickness if not closed
function pmeter_inner_ap(type)    = type[10]; //! Inner aperture
function pmeter_inner_ap_o(type)  = type[11]; //! Inner aperture offset
function pmeter_pcb(type)         = type[12]; //! Optional PCB for open types
function pmeter_pcb_z(type)       = type[13]; //! Distance of PCB from the back
function pmeter_pcb_h(type)       = type[14]; //! Component height from the front
function pmeter_buttons(type)     = type[15]; //! List of buttons

function pmeter_button_pos(type)    = type[0]; //! Button position
function pmeter_button_size(type)   = type[1]; //! Button size
function pmeter_button_r(type)      = type[2]; //! Button radius
function pmeter_button_colour(type) = type[3]; //! Button colour

function pmeter_depth(type) = pmeter_size(type).z - pmeter_bezel(type).z; //! Depth below bezel

module panel_meter_button(type) { //! Draw panel meter button
    size = pmeter_button_size(type);
    r = pmeter_button_r(type);
    color(pmeter_button_colour(type))
        translate(pmeter_button_pos(type))
            if(size.x)
                rounded_rectangle(pmeter_button_size(type), r);
            else
                cylinder(r = r, h = size.z);
}

module panel_meter(type) { //! Draw panel mounted LCD meter module
    vitamin(str("panel_meter(", type[0], "): ", type[1]));
    size = pmeter_size(type);
    bezel = pmeter_bezel(type);
    bevel = pmeter_bevel(type);
    t = pmeter_thickness(type);
    r = pmeter_bezel_r(type);
    h = size.z - bezel.z;
    ap = pmeter_aperture(type);
    tab = pmeter_tab(type);
    tab_z = pmeter_tab_z(type);
    pcb = pmeter_pcb(type);
    ap2 = pmeter_inner_ap(type);
    buttons = pmeter_buttons(type);

    color("#94A7AB")
        cube([ap.x, ap.y, 3 * eps], center = true);

    module corner(x, y)
        translate([x * (bezel.x / 2 - bevel), y * (bezel.y / 2 - bevel)])
            rounded_cylinder(r = r, r2 = bevel, h = bezel.z);

    color(grey(30)) union() {
        //
        // Bezel and aperture
        //
        difference() {
            if(is_list(bevel))
                hull() {
                    rounded_rectangle([bezel.x - 2 * bevel.x, bezel.y - 2 * bevel.x, bezel.z], r - bevel.x);
                    rounded_rectangle([bezel.x, bezel.y, bevel[1]], r);
                }
            else
                hull() {
                    corner(-1, -1);
                    corner(-1,  1);
                    corner( 1, -1);
                    corner( 1,  1);
                }

            hull() {
                r = max(0, -ap.z);
                if(ap.z > 0)
                    translate_z(bezel.z + eps)
                        cube([ap.x + ap.z, ap.y + ap.z, eps], center = true);

                translate_z(bezel.z + eps)
                    rounded_rectangle([ap.x, ap.y, bezel.z * 2], r, true);
            }
        }
        //
        // Body
        //
        translate_z(-h)
            linear_extrude(h)
                difference() {
                    square([size.x, size.y], center = true);

                    if(t)
                        square([size.x - 2 * t, size.y - 2 * t], center = true);
                }
        //
        // tabs
        //
        if(tab)
            for(end = [-1, 1])
                translate([end * (size.x / 2 + tab.x / 2), 0, -size.z + tab_z])
                    rotate([0, end * 10, 0])
                        translate_z(tab.z / 2)
                            cube([tab.x, tab.y, tab.z], center = true);

    }
    if(ap2)
        color("grey")
            linear_extrude(ap2.z)
                difference() {
                    square([ap.x, ap.y], center = true);

                    translate(pmeter_inner_ap_o(type))
                        square([ap2.x, ap2.y], center = true);
                }
    if(pcb) {
        vflip()
            translate_z(h - pcb_thickness(pcb) - pmeter_pcb_z(type))
                pcb(pcb);

        pcb_h = pmeter_pcb_h(type) - bezel.z;
        if(pcb_h > 0)
            %translate_z(-pcb_h / 2 - eps)
                cube([size.x - 2 * t - eps, size.y - 2 * t - eps, pcb_h], center = true);
    }
    if(buttons)
        for(b = buttons)
            panel_meter_button(b);
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
