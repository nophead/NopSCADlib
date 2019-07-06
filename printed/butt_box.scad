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
//! A box made from CNC cut panels butted together using printed fixing blocks. Useful for making large
//! boxes with minimal 3D printing.  More blocks are added as the box gets bigger.
//!
//! Needs to be ```include```d rather than ```use```d to allow the panel definitions to be overridden to add holes
//! and mounted components.
//!
//! A list specifies the internal dimensions, screw type, top, bottom and side sheet types and the block
//! maximum spacing.
//!
//! Uses [fixing blocks](#fixing_block) and [corner blocks](#corner_block).
//

use <fixing_block.scad>
use <corner_block.scad>
use <../utils/maths.scad>

function bbox_screw(type)     = type[0]; //! Screw type for corner blocks
function bbox_sheets(type)    = type[1]; //! Sheet type for the sides
function bbox_base_sheet(type)= type[2]; //! Sheet type for the base
function bbox_top_sheet(type) = type[3]; //! Sheet type for the top
function bbox_span(type)      = type[4]; //! Maximum span between fixing blocks
function bbox_width(type)     = type[5]; //! Internal width
function bbox_depth(type)     = type[6]; //! Internal depth
function bbox_height(type)    = type[7]; //! Internal height

module bbox_shelf_blank(type) { //! 2D template for a shelf
    dxf("bbox_shelf");

    sheet_2D(bbox_sheets(type), bbox_width(type), bbox_depth(type), 1);
}

function corner_block_positions(type) = let(
        width = bbox_width(type),
        depth = bbox_depth(type),
        height = bbox_height(type)
    )
    [for(corner = [0 : 3], z = [-1, 1])
        let(
            x = [-1,1,1,-1][corner],
            y = [-1,-1,1,1][corner]
        ) translate([x * (width / 2), y * (depth / 2), z * height / 2]) *
          rotate([z > 0 ? 180 : 0, 0, corner * 90 + (z > 0 ? 90 : 0)])

    ];

module corner_block_positions(type) {
    bt = sheet_thickness(bbox_base_sheet(type));
    tt = sheet_thickness(bbox_top_sheet(type));
    for(p = corner_block_positions(type))
        let($thickness = transform([0, 0, 0], p).z > 0 ? tt : bt)
            multmatrix(p)
                children();
}

function corner_holes(type) = [for(p = corner_block_positions(type), q = corner_block_holes(bbox_screw(type))) p * q];

function fixing_block_positions(type) = let(
        width = bbox_width(type),
        depth = bbox_depth(type),
        height = bbox_height(type),
        span = bbox_span(type),
        wspans = floor(width / span),
        wspan = width / (wspans + 1),
        dspans = floor(depth / span),
        dspan = depth / (dspans + 1),
        hspans = floor(height / span),
        hspan = height / (hspans + 1)
    )
    [
        for(i = [0 : 1 : wspans - 1], y = [-1, 1], z = [-1, 1])
            translate([(i - (wspans - 1) / 2) * wspan, y * depth / 2, z * height / 2]) *
            rotate([0, z * 90 + 90, y * 90 + 90]),

        for(i = [0 : 1 : dspans - 1], x = [-1, 1], z = [-1, 1])
            translate([x * width / 2, (i - (dspans - 1) / 2) * dspan, z * height / 2]) *
            rotate([0, z * 90 + 90, x * 90]),

        for(i = [0 : 1 : hspans - 1], x = [-1, 1], y = [-1, 1])
            translate([x * width / 2, y * depth / 2, (i - (hspans - 1) / 2) * hspan]) *
            rotate([y > 0 ? 180 : 0, x * y * 90, 0]),

    ];

function side_holes(type) = [for(p = fixing_block_positions(type), q = fixing_block_holes(bbox_screw(type))) p * q];

module fixing_block_positions(type) {
    t = sheet_thickness(bbox_sheets(type));
    bt = sheet_thickness(bbox_base_sheet(type));
    tt = sheet_thickness(bbox_top_sheet(type));
    h = bbox_height(type) / 2 - 1;
    for(p = fixing_block_positions(type))
        let(z = transform([0, 0, 0], p).z, $thickness = z > h ? tt : z < -h ? bt : t)
            multmatrix(p)
                children();
}

module drill_holes(type, t)
    for(list = [corner_holes(type), side_holes(type)], p = list)
        let(q = t * p)
            if(abs(transform([0, 0, 0], q).z) < eps)
                multmatrix(q)
                    drill(screw_clearance_radius(bbox_screw(type)), 0);

module bbox_base_blank(type) { //! 2D template for the base
    dxf("bbox_base");

    difference() {
        sheet_2D(bbox_base_sheet(type), bbox_width(type), bbox_depth(type), 1);

        drill_holes(type, translate(bbox_height(type) / 2));
    }
}

