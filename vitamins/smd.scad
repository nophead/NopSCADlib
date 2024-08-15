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
//!
//! Note that the value string for tantalum capacitors is the the capacitance in pico farads expressed as two digits plus an exponent plus a single letter voltage code.
//! E.g. 475A is 4.7uF 10V on the parts list.
//!
//! | Code | Voltage |
//! | ---- | ------- |
//! | e | 2.5 |
//! | G | 4 |
//! | J | 6.3 |
//! | A | 10 |
//! | C | 16 |
//! | D | 20 |
//! | E | 25 |
//! | V | 35 |
//! | H | 50 |
//
include <../utils/core/core.scad>

use <../utils/tube.scad>
use <../utils/sweep.scad>
use <../utils/sector.scad>

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
    vitamin(str("smd_led(", type[0], ", \"", colour, "\"): SMD LED ", smd_size(size), " ", colour));

    lens = smd_led_lens(type);
    r = size.y * 0.32;
    $fn = fn;

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
function smd_res_power(type)   = type[3]; //! Power rating in Watts, 0 for choke

module smd_resistor(type, value) { //! Draw an SMD resistor with specified value
    size = smd_res_size(type);
    power = smd_res_power(type);
    call = str("smd_resistor(", type[0], ", ", value, "): SMD ");
    if(power)
        vitamin(str(call, "resistor ", smd_size(size), " ", value, " ", power, "W"));
    else
        vitamin(str(call, "choke ", smd_size(size), " ", value));

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
    vitamin(str("smd_capacitor(", type[0], arg(value, undef, "value"), "): SMD capacitor ", smd_size(size), !is_undef(value) ? str(" ", value) : ""));

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
    vitamin(str("smd_sot(", type[0], ", \"", value, "\"): ", type[0], " package ", value));

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
    gullwing = rounded_path([[0, 0, ls.z / 2], [0, ls.y - ls.z, ls.z / 2], r, [0, ls.y -ls.z + z1 - ls.z, z1 - ls.z / 2], r, [0, span / 2, z1 - ls.z / 2]], $fn = fn);

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
    vitamin(str("smd_soic(", type[0], ", \"", value, "\"): ", type[0], " package ", value));

    size = smd_soic_size(type);
    z0 = smd_soic_z(type);
    z2 = z0 + size.z;
    z1 = z2 - smd_soic_lead_z(type);
    slant = 5;                              //! 5 degree body draft angle
    pitch = smd_soic_lead_pitch(type);
    span = (smd_soic_lead_span(type) / 2);
    ls = smd_soic_lead_size(type);
    leads = floor((size.x - ls.x) / pitch) + 1;

    r = ls.z;
    gullwing = rounded_path([
        [0, 0,                          ls.z / 2],
        [0, ls.y - r,                   ls.z / 2], r,
        [0, span - size.y / 2 - r, z1 - ls.z / 2], r,
        [0, span,                  z1 - ls.z / 2]
    ], $fn = fn);

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
            translate([i * pitch - size.x / 2 + (size.x - (leads - 1) * pitch) / 2, -span])
                sweep(gullwing, rectangle_points(ls.x, ls.z));
        }

    }

    color("white")
        translate_z(z0 + size.z)
            linear_extrude(eps)
                resize([size.x * 0.9, size.y / 2])
                    text(value, halign = "center", valign = "center");

}

function smd_diode_size(type)   = type[1]; //! Body length, width and height
function smd_diode_z(type)      = type[2]; //! Height above PCB surface
function smd_diode_lead_z(type) = type[3]; //! Top of lead frame from top
function smd_diode_leads(type)  = type[4]; //! Lead extent in x, width, thickness and gap
function smd_diode_colour(type) = type[5]; //! Body colour

module smd_diode(type, value) { //! Draw an SMD diode
    vitamin(str("smd_diode(", type[0], ", \"", value, "\"): ", type[0], " package ", value));

    slant = 5;                              //! 5 degree body draft angle
    size = smd_diode_size(type);
    z0 = smd_diode_z(type);
    z2 = z0 + size.z;
    z1 = z2 - smd_diode_lead_z(type);
    stripe = size.x / 5;
    leads = smd_diode_leads(type);
    gap = leads[3];
    gap2 = gap - leads.z * 2;

