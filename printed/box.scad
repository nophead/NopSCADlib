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
//! A box made from routed or laser cut sheet sheets and printed profiles and bezels. It can be arbitrarily large
//! compared to the 3D printed parts because they can be cut into interlocking sections and solvent welded
//! together. The box panels can be customised to have holes and parts mounted on them by overriding the
//! definitions of `box_base()`, `box_front()`, etc.
//!
//! `box.scad` should be `use`d and `box_assembly.scad` `include`d.
//!
//! A box is defined with a list that specifies the inside dimensions, top, bottom and side sheet materials, the
//! screw type and printed part wall thickness. This diagram shows how the various dimensions are labelled:
//! ![](docs/box.png)
//!
//! Normally the side sheets are the same type but they can be overridden individually as long as the substitute has the same thickness.
//
include <../core.scad>
use <../vitamins/sheet.scad>
use <../vitamins/insert.scad>
use <../utils/quadrant.scad>
use <../utils/round.scad>

bezel_clearance = 0.2;
sheet_end_clearance = 1;
sheet_slot_clearance = 0.2;

function box_screw(type)       = type[0]; //! Screw type to be used at the corners
function box_shelf_screw(type) = type[1]; //! Screw type to hold a shelf
function box_wall(type)        = type[2]; //! Wall thickness of 3D parts
function box_sheets(type)      = type[3]; //! Sheet type used for the sides
function box_top_sheet(type)   = type[4]; //! Sheet type for the top
function box_base_sheet(type)  = type[5]; //! Sheet type for the bottom
function box_feet(type)        = type[6]; //! True to enable feet on the bottom bezel
function box_width(type)       = type[7]; //! Internal width
function box_depth(type)       = type[8]; //! Internal depth
function box_height(type)      = type[9]; //! Internal height

function box(screw, wall, sheets, top_sheet, base_sheet, size, feet = false, shelf_screw = M3_dome_screw) = //! Construct a property list for a box.
 concat([screw, shelf_screw, wall, sheets, top_sheet, base_sheet, feet], size);

function box_bezel_clearance(type) = bezel_clearance;

function box_corner_gap(type) = 3; //! Gap between box_sheets at the corners to connect inside and outside profiles
function box_profile_overlap(type) = 3 + sheet_end_clearance / 2;

function box_washer(type) = screw_washer(box_screw(type));
function box_insert(type) = screw_insert(box_screw(type));
function box_shelf_insert(type) = screw_insert(box_shelf_screw(type));

function box_hole_inset(type) = washer_radius(box_washer(type)) + 1;
function box_insert_r(type) = insert_hole_radius(box_insert(type));
function box_insert_l(type) = insert_length(box_insert(type));
function box_boss_r(type) = ceil(corrected_radius(box_insert_r(type)) + box_wall(type));

function box_sheet_slot(type) = sheet_thickness(box_sheets(type)) + sheet_slot_clearance; // add some clearance
function box_corner_overlap(type) = box_wall(type);

function box_corner_rad(type) = box_sheet_slot(type) - sheet_slot_clearance / 2 + box_corner_gap(type) + box_corner_overlap(type);
function box_sheet_r(type) = box_corner_rad(type) - box_sheet_slot(type) - box_corner_overlap(type);

function box_screw_length(type, top) =
    let(s = top ? box_top_sheet(type) : box_base_sheet(type))
        screw_length(box_screw(type), sheet_thickness(s) + box_corner_gap(type) + box_profile_overlap(type) - 1, washers = 2, insert = true, longer = true);

function box_wall_clearance(type) = box_sheet_slot(type) / 2 - sheet_thickness(box_sheets(type)) / 2;
function box_margin(type) = box_profile_overlap(type) + box_corner_gap(type); //! How much the bezel intrudes on the specified height
function box_intrusion(type) = box_hole_inset(type) + box_boss_r(type); //! Corner profile intrusion
function sheet_reduction(type) = 2 * box_corner_gap(type) + sheet_end_clearance;
function box_outset(type) = box_sheet_slot(type) + box_wall(type) - sheet_slot_clearance / 2;  //! How much the bezel expands the specified internal size
function box_inset(type) = box_wall(type) + sheet_slot_clearance / 2; //! How much the bezel intrudes on the specified width and length, away from the corners
function box_bezel_height(type, bottom) = //! Bezel height for top or bottom
    let(t1 = sheet_thickness(box_base_sheet(type)), t2 = sheet_thickness(box_top_sheet(type)))
        box_corner_rad(type) + box_profile_overlap(type) + (bottom ? max(t1, t2) : t2) - sheet_thickness(box_sheets(type));

