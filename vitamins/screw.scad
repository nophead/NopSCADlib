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
//! Machine screws and wood screws with various head styles.
//!
//! For an explanation of `screw_polysink()` see <https://hydraraptor.blogspot.com/2020/12/sinkholes.html>.
//
include <../utils/core/core.scad>

use <washer.scad>
use <nut.scad>
use <../utils/rounded_cylinder.scad>
use <../utils/thread.scad>
include <inserts.scad>

function screw_head_type(type)        = type[2];     //! Head style hs_cap, hs_pan, hs_cs, hs_hex, hs_grub, hs_cs_cap, hs_dome
function screw_radius(type)           = type[3] / 2; //! Nominal radius
function screw_head_radius(type)      = type[4] / 2; //! Head radius
function screw_head_height(type)      = type[5];     //! Head height
function screw_socket_depth(type)     = type[6];     //! Socket or slot depth
function screw_socket_af(type)        = type[7];     //! Socket across flats
function screw_max_thread(type)       = type[8];     //! Maximum thread length
function screw_washer(type)           = type[9];     //! Default washer
function screw_nut(type)              = type[10];    //! Default nut
function screw_pilot_hole(type)       = type[11];    //! Pilot hole radius for wood screws, tap radius for machine screws
function screw_clearance_radius(type) = type[12];    //! Clearance hole radius
function screw_thread_diameter(type)  = type[13];    //! Thread diameter, if different from nominal diameter
function screw_nut_radius(type) = screw_nut(type) ? nut_radius(screw_nut(type)) : 0; //! Radius of matching nut
function screw_boss_diameter(type) = max(washer_diameter(screw_washer(type)) + 1, 2 * (screw_nut_radius(type) + 3 * extrusion_width)); //! Boss big enough for nut trap and washer
function screw_head_depth(type, d = 0) =             //! How far a counter sink head will go into a straight hole diameter d
    screw_head_height(type)
        ? 0
        : let(r = screw_radius(type)) screw_head_radius(type) - max(r, d / 2) + r / 5;

function screw_thread_radius(type)  = //! Thread radius
    let(d = screw_thread_diameter(type)) is_undef(d) ? screw_radius(type) : d / 2;

function screw_angle(type, length, nut_distance) = //! How much to rotate the screw to align it with a nut at the specified `distance` from the head
    -360 * (length - nut_distance) /  metric_coarse_pitch(screw_thread_radius(type) * 2);

function screw_longer_than(x) = x <=  5 ?  5 : //! Returns the length of the shortest screw length longer or equal to x
                                x <=  6 ?  6 :
                                x <=  8 ?  8 :
                                x <= 10 ? 10 :
                                x <= 12 ? 12 :
                                x <= 16 ? 16 :
                                ceil(x / 5) * 5;

function screw_shorter_than(x) = x >= 20 ? floor(x / 5) * 5 : //! Returns the length of the longest screw shorter than or equal to x
                                 x >= 16 ? 16 :
                                 x >= 12 ? 12 :
                                 x >= 10 ? 10 :
                                 x >=  8 ?  8 :
                                 x >=  6 ?  6 :
                                 x >=  5 ?  5 :
                                 x >=  4 ?  4 :
                                 3;

function screw_length(screw, thickness, washers, insert = false, nyloc = false, nut = false, longer = false) = //! Returns the length of the longest or shortest screw that will got through `thickness` and `washers` and possibly an `insert`, `nut` or `nyloc`
    let(washer = washers ? washers * washer_thickness(screw_washer(screw)) : 0,
        insert = insert ? insert_length(is_list(insert) ? insert : screw_insert(screw)) : 0,
        nut = nut || nyloc ? nut_thickness(screw_nut(screw), nyloc)  : 0,
        total = thickness + washer + insert + nut
       )
        longer || nut || nyloc ? screw_longer_than(total) : screw_shorter_than(total);

function screw_smaller_than(d) = d >= 2.5 && d < 3 ? 2.5 : floor(d); // Largest diameter screw less than or equal to specified diameter

function screw_insert(screw, short = false, i = 0) =  //! Find insert to fit specified screw, defaults to longest but can specify the shortest
    let(d = screw_radius(screw) * 2, list = short ? short_inserts : inserts)
        i >= len(list) ? undef
                       : insert_screw_diameter(list[i]) == d ? list[i]
                                                             : screw_insert(screw, short, i + 1);

module screw(type, length, hob_point = 0, nylon = false) { //! Draw specified screw, optionally hobbed or nylon
    description = str("Screw ", nylon ? "Nylon " : "", type[1], length < 10 ? " x  " : " x ", length, "mm", hob_point ? str(", hobbed at ", hob_point) : "");
    vitamin(str("screw(", type[0], "_screw, ", length, arg(hob_point, 0, "hob_point"), arg(nylon, false, "nylon"), "): ", description));

