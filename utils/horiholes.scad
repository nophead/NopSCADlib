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
//! Utilities for depicting the staircase slicing of horizontal holes made with [`teardrop_plus()`](#teardrops), see <https://hydraraptor.blogspot.com/2020/07/horiholes-2.html>
//!
//! `horicylinder()` makes cylinders that fit inside a round hole. Layers that are less than 2 filaments wide and layers that need more than a 45 degree overhang are omitted.
//
include <../utils/core/core.scad>

function teardrop_plus_x(r, y, h) = //! Calculate the ordinate of a compensated teardrop given y and layer height.
    let(fr = h / 2,
        hpot = r + fr,
        x2 = sqr(hpot) - sqr(y),
        x = x2 > 0 ? sqrt(x2) : 0
    )
    max(0,
        y < hpot / sqrt(2) ? x - fr :
        y < hpot           ? hpot * sqrt(2) - y - fr :
        0);

module horihole(r, z, h = 0, center = true) { //! For making horizontal holes that don't need support material and are correct dimensions
    bot_layer = floor((z - r) / layer_height);
    top_layer = ceil((z + r) / layer_height);
    render(convexity = 5)
        extrude_if(h, center)
            for(i = [bot_layer : top_layer]) {
                Z = i * layer_height;
                y = Z - z + layer_height / 2;
                x = teardrop_plus_x(r, y, layer_height);
                if(x > 0)
                    translate([0, y])
                        difference() {
                            square([2 * x + layer_height, layer_height], center = true);

                            for(end = [-1, 1])
                                translate([end * (x + layer_height / 2), 0])
                                    circle(d = layer_height, $fn = 32);
                        }
             }
}

function teardrop_minus_x(r, y, h) = //! Calculate the ordinate of a compensated teardrop given y and layer height.
    let(fr = h / 2,
        hpot = r - fr,
        x2 = sqr(hpot) - sqr(y),
        x = x2 > 0 ? sqrt(x2) : 0,
        X = y >= -hpot / sqrt(2) ? x + fr : 0
    )
    X >= extrusion_width ? X : 0;

module horicylinder(r, z, h = 0, center = true) { //! For making horizontal cylinders that don't need support material and are correct dimensions
    bot_layer = floor((z - r) / layer_height);
    top_layer = ceil((z + r) / layer_height);
    render(convexity = 5)
        extrude_if(h, center)
            for(i = [bot_layer : top_layer]) {
                Z = i * layer_height;
                y = Z - z + layer_height / 2;
                x = teardrop_minus_x(r, y, layer_height);
                if(x >= extrusion_width)
                    hull()
                        for(end = [-1, 1])
                            translate([end * (x - layer_height / 2), y])
                                circle(d = layer_height, $fn = 32);
             }
}