grill_hole = 5;
grill_gap = 1.9;

function box_grill_hole_r() = grill_hole / 2;

module grill_hole_positions(width, height, r = 1000) {
    nx = floor(width / (grill_hole + grill_gap));
    xpitch = width / nx;
    ny = floor(height / ((grill_hole + grill_gap) * cos(30)));
    ypitch = height / ny;

    for(y = [0 : ny - 1], x = [0 : nx - 1 - (y % 2)]) {
        $x = -width / 2 + (x + 0.5 + (y % 2) / 2) * xpitch;
        $y = -height / 2 + (y + 0.5) * ypitch;
        if(sqrt(sqr($x) + sqr($y)) + grill_hole / 2 <= r)
            translate([$x, $y])
                children();
    }
}

module grill(width, height, r = 1000, poly = false, h = 0) { //! A staggered array of 5mm holes to make grills in sheets. Can be constrained to be circular. Set `poly` `true` for printing, `false` for milling.
    extrude_if(h)
        if(poly)
            grill_hole_positions(width, height, r)
                poly_circle(r = grill_hole / 2);
        else
            grill_hole_positions(width, height, r)
                circle(d = grill_hole);
}

module box_corner_profile_2D(type) { //! The 2D shape of the corner profile.
    t = box_sheet_slot(type);
    inset = box_corner_gap(type) + box_profile_overlap(type);
    difference() {
        union() {
            quadrant(box_hole_inset(type) + box_boss_r(type), box_boss_r(type));     // inside corner

            translate([inset, inset])
                rotate(180)
                    quadrant(box_profile_overlap(type) + box_corner_rad(type), box_corner_rad(type)); // outside corner
        }
        translate([box_corner_gap(type), -t + sheet_slot_clearance / 2])
            square([100, t]);

        translate([-t + sheet_slot_clearance / 2, box_corner_gap(type)])
            square([t, 100]);
    }
}

module box_corner_profile(type) { //! Generates the corner profile STL for 3D printing.
    length = box_height(type) - 2 * box_margin(type);

    stl("box_corner_profile")
        difference() {
            linear_extrude(length, center = true, convexity = 5)
                box_corner_profile_2D(type);

            for(z = [-1, 1])
                translate([box_hole_inset(type), box_hole_inset(type), z * length / 2])
                    insert_hole(box_insert(type), 5);
        }
}

module box_corner_profile_section(type, section, sections) { //! Generates interlocking sections of the corner profile to allow it to be taller than the printer
    overlap = 4;
    length = box_height(type) - 2 * box_margin(type);
    section_length = round_to_layer((length - overlap) / sections);
    last_section = section >= sections - 1;
    h = last_section ? length - (sections - 1) * section_length : section_length;
    overlap_wall = 2;

    difference() {
        union() {
            linear_extrude(h, convexity = 5)
                box_corner_profile_2D(type);

            if(!last_section)                              // male end always at the top
                translate_z(section_length - 1)
                    for(i = [0 : 1], offset = i * layer_height)
                        linear_extrude(overlap + 1 - offset)
                            offset(1 + offset - layer_height)
                                offset(-overlap_wall - 1)
                                    box_corner_profile_2D(type);
        }
        if(section > 0)
            translate_z(last_section ? h : 0) {       // female at bottom unless last section
                linear_extrude(2 * (overlap + layer_height), center = true, convexity = 5)
                    offset(-overlap_wall)
                        box_corner_profile_2D(type);

                linear_extrude(2 * layer_height, center = true, convexity = 5)
                    offset(-overlap_wall + layer_height)
                        box_corner_profile_2D(type);
            }
        if(!section || last_section)                        // insert holes always at the bottom
            translate([box_hole_inset(type), box_hole_inset(type)])
                insert_hole(box_insert(type), 5);
    }
}

module box_corner_profile_sections(type, section, sections) { //! Generate four copies of a corner profile section
    stl("box_corner_profile");
    offset = box_boss_r(type) + 1;
    for(i = [0 : 3])
        rotate(i * 90)
            translate([offset, offset])
                box_corner_profile_section(type, section, sections);
}

