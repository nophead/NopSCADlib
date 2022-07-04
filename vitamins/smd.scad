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
//! Surface mount components for PCBs.
//
include <../utils/core/core.scad>

use <../utils/tube.scad>
use <../utils/sweep.scad>

function smd_led_size(type) = type[1]; //! Body length, width and height
function smd_led_lens(type) = type[2]; //! Lens length width and height
function smd_led_height(type) =        //! Total height
    smd_led_size(type).z + smd_led_lens(type).z;

function smd_100th(x) = //! Convert dimension to 1/100" notation
    let(s = str(round(x / inch(0.01))))
        len(s) < 2 ? str("0", s) : s;

function smd_size(size) = //! Convert size to 1/100" notation
    str(smd_100th(size.x), smd_100th(size.y));

module smd_led(type, colour, cutout) { //! Draw an SMD LED with specified `colour`
    size = smd_led_size(type);
    vitamin(str("smd_led(", type[0], ", ", colour, "): SMD LED ", smd_size(size), " ", colour));

    lens = smd_led_lens(type);
    r = size.y * 0.32;
    $fn = 32;

    if(cutout)
        poly_drill(r = 2.85 / 2, h = 100, center = false); // For lightguide made from transparent PLA filament
    else {
        color("white")
            linear_extrude(size.z)
                difference() {
                    square([size.x, size.y], center = true);

                    for(end = [-1, 1])
                        translate([end * size.x / 2, 0])
                            circle(r);
                }

        color(gold)
             linear_extrude(size.z)
                intersection() {
                    square([size.x, size.y], center = true);

                    union()
                        for(end = [-1, 1])
                            translate([end * size.x / 2, 0])
                                ring(or = r, ir = r / 2);
                }

        color(colour, 0.9)
            translate_z(size.z)
                hull() {
                    cube([lens.x, lens.y, eps], center = true);

                    slant = lens.z * tan(15);
                    translate_z(lens.z / 2)
                        cube([lens.x - slant, lens.y - slant, lens.z], center = true);
                }
    }
}

function smd_res_size(type)    = type[1]; //! Body length, width and height
function smd_res_end_cap(type) = type[2]; //! End cap width
function smd_res_power(type)   = type[3]; //! Power rating in Watts

module smd_resistor(type, value) { //! Draw an SMD resistor with specified value
    size = smd_res_size(type);
    vitamin(str("smd_resistor(", type[0], ", ", value, "): SMD resistor ", smd_size(size), " ", value, " ", smd_res_power(type), "W"));

    t = 0.04;
    cap = smd_res_end_cap(type);
    color("white")
        translate_z(size.z / 2)
            cube([size.x - 2 * t, size.y, size.z - 2 * t], center = true);

    color(grey(20))
        translate_z(size.z - t)
            cube([size.x - 2 * cap, size.y, eps], center = true);

    color(silver)
        for(end = [-1, 1])
            translate([end * (size.x / 2 - cap / 2), 0, size.z / 2])
                cube([cap, size.y - 2 * eps, size.z], center = true);

    color("white")
        translate_z(size.z)
            linear_extrude(eps)
                resize([(size.x - 2 * cap) * 0.75, size.y / 2])
                    text(value, halign = "center", valign = "center");
}

function smd_cap_size(type)    = type[1]; //! Body length, width
function smd_cap_end_cap(type) = type[2]; //! End cap width

module smd_capacitor(type, height, value = undef) { //! Draw an SMD capacitor with specified height
    size = smd_cap_size(type);
    vitamin(str("smd_capacitor(", type[0], "): SMD capacitor ", smd_size(size), !is_undef(value) ? str(" ", value) : ""));

    cap = smd_cap_end_cap(type);

    t = 0.02;
    color("tan")
        translate_z(height / 2)
            cube([size.x - 2 * cap, size.y - 2 * t, height - 2 * t], center = true);

    color(silver)
        for(end = [-1, 1])
            translate([end * (size.x / 2 - cap / 2), 0, height / 2])
                cube([cap, size.y - 2 * eps, height], center = true);
}

