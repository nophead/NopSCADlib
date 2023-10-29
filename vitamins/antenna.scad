//
// NopSCADlib Copyright Chris Palmer 2023
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
//! Wifi Antennas
//
include <../core.scad>
use <../utils/tube.scad>
use <../utils/fillet.scad>
use <../utils/thread.scad>

//
//                             s    d    t    s       s       s    s   p
//                             c    i    h    o       t       p    p   e
//                             r    a    i    f       a       r    r   n
//                             e    m    c    t       r       i    i   n
//                             w    e    k                    n    n   y
//                                  t    n            d       g    g
//                                  e    e            i                v
//                                  r    s            a       d    t   e
//                                       s                    i    h   r
//                                                            a    k
ant_washer = ["ant_washer", 6.4,    12,  0.6, false, 9.6,   8.6,   1,   undef];





//                                      s    d    t    n     w              t                  t
//                                      c    i    h    y     a              r                  h
//                                      r    a    i    l     s              a                  r
//                                      e    m    c    o     h              p                  e
//                                      w    e    k    c     e                                 d
//                                           t    n          r              d
//                                           e    e    t                    e                  p
//                                           r    s    h                    p                  i
//                                                s    k                    t                  t
//                                                                          h                  c
//                                                                                             h

ant_nut  =   ["ant_nut",              6.25, 9.24, 1.8, 1.8,  ant_washer,    2,                 inch(1/36)];





function antenna_length(type)   = type[2];  //! Total length
function antenna_top_d(type)    = type[3];  //! Diameter at the top
function antenna_bot_d(type)    = type[4];  //! Diameter at the base
function antenna_split(type)    = type[5];  //! Split point
function antenna_straight(type) = type[6];  //! Length of the straight part
function antenna_hinge(type)    = type[7];  //! Hinge post width, z value of the pin, pin diameter, width reduction and slot width
function antenna_grip(type)     = type[8];  //! Grip d, h, h2
function antenna_rings(type)    = type[9];  //! List of ring z, thickness, depths
function antenna_gap(type)      = type[10]; //! Space for left panel, washers and nuts when screwed on fully.
function antenna_hole_r(type)   = 6.4 / 2;  //! Panel hole radius
function antenna_nut(type)      = ant_nut;  //! The nut

module antenna(type, thickness, angle)         //! Draw a WiFi antenna
{
    vitamin(str("antenna(", type[0], "): Antenna ", type[1]));

    split = antenna_split(type);
    bot_d = antenna_bot_d(type);
    g = antenna_grip(type);
    grip_d = g[0];
    grip_h1 = g[1];
    grip_h2 = g[2];
    h = antenna_hinge(type);
    hinge_w = h[0];
    pin_z = h[1];
    pin_d = h[2];
    cutout = bot_d - h[3];
    slot_w = h[4];
    w = hinge_w + 0.2;
    slot_height = pin_z - split + w / 2;
    gap = antenna_gap(type);
    translate_z(gap - washer_thickness(ant_washer)) explode(20){
        color(grey(25)) {
            translate_z(pin_z) rotate([0, angle, 0]) translate_z(-pin_z) {
                difference() {
                    // Main rod
                    hull() {
                        translate_z(split)
                            cylinder(d = bot_d, h = antenna_straight(type));

                        d = antenna_top_d(type);
                        translate_z(antenna_length(type) - d / 2)
                            sphere(d = d);
                    }

                    // Rings
                    for(r = antenna_rings(type))
                        translate_z(r[0])
                            tube(or = bot_d / 2, ir = antenna_top_d(type) / 2 - r[2], h = r[1], center = false);

                    // Slot for hinge
                    translate([w / 2, 0, split])
                        cube([2 * w, w, 2 * slot_height], center = true);

                    // Chamfer top of slot and cut out to avoid knife edge
                    translate([bot_d / 2, 0, split])
                        hull() {
                            cube([2 * cutout, bot_d, 2 * slot_height], center = true);

                            cube([eps, bot_d, 2 * (slot_height + cutout)], center = true);
                        }

                    // Fillet at the bottom
                    translate([bot_d / 2 - cutout, 0, split])
                        rotate([90, 0, 180])
                            fillet(r = bot_d / 2 - cutout, h = bot_d, center = true);

                    // Hole for hinge pin
                    translate_z(pin_z)
                        rotate([90, 0, 0])
                            cylinder(d = pin_d, h = bot_d + 1, center = true);
                }
                // Hinge pins
                for(side = [-1, 1])
                    hull() {
                        translate([0, side * (bot_d - pin_d) / 2, pin_z])
                            sphere(d = pin_d);

                        translate([0, side * slot_w / 2, pin_z])
                            rotate([90, 0, 0])
                                cylinder(d = pin_d, h = eps);
                    }
            }
            // Static part
            translate_z(grip_h1)
                cylinder(d = bot_d, h = split - grip_h1);

            // Hinge base
            translate_z(split)
                cube([hinge_w, hinge_w, 2 * (pin_z - w / 2 - split)], center = true);

            // Hinge clevice
            cheek_w = (hinge_w - slot_w) / 2;
            for(side = [-1, 1])
                translate([0, side * (cheek_w + slot_w) / 2, pin_z])
                    hull() {
                        rotate([90, 0, 0])
                            cylinder(d = hinge_w, h = cheek_w, center = true);

                        translate_z(split - pin_z)
                            cube([ hinge_w, cheek_w, eps], center = true);
                    }
        }
        // wire
        color("Chocolate")
            translate_z(split)
                cylinder(d = slot_w, h = slot_height, center = false);

        // Grip for thread
        rib_d = grip_d - bot_d;
        ribs = floor(PI * bot_d / rib_d);
        color(grey(15)) {
            cylinder(d = bot_d, h = grip_h1);

            for(i = [0 : ribs - 1])
                rotate(i * 360 / ribs)
                    translate([bot_d / 2, 0, (grip_h1 - grip_h2) / 2])
                        cylinder(d = rib_d, h = grip_h2, $fn = 32);
        }
    }

    color(gold) {
        translate_z(thickness)
            explode(7, explode_children = true)
                //spring_washer(ant_washer)
                    translate_z(exploded() ? 7 : 0)
                        nut(ant_nut);

        vflip()
            explode(25)
                star_washer(ant_washer);
    }

    explode(-40) {
        color(gold) {
            vflip() translate_z(washer_thickness(ant_washer)) {
                cylinder(d = 8 / cos(30), $fn = 6, h = 2);

                cylinder(d = 5 / cos(30), $fn = 6, h = 4.5);

                vflip() {
                    tube(or = 5.3 / 2, ir = 4.6 / 2, h = 11, center = false);

                    tube(or = 5 / 2,   ir = 4.0 / 2, h = 9, center = false);

                    difference() {
                        tube(or = 1 / 2,   ir = 0.6 / 2, h = 8.8, center = false);

                        translate_z(8.8)
                            cube([0.1, 2, 10], center = true);
                    }

                    male_metric_thread(6.25, inch(1/36), 10, center = false, top = -1, bot = -1, solid = false, colour = gold);
                }
            }
        }
        color(grey(95))
            translate_z(-washer_thickness(ant_washer))
                tube(or = 5 / 2, ir = 0.5, h = 8.8, center = false);

        color(grey(15))
            vflip() {
                cylinder(d = 2.5, h = 9);

                cylinder(d = 1.75, h = 20);
            }
    }
}