module box_corner_quadrants(type, width, depth)
    for(corner = [0:3]) {
        x = [-1,1,1,-1][corner];
        y = [-1,-1,1,1][corner];

        translate([x * width / 2, y * depth / 2, 0])
            rotate(corner * 90)
                quadrant(box_intrusion(type), box_boss_r(type));
    }

module box_bezel(type, bottom) { //! Generates top and bottom bezel STLs
    feet = bottom && box_feet(type);
    t = box_sheet_slot(type);
    outset =  box_outset(type);
    inset = box_inset(type);
    inner_r = box_sheet_r(type);
    cgap = box_corner_gap(type);
    foot_height = cgap + sheet_thickness(box_base_sheet(type)) + washer_thickness(box_washer(type)) + screw_head_height(box_screw(type)) + box_profile_overlap(type) + 2;
    foot_length = box_corner_rad(type) * 2;
    height = box_bezel_height(type, bottom);
    foot_extension = foot_height - height;

    stl(bottom ? "bottom_bezel" : "top_bezel")
        difference() {
            w = box_width(type);
            d = box_depth(type);
            translate_z(-box_profile_overlap(type)) difference() {
                tw = w + 2 * outset;
                td = d + 2 * outset;
                rounded_rectangle([tw, td, feet ? foot_height : height], box_corner_rad(type));
                //
                // Remove edges between the feet
                //
                if(feet)
                    hull() {
                        translate_z(height + 0.5)
                            cube([w - 2 * foot_length, td + 1, 1], center = true);

                        translate_z(foot_height + 1)
                            cube([w - 2 * (foot_length - foot_extension), td + 1, 1], center = true);
                    }
                if(feet)
                    hull() {
                        translate_z(height + 0.5)
                            cube([tw + 1, d - 2 * foot_length, 1], center = true);

                        translate_z(foot_height + 1)
                            cube([tw + 1, d - 2 * (foot_length - foot_extension), 1], center = true);
                    }
            }
            //
            // slots for side panels
            //
            translate_z(-box_profile_overlap(type))
                linear_extrude(2 * box_profile_overlap(type), center = true)
                    for(i = [-1, 1]) {
                        translate([i * (w + t - sheet_slot_clearance) / 2, 0])
                             square([t, d - 2 * cgap], center = true);

                        translate([0, i * (d + t - sheet_slot_clearance) / 2])
                             square([w - 2 * cgap, t], center = true);
                    }
            //
            // recess for top / bottom panel
            //
            translate_z(cgap)
                rounded_rectangle([w + bezel_clearance, d + bezel_clearance, height], inner_r + bezel_clearance / 2);
            //
            // leave plastic over the corner profiles
            //
            translate_z(-box_profile_overlap(type) - 1)
                linear_extrude(box_profile_overlap(type) + cgap + 2)
                    union() {
                        difference() {
                            square([w - 2 * inset,
                                    d - 2 * inset], center = true);

                            box_corner_quadrants(type, w, d);
                        }
                        box_screw_hole_positions(type)
                            poly_circle(screw_clearance_radius(box_screw(type)));
                    }
         }
}

dowel_length = 20;
dowel_wall = extrusion_width * 3;
dowel_h_wall = layer_height * 6;

module box_bezel_section(type, bottom, rows, cols, x, y) { //! Generates interlocking sections of the bezel to allow it to be bigger than the printer
    tw = box_width(type) + 2 * box_outset(type);
    w = tw / cols;
    th = box_depth(type) + 2 * box_outset(type);
    h = th / rows;
    bw = box_outset(type) - bezel_clearance / 2;
    bw2 = box_outset(type) + box_inset(type);

    dw = bw - 2 * dowel_wall;
    dh = box_bezel_height(type, bottom) - dowel_h_wall;

    profile_overlap = box_profile_overlap(type);

    dh2 = profile_overlap + box_corner_gap(type) - dowel_h_wall;

    end_clearance = 0.5;
    module male() {
        rotate([90, 0, 90])
            linear_extrude(dowel_length - 2 * end_clearance, center = true)
                difference() {
                    union() {
                        h1 = dh - layer_height;
                        h2 = dh2 - layer_height;
                        hull() {
                            translate([bw / 2, h1 / 2])
                                square([dw - 1, h1], center = true);

                            translate([bw / 2, (h1 - 1) / 2])
                                square([dw, h1 - 1], center = true);
                        }

                        hull() {
                            translate([bw2 / 2, h2 / 2])
                                square([bw2 - 2 * dowel_wall - 1, h2], center = true);

                            translate([bw2 / 2, (h2 - 1) / 2])
                                square([bw2 - 2 * dowel_wall, h2 - 1], center = true);
                        }
                    }
                    translate([bw2 / 2, 0])
                        square([box_sheet_slot(type), 2 * profile_overlap], center = true);
                }
    }

