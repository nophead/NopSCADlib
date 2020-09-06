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
//! To make the back of the belt run against a smooth pulley on the outside of the loop specify a negative pitch radius.
//!
//! By default the path is a closed loop but a gap length and position can be specified to make open loops.
//! To draw the gap its XY position is specified by ```gap_pos```. ```gap_pos.z``` can be used to specify a rotation if the gap is not at the bottom of the loop.
//!
//! Individual teeth are not drawn, instead they are represented by a lighter colour.
//
include <../utils/core/core.scad>
use <../utils/rounded_polygon.scad>
use <../utils/maths.scad>

function belt_pitch(type)        = type[1]; //! Pitch in mm
function belt_width(type)        = type[2]; //! Width in mm
function belt_thickness(type)    = type[3]; //! Total thickness including teeth
function belt_tooth_height(type) = type[4]; //! Tooth height
function belt_pitch_height(type) = type[5] + belt_tooth_height(type); //! Offset of the pitch radius from the tips of the teeth

function belt_pitch_to_back(type) = belt_thickness(type) - belt_pitch_height(type); //! Offset of the back from the pitch radius
//
// We model the belt path at the pitch radius of the pulleys and the pitch line of the belt to get an accurate length.
// The belt is then drawn by offseting each side from the pitch line.
//
module belt(type, points, gap = 0, gap_pos = undef, belt_colour = grey(20), tooth_colour = grey(50)) { //! Draw a belt path given a set of points and pitch radii where the pulleys are. Closed loop unless a gap is specified
    width = belt_width(type);
    pitch = belt_pitch(type);
    thickness = belt_thickness(type);
    part = str(type[0],pitch);
    vitamin(str("belt(", no_point(part), "x", width, ", ", points, arg(gap, 0), arg(gap_pos, undef), "): Belt ", part," x ", width, "mm x ", length, "mm"));

    len = len(points);

    tangents = rounded_polygon_tangents(points);

    length = ceil((rounded_polygon_length(points, tangents) - gap) / pitch) * pitch;

    module shape() rounded_polygon(points, tangents);

    ph = belt_pitch_height(type);
    th = belt_tooth_height(type);
    module gap()
        if(gap)
            translate([gap_pos.x, gap_pos.y])
                rotate(is_undef(gap_pos.z) ? 0 : gap_pos.z)
                    translate([0, ph - thickness / 2])
                        square([gap, thickness + eps], center = true);

    color(belt_colour)
        linear_extrude(width, center = true)
            difference() {
                offset(-ph + thickness ) shape();
                offset(-ph + th) shape();
                gap();
            }

    color(tooth_colour)
        linear_extrude(width, center = true)
            difference() {
                offset(-ph + th) shape();
                offset(-ph) shape();
                gap();
            }
}

function belt_length(points, gap = 0) = rounded_polygon_length(points, rounded_polygon_tangents(points)) - gap; //! Compute belt length given path and optional gap
