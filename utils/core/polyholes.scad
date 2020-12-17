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
//
function sides(r) = max(round(4 * r), 3);                                       //! Optimium number of sides for specified radius
function corrected_radius(r, n = 0)   = r / cos(180 / (n ? n : sides(r)));      //! Adjusted radius to make flats lie on the circle
function corrected_diameter(d, n = 0) = d / cos(180 / (n ? n : sides(d / 2)));  //! Adjusted diameter to make flats lie on the circle

module poly_circle(r, sides = 0) { //! Make a circle adjusted to print the correct size
    n = sides ? sides : sides(r);
    circle(r = corrected_radius(r,n), $fn = n);
}

module poly_cylinder(r, h, center = false, sides = 0, chamfer = false, rotating = false) {//! Make a cylinder adjusted to print the correct size
    if (rotating) {
        sides = sides ? sides : sides(r);
        layers = floor(h / layer_height);
        lh = layer_height + eps;
        for(i = [0 : layers - 1])
            translate_z(i * layer_height + (center ? -h / 2 : 0))
                rotate(i * 180 / layers)
                    poly_cylinder(r = r, h = lh, center = false, sides = sides, rotating = false);
    } else {
        extrude_if(h, center)
            poly_circle(r, sides);
    }

    if(h && chamfer)
        poly_cylinder(r + layer_height, center ? layer_height * 2 : layer_height, center, sides = sides ? sides : sides(r));
}

module poly_ring(or, ir, sides = 0) { //! Make a 2D ring adjusted to have the correct internal radius
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
        drill(r, h, center = true);
    else
        poly_cylinder(r, h, center);

//
// Horizontal slot
//
module slot(r, l, h = 100) //! Make a horizontal slot suitable for CNC routing, set h = 0 for 2D version
    extrude_if(h)
        hull() {
            translate([l / 2,0])
                drill(r, 0);

            translate([-l / 2,0])
                drill(r, 0);
        }
