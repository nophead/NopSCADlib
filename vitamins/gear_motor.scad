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
//! DC motors with a gearbox
//
include <../core.scad>
use <../utils/rounded_cylinder.scad>

function gm_shaft(type)        = type[1]; //! Shaft diameter, flat width, length, flat length.
function gm_boss(type)         = type[2]; //! Motor boss diameter, corner radius, height and colour
function gm_shaft_offset(type) = type[3]; //! Offset of shaft from the centre of the gearbox
function gm_box(type)          = type[4]; //! Size, corner radius, colour
function gm_screw(type)        = type[5]; //! Screw type
function gm_screw_depth(type)  = type[6]; //! Screw hole depth
function gm_screw_boss(type)   = type[7]; //! Screw boss diameter and height
function gm_motor(type)        = type[8]; //! Motor position, diameter, height, corner rad and colour
function gm_hub(type)          = type[9]; //! Motor hub diameter, height, corner rad
function gm_motor_boss(type)   = type[10]; //! Motor mounting boss on gearbox
function gm_tags(type)         = type[11]; //! Tag size and pitch
function gm_holes(type)        = type[12]; //! List of hole positions

function gm_shaft_r(type) = gm_shaft(type).x / 2; //! Shaft radius
function gm_shaft_length(type) = gm_shaft(type).z; //! Length of the shaft
function gm_shaft_flat_w(type) = gm_shaft(type).y; //! Shaft width across the flat
function gm_shaft_flat_l(type) = gm_shaft(type)[3]; //! Length of the shaft flat section
function gm_motor_pos(type) = gm_motor(type)[0]; //! Motor position relative to centre of the gearbox
function gm_motor_d(type) = gm_motor(type)[1]; //! Motor diameter
function gm_depth(type) = gm_screw_boss(type)[1] + gm_box(type).z - gm_motor_pos(type).z + gm_motor(type).z + gm_tags(type).z;  //! Motor total depth
function gm_shaft_pos(type) = let(o = gm_shaft_offset(type)) [o.x, o.y, -gm_screw_boss(type)[1] + gm_boss(type).z]; //! Shaft position
function gm_box_width(type) = let(b = gm_box(type)) b.y ? b.y : b.x; //! Gearbox width if rectangular or diameter if round


module gm_shaft_shape(type) {
    shaft = gm_shaft(type);
    r =  shaft.x / 2;
    difference() {
        circle(r);

        translate([-r + shaft.y, -r - 1])
            square([shaft.x, 2 *(r + 1)]);
    }
}

module gm_screw_positions(type, skip = []) {
    holes = gm_holes(type);
    for(i = [0 : len(holes) - 1])
        if(!in(skip, i))
            translate(holes[i])
                children();
}

module gear_motor(type, alpha = 1) { //! Draw specified gear motor, can be partially transparent to see what is behind it
    boss = gm_boss(type);
    shaft = gm_shaft(type);
    box = gm_box(type);
    screw = gm_screw(type);
    screw_depth = gm_screw_depth(type);
    screw_boss = gm_screw_boss(type);
    motor = gm_motor(type);
    hub = gm_hub(type);
    motor_boss = gm_motor_boss(type);
    tags = gm_tags(type);

    $fa = fa; $fs = fs;

    module shaft_pos()
        translate(gm_shaft_pos(type))
            children();

    // Shaft
    color(silver) {
        shaft_pos() {
            linear_extrude(shaft.z)
                gm_shaft_shape(type);

            cylinder(d = shaft.x, h = shaft.z - shaft[3]);
        }
    }
    // Shaft boss
    color(boss[3])
        shaft_pos()
            translate_z(-boss.z)
                if(boss.y < 0)
                    hull() {
                        cylinder(d = boss.x, h = boss.z - boss.y);

                        cylinder(r = boss.x / 2 - boss.y, h = boss.z);
                    }
                else
                    rounded_cylinder(r = boss.x / 2, r2 = boss.y, h = boss.z);

    // Gearbox
    color(box[4]) {
        render() difference() {
            translate_z(-box.z - screw_boss[1])
                union() {
                    if(box.y)
                        rounded_top_rectangle(box, box[3], box[3]);
                    else
                        rounded_cylinder(r = box.x / 2, h = box.z, r2 = box[3]);

                    if(screw_boss.x)
                        gm_screw_positions(type)
                            cylinder(d = screw_boss.x, h = box.z + screw_boss[1]);
                }

            gm_screw_positions(type)
                cylinder(r = screw_radius(screw), h = screw_depth * 2, center = true);
        }
        if(motor_boss)
            translate(motor[0] - [0, 0, box.z])
                rounded_cylinder(r = motor_boss.x / 2, h = motor_boss[1], r2 = motor_boss[2]);
    }
    // Motor
    color(motor[4], alpha)
        translate(motor[0] - [0, 0, motor.z + box.z]) {
            rounded_cylinder(r = motor[1] / 2, h = motor.z, r2 = motor[3]);

            vflip()
                rounded_cylinder(r = hub.x / 2, h = hub[1], r2 = hub[2]);

        }

    // Tags
    color(brass)
        for(side = [-1, 1])
            translate(motor[0] + [side * tags[3] / 2, 0, -box.z -motor.z])
                rotate([90, 0, 90])
                    linear_extrude(tags.x, center = true)
                        difference() {
                            hull() {
                                square([tags.y, eps], center = true);

                                translate([0, -tags.z + tags.y / 2])
                                    circle(d = tags.y);
                            }
                            r = tags.y / 4;
                            hull()
                                for(y = [-tags.z + 2 * r, - tags.z / 2])
                                    translate([0, y])
                                        circle(r);
                        }

}