function smd_sot_size(type)       = type[1];    //! Body length, width and height
function smd_sot_z(type)          = type[2];    //! Height above PCB surface
function smd_sot_lead_z(type)     = type[3];    //! Top of lead frame from top
function smd_sot_lead_pitch(type) = type[4];    //! Lead pitch
function smd_sot_lead_span(type)  = type[5];    //! Total span of leads
function smd_sot_lead_size(type)  = type[6];    //! Lead width, foot depth, lead thickness
function smd_sot_tab_width(type)  = type[7];    //! The wide lead at the top

module smd_sot(type, value) { //! Draw an SMD transistor
    vitamin(str("smd_sot(", type[0], "): ", type[0], " package ", value));

    size = smd_sot_size(type);
    z0 = smd_sot_z(type);
    z2 = z0 + size.z;
    z1 = z2 - smd_sot_lead_z(type);
    slant = 7;                              //! 7 degree body draft angle
    pitch = smd_sot_lead_pitch(type);
    span = smd_sot_lead_span(type);
    leads = floor(size.x / pitch) + 1;
    ls = smd_sot_lead_size(type);

    r = ls.z;
    gullwing = rounded_path([[0, 0, ls.z / 2], [0, ls.y - ls.z, ls.z / 2], r, [0, ls.y -ls.z + z1 - ls.z, z1 - ls.z / 2], r, [0, span / 2, z1 - ls.z / 2]], $fn = 32);

    color(grey(20))
        hull()
            for(z = [z0, z1, z2], inset = abs(z - z1) * tan(slant))
                translate_z(z)
                    cube([size.x - 2 * inset, size.y - 2 * inset, eps], center = true);

    color(silver) {
        for(i = [0 : leads - 1])
            translate([i * pitch - size.x / 2 + (size.x - (leads - 1) * pitch) / 2, -span / 2])
                sweep(gullwing, rectangle_points(ls.x, ls.z));

        rotate(180)
            translate([0, -span / 2])
                sweep(gullwing, rectangle_points(smd_sot_tab_width(type), ls.z));
    }

    color("white")
        translate_z(z0 + size.z)
            linear_extrude(eps)
                resize([size.x - 4 * (z2 - z1) * tan(slant), size.y / 2])
                    text(value, halign = "center", valign = "center");

}

function smd_soic_size(type)       = type[1];    //! Body length, width and height
function smd_soic_z(type)          = type[2];    //! Height above PCB surface
function smd_soic_lead_z(type)     = type[3];    //! Top of lead frame from top
function smd_soic_lead_pitch(type) = type[4];    //! Lead pitch
function smd_soic_lead_span(type)  = type[5];    //! Total span of leads
function smd_soic_lead_size(type)  = type[6];    //! Lead width, foot depth, lead thickness

module smd_soic(type, value) { //! Draw an SMD SOIC
    vitamin(str("smd_soic(", type[0], "): ", type[0], " package ", value));

    size = smd_soic_size(type);
    z0 = smd_soic_z(type);
    z2 = z0 + size.z;
    z1 = z2 - smd_soic_lead_z(type);
    slant = 5;                              //! 5 degree body draft angle
    pitch = smd_soic_lead_pitch(type);
    span = (smd_soic_lead_span(type) / 2);
    leads = floor(size.x / pitch) + 1;
    ls = smd_soic_lead_size(type);

    r = ls.z;
    gullwing = rounded_path([[0, 0, ls.z / 2], [0, ls.y - ls.z, ls.z / 2], r, [0, ls.y -ls.z + z1 - ls.z, z1 - ls.z / 2], r, [0, span / 2, z1 - ls.z / 2]], $fn = 32);

    color(grey(20))
        hull()
            for(z = [z0, z1, z2], inset = abs(z - z1) * tan(slant))
                translate_z(z)
                    cube([size.x - 2 * inset, size.y - 2 * inset, eps], center = true);

    color(silver) {
        for(i = [0 : leads - 1]) {
            translate([i * pitch - size.x / 2 + (size.x - (leads - 1) * pitch) / 2, -span])
                sweep(gullwing, rectangle_points(ls.x, ls.z));

        rotate(180)
            translate([0, -span / 2])
                translate([i * pitch - size.x / 2 + (size.x - (leads - 1) * pitch) / 2, -span / 2])
                    sweep(gullwing, rectangle_points(ls.x, ls.z));
        }

    }

    color("white")
        translate_z(z0 + size.z)
            linear_extrude(eps)
                resize([size.x * 0.9, size.y / 2])
                    text(value, halign = "center", valign = "center");

}
