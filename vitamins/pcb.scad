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
//! PCBs and perfboard with optional components. The shape can be a rectangle with optionally rounded corners or a polygon for odd shapes like Arduino.
//
panel_clearance = 0.2;

include <../core.scad>
include <screws.scad>
include <buttons.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/dogbones.scad>
use <../utils/tube.scad>
use <d_connector.scad>

function pcb_name(type)         = type[1];  //! Description
function pcb_length(type)       = type[2];  //! Length
function pcb_width(type)        = type[3];  //! Width
function pcb_thickness(type)    = type[4];  //! Thickness
function pcb_radius(type)       = type[5];  //! Corner radius
function pcb_hole_d(type)       = type[6];  //! Mounting hole diameter
function pcb_land_d(type)       = type[7];  //! Pad around mounting hole
function pcb_colour(type)       = type[8];  //! Colour of the subtrate
function pcb_parts_on_bom(type) = type[9];  //! True if the parts should be separate BOM items
function pcb_holes(type)        = type[10]; //! List of hole positions
function pcb_components(type)   = type[11]; //! List of components
function pcb_accessories(type)  = type[12]; //! List of accessories to go on the BOM, SD cards, USB cables, etc.
function pcb_grid(type)         = type[13]; //! Grid if a perfboard
function pcb_polygon(type)      = type[14]; //! Optional outline polygon for odd shaped boards
function pcb_screw(type, cap = hs_cap) = Len(type[15]) ? type[15] : find_screw(cap, screw_smaller_than(pcb_hole_d(type))); //! Mounting screw type

module pcb_grid(type, x, y, z = 0)  //! Positions children at specified grid positions
    translate([-pcb_length(type) / 2 + pcb_grid(type).x + 2.54 * x,
               -pcb_width(type)  / 2 + pcb_grid(type).y + 2.54 * y, pcb_thickness(type) + z])
        children();

// allows negative ordinates to represent offsets from the far edge
function pcb_coord(type, p) = let(l = pcb_length(type), w = pcb_width(type)) //! Convert offsets from the edge to coordinates relative to the centre
    [(p.x > 0 ? p.x : l + p.x) - l / 2,
     (p.y > 0 ? p.y : w + p.y) - w / 2];

module pcb_screw_positions(type) { //! Positions children at the mounting hole positions
    holes = pcb_holes(type);

    if(len(holes))
        for($i = [0 : len(holes) - 1]) {
            p = pcb_coord(type, holes[$i]);
            translate([p.x, p.y, 0])
                children();
       }
}
//                          p     p   b    p     p       b
//                          i     i   e    i     i       a
//                          t     n   l    n     n       s
//                          c         o                  e
//                          h     l   w    w     c
//                                                       c
//
2p54header = ["2p54header", 2.54, 12, 3.2, 0.66, "gold", grey20, 8.5];

function hdr_pitch(type)        = type[1];  //! Header pitch
function hdr_pin_length(type)   = type[2];  //! Header pin length
function hdr_pin_below(type)    = type[3];  //! Header pin length underneath
function hdr_pin_width(type)    = type[4];  //! Header pin size
function hdr_pin_colour(type)   = type[5];  //! Header pin colour
function hdr_base_colour(type)  = type[6];  //! Header insulator colour
function hdr_socket_depth(type) = type[7];  //! Socket depth for female housing

module pin(type = 2p54header, length = undef) { //! Draw a header pin
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

module pin_header(type = 2p54header, cols = 1, rows = 1, smt = false, cutout = false) { //! Draw pin header
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
                    pin(type, 2);
    }
}

module pin_socket(type = 2p54header, cols = 1, rows = 1, right_angle = false, height = 0, cutout = false) { //! Draw pin socket
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

module chip(length, width, thickness, cutout = false) //! Draw a black cube to represent a chip
    if(!cutout)
        color(grey20)
            translate_z(thickness / 2) cube([length, width, thickness], center = true);

module usb_Ax2(cutout = false) { //! Draw USB type A dual socket
    l = 17;
    w = 13.25;
    h = 15.6;
    flange_t = 0.4;
    h_flange_h = 0.8;
    h_flange_l = 11;
    v_flange_h = 1;
    v_flange_l = 12.15;
    bar = 3.4;
    socket_h = (h - 2 * flange_t - bar) / 2;

