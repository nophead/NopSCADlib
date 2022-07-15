//
// NopSCADlib Copyright Chris Palmer 2021
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
//!  Brushless DC electric motor
//
include <../utils/core/core.scad>

use <rod.scad>
use <../utils/thread.scad>
use <../utils/tube.scad>


function BLDC_diameter(type)                    = type[1]; //! Diameter of motor
function BLDC_height(type)                      = type[2]; //! Height of motor including boss, if any, but excluding prop shaft
function BLDC_shaft_diameter(type)              = type[3]; //! shaft diameter
function BLDC_shaft_length(type)                = type[4]; //! Total shaft length
function BLDC_shaft_offset(type)                = type[5]; //! shaft offset from base
function BLDC_body_colour(type)                 = type[6]; //! Body colour
function BLDC_base_diameter(type)               = type[7]; //! Base diameter
function BLDC_base_height_1(type)               = type[8]; //! Base height 1
function BLDC_base_height_2(type)               = type[9]; //! Base height 2
function BLDC_base_hole_diameter(type)          = type[10]; //! Base hole diameter
function BLDC_base_holes(type)                  = type[11]; //! Base holes
function BLDC_base_open(type)                   = type[12]; //! Base open
function BLDC_wire_diameter(type)               = type[13]; //! Wire diameter
function BLDC_side_colour(type)                 = type[14]; //! Side colour
function BLDC_bell_diameter(type)               = type[15]; //! Bell diameter
function BLDC_bell_height_1(type)               = type[16]; //! Bell height 1
function BLDC_bell_height_2(type)               = type[17]; //! Bell height 2
function BLDC_bell_hole_diameter(type)          = type[18]; //! Bell hole diameter
function BLDC_bell_holes(type)                  = type[19]; //! Bell holes
function BLDC_bell_spokes(type)                 = type[20]; //! Bell spoke count
function BLDC_boss_diameter(type)               = type[21]; //! Boss diameter
function BLDC_boss_height(type)                 = type[22]; //! Boss height
function BLDC_prop_shaft_length(type)           = type[23]; //! Prop shaft length, including threaded section
function BLDC_prop_shaft_diameter(type)         = type[24]; //! Diameter of unthreaded portion of prop shaft
function BLDC_prop_shaft_thread_length(type)    = type[25]; //! Length of threaded section of prop shaft
function BLDC_prop_shaft_thread_diameter(type)  = type[26]; //! Diameter of threaded section of prop shaft

bldc_cap_colour  = grey(50);
bldc_shaft_colour = grey(90);
bldc_bearing_colour = grey(80);

module BLDC(type) { //! Draw specified BLDC motor
    vitamin(str("BLDC(", type[0], "): Brushless DC motor ", type[0]));

    body_colour = BLDC_body_colour(type);
    side_colour = BLDC_side_colour(type);
    body_diameter = BLDC_diameter(type);
    wall_thickness = 1;

    height = BLDC_height(type) - BLDC_boss_height(type);

    module feet(base_diameter) {
        holes = BLDC_base_holes(type);
        hole_count = is_list(holes) ? len(holes) : 4;
        for(i = [0 : 1 : hole_count - 1]) {
            spacing = is_list(holes) ? holes[i] : holes;
            radius = base_diameter / 2 - spacing / 2;
            rotate(i * 360 / hole_count + (hole_count == 4 ? 45 : 0))
                difference() {
                    hull() {
                        circle(r = radius);
                        translate([-spacing / 2, 0])
                            circle(r = radius);
                    }
                    translate([-spacing / 2, 0])
                        circle(d = BLDC_base_hole_diameter(type));
                }
        }
    }

    module cutout(d1, d2, r, h) {
        translate_z(-eps)
            linear_extrude(h + 2 * eps)
                hull() {
                    translate([d1 / 2, 0])
                        circle(r = r);
                    translate([d2 / 2, -r])
                        square([eps, 2 * r]);
                }
    }

    module cutout2(d1, r1, d2, r2, h) {
        translate_z(-eps)
            linear_extrude(h + 2 * eps)
                hull() {
                    translate([d1 / 2, 0])
                        circle(r = r1);
                    translate([d2 / 2, 0])
                        circle(r = r2);
                }
    }

