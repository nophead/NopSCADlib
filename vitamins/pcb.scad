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
include <buttons.scad>
include <green_terminals.scad>
include <pin_headers.scad>
use <microswitch.scad>
use <7_segment.scad>

use <../utils/rounded_cylinder.scad>
use <../utils/dogbones.scad>
use <../utils/thread.scad>
use <../utils/tube.scad>
use <../utils/pcb_utils.scad>

use <d_connector.scad>
use <led.scad>
use <dip.scad>
use <axial.scad>
use <radial.scad>
use <smd.scad>
use <terminal.scad>
include <potentiometers.scad>
use <component.scad>

function pcb_name(type)         = type[1];  //! Description
function pcb_length(type)       = type[2];  //! Length
function pcb_width(type)        = type[3];  //! Width
function pcb_thickness(type)    = type[4];  //! Thickness
function pcb_radius(type)       = type[5];  //! Corner radius
function pcb_hole_d(type)       = type[6];  //! Mounting hole diameter
function pcb_land_d(type)       = type[7];  //! Pad around mounting hole
function pcb_colour(type)       = type[8];  //! Colour of the substrate
function pcb_parts_on_bom(type) = type[9];  //! True if the parts should be separate BOM items
function pcb_holes(type)        = type[10]; //! List of hole positions
function pcb_components(type)   = type[11]; //! List of components
function pcb_accessories(type)  = type[12]; //! List of accessories to go on the BOM, SD cards, USB cables, etc.
function pcb_grid(type)         = type[13]; //! Grid origin if a perfboard
function pcb_polygon(type)      = type[14]; //! Optional outline polygon for odd shaped boards
function pcb_screw(type, cap = hs_cap) = Len(type[15]) ? type[15] : find_screw(cap, screw_smaller_than(pcb_hole_d(type))); //! Mounting screw type
function pcb_size(type) = [pcb_length(type), pcb_width(type), pcb_thickness(type)]; //! Length, width and thickness in a vector

function pcb(name, desc, size, corner_r = 0, hole_d = 0, land_d = 0, colour = "green", parts_on_bom = false, holes = [], components = [], accessories = [], grid = undef, polygon = undef, screw = undef) = //! Constructor
             [name, desc, size.x, size.y, size.z, corner_r, hole_d, land_d, colour, parts_on_bom, holes, components, accessories, grid, polygon, screw ];

function pcb_component(type, name, index = 0) = //! Return the component specified by name and index
    [for(component = pcb_components(type)) if(component[3] == name) component][index];

function pcb_grid_pos(type, x, y, z = 0, i = 0) = //! Returns a pcb grid position
    let(grid = pcb_grid(type))
        [-pcb_size(type).x / 2 + grid[i]     + x * (is_undef(grid[i + 5]) ? 2.54 : grid[i + 5]),
         -pcb_size(type).y / 2 + grid[i + 1] + y * (is_undef(grid[i + 6]) ? 2.54 : grid[i + 6]),
          pcb_size(type).z + z];

module pcb_grid(type, x, y, z = 0, i = 0)  //! Positions children at specified grid position
    translate(pcb_grid_pos(type, x, y, z, i))
        children();

// allows negative ordinates to represent offsets from the far edge
function pcb_coord(type, p) = let(l = pcb_length(type), w = pcb_width(type)) //! Convert offsets from the edge to coordinates relative to the centre
    [(p.x >= 0 ? p.x : l + p.x) - l / 2,
     (p.y >= 0 ? p.y : w + p.y) - w / 2];

module pcb_hole_positions(type, all = true) { // Position children at the hole positions, including holes not used for screws
    holes = pcb_holes(type);

    for($i = [0 : 1 : len(holes) - 1]) {
        hole = holes[$i];
        if(len(hole) == 2 || all)
            translate(pcb_coord(type, hole))
                children();
   }
}

module pcb_screw_positions(type)  //! Positions children at the mounting hole positions
    pcb_hole_positions(type, false) children();

module chip(length, width, thickness, colour, cutout = false) //! Draw a coloured cube to represent a chip, or other rectangular component, or cylinder if width is zero
    if(!cutout)
        color(colour)
            if(width)
                translate_z(thickness / 2) cube([length, width, thickness], center = true);
            else
                cylinder(d = length, h = thickness);

module usb_A_tongue() {
    l = 9;
    w = 12;
    h = 2;

    color("white")
        translate([-1, 0 , h / 2])
            rotate([90, 0, 90])
                hull() {
                    linear_extrude(l - 2)
                        square([w, h], center = true);

                    linear_extrude(l)
                        square([w - 1, h - 1], center = true);
                }
}

module usb_vAx1(cutout = false) { //! Draw a vertical USB type A single socket
    h = 5.8;
    w = 13.8;
    translate([0, h / 2, w / 2])
        rotate([90, 0, 0])
            usb_A(h = h, v_flange_l = 0, bar = 0, cutout = cutout, l = 14, h_flange_l = 0, flange_t = 0.3, w = w);
}

module usb_Ax1(cutout = false) { //! Draw USB type A single socket
    usb_A(h = 6.5, v_flange_l = 4.5, bar = 0, cutout = cutout);
}

module usb_Ax2(cutout = false) { //! Draw USB type A dual socket
    usb_A(h = 15.6, v_flange_l = 12.15, bar = 3.4, cutout = cutout);
}

module usb_A(h, v_flange_l, bar, cutout, l=17, h_flange_l = 11, flange_t = 0.4, w = 13.25) {
    h_flange_h = 0.8;
    v_flange_h = 1;
    socket_h = (h - 2 * flange_t - bar) / 2;

