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
//! Default is steel but can be drawn as brass or nylon. A utility for making nut traps included.
//!
//! If a nut is given a child then it gets placed on its top surface.
//
include <../utils/core/core.scad>
use <washer.scad>
use <screw.scad>
use <../utils/fillet.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/thread.scad>
use <../utils/tube.scad>
brass_colour = brass;

function nut_size(type)       = type[1];        //! Diameter of the corresponding screw
function nut_radius(type)     = type[2] / 2;    //! Radius across the corners
function nut_thickness(type, nyloc = false) = nyloc ? type[4] : type[3]; //! Thickness of plain or nyloc version
function nut_washer(type)     = type[5];        //! Corresponding washer
function nut_trap_depth(type) = type[6];        //! Depth of nut trap
function nut_pitch(type)      = type[7];        //! Pitch if not standard metric course thread

function nut_flat_radius(type) = nut_radius(type) * cos(30); //! Radius across the flats

function nut_square_size(type)      = type[1]; //! Diameter of the corresponding screw
function nut_square_width(type)     = type[2]; //! Width of the square nut
function nut_square_thickness(type) = type[3]; //! Thickness of the square nut

module nut(type, nyloc = false, brass = false, nylon = false) { //! Draw specified nut
    thread_d = nut_size(type);
    thread_p = nut_pitch(type) ? nut_pitch(type) : metric_coarse_pitch(thread_d);
    hole_rad  = thread_d / 2;
    outer_rad = nut_radius(type);
    thickness = nut_thickness(type);
    nyloc_thickness = nut_thickness(type, true);
    desc = nyloc ? "nyloc" : brass ? "brass" : nylon ? "nylon" : "";
    vitamin(str("nut(", type[0], arg(nyloc, false, "nyloc"), arg(brass, false, "brass"), arg(nylon, false, "nylon"),
                   "): Nut M", nut_size(type), " x ", thickness, "mm ", desc));

    colour = brass ? brass_colour : nylon ? grey(30): grey(70);
    explode(nyloc ? 10 : 0) {
        color(colour) {
            linear_extrude(thickness)
                difference() {
                    circle(outer_rad, $fn = 6);

                    circle(hole_rad);
                }

            if(nyloc)
                translate_z(-eps)
                    rounded_cylinder(r = outer_rad * cos(30) , h = nyloc_thickness, r2 = (nyloc_thickness - thickness) / 2, ir = hole_rad);
        }

        if(show_threads)
            female_metric_thread(thread_d, thread_p, thickness, center = false, colour = colour);

        if(nyloc)
            translate_z(thickness)
                color("royalblue")
                    tube(or = thread_d / 2 + eps, ir = (thread_d * 0.8) / 2, h = (nyloc_thickness - thickness) * 0.8, center = false);
    }
    if($children)
        translate_z(nut_thickness(type, nyloc))
            children();
}

module nut_and_washer(type, nyloc) { //! Draw nut with corresponding washer
    washer = nut_washer(type);

    translate_z(exploded() ? 7 : 0)
        washer(washer);

    translate_z(washer_thickness(washer))
        nut(type, nyloc);
}

module wingnut(type) { //! Draw a wingnut
    thread_d = nut_size(type);
    hole_rad  = thread_d / 2;
    bottom_rad = nut_radius(type);
    top_rad = type[4] / 2;
    thickness = nut_thickness(type);
    wing_span = type[7];
    wing_height = type[8];
    wing_width = type[9];
    wing_thickness = type[10];

    top_angle = asin((wing_thickness / 2) / top_rad);
    bottom_angle = asin((wing_thickness / 2) / bottom_rad);

    vitamin(str("wingnut(", type[0], "): Wingnut M", nut_size(type)));

    colour = silver;
    explode(10) {
        color(colour) {
            rotate_extrude()
                polygon([
                    [hole_rad, 0],
                    [bottom_rad, 0],
                    [top_rad,, thickness],
                    [hole_rad, thickness]
                ]);
            for(rot = [0, 180])
                rotate([90, 0, rot]) linear_extrude(wing_thickness, center = true)
                    hull() {
                        translate([wing_span / 2  - wing_width / 2, wing_height - wing_width / 2])
                            circle(wing_width / 2);
                        polygon([
                            [bottom_rad * cos(top_angle) - eps, 0],
                            [wing_span / 2  - wing_width / 2, wing_height - wing_width / 2],
                            [top_rad * cos(top_angle) - eps, thickness],
                        ]);
                    }
        }

        if(show_threads)
            female_metric_thread(thread_d, metric_coarse_pitch(thread_d), thickness, center = false, colour = colour);
    }
}

