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
//! Sheet materials. Rectangular with optional rounded corners. Negative radii make a chamfer.
//!
//! The "Soft" parameter can be used to determinesif the sheet material needs machine screws or wood screws, e.g.:
//!
//! * If soft, wood screws will be used, with a pilot hole.
//! * If not soft, either tapped holes or a clearance hole and nuts will be used to retain screws.
//!
//! The "Colour" parameter is a quad-array: [R, G, B, Alpha], or can be a named colour, see [OpenSCAD_User_Manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#color).
//!
//! For speed sheets should be modelled in 2D by subtracting holes from 2D templates made by ```sheet_2D()``` and then extruded to 3D with ```render_2D_sheet()```.
//! Note that modules that drill holes will return a 2D object if ```h``` is set to 0 to facilitate this.
//
include <../utils/core/core.scad>

function sheet_thickness(type) = type[2]; //! Thickness
function sheet_colour(type)    = type[3]; //! Colour
function sheet_is_soft(type)   = type[4]; //! Is soft enough for wood screws
function sheet_is_woven(type)  = !is_undef(type[5]); //! Is a woven sheet, eg carbon fiber
function sheet_colour2(type)   = is_undef(type[7]) ? sheet_colour(type) * 0.8 : type[7]; //! Second colour for a woven sheet

module corner(r) {
    if(r > 0)
        translate([r, -r])
            circle4n(r);
    else
        if(r < 0)
            translate([-r, r])
                rotate(45)
                    square(-r * sqrt(2), -r * sqrt(2), center = true);
        else
            translate([0.5, -0.5])
                square(1, center = true);
}

module corner_hull(w, d, corners) {
    c = is_list(corners) ? corners : corners * [1, 1, 1, 1];

    hull() {
        translate([-w/2,  d/2])
            corner(c[0]);

        translate([ w/2,  d/2])
            rotate(-90)
                corner(c[1]);

        translate([ w/2, -d/2])
            rotate(-180)
                corner(c[2]);

        translate([-w/2, -d/2])
            rotate(-270)
                corner(c[3]);
    }
}

module sheet_2D(type, w, d, corners = [0, 0, 0, 0]) { //! 2D sheet template with specified size and optionally rounded corners
    t = sheet_thickness(type);
    vitamin(str("sheet(", type[0], ", ", w, ", ", d, arg(corners, [0, 0, 0, 0]), "): ", type[1], " ",  round(w), "mm x ", round(d), "mm x ", t, "mm"));

    if (sheet_is_woven(type)) {
        if (is_undef($sheet_woven_positive)) {
            // not being called from within render_2D_sheet, so do both colours
            color(sheet_colour(type))
                let($sheet_woven_positive = true)
                    woven_sheet_2D(type, w, d, corners);
            color(sheet_colour2(type))
                let($sheet_woven_positive = false)
                    woven_sheet_2D(type, w, d, corners);
        } else {
            // being called from within render_2D_sheet
            woven_sheet_2D(type, w, d, corners);
        }
    } else {
        color(sheet_colour(type))
            corner_hull(w, d, corners);
    }
}

module sheet(type, w, d, corners = [0, 0, 0, 0]) //! Draw specified sheet
    if (sheet_is_woven(type) && is_undef($sheet_woven_positive)) {
        // not being called from within render_3D_sheet, so do both colours
        color(sheet_colour(type))
            linear_extrude(sheet_thickness(type), center = true)
                let($sheet_woven_positive = true)
                    woven_sheet_2D(type, w, d, corners);
        color(sheet_colour2(type))
            linear_extrude(sheet_thickness(type), center = true)
                let($sheet_woven_positive = false)
                    woven_sheet_2D(type, w, d, corners);
    } else {
        color(sheet_colour(type))
            linear_extrude(sheet_thickness(type), center = true)
                sheet_2D(type, w, d, corners);
    }


module render_sheet(type, colour = false, colour2 = false) { //! Render a sheet in the correct colour after holes have been subtracted
    color(colour ? colour : sheet_colour(type))
        render()
            let($sheet_woven_positive = true)
                children();

    if (sheet_is_woven(type))
        color(colour2 ? colour2 : sheet_colour2(type))
            render()
                let($sheet_woven_positive = false)
                    children();
}

module render_2D_sheet(type, colour = false, colour2 = false) { //! Extrude a 2D sheet template and give it the correct colour
    let($dxf_colour = colour ? colour : sheet_colour(type))
        color($dxf_colour)
            let($sheet_woven_positive = true)
                linear_extrude(sheet_thickness(type), center = true)
                    children();

    if (sheet_is_woven(type))
        color(colour2 ? colour2 : sheet_colour2(type))
            let($sheet_woven_positive = false)
                linear_extrude(sheet_thickness(type), center = true)
                    children();
}

module woven_sheet_2D(type, w, d, corners = [0, 0, 0, 0], warp = 2, weft) {//! Create a woven 2D sheet with specified size, colours, warp and weft
    size = [w, d];

    weft = weft ? weft : warp;
    warp_doublet_count = floor(size.x / (2 * warp)) + 1;

    module layer(weft) {
        for (x = [0 : warp_doublet_count - 1])
            translate([2 * x * warp, 0, 0])
                square([warp, weft]);
    }

    module positive() {
        intersection() {
            translate([-size.x / 2, -size.y / 2]) {
                weft_count = floor(size.y / weft) + 1;
                for (y = [0 : weft_count - 1])
                    translate([warp * (y % 2), weft * y, 0])
                        layer(weft);
            }
            corner_hull(w, d, corners);
        }
    }

    module negative() {
        difference() {
            corner_hull(size.x, size.y, corners);
            positive();
        }
    }

    if (is_undef($sheet_woven_positive) || $sheet_woven_positive==true)
        positive();
    else
        negative();
}

