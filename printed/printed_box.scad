//
// NopSCADlib Copyright Chris Palmer 2020
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
//! A fully parametric 3D printed case that can be customised with cutouts and additions specified by children.
//!
//! The walls can be made wavy, which possibly reduces warping when printing and looks nice, however if holes need to be made
//! in the sides you can't print a wavy bridge. Any holes need to be surrounded by a 45&deg; chamfer to make the bridges straight.
//! See the mounting points for the feet in the first example.
//!
//! It can also have printed feet on the base with the screws doubling up to hold the base on.
//
include <../utils/core/core.scad>
use <../vitamins/screw.scad>
use <../vitamins/washer.scad>
use <../vitamins/insert.scad>
use <foot.scad>

function pbox(name, wall, top_t, base_t, radius, size, foot = false, screw = false, short_insert = false, ridges = [0, 0]) //! Construct a printed box property list
    = concat([name, wall, top_t, base_t, foot, screw, short_insert, radius, ridges], size);

function pbox_name(type)       = type[0]; //! Name to allow more than one box in a project
function pbox_wall(type)       = type[1]; //! Wall thickness
function pbox_top(type)        = type[2]; //! Top thickness
function pbox_base(type)       = type[3]; //! Base thickness, can be zero for no base
function pbox_foot(type)       = type[4]; //! Printed foot, can be false to suppress feet
function pbox_base_screw(type) = type[5]; //! Screw type if no feet
function pbox_short_insert(type)=type[6]; //! Use short inserts
function pbox_radius(type)     = type[7]; //! Internal corner radius
function pbox_ridges(type)     = type[8]; //! Ridge wavelength and amplitude
function pbox_width(type)      = type[9]; //! Internal width
function pbox_depth(type)      = type[10]; //! Internal depth
function pbox_height(type)     = type[11]; //! Internal height

base_outset = 1;    // How much the base overlaps the inner dimensions
base_overlap = 2;   // The width of ledge the base sits on
height_overlap = 1; // How far the edges sit below the base

function pbox_inclusion(type) = pbox_base(type) ? base_overlap - base_outset : 0; //! How far the ledge for the base extends inwards

function pbox_total_height(type) =  //! Total height including base overlap
    let(base = pbox_base(type),
        foot = pbox_foot(type),
        washer = pbox_washer(type),
        screw = pbox_screw(type))
        pbox_height(type) + pbox_top(type) + base + (base ? height_overlap : 0) + (foot || !base ? 0 : washer_thickness(washer) + screw_head_height(screw));

function pbox_screw(type) =         //! Foot screw if got feet else base_screw
    let(foot = pbox_foot(type)) foot ? foot_screw(foot) : pbox_base_screw(type);

function pbox_insert(type) = screw_insert(pbox_screw(type), short = pbox_short_insert(type)); //! The insert for the base screws
function pbox_washer(type) = screw_washer(pbox_screw(type)); //! The washer for the base screws

function pbox_screw_length(type, panel_thickness = 0) =  //! Length of the base screw
    let(foot = pbox_foot(type), screw = pbox_screw(type))
        screw_length(screw, pbox_base(type) + (foot ? foot_thickness(foot) : panel_thickness), 1,  pbox_insert(type));

function pbox_mid_offset(type) = pbox_ridges(type).y + pbox_wall(type) / 2; // Offset to wall midpoint

function pbox_screw_inset(type) = //! How far the base screws are inset
    let(foot = pbox_foot(type),
        r = foot ? foot_diameter(foot) / 2 : pbox_base(type) ? washer_radius(pbox_washer(type)) : insert_hole_radius(pbox_insert(type)),
        R =  pbox_radius(type)
    ) max(r, R - (R - r) / sqrt(2));

module pbox_screw_positions(type) { //! Place children at base screw positions
    foot = pbox_foot(type);
    inset = pbox_screw_inset(type);
    for(x = [-1, 1], y = [-1, 1])
         translate([x * (pbox_width(type) / 2 - inset), y * (pbox_depth(type) / 2 - inset)])
            rotate((y > 0 ? -x * 45 : -x * 135) + 90)
                children();
}

module pbox_mid_shape(type) {
    ridges = pbox_ridges(type);
    offset = ridges.y + pbox_wall(type) / 2;
    rad = pbox_radius(type) + offset;
    w = pbox_width(type) + 2 * offset;
    d = pbox_depth(type) + 2 * offset;

