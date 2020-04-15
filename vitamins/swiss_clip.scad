//
// NopSCADlib Copyright Chris Palmer 2020
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
//! Swiss picture clip.
//! Used for holding glass on 3D printer beds.
//!
//! The bending model is an approximation because in real life the arms bend.
//! Should be reasonably accurate if not close to fully open.
//
include <../utils/core/core.scad>

function sclip_length(type)        = type[1]; //! Total external length
function sclip_height(type)        = type[2]; //! External height
function sclip_width(type)         = type[3]; //! Width
function sclip_thickness(type)     = type[4]; //! Thickness of the metal
function sclip_radius(type)        = type[5]; //! Bend radius
function sclip_arm_width(type)     = type[6]; //! Width of spring arms
function sclip_spigot(type)        = type[7]; //! Spigot length, width, height
function sclip_hook(type)          = type[8]; //! hook, length, width
function sclip_hinge_offset(type)  = type[9]; //! Offset of hinge
function sclip_arm_length(type)    = type[10]; //! Length of arms
function sclip_max_gap(type)       = type[11]; //! Maximum opening

function arm_angle(type, open) = asin((sclip_height(type) - 2 * sclip_thickness(type) - open) / sclip_arm_length(type));

function spigot_angle(type, open) =
    let(arm_w = sclip_arm_width(type), w = sclip_width(type) - 2 * arm_w)
        (arm_angle(type, 0) - arm_angle(type, open)) * 2 * arm_w / w;

module swiss_clip_hole(type, open, h = 0) { //! Drill hole for spigot
    spigot = sclip_spigot(type);
    angle = spigot_angle(type, open);
    t = sclip_thickness(type);
    or = sclip_radius(type);
    ir = or - t;
    shadow = (spigot.z - or) * sin(angle) - or * cos(angle) + or  + t * cos(angle);
    r = sqrt(sqr(shadow) + sqr(spigot.y)) / 2;
    offset = sclip_hinge_offset(type);
    hpot = offset - t;

    translate([sclip_length(type) - t - ir - offset + hpot * cos(angle) - (spigot.z - t) * sin(angle) + shadow / 2, 0])
        drill(r + 0.1, h);
}

module swiss_clip(type, open = 0.9) { //! Draw a Swiss clip open by specified amount
    vitamin(str("swiss_clip(", type[0], "): Swiss picture clip ", type[0], " ", sclip_max_gap(type),"mm"));

    length = sclip_length(type);
    width = sclip_width(type);
    height = sclip_height(type);

    spigot = sclip_spigot(type);
    hook = sclip_hook(type);
    offset = sclip_hinge_offset(type);
    t = sclip_thickness(type);
    arm_l = sclip_arm_length(type);
    arm_w = sclip_arm_width(type);
    w = width - 2 * arm_w;
    or = sclip_radius(type);
    ir = or - t;
    angle = arm_angle(type, open);
    angle2 = spigot_angle(type, open);
    $fn = 360;

    color("silver") translate([-t - ir, 0, -height + t]) {
        translate([length - offset - arm_l, -w / 2])    // Narrow part of base
            cube([arm_l, w, t]);

        translate([length - offset, 0, t])
            rotate([0, -angle2, 0])
                translate([offset - length, 0, -t]) {
                    translate([length - offset, -width / 2])        // Wide part of base
                        cube([offset - spigot.x, width, t]);

                    translate([length - spigot.x, -spigot.y / 2])   // Spigot base
                        cube([spigot.x - or, spigot.y, t]);

                    translate([length - t,  -spigot.y / 2, or])     // Spigot stem
                        cube([t, spigot.y, spigot.z - or]);

                    translate([length - or, -spigot.y / 2, or])     // Spigot bend
                        rotate([-90, 0, 0])
                            rotate_extrude(angle = 90)
                                translate([ir, 0])
                                    square([t, spigot.y]);
                }

        translate([or, -hook.y / 2])                    // Hook base
            cube([hook.x, hook.y, t]);

        translate([0, -hook.y / 2, or])                 // Hook stem
            cube([t, hook.y, height - 2 * or]);

        translate([or, -hook.y / 2, or])                // Hook lower bend
            rotate([0, 90, 90])
                rotate_extrude(angle = 90)
                    translate([ir, 0])
                        square([t, hook.y]);

        translate([or, -hook.y / 2, height - t])        // Hook top
            cube([hook.x - or, hook.y, t]);

        translate([or, hook.y / 2, height - or])        // Hook top bend
            rotate([0, -90, 90])
                rotate_extrude(angle = 90)
                    translate([ir, 0])
                        square([t, hook.y]);

        translate([length - offset, 0, t])              // Arms
            rotate([0, angle, 0])
                for(side = [-1, 1])
                    translate([-arm_l, side * (arm_w + w) / 2 - arm_w / 2, -t])
                        cube([arm_l, arm_w, t]);

        translate([length - offset, -w / 2, t])         // Central gusset
            rotate([-90, 0, 0])
                rotate(90 - angle2)
                    rotate_extrude(angle = angle2)
                        translate([0, 0])
                            square([t, w]);

        for(side = [-1, 1])                             // Arm gussets
            translate([length - offset, side * (arm_w + w) / 2 - arm_w / 2, t])
                rotate([-90, 0, 0])
                    rotate(90 - angle2)
                        rotate_extrude(angle = angle + angle2)
                            translate([0, 0])
                                square([t, arm_w]);

    }
}
