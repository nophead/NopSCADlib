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
//! Customisable printed rubber feet for equipment cases. The insert variant is better for solid feet because
//! inserts don't grip well in rubber.
//
include <../core.scad>
include <../vitamins/screws.scad>
include <../vitamins/inserts.scad>

foot        = [25, 12, 3, 2, M4_cap_screw, 10];
insert_foot = [20, 10, 0, 2, M3_cap_screw, 10];

function insert_foot() = insert_foot; //! Default foot with insert

function foot_diameter(type = foot) = type[0]; //! Outside maximum diameter
function foot_height(type = foot)   = type[1]; //! Total height
function foot_thickness(type = foot)= type[2]; //! Thickness under the screw
function foot_rad(type = foot)      = type[3]; //! Rounded corner radius
function foot_screw(type = foot)    = type[4]; //! Screw type
function foot_slant(type = foot)    = type[5]; //! Taper angle

module foot(type = foot) { //! Generate STL
    stl("foot");
    h = foot_height(type);
    t = foot_thickness(type);
    r1 = washer_radius(screw_washer(foot_screw(type)));
    r3 = foot_diameter(type) / 2;
    r2 = r3 - h * tan(foot_slant(type));
    r =  foot_rad(type);

    union() {
        rotate_extrude(convexity = 3) {
            hull() {
                translate([r1, 0])
                    square([r3 - r1, eps]);

                for(x = [r1 + r, r2 - r])
                    translate([x, h - r])
                        circle4n(r);
            }
        }
        linear_extrude(height = t)
            difference() {
                circle(r1 + eps);

                poly_circle( screw_clearance_radius(foot_screw(type)));
        }
    }
}

module foot_assembly(t = 0, type = foot) { //! Assembly with fasteners in place for specified sheet thickness
    screw = foot_screw(type);
    washer = screw_washer(screw);
    nut = screw_nut(screw);
    squeeze = 0.5;
    screw_length = screw_longer_than(foot_thickness(type) + t + 2 * washer_thickness(washer) + nut_thickness(nut, true) - squeeze);

    vflip() explode(15, true) {
        color(pp4_colour) foot(type);

        if(t)
            explode(15, true)
                translate_z(foot_thickness(type))
                    screw_and_washer(screw, screw_length);
    }
    if(t)
        translate_z(t)
            nut_and_washer(nut, true);
}

module insert_foot(type = insert_foot) { //! Generate STL for foot with insert
    stl("insert_foot");
    h = foot_height(type);
    r3 = foot_diameter(type) / 2;
    r2 = r3 - h * tan(foot_slant(type));
    r =  foot_rad(type);

    insert = screw_insert(foot_screw(type));
    h2 = insert_hole_length(insert);
    r4 = insert_hole_radius(insert);
    r5 = r4 + 1;
    union() {
        rotate_extrude() {
            union() {
                hull() {
                    translate([r5, 0]) {
                        square([r3 - r5, eps]);
                        square([eps, h]);
                    }

                    translate([r2 - r, h - r])
                        circle4n(r);
                }
            }
        }
        linear_extrude(height = h2 + eps)
            difference() {
                circle(r5 + eps);

                poly_circle(r4);
            }

        translate_z(h2)
            cylinder(r = r5 + eps, h = h - h2);
    }
}
//
//! Place the insert in the bottom of the foot and push home with a soldering iron with a conical bit heated to 200&deg;C.
//
module insert_foot_assembly(type = insert_foot) //! Printed part with insert in place
assembly("insert_foot") {
    screw = foot_screw(type);
    insert = screw_insert(screw);

    vflip()
        color(pp1_colour) insert_foot(type);

    translate_z(-foot_thickness(type))
        insert(insert);
}

module fastened_insert_foot_assembly(t = 3, type = insert_foot) { //! Assembly with fasteners in place for specified sheet thickness
    screw = foot_screw(type);
    washer = screw_washer(screw);
    insert = screw_insert(screw);
    screw_length = screw_shorter_than(insert_length(insert) + t + 2 * washer_thickness(washer));

    explode(-10) insert_foot_assembly(type);

    translate_z(t)
        screw_and_washer(screw, screw_length, true);
}
