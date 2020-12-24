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
//! LED strip lights that can be cut to size.
//!
//! The definitions are for the full length but they can be cut to size by specifying how many segments,
//! which can by calcuated using `light_strip_segments(type, max_length)`.
//!
//! The `light_strip_clip()` module makes a clip to go around the light that can be incorporated into a printed bracket to hold it.
//
include <../utils/core/core.scad>

function light_strip_length(type)        = type[2]; //! Un-cut length
function light_strip_leds(type)          = type[3]; //! Total number of LEDs
function light_strip_grouped(type)       = type[4]; //! Number of LEDs in each group
function light_strip_width(type)         = type[5]; //! Outside width
function light_strip_depth(type)         = type[6]; //! Outside depth
function light_strip_aperture(type)      = type[7]; //! Inside width
function light_strip_thickness(type)     = type[8]; //! Metal thickness
function light_strip_pcb_thickness(type) = type[9]; //! PCB thickness

function light_strip_segments(type, max_length) = let( //! Calculate the maximum number of segments that fit in max_length
        length = light_strip_length(type),
        seg_length = length * light_strip_grouped(type) / light_strip_leds(type),
        segs = floor(min(max_length, length) / seg_length)
    )
    assert(segs, str("max_length must be at least ", ceil(seg_length), "mm"))
    segs;

function light_strip_cut_length(type, segs) = ceil(light_strip_length(type) * segs * light_strip_grouped(type) / light_strip_leds(type)); //! Calculate cut length given segments

module light_strip(type, segs = undef) { //! Draw specified light strip, segs can be used to limit the length
    segment_length =  light_strip_length(type) / (light_strip_leds(type) / light_strip_grouped(type));
    segments = is_undef(segs) ? leds / light_strip_grouped(type) : segs;
    l = light_strip_cut_length(type, segs);
    vitamin(str("light_strip(", type[0], arg(segs, undef), "): Light strip ", type[1], " x ", l, "mm (", segments, " segments)"));
    leds = light_strip_grouped(type) * segments;
    w = light_strip_width(type);
    d = light_strip_depth(type);
    t = light_strip_thickness(type);
    a = light_strip_aperture(type);
    s = (w - a) / 2 - t;
    p = light_strip_pcb_thickness(type);
    x1 = w / 2;
    x2 = x1 - t;
    x3 = a / 2;
    y1 = t;
    y5 = d - s;
    y4 = y5 - t;
    y3 = y4 - p;
    y2 = y3 - t;

    module led_positions()
        for(i = [0 : leds - 1])
            translate([l * (i + 0.5) / leds - l / 2, 0])
                children();

    module segment_positions(n = segments)
        for(i = [0 : 1 : n - 1])
            translate([l * i / segments - l / 2, 0])
                children();

    module resistor_positions()
        segment_positions()
            for(end = [-1, 1], side = end > 0 ? [-1, 1] : [0])
                translate([end * l / leds / 2 + segment_length / 2, side * 2])
                    children();

    color("silver")
        rotate([90, 0, 90])
            linear_extrude(l, center = true)
                polygon([
                    [ x1,  0], [ x1,  d], [ x2,  d], [ x3, y5], [ x3, y4], [ x2, y4],
                    [ x2, y3], [ x3, y3], [ x3, y2], [ x2, y2], [ x2, y1],
                    [-x2, y1], [-x2, y2], [-x3, y2], [-x3, y3], [-x2, y3], [-x2, y4],
                    [-x3, y4], [-x3, y5], [-x2,  d], [-x1,  d], [-x1,  0],
                ]);

    color("ghostwhite")
        translate_z(y3 + p / 2)
            cube([l, w - 2 * t, p], center = true);

    translate_z(y4) {
        color("white")
            linear_extrude(1.6)
                led_positions()
                    square([5, 5], center = true);

        color("yellow")
            linear_extrude(1.6 + eps)
                led_positions()
                    circle(d = 3.5);

        color("silver")
            linear_extrude(0.8)
                led_positions()
                    for(side = [-1,1], end = [-1:1])
                        translate([side * 2.2, end * 1.6])
                            square([1, 0.9], center = true);

        color("black")
            linear_extrude(0.1)
                segment_positions(segments - 1)
                    translate([segment_length, 0])
                        square([0.2, a], center = true);

        color("silver")
            linear_extrude(0.15)
                segment_positions()
                    for(end = [-1, 1], side = [-1, 1])
                        translate([end * (segment_length / 2 - 1.25) + segment_length / 2, side * 2.5])
                            square(2.5, center = true);

        color("silver")
            linear_extrude(0.55)
                resistor_positions()
                    square([3.2, 1.5], center = true);

        color("black")
            linear_extrude(0.55 + eps)
                resistor_positions()
                    square([2.1, 1.5 + 2 * eps], center = true);
    }

    if(show_rays)
        %cylinder(r = 1, h = 150);
}

wall = 1.8;
clearance = 0.2;
function light_strip_clip_slot(light) = light_strip_width(light) + clearance;       //! Clip slot size
function light_strip_clip_depth(light) = 10;                                        //! Depth of the clip
function light_strip_clip_length(light) = light_strip_clip_slot(light) + 2 * wall;  //! Outside length of clip
function light_strip_clip_width(light) = light_strip_depth(light) + 2 * wall;       //! Outside width of clip
function light_strip_clip_wall() = wall;                                            //! Clip wall thickness

module light_strip_clip(light) { //! Make a clip to go over the strip to be incorporated into a bracket
    linear_extrude(light_strip_clip_depth(light), convexity = 2)
        difference() {
            translate([-light_strip_clip_length(light) / 2, -wall])
                square([light_strip_clip_length(light), light_strip_clip_width(light)]);

            translate([-light_strip_clip_slot(light) / 2, 0])
                square([light_strip_clip_slot(light), light_strip_clip_width(light) - 2 * wall]);

            translate([-light_strip_aperture(light) / 2, 0])
                square([light_strip_aperture(light), 100]);
        }
}
