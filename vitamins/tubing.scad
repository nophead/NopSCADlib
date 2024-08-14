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
//! Tubing and sleeving. The internal diameter can be forced to stretch it over something. A path can be specified, otherwise it is just straight with the specified length.
//
include <../utils/core/core.scad>
include <../utils/tube.scad>
include <../utils/sweep.scad>

function tubing_material(type) = type[1]; //! Material description
function tubing_od(type)       = type[2]; //! Outside diameter
function tubing_id(type)       = type[3]; //! Inside diameter
function tubing_colour(type)   = type[4]; //! Colour

function tubing_or(type)        = tubing_od(type) / 2; //! Outside radius
function tubing_ir(type)        = tubing_id(type) / 2; //! Inside radius

module tubing(type, length = 15, forced_id = 0, center = true, path = []) { //! Draw specified tubing with optional forced internal diameter and optional path.
    original_od = tubing_od(type);
    original_id = tubing_id(type);
    id = forced_id ? forced_id : original_id;
    od = original_od + id - original_id;
    length = path ? round(path_length(path)) : length;
    if(tubing_material(type) == "Heatshrink sleeving")
        vitamin(str("tubing(", type[0], arg(length, 15), "): ", tubing_material(type), " ID ", original_id, "mm x ",length, "mm"));
    else
        vitamin(str("tubing(", type[0], arg(length, 15), "): ", tubing_material(type), " OD ", original_od, "mm ID ", original_id,"mm x ",length, "mm"));

    if(tubing_material(type) == "Carbon fiber")
        woven_tube(od / 2, id /2, center = center, length, colour = tubing_colour(type));
    else
        color(tubing_colour(type))
            if(path)
                render_if(manifold)
                    difference() {
                        sweep(path, circle_points(od / 2));
                        start = path[0] - eps * unit(path[1] - path[0]);
                        n = len(path) - 1;
                        end = path[n] + eps * unit(path[n] - path[n - 1]);
                        sweep(concat([start], path, [end]), circle_points(id / 2));
                    }
            else
                linear_extrude(length, center = center, convexity = 4)
                    difference() {
                        circle(d = od);
                        circle(d = id);
                    }
}