    translate_z(h / 2)
        if(cutout)
            rotate([90, 0, 90])
                rounded_rectangle([w + 2 * v_flange_h + 2 * panel_clearance,
                                   h + 2 * h_flange_h + 2 * panel_clearance, 100], r = cnc_bit_r);
        else {
            color("silver") rotate([0, 90, 0]) {
                linear_extrude(l, center = true)
                    difference() {
                        square([h, w], center = true);

                        for(s = [-1, 1])
                            translate([s * (bar / 2 + socket_h / 2), 0])
                                square([socket_h, w - 2 * flange_t], center = true);
                    }

                translate_z(-l / 2 + 0.5)
                    cube([h, w, 1], center = true);

                translate_z(l / 2 - flange_t)
                    linear_extrude(flange_t) difference() {
                        union() {
                            if(h_flange_l)
                                square([h + 2 * h_flange_h, h_flange_l], center = true);

                            if(v_flange_l)
                                square([v_flange_l, w + 2 * v_flange_h], center = true);
                        }
                        square([h - eps, w - eps], center = true);
                    }
                }

                for(z = bar ?  [-1, 1] : [0])
                    translate_z(z * (bar / 2 + socket_h / 2))
                        translate([l - 17, 0])
                            usb_A_tongue();
            }
}

module molex_usb_Ax2(cutout) { //! Draw Molex dual USB A connector suitable for perf board
    w = 15.9;
    h = 16.6;
    l = 17;
    pin_l = 2.8;
    clearance = 0.2;
    tag_l = 4.4;
    tag_r = 0.5;
    tag_w = 1.5;
    tag_t = 0.3;
    tag_p = 5.65;

    if(cutout)
        translate([0, -w / 2 - clearance, -clearance])
            cube([100, w + 2 * clearance, h + 2 * clearance]);
    else {
        color(silver)
            translate([-l / 2, 0])
                rotate([90, 0, 90])
                    translate([-w / 2, 0]) {
                        cube([w, h, l - 9]);

                        linear_extrude(l)
                            difference() {
                                square([w, h]);

                                for(z = [-1, 1])
                                    translate([w / 2, h / 2 + z * 8.5 / 2])
                                        square([12.6, 5.08], center = true);
                            }
                    }

        for(z = [-1, 1])
            translate_z(h / 2 + z * 8.5 / 2)
                usb_A_tongue();

        color(silver)
            rotate(-90) {
                for(x = [-1.5 : 1 : 1.5], y = [0.5 : 1 : 1.5])
                    translate([inch(x / 10), -l / 2 + inch(y / 10)]) {
                        hull() {
                            cube([0.6, 0.3, 2 * pin_l - 2], center = true);

                            cube([0.4, 0.3, 2 * pin_l], center = true);
                        }
                        solder();
                    }

                for(side = [-1, 1], end = [0, 1])
                    translate([side * w / 2, -l / 2 + tag_w / 2 + end * tag_p])
                        rotate(-side * 90)
                            hull() {
                                translate([0, tag_l - tag_r])
                                    cylinder(r = tag_r, h = tag_t);

                                translate([-tag_w / 2, 0])
                                    cube([tag_w, eps, tag_t]);
                            }
            }
    }
}

module molex_usb_Ax1(cutout) { //! Draw Molex USB A connector suitable for perf board
    w = 15.3;
    h = 7.7;
    l = 14.5;
    pin_l = 2.8;
    clearance = 0.2;
    tag_l = 4.4;
    tag_r = 0.5;
    tag_w = 1.5;
    tag_t = 0.3;

