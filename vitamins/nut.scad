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
//!
//! The following diagram shows you the parameters for drawing a sliding_t_nut:
//!
//! ![](docs/sliding_t_nut.png)
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
function nut_dome(type)       = type[8];        //! Dome height and max thread depth if a domed acorn nut

function nut_flat_radius(type) = nut_radius(type) * cos(30); //! Radius across the flats

function nut_square_size(type)      = type[1];  //! Diameter of the corresponding screw
function nut_square_width(type)     = type[2];  //! Width of the square nut
function nut_square_thickness(type) = type[3];  //! Thickness of the square nut

function nut_weld_base_r(type) = type[7] / 2;   //! Weld nut base radius
function nut_weld_base_t(type) = type[8];       //! Weld nut base thickness

function nut_dome_height(type)  = let(d = nut_dome(type)) d ? d[0] : nut_thickness(type); //! Height of the domed version
function nut_thread_depth(type) = let(d = nut_dome(type)) d ? d[1] : nut_thickness(type); //! Max thread depth in domed version

module draw_nut(od, id, t, pitch, colour, show_thread, thread_h = undef ) {
    th = is_undef(thread_h) ? t : thread_h;

    color(colour) {
        or = od / 2;
        fr = or * cos(30);

        render_if(manifold) intersection() {
            linear_extrude(t, convexity = 5)
                difference() {
                    circle(or, $fn = 6);

                    if(id)
                        circle(d = id);
                }

            if(manifold)
                rotate_extrude()
                    hull() {
                        h = (or - fr) * tan(30);

                        translate([0, -eps])
                            square([fr, t + eps]);

                        translate([or, h])
                            square([eps, t - 2 * h]);
                    }
        }
    }
    if(show_thread && id)
        female_metric_thread(id, pitch,
            th,
            top = th > t ? 0 : manifold ? 1 : -1,
            bot = manifold ? 1 : -1,
            center = false, colour = colour);
}

module nut(type, nyloc = false, brass = false, nylon = false, dome = false) { //! Draw specified nut
    thread_d = nut_size(type);
    thread_p = nut_pitch(type) ? nut_pitch(type) : metric_coarse_pitch(thread_d);
    hole_rad  = thread_d / 2;
    outer_rad = nut_radius(type);
    thickness = nut_thickness(type);
    nyloc_thickness = nut_thickness(type, true);
    desc = nyloc ? "nyloc" : brass ? "brass" : nylon ? "nylon" : dome ? "domed" : "";
    vitamin(str("nut(", type[0],
                        arg(nyloc, false, "nyloc"),
                        arg(brass, false, "brass"),
                        arg(nylon, false, "nylon"),
                        arg(dome,  false, "dome"),
                   "): Nut M", nut_size(type), " x ", thickness, "mm ", desc));

    $fs = fs; $fa = fa;

