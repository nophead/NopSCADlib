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
//! LMnUU linear bearings.
//
include <../core.scad>

use <../utils/tube.scad>

bearing_colour = grey70;
seal_colour = grey20;

function bearing_length(type)  = type[1];   //! Total length
function bearing_dia(type)     = type[2];   //! Outside diameter
function bearing_rod_dia(type) = type[3];   //! Internal diameter

function bearing_radius(type)  = bearing_dia(type) / 2; //! Outside radius

module linear_bearing(type) { //! Draw specified linear bearing
    vitamin(str("linear_bearing(", type[0], "): Linear bearing LM", bearing_rod_dia(type),"UU"));

    casing_t = bearing_radius(type) / 10;
    casing_ir = bearing_radius(type) - casing_t;

    color(bearing_colour) tube(or = bearing_radius(type), ir = casing_ir,                 h = bearing_length(type));
    color(seal_colour)    tube(or = casing_ir,            ir = bearing_rod_dia(type) / 2, h = bearing_length(type) - 0.5);
}
