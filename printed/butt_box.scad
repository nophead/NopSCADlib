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
//! Uses [fixing blocks](#fixing_block) and [corner blocks](#corner_block) by default. Setting `thin_blocks` uses 2screw_blocks instead of
//! fixing_blocks along the sides.
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
function bbox_name(type)       = type[8]; //! Optional name if there is more than one box in a project
function bbox_skip_blocks(type)= type[9]; //! List of fixing blocks to skip, used to allow a hinged panel for example
function bbox_star_washers(type)= type[10];//! Set to false to remove star washers.
function bbox_thin_blocks(type) = type[11];//! Set for 2 screw blocks instead of three hole fixing blocks.
function bbox_short_inserts(type)= type[12];//! Set to use short inserts in the blocks

function bbox(screw, sheets, base_sheet, top_sheet, span, size, name = "bbox", skip_blocks = [], star_washers = true, thin_blocks = false, short_inserts = false) = //! Construct the property list for a butt_box
 [ screw, sheets, base_sheet, top_sheet, span, size.x, size.y, size.z, name, skip_blocks, star_washers, thin_blocks, short_inserts ];

function bbox_volume(type) = bbox_width(type) * bbox_depth(type) * bbox_height(type) / 1000000; //! Internal volume in litres
function bbox_area(type) = let(w =  bbox_width(type), d = bbox_depth(type), h = bbox_height(type)) //! Internal surface area in m^2
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

function corner_holes(type) = let(short = bbox_short_inserts(type))
    [for(p = corner_block_positions(type), q = corner_block_holes(bbox_screw(type), short_insert = short)) p * q];

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

function side_holes(type) = let(
    screw = bbox_screw(type),
    short = bbox_short_inserts(type),
    holes = bbox_thin_blocks(type) ? 2screw_block_holes(screw, short_insert = short) : fixing_block_holes(screw))
        [for(p = fixing_block_positions(type), q = holes) p * q];

module bbox_drill_holes(type, t)
    position_children(concat(corner_holes(type), side_holes(type)), t)
        drill(screw_clearance_radius(bbox_screw(type)), 0);

module bbox_base_blank(type) { //! 2D template for the base
    difference() {
        sheet_2D(bbox_base_sheet(type), bbox_width(type), bbox_depth(type), 1);

        bbox_drill_holes(type, translate(bbox_height(type) / 2));
    }
}

module bbox_top_blank(type) { //! 2D template for the top
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
    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));

    difference() {
        translate([-t / 2, -bb / 2])
            sheet_2D(subst_sheet(type, sheet), bbox_depth(type) + t, bbox_height(type) + bb);

        bbox_drill_holes(type, rotate([0, 90, 90]) * translate([bbox_width(type) / 2, 0]));
    }
}

module bbox_right_blank(type, sheet = false) { //! 2D template for the right side
    t = sheet_thickness(bbox_sheets(type));
    bb = sheet_thickness(bbox_base_sheet(type));

    difference() {
        translate([t / 2, -bb / 2])
            sheet_2D(subst_sheet(type, sheet), bbox_depth(type) + t, bbox_height(type) + bb);

        bbox_drill_holes(type, rotate([0, 90, 90]) * translate([-bbox_width(type) / 2, 0]));
    }
}

module bbox_front_blank(type, sheet = false, width = 0) { //! 2D template for the front
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
    bb = sheet_thickness(bbox_base_sheet(type));
    t = sheet_thickness(bbox_sheets(type));

    difference() {
        translate([0, -bb / 2])
            sheet_2D(subst_sheet(type, sheet), bbox_width(type), bbox_height(type) + bb);

        bbox_drill_holes(type, rotate([-90, 0, 0]) * translate([0, -bbox_depth(type) / 2]));
    }
}

module bbox_base(type)  //! Default base, can be overridden to customise
    render_2D_sheet(bbox_base_sheet(type))
        dxf(str(bbox_name(type), "_base"))
            bbox_base_blank(type);

module bbox_top(type)   //! Default top, can be overridden to customise
    render_2D_sheet(bbox_top_sheet(type))
        dxf(str(bbox_name(type), "_top"))
            bbox_top_blank(type);

module bbox_back(type)  //! Default back, can be overridden to customise
    render_2D_sheet(bbox_sheets(type))
        dxf(str(bbox_name(type), "_back"))
            bbox_back_blank(type);

module bbox_front(type) //! Default front, can be overridden to customise
    render_2D_sheet(bbox_sheets(type))
        dxf(str(bbox_name(type), "_front"))
            bbox_front_blank(type);

module bbox_left(type)  //! Default left side, can be overridden to customise
    render_2D_sheet(bbox_sheets(type))
        dxf(str(bbox_name(type), "_left"))
            bbox_left_blank(type);

module bbox_right(type) //! Default right side, can be overridden to customise
    render_2D_sheet(bbox_sheets(type))
        dxf(str(bbox_name(type), "_right"))
            bbox_right_blank(type);

module _bbox_assembly(type, top = true, base = true, left = true, right = true, back = true, front = true) { //! The box assembly, wrap with a local copy without parameters
    width = bbox_width(type);
    depth = bbox_depth(type);
    height = bbox_height(type);
    echo("Butt_box:", width, depth, height, volume = bbox_volume(type), area = bbox_area(type));

    t = sheet_thickness(bbox_sheets(type));
    bt = sheet_thickness(bbox_base_sheet(type));
    tt = sheet_thickness(bbox_top_sheet(type));
    star_washers = bbox_star_washers(type);
    thin_blocks = bbox_thin_blocks(type);
    short = bbox_short_inserts(type);

    function is_missing_screw(p) = p.y > depth / 2 - 1 ? !back : false;

    assembly(bbox_name(type)) {

        for(p = corner_block_positions(type))
            let(q = transform([0, 0, 0], p), thickness = q.z > 0 ? tt : bt)
                multmatrix(p)
                    fastened_corner_block_assembly(is_missing_screw(q) && ((q.z > 0) != (q.x > 0)) ? 0 : t, bbox_screw(type), thickness,
                                                   is_missing_screw(q) && ((q.z > 0) == (q.x > 0)) ? 0 : t, star_washers = star_washers, short_insert = short);

        h = height / 2 - 1;
        for(p = fixing_block_positions(type))
            let(q = transform([0, 0, 0], p), thickness = q.z > h ? tt : q.z < -h ? bt : t)
                multmatrix(p)
                    if(thin_blocks)
                        fastened_2screw_block_assembly(is_missing_screw(q) ? 0 : t, bbox_screw(type), thickness_below = thickness, star_washers = star_washers, short_insert = short);
                    else
                        fastened_fixing_block_assembly(is_missing_screw(q) ? 0 : t, bbox_screw(type), thickness2 = thickness, star_washers = star_washers);

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
