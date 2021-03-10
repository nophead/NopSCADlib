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
//! Axial fans.
//!
//! Can draw three styles: solid, open frame and open frame with screw bosses.
//
include <../utils/core/core.scad>
use <screw.scad>
use <nut.scad>
use <washer.scad>
use <../utils/tube.scad>

fan_colour = grey(20);

function fan_width(type)          = type[0];    //! Width of square
function fan_depth(type)          = type[1];    //! Depth of fan
function fan_bore(type)           = type[2];    //! Diameter of the hole for the blades
function fan_hole_pitch(type)     = type[3];    //! Screw hole pitch
function fan_screw(type)          = type[4];    //! Screw type
function fan_hub(type)            = type[5];    //! Diameter of the hub
function fan_thickness(type)      = type[6];    //! Thickness of the frame
function fan_outer_diameter(type) = type[7];    //! Outside diameter of the frame
function fan_blades(type)         = type[8];    //! The number of blades
function fan_boss_d(type)         = type[9];    //! Diameter of the screw bosses
function fan_aperture(type)       = type[10] ? type[10] : fan_bore(type); //! Optional diameter for the aperture, which can be bigger than the bore it has flared corners.

module fan(type) { //! Draw specified fan, origin in the centre
    width = fan_width(type);
    depth = fan_depth(type);
    thickness = fan_thickness(type);
    hole_pitch = fan_hole_pitch(type);
    corner_radius = width / 2 - hole_pitch;
    screw = fan_screw(type);

    vitamin(str("fan(fan", width, "x", depth, "): Fan ", width, "mm x ", depth, "mm"));

    module squarish(s, n) {
        polygon([
            for(i = [0 : n]) [i * s.x / n,  s.y + (i % 2) * eps],
            for(i = [0 : n]) [s.x - i * s.x / n, (i % 2) * eps],
        ]);
    }

    module shape()
        difference() {
            //overall outside
            rounded_square([width, width], corner_radius);

            //main inside bore, less hub
            difference() {
                circle(fan_bore(type) / 2);
                circle(fan_hub(type) / 2);
            }

            //Mounting holes
            fan_hole_positions(type)
                circle(screw_clearance_radius(screw));
       }

    color(fan_colour) {
        middle = depth - 2 * thickness;
        if(middle > 0) {
            for(z = [-1, 1])
                translate_z(z * (depth - thickness) / 2)
                    linear_extrude(thickness, center = true)
                        shape();

            linear_extrude(middle, center = true)
                difference() {
                    shape();
                    difference() {
                        circle(sqrt(2) * width / 2);
                        circle(d =  fan_outer_diameter(type));

                        if(fan_boss_d(type))
                            for(i = [-1, 1])
                                hull()
                                    for(side = [-1, 1])
                                        translate([hole_pitch * side * i, hole_pitch * side])
                                            circle(d = fan_boss_d(type));
                    }
                }
        }
        else
            linear_extrude(depth, center = true)
                shape();

        // Blades
        blade_ir = fan_hub(type) / 2 - 1;
        blade_len = fan_bore(type) / 2 - 0.75 - blade_ir;
        linear_extrude(depth - 1, center = true, convexity = 4, twist = -30, slices = round(depth / 2))
            for(i = [0 : fan_blades(type) - 1])
                rotate((360 * i) / fan_blades(type))
                    translate([blade_ir, -1.5 / 2])
                        squarish([blade_len, 1.5], round(blade_len / 2));
    }
}

module fan_hole_positions(type, z = undef) { //! Position children at the screw hole positions
    hole_pitch = fan_hole_pitch(type);
    for(x = [-hole_pitch, hole_pitch])
        for(y = [-hole_pitch, hole_pitch])
            translate([x, y, is_undef(z) ? fan_depth(type) / 2 : z])
                children();
}

module fan_holes(type, poly = false, screws = true, h = 100) { //! Make all the holes for the fan, or just the aperture if `screws` is false. Set `poly` true for poly_holes.
    hole_pitch = fan_hole_pitch(type);
    screw = fan_screw(type);

    extrude_if(h) {
        if(screws)
            fan_hole_positions(type, z = 0)
                if(poly)
                    poly_circle(r = screw_clearance_radius(screw));
                else
                    drill(screw_clearance_radius(screw), 0);

        difference() {
            intersection() {
                square(fan_bore(type), center = true);

                circle(d = fan_aperture(type));
            }
            if(screws)
                fan_hole_positions(type, z = 0)
                    circle(d = washer_diameter(screw_washer(screw)) + 1);
        }
    }
}

function fan_screw_depth(type, full_depth = false) = fan_boss_d(type) || full_depth ? fan_depth(type) : fan_thickness(type);

function fan_screw_length(type, thickness, full_depth = false) =
    let(depth = fan_screw_depth(type, full_depth),
        washers = depth == fan_depth(type) ? 2 : 1)
            screw_length(fan_screw(type), thickness + depth, washers, nyloc = true); //! Screw length required

module fan_assembly(type, thickness, include_fan = true, screw = false, full_depth = false) { //! Fan with its fasteners
    translate_z(-fan_depth(type) / 2) {
        if(include_fan)
            fan(type);

        Screw = screw ? screw : fan_screw(type);
        nut = screw_nut(Screw);
        fan_hole_positions(type) {
            translate_z(thickness)
                screw_and_washer(Screw, fan_screw_length(type, thickness, full_depth));

            translate_z(include_fan ? -fan_screw_depth(type, full_depth) : 0)
                vflip()
                    if(fan_screw_depth(type, full_depth) == fan_depth(type))
                        nut_and_washer(nut, true);
                    else
                        nut(nut, true);
        }
     }
}
