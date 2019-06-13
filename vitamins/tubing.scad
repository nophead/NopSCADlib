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
//! Tubing and sleeving. The internal diameter can be forced to stretch it over something.
//
include <../core.scad>

function tubing_material(type) = type[1]; //! Material description
function tubing_od(type)       = type[2]; //! Outside diameter
function tubing_id(type)       = type[3]; //! Inside diameter
function tubing_colour(type)   = type[4]; //! Colour

module tubing(type, length = 15, forced_id = 0) { //! Draw specified tubing with optional forced internal diameter
    original_od = tubing_od(type);
    original_id = tubing_id(type);
    id = forced_id ? forced_id : original_id;
    od = original_od + id - original_id;
    if(tubing_material(type) == "Heatshrink sleeving")
        vitamin(str("tubing(", type[0], arg(length, 15), "): ", tubing_material(type), " ID ", original_id, "mm x ",length, "mm"));
    else
        vitamin(str("tubing(", type[0], arg(length, 15), "): ", tubing_material(type), " OD ", original_od, "mm ID ", original_id,"mm x ",length, "mm"));
    color(tubing_colour(type))
        linear_extrude(height = length, center = true, convexity = 4)
            difference() {
                circle(d = od);
                circle(d = id);
            }
}