    module base() {
        base_diameter = BLDC_base_diameter(type);
        h1 = BLDC_base_height_1(type);
        h2 = BLDC_base_height_2(type);
        color(body_colour)
            if (BLDC_base_open(type)) {
                linear_extrude(h1)
                    difference() {
                        union() {
                            feet(base_diameter);
                            circle(d = 3 * BLDC_shaft_diameter(type));
                        }
                        circle(d = 2 * BLDC_shaft_diameter(type));
                    }
                translate_z(h1)
                    cylinder(d = 3 * BLDC_shaft_diameter(type), h = h2);
            } else {
                difference() {
                    union() {
                        render(convexity = 8)
                            linear_extrude(h1)
                                difference() {
                                    circle(d = base_diameter);
                                    circle(d = 2 * BLDC_shaft_diameter(type));
                                    BLDC_base_screw_positions(type)
                                        circle(d = BLDC_base_hole_diameter(type));
                                }
                        rotate_extrude()
                            polygon([ [base_diameter / 2, 0], [body_diameter / 2, h1], [body_diameter / 2, h1+h2], [body_diameter / 2 - wall_thickness, h1 + h2], [body_diameter / 2 - wall_thickness, h1], [base_diameter / 2, h1] ]);
                    }
                r = body_diameter > 40 ? 2 : body_diameter * PI / (8 * 3);
                if (body_diameter > 40) {
                    r = 2;
                    // cutout for wires
                    translate_z(h2 /2)
                        cutout(base_diameter, body_diameter, 6, h1);
                    for (a = [90, 180, 270])
                        rotate(a) {
                            cutout(base_diameter - 2 * r, body_diameter, r, h1 + h2 / 2);
                            for (b = [-90 / 4, 90 / 4])
                                rotate(b)
                                    cutout(base_diameter - 5 * r, body_diameter, r, h1 + h2 / 2);
                        }
                } else {
                    r = body_diameter * PI / (8 * 3);
                    for (a = [0, 90, 180, 270])
                        rotate(a)
                            cutout(base_diameter, body_diameter, r, h1);
                }
            }
        }
        color(bldc_bearing_colour)
            translate_z(0.25)
                tube(or = BLDC_shaft_diameter(type), ir = BLDC_shaft_diameter(type) / 2, h = h1, center = false);

        if (show_threads)
            BLDC_base_screw_positions(type)
                female_metric_thread(BLDC_base_hole_diameter(type), metric_coarse_pitch(BLDC_base_hole_diameter(type)), h1, center = false, colour = body_colour);

        wire_diameter = BLDC_wire_diameter(type);
        for (i = [0 : 2])
            color(wire_diameter >= 3 ? ["yellow", grey(20), "red"][i] : grey(20))
                translate([body_diameter / 5, (i - 1) * wire_diameter, wire_diameter / 2 + 0.25 + (body_diameter > 40 ? h2/2 : 0)])
                    rotate([0, 90, 0])
                        cylinder(r = wire_diameter / 2, h = body_diameter / 2, center = false);

    } // end module base

    module bell() {
        bell_diameter = BLDC_bell_diameter(type);
        h1 = BLDC_bell_height_1(type);
        h2 = BLDC_bell_height_2(type);
        gap = BLDC_base_open(type) ? 0 : height > 20 ? 0.5 : 0.25;
        side_length = height - h2 - h1 - gap - BLDC_base_height_1(type) - BLDC_base_height_2(type);