module bbox_top_blank(type) { //! 2D template for the top
    dxf("bbox_top");

    t = sheet_thickness(bbox_sheets(type));

    difference() {
        translate([0, t / 2])
            sheet_2D(bbox_top_sheet(type), bbox_width(type) + 2 * t, bbox_depth(type) + t);

        drill_holes(type, translate(-bbox_height(type) / 2));
    }
}

module bbox_left_blank(type) { //! 2D template for the left side
    dxf("bbox_left");

    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));

    difference() {
        translate([-t / 2, -bb / 2])
            sheet_2D(bbox_sheets(type), bbox_depth(type) + t, bbox_height(type) + bb);

        drill_holes(type, rotate([0, 90, 90]) * translate([bbox_width(type) / 2, 0]));
    }
}

module bbox_right_blank(type) { //! 2D template for the right side
    dxf("bbox_right");

    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));

    difference() {
        translate([t / 2, -bb / 2])
            sheet_2D(bbox_sheets(type), bbox_depth(type) + t, bbox_height(type) + bb);

        drill_holes(type, rotate([0, -90, 90]) * translate([-bbox_width(type) / 2, 0]));
    }
}

module bbox_front_blank(type) { //! 2D template for the front
    dxf("bbox_front");

    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));
    bt = sheet_thickness(bbox_top_sheet(type));

    difference() {
        translate([0, (bt - bb) / 2])
            sheet_2D(bbox_sheets(type), bbox_width(type) + 2 * t, bbox_height(type) + bb + bt);

        drill_holes(type, rotate([-90, 0, 0]) * translate([0, bbox_depth(type) / 2]));
    }
}

module bbox_back_blank(type) { //! 2D template for the back
    dxf("bbox_back");

    bb = sheet_thickness(bbox_base_sheet(type));
    t = sheet_thickness(bbox_sheets(type));

    difference() {
        translate([0, -bb / 2])
            sheet_2D(bbox_sheets(type), bbox_width(type), bbox_height(type) + bb);

        drill_holes(type, rotate([90, 0, 0]) * translate([0, -bbox_depth(type) / 2]));
    }
}

module bbox_base(type)  render_2D_sheet(bbox_base_sheet(type)) bbox_base_blank(type);   //! Default base, can be overridden to customise
module bbox_top(type)   render_2D_sheet(bbox_top_sheet(type)) bbox_top_blank(type);     //! Default top, can be overridden to customise
module bbox_back(type)  render_2D_sheet(bbox_sheets(type)) bbox_back_blank(type);       //! Default back, can be overridden to customise
module bbox_front(type) render_2D_sheet(bbox_sheets(type)) bbox_front_blank(type);      //! Default front, can be overridden to customise
module bbox_left(type)  render_2D_sheet(bbox_sheets(type)) bbox_left_blank(type);       //! Default left side, can be overridden to customise
module bbox_right(type) render_2D_sheet(bbox_sheets(type)) bbox_right_blank(type);      //! Default right side, can be overridden to customise

module _bbox_assembly(type, top = true, base = true, left = true, right = true, back = true, front = true) //! The box assembly, wrap with a local copy without parameters
assembly("bbox") {
    width = bbox_width(type);
    depth = bbox_depth(type);
    height = bbox_height(type);
    echo("Box:", width, depth, height);

    t = sheet_thickness(bbox_sheets(type));
    bt = sheet_thickness(bbox_base_sheet(type));
    tt = sheet_thickness(bbox_top_sheet(type));

    corner_block_positions(type)
        fastened_corner_block_assembly(t, bbox_screw(type), $thickness);

    fixing_block_positions(type)
        fastened_fixing_block_assembly(t, bbox_screw(type), thickness2 = $thickness);

    for(x = [-1, 1])
        translate([x * (width / 2 + t / 2 + eps + 25 * exploded()), 0])
            rotate([90, 0, x * 90])
                if(x > 0) {
                    if(right)
                        bbox_right(type);
                }
                else
                    if(left)
                        bbox_left(type);

    for(y = [-1, 1])
        translate([0, y * (depth / 2 + t / 2 + eps + 25 * exploded())])
            rotate([90, 0, y * 90 + 90])
                if(y < 0) {
                    if(front)
                        bbox_front(type);
                }
                else
                    if(back)
                        bbox_back(type);

    for(z = [-1, 1]) {
        sheet_thickness = z > 0 ? tt : bt;
        translate_z(z * (height / 2 + sheet_thickness / 2 + eps + 100 * exploded()))
            if(z > 0) {
                if(top)
                    bbox_top(type);
            }
            else
                if(base)
                    bbox_base(type);
    }
}
