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
//! Potentiometers and rotary encoders
include <../core.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/round.scad>
use <../utils/thread.scad>

pot_nut_t = 2;
pot_proud = 0.3;
spigot_r = 0.5;
tab = [3.2, 0.5];

function pot_body(type)     = type[1];  //! Body diameter or width & depth, height and corner radius
function pot_face(type)     = type[2];  //! Faceplate rib width, plate depth and plate height
function pot_wafer(type)    = type[3];  //! Width, diameter and thickness of the track wafer plus true if curved
function pot_gangs(type)    = type[4];  //! Number of gangs for mult-gang pot
function pot_thread_d(type) = type[5];  //! Nomininal thread diameter
function pot_thread_p(type) = type[6];  //! Thread pitch
function pot_thread_h(type) = type[7];  //! Height of threaded part
function pot_boss_d(type)   = type[8];  //! Boss diameter
function pot_boss_h(type)   = type[9];  //! Boss height
function pot_spigot(type)   = type[10]; //! Spigot width, length and height above the boss
function pot_spigot_x(type) = type[11]; //! Spigot offset from the shaft centre
function pot_shaft(type)    = type[12]; //! Diameter, flat diameter, length and flat/slot length and colour. If flat diameter is less than the radius then it is a slot width
function pot_neck(type)     = type[13]; //! Diameter and length of the shaft neck
function pot_nut(type)      = type[14]; //! Across flat diameter and thickness of the nut
function pot_washer(type)   = type[15]; //! Outside diameter and thickness of the washer

function pot_size(type) = let(d = pot_body(type)) len(d) > 3 ? [d.x , d.y, d.z] : [d.x, d.x, d.y]; //! Get pot body dimensions

function pot_z(type, washer = true) = pot_thread_h(type) - pot_nut(type)[1] - pot_proud - (washer ? pot_washer(type)[1] : 0); //! Ideal distance behind panel surface to get the nut and washer on comfortably
function pot_spigot_r(type) = let(sp = pot_spigot(type)) sp.x > 2 * spigot_r ? spigot_r : 0;

module pot_nut(type, washer = true) { //! Draw the nut for a potentiometer and possibly a washer
    nut = pot_nut(type);
    washer = washer ? pot_washer(type) : false;
    nut_z = washer ? washer[1] : 0;
    thread_d = pot_thread_d(type);
    vflip() explode(23, explode_children = true) {
        if(washer)
            color(washer[2])
                linear_extrude(washer[1])
                    difference() {
                        circle(d = washer.x);

                        circle(d =  thread_d);

                        serations = washer[3];
                        if(serations)
                            for(i = [1 : serations])
                                rotate(i * 360 / serations)
                                    translate([thread_d / 2, 0])
                                        square([(washer.x - thread_d) / 2, PI * thread_d / (2 * serations)], center = true);
                    }

        if(nut)
            translate_z(nut_z + exploded() * 10)
                draw_nut(nut.x / cos(30), thread_d, nut[1], pot_thread_p(type), nut[2], show_threads && exploded());
    }
}

module potentiometer(type, thickness = 3, shaft_length = undef, value = false) {//! Draw a potentiometer with nut spaced by specified thickness
    bh = pot_boss_h(type);
    s = pot_size(type);
    face =  pot_face(type);
    wafer =  pot_wafer(type);
    wafer_z = wafer? wafer.z : 0;
    round = len(pot_body(type)) < 4;
    dia_cast_colour = grey(60);
    thread_d = pot_thread_d(type);
    thread_h = pot_thread_h(type);
    shaft = pot_shaft(type);
    vitamin(str("potentiometer(", type[0], "): ", slice(type[0], start = -8) != "_encoder" ? "Potentiometer " : "", value ? value : type[0]));

    $fa = fa; $fs = fs;

