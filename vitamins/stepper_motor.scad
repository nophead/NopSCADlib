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

include <screws.scad>
use <washer.scad>
include <ring_terminals.scad>
use <../utils/tube.scad>

function NEMA_width(type)       = type[1]; //! Width of the square face
function NEMA_length(type)      = type[2]; //! Body length
function NEMA_radius(type)      = type[3]; //! End cap radius
function NEMA_body_radius(type) = type[4]; //! Body radius
function NEMA_boss_radius(type) = type[5]; //! Boss around the spindle radius
function NEMA_boss_height(type) = type[6]; //! Boss height
function NEMA_shaft_dia(type)   = type[7]; //! Shaft diameter
function NEMA_shaft_length(type)= type[8]; //! Shaft length above the face
function NEMA_hole_pitch(type)  = type[9]; //! Screw hole pitch
function NEMA_holes(type)       = [-NEMA_hole_pitch(type) / 2, NEMA_hole_pitch(type) / 2]; //! Screw positions for for loop
function NEMA_big_hole(type)    = NEMA_boss_radius(type) + 0.2; //! Clearance hole for the big boss

stepper_body_colour = "black";
stepper_cap_colour  = grey50;

module NEMA_outline(type) //! 2D outline
    intersection() {
        side = NEMA_width(type);
        square([side, side], center = true);

        circle(NEMA_radius(type));
    }

module NEMA(type) { //! Draw specified NEMA stepper motor
    side = NEMA_width(type);
    length = NEMA_length(type);
    body_rad = NEMA_body_radius(type);
    boss_rad = NEMA_boss_radius(type);
    boss_height =NEMA_boss_height(type);
    shaft_rad = NEMA_shaft_dia(type) / 2;
    cap = 8;
    vitamin(str("NEMA(", type[0], "): Stepper motor NEMA", round(NEMA_width(type) / 2.54), " x ", length, "mm"));

    union() {
        color(stepper_body_colour)                                          // black laminations
            translate_z(-length / 2)
                linear_extrude(height = length - cap * 2, center = true)
                    intersection() {
                        square([side, side], center = true);

                        circle(body_rad);
                    }

        color(stepper_cap_colour) {                                     // aluminium end caps
            tube(or = boss_rad, ir =  shaft_rad + 2, h = boss_height * 2); // raised boss

            for(end = [-1, 1])
                translate_z(-length / 2 + end * (length - cap) / 2)
                    linear_extrude(height = cap, center = true)
                        difference() {
                            intersection() {
                                square([side, side], center = true);
                                circle(NEMA_radius(type));
                            }
                            if(end > 0)
                                for(x = NEMA_holes(type), y = NEMA_holes(type))
                                    translate([x, y])
                                        circle(r = 3/2);
                        }
        }

        color(NEMA_shaft_length(type) > 50 ? "silver" : stepper_cap_colour)
            translate_z(-5)
                cylinder(r = shaft_rad, h = NEMA_shaft_length(type) + 5);  // shaft

        translate([0, side / 2, -length + cap / 2])
            rotate([90, 0, 0])
                for(i = [0 : 3])
                    rotate(225 + i * 90)
                        color(["red", "blue","green","black"][i])
                            translate([1, 0, 0])
                                cylinder(r = 1.5 / 2, h = 12, center = true);
    }
}

module NEMA_screw_positions(type, n = 4) { //! Positions children at the screw holes
    pitch = NEMA_hole_pitch(type);

    for($i = [0 : n - 1])
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