    module female() {
        union() {
            translate([0, bw / 2, dh / 2])
                cube([dowel_length, dw, dh], center = true);

            translate([0, bw2 / 2])
                cube([dowel_length, bw2 - 2 * dowel_wall, dh2 * 2], center = true);

            hull() {
                translate([0, bw / 2, dh / 2])
                    cube([2, dw, dh], center = true);

                translate([0, bw / 2, dh / 2])
                    cube([eps, dw + 2 * extrusion_width, dh], center = true);

            }
            hull() {
                translate([0, bw2 / 2, dh2 / 2])
                    cube([2, bw2 - 2 * dowel_wall, dh2], center = true);

                translate([0, bw2 / 2, dh2 / 2])
                    cube([eps, bw2 - 2 * dowel_wall + 2 * extrusion_width, dh2], center = true);

            }
        }
    }

    module support() {
        if(!$preview)
            translate([0, bw / 2 + dw / 2])
                cube([dowel_length / 2 - 0.25, 2 * extrusion_width + 0.2, dh2]);
    }

    union() {
        render() difference() {
            union() {
                clip(xmin = 0, xmax = w, ymin = 0, ymax = h)
                    translate([tw / 2 - x * w, th / 2 - y * h, profile_overlap])
                        box_bezel(type, bottom);

                if(x < cols - 1 && y == 0)
                    translate([w, 0])
                        male();

                if(x > 0 && y == rows - 1)
                    translate([0, h])
                        rotate(180)
                            male();

                if(y < rows - 1 && x == cols - 1)
                    translate([w, h])
                        rotate(90)
                            male();

                if(y > 0 && x == 0)
                    rotate(-90)
                        male();
            }

            if(x < cols - 1 && y == rows - 1)
                translate([w, h])
                    rotate(180)
                        female();

            if(x > 0 && y == 0)
                female();

            if(y < rows - 1 && x == 0)
                translate([0, h])
                    rotate(-90)
                        female();

            if(y > 0 && x == cols - 1)
                translate([w, 0])
                    rotate(90)
                        female();
        }
        if(x < cols - 1 && y == rows - 1)
            translate([w, h])
                rotate(180)
                    support();

        if(x > 0 && y == 0)
            support();

        if(y < rows - 1 && x == 0)
            translate([0, h])
                rotate(-90)
                    support();

        if(y > 0 && x == cols - 1)
            translate([w, 0])
                rotate(90)
                    support();
    }
}

module box_screw_hole_positions(type) {
    inset = box_hole_inset(type);
    w = box_width(type) / 2 - inset;
    d = box_depth(type) / 2 - inset;
    for(x = [-1, 1], y = [-1, 1])
        translate([x * w, y * d])
            children();
}

module box_base_blank(type) { //! Generates a 2D template for the base sheet
    dxf("box_base");

    difference() {
        sheet_2D(box_base_sheet(type), box_width(type), box_depth(type), box_sheet_r(type));

        box_screw_hole_positions(type)
            drill(screw_clearance_radius(box_screw(type)), 0);
    }
}

module box_top_blank(type) {  //! Generates a 2D template for the top sheet
    dxf("box_top");

    difference() {
        sheet_2D(box_top_sheet(type), box_width(type), box_depth(type), box_sheet_r(type));

        box_screw_hole_positions(type)
            drill(screw_clearance_radius(box_screw(type)), 0);
    }
}

function subst_sheet(type, sheet) =
    let(s = box_sheets(type))
        sheet ? assert(sheet_thickness(sheet) == sheet_thickness(s)) sheet : s;

module box_shelf_blank(type, sheet = false) { //! Generates a 2D template for a shelf sheet
    dxf("box_shelf");

    difference() {
        sheet_2D(subst_sheet(type, sheet), box_width(type) - bezel_clearance, box_depth(type) - bezel_clearance, 1);

        offset(bezel_clearance / 2)
            box_corner_quadrants(type, box_width(type), box_depth(type));
    }
}