    colour = brass ? brass_colour : nylon ? grey(30): grey(70);
    explode(nyloc ? 10 : 0) {
        draw_nut(outer_rad * 2, thread_d, thickness, thread_p, colour, show_threads, dome ? nut_thread_depth(type) : thickness);

        fr = nut_flat_radius(type);
        color(colour) {
            if(nyloc)
                translate_z(eps)
                    rounded_cylinder(r = outer_rad * cos(30), h = nyloc_thickness - eps, r2 = (nyloc_thickness - thickness) / 2, ir = hole_rad);

            if(dome)
                translate_z(thickness)
                    rotate_extrude()
                        difference() {
                            h = nut_dome_height(type) - thickness;
                            r = fr - eps;
                            rounded_corner(r, h, r);

                            square([thread_d / 2, nut_thread_depth(type) - thickness]);
                        }
        }

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
                    [top_rad, thickness],
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

function t_nut_tab(type) = [type[8], type[9]]; //! Sliding t-nut T dimensions

module sliding_ball_t_nut(size, w, h, r) { //! Draw a sliding ball t nut
    rad = 0.5;
    stem = size.z - h;
    ball_d = 4;
    offset = 12;

    module shape()
        rotate([90, 0, 90])
            translate_z(-offset)
                linear_extrude(size.x) {
                    hull() {
                        translate([0, h - size.y / 2])
                            semi_circle(d = size.y);

                        for(side = [-1, 1])
                            translate([side * (w / 2 - rad), rad])
                                circle(rad);
                    }
                    rounded_square([size.y, stem * 2], rad / 2, true);
                }

    render() difference() {
        shape();

        cylinder(r = r, h = 100, center = true);
    }

    translate([-offset + ball_d, 0, h - 0.4])
        sphere(d = ball_d);

    if(show_threads)
        render() intersection() {
            translate_z(-stem)
                female_metric_thread(2 * r, metric_coarse_pitch(2 * r), size.z - 2, center = false);

            shape();
        }
}

module sliding_t_nut(type) { //! Draw a sliding T nut, T nut with a spring loaded ball or a hammer nut.
    hammerNut = type[10];
    size = [type[7], nut_square_width(type), nut_thickness(type, true)];
    tab = t_nut_tab(type);
    tabSizeZ = nut_thickness(type);
    holeRadius  = nut_size(type) / 2;

    vitamin(str("sliding_t_nut(", type[0], "): Nut M", nut_size(type), hammerNut ? " hammer" : " sliding T", !tab[1] ? " with spring loaded ball" : ""));

    color(grey(80))
        if(!tab[1])
            sliding_ball_t_nut(size, tab[0], tabSizeZ, holeRadius);
        else
            extrusionSlidingNut(size, tab[0], tab[1], tabSizeZ, holeRadius, 0, hammerNut);
}

module weld_nut(type) { //! draw a weld nut
    thread_d = nut_size(type);
    hole_rad  = thread_d / 2;
    nut_neck_rad = nut_radius(type);
    thickness = nut_thickness(type);
    base_rad = nut_weld_base_r(type);
    base_thickness = nut_weld_base_t(type);


    vitamin(str("weld nut(", type[0], "): Weld Nut M", nut_size(type)));
    colour = silver;
    explode(-20) {
        color(colour) {

            rotate_extrude()
                polygon([
                    [hole_rad, -base_thickness],
                    [base_rad, -base_thickness],
                    [base_rad, 0],
                    [hole_rad, 0],
                    [nut_neck_rad, 0],
                    [nut_neck_rad, thickness],
                    [hole_rad, thickness]
                ]);
        }

        if(show_threads)
            female_metric_thread(thread_d, metric_coarse_pitch(thread_d), thickness, center = false, colour = colour);
    }

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
            square([size.x, tabSizeY1 == tabSizeY2 ? size.y : tabSizeY2], center = true);
            if(holeRadius)
                translate([holeOffset, 0])
                    circle(holeRadius);
        }

    thread_d = 2 * holeRadius;
    if(show_threads)
        translate([holeOffset, 0, -stem_h])
            female_metric_thread(thread_d, metric_coarse_pitch(thread_d), size.z, center = false);

    // add the side tabs
    tab_h = size.z - 2 * stem_h;
    chamfer =tab_h / 4;
    for(m = [0, 1])
        mirror([0, m, 0])
            if(tabSizeY1 == tabSizeY2)
                translate([-size.x / 2, size.y / 2])
                    hull() {
                        cube([size.x, (tabSizeY1 - size.y) / 2 - chamfer, tab_h]);

                        translate_z(chamfer)
                            cube([size.x, (tabSizeY1 - size.y) / 2,tab_h - 2 * chamfer]);
                    }

            else {
                dy = (tabSizeY1 - tabSizeY2) / 2;
                cubeZ = tabSizeZ - dy;
                translate([-size.x / 2, tabSizeY2 / 2])
                    cube([size.x, (tabSizeY1 - tabSizeY2) / 2, cubeZ]);

                translate([0, tabSizeY2 / 2, cubeZ])
                    rotate([0, -90, 0])
                        right_triangle(tabSizeZ - cubeZ, dy, size.x, center = true);
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
