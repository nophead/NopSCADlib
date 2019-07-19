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
//
module teardrop(h, r, center = true, truncate = true) //! For making horizontal holes that don't need support material, set ```truncate = false``` to make traditional RepRap teardrops that don't even need bridging
    render(convexity = 5)
        extrude_if(h, center)
           hull() {
                circle4n(r);

                if(truncate)
                    translate([0, r / 2])
                        square([2 * r * (sqrt(2) - 1), r], center = true);
                else
                    polygon([[0, 0], [eps, 0], [0, r * sqrt(2)]]);
            }

module semi_teardrop(h, r, d = undef, center = true) //! A semi teardrop in the positive Y domain
    render(convexity = 5)
        extrude_if(h, center)
            intersection() {
                R = is_undef(d) ? r : d / 2;
                teardrop(r = R, h = 0);

                sq = R + 1;
                translate([-sq, 0])
                    square([2 * sq, sq]);
            }

module teardrop_plus(h, r, center = true, truncate = true) //! Slightly bigger teardrop to allow for the 3D printing staircase effect
    teardrop(h, r + layer_height / 4, center, truncate);

module tearslot(h, r, w, center = true) //! A horizontal slot that doesn't need support material
    extrude_if(h, center)
        hull() {
            translate([-w/2,0,0]) teardrop(r = r, h = 0);
            translate([ w/2,0,0]) teardrop(r = r, h = 0);
        }

module vertical_tearslot(h, r, l, center = true) //! A vertical slot that doesn't need support material
    extrude_if(h, center)
        hull() {
            translate([0,  l / 2]) teardrop(0, r, true);
            translate([0, -l / 2])
                circle4n(r);
        }