module sliding_t_nut(type) {
    hammerNut = type[10];
    vitamin(str("sliding_t_nut(", type[0], "): Nut M", nut_size(type), hammerNut ? " hammer" : " sliding T"));

    size = [type[7], type[2], nut_thickness(type, true)];
    tabSizeY1 = type[8];
    tabSizeY2 = type[9];
    tabSizeZ = nut_thickness(type);
    holeRadius  = nut_size(type) / 2;

    color(grey(80))
        extrusionSlidingNut(size, tabSizeY1, tabSizeY2, tabSizeZ, holeRadius, 0, hammerNut);
}

module extrusionSlidingNut(size, tabSizeY1, tabSizeY2, tabSizeZ, holeRadius, holeOffset = 0, hammerNut = false) {
    // center section
    stem_h = size.z - tabSizeZ;
    translate_z(-stem_h)
        linear_extrude(stem_h)
            difference() {
                square([size.x, size.y], center = true);
                if(hammerNut) {
                    translate([size.x / 2, size.y / 2])
                        rotate(180)
                            fillet(1);
                    translate([-size.x / 2, -size.y / 2])
                        fillet(1);
                }
                if(holeRadius)
                    translate([holeOffset, 0])
                        circle(holeRadius);
            }
    linear_extrude(tabSizeZ)
        difference() {
            square([size.x, tabSizeY2], center = true);
            if(holeRadius)
                translate([holeOffset, 0])
                    circle(holeRadius);
        }

    thread_d = 2 * holeRadius;
    if(show_threads)
        translate([holeOffset, 0, -stem_h])
            female_metric_thread(thread_d, metric_coarse_pitch(thread_d), size.z, center = false);

    // add the side tabs
    for(m = [0, 1])
        mirror([0, m, 0])
            translate([0, tabSizeY2 / 2]) {
                cubeZ = 1;
                translate([-size.x / 2, 0])
                    cube([size.x, (tabSizeY1 - tabSizeY2) / 2, cubeZ]);
                translate_z(cubeZ)
                    rotate([0, -90, 0])
                        right_triangle(tabSizeZ - cubeZ, (tabSizeY1 - tabSizeY2) / 2, size.x, center = true);
            }
}

module nut_square(type, brass = false, nylon = false) { //! Draw specified square nut
    thread_d = nut_size(type);
    hole_rad  = thread_d / 2;
    width = nut_square_width(type);
    thickness = nut_square_thickness(type);
    desc = brass ? "brass" : nylon ? "nylon" : "";
    vitamin(str("nut(", type[0], arg(brass, false, "brass"), arg(nylon, false, "nylon"),
                   "): Nut M", nut_size(type), "nS ", width, " x ", thickness, "mm ", desc));

    colour = brass ? brass_colour : nylon ? grey(30) : grey(70);
    color(colour)
        difference() {
            linear_extrude(thickness) {
                difference() {
                    square([width, width], center = true);

                    circle(hole_rad);
                }
            }

        }
    if(show_threads)
        female_metric_thread(thread_d, metric_coarse_pitch(thread_d), thickness, center = false, colour = colour);
}

function nut_trap_radius(nut, horizontal = false) = nut_radius(nut) + (horizontal ? layer_height / 4 : 0); //! Radius across the corners of a nut trap
function nut_trap_flat_radius(nut, horizontal = false) = nut_trap_radius(nut, horizontal) * cos(30);       //! Radius across the flats of a nut trap

module nut_trap(screw, nut, depth = 0, horizontal = false, supported = false, h = 200) { //! Make a nut trap
    nut_r = is_list(nut) ? nut_trap_radius(nut, horizontal) : nut + (horizontal ? layer_height / 4 : 0);
    nut_d = depth ? depth : nut_trap_depth(nut);
    screw_r = is_list(screw) ? screw_clearance_radius(screw) : screw;
    render(convexity = 5) union() {
        if(horizontal) {
            if(screw_r)
                teardrop_plus(r = screw_r, h = h);

            cylinder(r = nut_r, h = nut_d * 2, center = true, $fn = 6);
        }
        else {
            difference() {
                union() {
                    if(screw_r)
                        poly_cylinder(r = screw_r, h = h, center = true);

                    cylinder(r = nut_r, h = nut_d * 2, center = true, $fn = 6);
                }
                if(supported)
                    translate_z(nut_d - eps)
                        cylinder(r = nut_r + eps, h = layer_height, center = false);
            }
        }
    }
}
