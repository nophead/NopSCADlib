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
use <rod.scad>

function NEMA_width(type)        = type[1]; //! Width of the square face
function NEMA_length(type)       = type[2]; //! Body length
function NEMA_radius(type)       = type[3]; //! End cap radius
function NEMA_body_radius(type)  = type[4]; //! Body radius
function NEMA_boss_radius(type)  = type[5]; //! Boss around the spindle radius
function NEMA_boss_height(type)  = type[6]; //! Boss height
function NEMA_shaft_dia(type)    = type[7]; //! Shaft diameter
function NEMA_shaft_length(type) = type[8]; //! Shaft length above the face, if a list then a leadscrew: length, lead, starts
function NEMA_hole_pitch(type)   = type[9]; //! Screw hole pitch
function NEMA_cap_heights(type)  = type[10]; //! Height of the end cap at the corner and the side
function NEMA_thread_d(type)     = type[11]; //! Screw hole diameter
function NEMA_black_caps(type)   = type[12]; //! End caps are black
function NEMA_end_connector(type)= type[13]; //! If has a connector then plug goes in the end rather than the side
function NEMA_shaft_length2(type)= type[14]; //! Rear shaft length if non-zero
function NEMA_shaft_bore(type)   = type[15]; //! Hollow shaft in non-zero

function NEMA_holes(type)       = [-NEMA_hole_pitch(type) / 2, NEMA_hole_pitch(type) / 2]; //! Screw positions for for loop
function NEMA_big_hole(type)    = NEMA_boss_radius(type) + 0.2; //! Clearance hole for the big boss
stepper_body_colour = grey(20);
stepper_cap_colour  = grey(50);
stepper_machined_colour = grey(90);

function NEMA_connection_pos(type, jst_connector = false) = let( //! Position of the wires or the connector
        side = NEMA_width(type),
        length = NEMA_length(type),
        cap = NEMA_cap_heights(type)[1],
        hdr = NEMA_end_connector(type) ? jst_zh_header : jst_ph_header,
        socket_size = hdr_box_size(hdr),
        end_conn_inset = socket_size.y - 2
    )
    jst_connector ? NEMA_end_connector(type) ? [0, side / 2 + hdr_y_offset(hdr) + socket_size.y / 2 - end_conn_inset, -length]
                                             : [0, side / 2 + socket_size.z,  hdr_y_offset(hdr) - socket_size.y / 2 - length + cap]
                  : [0, side / 2, -length + cap / 2];

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
    vitamin(str("NEMA(", type[0], "): Stepper motor NEMA", round(NEMA_width(type) / 2.54), " x ", length, "mm (", type[7],"x",type[8], " shaft)"));
    thread_d = NEMA_thread_d(type);
    corner_r = 0.9;
    bore = NEMA_shaft_bore(type);
    end_connector = NEMA_end_connector(type) && jst_connector;
    header = end_connector ? jst_zh_header : jst_ph_header;
    socket_size = hdr_box_size(header);
    pcb_thickness = 1.6;
    tabSize = [16, 4, cap - hdr_ra_height(header) - pcb_thickness];
    pins = 6;
    end_conn_w = socket_size.x + hdr_pitch(header) * (pins - 1);
    end_conn_inset = socket_size.y - 2;

    module cap_shape(end)
        difference() {
            round(corner_r, $fn = 32) intersection() {
                square([side, side], center = true);

                circle(NEMA_radius(type), $fn = 360);
            }
            if(end > 0)
                for(x = NEMA_holes(type), y = NEMA_holes(type))
                    translate([x, y])
                        circle(d = thread_d);

            if(bore)
                circle(d = bore + eps);

            if(end_connector && end < 0)
                translate([0, side / 2])
                    square([end_conn_w, end_conn_inset * 2], true);
        }

    color(stepper_body_colour)                                          // black laminations
        translate_z(-length / 2)
            linear_extrude(length - cap * 2, center = true)
                difference() {
                    round(corner_r, $fn = 32)
                        intersection() {
                            square([side, side], center = true);

                            circle(body_rad);
                        }
                    circle(d = bore + eps);
                }

    color(stepper_machined_colour) {
        tube(or = boss_rad, ir =  shaft_rad + 2, h = boss_height * 2); // raised boss

        linear_extrude(eps)
            cap_shape(1);
    }

    wing_t = 0.5;  // end connector side wings
    color(NEMA_black_caps(type) ? "black" : stepper_cap_colour) {                                     // aluminium end caps
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
            if(end_connector)
                for(x = [-1, 1])
                    translate([x * (end_conn_w / 2 + wing_t / 2), side / 2 - end_conn_inset, -length + cap / 2])
                        cube([wing_t, socket_size.y * 2, cap], center = true);
            else
                translate([-tabSize.x / 2, side / 2, -length])
                    cube(tabSize);
    }

    if(jst_connector) not_on_bom()
        if(end_connector) {
            translate([0, side / 2 + hdr_y_offset(header) + socket_size.y / 2 - end_conn_inset, -length + socket_size.z])
                rotate([180, 0, 0])
                    jst_xh_header(header, pins, false, smt = true);

            h = cap - socket_size.z;
            translate([0, side / 2 + socket_size.y / 2 - end_conn_inset, -length + socket_size.z + h / 2])
                color(grey(70))
                    cube([end_conn_w, socket_size.y, h], center = true);

            }
        else
            translate([0, side / 2, -length + cap - hdr_ra_height(header)]) {
                rotate(180)
                    jst_xh_header(header, pins, true, smt = true);

                translate_z(-pcb_thickness / 2)
                    color("green")
                        cube([socket_size.x + 5 * 2, tabSize.y * 2, pcb_thickness], true);
            }

    if(show_threads)
        for(x = NEMA_holes(type), y = NEMA_holes(type))
            translate([x, y, -cap / 2])
                female_metric_thread(thread_d, metric_coarse_pitch(thread_d), cap, colour = stepper_cap_colour);

    shaft =  NEMA_shaft_length(type);
    shaft2 = NEMA_shaft_length2(type);
    translate_z(-length + eps - shaft2)
        rotate(shaft_angle)
            if(!is_list(shaft))
                color(stepper_machined_colour)
                    tube(or = shaft_rad, ir = bore / 2, h = shaft + length + shaft2, center = false);  // shaft
            else
                not_on_bom()
                    leadscrew(shaft_rad * 2, shaft.x + length + shaft2, shaft.y, shaft.z, center = false);

    if(jst_connector == false)
        translate([0, side / 2, -length + cap / 2])
            rotate([90, 0, 0])
                for(i = [0 : 3])
                    rotate(225 + i * 90)
                        color(["red", "green", "black", "blue"][i])
                            translate([1.48 / sqrt(2), 0, 0])
                                cylinder(d = 1.48, h = 12, center = true);
}

module NEMA_screw_positions(type, n = 4) { //! Positions children at the screw holes
    pitch = NEMA_hole_pitch(type);

    for($i = [0 : 1 : min(n - 1, 4)])
        rotate($i * 90)
            translate([pitch / 2, pitch / 2])
                rotate($i * -90)
                    children();
}

module NEMA_screws(type, screw, n = 4, screw_length = 8, earth = undef, earth_rot = undef) //! Place screws and optional earth tag
    NEMA_screw_positions(type, n)
        if($i != earth)
            screw_and_washer(screw, screw_length, true);
        else
            rotate(is_undef(earth_rot) ? $i > 1 ? 180 : 0 : earth_rot)
                ring_terminal(M3_ringterm)
                    star_washer(screw_washer(screw))
                        screw(screw, screw_length);
