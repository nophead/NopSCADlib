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
//! Needs to be `include`d rather than `use`d to allow the panel definitions to be overridden to add holes
//! and mounted components.
//!
//! A list specifies the internal dimensions, screw type, top, bottom and side sheet types and the block
//! maximum spacing.
//!
//!  * An optional name can be specified to allow more then one box in a project.
//!  * An optional list of fixing blocks to be omitted can be given.
//!  * Star washers can be omitted by setting the 11th parameter to false.
//!
//! Uses [fixing blocks](#fixing_block) and [corner blocks](#corner_block).
//

use <fixing_block.scad>
use <corner_block.scad>
use <../utils/maths.scad>

function bbox_screw(type)      = type[0]; //! Screw type for corner blocks
function bbox_sheets(type)     = type[1]; //! Sheet type for the sides
function bbox_base_sheet(type) = type[2]; //! Sheet type for the base
function bbox_top_sheet(type)  = type[3]; //! Sheet type for the top
function bbox_span(type)       = type[4]; //! Maximum span between fixing blocks
function bbox_width(type)      = type[5]; //! Internal width
function bbox_depth(type)      = type[6]; //! Internal depth
function bbox_height(type)     = type[7]; //! Internal height
function bbox_name(type)       = type[8] ? type[8] : "bbox"; //! Optional name if there is more than one box in a project
function bbox_skip_blocks(type)= type[9] ? type[9] : [];  //! List of fixing blocks to skip, used to allow a hinged panel for example
function star_washers(type)    = type[10] ? type[10] : is_undef(type[10]); //! Set to false to remove star washers.

function bbox(screw, sheets, base_sheet, top_sheet, span, size, name = "bbox", skip_blocks = [], star_washers = true) = //! Construct the property list for a butt_box
 [ screw, sheets, base_sheet, top_sheet, span, size.x, size.y, size.z, name, skip_blocks, star_washers ];

function bbox_volume(type) = bbox_width(type) * bbox_depth(type) * bbox_height(type) / 1000000; //! Internal volume in litres
function bbox_area(type) = let(w =  bbox_width(type), d = bbox_depth(type), h = bbox_height(type)) //! Internal surdface area in m^2
    2 * (w * d + w * h + d * h) / 1000000;

module bbox_shelf_blank(type) { //! 2D template for a shelf
    dxf(str(bbox_name(type), "_shelf"));

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
        hspan = height / (hspans + 1),
        skips = bbox_skip_blocks(type)
    )
    [
        for(i = [0 : 1 : wspans - 1], y = [-1, 1], z = [-1, 1])
            if(!in(skips, [0, y, z]))
                translate([(i - (wspans - 1) / 2) * wspan, y * depth / 2, z * height / 2]) *
                rotate([0, z * 90 + 90, y * 90 + 90]),

        for(i = [0 : 1 : dspans - 1], x = [-1, 1], z = [-1, 1])
            if(!in(skips, [x, 0, z]))
                translate([x * width / 2, (i - (dspans - 1) / 2) * dspan, z * height / 2]) *
                rotate([0, z * 90 + 90, x * 90]),

        for(i = [0 : 1 : hspans - 1], x = [-1, 1], y = [-1, 1])
            if(!in(skips, [x, y, 0]))
                translate([x * width / 2, y * depth / 2, (i - (hspans - 1) / 2) * hspan]) *
                rotate([y > 0 ? 180 : 0, x * y * 90, 0]),
    ];

function side_holes(type) = [for(p = fixing_block_positions(type), q = fixing_block_holes(bbox_screw(type))) p * q];

module bbox_drill_holes(type, t)
    position_children(concat(corner_holes(type), side_holes(type)), t)
        drill(screw_clearance_radius(bbox_screw(type)), 0);

module bbox_base_blank(type) { //! 2D template for the base
    dxf(str(bbox_name(type), "_base"));

    difference() {
        sheet_2D(bbox_base_sheet(type), bbox_width(type), bbox_depth(type), 1);

        bbox_drill_holes(type, translate(bbox_height(type) / 2));
    }
}

module bbox_top_blank(type) { //! 2D template for the top
    dxf(str(bbox_name(type), "_top"));

    t = sheet_thickness(bbox_sheets(type));

    difference() {
        translate([0, t / 2])
            sheet_2D(bbox_top_sheet(type), bbox_width(type) + 2 * t, bbox_depth(type) + t);

        bbox_drill_holes(type, translate(-bbox_height(type) / 2));
    }
}

