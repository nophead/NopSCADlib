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

//
//! Actually just single cells at the moment, shown here with mating contacts in place.
//!
//! Note that the [Lumintop LM34](http://www.lumintop.com/lm34c-usb-rechargeable-18650-li-ion-battery.html) has a built in charger with a USB socket and two LEDs.
//!
//! The battery length includes its contacts and the origin is the centre of that length. As well as drawing the battery and contacts there are functions
//! exposing enough information to make a battery box.
//
include <../utils/core/core.scad>
use <spring.scad>
use <../utils/rounded_cylinder.scad>

function battery_length(type)        = type[2]; //! Total length including terminals
function battery_diameter(type)      = type[3]; //! Casing diameter
function battery_neg_dia(type)       = type[4]; //! Negative terminal diameter
function battery_pos_dia(type)       = type[5]; //! Positive terminal diameter
function battery_pos_height(type)    = type[6]; //! Positive terminal height above the casing
function battery_colour(type)        = type[7]; //! Casing colour
function battery_led_positions(type) = type[8]; //! LED positions for Lumintop
function battery_usb_offset(type)    = type[9]; //! USB connector offset from the top
function battery_contact(type)       = type[10]; //! Contact type

module battery_led_positions(type) { //! Position of the LEDs on a Lumintop
    posns = battery_led_positions(type);
    for($i = [0 : 1 : len(posns) - 1])
        translate([posns[$i].x, posns[$i].y, battery_length(type) / 2 - battery_pos_height(type)])
            children();
}

module battery(type) { //! Draw a battery
    vitamin(str("battery(", type[0], "): ", type[1]));
    len =  battery_length(type);

    l = 6;
    iw1 = 7;
    iw2 = 5.7;
    ih1 = 1;
    ih2 = 1.85;
    h = 2.65;
    t = 0.4;

    module D() {
        hull() {
            translate([-iw1 / 2, h - t - ih1])
                square([iw1, ih1]);

            translate([-iw2 / 2, h - t - ih2])
                square([iw2, ih2]);
        }
    }

    color(battery_colour(type)) render() difference() {
        translate_z(-battery_pos_height(type) / 2)
            cylinder(d = battery_diameter(type), h = len - battery_pos_height(type), center = true);

        if(battery_usb_offset(type))
            translate([battery_diameter(type) / 2, 0, len / 2 - battery_usb_offset(type) + h / 2])
                rotate([-90, 0, 90])
                    linear_extrude(l + 1)
                        offset(delta = t)
                            D();
    }
    color("gold")
        translate_z(len / 2 - battery_pos_height(type))
            rounded_cylinder(r = battery_pos_dia(type) / 2, h = battery_pos_height(type) + eps, r2 = 0.5);

    color("silver") {
        if(battery_usb_offset(type))
            translate([battery_diameter(type) / 2 - 1, 0, len / 2 - battery_usb_offset(type) + h / 2])
                rotate([-90, 0, 90]) {
                    linear_extrude(l)
                        difference() {
                            offset(t) D();
                            D();
                       }

                    translate_z(l - 1)
                        linear_extrude(1)
                            D();
                }

        translate_z(-len / 2)
            vflip()
                cylinder(d = battery_neg_dia(type), h = eps);

    }

    battery_led_positions(type)
        color(["red","green","blue"][$i])
            cylinder(d = 1.5, h = eps);
}

function contact_width(type)      = type[1]; //! Width of the flat part
function contact_height(type)     = type[2]; //! Height of the flat part
function contact_thickness(type)  = type[3]; //! Thickness of the metal
function contact_tab_width(type)  = type[4]; //! Width of the tab
function contact_tab_length(type) = type[5]; //! Length of the tab
function contact_pos(type)        = type[6]; //! Positive contact dimple height and top and bottom internal diameter
function contact_neg(type)        = type[7]; //! Negative spring height above the plate when compressed and the spring type

module battery_contact(type, pos = true) { //! Draw a positive or negative battery contact for specified battery
    vitamin(str("battery_contact(", type[0], ", ", pos, "): Battery ", pos ? "positive" : "negative", " contact"));

    neg = 9;

    tw = contact_tab_width(type);
    h = contact_height(type);
    hole_y = -contact_tab_length(type) + tw / 2;
    t = contact_thickness(type);

    color("silver") {
        rounded_rectangle([contact_width(type), h, t], r = 1);

        translate([0, -h / 2, t])
            rotate([90, 0, 0])
                linear_extrude(t)
                    difference() {
                        hull() {
                            translate([-tw / 2, -1])
                                square([tw, 1]);

                            translate([0, hole_y])
                                circle(d = tw);
                        }
                        translate([0, hole_y])
                            circle(tw / 4);
                    }

        if(pos) {
            p = contact_pos(type);

            cylinder(d1 = p.z + 2 * t, d2 = p.y + 2 * t, h = p.x);
        }
        else {
            p = contact_neg(type);

            not_on_bom()
                translate_z(t)
                    comp_spring(p.y, p.x - t);
        }
    }
}
