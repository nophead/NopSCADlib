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

//! Filament spool models

include <../utils/core/core.scad>
include <../utils/tube.scad>

function spool_diameter(type)      = type[1]; //! Outside diameter
function spool_width(type)         = type[2]; //! Internal width
function spool_depth(type)         = type[3]; //! Internal depth
function spool_rim_thickness(type) = type[4]; //! Thickness at the outside rim
function spool_hub_thickness(type) = type[5]; //! Thickness at the hub
function spool_hub_bore(type)      = type[6]; //! Bore through the hub
function spool_hub_diameter(type)  = type[7]; //! Diameter of the thicker hub
function spool_hub_taper(type)     = type[8]; //! Diameter at which it tapers down to rim thickness
function spool_height(type)        = spool_width(type) + 2 * spool_hub_thickness(type); //! Outside width
function spool_pitch(type)         = spool_width(type) + spool_rim_thickness(type); //! Spacing of the rims

module spool(type, filament_depth = 0, filament_colour = "white", filament_d = 3) { //! Draw specified spool with optional filament
    vitamin(str("spool(", type[0], "): Filament spool ", spool_diameter(type), " x ", spool_width(type)));

    h = spool_height(type);
    r1 = spool_hub_bore(type) / 2;
    r2 = spool_hub_diameter(type) / 2;
    r3 = spool_hub_taper(type) / 2;
    r4 = spool_diameter(type) / 2;
    r5 = r4 - spool_depth(type);

    color([0.2, 0.2, 0.2]) translate_z(-h / 2) rotate_extrude(convexity = 5)
        polygon([
            [r1, h],
            [r1, 0],
            [r2, 0],
            [r3, spool_hub_thickness(type) - spool_rim_thickness(type)],
            [r4, spool_hub_thickness(type) - spool_rim_thickness(type)],
            [r4, spool_hub_thickness(type)],
            [r5, spool_hub_thickness(type)],
            [r5, h - spool_hub_thickness(type)],
            [r4, h - spool_hub_thickness(type)],
            [r4, h - spool_hub_thickness(type) + spool_rim_thickness(type)],
            [r3, h - spool_hub_thickness(type) + spool_rim_thickness(type)],
            [r2, h],
        ]);

    if(filament_depth) {
        w = spool_width(type);
        r = r5 + filament_depth;
        color(filament_colour)
            if(filament_d) {
                n = round(w / filament_d) + 1;
                fd = w / n;
                rotate_extrude($fn = 180) {
                    for(i = [0 : n -1])
                        translate([r - fd / 2, i * fd - w / 2 + fd / 2])
                            circle(d = fd, $fn = 32);

                    translate([r5, -w / 2])
                        square([filament_depth - fd / 2, w]);
                }
            }

            else
                tube(r, r5, w, $fn = 180);
    }
}
