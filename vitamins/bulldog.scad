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
//! Crude representation of a bulldog clip. The handle is not currently drawn but its length can be
//! accessed to allow clearance. Used for holding glass on 3D printer beds but Swiss picture clips can be
//! better.
//
include <../utils/core/core.scad>
use <../utils/rounded_polygon.scad>
use <../utils/sector.scad>

function bulldog_length(type)    = type[1];     //! Length along the profile
function bulldog_depth(type)     = type[2];     //! Depth from the back to the front of the tubes
function bulldog_height(type)    = type[3];     //! Height at the back
function bulldog_thickness(type) = type[4];     //! Thickness of the metal
function bulldog_tube(type)      = type[5] / 2; //! Outside diameter of the tubes
function bulldog_radius(type)    = type[6];     //! Outside radius of the back corners
function bulldog_handle_length(type) = type[7]; //! Length that the handle protrudes from the back

module bulldog_shape(depth, height, radius, tube, open) {
        rounded_polygon([
            [-depth / 2 + radius, -height / 2 + radius, radius],
            [-depth / 2 + radius,  height / 2 - radius, radius],
            [ depth / 2 - tube,    open / 2 + tube,    -tube],
            [ depth / 2 + tube,    height / 2,          tube],
            [ depth / 2 + tube,   -height / 2,          tube],
            [ depth / 2 - tube,   -open / 2 - tube,    -tube],

        ]);
}

module bulldog(type, open = 4) { //! Draw bulldog clip open by specified amount
    tube = bulldog_tube(type);
    thickness = bulldog_thickness(type);
    depth = bulldog_depth(type);
    length = bulldog_length(type);
    height = bulldog_height(type);
    rad = bulldog_radius(type);
    gap = open + thickness * 2;

    vitamin(str("bulldog(", type[0], "): Bulldog clip ",length, "mm"));

    color("yellow")
    translate([depth / 2 - thickness - eps, 0])
        rotate([90, 0, 0])
            linear_extrude(length, center = true)
                union() {
                    difference() {
                        bulldog_shape(depth, height, rad, tube, gap);

                        offset(-thickness)
                            bulldog_shape(depth, height, rad, tube, gap);

                        translate([depth / 2 - tube, -height])
                            square([depth, 2 * height]);
                    }

                    for(side = [-1, 1])
                        translate([depth / 2 - tube, side * (open / 2 + tube)])
                            difference() {
                                mirror([0, side < 0 ? 1 : 0])
                                    sector(tube, -90, 210);
                                circle(tube - thickness);
                            }
                }
}
