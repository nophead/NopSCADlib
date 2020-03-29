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
//! 4mm jack sockets and binding posts. Each has a colour for the BOM entry and an optional alternative colour for display.
//! E.g. a "brown" socket for mains live needs to be displayed as "sienna" to look realistic.
//
include <../core.scad>
include <spades.scad>
use <../utils/tube.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/thread.scad>
use <ring_terminal.scad>

function jack_4mm_hole_radius() = 8/2; //! Panel hole radius for 4mm jack

module jack_4mm(colour, thickness, display_colour = false) { //! Draw a 4mm jack socket with nut positioned for specified panel thickness
    vitamin(str("jack_4mm(\"", colour, "\", 3", arg(display_colour, false), "): 4mm jack socket ", colour));
    flange_d = 10.6;
    flange_t = 3;
    flange_id = 4.6;
    length = 28.5;
    sleaved = 15;
    sleaved_d = 6.4;
    thread = 10.4;
    thread_d = 8;
    thread_p = 0.75;
    nut_d = 9.8;
    nut_t = 3;
    barrel_d = 5.4;
    barrel = 18.5;
    spade = 7;

    explode(length, offset = -length + flange_t) {
        color(display_colour ? display_colour : colour) rotate_extrude() difference() {
            union() {
                square([flange_d / 2, flange_t]);

                translate([0, -sleaved])
                    square([sleaved_d / 2, sleaved]);

            }
            square([flange_id, 100], center = true);
        }
        color(silver) rotate_extrude() difference() {
            union() {
                translate([0, -thread])
                    square([thread_d / 2 - (show_threads ? thread_p / 2 : 0), thread]);

                translate([0, -barrel])
                    square([barrel_d / 2, barrel]);
            }
            square([4, 2 * (barrel - 1)], center = true);
        }
        if(show_threads)
            translate_z(-thread)
                male_metric_thread(thread_d, thread_p, thread, false, solid = false, colour = silver);

        translate_z(-length + flange_t + spade)
            vflip()
                spade(spade4p8l, spade);
    }
    translate_z(-thickness)
        explode(-length)
            vflip() {
                color(silver)
                    tube(ir = thread_d / 2, or = nut_d / 2, h = nut_t, center = false);

                if(show_threads)
                    female_metric_thread(thread_d, thread_p, nut_t, false, colour = silver);
            }
}

function jack_4mm_shielded_hole_radius() = 12/2; //! Panel hole radius for 4mm shielded jack

module jack_4mm_shielded(colour, thickness, display_colour = false) { //! Draw a 4mm shielded jack
    vitamin(str("jack_4mm_shielded(\"", colour, "\", 3", arg(display_colour, false), "): 4mm shielded jack socket ", colour));
    flange_d = 14.5;
    flange_t = 2.5;
    flange_id = 4.6;
    sleaved = 21;
    sleaved_d = 10.7;
    thread = 14;
    thread_d = 12;
    thread_p = 0.75;
    nut_d = 14.4;
    nut_t = 5;
    length = 32;
    spade = 8.5;
    actual_colour = display_colour ? display_colour : colour;

    explode(length, offset = -length + flange_t) {
        color(actual_colour) {
            rounded_cylinder(r = flange_d / 2, h = flange_t, r2 = 1, ir = 4.5);

            rotate_extrude() difference() {
                union() {
                    translate([0, -sleaved])
                        square([sleaved_d  / 2, sleaved + flange_t]);

                    if(!show_threads)
                        translate([0, -thread])
                            square([thread_d / 2, thread]);
                }
                square([flange_id, 100], center = true);

                difference() {
                    square([9, 2 * sleaved - 1], center = true);
                    square([6, 2 * sleaved], center = true);
                }
            }

            if(show_threads)
                translate_z(-thread)
                    male_metric_thread(thread_d, thread_p, thread, false, solid = false);
        }

        color(silver)
            translate_z(-length + flange_t + spade - 0.5)
                cylinder(d = 4.8, h = 0.5);

        translate_z(-length + flange_t + spade)
            vflip()
                spade(spade4p8ll, spade);
    }

    translate_z(-thickness)
        explode(-length)
            vflip() {
                color(silver)
                    tube(ir = thread_d / 2, or = nut_d / 2, h = nut_t, center = false);

                if(show_threads)
                    female_metric_thread(thread_d, thread_p, nut_t, false, colour = silver);
            }
}

