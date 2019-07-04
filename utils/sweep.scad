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
//! Utility to generate a polhedron by sweeping a 2D profile along a 3D path and utilities for generating paths.
//!
//! The initial orientation is the Y axis of the profile points towards the initial center of curvature, Frenet-Serret style.
//! This means the first three points must not be colinear. Subsequent rotations use the minimum rotation method.
//!
//! The path can be open or closed. If closed sweep ensures that the start and end have the same rotation to line up.
//! An additional twist around the path can be specified. If the path is closed this should be a multiple of 360.
//
include <../core.scad>

use <maths.scad>

function transpose3(m) = [ [m[0].x, m[1].x, m[2].x],
                           [m[0].y, m[1].y, m[2].y],
                           [m[0].z, m[1].z, m[2].z] ];
//
// Frenet-Serret frame
//
function fs_frame(tangents) =
    let(tangent = tangents[0],
        normal = tangents[1] - tangents[0],
        binormal = cross(tangent, normal),
        z = unit(tangent),
        x = assert(norm(binormal) > 0.00001, "first three points are colinear") unit(binormal),
        y = unit(cross(z, x))
       ) [[x.x, y.x, z.x],
          [x.y, y.y, z.y],
          [x.z, y.z, z.z]];
//
// Computes the rotation with minimum angle that brings UNIT vectors a to b.
// The code fails if a and b are opposed to each other.
//
function rotate_from_to(a, b) =
    let(axis = unit(cross(a, b)))
        axis * axis >= 0.99 ? transpose3([b, axis, cross(axis, b)]) * [a, axis, cross(axis, a)]
                            : a * b > 0 ? [[ 1, 0, 0], [0, 1, 0], [0, 0,  1]]
                                        : [[-1, 0, 0], [0, 1, 0], [0, 0, -1]];
//
// Given two rotations A and B, calculates the angle between B*[1,0,0]
// and A*[1,0,0] that is, the total torsion angle difference between A and B.
//
function calculate_twist(A, B) = let(D = transpose3(B) * A) atan2(D[1][0], D[0][0]);
//
// Compute a 4x3 matrix to orientate a frame of the sweep given the position and a 3x3 rotation matrix.
//
function orientate(p, r) =
    let(x = r[0], y = r[1], z = r[2])
        [[x.x, y.x, z.x],
         [x.y, y.y, z.y],
         [x.z, y.z, z.z],
         [p.x, p.y, p.z]];

//
// Rotate around z
//
function rot3_z(a) =
    let(c = cos(a),
        s = sin(a))
        [ [ c, -s,  0],
          [ s,  c,  0],
          [ 0,  0,  1] ];

//
// Calculate the unit tangent at a vertex given the indices before and after. One of these can be the same as i in the case
// of the start and end of a non closed path.
//
function tangent(path, before, i, after) = unit(unit(path[after] - path[i]) - unit(path[before] - path[i]));
//
// Generate all the surface points of the swept volume.
//
function skin_points(profile, path, loop, twist = 0) =
    let(len = len(path),
        last = len - 1,

        profile4 = [for(p = profile) [p.x, p.y, p.z, 1]],

        tangents = [tangent(path, loop ? last : 0, 0, 1),
                    for(i = [1 : last - 1]) tangent(path, i - 1, i, i + 1),
                    tangent(path, last - 1, last, loop ? 0 : last)],

        rotations = [for(i = 0, rot = fs_frame(tangents);
                         i < len;
                         i = i + 1,
                         rot = i < len ? rotate_from_to(tangents[i - 1], tangents[i]) * rot : undef) rot],

        missmatch = loop ? calculate_twist(rotations[0], rotations[last]) : 0,
        rotation = missmatch + twist
    )
    [for(i = [0 : last])
        let(za = rotation * i / last)
            each profile4 * orientate(path[i], rotations[i] * rot3_z(za))
    ];

function cap(facets, segment = 0) = [for(i = [0 : facets - 1]) segment ? facets * segment + i : facets - 1 - i];

function quad(p, a, b, c, d) = norm(p[a] - p[c]) > norm(p[b] - p[d]) ? [[b, c, d], [b, d, a]] : [[a, b, c], [a, c, d]];

function skin_faces(points, segs, facets, loop) = [for(i = [0 : facets - 1], s = [0 : segs - (loop ? 1 : 2)])
   each quad(points,
        s * facets + i,
        s * facets + (i + 1) % facets,
       ((s + 1) % segs) * facets + (i + 1) % facets,
       ((s + 1) % segs) * facets + i)];

function sweep(path, profile, loop = false, twist = 0) = //! Generate the point list and face list of the swept volume
    let(
        segments = len(path),
        facets = len(profile),
        points = skin_points(profile, path, loop, twist),
        skin_faces = skin_faces(points, segments, facets, loop),
        faces = loop ? skin_faces : concat([cap(facets)], skin_faces, [cap(facets, segments - 1)])
        ) [points, faces];

module sweep(path, profile, loop = false, twist = 0) { //! Draw a polyhedron that is the swept volume
    mesh = sweep(path, profile, loop, twist);

    polyhedron(points = mesh[0], faces = mesh[1]);
}

function path_length(path, i = 0, length = 0) = //! Calculated the length along a path
    i >= len(path) - 1 ? length
                       : path_length(path, i + 1, length + norm(path[i + 1] - path[i]));

function circle_points(r = 1, z = 0) = //! Generate the points of a circle, setting z makes a single turn spiral
    let(sides = r2sides(r))
        [for(i = [0 : sides - 1]) let(a = i * 360 / sides) [r * sin(a), r * cos(a), z * a / 360]];

function rectangle_points(w, h) = [[-w/2, -h/2, 0], [-w/2, h/2, 0], [w/2, h/2, 0], [w/2, -h/2, 0]]; //! Generate the points of a rectangle

function arc_points(r, a = [90, 0, 180], al = 90) = //! Generate the points of a circular arc
   let(sides = ceil(r2sides(r) * al / 360), tf = rotate(a))
    [for(i = [0 : sides]) let(t = i * al / sides) transform([r * sin(t), r * cos(t), 0], tf)];

function before(path1, path2) =  //! Translate ```path1``` so its end meets the start of ```path2``` and then concatenate
    let(end = len(path1) - 1, offset = path2[0] - path1[end])
        concat([for(i = [0 : end - 1]) path1[i] + offset], path2);

function after(path1, path2) =  //! Translate ```path2``` so its start meets the end of ```path1``` and then concatenate
    let(end1 = len(path1) - 1, end2 = len(path2) - 1, offset = path1[end1] - path2[0])
        concat(path1, [for(i = [1 : end2]) path2[i] + offset]);
