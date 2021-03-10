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
//! Pin headers and sockets, etc.
include <../utils/core/core.scad>
use <../utils/dogbones.scad>

panel_clearance = 0.2;

function hdr_pitch(type)        = type[1];  //! Header pitch
function hdr_pin_length(type)   = type[2];  //! Header pin length
function hdr_pin_below(type)    = type[3];  //! Header pin length underneath
function hdr_pin_width(type)    = type[4];  //! Header pin size
function hdr_pin_colour(type)   = type[5];  //! Header pin colour
function hdr_base_colour(type)  = type[6];  //! Header insulator colour
function hdr_socket_depth(type) = type[7];  //! Socket depth for female housing
function hdr_box_size(type)     = type[8];  //! Box header outside dimensions
function hdr_box_wall(type)     = type[9];  //! Box header wall thickness
function hdr_y_offset(type)     = type[10]; //! Y offset of pins from center of the box
function hdr_ra_box_offset(type)= type[11]; //! Offset between back of the box and the pins
function hdr_ra_height(type)    = type[12]; //! Height of right angle connector

module pin(type, length = undef) { //! Draw a header pin
    w = hdr_pin_width(type);
    l = length == undef ? hdr_pin_length(type) : length;
    chamfer = w / 2;
    color(hdr_pin_colour(type))
        translate_z(l / 2 - hdr_pin_below(type))
            hull() {
                cube([w, w, l - 2 * chamfer], center = true);

                cube([w - chamfer, w - chamfer, l], center = true);
            }
}

module pin_header(type, cols = 1, rows = 1, smt = false, right_angle = false, cutout = false, colour) { //! Draw pin header
    pitch =  hdr_pitch(type);
    base_colour = colour ? colour : hdr_base_colour(type);
    h = pitch;
    ra_offset = 2.4;
    width = pitch * rows;

    module cutout()
        dogbone_rectangle([cols * pitch + 2 * panel_clearance, rows * pitch + 2 * panel_clearance, 100], center = false);

    if(cutout) {
        if(right_angle)
            translate_z(width / 2)
                rotate([-90, 0, 180])
                    cutout();
        else
            cutout();
    }
    else {
        vitamin(str("pin_header(", type[0], ", ", cols, ", ", rows,
                    arg(smt, false, "smt"), arg(right_angle, false, "right_angle"), "): Pin header ", cols, " x ", rows, right_angle ? " right_angle" : ""));

        translate_z(smt ? 3.5 - h : 0) {
            for(x = [0 : cols - 1], y = [0 : rows - 1]) {
                // Vertical part of the pin
                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2)])
                    if(right_angle)
                        pin(type, hdr_pin_below(type) + (y + 0.5) * pitch);
                    else
                        pin(type);

                if(right_angle) {
                    w = hdr_pin_width(type);
                    // Horizontal part of the pin
                    rotate([-90, 0, 180])
                        translate([pitch * (x - (cols - 1) / 2), -pitch * (y - (rows - 1) / 2) - width / 2, hdr_pin_below(type) - (y - (rows - 1) / 2) * pitch])
                            pin(type, hdr_pin_length(type) - hdr_pin_below(type) + ra_offset + pitch / 2 + (y - 0.5) * pitch);
                    // corner
                    translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2) - w / 2, pitch * (y - (rows - 1) / 2) + width / 2 - w / 2])
                        rotate([0, -90, 0])
                            color(hdr_pin_colour(type))
                                rotate_extrude(angle = 90, $fn = 32)
                                    translate([0, -w / 2])
                                        square(w);
                }
            }
            // Insulator
            translate([0, right_angle ? -ra_offset - (rows - 1) * pitch / 2 : 0, right_angle ? width / 2 : 0])
                rotate([right_angle ? 90 : 0, 0, 0])
                    color(base_colour)
                        linear_extrude(h)
                            for(x = [0 : cols - 1], y = [0 : rows - 1])
                                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), pitch / 2])
                                    hull() {
                                        chamfer = pitch / 4;
                                        square([pitch + eps, pitch - chamfer], center = true);

                                        square([pitch - chamfer, pitch + eps], center = true);
                                    }
        }
    }
}

