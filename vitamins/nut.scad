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
include <../core.scad>
use <washer.scad>
use <screw.scad>
use <../utils/rounded_cylinder.scad>
brass_colour = brass;

function nut_size(type)       = type[1];        //! Diameter of the corresponding screw
function nut_radius(type)     = type[2] / 2;    //! Radius across the corners
function nut_thickness(type, nyloc = false) = nyloc ? type[4] : type[3]; //! Thickness of plain or nyloc version
function nut_washer(type)     = type[5];        //! Corresponding washer
function nut_trap_depth(type) = type[6];        //! Depth of nut trap

function nut_flat_radius(type) = nut_radius(type) * cos(30); //! Radius across the flats

module nut(type, nyloc = false, brass = false, nylon = false) { //! Draw specified nut
    hole_rad  = nut_size(type) / 2;
    outer_rad = nut_radius(type);
    thickness = nut_thickness(type);
    nyloc_thickness = nut_thickness(type, true);
    desc = nyloc ? "nyloc" : brass ? "brass" : nylon ? "nylon" : "";
    vitamin(str("nut(", type[0], arg(nyloc, false, "nyloc"), arg(brass, false, "brass"), arg(nylon, false, "nylon"),
                   "): Nut M", nut_size(type), " x ", thickness, "mm ", desc));

    explode(nyloc ? 10 : 0)
        color(brass ? brass_colour : nylon ? grey30: grey70) {
            linear_extrude(height = thickness)
                difference() {
                    circle(outer_rad, $fn = 6);

                    circle(hole_rad);
                }
            if(nyloc)
                translate_z(-eps)
                    rounded_cylinder(r = outer_rad * cos(30) , h = nyloc_thickness, r2 = (nyloc_thickness - thickness) / 2, ir = hole_rad);
        }
    if($children)
        translate_z(thickness)
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
    hole_rad  = nut_size(type) / 2;
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

    explode(10) color(grey70) {
        rotate_extrude()
            polygon([
                [hole_rad, 0],
                [bottom_rad, 0],
                [top_rad,, thickness],
                [hole_rad, thickness]
            ]);
        for(rot = [0, 180])
            rotate([90, 0, rot]) linear_extrude(height = wing_thickness, center = true)
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
