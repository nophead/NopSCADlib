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
//! A method of making 3D printed holes come out the right size regardless of the printer, providing
//! it gets the linear dimensions right. See <https://hydraraptor.blogspot.com/2011/02/polyholes.html>
//!
//! The module provides `poly_circle()`, `poly_cylinder()` and `poly_ring()` that is useful for making printed washers and pillars.
//!
//! `poly_cylinder()` has a `twist` parameter which can be set to make the polygon rotate each layer.
//! This can be used to mitigate the number of sides being small and make small holes stronger and more round, but is quite slow due to the
//! large increase in the number of facets.
//! When set to 1 the polygons alternate each layer, when set higher the rotation takes `twist + 1` layers to repeat.
//! A small additional rotation is added to make the polygon rotate one more side over the length of the hole to make it appear round when
//! viewed end on.
//!
//! When `twist` is set the resulting cylinder is extended by `eps` at each end so that the exact length of the hole can be used without
//! leaving a scar on either surface.
//
function sides(r, n = undef) = is_undef(n) ? max(round(4 * r), 3) : n ? max(n, 3) : r2sides(r); //! Optimum number of sides for specified radius
function corrected_radius(r, n = undef)   = r / cos(180 / sides(r, n));                         //! Adjusted radius to make flats lie on the circle
function corrected_diameter(d, n = undef) = 2 * corrected_radius(d / 2 , n);                    //! Adjusted diameter to make flats lie on the circle

module poly_circle(r, sides = undef) { //! Make a circle adjusted to print the correct size
    n = sides(r, sides);
    circle(r = corrected_radius(r, n), $fn = n);
}

module poly_cylinder(r, h, center = false, sides = undef, chamfer = false, twist = 0) {//! Make a cylinder adjusted to print the correct size
    if(twist) {
        slices = ceil(h / layer_height);
        twists = min(twist + 1, slices);
        sides = sides(r, sides);
        rot = 360 / sides / twists * (twists < slices ? (1 + 1 / slices) : 1);
        if(center)
            for(side = [0, 1])
                mirror([0, 0, side])
                    poly_cylinder(r = r, h = h / 2, sides = sides, twist = twist);
        else
            render(convexity = 5)
                for(i = [0 : slices - 1])
                    translate_z(i * layer_height - eps)
                        rotate(rot * i)
                            poly_cylinder(r = r, h = layer_height + 2 * eps, sides = sides);
    }
    else
        extrude_if(h, center)
            poly_circle(r, sides);

    if(h && chamfer)
        poly_cylinder(r + layer_height, center ? layer_height * 2 : layer_height, center, sides = sides(r, sides));
}

module poly_ring(or, ir, sides = undef) { //! Make a 2D ring adjusted to have the correct internal radius
    cir = corrected_radius(ir, sides);
    filaments = (or - cir) / extrusion_width;
    if(filaments > 3 + eps)
        difference() {
            circle(or);

            poly_circle(ir, sides);
        }
    else
        if(filaments >= 2)
            difference() {
                offset(or - cir)
                    poly_circle(ir, sides);

                poly_circle(ir, sides);
            }
            else
                difference() {
                    poly_circle(or, sides);

                    offset(-squeezed_wall)
                        poly_circle(or, sides);
                }
}

module poly_tube(or, ir, h, center = false) //! Make a tube adjusted to have the correct internal radius
    extrude_if(h, center)
        poly_ring(or, ir);

module drill(r, h = 100, center = true) //! Make a cylinder for drilling holes suitable for CNC routing, set h = 0 for circle
    extrude_if(h, center)
        circle(r = corrected_radius(r, r2sides(r)));

module poly_drill(r, h = 100, center = true) //! Make a cylinder for drilling holes suitable for CNC routing if cnc_bit_r is non zero, otherwise a poly_cylinder.
    if(cnc_bit_r)
        drill(r, h, center = center);
    else
        poly_cylinder(r, h, center);

//
// Horizontal slot
//
module slot(r, l, h = 100, center = false) //! Make a horizontal slot suitable for CNC routing, set h = 0 for 2D version
    extrude_if(h, center)
        hull() {
            translate([l / 2,0])
                drill(r, 0);

            translate([-l / 2,0])
                drill(r, 0);
        }
