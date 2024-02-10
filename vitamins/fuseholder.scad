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
//! 20mm panel mount fuse holder.
//
include <../core.scad>
include <spades.scad>
use <../utils/tube.scad>
use <../utils/thread.scad>

module fuseholder_hole(h = 100) //! Hole with flats for fuseholder
    extrude_if(h)
        intersection() {
            r = 12 / 2;
            if(cnc_bit_r)
                drill(r, 0);
            else
                poly_circle(r);

            square([100, 11], center = true);
        }

function fuseholder_diameter() = 18.8; //! Outside diameter of flange

module fuseholder(thickness) { //! Fuseholder with nut in place for specified panel thickness
    vitamin(str("fuseholder(6): Fuse holder 20mm"));
    flange_d = fuseholder_diameter();
    flange_t = 2;
    height = 33.2;
    thread_d = 12;
    thread_p = 1;
    thread = 15;
    bot_d = 10.4;
    top_d = 8.7;
    flat = 10.8;
    nut_d = 18.8;
    nut_t = 6;
    nut_flange_t = 1.5;
    spade = 5.4;
    contact_slot_z = 20;
    contact_slot_w = 3.2;
    contact_slot_d = 7;

    contact_w = 2.8;
    contact_t = 0.3;
    contact_l1 = 11;
    contact_l2 = 6;
    //
    // Nut
    //
    colour = grey(40);
    vflip()
        translate_z(thickness)
            explode(height, explode_children = true) {
                color(colour)
                    tube(or = nut_d / 2, ir = thread_d / 2, h = nut_flange_t, center = false);

                draw_nut(nut_d, thread_d, nut_t, thread_p, colour, show_threads && exploded() || thickness > thread);
            }
    //
    // Body
    //
    explode(height + 5, offset = -height - 4) {
        color(colour) {
            tube(or = flange_d / 2, ir = 5.2, h = flange_t, center = false);

            cylinder(r = 5, h = flange_t - 1);

            linear_extrude(flange_t)
                difference() {
                    circle(r = 5);

                    square([8, 1.5], center = true);
                }

            vflip() {
                if(!show_threads)
                    linear_extrude(thread)
                        intersection() {
                            circle(d = thread_d - 0.3);

                            square([100, 10.8], center = true);
                        }
                render() difference() {
                    translate_z(thread)
                        cylinder(d1 = bot_d, d2 = top_d, h = height - flange_t - thread);

                    for(side = [-1, 1])
                        translate([side * (contact_slot_d / 2 + 1) - 1, -contact_slot_w / 2, contact_slot_z])
                             cube([2, contact_slot_w, 100]);
                }
            }
            if(show_threads)
                vflip()
                    render() intersection() {
                        male_metric_thread(thread_d, thread_p, thread, false, colour = colour);

                        translate_z(thread / 2)
                            cube([100, 10.8, thread + 1], center = true);
                    }
        }
        //
        // Side contacts
        //
        color(silver) vflip()
            for(side = [-1, 1])
                translate([side * contact_slot_d / 2, 0, contact_slot_z])
                    rotate([0, -70, 90 - side * 90])
                        linear_extrude(contact_t, center = true) difference() {
                            hull() {
                                square([eps, contact_w], center = true);

                                translate([(side > 0 ? contact_l1 : contact_l2) - contact_w / 2, 0])
                                    circle(d = contact_w);
                            }
                            translate([(side > 0 ? contact_l1 : contact_l2) - contact_w / 2, 0])
                                circle(d = 1);
                        }
        //
        // Bottom contact
        //
        translate_z(-height + flange_t)
            vflip()
                rotate(45)
                    spade(spade3, spade);
    }
}