    color(smd_diode_colour(type))
        difference() {
            hull()
                for(z = [z0, z1, z2], inset = abs(z - z1) * tan(slant))
                    translate_z(z)
                        cube([size.x - 2 * inset, size.y - 2 * inset, eps], center = true);

            for(side = [-1, 1])
                translate([side * (size.x / 2 - (size.x - gap2) / 4), 0, eps])
                    cube([(size.x - gap2) / 2, size.y, 3 * leads.z], center = true);
        }

    color("white")
        translate([-stripe / 2, 0, z2])
            linear_extrude(eps)
                resize([0.9 * (size.x - stripe), size.y / 2])
                    text(value, halign = "center", valign = "center");

    color(grey(90)) {
        inset = (z2 - z1) * tan(slant);
        translate([size.x / 2 - stripe, -size.y / 2 + inset, z2])
            cube([stripe - inset, size.y - 2 * inset, eps]);
    }

    color(silver)
        translate_z(z1 / 2)
            rotate([90, 0, 0])
                linear_extrude(leads.y, center = true, convexity = 3)  let($fn = fn)
                    difference() {
                        rounded_square([leads.x, z1], 2 * leads.z);

                        rounded_square([leads.x - 2 * leads.z, z1 - 2 * leads.z], leads.z);

                        translate([0, - z1 / 2])
                            square([gap, leads.z * 2 + eps], center = true);
                    }

}

function smd_tant_size(type)   = type[1]; //! Body length, width and height
function smd_tant_z(type)      = type[2]; //! Height above PCB surface
function smd_tant_lead_z(type) = type[3]; //! Top of lead frame from top
function smd_tant_leads(type)  = type[4]; //! Lead extent in x, width, thickness and gap
function smd_tant_colours(type)= type[5]; //! Colours of body and stripe

module smd_tant(type, value) { //! Draw an SMD tantalum capacitor
    function dig(c) = let(x = ord(c) - ord("0")) assert(x >= 0 && x <= 9, "expected value in the form 475A for 4.7uF 10V") x;
    uF = is_undef(value) ? "" : str(" ,", (dig(value[0]) * 10 + dig(value[1])) * 10 ^ dig(value[2]) / 10^6, "uF");
    codes = "eGJACDEVH";
    voltages = [2.5, 4, 6.3, 10, 16, 20, 25, 35, 50];
    volts = is_undef(value) ? "" : let(c = value[3])
        assert(in(codes, c), str("expected the 4th character of value to be a voltage code: ", codes, ", got ", c))
            str(", ", voltages[search(c, codes)[0]], "V");
    vitamin(str("smd_tant(", type[0], arg(value, undef, "value"), "): SMD Tantalum capacitor package ", type[0][len(type[0]) -1], uF, volts));

    size = smd_tant_size(type);
    slant = 5;                              //! 5 degree body draft angle
    z0 = smd_tant_z(type);
    z2 = z0 + size.z;
    z1 = z2 - smd_tant_lead_z(type);
    stripe = size.x / 5;
    leads = smd_tant_leads(type);
    gap = leads[3];
    gap2 = gap - leads.z * 2;
    colours = smd_tant_colours(type);
    inset = (z2 - z1) * tan(slant);

    color(colours[0])
        difference() {
            hull()
                for(z = [z0, z1, z2], inset = abs(z - z1) * tan(slant))
                    translate_z(z)
                        cube([size.x - 2 * inset, size.y - 2 * inset, eps], center = true);

            for(side = [-1, 1])
                translate([side * (size.x / 2 - (size.x - gap2) / 4), 0, eps])
                    cube([(size.x - gap2) / 2, size.y, 3 * leads.z], center = true);
        }

    color("white") {
        w = 0.9 * (size.x - stripe - inset);
        translate([-size.x / 2 + inset + stripe + w / 2, 0, z2])
            linear_extrude(eps)
                resize([w, size.y / 2])
                    text(value, halign = "center", valign = "center");
    }

    color(colours[1]) {
        translate([-size.x / 2 + stripe * 0.2, -size.y / 2 + inset, z2])
            cube([(stripe - inset) * 0.8, size.y - 2 * inset, eps]);
    }

    color(silver)
        translate_z(z1 / 2)
            rotate([90, 0, 0])
                linear_extrude(leads.y, center = true, convexity = 3)  let($fn = fn)
                    difference() {
                        rounded_square([leads.x, z1], 2 * leads.z);

                        rounded_square([leads.x - 2 * leads.z, z1 - 2 * leads.z], leads.z);

                        translate([0, - z1 / 2])
                            square([gap, leads.z * 2 + eps], center = true);
                    }

}


