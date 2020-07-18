//
// NopSCADlib Copyright Chris Palmer 2020
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
//! Utilities for depicting the staircase slicing of horizontal holes made with [`teardrop_plus()`](#teardrops).
//
include <../utils/core/core.scad>

function teardrop_x(r, y) = //! Calculate the ordinate of a teardrop given y. Sweeping y from -r to + r yields the positive X half of the shape.
    let(x2 = sqr(r) - sqr(y))
        y > r / sqrt(2) ? y >= r ? 0
                                 : r * sqrt(2) - y
                        : x2 > 0 ? sqrt(x2)
                                 : 0;

function teardrop_plus_x(r, y, h) = //! Calculate the ordinate of a compensated teardrop given y.
    y < -h ? teardrop_x(r, y + h)
           : y > h ? teardrop_x(r, y - h)
                   : r;

module horihole(r, z, h = 0, center = true) { //! For making horizontal holes that don't need support material and are correct dimensions
    bot_layer = floor((z - r) / layer_height);
    top_layer = ceil((z + r) / layer_height);
    render(convexity = 5)
        extrude_if(h, center)
            for(i = [bot_layer : top_layer]) {
                Z = i * layer_height;
                x = teardrop_plus_x(r, Z - z + layer_height / 2, layer_height / 2);
                if(x > 0)
                    translate([-x, Z - z])
                        square([2 * x, layer_height]);
             }
}
