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
//! Utility to generate a polyhedron by sweeping a 2D profile along a 3D path and utilities for generating paths.
//!
//! The initial orientation is the Y axis of the profile points towards the initial center of curvature, Frenet-Serret style.
//! Subsequent rotations use the minimum rotation method.
//!
//! The path can be open or closed. If closed sweep ensures that the start and end have the same rotation to line up.
//! An additional twist around the path can be specified. If the path is closed this should be a multiple of 360.
//!
//! `rounded_path()` can be used to generate a path of lines connected by arcs, useful for wire runs, etc.
//! The vertices specify where the the path would be without any rounding.
//! Each vertex, apart from the first and the last, has an associated radius and the path shortcuts the vertex with an arc specified by the radius.
//!
//! `spiral_paths()` makes a list of new paths that spiral around a given path. It can be used to make twisted wires that follow a rounded_path, for example.
//
include <../utils/core/core.scad>

use <maths.scad>

function transpose3(m) = [ [m[0].x, m[1].x, m[2].x],
                           [m[0].y, m[1].y, m[2].y],
                           [m[0].z, m[1].z, m[2].z] ];
//
// Find the first non-colinear point
//
tiny = 0.00001;
function find_curve(tangents, i = 1) =
    i >= len(tangents) - 1 || norm(cross(tangents[0], tangents[i] - tangents[0])) > tiny ? i
                                                                                         : find_curve(tangents, i + 1);