        color(body_colour) {
            translate_z(height - h2) {
                difference() {
                    union() {
                        top_thickness = min(h2, 2);
                        render(convexity = 8)
                            translate_z(h2 - top_thickness)
                                linear_extrude(top_thickness)
                                    difference() {
                                        circle(d = bell_diameter);
                                        if (BLDC_shaft_length(type) > height)
                                            circle(d = BLDC_shaft_diameter(type));
                                        BLDC_bell_screw_positions(type)
                                            circle(d = BLDC_bell_hole_diameter(type));
                                    }
                        rotate_extrude()
                            polygon([ [bell_diameter/2, h2], [body_diameter/2, 0], [body_diameter/2, -h1], [body_diameter/2 - wall_thickness, -h1], [body_diameter/2 - wall_thickness, 0], [bell_diameter/2, h2 - top_thickness] ]);
                    }
                    spoke_count = BLDC_bell_spokes(type);
                    if (spoke_count % 4 == 0) {
                        r = body_diameter > 40 ? body_diameter / 15 : 2.5;
                        for (a = [0, 90, 180, 270])
                            rotate(a) {
                                cutout(bell_diameter + 2 * r, body_diameter, r, h2);
                                rotate(45) {
                                    cutout(bell_diameter, body_diameter, r, h2);
                                }
                            }
                    } else {
                        r1 = bell_diameter * PI / (spoke_count * 3);
                        r2 = body_diameter * PI / (spoke_count * 3);
                        for (i = [0 : 1 : spoke_count - 1])
                            rotate(i * 360 / spoke_count)
                                cutout2(bell_diameter, r1, body_diameter, r2, h2);
                    }
                } // end difference
            } // end translate

            if (BLDC_boss_height(type))
                translate_z(height)
                    tube(or = BLDC_boss_diameter(type)/2, ir = BLDC_shaft_diameter(type)/2, h = BLDC_boss_height(type), center = false);

        } // end colour

        color(BLDC_prop_shaft_thread_length(type) == 0 ? bldc_shaft_colour : body_colour)
            if (BLDC_prop_shaft_diameter(type))
                translate_z(height + BLDC_boss_height(type)) {
                    thread_diameter = BLDC_prop_shaft_thread_diameter(type);
                    unthreaded_length = BLDC_prop_shaft_length(type) - BLDC_prop_shaft_thread_length(type);
                    cylinder(d=BLDC_prop_shaft_diameter(type), h = unthreaded_length);
                    if (BLDC_prop_shaft_thread_length(type) > 0)
                        translate_z(unthreaded_length)
                            if (show_threads)
                                male_metric_thread(thread_diameter, metric_coarse_pitch(thread_diameter), BLDC_prop_shaft_thread_length(type), center = false);
                            else
                                cylinder(d = thread_diameter, h = BLDC_prop_shaft_thread_length(type));
                }
        color(side_colour)
            translate_z(height - h2 - h1  -side_length)
                tube(body_diameter/2, body_diameter/2 - wall_thickness, side_length, center = false);

        if (show_threads)
            translate_z(height)
                BLDC_bell_screw_positions(type)
                    vflip()
                        female_metric_thread(BLDC_bell_hole_diameter(type), metric_coarse_pitch(BLDC_bell_hole_diameter(type)), h2, center = false, colour = body_colour);
    } // end module bell

    base();
    bell();

    color(bldc_shaft_colour)
        translate_z(-BLDC_shaft_offset(type) - eps)
            not_on_bom()
                rod(d = BLDC_shaft_diameter(type), l = BLDC_shaft_length(type), center = false);

}

module BLDC_screw_positions(holes, n = 4) { //! Screw positions utility function
    hole_count = is_list(holes) ? len(holes) : 4;
    for($i = [0 : min(n, hole_count) - 1]) {
        spacing = is_list(holes) ? holes[$i] : holes;
        rotate($i * 360 / hole_count)
            translate([spacing / 2, 0])
                rotate(-$i * 90)
                    children();
    }
}

module BLDC_base_screw_positions(type, n = 4) { //! Positions children at the base screw holes
    if (BLDC_base_holes(type))
        rotate(is_list(BLDC_base_holes(type)) && len(BLDC_base_holes(type)) == 3 ? 180 : 45)
            BLDC_screw_positions(BLDC_base_holes(type), n)
                children();
}

module BLDC_bell_screw_positions(type, n = 4) { //! Positions children at the bell screw holes
    if (BLDC_bell_holes(type))
        rotate(is_list(BLDC_bell_holes(type)) && len(BLDC_bell_holes(type)) == 3 ? 30 : 0)
            BLDC_screw_positions(BLDC_bell_holes(type), n)
                children();
}