    translate_z(h / 2)
        if(cutout)
            rotate([90, 0, 90])
                rounded_rectangle([w + 2 * v_flange_h + 2 * panel_clearance,
                                   h + 2 * h_flange_h + 2 * panel_clearance, 100], r = cnc_bit_r, center = false);
        else
            color("silver") rotate([0, 90, 0]) {
                linear_extrude(height = l, center = true)
                    difference() {
                        square([h, w], center = true);

                        for(s = [-1, 1])
                            translate([s * (bar / 2 + socket_h / 2), 0])
                                square([socket_h, w - 2 * flange_t], center = true);
                    }

                translate_z(-l / 2 + 0.5)
                    cube([h, w, 1], center = true);

                translate_z(l / 2 - flange_t)
                    linear_extrude(height = flange_t) difference() {
                        union() {
                            square([h + 2 * h_flange_h, h_flange_l], center = true);

                            square([v_flange_l, w + 2 * v_flange_h], center = true);
                        }
                        square([h - eps, w - eps], center = true);
                    }
           }
}

module rj45(cutout = false) { //! Draw RJ45 Ethernet connector
    l = 21;
    w = 16;
    h = 13.5;

    plug_h = 6.8;
    plug_w = 12;
    plug_z = 4;

    tab_z = 0.8;
    tab_w = 4;

    translate_z(h / 2)
        if(cutout)
            rotate([90, 0, 90])
                dogbone_rectangle([w + 2 * panel_clearance, h + 2 * panel_clearance, 100], center = false);
        else {
            rotate([0, 90, 0]) {
                mouth = plug_z + plug_h - tab_z;
                color("silver") {
                    linear_extrude(height = l, center = true)
                        difference() {
                            square([h, w], center = true);

                            translate([h / 2 - tab_z - mouth / 2, 0])
                                square([mouth + 0.1, plug_w + 0.1], center = true);
                        }

                    translate_z(-l / 2)
                        cube([h, w, eps], center = true);
                }

                color(grey30) {
                    linear_extrude(height = l - 0.2, center = true)
                        difference() {
                            square([h - 0.1, w - 0.1], center = true);

                            translate([h / 2 - plug_z - plug_h / 2, 0])
                                square([plug_h, plug_w - 0.1], center = true);

                            translate([h / 2 - tab_z - plug_h / 2, 0])
                                square([plug_h, tab_w], center = true);
                        }

                    translate_z(-l / 2 + 1)
                        cube([h - 0.1, w - 0.1, 0.1], center = true);
                }
            }
        }
}

module jack(cutout = false) { //! Draw 3.5mm jack
    l = 12;
    w = 7;
    h = 6;
    d = 6;
    ch = 2.5;

    translate_z(h / 2)
        if(cutout)
            rotate([0, 90, 0])
                cylinder(d = d + 2 * panel_clearance, h = 100);
        else
            color(grey20)
                rotate([0, 90, 0]) {
                    linear_extrude(height = l / 2)
                        difference() {
                            square([h, w], center = true);

                            circle(d = 3.5);
                        }

                    tube(or  = d / 2, ir = 3.5 / 2, h = l / 2 + ch, center = false);

                    translate_z(-l / 4)
                        cube([h, w, l / 2], center = true);
                }
}

module hdmi(cutout = false) { //! Draw HDMI socket
    l = 12;
    iw1 = 14;
    iw2 = 10;
    ih1 = 3;
    ih2 = 4.5;
    h = 6.5;
    t = 0.5;

    module D() {
        hull() {
            translate([-iw1 / 2, h - t - ih1])
                square([iw1, ih1]);

            translate([-iw2 / 2, h - t - ih2])
                square([iw2, ih2]);
        }
    }

