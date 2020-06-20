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
//! D-connectors. Can be any number of ways, male or female, solder buckets, PCB mount or IDC, with or without pillars.
//
include <../utils/core/core.scad>
use <../utils/thread.scad>

d_pillar_colour                   = grey(90);
d_plug_shell_colour               = grey(80);
d_plug_insulator_colour           = grey(20);

function  d_flange_length(type)    = type[1];   //! Length of the flange
function  d_lengths(type)          = type[2];   //! Lengths of the D for plug and socket
function  d_hole_pitch(type)       = type[3];   //! Mounting hole pitch
function  d_widths(type)           = type[4];   //! Widths of the D for plug and socket
function  d_flange_width(type)     = type[5];   //! Width of the flange
function  d_height(type)           = type[6];   //! From the front to the back of the metal part
function  d_front_height(type)     = type[7];   //! From the back of the flange to the front
function  d_flange_thickness(type) = type[8];   //! Thickness of the flange
function  d_ways(type)             = type[9];   //! Number of ways
function  d_mate_distance(type)    = 8.5;       //! Spacing when mated
function  d_pcb_offset(type)       = d_height(type) - d_front_height(type) + 2; //! Height of the back of the flange above the PCB

function  d_slot_length(type) = d_lengths(type)[0] + 3;  //! Slot to clear the back

module d_connector_holes(type) //! Place children at the screw hole positions
    for(end = [-1, 1])
        translate([end * d_hole_pitch(type) / 2, 0])
            children();

module d_pillar() { //! Draw a pillar for a D-connector
    vitamin("d_pillar(): D-type connector pillar");
    rad = 5.37 / 2;
    height = 4.5;
    screw = 2.5;
    screw_length = 8;
    pitch = metric_coarse_pitch(screw);

    translate_z(-screw_length)
        if(show_threads)
            male_metric_thread(screw, pitch, screw_length, false, top = 0, colour = d_pillar_colour);
        else
            color(d_pillar_colour)
                cylinder(d = screw, h = screw_length + 1);

    color(d_pillar_colour) {
        linear_extrude(height)
            difference() {
                circle(r = rad, $fn = 6);
                circle(d = screw);
            }
        }
    if(show_threads)
        female_metric_thread(screw, pitch, height, false, colour = d_pillar_colour);
}

module d_plug(type, socket = false, pcb = false, idc = false) { //! Draw specified D plug, which can be IDC, PCB or plain solder bucket
    hole_r = 3.05 / 2;
    dwall = 0.5;

    flange_length    = d_flange_length(type);
    d_length         = d_lengths(type)[socket ? 1 : 0];
    hole_pitch       = d_hole_pitch(type);
    d_width          = d_widths(type)[socket ? 1 : 0];
    flange_width     = d_flange_width(type);
    front_height     = d_front_height(type);
    back_height      = d_height(type) - front_height;
    pins             = d_ways(type);

    desc = idc ? "IDC" : pcb ? "PCB mount" : "";
    vitamin(str(socket ? "d_socket(" : "d_plug(", type[0], arg(pcb, false, "pcb"), arg(idc, false, "idc"),
                                  "): D-type ", pins, " way ", desc, socket ? " socket" : " plug"));

    module D(length, width, rad) {
        d = width / 2 - rad;
        offset = d * sin(10);

        hull()
            for(x = [-1, 1], y = [-1, 1])
                translate([x * (length / 2 - rad) + y * x * offset, y * (width / 2 - rad)])
                    circle(rad);
    }

    module pin_positions()
        for($i = [1 : pins])
            translate([($i - (pins + 1) / 2) * 2.77 / 2, ($i % 2 - 0.5) * 2.84])
                children();
    //
    // Shell
    //
    color(d_plug_shell_colour)  {
        linear_extrude( d_flange_thickness(type))
            difference() {
                rounded_square([flange_length, flange_width], 2);

                d_connector_holes(type)
                    circle(hole_r);
            }

        linear_extrude(front_height, convexity = 5)
            difference() {
                D(d_length, d_width, 2.5);
                D(d_length - 2 * dwall, d_width - 2 * dwall, 2.5 - dwall);
            }

        if(!idc)
            rotate([0,180,0])
                linear_extrude(back_height, convexity = 5)
                    D(d_lengths(type)[0] + 2 * dwall, d_widths(type)[0] + 2 * dwall, 2.5 + dwall);

    }
    //
    // Insulator
    //
    color(d_plug_insulator_colour) {
        translate_z(d_flange_thickness(type) + eps)
            rotate([0, 180, 0])
                linear_extrude(back_height + 1 + d_flange_thickness(type), convexity = 5)
                    D(d_length - dwall, d_width - dwall, 2.5 - dwall/2);

        if(socket)
            linear_extrude(front_height - eps, convexity = 5)
                difference() {
                    D(d_length - dwall, d_width - dwall, 2.5 - dwall/2);

                    pin_positions()
                        circle(r = 0.7);
                }
        if(idc) {
            translate_z(-2.4 / 2)
                cube([((pins + 1) / 2) * 2.77 + 6, flange_width, 2.4], center = true);

            translate_z(-14.4 / 2)
                cube([pins * 1.27 + 7.29, flange_width, 14.4], center = true);
        }
    }
    //
    // Pins
    //
    color("gold") {
        if(!socket)
            translate_z(-0.5)
                pin_positions()
                    hull() {
                        pin_r = 0.5;
                        cylinder(r = pin_r, h = eps);

                        translate_z(front_height - pin_r)
                            sphere(pin_r);
                    }

        if(pcb)
           rotate([0, 180, 0]) {
                linear_extrude(back_height + 1 + 4.5)
                    pin_positions()
                         circle(r = 0.75 / 2, $fn = 12);

                linear_extrude(back_height + 1 + 1)
                    pin_positions()
                         circle(r = 0.75, $fn = 12);
            }

        if(!pcb && !idc)
            rotate([0, 180, 0])
                pin_positions()
                    rotate(180 + ($i % 2) * 180)
                    render() difference() {
                        linear_extrude(8)
                            difference() {
                                circle(1);

                                circle(0.45);
                            }
                        translate([0, 2.1, 8])
                            rotate([45, 0, 0])
                                cube([3, 3, 3], center = true);
                    }
    }
}

module d_socket(connector, pcb = false, idc = false) //! Draw specified D socket, which can be IDC, PCB or plain solder bucket
    d_plug(connector, true, pcb = pcb, idc = idc);
