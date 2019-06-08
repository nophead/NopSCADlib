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
//! Machine screws and wood screws with various head styles.
//
include <../core.scad>

use <washer.scad>
use <../utils/rounded_cylinder.scad>

function screw_head_type(type)        = type[2];     //! Head style hs_cap, hs_pan, hs_cs, hs_hex, hs_grub, hs_cs_cap, hs_dome
function screw_radius(type)           = type[3] / 2; //! Nominal radius
function screw_head_radius(type)      = type[4] / 2; //! Head radius
function screw_head_height(type)      = type[5];     //! Head height
function screw_socket_depth(type)     = type[6];     //! Socket or slot depth
function screw_socket_af(type)        = type[7];     //! Socket across flats
function screw_max_thread(type)       = type[8];     //! Maximum thread length
function screw_washer(type)           = type[9];     //! Default washer
function screw_nut(type)              = type[10];    //! Default nut
function screw_pilot_hole(type)       = type[11];    //! Pilot hole radius for wood screws, tap radius for machine screws
function screw_clearance_radius(type) = type[12];    //! Clearance hole radius
function screw_nut_radius(type) = screw_nut(type) ? nut_radius(screw_nut(type)) : 0; //! Radius of matching nut
function screw_boss_diameter(type) = max(washer_diameter(screw_washer(type)) + 1, 2 * (screw_nut_radius(type) + 3 * extrusion_width)); //! Boss big enough for nut trap and washer
function screw_head_depth(type, d) = screw_head_height(type) ? 0 : screw_head_radius(type) - d / 2; //! How far a counter sink head will go into a straight hole diameter d

function screw_longer_than(x) = x <=  5 ?  5 : //! Returns shortest screw length longer or equal to x
                                x <=  8 ?  8 :
                                x <= 10 ? 10 :
                                x <= 12 ? 12 :
                                x <= 16 ? 16 :
                                ceil(x / 5) * 5;

function screw_shorter_than(x) = x >= 20 ? floor(x / 5) * 5 : //! Returns longest screw length shorter than or equal to x
                                 x >= 16 ? 16 :
                                 x >= 12 ? 12 :
                                 x >= 10 ? 10 :
                                 x >=  8 ?  8 :
                                 x >=  6 ?  6 :
                                 5;

function screw_smaller_than(d) = d >= 2.5 && d < 3 ? 2.5 : floor(d); // Largest diameter screw less than or equal to specified diameter

module screw(type, length, hob_point = 0, nylon = false) { //! Draw specified screw, optionally hobbed or nylon
    description = str("Screw ", nylon ? "Nylon " : "", type[1], " x ", length, "mm", hob_point ? str(", hobbed at ", hob_point) : "");
    vitamin(str("screw(", type[0], "_screw, ", length, arg(hob_point, 0, "hob_point"), arg(nylon, false, "nylon"), "): ", description));

    head_type   = screw_head_type(type);
    rad         = screw_radius(type) - eps;
    head_rad    = screw_head_radius(type);
    head_height = screw_head_height(type);
    socket_af   = screw_socket_af(type);
    socket_depth= screw_socket_depth(type);
    socket_rad  = socket_af / cos(30) / 2;
    max_thread  = screw_max_thread(type);
    thread = max_thread ? min(length, max_thread) : length;
    shank  = length - thread;
    colour = nylon || head_type == hs_grub ? grey40 : grey80;


    module shaft(headless = 0) {
        point = screw_nut(type) ? 0 : 3 * rad;
        color(colour * 0.9 )
            rotate_extrude() {
                translate([0, -length + point])
                    square([rad, length - headless - point]);

                if(point)
                    polygon([
                        [0, -length], [0, point - length], [rad - 0.1, point - length]
                    ]);
            }
        if(shank >= 5)
            color(colour)
                translate_z(-shank)
                    cylinder(r = rad + eps, h = shank - headless);

    }