module box_header(type, cols = 1, rows = 1, smt = false, cutout = false) { //! Draw box header
    pitch =  hdr_pitch(type);
    size = hdr_box_size(type);
    w = cols * pitch + 7.62;
    l = rows * pitch + 3.52;
    h = size.z;
    t = hdr_box_wall(type);
    base = h - 6.4;

    if(cutout)
        dogbone_rectangle([cols * pitch + 2 * panel_clearance, rows * pitch + 2 * panel_clearance, 100], center = false);
    else {
        vitamin(str("box_header(", type[0], ", ", cols, ", ", rows, arg(smt, false, "smt"), "): Box header ", cols, " x ", rows));

        translate_z(smt ? 3.5 - h : 0) {
            for(x = [0 : cols - 1], y = [0 : rows - 1])
                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), 0])
                    pin(type, hdr_pin_length(type) - pitch + base);

            color(hdr_base_colour(type)) {
                linear_extrude(base)
                    square([w, l], center = true);

                linear_extrude(h)
                    difference() {
                        square([w, l], center = true);

                        square([w - t, l - t], center = true);

                        translate([0, -l / 2])
                            square([4.5, 4.5], center = true);
                    }
            }
        }
    }
}

module idc_transition(type, cols = 5, skip = [], cutout = false) { //! Draw IDC transition header
    rows = 2;
    pitch =  hdr_pitch(type);
    height = 7.4;
    width = 6;
    length = cols * pitch + 5.08;
    if(cutout)
        ;
    else {
        vitamin(str("idc_transition(", type[0], ", ", cols, "): IDC transition header ", cols, " x ", rows));

        color(hdr_base_colour(type))
            rotate([90, 0, 0])
                linear_extrude(width, center = true, convexity = cols * rows)
                    difference() {
                        translate([0, height / 2])
                            square([length, height], center = true);

                            for(i = [0 : cols * rows - 1])
                                translate([pitch / 2 * (i - (cols * rows - 1) / 2), height / 2])
                                    circle(d = pitch / 2 + eps);

                            slot = pitch / 3;
                            translate([0, height / 2 - pitch / 4 + slot / 2])
                                square([cols * pitch, slot], center = true);
                        }

        for(x = [0 : cols - 1], y = [0 : rows -1])
            if(!in(skip, x))
                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), 0])
                    pin(type, 5);
    }
}

module pin_socket(type, cols = 1, rows = 1, right_angle = false, height = 0, smt = false, cutout = false, colour) { //! Draw pin socket
    pitch = hdr_pitch(type);
    length = pitch * cols + 0.5;
    width = pitch * rows - 0.08;
    depth = height ? height : hdr_socket_depth(type);
    base_colour = colour ? colour : hdr_base_colour(type);
    ra_offset = 1.5;
    if(cutout)
        ;
    else {
        vitamin(str("pin_socket(", type[0], ", ", cols, ", ", rows, arg(right_angle, false, "right_angle"), arg(height, 0, "height"), arg(smt, false, "smt"),
                               "): Pin socket ", cols, " x ", rows, right_angle ? " right_angle" : ""));
        color(base_colour)
            translate([0, right_angle ? -ra_offset - (rows - 1) * pitch / 2 : 0, right_angle ? width / 2 : 0])
                rotate([right_angle ? 90 : 0, 0, 0])
                    translate_z(depth / 2)
                        linear_extrude(depth, center = true)
                            difference() {
                                square([length, width], center = true);

                            for(x = [0 : cols - 1], y = [0 : rows -1])
                                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2)])
                                    square(hdr_pin_width(type), center = true);
                    }

        color(hdr_pin_colour(type))
            for(x = [0 : cols - 1], y = [0 : rows -1]) {
                if(!smt)
                    translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), 0])
                        pin(type, hdr_pin_below(type) + (y + 0.5) * pitch);

                if(right_angle) {
                    rotate([-90, 0, 180])
                        translate([pitch * (x - (cols - 1) / 2), -pitch * (y - (rows - 1) / 2) - width / 2, hdr_pin_below(type) - (y - (rows - 1) / 2) * pitch])
                            pin(type, hdr_pin_below(type) + (y - 0.5) * pitch);

                    w = hdr_pin_width(type);
                    translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2) - w / 2, pitch * (y - (rows - 1) / 2) + width / 2 - w / 2])
                        rotate([0, -90, 0])
                            rotate_extrude(angle = 90, $fn = 32)
                                translate([0, -w / 2])
                                    square(w);
                }
            }
    }
}