    if(cutout)
        rotate([90, 0, 90])
            linear_extrude(height = 100)
                offset(t + panel_clearance)
                    D();
    else
        color("silver")
            rotate([90, 0, 90]) {
                linear_extrude(height = l, center = true)
                    difference() {
                        offset(t)
                            D();
                        D();
                    }

                translate_z(-l / 2)
                    linear_extrude(height = 1)
                        offset(t)
                            D();
            }
}

module usb_uA(cutout = false) { //! Draw USB micro A connector
    l = 6;
    iw1 = 7;
    iw2 = 5.7;
    ih1 = 1;
    ih2 = 1.85;
    h = 2.65;
    t = 0.4;
    flange_h = 3;
    flange_w = 8;

    module D() {
        hull() {
            translate([-iw1 / 2, h - t - ih1])
                square([iw1, ih1]);

            translate([-iw2 / 2, h - t - ih2])
                square([iw2, ih2]);
        }
    }

    if(cutout)
        rotate([90, 0, 90])
            linear_extrude(height = 100)
                offset((flange_h - ih2) / 2 + 2 * panel_clearance)
                    D();
    else
        color("silver") rotate([90, 0, 90]) {
            linear_extrude(height = l, center = true)
                difference() {
                    offset(t)
                        D();

                    D();
                }

            translate_z(-l / 2)
                linear_extrude(height = 1)
                    offset(t)
                        D();

            translate_z(l / 2 - t)
                linear_extrude(height = t) difference() {
                    union() {
                        translate([0, h - t - ih1 / 2])
                            square([flange_w, ih1], center = true);

                        translate([0, h / 2 + flange_h / 4])
                            square([iw1, flange_h / 2], center = true);

                        translate([0, h / 2 - flange_h / 4])
                            square([iw2, flange_h / 2], center = true);
                    }
                    D();
                }
        }
}

module usb_B(cutout = false) {  //! Draw USB B connector
    l = 16.4;
    w = 12.2;
    h = 11;
    tab_w = 5.6;
    tab_h = 3.2;
    d_h = 7.78;
    d_w = 8.45;
    d_w2 = 5;
    d_h2 = d_h - (d_w - d_w2) / 2;

    module D()
        hull() {
            translate([-d_w / 2, 0])
                square([d_w, d_h2]);
            translate([-d_w2 /2, 0])
                square([d_w2, d_h]);
        }


    if(cutout)
        translate([50, 0, h / 2 - panel_clearance])
            cube([100, w + 2 * panel_clearance, h + 2 * panel_clearance], center = true);
    else
        translate_z(h / 2) rotate([90, 0, 90]) {
            color("silver")  {
                linear_extrude(height = l, center = true)
                    difference() {
                        square([w, h], center = true);

                    translate([0, -d_h / 2])
                        offset(delta = 0.2)
                            D();
                    }
                translate_z(-l / 2 + 0.1)
                    cube([w, h, 0.2], center = true);
            }

            color("white") {
                linear_extrude(height = l - 0.4, center = true)
                    difference() {
                        square([w - 0.2, h - 0.2], center = true);

                        translate([0, -d_h / 2])
                            difference() {
                                D();

                                translate([0, d_h / 2])
                                    square([tab_w, tab_h], center = true);
                            }
                    }
                translate_z( -(l - 0.4) / 2 + 1)
                    cube([w - 0.2, h - 0.2, 2], center = true);
            }
    }
}

module barrel_jack(cutout = false) { //! Draw barrel power jack
    l = 13.2;
    w = 8.89;
    h = 11;
    bore_d = 6.3;
    bore_h = 6.5;
    bore_l = 11.8;
    pin_d = 2;
    front = 3.3;
    r = 0.5;
    contact_d = 2;
    contact_w = 4;
    inset = 1;
    if(cutout)
        ;
    else {
        color(grey20) rotate([0, 90, 0]) {
            linear_extrude(height = l, center = true) {
                difference() {
                    translate([-h / 2, 0])
                        rounded_square([h, w], r);

                    translate([-bore_h, 0])
                        circle(d = bore_d);

                    translate([-h / 2 - bore_h, 0])
                        square([h, w], center = true);

                }
            }
            translate_z(l / 2 - front)
                linear_extrude(height = front) {
                    difference() {
                        translate([-h / 2, 0])
                            rounded_square([h, w], r);

                        translate([-bore_h, 0])
                            circle(d = bore_d);
                    }
                }

            translate([-bore_h, 0])
                tube(or = w / 2 - 0.5, ir = bore_d / 2, h = l);

            translate([-bore_h, 0, -l / 2])
                cylinder(d = w -1, h = l - bore_l);
        }
        color("silver") {
            translate([l / 2 - inset - pin_d / 2, 0, bore_h])
                hull() {
                    sphere(pin_d / 2);

                    rotate([0, -90, 0])
                        cylinder(d = pin_d, h = bore_l - inset);
                }
            hull() {
                translate([l / 2 - inset - contact_d / 2, 0, bore_h - bore_d / 2])
                    rotate([90, 0, 0])
                        cylinder(d = contact_d, h = contact_w, center = true);

                translate([l / 2 - bore_l, 0,  bore_h - bore_d / 2 + contact_d / 4])
                    cube([eps, contact_w, eps], center = true);
            }
        }
    }
}

module flex(cutout = false) { //! Draw flexistrip connector
    l = 20.6;
    w = 3;
    h = 5.6;
    top_l = 22.4;
    top_t = 1.1;
    tab_l = 13;
    tab_w = 1;
    slot_l = 16.4;
    slot_w = 0.7;
    slot_offset = 0.6;

