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
//! Toggle switches
//
include <../utils/core/core.scad>
use <nut.scad>
use <washer.scad>
use <../utils/thread.scad>
use <../utils/tube.scad>

function toggle_part(type)     = type[1];       //! Part description
function toggle_width(type)    = type[2];       //! Body width
function toggle_height(type)   = type[3];       //! Body height
function toggle_depth(type)    = type[4];       //! Body depth
function toggle_thickness(type)= type[5];       //! Metal thickness
function toggle_inset(type)    = type[6];       //! How far the metal is inset into the body
function toggle_colour(type)   = type[7];       //! Body colour
function toggle_od(type)       = type[8];       //! Barrel outside diameter
function toggle_id(type)       = type[9];       //! Barrel inside diameter
function toggle_thread(type)   = type[10];      //! Length of threaded barrel
function toggle_collar_d(type) = type[11];      //! Collar diameter
function toggle_collar_t(type) = type[12];      //! Collar thickness
function toggle_pivot(type)    = type[13];      //! Z offset of the pivot point above the top of the body
function toggle_angle(type)    = type[14];      //! Angle of the paddle
function toggle_paddle_l(type) = type[15];      //! Length of the paddle
function toggle_paddle_d1(type)= type[16];      //! Diameter at the top of the paddle
function toggle_paddle_w(type) = type[17];      //! Width at the top for non-spherical end
function toggle_nut(type)      = type[18];      //! Nut type
function toggle_washer(type)   = type[19];      //! Washer type
function toggle_pins(type)     = type[20];      //! Number of pins
function toggle_pin_l(type)    = type[21][0];   //! Pin length
function toggle_pin_w(type)    = type[21][1];   //! Pin width
function toggle_pin_t(type)    = type[21][2];   //! Pin thickness
function toggle_pin_vp(type)   = type[21][3];   //! Pin y pitch
function toggle_pin_hp(type)   = type[21][4];   //! Pin x pitch

function toggle_hole_radius(type) = toggle_od(type) / 2 + 0.1; //! Radius of the panel hole

module toggle(type, thickness) { //! Draw specified toggle switch with the nuts and washers positioned for the specified panel thickness
    vitamin(str("toggle(", type[0], ", 3): Toggle switch ", toggle_part(type)));

    inset = toggle_inset(type);
    t = toggle_thickness(type);
    h1 = toggle_depth(type) - t;
    h2 = toggle_depth(type) - inset;
    t2 = (toggle_od(type) - toggle_id(type)) / 2;
    nut = toggle_nut(type);
    washer = toggle_washer(type);
    chamfer = t2 / 2;
    thread = toggle_thread(type);
    stack = chamfer + nut_thickness(nut) + 3 * washer_thickness(washer) + thickness + toggle_collar_t(type);
    back_nut = thread - stack > nut_thickness(nut);
    gap = back_nut ? thread - stack -  nut_thickness(nut) : 0;

    module stack()
        washer(washer)
            translate_z(thickness)
                explode(20, true)    washer(washer)
                    explode(5, true) star_washer(washer)
                        explode(5)   nut(nut);

    translate_z(-washer_thickness(washer) - (back_nut ? nut_thickness(nut) : 0) - gap - toggle_collar_t(type)) {
        color(toggle_colour(type))
            translate_z(-h1 / 2 - t)
                cube([toggle_width(type), toggle_height(type), h1], center = true);

        if(show_threads) {
            d = toggle_od(type);
            pitch = inch(1/40);
            h = 5 * pitch * sqrt(3) / 16;

            male_metric_thread(d, pitch, thread, center = false, solid = false, colour = silver);

            color(silver)
                tube(or = d / 2 - h, ir = toggle_id(type) / 2, h = thread, center = false);
        }
        else
            color(silver)
                rotate_extrude()
                    difference() {
                        hull() {
                            square([toggle_od(type) / 2, thread - chamfer]);

                            square([toggle_od(type) / 2 - chamfer, thread]);
                        }
                        square([toggle_id(type) / 2, thread + 1]);
                    }

        color(silver) {
            if(toggle_collar_t(type))
                cylinder(d = toggle_collar_d(type), h = toggle_collar_t(type));

            translate_z(-t / 2)
                cube([toggle_width(type), toggle_height(type), t], center = true);

            translate_z(-h2 / 2)
                cube([toggle_width(type) + 2 * eps, toggle_height(type) - 2 * inset, h2], center = true);


            translate_z(toggle_pivot(type)) {
                angle = toggle_angle(type);
                l1 = toggle_paddle_l(type);
                l2 = toggle_thread(type) - toggle_pivot(type);
                l = l1 + l2;
                sphere(d = toggle_id(type));

                d1 = toggle_paddle_d1(type);
                d2 = toggle_id(type) - 2 * l2 * tan(abs(angle));
                d3 = d2 - (d1 - d2) * l2 / l1;

                hull() {
                    rotate([max(angle, 0), 0, 0])
                        if(toggle_paddle_w(type))
                            translate_z(l)
                                linear_extrude(eps, center = true)
                                    intersection() {
                                        circle(d = d1);

                                        square([d1 + 1, toggle_paddle_w(type)], center = true);
                                    }
                        else
                            translate_z(l - d1 / 2) sphere(d = d1);

                    rotate([max(angle, 0), 0, 0])
                        translate_z(l2)
                            cylinder(d = d2, h = eps);

                    sphere(d = d3);
                }
            }
        }
        pins = toggle_pins(type);
        rows = pins > 3 ? 2 : 1;
        color("gold")
            translate_z(-toggle_depth(type) - toggle_pin_l(type) / 2)
                linear_extrude(toggle_pin_l(type), center = true)
                    for(i = [0 : pins - 1]) {
                        x = rows < 2 ? 0 : (i % 2) - 0.5;
                        y = rows < 2 ? i - 1 : floor(i / 2) - 1;
                        translate([x * toggle_pin_hp(type), y * toggle_pin_vp(type)])
                            square([toggle_pin_w(type), toggle_pin_t(type)], center = true);
                    }

        not_on_bom()
            translate_z(gap + toggle_collar_t(type))
                if(back_nut)
                    nut(nut) stack();
                else
                    stack();
    }
}

module toggle_hole(type, h = 100)           //! Drill the hole in a panel
    drill(toggle_hole_radius(type), h);
