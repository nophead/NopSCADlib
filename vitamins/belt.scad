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
//! Models timing belt running over toothed or smooth pulleys and calculates an accurate length.
//! Only models 2D paths, so not core XY!
//!
//! By default the path is a closed loop but a gap length and position can be specified to make open loops.
//!
//! Individual teeth are not drawn, instead they are represented by a lighter colour.
//
include <../core.scad>
use <../utils/rounded_polygon.scad>

function belt_pitch(type)        = type[1]; //! Pitch in mm
function belt_width(type)        = type[2]; //! Width in mm
function belt_thickness(type)    = type[3]; //! Total thickness including teeth
function belt_tooth_height(type) = type[4]; //! Tooth height
function belt_pitch_height(type) = belt_tooth_height(type) + type[4]; //! Offset of the pitch radius from the tips of the teeth

function no_point(str) = chr([for(c = str) if(c == ".") ord("p") else ord(c)]);
//
// We model the belt path at the pitch radius of the pulleys and the pitch line of the belt to get an accurate length.
// The belt is then drawn by offseting each side from the pitch line.
//
module belt(type, points, gap = 0, gap_pt = undef) { //! Draw a belt path given a set of points and pitch radii where the pulleys are. Closed loop unless a gap is specified
    belt_colour = grey20;
    tooth_colour = grey50;
    width = belt_width(type);
    pitch = belt_pitch(type);
    thickness = belt_thickness(type);
    part = str(type[0],pitch);
    vitamin(str("belt(", no_point(part), "x", width, ", ", points, arg(gap, 0), arg(gap_pt, undef), "): Belt ", part," x ", width, "mm x ", length, "mm"));

    len = len(points);

    tangents = rounded_polygon_tangents(points);

    length = ceil((rounded_polygon_length(points, tangents) - gap) / pitch) * pitch;

    module shape() rounded_polygon(points, tangents);

    module gap()
        if(gap)
            translate(gap_pt)
                square([gap, thickness + eps], center = true);

    color(belt_colour)
        linear_extrude(height = width, center = true)
            difference() {
                offset(thickness - belt_pitch_height(type)) shape();
                offset(-belt_pitch_height(type) + belt_tooth_height(type)) shape();
                gap();

            }
    color(tooth_colour)
        linear_extrude(height = width, center = true)
            difference() {
                offset(-belt_pitch_height(type) + belt_tooth_height(type)) shape();
                offset(-belt_pitch_height(type)) shape();
                gap();
            }
}

function belt_length(points, gap = 0) = rounded_polygon_length(points, rounded_polygon_tangents(points)) - gap; //! Compute belt length given path and optional gap
