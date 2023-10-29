//
// NopSCADlib Copyright Niclas Hedhman 2018
// niclas@hedhman.org
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
//! BLDC servos for CNC machines
//

include <../utils/core/core.scad>
use <../utils/tube.scad>
use <../utils/round.scad>
use <../utils/quadrant.scad>
use <../utils/rounded_cylinder.scad>

function servo_motor_cap(type)       = type[2]; //! Diameter height and corner radius of encoder cover
function servo_motor_length(type)    = type[3]; //! Total length from the faceplate
function servo_motor_shaft(type)     = type[4]; //! Shaft type
function servo_motor_faceplate(type) = type[5]; //! Face plate type

function faceplate_width(type)          = type[1]; //! Width of faceplate
function faceplate_thickness(type)      = type[2]; //! Thickness of the faceplate
function faceplate_boss_size(type)      = type[3]; //! Centre boss outer d, inner d and height
function faceplate_hole_pitch(type)     = type[4]; //! Screw hole pitch
function faceplate_hole_dia(type)       = type[5]; //! Screw hole size

function servo_motor_width(type) = faceplate_width(servo_motor_faceplate(type)); //! Width of the motor body

function shaft_type(type)       = type[0]; //! String to indicate the shaft type
function shaft_diameter(type)   = type[1]; //! Shaft diameter
function shaft_length(type)     = type[2]; //! Shaft length
function shaft_key_size(type)   = type[3]; //! Keyway [length, width, depth]

module servo_motor(type) { //! Draw the specified servo
    fplate = servo_motor_faceplate(type);
    t = faceplate_thickness(fplate);
    w = servo_motor_width(type);
    inset = (w - faceplate_hole_pitch(fplate)) / 2;
    cap = servo_motor_cap(type);
    l = servo_motor_length(type);

    vitamin(str("servo_motor(", type[0], ") : Servo ", type[1], " ", fplate[0], " mount ", servo_motor_width(type), " x ", servo_motor_length(type), "mm"));

    color(grey(20))
        translate_z(-l + cap.z) {
            linear_extrude(l - t - cap.z)
                round(2)
                    difference() {
                        square([w, w], center = true);

                        faceplate_screw_positions(fplate)
                            rotate($i * 90 + 180)
                                quadrant(w = 2 * inset, r = inset, center = true);
                    }

            vflip()
                rounded_cylinder(r = cap.x / 2, r2 = cap.y, h = cap.z);
        }

    motor_shaft(servo_motor_shaft(type));

    motor_faceplate(fplate);
}

module motor_shaft(type) { //! Draw the specified motor shaft
    diameter = shaft_diameter(type);
    length = shaft_length(type);
    key_size = shaft_key_size(type);
    key_r = key_size.y / 2;

    color("silver")
        if( shaft_type(type) == "keyed" ) {
            render() difference() {
                cylinder(h = length, d = diameter);

                translate([diameter / 2, 0, length])
                    rotate([0, 90, 0])
                        slot(r = key_r, l = 2 * (key_size.x - key_r), h = 2 * key_size.z);
            }
        }
}

module servo_screw_positions(type) //! Position children at screw positions
    faceplate_screw_positions(servo_motor_faceplate(type))
        children();

module faceplate_screw_positions(type) //! Position children at faceplate screw positions
    for($i = [0 : 3])
        let(corner = [[1, 1], [-1, 1], [-1,-1], [1, -1]][$i], pitch = faceplate_hole_pitch(type))
            translate(corner * pitch / 2)
                children();

module motor_faceplate(type) { //! Draw specified motor faceplate
    w = faceplate_width(type);
    t = faceplate_thickness(type);
    boss = faceplate_boss_size(type);
    boss_r = boss[0] / 2;
    boss_ir = boss[1] / 2;
    boss_t = boss.z;
    rad = 5; // corner radius

    translate_z(-t) {
        color(silver)
            linear_extrude(t)
                difference() {
                    rounded_square([w - eps, w - eps], rad);

                    faceplate_screw_positions(type)
                        circle(d = faceplate_hole_dia(type));
                }

        color(grey(10))
            translate_z(eps)
                linear_extrude(t - 2 * eps)
                    difference() {
                        rounded_square([w, w], rad);

                        faceplate_screw_positions(type)
                            circle(d = faceplate_hole_dia(type) + eps);
                    }
    }

    color(grey(10))
        tube(h = boss_t, or = boss_r - eps, ir = boss_ir + eps, center = false);

    color(silver)
        tube(h = boss_t - eps, or = boss_r, ir = boss_ir, center = false);
}
