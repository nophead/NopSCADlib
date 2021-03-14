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
//! Models timing belt running in a path over toothed or smooth pulleys and calculates an accurate length.
//! Only models 2D paths, belt may twist to support crossed belt core XY and other designes where the belt twists!
//!
//! By default the path is a closed loop. An open loop can be specified by specifying `open=true`, and in that case the start and end points are not connected, leaving the loop open.
//!
//! To get a 180 degree twist of the loop, you can use the `twist` argument. `Twist` can be a single number, and in that case the belt will twist after
//! the position with that number. Alternatively `twist` can be a list of boolean values with a boolean for each position; the belt will then twist after
//! the position that have a `true` value in the `twist` list. If the path is specified with pulley/idler types, then you can use `auto_twist=true`; in
//! that case the belt will automatically twist so the back of the belt always runs against idlers and the tooth side runs against pullies. If you use
//! `open=true` then you might also use `start_twist=true` to let the belt start the part with the back side out.
//!
//! The path must be specified as a list of positions. Each position should be either a vector with `[x, y, pulley]` or `[x, y, r]`. A pully is a type from
//! `pulleys.scad`, and correct radius and angle will automatically be calculated. Alternatively a radius can be specified directly.
//!
//! To make the back of the belt run against a smooth pulley on the outside of the loop specify a negative pitch radius.
//! Alternativley you can just specify smooth pulleys in the path, and it will then happen automatically.
//!
//! Individual teeth are not drawn, instead they are represented by a lighter colour.
//
include <../utils/core/core.scad>
use <../utils/rounded_polygon.scad>
use <../utils/maths.scad>
use <pulley.scad>

function belt_pitch(type)        = type[1]; //! Pitch in mm
function belt_width(type)        = type[2]; //! Width in mm
function belt_thickness(type)    = type[3]; //! Total thickness including teeth
function belt_tooth_height(type) = type[4]; //! Tooth height
function belt_pitch_height(type) = type[5] + belt_tooth_height(type); //! Offset of the pitch radius from the tips of the teeth

function belt_pitch_to_back(type) = belt_thickness(type) - belt_pitch_height(type); //! Offset of the back from the pitch radius
//
// We model the belt path at the pitch radius of the pulleys and the pitch line of the belt to get an accurate length.
//
module belt(type, points, belt_colour = grey(20), tooth_colour = grey(50), open = false, twist = undef, auto_twist = false, start_twist = false) { //! Draw a belt path given a set of points and pitch radii where the pulleys are. Closed loop unless open is specified
    width = belt_width(type);
    pitch = belt_pitch(type);
    thickness = belt_thickness(type);

    info = _belt_points_info(type, points, open, twist, auto_twist, start_twist);
    dotwist = info[0]; // array of booleans, true if a twist happen after the position
    twisted = info[1]; // array of booleans, true if the belt is twisted at the position
    pointsx = info[2]; // array of [x,y,r], r is negative if left-angle (points may have pulleys as third element, but pointsx have radi)
    tangents = info[3];
    arcs = info[4];
    length = ceil(_belt_length(info, open) / pitch) * pitch;

    part = str(type[0],pitch);
    vitamin(str("belt(", no_point(part), "x", width, ", ", pointsx, "): Belt ", part," x ", width, "mm x ", length, "mm"));

    len = len(points);

    th = belt_tooth_height(type);
    ph = belt_pitch_height(type);
    module beltp() translate([ph - th, -width / 2]) square([th, width]);
    module beltb() translate([ph - thickness, -width / 2]) square([thickness - th, width]);

    for (i = [0 : len - (open ? 2 : 1)]) {
        p1 = tangents[i].x;
        p2 = tangents[i].y;
        v = p2-p1;
        a =  atan(v.y / v.x) - (v.x < 0 ? 180 : 0); //a2(p2-p1);
        l = norm(v);
        translate(p1) rotate([-90, 0, a - 90]) {
            twist = dotwist[i] ? 180 : 0;
            mirrored = twisted[i] ? 1 : 0;
            color(tooth_colour) linear_extrude(l, twist = twist) mirror([mirrored, 0, 0]) beltp();
            color(belt_colour)  linear_extrude(l, twist = twist) mirror([mirrored, 0, 0]) beltb();
        }
    }

    for (i = [(open ? 1 : 0) : len - (open ? 2 : 1)]) {
        p = pointsx[i];
        arc = arcs[i];
        translate([p.x, p.y]) rotate([0, 0, arc[1]]) {
            mirrored = xor(twisted[i], p[2] < 0) ? 0 : 1;
            color(tooth_colour) rotate_extrude(angle = arc[0]) translate([abs(p[2]), 0, 0]) mirror([mirrored, 0, 0]) beltp();
            color(belt_colour)  rotate_extrude(angle = arc[0]) translate([abs(p[2]), 0, 0]) mirror([mirrored, 0, 0]) beltb();
        }
    }
}

function _belt_points_info(type, points, open, twist, auto_twist, start_twist) = //! Helper function that calculates [twist, istwisted, points, tangents, arcs]
let(
    len = len(points),
    isleft = function(i) let(
            p = vec2(points[i]),
            p0 = vec2(points[(i - 1 + len) % len]),
            p1 = vec2(points[(i + 1) % len])
        ) cross(p-p0,p1-p) > 0,
    dotwist = function(i, istwisted) let( in = (i + 1) % len )
        is_list(twist) ? twist[i] :
        !is_undef(twist) ? i == twist :
        open && is_list(points[in][2]) && auto_twist ? !pulley_teeth(points[in][2]) && !xor(isleft(in), istwisted) :
        false,
    twisted = [
        for (
            i = 0,
            istwisted = start_twist,
            twist = dotwist(i, istwisted),
            nexttwisted = xor(twist, istwisted);
            i < len;
            i = i + 1,
            istwisted = nexttwisted,
            twist = dotwist(i, istwisted),
            nexttwisted = xor(twist, istwisted)
        ) [twist, istwisted] ],
    pointsx = mapi(points, function(i, p) !is_list(p[2]) ? p : [p.x, p.y, let( // if p[2] is not a list it is just r, otherwise it is taken to be a pulley and we calculate r
            isleft = isleft(i),
            r = belt_pulley_pr(type, p[2], twisted = !xor(pulley_teeth(p[2]), xor(isleft, twisted[i][1])))
        ) isleft ? -r : r ] ),
    tangents = rounded_polygon_tangents(pointsx),
    arcs = rounded_polygon_arcs(pointsx, tangents)
) [ [ for (t = twisted) t[0] ], [ for (t = twisted) t[1] ], pointsx, tangents, arcs];

function belt_pulley_pr(type, pulley, twisted=false) = //! Pitch radius. Default it expects the belt tooth to be against a toothed pulley an the backside to be against a smooth pulley (an idler). If `twisted` is true, the the belt is the other way around.
    let(
        thickness = belt_thickness(type),
        ph = belt_pitch_height(type)
    ) pulley_teeth(pulley)
        ? pulley_pr(pulley) + (twisted ? thickness - ph : 0 )
        : pulley_ir(pulley) + (twisted ? ph : thickness - ph );


function belt_length(type, points, open = false) = _belt_length(_belt_points_info(type, points, open), open); //! Compute belt length given path

function _belt_length(info, open) = let(
    len = len(info[0]),
    d = open ? 1 : 0,
    tangents = slice(info[3], 0, len - d) ,
    arcs = slice(info[4], d, len - d)
) sumv( map( concat(tangents, arcs), function(e) e[2] ));