    head_type   = screw_head_type(type);
    shaft_rad   = screw_radius(type) - eps;
    head_rad    = screw_head_radius(type);
    head_height = screw_head_height(type);
    socket_af   = screw_socket_af(type);
    socket_depth= screw_socket_depth(type);
    socket_rad  = socket_af / cos(30) / 2;
    max_thread  = screw_max_thread(type);
    has_shoulder = !is_undef(screw_thread_diameter(type));
    thread_rad = screw_thread_radius(type);
    thread = max_thread ? length >= max_thread + 5 ? max_thread
                                                   : length
                        : length;
    thread_offset = has_shoulder ? thread : 0;
    thread_d = 2 * thread_rad;
    pitch = metric_coarse_pitch(thread_d);
    colour = nylon || head_type == hs_grub ? grey(40) : grey(80);

    $fs = fs; $fa = fa;

    module shaft(socket = 0, headless = false) {
        point = screw_nut(type) ? 0 : 3 * shaft_rad;
        shank  = length - socket - (has_shoulder ? 0 : thread);

        if(show_threads && !point && pitch)
            translate_z(-length - thread_offset)
                male_metric_thread(thread_d, pitch, thread - (shank > 0 || headless ? 0 : socket), false, top = headless ? -1 : 0, solid = !headless, colour = colour);
        else
            color(colour * 0.9)
                rotate_extrude() {
                    translate([0, -length + point - thread_offset])
                        square([thread_rad - eps, length - socket - point]);

                    if(point)
                        polygon([
                            [0.4, -length], [0, point - length], [shaft_rad, point - length]
                        ]);
                }

        if(shank > 0)
            color(colour)
                translate_z(-shank - socket)
                    cylinder(r = shaft_rad + eps, h = shank);
    }

    module cs_head(socket_rad, socket_depth) {
        head_t = shaft_rad / 5;
        head_height = head_rad + head_t;

        color(colour) {
            rotate_extrude()
                difference() {
                    polygon([[0, 0], [head_rad, 0], [head_rad, -head_t], [0, -head_height]]);

                    translate([0, -socket_depth + eps])
                        square([socket_rad, 10]);
                }

            translate_z(-socket_depth)
                linear_extrude(socket_depth)
                    difference() {
                        circle(socket_rad + 0.1);

                        children();
                    }
        }
        color(colour * 0.9)
            translate_z(-socket_depth)
                cylinder(h=2 * eps, r=socket_rad, $fn = 6);
    }

    explode(length + 10) {
        if(head_type == hs_cap) {
            color(colour) {
                cylinder(r = head_rad, h = head_height - socket_depth);

                translate_z(head_height - socket_depth)
                    linear_extrude(socket_depth)
                        difference() {
                            circle(head_rad);

                            circle(socket_rad, $fn = 6);
                        }

            }
            color(colour * 0.9)
                translate_z(head_height - socket_depth)
                    cylinder(h=2 * eps, r=socket_rad, $fn = 6);
            shaft();
        }
        if(head_type == hs_grub) {
            color(colour) {
                r = show_threads ? shaft_rad - pitch / 2 : shaft_rad;
                translate_z(-socket_depth)
                    linear_extrude(socket_depth)
                        difference() {
                            circle(r);

                            circle(socket_rad, $fn = 6);
                        }

                shaft(socket_depth, true);

                if(show_threads)
                    translate_z(-length)
                        cylinder(r = r, h = length - socket_depth);
            }
            color(colour * 0.8)
                translate_z(head_height - socket_depth)
                    cylinder(h=2 * eps, r=socket_rad, $fn = 6);
        }
        if(head_type == hs_hex) {
            draw_nut(head_rad * 2, 0, head_height, 0, colour, false);

            shaft();
        }
        if(head_type == hs_pan) {
            socket_rad = 0.6 * head_rad;
            socket_depth = 0.5 * head_height;
            socket_width = 1;
            color(colour) {
                rotate_extrude()
                    difference() {
                        rounded_corner(r = head_rad, h = head_height, r2 = head_height / 2);

                        translate([0, head_height - socket_depth])
                            square([socket_rad, 10]);
                    }

                linear_extrude(head_height)
                    difference() {
                        circle(socket_rad + eps);

                        square([2 * socket_rad, socket_width], center = true);
                        square([socket_width, 2 * socket_rad], center = true);
                    }
            }
            color(colour * 0.9)
                translate_z(head_height - socket_depth)
                    cylinder(h=2 * eps, r=socket_rad + eps);
            shaft();
        }
        if(head_type == hs_dome) {
            edge_height = head_rad / 7.5;
            head_chamfer_angle= 15; // degrees
            head_chamfer_x=edge_height*tan(head_chamfer_angle);
            head_fillet_radius= 0.3;
            p0 = [head_rad, edge_height];                   // Lowest point on the arc
            p1 = [1.3 * socket_rad / cos(30), head_height]; // Highest point on the arc
            p = (p0 + p1) / 2;                              // Start of bisector
            gradient = (p0.x - p1.x) / (p1.y - p0.y);       // Gradient of perpendicular bisector = -1 / gradient of the line between p10 and p1
            c = p.y - gradient * p.x;                       // Y ordinate of the centre of the dome
            r = norm(p1 - [0, c]);                          // Dome radius is distance from centre
            color(colour) {
                rotate_extrude() {
                    difference() {
                        intersection() {
                            translate([0, c])
                                circle(r);

                            // offset(head_fillet_radius) offset(-head_fillet_radius)
                            polygon(points = [
                                [0,0],
                                [head_rad-head_chamfer_x,0],
                                [head_rad, edge_height],
                                [head_rad,head_height],
                                [0,head_height],
                                ]);
                        }
                        translate([0, head_height - socket_depth])
                            square([socket_rad, 10]);
                    }
                }
                linear_extrude(head_height)
                    difference() {
                        circle(socket_rad + eps);
                        circle(socket_rad, $fn = 6);
                    }
            }
            color(colour * 0.9)
                translate_z(head_height - socket_depth)
                    cylinder(h=2 * eps, r=socket_rad, $fn = 6);
            shaft();
        }

        if(head_type == hs_cs) {
            socket_rad = 0.6 * head_rad;
            socket_depth = 0.3 * head_rad;
            socket_width = 1;
            cs_head(socket_rad, socket_depth) {
                square([2 * socket_rad, socket_width], center = true);
                square([socket_width, 2 * socket_rad], center = true);
            }

            shaft(socket_depth);
        }

        if(head_type == hs_cs_cap) {
            cs_head(socket_rad, socket_depth)
                circle(socket_rad, $fn = 6);

            shaft(socket_depth);
        }
    }
}