function subst_sheet(type, sheet) =
    let(s = bbox_sheets(type))
        sheet ? assert(sheet_thickness(sheet) == sheet_thickness(s)) sheet : s;

module bbox_left_blank(type, sheet = false) { //! 2D template for the left side
    dxf(str(bbox_name(type), "_left"));

    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));

    difference() {
        translate([-t / 2, -bb / 2])
            sheet_2D(subst_sheet(type, sheet), bbox_depth(type) + t, bbox_height(type) + bb);

        bbox_drill_holes(type, rotate([0, 90, 90]) * translate([bbox_width(type) / 2, 0]));
    }
}

module bbox_right_blank(type, sheet = false) { //! 2D template for the right side
    dxf(str(bbox_name(type), "_right"));

    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));

    difference() {
        translate([t / 2, -bb / 2])
            sheet_2D(subst_sheet(type, sheet), bbox_depth(type) + t, bbox_height(type) + bb);

        bbox_drill_holes(type, rotate([0, 90, 90]) * translate([-bbox_width(type) / 2, 0]));
    }
}

module bbox_front_blank(type, sheet = false, width = 0) { //! 2D template for the front
    dxf(str(bbox_name(type), "_front"));

    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));
    bt = sheet_thickness(bbox_top_sheet(type));

    difference() {
        translate([0, (bt - bb) / 2])
            sheet_2D(subst_sheet(type, sheet), max(bbox_width(type) + 2 * t, width), bbox_height(type) + bb + bt);

        bbox_drill_holes(type, rotate([-90, 0, 0]) * translate([0, bbox_depth(type) / 2]));
    }
}

module bbox_back_blank(type, sheet = false) { //! 2D template for the back
    dxf(str(bbox_name(type), "_back"));

    bb = sheet_thickness(bbox_base_sheet(type));
    t = sheet_thickness(bbox_sheets(type));

    difference() {
        translate([0, -bb / 2])
            sheet_2D(subst_sheet(type, sheet), bbox_width(type), bbox_height(type) + bb);

        bbox_drill_holes(type, rotate([-90, 0, 0]) * translate([0, -bbox_depth(type) / 2]));
    }
}

module bbox_base(type)  render_2D_sheet(bbox_base_sheet(type)) bbox_base_blank(type);   //! Default base, can be overridden to customise
module bbox_top(type)   render_2D_sheet(bbox_top_sheet(type)) bbox_top_blank(type);     //! Default top, can be overridden to customise
module bbox_back(type)  render_2D_sheet(bbox_sheets(type)) bbox_back_blank(type);       //! Default back, can be overridden to customise
module bbox_front(type) render_2D_sheet(bbox_sheets(type)) bbox_front_blank(type);      //! Default front, can be overridden to customise
module bbox_left(type)  render_2D_sheet(bbox_sheets(type)) bbox_left_blank(type);       //! Default left side, can be overridden to customise
module bbox_right(type) render_2D_sheet(bbox_sheets(type)) bbox_right_blank(type);      //! Default right side, can be overridden to customise

module _bbox_assembly(type, top = true, base = true, left = true, right = true, back = true, front = true) { //! The box assembly, wrap with a local copy without parameters
    width = bbox_width(type);
    depth = bbox_depth(type);
    height = bbox_height(type);
    echo("Box:", width, depth, height, volume = bbox_volume(type), area = bbox_area(type));

    t = sheet_thickness(bbox_sheets(type));
    bt = sheet_thickness(bbox_base_sheet(type));
    tt = sheet_thickness(bbox_top_sheet(type));

    function is_missing_screw(p) = p.y > depth / 2 - 1 ? !back : false;

    assembly(bbox_name(type)) {

        for(p = corner_block_positions(type))
            let(q = transform([0, 0, 0], p), thickness = q.z > 0 ? tt : bt)
                multmatrix(p)
                    fastened_corner_block_assembly(is_missing_screw(q) && ((q.z > 0) != (q.x > 0)) ? 0 : t, bbox_screw(type), thickness,
                                                   is_missing_screw(q) && ((q.z > 0) == (q.x > 0)) ? 0 : t, star_washers = star_washers(type));

        h = height / 2 - 1;
        for(p = fixing_block_positions(type))
            let(q = transform([0, 0, 0], p), thickness = q.z > h ? tt : q.z < -h ? bt : t)
                multmatrix(p)
                    fastened_fixing_block_assembly(is_missing_screw(q) ? 0 : t, bbox_screw(type), thickness2 = thickness, star_washers = star_washers(type));

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

        for(y = [1, -1])
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
}
