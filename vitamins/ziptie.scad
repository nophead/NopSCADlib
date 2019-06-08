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

include <../core.scad>
use <../utils/tube.scad>

function ziptie_width(type)     = type[1]; //! Width
function ziptie_thickness(type) = type[2]; //! Thickness
function ziptie_latch(type)     = type[3]; //! Latch dimensions
function ziptie_colour(type)    = type[4]; //! Colour
function ziptie_tail(type)      = type[5]; //! The length without teeth

module ziptie(type, r)
{
    latch = ziptie_latch(type);
    length = ceil(2 * PI * r + ziptie_tail(type) + latch.z + 1);
    len = length <= 100 ? 100 : length;
    vitamin(str("ziptie(", type[0], ", ", r, "): Ziptie ", len, "mm min length"));

    angle = (r > latch.x / 2) ? asin((latch.x / 2) / r) - asin(ziptie_thickness(type) / latch.x) : 0;
    color(ziptie_colour(type)) union() {
        tube(ir = r, or = r + ziptie_thickness(type), h = ziptie_width(type));
        translate([0, -r, - latch.y / 2])
            rotate([90, 0, angle]) {
                union() {
                    cube(latch);

                    translate([latch.x / 2, latch.y / 2, (latch.z + 1) / 2])
                        cube([ziptie_thickness(type), ziptie_width(type), latch.z + 1], center = true);
                }
            }
    }
}