//
// Frenet-Serret frame
//
function fs_frame(tangents) =
    let(tangent = tangents[0],
        i = find_curve(tangents),
        normal = tangents[i] - tangents[0],
        binormal = cross(tangent, normal),
        z = unit(tangent),
        x = assert(norm(binormal) > tiny, "all points are colinear") unit(binormal),
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
// Note that the rotation matrix is transposed to allow post multiplication.
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
// of the start and end of a non closed path. Note that the edges are converted to unit vectors so that their relative lengths
// don't affect the direction of the tangent.
//
function tangent(path, before, i, after) = unit(unit(path[i] - path[before]) + unit(path[after] - path[i]));
//
// Calculate the twist per segment caused by rotate_from_to() instead of a simple Euler rotation around Z.
//
function helical_twist_per_segment(r, pitch, sides) = //! Calculate the twist around Z that rotate_from_to() introduces
    let(step_angle = 360 / sides,
        lt = 2 * r * sin(step_angle),               // length of tangent between two facets
        slope = atan(2 * pitch / sides / lt)        // slope of tangents
       ) step_angle * sin(slope);                   // angle tangent should rotate around z projected onto axis rotate_from_to() uses

//
// Generate all the transforms for the profile of the swept volume.
//
function sweep_transforms(path, loop = false, twist = 0, initial_rotation = undef) =
    let(len = len(path),
        last = len - 1,

        tangents = [tangent(path, loop ? last : 0, 0, 1),
                    for(i = [1 : last - 1]) tangent(path, i - 1, i, i + 1),
                    tangent(path, last - 1, last, loop ? 0 : last)],

        lengths = [for(i = 0, t = 0; i < len; t = t + norm(path[min(i + 1, last)] - path[i]), i = i + 1) t],
        length = lengths[last],

        rotations = [for(i = 0, rot = is_undef(initial_rotation) ? fs_frame(tangents) : rot3_z(initial_rotation);
                         i < len;
                         i = i + 1,
                         rot = i < len ? rotate_from_to(tangents[i - 1], tangents[i]) * rot : undef) rot],

        mismatch = loop ? calculate_twist(rotations[0], rotations[last]) : 0,
        rotation = mismatch + twist
    )
    [for(i = [0 : last])
        let(za = rotation * lengths[i] / length)
            orientate(path[i], rotations[i] * rot3_z(za))
    ];

//
// Generate all the surface points of the swept volume.
//
function skin_points(profile, path, loop, twist = 0) =
    let(profile4 = [for(p = profile) [p.x, p.y, p.z, 1]],

        transforms = sweep_transforms(path, loop, twist)
    )
    [for(t = transforms)
        each profile4 * t
    ];

function cap(facets, segment = 0, end) = //! Create the mesh for an end cap
    let(reverse = is_undef(end) ? segment : end)
        [for(i = [0 : facets - 1]) facets * segment + (reverse ? i : facets - 1 - i)];

function quad(p, a, b, c, d) = norm(p[a] - p[c]) > norm(p[b] - p[d]) ? [[b, c, d], [b, d, a]] : [[a, b, c], [a, c, d]];

function skin_faces(points, npoints, facets, loop, offset = 0) = //! Create the mesh for the swept volume without end caps
    [for(i = [0 : facets - 1], s = [0 : npoints - (loop ? 1 : 2)])
       let(j = s + offset, k = loop ? (j + 1) % npoints : j + 1)
       each quad(points,
            j * facets + i,
            j * facets + (i + 1) % facets,
            k * facets + (i + 1) % facets,
            k * facets + i)];

function sweep(path, profile, loop = false, twist = 0) = //! Generate the point list and face list of the swept volume
    let(
        npoints = len(path),
        facets = len(profile),
        points = skin_points(profile, path, loop, twist),
        skin_faces = skin_faces(points, npoints, facets, loop),
        faces = loop ? skin_faces : concat([cap(facets)], skin_faces, [cap(facets, npoints - 1)])
    ) [points, faces];

module sweep(path, profile, loop = false, twist = 0, convexity = 1) { //! Draw a polyhedron that is the swept volume
    mesh = sweep(path, profile, loop, twist);

    polyhedron(points = mesh[0], faces = mesh[1], convexity = convexity);
}

function circle_points(r = 1, z = 0, dir = -1) = //! Generate the points of a circle, setting z makes a single turn spiral
    let(sides = r2sides(r))
        [for(i = [0 : sides - 1]) let(a = dir * i * 360 / sides) [r * cos(a), r * sin(a), z * i / sides]];

function rectangle_points(w, h) = [[-w/2, -h/2, 0], [-w/2, h/2, 0], [w/2, h/2, 0], [w/2, -h/2, 0]]; //! Generate the points of a rectangle

function arc_points(r, a = [90, 0, 180], al = 90) = //! Generate the points of a circular arc
   let(sides = ceil(r2sides(r) * al / 360), tf = rotate(a))
    [for(i = [0 : sides]) let(t = i * al / sides) transform([r * sin(t), r * cos(t), 0], tf)];

function before(path1, path2) =  //! Translate `path1` so its end meets the start of `path2` and then concatenate
    let(end = len(path1) - 1, offset = path2[0] - path1[end])
        concat([for(i = [0 : end - 1]) path1[i] + offset], path2);

function after(path1, path2) =  //! Translate `path2` so its start meets the end of `path1` and then concatenate
    let(end1 = len(path1) - 1, end2 = len(path2) - 1, offset = path1[end1] - path2[0])
        concat(path1, [for(i = [1 : end2]) path2[i] + offset]);

function rounded_path(path) = //! Convert a rounded_path, consisting of a start coordinate, vertex / radius pairs and then an end coordinate, to a path of points for sweep.
    let(len = len(path)) assert(len > 3 && len % 2 == 0) [
        path[0],                                        // First point has no radius
        for(i = [1 : 2 : len - 3]) let(                 // Step through the vertices with radii, i.e. not the first or last
            prev = max(i - 2, 0),                       // Index of previous point, might be the first point, which is a special case
            p0 = path[prev],                            // Point before the vertex
            p1 = path[i],                               // Vertex
            r = path[i + 1],                            // Radius of shortcut curve
            p2 = path[i + 2],                           // Point after the vertex
            v1 = assert(Len(p0) == 3, str("expected path[", prev,  "] to be a vertex coordinate, got ", p0))
                 assert(Len(p1) == 3, str("expected path[", i,     "] to be a vertex coordinate, got ", p1))
                 assert(Len(p2) == 3, str("expected path[", i + 2, "] to be a vertex coordinate, got ", p2))
                 assert(is_num(r),    str("expected path[", i + 1, "] to be a radius, got ", r))
            p0 - p1,                                    // Calculate vectors between vertices
            v2 = p2 - p1,
            a = angle_between(v1, -v2),                 // Angle turned through
            d = r * tan(a / 2),                         // Distance from vertex to tangents
            room = min(norm(v1), norm(v2)),             // Maximum distance
            arc_start = assert(d <= room,
                str("Can't fit radius ", r, " into corner at vertex path[", i, "] = ", p1, " only room for radius ", room / tan(a / 2)))
                p1 + unit(v1) * d,                      // Calc the start position
            z_axis = unit(cross(v1, v2)),               // z_axis is perpendicular to both vectors
            centre = arc_start + unit(cross(z_axis, v1)) * r, // Arc center is a radius away, and perpendicular to v1 and the z_axis.
            x_axis = arc_start - centre,                // Make the x_axis along the radius to the start point, includes radius a scale factor
            y_axis = cross(x_axis, z_axis),             // y_axis perpendicular to the other two
            sides = ceil(r2sides(r) * a / 360)          // Sides needed to make the arc
        )
        for(j = [0 : sides], t = a * j / sides)         // For each vertex in the arc
            cos(t) * x_axis + sin(t) * y_axis + centre, // Circular arc in the tiled xy plane.
        path[len - 1],                                  // Last point has no radius
    ];

function segmented_path(path, min_segment) = [  //! Add points to a path to enforce a minimum segment length
    for(i = [0 : len(path) - 2])
        let(delta =
            assert(path[i] != path[i + 1], str("Coincident points at path[", i, "] = ", path[i]))
            path[i+1] - path[i],
            segs = ceil(norm(delta) / min_segment)
        )
        for(j = [0 : segs - 1])
            path[i] + delta * j / segs, // Linear interpolation
        path[len(path) - 1]
];

function offset_paths(path, offsets, twists = 0) = let( //! Create new paths offset from the original, optionally spiralling around it
        transforms = sweep_transforms(path, twist = 360 * twists, initial_rotation = 0)
    ) [for(o = offsets) let(initial = [o.x, o.y, o.z, 1]) [for(t = transforms) initial * t]];

function spiral_paths(path, n, r, twists, start_angle) = let( //! Create a new paths which spiral around the given path. Use for making twisted cables
        segment = twists ? path_length(path) / twists / r2sides(2 * r) : inf,
        transforms = sweep_transforms(segmented_path(path, segment), twist = 360 * twists)
    ) [for(i = [0 : n - 1]) let(initial = [r, 0, 0, 1] * rotate(start_angle + i * 360 / n)) [for(t = transforms) initial * t]];

function rounded_path_vertices(path) = [path[0], for(i = [1 : 2 : len(path) - 1]) path[i]]; //! Show the unrounded version of a rounded_path for debug

module show_path(path, r = 0.1) //! Show a path using a chain of hulls for debugging, duplicate points are highlighted.
    for(i = [0 : len(path) - 2]) {
        hull($fn = 16) {
            translate(path[i])
                sphere(r);

            translate(path[i + 1])
                sphere(r);
        }
        if(path[i] == path[i + 1])
            translate(path[i])
                color("red") sphere($fn = 16, r * 4);
    }

function move_along(j, z, path_S) =
     j >= len(path_S) - 1 || z <= path_S[j] ? j : move_along(j + 1, z, path_S);

function spiral_wrap(path, profile, pitch, turns) = //! Create a path that spirals around the specified profile with the given pitch.
    let(
        transforms = sweep_transforms(path, loop = false, twist = 0),
        plen = len(profile),
        S = path_length(profile),
        profile = [
            for(i = 0, s = 0; i < plen; s = s + norm(profile[(i + 1) % plen] - profile[i]), i = i + 1)
                let(p = profile[i]) [p.x, p.y, p.z + pitch * s / S, 1]
        ],
        path_len = len(path),
        path_S = [for(i = 0, s = 0; i < path_len; s = s + norm(path[(i + 1) % path_len] - path[i]), i = i + 1) s],
        n = turns * plen
    ) [
        for(i = 0, j = 0, k = 0, zstep = 0;
            i < n;
            i = i + 1,
            k = i % plen,
            zstep = floor(i / plen) * pitch,
            j = move_along(j, zstep + profile[k].z, path_S))
                if(!i || k) (profile[k] + [0, 0, zstep - path_S[j], 0]) * transforms[j]
    ];
