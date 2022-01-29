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
//! A strip of polypropylene used with ribbon cable to make a cable flexible in one direction only.
//!
//! Modelled with a Bezier spline, which is not quite the same as a minimum energy curve but very close, especially
//! near the extreme positions, where the model needs to be accurate.
//!
//! When the sides are constrained then a circular model is more accurate.
//
include <../utils/core/core.scad>
cable_strip_thickness = 0.8;
function ribbon_ways(ways) = is_list(ways) ? ways : [ways, 1]; //! Allows ribbon clamps to accept multiple cables
function ribbon_clamp_slot(ways) = let(w = ribbon_ways(ways)) w[0] * inch(0.05) + 1; //! Width of the slot to accept a ribbon cable
function ribbon_clamp_slot_depth() = cable_strip_thickness + inch(0.05); //! Depth of slot to accept a ribbon cable and a cable strip
function cable_strip_thickness() = cable_strip_thickness;

use <../utils/bezier.scad>
use <../utils/sweep.scad>

cable_strip_colour = "green";

function cable_strip_control_points(depth, min_z, pos) = let(z = min(min_z, min_z + pos))
[
    [0, 0, 0], [0, 0, z], [0, depth, z], [0, depth, pos]
];

function bezier_cable_length(depth, min_z, pos) = //! Calculate a length that will achieve the desired minimum z
    bezier_length(adjust_bezier_z(cable_strip_control_points(depth, min_z, pos), min_z));

module bezier_cable_strip(ways, depth, length, below, extra, pos = 0) { //! Draw a cable strip using a Bezier curve
    width = ceil(ribbon_clamp_slot(ways) - 1);

    thickness = cable_strip_thickness;

    total = 2 * extra + length;

    vitamin(str("bezier_cable_strip(", ways, ", ", depth, ", ", length, ", ", below, ", ", extra,
                                   "): Polypropylene strip ", total, "mm x ", width, "mm x ", thickness, "mm"));

    c = cable_strip_control_points(depth, -below + extra, pos);
    v = adjust_bezier_length(c, length);

    steps = 100;
    extra_v = [0, 0, extra];

    path = [v[0] + extra_v, each bezier_path(v, steps), v[3] + extra_v];

    color(cable_strip_colour)
        translate_z(-extra)
            sweep(path, rectangle_points(width, thickness));
    *echo(cable_strip_lengh = length);
    *translate_z(-extra) sweep(v, circle_points(1));
}

function cable_strip_length(depth, travel, extra = 15) = ceil(travel / 2 + 2 * extra + PI * depth); //! Calculate circular cable strip length

module cable_strip(ways, depth, travel, extra = 15, pos = 0) {  //! Draw a cable stripe with a semi circular fold

    width = ribbon_clamp_slot(ways);

    thickness = cable_strip_thickness;

    radius = depth / 2;

    top = travel / 4 + extra + pos / 2;
    bottom = travel / 4 + extra - pos /2;

    length = max(top, bottom);

    total = ceil(top + bottom + PI * depth);
    w = floor(width - 2);

    vitamin(str("cable_strip(", ways, ", ", depth, ", ", travel, arg(extra, 15), "): Polypropylene strip ", total, "mm x ", w, "mm x ", thickness, "mm"));

    color(cable_strip_colour) linear_extrude(w, center = true, convexity = 4)
        difference() {
            union() {
                translate([-bottom, radius])
                    circle(radius);

                translate([-bottom, 0])
                    square([length, depth]);
            }
            union() {
                translate([-bottom, radius])
                    circle(radius - thickness);

                translate([-bottom, thickness])
                    square([length + 1, depth - thickness * 2]);
            }
            translate([0, -thickness / 2])
                square([travel, thickness * 2]);

            translate([pos, depth - thickness - thickness / 2])
                square([travel, thickness * 2]);
        }
}

function elliptical_cable_strip_length(p1, pmax, extra = 15) =  ceil(PI * pow((pow(abs((pmax - p1)[0] / 2),1.5) + pow(75,1.5))/2, 1/1.5)) + 2 * extra;

module elliptical_cable_strip(ways, p1, p2, pmax, extra = 15) {
    width = ribbon_clamp_slot(ways);

    thickness = cable_strip_thickness;
    w = floor(width - 1);

    max_delta = pmax - p1;
    delta = p2 - p1;

    A = abs(max_delta[0] / 2);
    B = 75;

    length = ceil(PI * pow((pow(A,1.5) + pow(B,1.5))/2, 1/1.5));
    total = length + 2 * extra;

    vitamin(str("elliptical_cable_strip(", ways, ", ", p1, ", ", p2, ", ", pmax, arg(extra, 15),
                    "): Polypropylene strip ", total, "mm x ", w, "mm x ", thickness, "mm"));

    a = abs(delta[0] / 2);
    b = pow(2 * pow(length / PI, 1.5) - pow(a, 1.5), 1/1.5);

    translate(p1 - [a, 0, 0])
        multmatrix(m = [ [1, 0, 0, 0],
                         [delta[1] / delta[0], 1, 0, delta[1] / 2],
                         [delta[2] / delta[0], 0, 1, delta[2] / 2],
                         [0, 0, 0, 1] ])

        color(cable_strip_colour) linear_extrude(w, center = true, convexity = 4)
            difference() {
                union()  {
                    square([(a + thickness) * 2, extra * 2], center = true);
                    translate([0, -extra])
                        ellipse((a + thickness), b + thickness);
                }
                translate([0, (b + 1) / 2])
                    square([a * 2 + 1, b + 1], center = true);

                square([a * 2, extra * 2], center = true);
                translate([0, -extra])
                    ellipse(a, b);
            }
}