module jst_xh_header(type, pin_count, right_angle = false, colour = false, pin_colour = false) { //! Draw JST XH connector
    colour = colour ? colour : hdr_base_colour(type);
    pin_colour = pin_colour ? pin_colour : hdr_pin_colour(type);
    pitch = hdr_pitch(type);
    size = hdr_box_size(type) + [(pin_count - 1) * pitch, 0, 0];
    pinOffsetX = hdr_box_size(type).x / 2;                          // Offset from last pin to box edge
    wallThickness = hdr_box_wall(type);
    y_offset = hdr_y_offset(type);
    ra_box_offset = hdr_ra_box_offset(type);
    ra_h = hdr_ra_height(type);
    ra_z = ra_h - size.y / 2;
    ra_extra = ra_h - size.y;                                   // thicker base for right angle version
    pinWidth = hdr_pin_width(type);

    module jst_xh_socket(type, pin_count, ra = false) {
        module wall() {
            difference() {
                square([size.x, size.y], center = true);

                offset(-wallThickness)
                    square([size.x, size.y], center = true);
            }
            if(right_angle)
                translate([0, size.y / 2 + ra_extra / 2])
                    square([size.x, ra_extra], center = true);
        }

        module slots() {
            cutoutWidth = 1.3;
            cutoutOffset = pinOffsetX + cutoutWidth / 2 - hdr_pin_width(type) / 2;
            for(side = [-1, 1])
                translate([side * (size.x / 2 - cutoutOffset), -size.y / 2 + wallThickness / 2])
                    square([cutoutWidth, 2 * wallThickness], center = true);
        }

        linear_extrude(wallThickness)
            square([size.x, size.y], center = true);                    // the base

        linear_extrude(size.z / 2)                                      // full walls up to the slots
            wall();

        linear_extrude(size.z)                                          // slotted walls to the top
            difference() {
                wall();

                if(type[0] == "jst_xh_header") {
                    if(pin_count > 2)
                        slots();
                    else
                        hull()
                            slots();

                    translate([0, -size.y / 2 + 3 * wallThickness / 2])
                        square([size.x + 1, wallThickness], center = true);
                }

                if(type[0] == "jst_ph_header") {
                    translate([0, -size.y / 2 + wallThickness / 2])
                        square([max((pin_count - 2) * pitch, 1), 2 * wallThickness], center = true);

                    translate([0, -y_offset / 2 - pinWidth / 4])
                        square([size.x + 1, y_offset + pinWidth / 2], center = true);
                }
            }
    } // end module

    color(colour)
        if(right_angle)
            translate([0, -ra_box_offset, ra_z])
                rotate([-90, 0, 180])
                    jst_xh_socket(type, pin_count, true);
        else
            translate([0, y_offset])
                jst_xh_socket(type, pin_count);

    color(pin_colour)
        for(x = [0 : pin_count - 1]) {
            verticalPinLength = right_angle ? hdr_pin_below(type) + ra_z + y_offset : hdr_pin_length(type);
            horizontalPinLength = hdr_pin_length(type) - hdr_pin_below(type) + ra_box_offset;
            translate([pitch * (x - (pin_count - 1) / 2), 0]) {
                pin(type, verticalPinLength);

                if(right_angle) {
                    translate([0, -pinWidth / 2, ra_z - pinWidth / 2 + y_offset])
                        rotate([0, -90, 0])
                            rotate_extrude(angle = 90, $fn = 32)
                                translate([0, -pinWidth / 2])
                                    square(pinWidth);

                    translate([0, -hdr_pin_below(type), ra_z + y_offset])
                        rotate([90, 0, 0])
                            pin(type, horizontalPinLength);
                }
            }
        }
}
