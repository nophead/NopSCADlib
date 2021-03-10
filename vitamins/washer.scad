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
//! Washers, star washers, penny washers and printed washers.
//!
//! If a washer is given a child, usually a screw or a nut, then it is placed on its top surface.
//
include <../utils/core/core.scad>
include <../utils/sweep.scad>

soft_washer_colour = grey(20);
hard_washer_colour = grey(80);
star_washer_colour = brass;

function washer_size(type)            = type[1]; //! Noiminal size
function washer_diameter(type)        = type[2]; //! External diameter
function washer_thickness(type)       = type[3]; //! Thickness
function washer_soft(type)            = type[4]; //! True if rubber
function star_washer_diameter(type)   = type[5]; //! Star version size
function spring_washer_diameter(type) = type[6]; //! Spring washer size
function spring_washer_thickness(type)= type[7]; //! Spring washer thickness
function penny_washer(type)           = type[8]; //! Corresponding penny washer
function washer_radius(type)          = washer_diameter(type) / 2; //! Outside radius

function washer_id(type) = washer_size(type) + 0.1; //! Inside diameter
function washer_colour(type) = washer_soft(type) ? soft_washer_colour : hard_washer_colour; //! Washer colour

module washer(type) { //! Draw specified washer
    hole = washer_size(type);
    thickness = washer_thickness(type);
    diameter  = washer_diameter(type);
    p = penny_washer(type);
    penny = !is_undef(p) && !is_list(p);
    if(washer_soft(type))
        vitamin(str("washer(", type[0], "_washer): Washer rubber M", hole, " x ", diameter, "mm x ", thickness, "mm"));
    else
        vitamin(str("washer(", type[0], "_washer): Washer ", penny ? "penny " : "", " M", hole, " x ", diameter, "mm x ", thickness, "mm"));
    color(washer_colour(type))
        linear_extrude( thickness - 0.05)
            difference() {
                circle(d = diameter);
                circle(d = washer_id(type));
            }

    if($children)
        translate_z(thickness)
            children();
}

module penny_washer(type) { //! Draw penny version of specified plain washer
    penny = penny_washer(type);
    assert(penny, "no penny version");
    washer(penny)
        children();
}

module star_washer(type) { //! Draw star version of washer
    hole = washer_size(type);
    thickness = washer_thickness(type);
    diameter  = star_washer_diameter(type);
    rad = diameter / 2;
    inner = (hole / 2 + rad) / 2;
    spoke  = rad - hole / 2;
    vitamin(str("star_washer(", type[0], "_washer): Washer star M", hole, " x ", thickness, "mm"));
    color(star_washer_colour)
        linear_extrude(thickness)
            difference() {
                circle(rad);

                circle(d = washer_id(type));

                for(a = [0:30:360])
                    rotate(a)
                        translate([inner + spoke / 2, 0, 0.5])
                            square([spoke, 2 * PI * inner / 36], center = true);
            }
    if($children)
        translate_z(thickness)
            children();
}

module spring_washer(type) { //! Draw spring version of washer
    hole = washer_size(type);
    thickness = spring_washer_thickness(type);
    diameter  = spring_washer_diameter(type);
    vitamin(str("spring_washer(", type[0], "_washer): Washer spring M", hole, " x ", thickness, "mm"));
    ir =  washer_id(type) / 2;
    or = diameter / 2;
    pitch = exploded() ? thickness / 2 : 0;
    path = circle_points((ir + or) / 2, pitch);
    profile = rectangle_points(thickness, or - ir);
    len = len(path);
    color(hard_washer_colour)
        translate_z(thickness / 2)
            rotate(-90)
                sweep(path, profile, twist = -helical_twist_per_segment(ir, pitch, len) * (len - 1));

    if($children)
        translate_z(thickness)
            children();
}

module printed_washer(type, name = false) { //! Create printed washer
    stl(name ? name : str("M", washer_size(type) * 10, "_washer"));
    t = round_to_layer(washer_thickness(type));
    or = washer_radius(type);
    ir = washer_id(type) / 2;
    stl_colour(pp1_colour)
        linear_extrude(t, center = false, convexity = 2)
            poly_ring(or, ir);

    if($children)
        translate_z(t)
            children();
}