    explode(length + 10) {
        if(head_type == hs_cap) {
            color(colour) {
                cylinder(r = head_rad, h = head_height - socket_depth);

                translate_z(head_height - socket_depth)
                    linear_extrude(height = socket_depth)
                        difference() {
                            circle(head_rad);
                            circle(socket_rad, $fn = 6);
                        }

            }
            shaft();
        }
        if(head_type == hs_grub) {
            color(colour) {
                translate_z(-socket_depth)
                    linear_extrude(height = socket_depth)
                        difference() {
                            circle(r = rad);
                            circle(socket_rad, $fn = 6);
                        }

                shaft(socket_depth);
            }
        }
        if(head_type == hs_hex) {
            color(colour)
                cylinder(r = head_rad, h = head_height, $fn = 6);

            shaft();
        }
        if(head_type == hs_pan) {
            socket_rad = 0.6 * head_rad;
            socket_depth = 0.5 * head_height;
            socket_width = 1;
            color(colour) {
                rotate_extrude()
                    difference() {
                        rounded_corner(r = head_rad, h = head_height, r2 = head_height / 2);

                        translate([0, head_height - socket_depth])
                            square([socket_rad, 10]);
                    }

                linear_extrude(height = head_height)
                    difference() {
                        circle(socket_rad + eps);

                        square([2 * socket_rad, socket_width], center = true);
                        square([socket_width, 2 * socket_rad], center = true);
                    }
            }
            shaft();
        }

        if(head_type == hs_dome) {
            lift = 0.38;
            color(colour) {
                rotate_extrude() {
                    difference() {
                        intersection() {
                            translate([0, -head_height + lift])
                                circle(2 * head_height);

                            square([head_rad, head_height]);
                        }
                        translate([0, head_height - socket_depth])
                            square([socket_rad, 10]);
                    }
                }
                linear_extrude(height = head_height)
                    difference() {
                        circle(socket_rad + eps);
                        circle(socket_rad, $fn = 6);
                    }
            }
            shaft();
        }

        if(head_type == hs_cs) {
            head_height = head_rad;
            socket_rad = 0.6 * head_rad;
            socket_depth = 0.3 * head_rad;
            socket_width = 1;
            color(colour) {
                rotate_extrude()
                    difference() {
                        polygon([[0, 0], [head_rad, 0], [0, -head_height]]);

                        translate([0, -socket_depth + eps])
                            square([socket_rad + 0.1, 10]);
                    }

                translate_z(-socket_depth)
                    linear_extrude(height = socket_depth)
                        difference() {
                            circle(socket_rad + 0.1);

                            square([2 * socket_rad, socket_width], center = true);
                            square([socket_width, 2 * socket_rad], center = true);
                        }
            }
            shaft(socket_depth);
        }

        if(head_type == hs_cs_cap) {
            head_height = head_rad;
            color(colour) {
                rotate_extrude()
                    difference() {
                        polygon([[0, 0], [head_rad, 0], [0, -head_height]]);

                        translate([0, -socket_depth + eps])
                            square([socket_rad, 10]);
                    }

                translate_z(-socket_depth)
                    linear_extrude(height = socket_depth)
                        difference() {
                            circle(socket_rad + 0.1);

                            circle(socket_rad, $fn = 6);
                        }
            }
            shaft(socket_depth);
        }
    }
}

module screw_countersink(type) { //! Countersink shape
    head_type   = screw_head_type(type);
    head_rad    = screw_head_radius(type);
    head_height = head_rad;

    if(head_type == hs_cs || head_type == hs_cs_cap)
        translate_z(-head_height)
             cylinder(h = head_height, r1 = 0, r2 = head_rad);
}

module screw_and_washer(type, length, star = false, penny = false) { //! Screw with a washer which can be standard or penny and an optional star washer on top
    washer = screw_washer(type);

    translate_z(exploded() * 6)
        if(penny)
            penny_washer(washer);
        else
            washer(washer);

    translate_z(washer_thickness(washer)) {
        if(star) {
            translate_z(exploded() * 8)
                star_washer(washer);

            translate_z(washer_thickness(washer))
                screw(type, length);
        }
        else
            screw(type, length);
    }
}
