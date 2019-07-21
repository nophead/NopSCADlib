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
//! The "Color" parameter is a quad-array: [R, G, B, Alpha], or can be a named color, see [OpenSCAD_User_Manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#color).
//!
//! For speed sheets should be modelled in 2D by subtracting holes from 2D templates made by ```sheet_2D()``` and then extruded to 3D with ```render_2D_sheet()```.
//! Note that modules that drill holes will return a 2D object if ```h``` is set to 0 to facilitate this.
//
include <../core.scad>

function sheet_thickness(type) = type[2]; //! Thickness
function sheet_colour(type)    = type[3]; //! Colour
function sheet_is_soft(type)   = type[4]; //! Is soft enough for wood screws

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

module sheet(type, w, d, corners = [0, 0, 0, 0]) //! Draw specified sheet
    linear_extrude(height = sheet_thickness(type), center = true)
        sheet_2D(type, w, d, corners);

module render_sheet(type, color = false) //! Render a sheet in the correct colour after holes have been subtracted
    color(color ? color : sheet_colour(type))
        render() children();

module render_2D_sheet(type, color = false) //! Extrude a 2D sheet template and give it the correct colour
    color(color ? color : sheet_colour(type))
        linear_extrude(height = sheet_thickness(type), center = true)
            children();