    if(cutout)
        ;
    else {
        color(grey30) {
            translate_z(0.5)
                cube([l, w, 1], center = true);

            linear_extrude(height = h)
                difference() {
                    square([l, w], center = true);

                    translate([0, -w / 2 + slot_offset + slot_w / 2])
                        square([slot_l, slot_w], center = true);
                }

            translate_z(h - top_t)
                linear_extrude(height = top_t)
                    difference() {
                        union() {
                            square([top_l, w], center = true);

                            hull() {
                                translate([0, -w / 2 + (w + tab_w) / 2])
                                    square([tab_l - 1, w + tab_w], center = true);

                                square([tab_l, w], center = true);
                            }
                        }

                        translate([0, -w / 2 + slot_offset + slot_w / 2])
                            square([slot_l, slot_w], center = true);

                    }
        }
    }
}

module terminal_35(ways) { //! Draw 3.5mm terminal block
    vitamin(str("terminal_35(", ways, "): Terminal block ", ways, " way 3.5mm"));
    pitch = 3.5;
    width = ways * pitch;
    depth = 7;
    height = 8.3;
    chamfer_h = 3;
    chamfer_d = 1;
    box_z = 0.5;
    box_w = 2.88;
    box_h = 4.1;
    wire_z = 2;
    wire_d = 2;
    pin_l = 4.2;
    pin_d = 0.9;

