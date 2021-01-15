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
//! Square with one rounded corner.
//
include <../utils/core/core.scad>

module quadrant(w, r, center = false) { //! Draw a square with one rounded corner, can be centered on the arc centre, when `center` is `true`.
    h = is_list(w) ? w.y : w;
    w = is_list(w) ? w.x : w;
    offset_w = center ? r - w : 0;
    offset_h = center ? r - h : 0;
    translate([offset_w, offset_h])
        hull() {
            intersection() {
                translate([w - r, h - r])
                    circle4n(r);

                square([w, h]);
            }

            square([w, eps]);

            square([eps, h]);
        }
}
