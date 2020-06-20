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
include <../utils/core/core.scad>

use <../utils/tube.scad>

bearing_colour = grey(70);
groove_colour = grey(60);
seal_colour = grey(30);


function bearing_length(type)           = type[1];   //! Total length
function bearing_dia(type)              = type[2];   //! Outside diameter
function bearing_rod_dia(type)          = type[3];   //! Internal diameter
function bearing_groove_length(type)    = type[4];   //! Groove length
function bearing_groove_dia(type)       = type[5];   //! Groove diameter
function bearing_groove_spacing(type)   = type[6];   //! Spacing between grooves, outer to outer, ie includes the grooves themselves

function bearing_radius(type)  = bearing_dia(type) / 2; //! Outside radius

module linear_bearing(type) { //! Draw specified linear bearing
    vitamin(str("linear_bearing(", type[0], "): Linear bearing ", type[0]));

    casing_t = bearing_radius(type) / 10;
    casing_ir = bearing_radius(type) - casing_t;
    length = bearing_length(type);
    or = bearing_radius(type);
    gl = bearing_groove_length(type);
    gr = bearing_groove_dia(type) / 2;
    gs = bearing_groove_spacing(type);
    offset = (length-gs)/2;

    if(gs==0) {
        color(bearing_colour) tube(or = or, ir = casing_ir, h = length);
    } else {
        translate_z(-length/2) {
            color(bearing_colour) tube(or = or, ir = casing_ir, h = offset, center = false);
            color(groove_colour) translate_z(offset) tube(or = gr, ir = casing_ir, h = gl,center = false);
            color(bearing_colour) translate_z(offset+gl) tube(or = or, ir = casing_ir, h = gs-2*gl, center = false);
            color(groove_colour) translate_z(offset+gs-gl) tube(or = gr, ir = casing_ir, h = gl, center = false);
            color(bearing_colour) translate_z(offset+gs) tube(or = or, ir = casing_ir, h = offset, center = false);
        }
    }
    rod_r =  bearing_rod_dia(type) / 2;
    color(seal_colour)
        tube(or = casing_ir, ir = rod_r + eps, h = length - 0.5);

    color(seal_colour * 0.8)
        tube(or = rod_r * 1.12, ir = rod_r, h = length);
}