    module waves(length) {
        l = length - 2 * rad;

        waves = round(l / ridges.x);
        points = 16;
        translate([-l / 2, ridges.y / 2])
            polygon(concat([[0, -10]], [for(i = [0 : waves * points], a = 360 * i / points) [i * l / waves / points, -cos(a) * ridges.y / 2] ], [[l, -10]]));
    }

    difference() {
        rounded_square([w, d], rad, center = true);

        if(ridges.y)
            for(side = [-1, 1]) {
                translate([0,  side * d / 2])
                    rotate(90 + side * 90)
                        waves(w);

                translate([side * w / 2, 0])
                    rotate(side * 90)
                        waves(d);
            }
     }
}

module pbox_inner_shape(type) {
    rad = pbox_radius(type);
    w = pbox_width(type);
    d = pbox_depth(type);

    rounded_square([w, d], rad, center = true);
}

module pbox_outer_shape(type) //! 2D outer shape of the box
    offset(pbox_wall(type) / 2) pbox_mid_shape(type);

module pbox_base(type) { //! Generate the STL for the base
    t = pbox_base(type);

    stl(str(pbox_name(type),"_base"))
        difference() {
            union() {
                linear_extrude(t)
                    offset(base_outset - 0.2)
                        pbox_inner_shape(type);

                if($children > 0)
                    children(0);
            }
            pbox_screw_positions(type)
                poly_cylinder(r = screw_clearance_radius(pbox_screw(type)), h = 2 * t + eps, center = true);

            if($children > 1)
                children(1);
        }
}

module pbox(type) { //! Generate the STL for the main case
    height = pbox_height(type);
    total_height = pbox_total_height(type);
    top_thickness = pbox_top(type);
    wall = pbox_wall(type);
    ledge_outset = pbox_ridges(type).y;
    ledge_inset = base_outset - base_overlap;
    ledge_h = pbox_base(type) ? (ledge_outset - ledge_inset) * 2 : 0;

    stl(pbox_name(type))
        difference() {
            union() {
                linear_extrude(total_height)
                    pbox_outer_shape(type);

                if($children > 2)
                    children(2);
            }
            difference() {
                translate_z(top_thickness)
                    union() {
                        linear_extrude(height + eps)
                             offset(-wall / 2) pbox_mid_shape(type);

                         translate_z(height)                                     // Recess for the base
                            linear_extrude(total_height - height)
                                offset(base_outset)
                                    pbox_inner_shape(type);
                    }
                // Ledge to support the lid
                if(ledge_h)
                    translate_z(top_thickness + height - ledge_h)
                        difference() {
                            rounded_rectangle([pbox_width(type) + 2 * outset, pbox_depth(type) + 2 * outset, ledge_h], 1);

                            hull() {
                                linear_extrude(ledge_h + eps)
                                    offset(ledge_inset)
                                        pbox_inner_shape(type);

                                linear_extrude(eps)
                                    offset(ledge_outset)
                                         pbox_inner_shape(type);
                            }
                            pbox_screw_positions(type)
                                insert_hole(pbox_insert(type));
                        }

                // Corner lugs for inserts
                outset = wall + pbox_ridges(type).y;
                or = pbox_radius(type) + outset;
                inset = pbox_screw_inset(type) + outset;
                br = insert_boss_radius(pbox_insert(type), wall);
                ext = sqrt(2) * inset - or * (sqrt(2) - 1) - br;
                translate_z(height + top_thickness)
                    pbox_screw_positions(type)
                        insert_lug(pbox_insert(type), wall, counter_bore = 0, extension = ext, corner_r = or);

                if($children > 0)
                    children(0);
            }
            if($children > 1)
                children(1);
        }
}

module pbox_inserts(type) //! Place the inserts for the base screws
    translate_z(pbox_height(type) + pbox_top(type))
        pbox_screw_positions(type)
            insert(pbox_insert(type));

module pbox_base_screws(type, thickness = 0)           //! Place the screws and feet
    translate_z(pbox_height(type) + pbox_top(type) + pbox_base(type))
        pbox_screw_positions(type) {
            foot = pbox_foot(type);
            if(foot)
                stl_colour(pp4_colour)
                    foot(foot);

            translate_z(foot ? foot_thickness(foot) : thickness)
                screw_and_washer(pbox_screw(type), pbox_screw_length(type, thickness));
        }
