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
function jack_4mm_flange_radius() = 10.6 / 2; //! 4mm jack socket flange radius

module jack_4mm(colour, thickness, display_colour = false) { //! Draw a 4mm jack socket with nut positioned for specified panel thickness
    vitamin(str("jack_4mm(\"", colour, "\", 3", arg(display_colour, false), "): 4mm jack socket ", colour));
    flange_r = jack_4mm_flange_radius();
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
                square([flange_r, flange_t]);

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
        explode(-length, explode_children = true)
            vflip() {
                color(silver)
                    tube(ir = thread_d / 2, or = nut_d / 2, h = nut_t, center = false);

                if(show_threads && exploded())
                    female_metric_thread(thread_d, thread_p, nut_t, false, colour = silver);
            }
}

function jack_4mm_plastic_flange_radius() = 11.66 / 2; //! 4mm plastic jack socket flange radius

module jack_4mm_plastic(colour, thickness, display_colour = false) { //! Draw a 4mm plastic jack socket with nut positioned for specified panel thickness
    vitamin(str("jack_4mm_plastic(\"", colour, "\", 3", arg(display_colour, false), "): 4mm plastic jack socket ", colour));
    flange_r2 = jack_4mm_plastic_flange_radius();
    flange_d1 = 10.75;
    flange_t = 4;
    flange_id1 = 7.66;
    flange_id2 = 5.12;

    length = 19.6;
    sleaved_d = 6.4;
    thread = 16;
    thread_d = 8;
    thread_p = 0.75;

    barrel_d = 5.4;
    barrel = 18.5;

    solder_bucket = [3.75 / 2, 2.4 / 2, 5.6];

    nut_d = 10.8;
    nut_t = 3;

    colour = display_colour ? display_colour : colour;
    explode(length, offset = -length + flange_t) {
        color(colour) rotate_extrude() difference() {
            union() {
                polygon([
                    [flange_id2 / 2, -eps],
                    [flange_id1 / 2, flange_t],
                    [flange_d1 / 2,  flange_t],
                    [flange_r2,      -eps],
                ]);

                translate([0, -length])
                    square([sleaved_d / 2, length]);

                translate([0, -thread])
                    square([(thread_d - (show_threads ? thread_p : 0)) / 2, thread]);
            }
            square([4.1, 2 * length +1], center = true);
        }
        color(silver) rotate_extrude() {
            difference() {
                translate([0, -length + eps])
                    square([barrel_d / 2, length]);

                square([4, 2 * (barrel - 1)], center = true);
            }
            translate([solder_bucket.y, -length - solder_bucket.z])
                square([solder_bucket.x - solder_bucket.y, solder_bucket.z]);
        }
        if(show_threads)
            color(colour)
                translate_z(-thread)
                    male_metric_thread(thread_d, thread_p, thread, false, solid = false);

    }
    translate_z(-thickness)
        explode(-length)
            vflip()
                draw_nut(nut_d, thread_d, nut_t, thread_p, silver, show_threads);
}

function jack_4mm_shielded_hole_radius() = 12 / 2; //! Panel hole radius for 4mm shielded jack
function jack_4mm_shielded_nut_radius() = 14.4 / 2; //! Largest diameter of 4mm shielded jack

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

        draw_nut(6.3 / cos(30), thread_d, nut_t, thread_p, silver, show_threads);

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

function power_jack_radius() = 9.8 / 2; //! Power jack socket flange radius

power_jack_flat = 6.7;

module power_jack_hole(h = 0, poly = false, center = true)
    extrude_if(h, center = center)
        intersection() {
            if(poly)
                poly_circle(4);
            else
                drill(4, 0);

            square([power_jack_flat, 8], center = true);
        }

module power_jack(thickness) { //! Draw a power jack socket with nut positioned for specified panel thickness
    vitamin("power_jack(): Power jack socket");
    flange_r = power_jack_radius();
    flange_t = 3.3;
    flange_ir = power_jack_flat / 2 - eps;

    thread = 8;
    thread_d = 8;
    thread_p = 0.75;

    barrel_ir = 5.6 / 2;
    barrel_or = 8.9 / 2;
    barrel_above = 0.7;
    barrel_chamfer = 0.5;
    barrel_h = 3;

    pin_r = 2 / 2;
    pin_z = -2.3;

    nut_d = 10.8;
    nut_t = 1.9;

    length = 17.7;
    tag_w = 2;
    tag_hole_r = 1.2 / 2;
    tag_t1 = 0.4;
    tag_t2 = 0.5;
    tag_pitch = 5.64 - tag_t1 / 2 - tag_t2 / 2;

    colour = grey(20);
    explode(length, offset = -length + flange_t) {
        color(colour) {
            tube(or = flange_r, ir = flange_ir, h = flange_t, center = false);

            r = (thread_d - (show_threads ? thread_p : 0)) / 2;
            vflip()
                linear_extrude(thread)
                    intersection() {
                        ring(or = r, ir = flange_ir);

                        square([power_jack_flat, thread_d], center = true);
                    }

            translate_z(-thread)
                linear_extrude(1)
                    intersection() {
                        circle(r);

                        square([power_jack_flat, thread_d], center = true);
                    }
            if(show_threads) render()
                 intersection() {
                    color(colour)
                        translate_z(-thread)
                            male_metric_thread(thread_d, thread_p, thread, false, solid = false);

                    translate_z(-thread / 2)
                        cube([power_jack_flat, thread_d, thread], center = true);
                 }
            }

        color(silver) {
            translate_z(flange_t + barrel_above) {
                rotate_extrude()
                        polygon([
                            [barrel_ir,                  -barrel_h],
                            [barrel_ir,                  -barrel_chamfer],
                            [barrel_ir + barrel_chamfer, 0],
                            [barrel_or - barrel_chamfer, 0],
                            [barrel_or,                  -barrel_chamfer],
                            [barrel_or,                  -barrel_h],
                        ]);

                hull() {
                    translate_z(pin_z - pin_r)
                        sphere(pin_r);

                    translate_z(-flange_t - barrel_above - thread + 1)
                        cylinder(r = pin_r, h = eps);
                }
                for(side = [-1, 1], offset = side > 0 ? 1 : 0)
                    translate([0, side * tag_pitch / 2, - length + tag_w / 2 + offset])
                        rotate([90, 0, 0])
                            linear_extrude(side > 0 ? tag_t2 : tag_t1, center = true)
                                difference() {
                                    hull() {
                                        circle(d = tag_w);

                                        translate([0, length - flange_t - thread - tag_w - offset])
                                            square([tag_w, eps], center = true);
                                    }
                                    circle(tag_hole_r);
                                }

            }
        }
    }
    // Nut
    translate_z(-thickness)
        explode(-length)
            vflip()
                draw_nut(nut_d, thread_d, nut_t, thread_p, silver, show_threads);
}