function post_4mm_diameter() = 13; //! Outer diameter of 4mm binding post

post_4mm_hole_radius = 7 / 2;
post_4mm_spigot_w = 1.1;
post_4mm_spigot_l = 1.2;
post_4mm_spigot_h = 2.5;

module post_4mm_hole(h = 100, poly = false) { //! Drill hole for 4mm binding post
    extrude_if(h) union() {
        r = cnc_bit_r + eps;
        if(poly)
            poly_circle(post_4mm_hole_radius);
        else
            drill(post_4mm_hole_radius, 0);

        hull() {
            translate([0, post_4mm_hole_radius + post_4mm_spigot_l - r])
                drill(r, 0);

            drill(r, 0);
        }
    }
}

module post_4mm(colour, thickness, display_colour = false) { //! Draw a 4mm binding post
    vitamin(str("post_4mm(\"", colour, "\", 3", arg(display_colour, false), "): 4mm jack binding post ", colour));

    actual_colour = display_colour ? display_colour : colour;
    d = post_4mm_diameter();
    base_h = 5;
    collar_t = post_4mm_spigot_h;

    post_od = 9.5;
    post_metal = 0.2;
    thread_d = 3.6;
    thread_p = 0.66;
    thread_l = 15;
    post_d = 7;
    post_h = 14;

    ringterm = ["", 6.3, 3.8, 16.7, 3, 1.6, 0.3, M4_dome_screw];

    module washer() color(silver) {
        washer_t = 0.65;

        tube(or = 7.6 / 2, ir = thread_d / 2, h = washer_t, center = false);

        translate_z(washer_t)
            children();
    }

    module nut() {
        nut_t = 2.3;

        color(silver)
            linear_extrude(nut_t) difference() {
                circle(d = 6.3 / cos(30), $fn = 6);

                circle(d = thread_d);
            }
        if(show_threads)
            female_metric_thread(thread_d, thread_p, nut_t, false, colour = silver);

        translate_z(nut_t)
            children();
    }

    module spigot()
        hull()
            for(end = [-1, 1])
                translate([0, post_4mm_hole_radius + end * (post_4mm_spigot_l - post_4mm_spigot_w / 2)])
                    circle(d = post_4mm_spigot_w);

    explode(20, offset = -thread_l) {
        color(actual_colour) {
            cylinder(d = d, h = base_h);

            translate_z(-collar_t)
                linear_extrude(base_h) {
                    circle(post_4mm_hole_radius - 0.1);

                    spigot();
                }

            translate_z(base_h + 1)
                for(i = [0 : 7])
                    rotate(i * 360 / 8)
                        render() difference() {
                            rotate_extrude(angle = 360 / 8)
                                polygon([
                                    [post_d / 2, 0],
                                    [post_d / 2, 2],
                                    [post_d / 2, 17.5],
                                    [11 / 2,     17.5],
                                    [12.5 / 2,   0]
                                ]);

                            rotate(180 /8)
                                hull() {
                                    translate([6.5, 0, 3])
                                        sphere(d = 2.5);

                                    translate([6, 0, 17.5])
                                        cylinder(d = 2.5, h = eps);
                                }
                }
        }

        color(silver) {
            translate_z(post_metal)
                cylinder(d = post_od, h = base_h);

            translate_z(base_h + post_metal + 0.1)
                cylinder(d = post_od, h = 2);

            rotate_extrude() difference() {
                square([post_d / 2, base_h + post_metal + post_h]);

                translate([0, base_h + post_metal + 1])
                    square([2, post_h]);

            }
            if(!show_threads)
                vflip()
                    cylinder(d = thread_d, h = thread_l);
        }
        if(show_threads)
            vflip()
                male_metric_thread(thread_d, thread_p, thread_l, false, colour = silver);
    }
    explode(-15)
        color(actual_colour) {
            translate_z(-thickness - base_h) {
                linear_extrude(base_h)
                    difference() {
                        circle(d = d);

                        circle(post_4mm_hole_radius);

                        offset(0.1) spigot();
                    }
                tube(or = d / 2, ir = thread_d / 2, h = collar_t, center = false);
            }
        }
    translate_z(-thickness - base_h)
        explode(-20, true)
            vflip()
                not_on_bom()
                    washer()
                    explode(5, true) nut()
                    explode(5, true) ring_terminal(ringterm)
                    explode(5, true) washer()
                    explode(5, true) nut();
}
