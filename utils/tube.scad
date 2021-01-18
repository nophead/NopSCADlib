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
//! Simple tube or ring
//
include <../utils/core/core.scad>

module ring(or, ir) //! Create a ring with specified external and internal radii
        difference() {
            circle4n(or);
            circle4n(ir);
        }

module tube(or, ir, h, center = true) //! Create a tube with specified external and internal radii and height `h`
    linear_extrude(h, center = center, convexity = 5)
        ring(or, ir);

module woven_tube(or, ir, h, center= true, colour = grey(30), colour2, warp = 2, weft) {//! Create a woven tube with specified external and internal radii, height `h`, colours, warp and weft
    colour2 = colour2 ? colour2 : colour * 0.8;
    weft = weft ? weft : warp;
    warp_count = max(floor(PI * or / warp), 0.5);
    angle = 360 / (2 * warp_count);

    module layer(weft) {
        points = [[ir, weft / 2], [or, weft / 2], [or, -weft / 2], [ir, -weft / 2]];
        color(colour)
            for (i = [0 : warp_count])
                rotate(2 * i * angle)
                    rotate_extrude(angle = angle)
                        polygon(points);
        color(colour2)
            for (i = [0 : warp_count])
                rotate((2 * i + 1) * angle)
                    rotate_extrude(angle = angle)
                        polygon(points);
    }

    translate_z(center ? -h / 2 : 0) {
        weft_count = floor(h / weft);
        if (weft_count > 0)
            for (i = [0 : weft_count - 1]) {
                translate_z(i * weft + weft / 2)
                    rotate(i * angle)
                        layer(weft);
        }
        remainder = h - weft * weft_count;
        if (remainder) {
            translate_z(weft_count * weft + remainder / 2)
                rotate(weft_count * angle)
                    layer(remainder);
        }
    }
}

module rectangular_tube(size, center = true, thickness = 1, fillet = 0.5) { //! Create a retangular tube with filleted corners
    extrude_if(size.z, center = center)
        difference() {
            rounded_square([size.x, size.y], fillet);
            rounded_square([size.x - 2 * thickness, size.y - 2 * thickness], fillet);
        }
}
