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
//! IEC mains inlets and outlet.
//
include <../core.scad>
use <screw.scad>
use <nut.scad>
use <washer.scad>
use <spade.scad>
include <inserts.scad>

function iec_part(type)     = type[1];  //! Description
function iec_screw(type)    = type[2];  //! Screw type
function iec_pitch(type)    = type[3];  //! Screw hole pitch
function iec_slot_w(type)   = type[4];  //! Body width
function iec_slot_h(type)   = type[5];  //! Body height
function iec_slot_r(type)   = type[6];  //! Body corner radius
function iec_bezel_w(type)  = type[7];  //! Bezel width
function iec_bezel_h(type)  = type[8];  //! Bezel height
function iec_bezel_r(type)  = type[9];  //! Bezel corner radius
function iec_bezel_t(type)  = type[10]; //! Bezel thickness
function iec_flange_w(type) = type[11]; //! Flange width not including the lugs
function iec_flange_h(type) = type[12]; //! Flange height
function iec_flange_r(type) = type[13]; //! Flange corner radius
function iec_flange_t(type) = type[14]; //! Flange thickness
function iec_width(type)    = type[15]; //! Widest part including the lugs
function iec_depth(type)    = type[16]; //! Depth of the body below the flange
function iec_spades(type)   = type[17]; //! Spade type
function iec_male(type)     = type[18]; //! True for an outlet

insert_overlap = 1.1; // chosen to make cap screws 10mm long.

module iec(type) { //! Draw specified IEC connector
    vitamin(str("iec(", type[0], "): ", iec_part(type)));

    pin_w = 2;
    pin_d = 4;
    pin_h1 = 12;
    pin_h2 = 15;
    pin_chamfer = 1;

    module pin(h)
        color("silver")
            hull() {
                translate_z(h / 2)
                    cube([pin_w - pin_chamfer, pin_d - pin_chamfer, h], center = true);

                translate_z((h - pin_chamfer) / 2)
                    cube([pin_w, pin_d, h - pin_chamfer], center = true);
            }

    socket_w  = 24;
    socket_w2 = 14;
    socket_h  = 16.5;
    socket_h2 = 12;
    socket_d  = 17;
    socket_r = 3;
    socket_r2 = 0.5;
    socket_offset = iec_bezel_h(type) / 2 - socket_h / 2  - (iec_bezel_w(type) - socket_w) / 2;

    module socket_shape()
        hull()
            for(side = [-1, 1]) {
                translate([side * (socket_w / 2 - socket_r), -socket_h / 2 + socket_r])
                    circle(socket_r);

                translate([side * (socket_w / 2 - socket_r2), -socket_h / 2 + socket_h2 + socket_r2])
                    circle(socket_r2);

                translate([side * (socket_w2 / 2 - socket_r2), socket_h / 2 - socket_r2])
                    circle(socket_r2);
            }

    module oriffice_shape()
        translate([0, socket_offset])
            if(iec_male(type))
                difference() {
                    offset(3)
                        socket_shape();

                    difference() {
                        offset(-1) socket_shape();

                        translate([0, 2])
                            square([2.4, 5], center = true);

                        for(side = [-1, 1])
                            translate([side * 7, -2])
                                square([2.4, 5], center = true);
                    }
                }
            else
                socket_shape();

    color(grey20) {
        // Flange
        flange_t = iec_flange_t(type);
        linear_extrude(height = flange_t)
            difference() {
                hull() {
                    rounded_square([iec_flange_w(type), iec_flange_h(type)], iec_flange_r(type));

                    iec_screw_positions(type)
                        circle(d = iec_width(type) - iec_pitch(type));
                }
                oriffice_shape();

                iec_screw_positions(type)
                    circle(socket_r);
            }
        head_r = screw_head_radius(iec_screw(type));
        screw_r = screw_clearance_radius(iec_screw(type));
        iec_screw_positions(type)
            rotate_extrude()
                difference() {
                    translate([screw_r, 0])
                        square([socket_r - screw_r, flange_t]);

                    translate([0, flange_t - head_r])
                        rotate(45)
                            square(10);
                }
        // Bezel
        translate_z(iec_flange_t(type))
            linear_extrude(height = iec_bezel_t(type))
                difference() {
                    rounded_square([iec_bezel_w(type), iec_bezel_h(type)], iec_bezel_r(type));

                    oriffice_shape();
                }

        // Body
        h = socket_d - iec_flange_t(type) - iec_bezel_t(type);
        translate_z(-h)
            linear_extrude(height = h)
                difference() {
                    rounded_square([iec_slot_w(type), iec_slot_h(type)], iec_slot_r(type));
                    oriffice_shape();
                }
        // Back
        translate_z(-iec_depth(type))
            rounded_rectangle([iec_slot_w(type), iec_slot_h(type), iec_depth(type) - h], iec_slot_r(type), center = false);
    }
    if(!iec_male(type))
        translate([0, socket_offset, iec_flange_t(type) + iec_bezel_t(type) - socket_d]) {
            translate([0, 2])
                pin(pin_h2);

            for(side = [-1, 1])
                translate([side * 7, -2])
                    pin(pin_h1);
        }
    for(spade = iec_spades(type))
        translate([spade[2], spade[3], -iec_depth(type)])
            rotate([180, 0, spade[4]])
                spade(spade[0], spade[1]);
}

module iec_screw_positions(type) //! Position children at the screw holes
    for(side = [-1, 1])
        translate([side * iec_pitch(type) / 2, 0])
            children();

module iec_holes(type, h = 100, poly = false, horizontal = false, insert = false) { //! Drill the required panel holes
    clearance = 0.2;

    iec_screw_positions(type)
        if(insert)
            insert_hole(screw_insert(iec_screw(type)), insert_overlap, horizontal = horizontal);
        else
            if(horizontal)
                teardrop_plus(r = screw_clearance_radius(iec_screw(type)), h = h);
            else
                if(poly)
                    poly_cylinder(r = screw_clearance_radius(iec_screw(type)), h = h, center = true);
                else
                    drill(screw_clearance_radius(iec_screw(type)), h);

    extrude_if(h)
        hull()
            for(x = [-1, 1], y = [-1, 1], sag = horizontal && y > 1 ? layer_height : 0)
                translate([x * (iec_slot_w(type) / 2 - iec_slot_r(type)), y * (iec_slot_h(type) / 2  - iec_slot_r(type) + sag )])
                    if(horizontal)
                        teardrop(0, iec_slot_r(type) + clearance / 2 + layer_height / 4);
                    else
                        drill(iec_slot_r(type) + clearance / 2, 0);
}

module iec_assembly(type, thickness) { //! Assembly with fasteners given panel thickness
    screw = iec_screw(type);
    washer = screw_washer(screw);
    nut = screw_nut(screw);
    insert = screw_insert(screw);
    screw_length = thickness ? screw_longer_than(iec_flange_t(type) + thickness + washer_thickness(washer) + nut_thickness(nut, true))
                             : screw_shorter_than(iec_flange_t(type) + insert_hole_length(insert) + insert_overlap);

    iec(type);

    iec_screw_positions(type) {
        translate_z(iec_flange_t(type))
            screw(screw, screw_length);

        if(thickness)
            translate_z(-thickness)
                vflip()
                    nut_and_washer(nut, true);
        else
            insert(insert);
    }
}
