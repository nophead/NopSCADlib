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
include <../utils/fillet.scad>

function sheet_thickness(type) = type[2]; //! Thickness
function sheet_colour(type)    = type[3]; //! Colour
function sheet_is_soft(type)   = type[4]; //! Is soft enough for wood screws
function sheet_is_woven(type)  = !is_undef(type[5]); //! Is a woven sheet, eg carbon fiber

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

module sheet(type, w, d, corners = [0, 0, 0, 0], texture = false) //! Draw specified sheet
    if (sheet_is_woven(type))
        difference() {
            t = sheet_thickness(type);
            woven_sheet([w, d, t], center = true, texture = texture, warp = type[5], weft = type[6], colour2 = type[7]);
            c = is_list(corners) ? corners : corners * [1, 1, 1, 1];
            translate([-w/2,  d/2, -t / 2 -eps])
                rotate(-90)
                    fillet(c[0], t + 2 * eps);
            translate([ w/2,  d/2, -t / 2 -eps])
                rotate(180)
                    fillet(c[1], t + 2 * eps);
            translate([ w/2, -d/2, -t / 2 -eps])
                rotate(90)
                    fillet(c[2], t + 2 * eps);
            translate([-w/2, -d/2, -t / 2 -eps])
                fillet(c[3], t + 2 * eps);
        }
    else
        linear_extrude(sheet_thickness(type), center = true)
            sheet_2D(type, w, d, corners);

module render_sheet(type, colour = false) //! Render a sheet in the correct colour after holes have been subtracted
    color(colour ? colour : sheet_colour(type))
        render() children();

module render_2D_sheet(type, colour = false) //! Extrude a 2D sheet template and give it the correct colour
    let($dxf_colour = colour ? colour : sheet_colour(type))
        color($dxf_colour)
            linear_extrude(sheet_thickness(type), center = true)
                children();

module woven_sheet(size, center = true, colour = grey(30), texture = false, warp = 2, weft, colour2) {//! Create a woven sheet with specified size, colours, warp and weft
    colour2 = colour2 ? colour2 : colour * 0.8;
    weft = weft ? weft : warp;
    warp_doublet_count = floor(size.x / (2 * warp));

    eps = texture ? 1 / 64 : 0;
    module layer(weft, swap_colours) {
        if (warp_doublet_count > 0)
            for (x = [0 : warp_doublet_count - 1]) {
                translate([2 * x * warp, 0, 0])
                    color(swap_colours ? colour2 : colour)
                        linear_extrude(size.z - (swap_colours ? eps : 0))
                            square([warp, weft]);
                translate([(2 * x + 1) * warp, 0, 0])
                    color(swap_colours ? colour : colour2)
                        linear_extrude(size.z - (swap_colours ? 0 : eps))
                            square([warp, weft]);
            }
        remainder = size.x - 2 * warp * warp_doublet_count;
        if (remainder)
            translate([2 * warp_doublet_count * warp, 0, 0])
                color(swap_colours ? colour2 : colour)
                    linear_extrude(size.z - (swap_colours ? eps : 0))
                        square([min(remainder,warp), weft]);
        if (remainder>warp)
            translate([(2 * warp_doublet_count + 1) * warp, 0, 0])
                color(swap_colours ? colour : colour2)
                    linear_extrude(size.z - (swap_colours ? 0 : eps))
                        square([min(remainder-warp,warp), weft]);
    }

    weft_count = floor(size.y / weft);
    translate(center ? [-size.x / 2, -size.y / 2, -size.z / 2] : [0, 0, 0]) {
        if (weft_count > 0)
            for (y = [0 : weft_count - 1])
                translate([0, y * weft, 0])
                    layer(weft, floor(y / 2) * 2 == y);
        remainder = size.y - weft * weft_count;
        if (remainder)
            translate([0, weft_count * weft, 0])
                layer(remainder, floor(weft_count/2)*2 == weft_count);
    }
}

