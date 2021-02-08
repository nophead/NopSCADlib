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

module ziptie(type, r, t = 0) //! Draw specified ziptie wrapped around radius `r` and optionally through panel thickness `t`
{
    latch = ziptie_latch(type);
    lx = latch.x / 2;
    zt = ziptie_thickness(type);
    cr = zt;                        // sharp corner raduus
    z = r + t - cr;
    x = r - cr;
    inside_corners  = t ? [ [0, 0, r],      [-x, z, cr],      [x, z, cr]      ] : [];
    outside_corners = t ? [ [0, 0, r + zt], [-x, z, cr + zt], [x, z, cr + zt] ] : [];
    x1 = lx - zt / 2;
    x2 = x1 + x1 * zt / r;
    inside_path  = concat([ [0, 0, r],      [x1, -r,      eps] ], inside_corners);
    outside_path = concat([ [0, 0, r + zt], [x2, -r - zt, eps] ], outside_corners);

    tangents = rounded_polygon_tangents(outside_path);
    length = ceil(rounded_polygon_length(outside_path, tangents) + ziptie_tail(type) + latch.z + 1);
    len = length <= 100 ? 100 : length;
    width =  ziptie_width(type);

    vitamin(str("ziptie(", type[0], ", ", r, "): Ziptie ", width, "mm x ", len, "mm min length"));

    color(ziptie_colour(type)){
        linear_extrude(width, center = true)
            difference() {
                rounded_polygon(outside_path, tangents);
                rounded_polygon(inside_path);
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