    module single() {
        screw_r = 1;
        color("blue") {
            rotate([90, 0, 0])
                linear_extrude(height = pitch, center = true)
                    polygon(points = [
                        [ depth / 2,               0],
                        [ depth / 2,               box_z],
                        [-depth / 2 + 1,           box_z],
                        [-depth / 2 + 1,           box_z + box_h],
                        [ depth / 2,               box_z + box_h],
                        [ depth / 2,               height - chamfer_h],
                        [ depth / 2 - chamfer_d,   height],
                        [ -screw_r - eps,          height],
                        [ -screw_r - eps,          box_z + box_h],
                        [  screw_r + eps,          box_z + box_h],
                        [  screw_r + eps,          height],
                        [-depth / 2,               height],
                        [-depth / 2,               0],
                    ]);

            linear_extrude(height = box_z + box_h)
                difference() {
                    square([depth, pitch], center = true);

                    translate([1, 0])
                        square([depth, box_w], center = true);


                }

            translate_z(box_z + box_h)
                linear_extrude(height = height - box_z - box_h)
                    difference() {
                        square([2 * screw_r + 0.1, pitch], center = true);

                        circle(screw_r);
                    }
        }
        color("silver") {
            screw_z = box_z + box_h;
            translate_z(screw_z) {
                cylinder(r = screw_r, h = height - screw_z - 1);      // screw

                linear_extrude(height = height - screw_z - 0.5)
                    difference() {
                        circle(1);

                        square([4, 0.5], center = true);       // screw slot

                        square([0.5, 1.7], center = true);     // second screw slot
                    }

            }
            translate_z(box_z - pin_l)
                cylinder(d = pin_d, h = pin_l + box_z, $fn = 16); // pin

            translate_z(box_z + box_h / 2)                      // terminal
                rotate([0, -90, 0]) {
                    linear_extrude(height = depth - 2, center = true)
                        difference() {
                            square([box_h, box_w], center = true);

                            translate([wire_z - box_z - box_h / 2, 0])
                                circle(d = wire_d);
                        }
                    translate_z(depth / 2 - 1.5)
                        cube([box_h, box_w, 1], center = true);
                }
        }
    }
    for(i = [0: ways -1])
        translate([0, i * pitch - width / 2 + pitch / 2])
            single();
}

module terminal_254(ways, skip = []) { //! Draw 0.1" terminal block
    vitamin(str("terminal_254(", ways, "): Terminal block ", ways, " way 0.1\""));
    pitch = 2.54;
    width = ways * pitch;
    depth = 6.2;
    height = 8.5;
    ledge_height = 5;
    ledge_depth = 0.7;
    top = 3;
    back = 3;
    module single(skip = false) {
        screw_r = 1;
        box_w1 = pitch - 0.4;
        box_h1 = ledge_height - 0.4;
        box_w2 = 2;
        box_h2 = 2;
        color("lime") {
            rotate([90, 0, 0])
                linear_extrude(height = pitch, center = true, convexity = 5)
                    polygon(points = [
                        [ depth / 2,               0],
                        [ depth / 2,               ledge_height / 2 - box_h1 / 2],
                        [ depth / 2 - 0.5,         ledge_height / 2 - box_h1 / 2],
                        [ depth / 2 - 2,           ledge_height / 2 - box_h2 / 2],
                        [-depth / 2 + 1,           ledge_height / 2 - box_h2 / 2],
                        [-depth / 2 + 1,           ledge_height / 2 + box_h2 / 2],
                        [ depth / 2 - 2,           ledge_height / 2 + box_h2 / 2],
                        [ depth / 2 - 0.5,         ledge_height / 2 + box_h1 / 2],
                        [ depth / 2,               ledge_height / 2 + box_h1 / 2],
                        [ depth / 2,               ledge_height],
                        [ depth / 2 - ledge_depth, ledge_height],
                        [   top / 2,               height],
                        [ screw_r + eps,           height],
                        [ screw_r + eps,           ledge_height / 2 + box_h2 / 2],
                        [-screw_r - eps,           ledge_height / 2 + box_h2 / 2],
                        [-screw_r - eps,           height],
                        [  -top / 2,               height],
                        [-depth / 2,               back],
                        [-depth / 2,               0],
                    ]);

            translate_z(ledge_height / 2 + box_h2 / 2)
                linear_extrude(height = height - ledge_height / 2 - box_h2 / 2)
                    difference() {
                        square([screw_r * 2 + 0.1, pitch], center = true);

                        circle(screw_r);
                    }

            linear_extrude(height = ledge_height)
                difference() {
                    translate([0.5, 0])
                        square([depth - 1, pitch], center = true);


                    translate([depth / 2, 0]) {
                        square([9, box_w2], center = true);

                        hull() {
                            square([1, box_w1], center = true);
                            square([4, box_w2], center = true);
                        }
                    }
                }
        }
        if(!skip)
            color("silver")
                translate_z(1) {
                    slot_depth = 1;
                    screw_top = height - 1.5;
                    pin_l = 3.3 + ledge_height / 2 - 2;
                    translate_z(ledge_height / 2)               // screw
                        cylinder(r = 1, h = screw_top - slot_depth - ledge_height / 2);

                    translate_z(screw_top - slot_depth)         // screw head
                        linear_extrude(height = slot_depth)
                            difference() {
                                circle(1);
                                square([4, 0.5], center = true);
                            }

                    translate_z(ledge_height / 2 - 1)
                        rotate([0, 90, 0])
                            linear_extrude(height = 2, center = true)
                                difference() {
                                    square([2, 2], center = true);

                                    square([1.5, 1.9], center = true);

                                }

                    translate([-1.5, 0, ledge_height / 2 - 1])  // terminal back
                        cube([1, 2, 2], center = true);

                    translate_z(ledge_height / 2 - 2 - pin_l / 2)
                        cube([0.44, 0.75, pin_l], center = true);     // pin
                }
    }
    for(i = [0: ways -1])
        translate([0, i * pitch - width / 2 + pitch / 2])
            single(in(skip, i));
}

module molex_254(ways) { //! Draw molex header
    vitamin(str("molex_254(", ways, "): Molex KK header ", ways, " way"));
    pitch = 2.54;
    width = ways * pitch - 0.1;
    depth = 6.35;
    height = 8.15;
    base = 3.18;
    back = 1;
    below = 2.3;
    above = 9;
    color("white")
        union() {
            translate([ -depth / 2, -width / 2,])
                cube([depth, width, base]);

