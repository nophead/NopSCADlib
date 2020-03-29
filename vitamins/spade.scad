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
//! Spade terminals used as parts of electrical components.
//
include <../utils/core/core.scad>

function spade_l(type)     = type[0]; //! Length of the narrow part
function spade_w(type)     = type[1]; //! Width
function spade_t(type)     = type[2]; //! Thickness
function spade_hole(type)  = type[3]; //! Hole diameter
function spade_shank(type) = type[4]; //! Shank width

module spade(type, height = 14) { //! Draw a spade of the specified type and total length. The shank length is adjusted to make the length.
    w = spade_w(type);
    l = spade_l(type);
    chamfer = w / 4;
    shank_w = spade_shank(type);
    shank_l = height - spade_l(type);

    color("silver")
    rotate([90, 0, 0])
        linear_extrude(spade_t(type), center = true)
            difference() {
                union() {
                    if(shank_l > 0)
                        translate([-shank_w / 2, 0])
                            square([shank_w, shank_l]);

                    translate([0, shank_l])
                        hull() {
                            translate([- w/ 2, 0])
                                square([w, l - chamfer]);

                            translate([- (w - chamfer) / 2, 0])
                                square([w - chamfer, l]);
                        }
                }
                translate([0, shank_l + l / 2])
                    circle(d = spade_hole(type));
            }
}
