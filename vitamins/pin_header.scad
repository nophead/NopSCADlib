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
include <../core.scad>
use <../utils/dogbones.scad>

panel_clearance = 0.2;

function hdr_pitch(type)        = type[1];  //! Header pitch
function hdr_pin_length(type)   = type[2];  //! Header pin length
function hdr_pin_below(type)    = type[3];  //! Header pin length underneath
function hdr_pin_width(type)    = type[4];  //! Header pin size
function hdr_pin_colour(type)   = type[5];  //! Header pin colour
function hdr_base_colour(type)  = type[6];  //! Header insulator colour
function hdr_socket_depth(type) = type[7];  //! Socket depth for female housing

module pin(type, length = undef) { //! Draw a header pin
    w = hdr_pin_width(type);
    l = length == undef ? hdr_pin_length(type) : length;
    chamfer = w / 2;
    color(hdr_pin_colour(type))
        translate_z(l / 2 -hdr_pin_below(type))
            hull() {
                cube([w, w, l - 2 * chamfer], center = true);

                cube([w - chamfer, w - chamfer, l], center = true);
            }
}

module pin_header(type, cols = 1, rows = 1, smt = false, cutout = false) { //! Draw pin header
    pitch =  hdr_pitch(type);
    h = pitch;

    if(cutout)
        dogbone_rectangle([cols * pitch + 2 * panel_clearance, rows * pitch + 2 * panel_clearance, 100], center = false);
    else
        vitamin(str("pin_header(", type[0], cols, rows, arg(smt, false, "smt"), "): Pin header ", cols, " x ", rows));

        translate_z(smt ? 3.5 - h : 0) {
            for(x = [0 : cols - 1], y = [0 : rows - 1])
                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), 0])
                    pin(type);

            color(hdr_base_colour(type))
                linear_extrude(height = h)
                    for(x = [0 : cols - 1], y = [0 : rows - 1])
                        translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), pitch / 2])
                            hull() {
                                chamfer = pitch / 4;
                                square([pitch + eps, pitch - chamfer], center = true);

                                square([pitch - chamfer, pitch + eps], center = true);
                            }
        }
}

module box_header(type, cols = 1, rows = 1, smt = false, cutout = false) { //! Draw box header
    pitch =  hdr_pitch(type);
    w = cols * pitch + 7.62;
    l = rows * pitch + 3.52;
    h = 8.7;
    base = h - 6.4;

    if(cutout)
        dogbone_rectangle([cols * pitch + 2 * panel_clearance, rows * pitch + 2 * panel_clearance, 100], center = false);
    else
        vitamin(str("box_header(", type[0], cols, rows, arg(smt, false, "smt"), "): Pin header ", cols, " x ", rows));

        translate_z(smt ? 3.5 - h : 0) {
            for(x = [0 : cols - 1], y = [0 : rows - 1])
                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), 0])
                    pin(type);

            color(hdr_base_colour(type)) {
                linear_extrude(height = base)
                    square([w, l], center = true);

                linear_extrude(height = h)
                    difference() {
                        square([w, l], center = true);

                        square([w - 2.4, l - 2.4], center = true);

                        translate([0, -l / 2])
                            square([4.5, 4.5], center = true);
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
                linear_extrude(height = width, center = true, convexity = cols * rows)
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

module pin_socket(type, cols = 1, rows = 1, right_angle = false, height = 0, cutout = false) { //! Draw pin socket
    pitch = hdr_pitch(type);
    length = pitch * cols + 0.5;
    width = pitch * rows - 0.08;
    depth = max(hdr_socket_depth(type), height);
    ra_offset = 1.5;
    if(cutout)
        ;
    else {
        vitamin(str("pin_socket(", type[0], ", ", cols, ", ", rows, arg(right_angle, false, "right_angle"), arg(height, 0, "height"),
                               "): Pin socket ", cols, " x ", rows, right_angle ? " right_angle" : ""));
        color(hdr_base_colour(type))
            translate([0, right_angle ? -ra_offset - pitch / 2 : 0, right_angle ? width / 2 : 0])
                rotate([right_angle ? 90 : 0, 0, 0])
                    translate_z(depth / 2)
                        linear_extrude(height = depth, center = true)
                            difference() {
                                square([length, width], center = true);

                            for(x = [0 : cols - 1], y = [0 : rows -1])
                                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2)])
                                    square(hdr_pin_width(type), center = true);
                    }

        color(hdr_pin_colour(type))
            for(x = [0 : cols - 1], y = [0 : rows -1]) {
                translate([pitch * (x - (cols - 1) / 2), pitch * (y - (rows - 1) / 2), 0])
                    pin(type, hdr_pin_below(type) + width / 2 + (y - 0.5) * pitch);

                if(right_angle) {
                    rotate([-90, 0, 0])
                        translate([pitch * (x - (cols - 1) / 2), -pitch * (y - (rows - 1) / 2) -width / 2, 0])
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