            w = width - pitch;
            translate([- depth / 2, -w / 2])
                cube([back, w, height]);
         }

    color("silver")
        for(i = [0: ways -1])
            translate([0, i * pitch - width / 2 + pitch / 2, (above + below) / 2 - below])
                cube([0.44, 0.75, above + below], center = true);
}

module pcb_component(comp, cutouts = false, angle = undef) { //! Draw pcb component from description
    function show(comp, part) = (comp[3] == part || comp[3] == str("-",part)) && (!cutouts || angle == undef || angle == comp.z);
    rotate(comp.z) {
        if(show(comp, "2p54header")) pin_header(2p54header, comp[4], comp[5], len(comp) > 5 ? comp[6] : false, cutouts);
        if(show(comp, "2p54socket")) pin_socket(2p54header, comp[4], comp[5], comp[6], len(comp) > 7 ? comp[7] : 0, cutouts);
        if(show(comp, "chip")) chip(comp[4], comp[5], comp[6], cutouts);
        if(show(comp, "rj45")) rj45(cutouts);
        if(show(comp, "usb_Ax2")) usb_Ax2(cutouts);
        if(show(comp, "usb_uA")) usb_uA(cutouts);
        if(show(comp, "usb_B")) usb_B(cutouts);
        if(show(comp, "jack")) jack(cutouts);
        if(show(comp, "barrel_jack")) barrel_jack(cutouts);
        if(show(comp, "hdmi")) hdmi(cutouts);
        if(show(comp, "flex")) flex(cutouts);
        if(show(comp, "D_plug")) if(!cutouts) translate_z(d_pcb_offset(comp[4])) d_plug(comp[4], pcb = true);
        if(show(comp, "molex_hdr")) if(!cutouts) molex_254(comp[4]);
        if(show(comp, "term254")) if(!cutouts) terminal_254(comp[4], comp[5]);
        if(show(comp, "term35")) if(!cutouts) terminal_35(comp[4]);
        if(show(comp, "transition")) if(!cutouts) idc_transition(2p54header, comp[4], comp[5]);
        if(show(comp, "block"))
            color(comp[7]) if(!cutouts) translate_z(comp[6] / 2) cube([comp[4], comp[5], comp[6]], center = true);
                           else if(comp[8]) translate([-50, 0, comp[6] / 2 - panel_clearance]) cube([100, comp[5] + 2 * panel_clearance, comp[6] + 2 * panel_clearance], center = true);
        if(show(comp, "button_6mm")) square_button(button_6mm);
    }
}

module pcb_components(type, cutouts = false, angle = undef) { //! Draw list of PCB components on the PCB
    not_on_bom(pcb_parts_on_bom(type))
        for(comp = pcb_components(type)) {
            p = pcb_coord(type, [comp.x, comp.y]);
            if(comp[3][0] == "-")
                translate([p.x, p.y])
                    vflip()
                        pcb_component(comp, cutouts, angle);
            else
                translate([p.x, p.y, pcb_thickness(type)])
                    pcb_component(comp, cutouts, angle);
        }
}

module pcb_cutouts(type, angle = undef) pcb_components(type, true, angle); //! Make cut outs to clear components on a PCB

module pcb_grid_positions(type) {
    x0 = pcb_grid(type).x;
    y0 = pcb_grid(type).y;

