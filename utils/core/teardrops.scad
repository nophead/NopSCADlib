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
//! For making horizontal holes that don't need support material.
//! Small holes can get away without it, but they print better with truncated teardrops.
//!
//! Using teardrop_plus() or setting the plus option on other modules will elongate the teardrop vertically by the layer height, so when sliced the staircase tips
//! do not intrude into the circle. See <https://hydraraptor.blogspot.com/2020/07/horiholes-2.html>
//
module teardrop(h, r, center = true, truncate = true, chamfer = 0, chamfer_both_ends = true, plus = false) { //! For making horizontal holes that don't need support material, set `truncate = false` to make traditional RepRap teardrops that don't even need bridging
    module teardrop_2d(r, truncate) {
        er = layer_height / 2 - eps;    // Extrustion edge radius
        R = plus ? r + er : r;          // Corrected radius
        offset = plus ? -er : 0;        // Offset inwards
        hull()
            for(side = [0 : 1])
                mirror([side, 0, 0])
                    intersection() {
                        hull()
                        translate([offset, 0]) {
                            circle4n(R);

                            if(truncate)
                                translate([0, R / 2])
                                    square([2 * R * (sqrt(2) - 1), R], center = true);
                            else
                                polygon([[0, 0], [eps, 0], [0, R * sqrt(2)]]);
                        }
                        translate([0, -2 * R])
                            square([R, 4 * R]);
                    }
    }

    render(convexity = 5)
        extrude_if(h, center)
            teardrop_2d(r, truncate);

    teardrop_chamfer(h, center, chamfer, chamfer_both_ends) {
        linear_extrude(eps, center = true)
            teardrop_2d(r + chamfer / 2, truncate);

        translate_z(-chamfer / 2)
            linear_extrude(eps, center = true)
                teardrop_2d(r, truncate);
    }
}

module semi_teardrop(h, r, d = undef, center = true, chamfer = 0, chamfer_both_ends = true, plus = false) { //! A semi teardrop in the positive Y domain
    module semi_teardrop_2d(r, d)
        intersection() {
            R = is_undef(d) ? r : d / 2;
            teardrop(r = R, h = 0, plus = plus);

            sq = R + 1;
            translate([-sq, 0])
                square([2 * sq, sq]);
        }

    render(convexity = 5)
        extrude_if(h, center)
            semi_teardrop_2d(r, d);

    teardrop_chamfer(h, center, chamfer, chamfer_both_ends) {
        linear_extrude(eps, center = true)
            semi_teardrop_2d(r + chamfer / 2, d);

        translate_z(-chamfer / 2)
            linear_extrude(eps, center = true)
                semi_teardrop_2d(r, d);
    }
}

module teardrop_plus(h, r, center = true, truncate = true, chamfer = 0, chamfer_both_ends = true) //! Slightly elongated teardrop to allow for the 3D printing staircase effect
    teardrop(h, r, center, truncate, chamfer, chamfer_both_ends, plus = true);

module tearslot(h, r, w, center = true, chamfer = 0, chamfer_both_ends = true, plus = false) { //! A horizontal slot that doesn't need support material
    module tearslot_2d(r, w)
        hull()
            for(x = [-1, 1])
                translate([x * w / 2, 0]) teardrop(r = r, h = 0, plus = plus);

    extrude_if(h, center)
        tearslot_2d(r, w);

    teardrop_chamfer(h, center, chamfer, chamfer_both_ends) {
        linear_extrude(eps, center = true)
            tearslot_2d(r + chamfer / 2, w);

        translate_z(-chamfer / 2)
            linear_extrude(eps, center = true)
                tearslot_2d(r, w);
    }
}

module vertical_tearslot(h, r, l, center = true, chamfer = 0, chamfer_both_ends = true, plus = false) { //! A vertical slot that doesn't need support material
    module vertical_tearslot_2d(r, l)
        hull()
            for(y = [-1, 1])
                translate([0,  y * l / 2])
                    teardrop(0, r, true, plus = plus);

    extrude_if(h, center)
        vertical_tearslot_2d(r, l);

    teardrop_chamfer(h, center, chamfer, chamfer_both_ends) {
        linear_extrude(eps, center = true)
            vertical_tearslot_2d(r + chamfer / 2, l);

        translate_z(-chamfer / 2)
            linear_extrude(eps, center = true)
                vertical_tearslot_2d(r, l);
    }
}

module teardrop_chamfer(h, center, chamfer, chamfer_both_ends) { //! Helper module for adding chamfer to a teardrop
    if(h && chamfer)
        translate_z(center ? 0 : h / 2)
            for(m = chamfer_both_ends ? [0, 1] : [1])
                mirror([0, 0, m])
                    translate_z((h - eps ) / 2)
                        hull()
                            children();
}
