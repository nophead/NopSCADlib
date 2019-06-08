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
//! Simple model of ball bearings with seals, the colour of which can be specified. If silver they are assumed to be metal and the
//! part number gets a ZZ suffix. Any other colour is assumed to be rubber and the suffix is -2RS.
//!
//! If a ball bearing has a child it is placed on its top surface, the same as nuts and washers, etc.
//!
//! Also single bearing balls are modelled as just a silver sphere and a BOM entry.
//
include <../core.scad>

function bb_name(type)     = type[0]; //! Part code without shield type suffix
function bb_bore(type)     = type[1]; //! Internal diameter
function bb_diameter(type) = type[2]; //! External diameter
function bb_width(type)    = type[3]; //! Width
function bb_colour(type)   = type[4]; //! Shield colour, "silver" for metal
function bb_rim(type)      = bb_diameter(type) / 10;  //! Inner and outer rim thickness

module ball_bearing(type) { //! Draw a ball bearing
    shield = bb_colour(type);
    suffix = shield == "silver" ? "ZZ " : "-2RS ";
    vitamin(str("ball_bearing(BB", bb_name(type), "): Ball bearing ", bb_name(type), suffix, bb_bore(type), "mm x ", bb_diameter(type), "mm x ", bb_width(type), "mm"));
    rim = bb_rim(type);
    h = bb_width(type);
    od = bb_diameter(type);
    id = bb_bore(type);

    module tube(od, id, h)
        linear_extrude(height = h, center = true, convexity = 5)
            difference() {
                circle(d = od);
                circle(d = id);
            }

    color("silver") {
        tube(od, od - rim, h);
        tube(id + rim, id, h);
    }

    color(shield) tube(od - rim, id + rim, h - 1);

    if($children)
        translate_z(bb_width(type) / 2)
            children();
}

module bearing_ball(dia) { //! Draw a steel bearing ball
    vitamin(str(" bearing_ball(", dia, "): Steel ball ", dia, "mm"));
    color("silver") sphere(d = dia);
}