    color(dia_cast_colour) {
        // Boss
        if(bh)
            cylinder(d = pot_boss_d(type), h = bh);

        if(face) {
            if(face.x) {
                linear_extrude(face.z)
                    square([face.x, face.y], center = true);

                linear_extrude(bh)
                    difference() {
                        square([face.x, face.y], center = true);

                        square([face.x - 2 * face.z, s.x], center = true);
                    }
            }
            translate_z(bh - face.z)
                linear_extrude(face.z)
                    intersection() {
                        circle(d = s.x - eps);

                        difference() {
                            square([s.x + eps, face.y], center = true);

                            if(face.x)
                                square([face.x - 2 * face.z, s.x], center = true);
                        }
                    }
        }

        // spigot
        x = pot_spigot_x(type);
        sp = pot_spigot(type);
        if(x)
            translate([x, 0, bh])
                vflip()
                    rounded_rectangle(sp + [0, 0, bh], pot_spigot_r(type));
        // thread
        vflip()
            if(show_threads)
                male_metric_thread(thread_d, pot_thread_p(type), thread_h, center = false, bot = 0, colour = dia_cast_colour);
            else
                cylinder(d = thread_d, h = pot_thread_h(type));
    }

    d = pot_body(type);
    fz = face ? face.z : 0;
    gap = face ? face.z + tab[1] : 0;
    total_h = s.z - bh;
    gangs = pot_gangs(type);
    gang_h = (total_h - (gangs - 1) * gap) / gangs;
    pitch = gang_h + gap;
    for(i = [0 : gangs - 1])
        translate_z(bh + i * pitch) {
            // Wafer that carries the track and contacts
            if(wafer)
                color("sienna") {
                    linear_extrude(wafer.z) round(wafer[3] ? 1 : 0) {
                        if(round)
                            circle(d = s.x - eps);
                        else
                            rounded_square([s.x, s.y], d[3]);

                        intersection() {
                            translate([0, -s.y / 2])
                                square([wafer.x, (wafer.y - s.y) * 2], center = true);

                            if(wafer[3])
                                circle(wafer.y - s.y / 2);
                            else
                                square(100, center = true);
                        }
                    }
                }

            color(silver) {
                // Body
                translate_z(wafer_z)
                    if(round)
                        rounded_cylinder(r = s.x / 2, r2 = d[2], h = gang_h - wafer_z);
                    else
                        rounded_rectangle([s.x, s.y, gang_h - wafer_z], d[3]);

                // Make tabs that hold the face on
                if(face) {
                    translate_z(-tab[1] - fz)
                        linear_extrude(face.z + tab[1] + wafer_z)
                            intersection() {
                                circle(d = s.x);

                                for(x = [-1, 1], y = [-1, 1], a = y * 90 + 90 + x * 30)
                                    rotate(a)
                                        translate([s.x / 2, 0])
                                            slot(r = tab.x / 2, l = (s.x - pot_boss_d(type)) / 2 - tab.x / 2, h = 0);
                            }
                }
            }

            // Face plate between sections
            if(face && i) {
                color(dia_cast_colour)
                    translate_z(-fz)
                        linear_extrude(fz)
                            intersection() {
                                circle(d = s.x - eps);

                            square([s.x + eps, face.y], center = true);
                         }

                color(shaft[4])
                    vflip()
                        cylinder(d = shaft.x, h = gap);
            }
        }

    // Shaft
    color(shaft[4])
        translate_z(-thread_h) vflip() {
                shaft_z = is_undef(shaft_length) ? shaft.z : min(shaft_length, shaft.z);
                flat_h = shaft[3] - (shaft.z - shaft_z);
                plain = shaft_z - flat_h;
                neck = pot_neck(type);
                neck_h = neck[1];

                if(neck_h)
                    cylinder(d = neck.x, h = neck_h);

                if(plain - neck_h > 0)
                    translate_z(neck_h)
                        cylinder(d = shaft.x, h = plain - neck_h);

                if(flat_h)
                    translate_z(plain)
                        linear_extrude(flat_h)
                            difference() {
                                circle(d = shaft.x);

                                if(shaft.y > shaft.x / 2)
                                    translate([0, shaft.x / 2])
                                        square([shaft.x, 2 * (shaft.x - shaft.y)], center = true);
                                else
                                    if(shaft.y)
                                        square([shaft.y, shaft.x + 1], center = true);
                            }
            }
}