    cols = round((pcb_length(type) - 2 * x0) / inch(0.1));
    rows = round((pcb_width(type) - 2 * y0) / inch(0.1));
    for(x = [0 : cols], y = [0 : rows])
        pcb_grid(type, x, y)
            children();
}

module pcb(type) { //! Draw specified PCB
    grid = pcb_grid(type);
    t = pcb_thickness(type);
    if(pcb_name(type))
        vitamin(str("pcb(", type[0], "): ", pcb_name(type)));

    for(part = pcb_accessories(type))
        vitamin(part);

    pcb_components(type);

    color(pcb_colour(type)) linear_extrude(height = t) difference() {
        if(Len(pcb_polygon(type)))
            polygon(pcb_polygon(type));
        else
            rounded_square([pcb_length(type), pcb_width(type)], r = pcb_radius(type));

        pcb_screw_positions(type)
            circle(d = pcb_hole_d(type) + eps);

        if(Len(grid))
            pcb_grid_positions(type)
                circle(d = 1 + eps);
    }

    color("silver")
        translate_z(t / 2)
            pcb_screw_positions(type)
                tube(or =  max(pcb_land_d(type), 1) / 2, ir = pcb_hole_d(type) / 2, h = t + 2 * eps);

    fr4 = pcb_colour(type) == "green";
    plating = 0.15;
    color(fr4 ? "silver" : "gold")
        translate_z(-plating)
            linear_extrude(height = fr4 ? t + 2 * plating : plating)
                if(Len(grid)) {
                    pcb_grid_positions(type)
                        difference() {
                            circle(d = 2);

                            circle(d = 1);
                        }
                    if(fr4) { // oval lands at the ends
                        screw_x = pcb_coord(type, pcb_holes(type)[0]).x;
                        y0 = pcb_grid(type).y;
                        rows = round((pcb_width(type) - 2 * y0) / inch(0.1));
                        for(end = [-1, 1], y = [1 : rows - 1])
                            translate([end * screw_x, y0 + y * inch(0.1) - pcb_width(type) / 2])
                                hull()
                                    for(x = [-1, 1])
                                        translate([x * 1.6 / 2, 0])
                                            circle(d = 2);
                    }
                }
}

module pcb_spacer(screw, height, wall = 1.8) { //! Generate STL for PCB spacer
    stl(str("pcb_spacer", round(screw_radius(screw) * 20), round(height * 10)));

    ir = screw_clearance_radius(screw);
    or = corrected_radius(ir) + wall;

    linear_extrude(height = height)
        poly_ring(or, ir);
}

module pcb_base(type, height, thickness, wall = 2) { //! Generate STL for a base with PCB spacers
    screw = pcb_screw(type);
    ir = screw_clearance_radius(screw);
    or = corrected_radius(ir) + wall;

    union() {
        linear_extrude(height = thickness)
            difference() {
                hull()
                    pcb_screw_positions(type)
                        poly_ring(or, ir);

                pcb_screw_positions(type)
                    poly_circle(ir);
            }

        linear_extrude(height = height)
            pcb_screw_positions(type)
                poly_ring(or, ir);
    }
}

module pcb_assembly(type, height, thickness) { //! Draw PCB assembly with spaces and fasteners in place
    translate_z(height)
        pcb(type);

    screw = pcb_screw(type);
    if(!is_undef(screw)) {
        washer = screw_washer(screw);
        nut = screw_nut(screw);
        screw_length = screw_longer_than(height + thickness + pcb_thickness(type) + washer_thickness(washer) + nut_thickness(nut, true));

        taper = screw_smaller_than(pcb_hole_d(type)) > 2 * screw_radius(screw); // Arduino?
        pcb_screw_positions(type) {
            translate_z(height + pcb_thickness(type))
                screw(screw, screw_length);

            color(pp1_colour)
                if(taper) {
                    h2 = max(0,  height - 2);
                    if(h2)
                        pcb_spacer(screw, h2);
                    pcb_spacer(screw, height, 2 * extrusion_width); // Thin as can be at the top because there is no clearance around the holes.
                }
                else
                    pcb_spacer(screw, height);

            translate_z(-thickness)
                vflip()
                    nut_and_washer(nut, true);
        }
    }
}
