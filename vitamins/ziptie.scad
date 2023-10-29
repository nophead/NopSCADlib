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
//! Cable zipties.
//

include <../utils/core/core.scad>
use <../utils/rounded_polygon.scad>

function ziptie_width(type)     = type[1]; //! Width
function ziptie_thickness(type) = type[2]; //! Thickness
function ziptie_latch(type)     = type[3]; //! Latch dimensions
function ziptie_colour(type)    = type[4]; //! Colour
function ziptie_tail(type)      = type[5]; //! The length without teeth

module ziptie(type, r = 5, t = 0) //! Draw specified ziptie wrapped around radius `r` and optionally through panel thickness `t`
{
    $fa = fa; $fs = fs;

    latch = ziptie_latch(type);
    zt = ziptie_thickness(type);
    lx = min(latch.x / 2, r + zt / 2);
    right_bulge = (r > lx - zt / 2) || !t;
    cr = zt / 2;                        // sharp corner radius
    z = r + t - cr;
    x = r - cr;
    outside_corners = t ? [ [0, 0, r + zt], [-x, z, cr + zt], [x, z, cr + zt] ] : [];
    x1 = lx - zt / 2;
    x2 = x1 + x1 * zt / r;
    outside_path = concat([ if(right_bulge) [0, 0, r + zt], [x2, -r - zt, eps] ], outside_corners);

    tangents = rounded_polygon_tangents(outside_path);
    length = ceil(rounded_polygon_length(outside_path, tangents) + ziptie_tail(type) + latch.z + 1);
    len = length <= 100 ? 100 : length;
    width =  ziptie_width(type);

    vitamin(str("ziptie(", type[0], "): Ziptie ", width, "mm x ", len, "mm min length"));

    color(ziptie_colour(type)){
        linear_extrude(width, center = true)
            difference() {
                rounded_polygon(outside_path, tangents);

                offset(-zt)
                    rounded_polygon(outside_path, tangents);
             }

        translate([lx, -r])
             rotate([90, 0, 0])
                union() {
                    rounded_rectangle(latch, 0.5);

                    translate_z((latch.z + 1) / 2)
                        cube([ziptie_thickness(type), ziptie_width(type), latch.z + 1], center = true);
                }
     }
}