    if(cutout)
        translate([0, -w / 2 - clearance, -clearance])
            cube([100, w + 2 * clearance, h + 2 * clearance]);
    else {
        color(silver)
            translate([-l / 2, 0])
                rotate([90, 0, 90])
                    translate([-w / 2, 0]) {
                        cube([w, h, l - 9]);

                        linear_extrude(l)
                            difference() {
                                square([w, h]);

                                 translate([w / 2, h / 2])
                                    square([12.6, 5.08], center = true);
                            }
                    }

        translate([-1.5, 0, h / 2])
            usb_A_tongue();

        color(silver)
            rotate(-90) {
                for(x = [-1.5 : 1 : 1.5])
                    translate([inch(x / 10), - l / 2 + inch(0.05)]) {
                        hull() {
                            cube([0.6, 0.3, 2 * pin_l - 2], center = true);

                            cube([0.4, 0.3, 2 * pin_l], center = true);
                        }
                        solder();
                    }

                for(side = [-1, 1])
                    translate([side * w / 2, -l / 2 + 4.2])
                        rotate(-side * 90)
                            hull() {
                                translate([0, tag_l - tag_r])
                                    cylinder(r = tag_r, h = tag_t);

                                translate([-tag_w / 2, 0])
                                    cube([tag_w, eps, tag_t]);
                            }
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
                    linear_extrude(l, center = true)
                        difference() {
                            square([h, w], center = true);

                            translate([h / 2 - tab_z - mouth / 2, 0])
                                square([mouth + 0.1, plug_w + 0.1], center = true);
                        }

                    translate_z(-l / 2)
                        cube([h, w, eps], center = true);
                }

                color(grey(30)) {
                    linear_extrude(l - 0.2, center = true)
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
            color(grey(20))
                rotate([0, 90, 0]) {
                    linear_extrude(l / 2)
                        difference() {
                            square([h, w], center = true);

                            circle(d = 3.5);
                        }

                    tube(or  = d / 2, ir = 3.5 / 2, h = l / 2 + ch, center = false);

                    translate_z(-l / 4)
                        cube([h, w, l / 2], center = true);
                }
}

module buzzer(height, diameter, colour) { //! Draw PCB buzzer with specified height, diameter and colour
    color (colour)
        tube(or = diameter / 2, ir = height > 5 ? 1 : 0.75, h = height, center = false);

    color("white")
        cylinder(d = 2, h = max(height - 3 , 0.5));
}

function hdmi_depth(type)     = type[2]; //! Front to back depth
function hdmi_width1(type)    = type[3]; //! Inside width at the top
function hdmi_width2(type)    = type[4]; //! Inside width at the bottom
function hdmi_height1(type)   = type[5]; //! Inside height at the sides
function hdmi_height2(type)   = type[6]; //! Inside height in the middle
function hdmi_height(type)    = type[7]; //! Outside height above the PCB
function hdmi_thickness(type) = type[8]; //! Wall thickness of the metal

hdmi_full = [ "hdmi_full", "HDMI socket",        12,   14,   10,  3,    4.5, 6.5, 0.5 ];
hdmi_mini = [ "hdmi_mini", "Mini HDMI socket",    7.5, 10.5, 8.3, 1.28, 2.5, 3.2, 0.35 ];
hdmi_micro = [ "hdmi_micro", "Micro HDMI socket", 8.5,  5.9, 4.43, 1.4, 2.3, 3,   0.3 ];

module hdmi(type, cutout = false) { //! Draw HDMI socket
    vitamin(str("hdmi(", type[0], "): ", type[1]));

    l = hdmi_depth(type);
    iw1 = hdmi_width1(type);
    iw2 = hdmi_width2(type);
    ih1 = hdmi_height1(type);
    ih2 = hdmi_height2(type);
    h = hdmi_height(type);
    t = hdmi_thickness(type);

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
            linear_extrude(100)
                offset(t + panel_clearance)
                    D();
    else
        color("silver")
            rotate([90, 0, 90]) {
                linear_extrude(l, center = true)
                    difference() {
                        offset(t)
                            D();
                        D();
                    }

                translate_z(-l / 2)
                    linear_extrude(1)
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
            linear_extrude(100)
                offset((flange_h - ih2) / 2 + 2 * panel_clearance)
                    D();
    else
        color("silver") rotate([90, 0, 90]) {
            linear_extrude(l, center = true)
                difference() {
                    offset(t)
                        D();

                    D();
                }

            translate_z(-l / 2)
                linear_extrude(1)
                    offset(t)
                        D();

            translate_z(l / 2 - t)
                linear_extrude(t) difference() {
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

module usb_miniA(cutout = false) { //! Draw USB mini A connector
    l = 9.2;
    iw1 = 7.0;
    iw2 = 6.0;
    ih1 = 1.05;
    ih2 = 1.0;
    h = 4.0;
    t = 0.4;

    module D() {
        hull() {
            translate([-iw1 / 2, h - t - ih1])
                square([iw1, ih1]);

            translate([-iw2 / 2, t + ih2])
                square([iw2, eps]);

        }
        translate([-iw2 / 2, t])
            square([iw2, ih2]);
    }

    if(cutout)
        rotate([90, 0, 90])
            linear_extrude(100)
                offset(2 * panel_clearance)
                    D();
    else
        color("silver") rotate([90, 0, 90]) {
            linear_extrude(l, center = true)
                difference() {
                    offset(t)
                        D();

                    D();
                }

            translate_z(-l / 2)
                linear_extrude(1)
                    offset(t)
                        D();
        }
}

module usb_C(cutout = false) { //! Draw USB C connector
    l = 7.35;
    w = 8.94;
    h = 3.26;
    t = 0.4;
    flange_h = 3;
    flange_w = 8;

    module O()
        translate([0, h / 2])
            rounded_square([w, h], h / 2 - 0.5, center = true);

    if(cutout)
        rotate([90, 0, 90])
            linear_extrude(100)
                offset(2 * panel_clearance)
                    O();
    else
        color("silver") rotate([90, 0, 90]) {
            linear_extrude(l, center = true)
                difference() {
                    O();

                    offset(-t)
                        O();
                }

            translate_z(-l / 2)
                linear_extrude(2.51)
                    O();

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
                linear_extrude(l, center = true)
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
                linear_extrude(l - 0.4, center = true)
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
    if(cutout) {
        rotate([0, 90, 0])
            translate([-bore_h, 0])
                cylinder(d = bore_d + panel_clearance, h = 100);
    } else {
        color(grey(20)) rotate([0, 90, 0]) {
            linear_extrude(l, center = true) {
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
                linear_extrude(front) {
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

module uSD(size, cutout = false) { //! Draw uSD socket
    min_w = 12;
    w = size.x - min_w;
    t = 0.15;

    if(cutout)
        ;
    else
        translate_z(size.z / 2) {
            color("silver")
                rotate([90, 0, 90]) {
                    linear_extrude(size.y, center = true)
                        difference() {
                            square([size.x, size.z], center = true);
                            square([size.x - 2 * t, size.z - 2 * t], center = true);
                        }

                    translate_z(-size.y / 2 + t / 2)
                        cube([size.x, size.z, t], center = true);
                }
            if(w > 0)
                color(grey(20))
                    rotate([90, 0, 90])
                        translate_z(t)
                            linear_extrude(size.y - t, center = true)
                                difference() {
                                    square([size.x - 2 * t, size.z - 2 * t], center = true);

                                    translate([-size.x / 2 + min_w / 2 + 0.7, size.z / 2 - t])
                                        square([min_w, 2.2], center = true);
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
        color(grey(30)) {
            translate_z(0.5)
                cube([l, w, 1], center = true);

            linear_extrude(h)
                difference() {
                    square([l, w], center = true);

                    translate([0, -w / 2 + slot_offset + slot_w / 2])
                        square([slot_l, slot_w], center = true);
                }

            translate_z(h - top_t)
                linear_extrude(top_t)
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

small_ff = [[11.8, 0.9], [17, 1.4, 1.2], [12, 1.6, 1.2], [16, 1.1, 1.2]];
large_ff = [[16,  1.25], [22, 1.5, 2.5], [16, 4.0, 2.5], [21, 0,   2.5]];

function ff_slot(type)  = type[0]; //! Flat flex slot size
function ff_latch(type) = type[1]; //! Flat flex latch size
function ff_mid(type)   = type[2]; //! Flat flex middle section size
function ff_back(type)  = type[3]; //! Flat flex back section size

module flat_flex(type, cutout = false) { //! Draw flat flexistrip connector as used on RPI0
    slot = ff_slot(type);
    latch = ff_latch(type);
    mid =   ff_mid(type);
    back =  ff_back(type);

    w = latch.y + mid.y + back.y;
    if(cutout)
        ;
    else {
        color(grey(30))
            translate([0, w / 2 - latch.y])
                rotate([90, 0, 180])
                    linear_extrude(latch.y)
                        difference() {
                            translate([-latch.x / 2, 0])
                                square([latch.x, latch.z]);

                            square([slot.x, slot.y * 2], center = true);
                        }

        color("ivory") {
            translate([-back.x / 2, -w / 2])
                if(back.y)
                    cube(back);

            translate([-mid.x / 2,  -w / 2 + back.y])
                cube(mid);
       }

       color(grey(80))
            translate([-back.x / 2, -w / 2 + back.y + eps])
                cube([back.x, mid.y - 2 * eps, mid.z - eps]);
    }
}

module terminal_35(ways, colour = "blue") { //! Draw 3.5mm terminal block
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
        color(colour) {
            rotate([90, 0, 0])
                linear_extrude(pitch, center = true)
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

            linear_extrude(box_z + box_h)
                difference() {
                    square([depth, pitch], center = true);

                    translate([1, 0])
                        square([depth, box_w], center = true);


                }

            translate_z(box_z + box_h)
                linear_extrude(height - box_z - box_h)
                    difference() {
                        square([2 * screw_r + 0.1, pitch], center = true);

                        circle(screw_r);
                    }
        }
        color("silver") {
            screw_z = box_z + box_h;
            translate_z(screw_z) {
                cylinder(r = screw_r, h = height - screw_z - 1);      // screw

                linear_extrude(height - screw_z - 0.5)
                    difference() {
                        circle(1);

                        square([4, 0.5], center = true);       // screw slot

                        square([0.5, 1.7], center = true);     // second screw slot
                    }

            }
            translate_z(box_z - pin_l)
                cylinder(d = pin_d, h = pin_l + box_z, $fn = fn); // pin

            solder(pin_d / 2);

            translate_z(box_z + box_h / 2)                      // terminal
                rotate([0, -90, 0]) {
                    linear_extrude(depth - 2, center = true)
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

module molex_254_housing(ways) { //! Draw a Molex KK housing
    vitamin(str("molex_254_housing(", ways, "): Molex KK housing ", ways, " way"));
    pitch = 2.54;
    width = ways * pitch + 0.6;
    depth = 4.9;
    height = 12.8;
    header_depth = 6.35;
    tab = [1.73, 0.96, 2.15];

    color("white")
        translate([(header_depth - depth) / 2, 0]) {
            linear_extrude(height)
                square([depth, width], center = true);

            for(side = [-1, 1])
                translate([-depth / 2 - tab.x / 2, side * (pitch / 2 - tab.y / 4) * ways, tab.z / 2])
                    cube(tab, center = true);
        }
}

module molex_254(ways, right_angle = 0, skip = undef) { //! Draw molex KK header, set `right_angle` to 1 for normal right angle version or -1 for inverted right angle version.
    vitamin(str("molex_254(", ways, arg(right_angle, 0, "right_angle"), arg(skip, undef, "skip"), "): Molex KK header ", ways, " way", right_angle ? " right angle" : ""));
    pitch = 2.54;
    width = ways * pitch - 0.1;
    depth = 6.35;
    height = 8.15;
    base = 3.18;
    back = 1;
    below = 3.3;
    above = 9;
    pin_w = 0.64;
    r = 1;
    a = right_angle ? depth / 2 - r : above;
    ra_offset = 2.2;

    color("white")
        translate(right_angle ? [-ra_offset, 0, depth / 2] : [ 0, 0, 0])
            rotate(right_angle ? right_angle > 0 ? [180, 90, 0] : [0, -90, 0] : [ 0, 0, 0]) {
                union() {
                    translate([ -depth / 2, -width / 2,])
                        cube([depth, width, base]);

                    w = width - pitch;
                    translate([- depth / 2, -w / 2])
                        cube([back, w, height]);
                 }

                 if(show_plugs)
                    translate_z(base + 0.1)
                        molex_254_housing(ways);
            }

    color("silver")
        for(i = [0 : ways -1])
            if(is_undef(skip) || !in(skip, i))
                translate([0, i * pitch - width / 2 + pitch / 2]) {
                    chamfer = pin_w / 2;
                    l1 = a + below;
                    translate_z(l1 / 2 - below)
                        hull() {
                            cube([pin_w, pin_w, l1 - 2 * chamfer], center = true);

                            cube([pin_w - chamfer, pin_w - chamfer, l1], center = true);
                        }

                    solder();

                    l = above + ra_offset - r;
                    if(right_angle) {
                        translate([-l / 2 - r, 0, depth / 2])
                            hull() {
                                cube([l - 2 * chamfer, pin_w, pin_w], center = true);

                                cube([l, pin_w - chamfer, pin_w - chamfer], center = true);
                            }

                        translate([-r - pin_w / 2, 0, a - pin_w / 2])
                            rotate([90, 0, 0])
                                rotate_extrude(angle = 90)
                                    translate([r + pin_w / 2, 0])
                                        square(pin_w, true);
                    }
                }
}

module vero_pin(cropped = false) { //! Draw a vero pin
    vitamin("vero_pin(): Vero board pin");
    l = cropped ? 7.5 : 10;
    d = 1.03;
    spline_d = 1.23;
    spline_h = 1.3;
    collar_d = 1.72;
    collar_h = 0.65;
    above = 3.6;
    splines = 6;
    spline_w = 0.3;

    color(silver) {
        translate_z(-l + above + collar_h)
            cylinder(d = d, h = l, $fn = fn);

        cylinder(d = collar_d, h = collar_h);

        for(i = [0 : splines - 1])
            rotate(360 * i / splines)
                translate([d / 2, 0, -spline_h])
                    rounded_rectangle([spline_d - d, spline_w, spline_h], spline_w / 4, center = false);
    }
    solder(d / 2);
}

module standoff(h, d, h2, d2) { //! Draw a standoff
    color("white") {
        cylinder(d = d, h = h);

        hull() {
            translate_z(-(h2 - h) / 2 + d2 / 2)
                sphere(d = d2);

            translate_z(h +(h2 - h) / 2 - d2 / 2)
                sphere(d = d2);
        }
    }
}

module trimpot10(vertical, cutout = false) { //! Draw a ten turn trimpot
    l = 10;
    w = 9.5;
    h = 4.8;
    foot_w = 1;
    foot_h = 0.5;
    screw_h = 1.5;
    screw_d = 2.25;
    slot_w =  0.6;
    slot_h = 0.8;

    module screw_pos()
        translate([-w / 2 + screw_d / 2, -l / 2, h - screw_d / 2])
            rotate([90, 0, 0])
                children();

    translate(vertical ? [0, -h / 2, l / 2] : [0, 0])
        rotate([vertical ? -90 : 0, 0, 0]) {
            if(cutout)
                screw_pos()
                    poly_drill(r = (screw_d + 1) / 2, h = 100, center = false);
            else
                color("#2CA1FD") {
                    translate([0, -foot_h / 2, foot_h / 2 + h / 2])
                        cube([w, l - foot_h, h - foot_h], center = true);

                    for(x = [-1, 1], y = [-1, 1])
                        translate([x * (w - foot_w) / 2, y * (l - foot_w) / 2, h / 2])
                            cube([foot_w, foot_w, h], center = true);

                }

                color(brass)
                    screw_pos() {
                        cylinder(d = screw_d, h = screw_h - slot_h);

                        linear_extrude(screw_h)
                            difference() {
                                circle(d = screw_d);

                                square([slot_w, screw_d + 1], center = true);
                            }
                    }
             }
}

//! Draw a 1/4" square trimpot (https://ar.mouser.com/datasheet/2/54/3362-776956.pdf)
module trimpot3362() {
    l = 6.60;
    w = 6.99;
    h = 4.88;
    foot_w = 0.38;
    foot_h = 0.38;
    screw_h = 0;
    screw_d = 2.25;
    slot_w =  0.6;
    slot_h = 0.8;

    module adjust(){
      d = 2.77;
      width = 0.64;
      deep = 0.89;

      color("white"){
        difference(){
          cylinder(d=d, h=2*deep, center=true);
          translate([0, 0, deep-deep/2+0.01])
            cube([d, width, deep], center=true);
          translate([0, 0, deep-deep/2+0.01]) rotate([0, 0, 90])
            cube([d, width, deep], center=true);
        }
      }
    }

    color("#2CA1FD") {
      difference(){
      translate([0, 0, foot_h / 2 + h / 2])
        cube([w, l, h - foot_h], center = true);
      translate_z(h-0.88) hull() adjust();
      //Grub
      for(ang=[-30:30:210])
        rotate([0, 0, ang])
        translate([2.77/2+0.46, 0, h]) cube([1, 0.3, 0.3], center=true);
      }

      for(x = [-1, 1], y = [1, -1])
        translate([x * (w - foot_w) / 2, y * (l - foot_w) / 2, h / 2])
          cube([foot_w, foot_w, h], center = true);

      for(x = [-1, 1])
        translate([x*(w/2-1), -l/2, h/2+foot_h/2])
          cube([0.7, 0.7, h-foot_h], center=true);
    }
    translate([0, 0, h-0.89]) adjust();
}

module block(size, colour, makes_cutout, cutouts, r = 0, rtop = 0) //! Draw a coloured cube to represent a random PCB component
    if(cutouts) {
        if(makes_cutout)
             translate([-50, 0, size.z / 2 - panel_clearance])
                cube([100, size.y + 2 * panel_clearance, size.z + 2 * panel_clearance], center = true);
    }
    else
        color(colour)
            let($fs = fs, $fa = fa)
                if(rtop)
                    rounded_top_rectangle(size, r, rtop);
                else
                    rounded_rectangle(size, r);

module pcb_component(comp, cutouts = false, angle = undef) { //! Draw pcb component from description
    function show(comp, part) = (comp[3] == part || comp[3] == str("-",part)) && (!cutouts || angle == undef || angle == comp.z);
    function param(n, default = 0) = len(comp) > n && !is_undef(comp[n]) ? comp[n] : default;
    rotate(comp.z) {
        // Components that have a cutout parameter go in this section
        if(show(comp, "2p54header")) let($show_plugs = show_plugs && param(9, true))
                                        pin_header(2p54header, comp[4], comp[5], param(6, false), param(8, false), cutouts, colour = param(7, undef));
        if(show(comp, "2p54joiner"))    pin_header(2p54joiner, comp[4], comp[5], param(6, false), param(8, false), cutouts, colour = param(7, undef));
        if(show(comp, "2p54boxhdr")) let($show_plugs = show_plugs && param(7, true))
                                        box_header(2p54header, comp[4], comp[5], param(6, false), cutouts, param(8, false));
        if(show(comp, "2p54socket"))    pin_socket(2p54header, comp[4], comp[5], param(6, false), param(7, 0), param(8, false), cutouts, param(9, undef));
        if(show(comp, "chip"))          chip(comp[4], comp[5], comp[6], param(7, grey(30)), cutouts);
        if(show(comp, "rj45"))          rj45(cutouts);
        if(show(comp, "usb_A"))         usb_Ax1(cutouts);
        if(show(comp, "usb_vAx1"))      usb_vAx1(cutouts);
        if(show(comp, "usb_Ax1"))       usb_Ax1(cutouts);
        if(show(comp, "usb_Ax2"))       usb_Ax2(cutouts);
        if(show(comp, "usb_uA"))        usb_uA(cutouts);
        if(show(comp, "usb_miniA"))     usb_miniA(cutouts);
        if(show(comp, "usb_B"))         usb_B(cutouts);
        if(show(comp, "usb_C"))         usb_C(cutouts);
        if(show(comp, "jack"))          jack(cutouts);
        if(show(comp, "barrel_jack"))   barrel_jack(cutouts);
        if(show(comp, "hdmi"))          hdmi(hdmi_full, cutouts);
        if(show(comp, "mini_hdmi"))     hdmi(hdmi_mini, cutouts);
        if(show(comp, "micro_hdmi"))    hdmi(hdmi_micro, cutouts);
        if(show(comp, "flex"))          flex(cutouts);
        if(show(comp, "flat_flex"))     flat_flex(param(4, false) ? large_ff : small_ff, cutouts);
        if(show(comp, "uSD"))           uSD(comp[4], cutouts);
        if(show(comp, "trimpot10"))     trimpot10(param(4, false), cutouts);
        if(show(comp, "molex_usb_Ax2")) molex_usb_Ax2(cutouts);
        if(show(comp, "molex_usb_Ax1")) molex_usb_Ax1(cutouts);
        if(show(comp, "smd_led"))       smd_led(comp[4], comp[5], cutouts);
        if(show(comp, "7seg"))          let(z = param(6, 0)) translate_z(z) 7_segment_digits(comp[4], comp[5], pin_length = z + 3, cutout = cutouts);
        if(show(comp, "block"))         block(size = [comp[4], comp[5], comp[6]], colour = comp[7], makes_cutout = param(8), r = param(9, 0), rtop = param(10, 0));
        if(!cutouts) {
            // Components that don't have a cutout parameter go in this section
            if(show(comp, "button"))        square_button(comp[4], param(6, "yellow"), param(5, false));
            if(show(comp, "button_6mm"))    square_button(button_6mm);
            if(show(comp, "button_4p5mm"))  square_button(button_4p5mm);
            if(show(comp, "microswitch"))   translate_z(microswitch_thickness(comp[4])/2) microswitch(comp[4]);
            if(show(comp, "pcb"))           translate_z(comp[4]) pcb(comp[5]);
            if(show(comp, "standoff"))      standoff(comp[4], comp[5], comp[6], comp[7]);
            if(show(comp, "term254"))       green_terminal(gt_2p54,comp[4], comp[5], param(6,"lime"));
            if(show(comp, "gterm"))         green_terminal(comp[4], comp[5], comp[6], param(7,"lime"));
            if(show(comp, "gterm35"))       green_terminal(gt_3p5, comp[4], comp[5], param(6,"lime"));
            if(show(comp, "gterm508"))      green_terminal(gt_5p08, comp[4], comp[5], param(6,"lime"));
            if(show(comp, "gterm635"))      green_terminal(gt_6p35, comp[4], comp[5], param(6,"lime"));
            if(show(comp, "term35"))        terminal_35(comp[4], param(5,"blue"));
            if(show(comp, "transition"))    idc_transition(2p54header, comp[4], comp[5]);
            if(show(comp, "led"))           let(z = param(6, 0)) translate_z(z + eps) led(comp[4], comp[5], 2.6 + z, param(7, 0));
            if(show(comp, "pdip"))          pdip(comp[4], comp[5], param(6, false), param(7, inch(0.3)));
            if(show(comp, "ax_res"))        ax_res(comp[4], comp[5], param(6, 5), param(7, 0));
            if(show(comp, "ax_diode"))      ax_diode(type = comp[4], value = comp[5], pitch = param(6, 0));
            if(show(comp, "rd_xtal"))       rd_xtal(type = comp[4], value = param(5, undef), z = param(6, 0), pitch = param(7, undef)); // type, value, z, forced pitch
            if(show(comp, "rd_electrolytic")) rd_electrolytic(type = comp[4], value = param(5, undef), z = param(6, 0), pitch = param(7, undef)); // type, value, z, forced pitch
            if(show(comp, "rd_disc"))       rd_disc(type = comp[4], value = param(5, undef), z = param(6, 0), pitch = param(7, inch(0.2))); // type, value, z, forced pitch
            if(show(comp, "rd_module"))     rd_module(type = comp[4], value = comp[5]);
            if(show(comp, "rd_transistor")) rd_transistor(type = comp[4], value = comp[5], lead_positions = param(6, undef), z = param(7, 5), kind = param(8,"Transistor"));
                                             // type, value, lead positions, z, kind
            if(show(comp, "rd_box_cap"))    rd_box_cap(type = comp[4], kind = comp[5], value = comp[6]);
            if(show(comp, "rd_cm_choke"))   rd_cm_choke(type = comp[4], value = comp[5]);
            if(show(comp, "rd_coil"))       rd_coil(type = comp[4], value = comp[5], pitch = param(6, undef));
            if(show(comp, "link"))          wire_link(l = comp[4], h = param(5, 1), d = param(6, 0.8), tail = param(7, 3), sleeve = param(8, false));
            if(show(comp, "D_plug"))        translate_z(d_pcb_offset(comp[4])) d_plug(comp[4], pcb = true);
            if(show(comp, "molex_hdr"))     molex_254(comp[4], param(5, 0), param(6, undef));
            if(show(comp, "jst_xh"))        jst_xh_header(jst_xh_header, comp[4], param(5, false), param(6, false), param(7, undef));
            if(show(comp, "jst_ph"))        jst_xh_header(jst_ph_header, comp[4], param(5, false), param(6, false), param(7, undef));
            if(show(comp, "jst_zh"))        jst_xh_header(jst_zh_header, comp[4], param(5, false), param(6, false), param(7, undef));
            if(show(comp, "potentiometer")) let(pot = param(4, BTT_encoder)) translate_z(pot_size(pot).z) vflip() potentiometer(pot, shaft_length = param(5, undef));
            if(show(comp, "trimpot3362"))   trimpot3362();
            if(show(comp, "buzzer"))        buzzer(param(4, 9), param(5, 12), param(6, grey(20)));
            if(show(comp, "smd_250V_fuse")) smd_250V_fuse(comp[4], comp[5]);
            if(show(comp, "smd_res"))       smd_resistor(comp[4], comp[5]);
            if(show(comp, "smd_cap"))       smd_capacitor(comp[4], comp[5], param(6, undef));
            if(show(comp, "smd_tant"))      smd_tant(comp[4], param(5, undef));
            if(show(comp, "smd_sot"))       smd_sot(comp[4], comp[5]);
            if(show(comp, "smd_soic"))      smd_soic(comp[4], comp[5]);
            if(show(comp, "smd_diode"))     smd_diode(comp[4], comp[5]);
            if(show(comp, "smd_inductor"))  smd_inductor(comp[4], comp[5]);
            if(show(comp, "smd_pot"))       smd_pot(comp[4], comp[5]);
            if(show(comp, "smd_coax"))      smd_coax(comp[4]);
            if(show(comp, "smd_qfp"))       smd_qfp(comp[4], comp[5]);
            if(show(comp, "vero_pin"))      vero_pin(param(4, false));
            if(show(comp, "terminal"))      terminal_block(comp[5], comp[4]);
            if(show(comp, "multiwatt11"))   multiwatt11(comp[4], param(5, 3));
            if(show(comp, "text"))          color(param(8, "white"))
                                                linear_extrude(0.04) resize([comp[4], comp[5]], auto = true) text(comp[6], font = param(7, "Liberation Mono"), valign = "center", halign = "center");
        }
    }
}

function pcb_component_position(type, name, index = 0) = //! Return x y position of specified component
    [for(comp = pcb_components(type), p = [pcb_coord(type, [comp.x, comp.y])]) if(comp[3] == name) [p.x, p.y]][index];

module pcb_component_position(type, name) { //! Position child at the specified component position
    for(comp = pcb_components(type)) {
        p = pcb_coord(type, [comp.x, comp.y]);
        if(comp[3][0] == "-") {
            if(comp[3] == str("-", name))
                translate([p.x, p.y])
                    vflip()
                        children();
        }
        else
            if(comp[3] == name)
                translate([p.x, p.y, pcb_thickness(type)])
                    children();
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

module pcb_grid_components(type, components, cutouts = false, angle = undef) //! Draw list of components on the PCB grid for perf board
    let($solder = pcb_solder(type))
        for(comp = components) {
            p = pcb_grid_pos(type, comp.x, comp.y);
            if(comp[3][0] == "-")
                translate([p.x, p.y])
                    vflip()
                        pcb_component(comp, cutouts, angle);
            else
                translate([p.x, p.y, pcb_thickness(type)])
                    pcb_component(comp, cutouts, angle);
        }


module pcb_cutouts(type, angle = undef)  //! Make cut outs to clear components on a PCB
    pcb_components(type, true, angle);

module pcb_grid_positions(type) {
    grid =  pcb_grid(type);
    for(i = [0 : 7 : len(grid) - 1]) {
        x0 = grid[i];
        y0 = grid[i + 1];

        cols = is_undef(grid[i + 2]) ? round((pcb_length(type) - 2 * x0) / inch(0.1)) : grid[i + 2] - 1;
        rows = is_undef(grid[i + 3]) ? round((pcb_width(type) - 2 * y0) / inch(0.1))  : grid[i + 3] - 1;
        for(x = [0 : cols], y = [0 : rows])
            pcb_grid(type, x, y, i = i)
                children();
    }
}

plating = 0.1;

function pcb_solder(type) = [1, 0, pcb_thickness(type) + plating];

module pcb(type) { //! Draw specified PCB
    grid = pcb_grid(type);
    t = pcb_thickness(type);
    w = pcb_width(type);
    l = pcb_length(type);

    $fs = fs; $fa = fa;

    module pcb_shape()
        if(Len(pcb_polygon(type)))
            polygon(pcb_polygon(type));
        else
            rounded_square([l, w], r = pcb_radius(type));

    if(pcb_name(type))
        vitamin(str("pcb(", type[0], "): ", pcb_name(type)));

    for(part = pcb_accessories(type))
        vitamin(part);

    color(pcb_colour(type))
        linear_extrude(t)
            difference() {
                pcb_shape();

                pcb_hole_positions(type)
                    offset(eps)
                        circle4n(d = pcb_hole_d(type));

                if(Len(grid))
                    pcb_grid_positions(type)
                        circle(d = 1 + eps);
            }

    land = pcb_land_d(type);
    land_r = Len(land) > 2 ? land[2] : 0;
    hole = pcb_hole_d(type);
    color(Len(land) > 3 ? land[3] : silver)
        translate_z(t / 2)
            linear_extrude(t + 2 * plating, center = true)
                difference() {
                    intersection() {
                        pcb_hole_positions(type)
                            if(is_list(land)) {
                                p = pcb_holes(type)[$i];  // If edge SMT pad then make it rectangular to overlap without gaps
                                edge = abs(p.x) < eps || abs(p.x - l) < eps || abs(p.y) < eps || abs(p.y - w) < eps;
                                rounded_square([land.x, land.y], edge ? 0 : land_r);
                            }
                            else
                                circle(d = max(land, 1));

                        offset(eps)
                            pcb_shape();   // Handle half holes on the edge of PCBs such as ESP8266
                    }

                    pcb_hole_positions(type)
                        circle4n(d = hole);
                }

    fr4 = pcb_colour(type) != "sienna";
    pcb_colour = pcb_colour(type);
    plating_colour = is_undef(grid[4]) ? ((pcb_colour == "green" || pcb_colour == "#2140BE") ? silver : pcb_colour == "sienna" ? copper : gold) : grid[4];
    color(plating_colour)
        translate_z(-plating)
            linear_extrude(fr4 ? t + 2 * plating : plating)
                if(Len(grid)) {
                    pcb_grid_positions(type)
                        difference() {
                            circle(d = 2);

                            circle(d = 1);
                        }
                    if(fr4 && len(grid) < 3 && pcb_holes(type)) { // oval lands at the ends
                        screw_x = pcb_coord(type, pcb_holes(type)[0]).x;
                        both_ends = len(pcb_holes(type)) > 2;
                        y0 = pcb_grid(type).y;
                        rows = round((pcb_width(type) - 2 * y0) / inch(0.1));
                        for(end = both_ends ? [-1, 1] : [1], y = [1 : rows - 1])
                            translate([end * screw_x, y0 + y * inch(0.1) - pcb_width(type) / 2])
                                hull()
                                    for(x = [-1, 1])
                                        translate([x * 1.6 / 2, 0])
                                            circle(d = 2);
                    }
                }

   let($solder = is_undef($solder) ? undef : pcb_solder(type)) // Handle PCB sub assembly on perfoard
        pcb_components(type);
}

module pcb_spacer(screw, height, wall = 1.8, taper = 0) { //! Generate STL for PCB spacer
    stl(str("pcb_spacer", round(screw_radius(screw) * 20), round(height * 10), taper ? str("_", taper) : ""));

    ir = screw_clearance_radius(screw);
    or = corrected_radius(ir) + wall;

    if(height > taper)
        linear_extrude(height - taper)
            poly_ring(or, ir);

    if(taper)
        linear_extrude(height)
            poly_ring(ir + 2 * extrusion_width, ir);
}

module pcb_base(type, height, thickness, wall = 2) { //! Generate STL for a base with PCB spacers
    screw = pcb_screw(type);
    ir = screw_clearance_radius(screw);
    or = corrected_radius(ir) + wall;

    union() {
        linear_extrude(thickness)
            difference() {
                hull()
                    pcb_screw_positions(type)
                        poly_ring(or, ir);

                pcb_screw_positions(type)
                    poly_circle(ir);
            }

        linear_extrude(height)
            pcb_screw_positions(type)
                poly_ring(or, ir);
    }
}

module pcb_assembly(type, height, thickness) { //! Draw PCB assembly with spaces and fasteners in place
    translate_z(height)
        pcb(type);

    screw = pcb_screw(type);
    if(!is_undef(screw)) {
        screw_length = screw_length(screw, height + thickness + pcb_thickness(type), 1, nyloc = true);

        taper = screw_smaller_than(pcb_hole_d(type)) > 2 * screw_radius(screw); // Arduino?
        pcb_screw_positions(type) {
            translate_z(height + pcb_thickness(type))
                screw(screw, screw_length);

            stl_colour(pp1_colour)
                if(taper)
                    pcb_spacer(screw, height, taper = 2);
                else
                    pcb_spacer(screw, height);

            translate_z(-thickness)
                vflip()
                    nut_and_washer(screw_nut(screw), true);
        }
    }
 }
