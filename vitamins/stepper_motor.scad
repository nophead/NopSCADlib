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
//! NEMA stepper motor model.
//
include <../core.scad>
include <ring_terminals.scad>

include <../vitamins/pin_headers.scad>
use <../utils/tube.scad>
use <../utils/thread.scad>
use <../utils/round.scad>
use <washer.scad>
use <rod.scad>

function NEMA_width(type)       = type[1]; //! Width of the square face
function NEMA_length(type)      = type[2]; //! Body length
function NEMA_radius(type)      = type[3]; //! End cap radius
function NEMA_body_radius(type) = type[4]; //! Body radius
function NEMA_boss_radius(type) = type[5]; //! Boss around the spindle radius
function NEMA_boss_height(type) = type[6]; //! Boss height
function NEMA_shaft_dia(type)   = type[7]; //! Shaft diameter
function NEMA_shaft_length(type)= type[8]; //! Shaft length above the face, if a list then a leadscrew: length, lead, starts
function NEMA_hole_pitch(type)  = type[9]; //! Screw hole pitch
function NEMA_cap_heights(type) = type[10]; //! Height of the end cap at the corner and the side

function NEMA_holes(type)       = [-NEMA_hole_pitch(type) / 2, NEMA_hole_pitch(type) / 2]; //! Screw positions for for loop
function NEMA_big_hole(type)    = NEMA_boss_radius(type) + 0.2; //! Clearance hole for the big boss
stepper_body_colour = "black";
stepper_cap_colour  = grey(50);
stepper_machined_colour = grey(90);

module NEMA_outline(type) //! 2D outline
    intersection() {
        side = NEMA_width(type);
        square([side, side], center = true);

        circle(NEMA_radius(type));
    }

module NEMA(type, shaft_angle = 0, jst_connector = false) { //! Draw specified NEMA stepper motor
    side = NEMA_width(type);
    length = NEMA_length(type);
    body_rad = NEMA_body_radius(type);
    boss_rad = NEMA_boss_radius(type);
    boss_height =NEMA_boss_height(type);
    shaft_rad = NEMA_shaft_dia(type) / 2;
    cap = NEMA_cap_heights(type)[1];
    cap2 = NEMA_cap_heights(type)[0];
    vitamin(str("NEMA(", type[0], "): Stepper motor NEMA", round(NEMA_width(type) / 2.54), " x ", length, "mm"));
    thread_d = 3;                                                       // Is this always the case?

    module cap_shape(end)
        round(0.5, $fn = 32) difference() {
            intersection() {
                square([side, side], center = true);

                circle(NEMA_radius(type), $fn = 360);
            }
            if(end > 0)
                for(x = NEMA_holes(type), y = NEMA_holes(type))
                    translate([x, y])
                        circle(d = thread_d);
        }

    color(stepper_body_colour)                                          // black laminations
        translate_z(-length / 2)
            linear_extrude(length - cap * 2, center = true)
                intersection() {
                    square([side, side], center = true);

                    circle(body_rad);
                }

    color(stepper_machined_colour) {
        tube(or = boss_rad, ir =  shaft_rad + 2, h = boss_height * 2); // raised boss

        linear_extrude(eps)
            cap_shape(1);
    }

    pcb_thickness = 1.6;
    header = jst_ph_header;
    socket_size = hdr_box_size(header);
    tabSize = [16, 4, cap - hdr_ra_height(header) - pcb_thickness];
    color(stepper_cap_colour) {                                     // aluminium end caps
        for(end = [-1, 1]) {
            translate_z(-length / 2 + end * (length - cap) / 2)
                linear_extrude(cap, center = true)
                    cap_shape(end);

            translate_z(-length / 2 + end * (length - cap2) / 2)
                linear_extrude(cap2, center = true)
                    difference() {
                        cap_shape(end);

                        circle(body_rad);
                    }
        }

        if(jst_connector)
            translate([-tabSize.x / 2, side / 2, -length])
                cube(tabSize);
    }

    if(jst_connector)
        translate([0, side / 2, -length + cap - hdr_ra_height(header)]) {
            rotate(180)
                not_on_bom()
                    jst_xh_header(header, 6, true);

            translate_z(-pcb_thickness / 2)
                color("green")
                    cube([socket_size.x + 5 * 2, tabSize.y * 2, pcb_thickness], true);
        }

    if(show_threads)
        for(x = NEMA_holes(type), y = NEMA_holes(type))
            translate([x, y, -cap / 2])
                female_metric_thread(thread_d, metric_coarse_pitch(thread_d), cap, colour = stepper_cap_colour);

    shaft =  NEMA_shaft_length(type);
    translate_z(-5)
        rotate(shaft_angle)
            if(!is_list(shaft))
                color(stepper_machined_colour)
                    cylinder(r = shaft_rad, h = shaft + 5);  // shaft
            else
                not_on_bom()
                    leadscrew(shaft_rad * 2, shaft.x + 5, shaft.y, shaft.z, center = false);

    if(!jst_connector)
        translate([0, side / 2, -length + cap / 2])
            rotate([90, 0, 0])
                for(i = [0 : 3])
                    rotate(225 + i * 90)
                        color(["red", "blue","green","black"][i])
                            translate([1, 0, 0])
                                cylinder(r = 1.5 / 2, h = 12, center = true);
}

module NEMA_screw_positions(type, n = 4) { //! Positions children at the screw holes
    pitch = NEMA_hole_pitch(type);

    for($i = [0 : 1 : min(n - 1, 4)])
        rotate($i * 90)
            translate([pitch / 2, pitch / 2])
                rotate($i * -90)
                    children();
}

module NEMA_screws(type, screw, n = 4, screw_length = 8, earth = undef) //! Place screws and optional earth tag
    NEMA_screw_positions(type, n)
        if($i != earth)
            screw_and_washer(screw, screw_length, true);
        else
            rotate($i > 1 ? 180 : 0)
                ring_terminal(M3_ringterm)
                    star_washer(screw_washer(screw))
                        screw(screw, screw_length);
