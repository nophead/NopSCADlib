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
//! The "Soft" parameter can be used to determine if the sheet material needs machine screws or wood screws, e.g.:
//!
//! * If soft, wood screws will be used, with a pilot hole.
//! * If not soft, either tapped holes or a clearance hole and nuts will be used to retain screws.
//!
//! The "Colour" parameter is a quad-array: [R, G, B, Alpha], or can be a named colour, see [OpenSCAD_User_Manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#color).
//!
//! For speed sheets should be modelled in 2D by subtracting holes from 2D templates made by `sheet_2D()` and then extruded to 3D with `render_2D_sheet()`.
//! Note that modules that drill holes will return a 2D object if `h` is set to 0 to facilitate this.
//!
//! If 3D features are needed, for example countersinks, then sheets can be modelled in 3D using `sheet()` and then coloured with `render_sheet()`.
//!
//! When woven sheets (e.g. carbon fibre) are rendered it is necessary to specify the dimensions again to `render_sheet()` or `render_2D_sheet()`.
//
include <../utils/core/core.scad>

function sheet_thickness(type) = type[2]; //! Thickness
function sheet_colour(type)    = type[3]; //! Colour
function sheet_is_soft(type)   = type[4]; //! Is soft enough for wood screws
function sheet_is_woven(type)  = !is_undef(type[5]); //! Is a woven sheet, eg carbon fiber
function sheet_warp(type)      = type[5]; //! Woven sheet warp
function sheet_weft(type)      = type[6]; //! Woven sheet weft
function sheet_colour2(type)   = type[7]; //! Second colour for a woven sheet

module corner(r) {
    if(r > 0)
        translate([r, -r])
            circle4n(r);
    else
        if(r < 0)
            translate([-r, r])
                rotate(45)
                    square([-r * sqrt(2), -r * sqrt(2)], center = true);
        else
            translate([0.5, -0.5])
                square(1, center = true);
}

module sheet_2D(type, w, d, corners = [0, 0, 0, 0]) { //! 2D sheet template with specified size and optionally rounded corners
    t = sheet_thickness(type);
    vitamin(str("sheet(", type[0], ", ", w, ", ", d, arg(corners, [0, 0, 0, 0]), "): ", type[1], " ",  round(w), "mm x ", round(d), "mm x ", t, "mm"));

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

module sheet(type, w, d, corners = [0, 0, 0, 0]) //! Draw specified sheet
    linear_extrude(sheet_thickness(type), center = true)
        sheet_2D(type, w, d, corners);

module render_sheet(type, colour = false, colour2 = false, w = undef, d = undef) { //! Render a sheet in the correct colour after holes have been subtracted
    woven = sheet_is_woven(type);
    t = sheet_thickness(type);
    colour = colour ? colour : sheet_colour(type);
    colour2 = colour2 ? colour2 : sheet_colour2(type);
    let($dxf_colour = colour)
        color(woven ? colour2 : colour)
            render()
                scale([1, 1, woven ? (t - 2 * eps) / t : 1])
                    children();

    if(woven)
        for(side = [-1, 1], z = side * (t - eps) / 2)
            translate_z(z)
                woven_sheet(type, eps, colour, colour2, w, d)
                    projection(cut = true)
                        translate_z(-z)
                            not_on_bom()
                                children();
}

module render_2D_sheet(type, colour = false, colour2 = false, w = undef, d = undef) { //! Extrude a 2D sheet template and give it the correct colour
    colour = colour ? colour : sheet_colour(type);
    colour2 = colour2 ? colour2 : sheet_colour2(type);
    let($dxf_colour = colour)
        if(sheet_is_woven(type))
            woven_sheet(type, sheet_thickness(type), colour, colour2, w, d)
                children();
        else
            color($dxf_colour)
                linear_extrude(sheet_thickness(type), center = true)
                    children();
}

module woven_sheet(type, thickness, colour, colour2, w, d) { // Create a woven 2D sheet with specified thickness and colours
    warp = sheet_warp(type);
    weft = sheet_weft(type);
    warp_doublet_count = assert(!is_undef(w) && !is_undef(d), "Must specify the dimensions to render woven sheets") ceil(w / (2 * warp));
    weft_count = ceil(d / weft);

    module chequerboard(odd = 0)
        translate([-w / 2, -d / 2])
            for (y = [0 : weft_count - 1], x = [0 : warp_doublet_count - 1])
                translate([warp * (2 * x + ((y + odd) % 2)), weft * y])
                    square([warp, weft]);

    color(colour)
        linear_extrude(thickness)
            intersection() {
                chequerboard();
                children();
            }

    if(thickness > eps)
        color(colour2)
            linear_extrude(thickness)
                intersection() {
                    chequerboard(1);

                    not_on_bom()
                        children();
                }
}