function smd_inductor_size(type)   = type[1]; //! Body length, width and height
function smd_inductor_z(type)      = type[2]; //! Height above PCB surface
function smd_inductor_lead_z(type) = type[3]; //! Top of lead frame from top
function smd_inductor_leads(type)  = type[4]; //! Lead extent in x, width, thickness and gap
function smd_inductor_colour(type) = type[5]; //! Body colour

module smd_inductor(type, value) { //! Draw an SMD inductor
    vitamin(str("smd_inductor(", type[0], " ,\"", value, "\"): ", type[0], " package ", value));

    size = smd_inductor_size(type);
    z0 = smd_inductor_z(type);
    z1 = smd_inductor_lead_z(type);
    z2 = z0 + size.z;
    leads = smd_inductor_leads(type);
    gap = leads[3];
    gap2 = gap - leads.z * 2;

    $fs = fs; $fa = fa;

    color(smd_inductor_colour(type))
        render() difference() {
            translate_z(z0)
                rounded_rectangle(size, 0.5);

            for(side = [-1, 1])
                translate([side * (size.x / 2 - (size.x - gap2) / 4), 0, eps])
                    cube([(size.x - gap2) / 2, leads.y + 2 * leads.z, 3 * leads.z], center = true);
        }

    color("white")
        translate_z(z2)
            linear_extrude(eps)
                resize([0.9 * size.x, size.y / 2])
                    text(value, halign = "center", valign = "center");

    color(silver)
        translate_z(z1 / 2)
            rotate([90, 0, 0])
                linear_extrude(leads.y, center = true, convexity = 5) let($fn = fn)
                    difference() {
                        rounded_square([leads.x, z1], 2 * leads.z);

                        rounded_square([leads.x - 2 * leads.z, z1 - 2 * leads.z], leads.z);

                        translate([0, - z1 / 2])
                            square([gap, leads.z * 2 + eps], center = true);
                    }
}

function smd_pot_size(type)     = type[1]; //! Base length, width and height
function smd_pot_contacts(type) = type[2]; //! Contacts width, depth, pitch and width, depth, gap for center contact
function smd_pot_wiper(type)    = type[3]; //! Wiper diameter, offset, thickness, height, d1, d2, d3, d4
function smd_pot_cross(type)    = type[4]; //! Cross head slot for screwdriver
function smd_pot_flat(type)     = type[5]; //! Flat at the back of the wiper

module smd_pot(type, value) { //! Draw an SMD pot
    vitamin(str("smd_pot(", type[0], ", \"", value, "\"): ", type[0], " package ", value));

    size = smd_pot_size(type);
    contacts = smd_pot_contacts(type);
    contacts_pitch = contacts[2];
    centre_contact_w = contacts[3];
    centre_contact_d = contacts[4];
    centre_contact_gap = contacts[5];
    wiper = smd_pot_wiper(type);
    wiper_r1 = wiper.x / 2; // outer radius
    wiper_y = wiper.y;
    wiper_t = wiper.z;
    wiper_h = wiper[3];
    wiper_r2 = wiper[4] / 2;   // inner radius at the top
    wiper_r3 = wiper[5] / 2;   // inner radius at the bottom
    wiper_r4 = wiper[6] / 2;   // outer radius of rivet
    wiper_r5 = wiper[7] / 2;   // inner radius of rivet
    cross = smd_pot_cross(type);
    flat = smd_pot_flat(type);
    track_or = size.x * 0.48;
    track_ir = track_or * 0.6;

    $fs = fs; $fa = fa;

    color(grey(90))
        translate_z(size.z / 2)
            cube(size, center = true);