module screw_countersink(type, drilled = true) { //! Countersink shape
    head_type   = screw_head_type(type);
    head_rad    = screw_head_radius(type);
    rad = screw_radius(type);
    head_t = rad / 5;
    head_height = head_rad + head_t;

    if(head_type == hs_cs || head_type == hs_cs_cap)
        translate_z(-head_height)
            if(drilled)
                cylinder(h = head_height + eps, r1 = 0, r2 = head_rad + head_t);
            else
                render() intersection() {
                    cylinder(h = head_height + eps, r1 = 0, r2 = head_rad + head_t);

                    cylinder(h = head_height + eps, r = head_rad + eps);
                }
}

module screw_tearsink(type) { //! Countersink shape for horizontal holes
    head_type   = screw_head_type(type);
    head_rad    = screw_head_radius(type);
    rad = screw_radius(type);
    head_t = rad / 5;
    head_height = head_rad - rad + head_t;

    if(head_type == hs_cs || head_type == hs_cs_cap)
        translate_z(-head_height)
            hull() {
                teardrop_plus(h = eps, r = rad, center = false);

                translate_z(head_height - head_t)
                    teardrop_plus(h = head_t + eps, r = head_rad, center = false);
            }
}

function screw_polysink_r(type, z) = //! Countersink hole profile corrected for rounded staircase extrusions.
    let(rad = screw_radius(type),
        head_t = rad / 5,
        head_rad = screw_head_radius(type)
    )
    limit(head_rad + head_t - z + (sqrt(2) - 1) * layer_height / 2, screw_clearance_radius(type), head_rad);

module screw_polysink(type, h = 100, alt = false, sink = 0) { //! A countersink hole made from stacked polyholes for printed parts, default is flush, `sink` can be used to recess the head
    head_depth = screw_head_depth(type);
    assert(head_depth, "Not a countersunk screw");
    layers = ceil((head_depth + sink) / layer_height);
    rmin = screw_clearance_radius(type);
    sides = sides(rmin);
    lh = layer_height + eps;
    render(convexity = 5)
        for(side = [0, 1]) mirror([0, 0, side]) {
            for(i = [0 : layers - 1])
                translate_z(i * layer_height) {
                    r = screw_polysink_r(type, i * layer_height + layer_height / 2 - sink);
                    if(alt)
                        rotate(i % 2 == layers % 2 ? 180 / sides : 0)
                            poly_cylinder(r = r, h = lh, center = false, sides = sides);
                    else
                        poly_cylinder(r = r, h = lh, center = false);
                }

            remainder = h / 2 - layers * layer_height;
            if(remainder > 0)
                translate_z(layers * layer_height)
                    poly_cylinder(r = rmin, h = remainder, center = false);
        }
}

module screw_keyhole(type, h = 0) { //! Make keyhole slot to accept and retain screw head
    r = screw_head_radius(type);
    extrude_if(h) {
        translate([0, - 2 * r])
            drill(r + 0.5, 0);

        hull()
            for(y = [0, -2 * r])
                translate([0, y])
                    drill(screw_clearance_radius(type), 0);
    }
}

module screw_and_washer(type, length, star = false, penny = false) { //! Screw with a washer which can be standard or penny and an optional star washer on top
    washer = screw_washer(type);
    head_type = screw_head_type(type);

    if(head_type != hs_cs && head_type != hs_cs_cap) {
        translate_z(exploded() * 6)
            if(penny)
                penny_washer(washer);
            else
                washer(washer);

        translate_z(washer_thickness(washer)) {
            if(star) {
                translate_z(exploded() * 8)
                    star_washer(washer);

                translate_z(washer_thickness(washer))
                    screw(type, length);
            }
            else
                screw(type, length);
        }
    }
    else
        translate_z(eps)
            screw(type, length);
}