module box_shelf_screw_positions(type, screw_positions, thickness = 0, wall = undef) { //! Place children at the shelf screw positions
    w = is_undef(wall) ? box_wall(type) : wall;
    insert = box_shelf_insert(type);
    translate_z(-insert_boss_radius(insert, w))
        for(p = screw_positions)
            multmatrix(p)
                translate_z(thickness)
                    children();
}

module box_shelf_bracket(type, screw_positions, wall = undef) { //! Generates a shelf bracket, the first optional child is a 2D cutout and the second 3D cutouts
    w = is_undef(wall) ? box_wall(type) : wall;
    insert = box_shelf_insert(type);
    lip = 2 * insert_boss_radius(insert, w);
    width = insert_length(insert) + w;

    module shape()
        difference() {
            square([box_width(type), box_depth(type)], center = true);

            offset(bezel_clearance / 2)
                box_corner_quadrants(type, box_width(type), box_depth(type));

            if($children)
                hflip()
                    children();
        }

    module boss()
        translate_z(-width + eps)
            linear_extrude(width - 2 * eps)
                hull() {
                    circle4n(r = lip / 2 - eps);

                    translate([-lip / 2, -lip / 2 + eps])
                        square([lip, eps]);
                }

    stl("shelf_bracket")
        difference() {
            union() {
                linear_extrude(w)
                    difference() {
                        shape()
                            if($children)
                                children(0);

                        round(2) offset(-width)
                            shape()
                                if($children)
                                    children(0);
                    }

                linear_extrude(lip)
                    difference() {
                        shape()
                            if($children)
                                children(0);

                        offset(-w)
                            shape()
                                if($children)
                                    children(0);
                    }

                hflip()
                    box_shelf_screw_positions(type, screw_positions, 0, w)
                        boss();
            }
            if($children > 1)
                hflip()
                    children(1);

            hflip()
                box_shelf_screw_positions(type, screw_positions, 0, w)
                    insert_hole(insert, counterbore = 1, horizontal = true);
        }
}

module box_shelf_bracket_section(type, rows, cols, x, y) { //! Generates sections of the shelf bracket to allow it to be bigger than the printer
    tw = box_width(type);
    w = tw / cols;
    th = box_depth(type);
    h = th / rows;

    clip(xmin = 0, xmax = w, ymin = 0, ymax = h)
        translate([tw / 2 - x * w, th / 2 - y * h])
            children();
}

module box_left_blank(type, sheet = false) { //! Generates a 2D template for the left sheet, `sheet` can be set to override the type
    dxf("box_left");

    sheet_2D(subst_sheet(type, sheet), box_depth(type) - sheet_reduction(type), box_height(type) - sheet_reduction(type), 1);
}

module box_right_blank(type, sheet = false) { //! Generates a 2D template for the right sheet, `sheet` can be set to override the type
    dxf("box_right");

    sheet_2D(subst_sheet(type, sheet), box_depth(type) - sheet_reduction(type), box_height(type) - sheet_reduction(type), 1);
}

module box_front_blank(type, sheet = false) { //! Generates a 2D template for the front sheet, `sheet` can be set to override the type
    dxf("box_front");

    sheet_2D(subst_sheet(type, sheet), box_width(type) - sheet_reduction(type), box_height(type) - sheet_reduction(type), 1);
}

module box_back_blank(type, sheet = false) { //! Generates a 2D template for the back sheet, `sheet` can be set to override the type
    dxf("box_back");

    sheet_2D(subst_sheet(type, sheet), box_width(type) - sheet_reduction(type), box_height(type) - sheet_reduction(type), 1);
}

module box_base(type)  render_2D_sheet(box_base_sheet(type)) box_base_blank(type);  //! Default base, can be overridden to customise
module box_top(type)   render_2D_sheet(box_top_sheet(type))  box_top_blank(type);   //! Default top, can be overridden to customise
module box_back(type)  render_2D_sheet(box_sheets(type))     box_back_blank(type);  //! Default back, can be overridden to customise
module box_front(type) render_2D_sheet(box_sheets(type))     box_front_blank(type); //! Default front, can be overridden to customise
module box_left(type)  render_2D_sheet(box_sheets(type))     box_left_blank(type);  //! Default left side, can be overridden to customise
module box_right(type) render_2D_sheet(box_sheets(type))     box_right_blank(type); //! Default right side, can be overridden to customise