    color(silver) {
        for(side = [-1, 1])
            translate([side * contacts_pitch, -size.y / 2 + contacts.y / 2, size.z / 2])
                cube([contacts.x, contacts.y, size.z] + 2 * eps * [1,1,1], center = true);

        translate([0, size.y / 2 - centre_contact_d / 2, size.z / 2])
            render() difference() {
                cube([centre_contact_w, centre_contact_d + 2 * eps, size.z + 2 * eps], center = true);

                translate_z(size.z / 2)
                    cube([centre_contact_gap, centre_contact_d + 4 * eps, 2 * eps], center = true);
            }
        slope_angle = atan((wiper_h - size.z - wiper_t) / (wiper_r2 - wiper_r3));
        dx = wiper_t / tan(90 - slope_angle / 2);
        translate([0, wiper_y]) {
            render() difference() {
                rotate_extrude() {
                    polygon([
                        [wiper_r5,      size.z + wiper_t],
                        [wiper_r3,      size.z + wiper_t],
                        [wiper_r2,      wiper_h],
                        [wiper_r1,      wiper_h],
                        [wiper_r1,      wiper_h - wiper_t],
                        [wiper_r2 + dx, wiper_h - wiper_t],
                        [wiper_r3 + dx, size.z],
                        [wiper_r5,      size.z],
                    ]);
                    r = (wiper_r4 - wiper_r5) / 2;
                    translate([wiper_r5 + r, size.z + wiper_t])
                        circle(r, $fn = fn);
                }

                translate_z(size.z + wiper_t)
                    linear_extrude(wiper_h - size.z - wiper_t)
                        difference() {
                            union() {
                                square(cross, center = true);

                                rotate(90)
                                    square(cross, center = true);
                            }
                            circle(wiper_r4 + eps);
                        }

            }
            translate([0, -(wiper_r1 + cross.x / 2) / 2, wiper_h - wiper_t / 2])
                cube([flat, wiper_r1 - cross.x / 2, wiper_t], center = true);
        }
    }

    color("black")
        translate([0, wiper.y, size.z])
            linear_extrude(eps) {
                difference() {
                    sector(track_or, -270 / 2 + 90, 270 / 2 + 90);
                    circle(track_ir);
                }
                track_w = track_or - track_ir;
                track_l = wiper.y - track_ir / sqrt(2) + size.y / 2 - contacts.y;
                for(side = [-1, 1])
                    translate([side * (track_ir / sqrt(2) + track_w / 2), -wiper.y -size.y / 2 + track_l / 2 + contacts.y])
                        square([track_w, track_l], center = true);
            }
}

function smd_coax_base_size(type) = type[1]; //! Size of the insulating base
function smd_coax_base_r(type)    = type[2]; //! Corner radius of the base
function smd_coax_tube(type)      = type[3]; //! OD, ID, height
function smd_coax_groove(type)    = type[4]; //! Groove id, width and z
function smd_coax_pin_d(type)     = type[5]; //! Central pin diameter
function smd_coax_lug_size(type)  = type[6]; //! lug size
function smd_contact_size(type)   = type[7]; //! contact size

module smd_coax(type) { //! Draw an SMD coaxial connector
    vitamin(str("smd_coax(", type[0], "): SMD coax connector type: ", type[0]));

    size = smd_coax_base_size(type);
    t = smd_coax_tube(type);
    g = smd_coax_groove(type);
    chamfer = (t.x - g.x) / 2;
    pin_r = smd_coax_pin_d(type) / 2;
    lug = smd_coax_lug_size(type);
    contact = smd_contact_size(type);

    $fs = fs; $fa = fa;

    color(grey(90))
        translate_z(eps)
            rounded_rectangle(size, smd_coax_base_r(type));

    color(gold) {
        rotate_extrude() {
            polygon([
                [t.y / 2, 0.1],
                [t.y / 2, t.z],
                [g.x / 2, t.z],
                [t.x / 2, t.z - chamfer],
                [t.x / 2, g.z + g.y / 2 + chamfer],
                [g.x / 2, g.z + g.y / 2],
                [g.x / 2, g.z - g.y / 2],
                [t.x / 2, g.z - g.y / 2 - chamfer],
                [t.x / 2, 0.1],
            ]);
        }
        hull() {
            translate_z(t.z - pin_r)
                sphere(pin_r, $fn = fn);

            translate_z(0.1)
                cylinder(r = pin_r, h = eps, $fn = fn);
        }

        for(side = [-1, 1])
            translate([side * size.x / 2, 0, lug.z / 2])
                cube(lug, center = true);

        rotate(180)
            translate([-contact.x / 2, 0])
                cube([contact.x, contact.y / 2, contact.z]);

        cylinder(r = pin_r * 9 / 5, h = 0.1);

        tube_wall = (t.x - t.y) / 2;
        translate([-contact.x / 2, 0, (size.z - tube_wall) / 2])
            cube([contact.x, contact.y / 2, tube_wall]);
    }
}

function smd_qfp_body_size(type) = type[1]; //! Size of the body
function smd_qfp_slant(type)     = type[2]; //! Angle of the slope
function smd_qfp_pins(type)      = type[3]; //! Number of pins
function smd_qfp_pitch(type)     = type[4]; //! Pin pitch
function smd_qfp_pin_size(type)  = type[5]; //! Pins dimensions
function smd_qfp_gullwing(type)  = type[6]; //! Gullwing S, L, R1, R2

module smd_qfp(type, value) { //! Draw and SMD QFP package
    vitamin(str("smd_qfp(", type[0], ", \"", value, "\"): SMD chip: ", value, ", package : ", type[0]));

    size = smd_qfp_body_size(type);
    offset = size.z / 2 * tan(smd_qfp_slant(type));
    d = 3 * offset;
    pitch = smd_qfp_pitch(type);
    pin = smd_qfp_pin_size(type);
    pins =  smd_qfp_pins(type);
    g = smd_qfp_gullwing(type);
    s = g[0]; // length of top flat
    l = g[1]; // length of bottom flat
    r1 = g[2]; // top radius
    r2 = g[3] + pin.z / 2; // bottom radius
    pz = -size.z / 2 + pin.z / 2;
    gullwing = rounded_path([[-1, 0, 0], [s, 0, 0], r1, [pin.x - l + r2, 0, pz], r2, [pin.x, 0, pz]], $fn = fn);

    color(grey(20))
        hull() {
            translate_z(size.z / 2)
                linear_extrude(eps)
                    offset(delta = d, chamfer = true)
                        offset(-d)
                            square([size.x, size.y], center = true);

            translate_z(size.z - eps)
                linear_extrude(eps)
                    offset(-offset)
                        square([size.x, size.y], center = true);

            linear_extrude(eps)
                offset(-offset)
                    square([size.x, size.y], center = true);
        }

    color(silver)
        for(a = [0 : 90: 270])
            rotate(a)
                for(i = [0 : pins / 4 - 1])
                    translate([size.x / 2, (i - (pins / 4 - 1) / 2) * pitch, size.z / 2])
                        sweep(gullwing, rectangle_points(pin.y, pin.z));

    color("white")
        translate_z(size.z)
            linear_extrude(eps) {
                resize([size.x * 0.9, size.y / 8])
                    text(value, halign = "center", valign = "center");

                translate([(-(pins / 4 - 1) * pitch) / 2, (-(pins / 4 - 1) * pitch) / 2])
                    circle(r = pin.y, $fn = fn);
            }
}

function smd_250V_fuse_size(type) = type[1]; //! Bounding box of the body
function smd_250V_fuse_z(type)    = type[2]; //! Height of body above the PCB surface
function smd_250V_fuse_step(type) = type[3]; //! End cutout length, width and height
function smd_250V_fuse_base(type) = type[4]; //! Base length

module gcube(s) translate_z(s.z / 2) cube(s, center = true);

module smd_250V_fuse(type, value) { //! Draw an SMD mains fuse
    size = smd_250V_fuse_size(type);
    step = smd_250V_fuse_step(type);
    base = smd_250V_fuse_base(type);
    z = smd_250V_fuse_z(type);

    vitamin(str("smd_250V_fuse(", type[0], ", \"", value, "\"): SMD fuse: ", type[0], " ", value));

    color("LightYellow")
        translate_z(z) {
            gcube(base);

            translate_z(base.z)
                gcube([size.x - step.x * 2, size.y, size.z - base.z]);

            for(end = [-1, 1], side = [-1,1]) {
                translate([end * (size.x / 2 - step.x / 2), side * (size.y / 2 - step.y / 2)])
                    gcube(step);

                translate([end * (size.x / 2 - step.x / 2 - eps), 0])
                    gcube([step.x, size.y, base.z]);

            }
        }

    color(silver) {
        contact_h = step.z - 0.2;
        fuse_d = size.y - 2 * step.y;

        for(end = [-1, 1])
            translate([end * (size.x / 2 - step.x), 0, contact_h / 2])
                rotate([90, 0, 0])
                    linear_extrude(size.y - 2 * step.y, center = true)
                        difference() {
                            rounded_square([step.x * 2, contact_h], 0.2, $fn = fn);

                            translate([-step.x * end, 0])
                                square([step.x * 2, contact_h], center = true);
                        }

        translate_z(step.z - fuse_d / 2)
            rotate([0, 90, 0])
                linear_extrude(size.x - (2 * step.x - eps), center = true)
                    scale([1, size.y / fuse_d - eps])
                    rotate(90)
                        semi_circle(fuse_d / 2);

    }

    color("black")
        translate_z(z + size.z)
            linear_extrude(eps)
                resize([(size.x - 2 * step.x) * 0.9, size.y / 2])
                    text(value, halign = "center", valign = "center");
}
