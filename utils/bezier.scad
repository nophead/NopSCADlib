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
//! Bezier curves and function to get and adjust the length or minimum z point.
//!
//! `bezier_join()` joins two paths with a Bezier curve that starts tangential to the end of `path1` and ends tangential to the end of `path2`.
//! To do this the outer control points are the path ends and the inner two control points are along the tangents to the path ends.
//! The only degree of freedom is how far along those tangents, which are the `d` and optional `d2` parameters.
//
include <../global_defs.scad>
include <maths.scad>

function bezier(t, v) = //! Returns a point at distance `t` [0 - 1] along the curve with control points `v`
    (len(v) > 2) ? bezier(t, [for (i = [0 : len(v) - 2]) v[i] * (1 - t) + v[i + 1] * (t)])
                 : v[0] * (1 - t) + v[1] * (t);

function bezier_path(v, steps = 100) = //! Returns a Bezier path from control points `v` with `steps` segments
    [for(i = [0 : steps], t = i / steps) bezier(t, v)];

function bezier_length(v, delta = 0.01, t = 0, length = 0) = //! Calculate the length of a Bezier curve from control points `v`
    t > 1 ? length
          : bezier_length(v, delta, t + delta, length + norm(bezier(t, v) - bezier(t + delta, v)));

function adjust_bezier(v, r) =
    let(extension = (v[1] - v[0]) * (r - 1))
        [v[0], v[1] + extension, v[2] + extension, v[3]];

function adjust_bezier_length(v, l, eps = 0.001, r1 = 1.0, r2 = 1.5, l1, l2) = //! Adjust Bezier control points `v` to get the required curve length `l`
    let(l1 = l1 != undef ? l1 : bezier_length(adjust_bezier(v, r1)),
        l2 = l2 != undef ? l2 : bezier_length(adjust_bezier(v, r2))
       ) abs(l1 - l) < eps ? adjust_bezier(v, r1)
                           : let(r = r1 + (l - l1) * (r2 - r1) / (l2 - l1))
                                 abs(r - r1) < abs(r - r2) ? adjust_bezier_length(v, l, eps, r, r1, undef, l1)
                                                           : adjust_bezier_length(v, l, eps, r, r2, undef, l2);

function bezier_min_z(v, steps = 100, z = inf, i = 0) = //! Calculate the minimum z coordinate of a Bezier curve from control points `v`
     i <= steps ? bezier_min_z(v, steps, min(z, bezier(i / steps, v).z), i + 1) : z;

function adjust_bezier_z(v, z, eps = 0.001, r1 = 1, r2 = 1.5, z1, z2) = //! Adjust Bezier control points `v` to get the required minimum `z`
    let(z1 = z1 != undef ? z1 : bezier_min_z(adjust_bezier(v, r1)),
        z2 = z2 != undef ? z2 : bezier_min_z(adjust_bezier(v, r2))
       ) abs(z1 - z) < eps ? adjust_bezier(v, r1)
                           : let(r = r1 + (z - z1) * (r2 - r1) / (z2 - z1))
                                 abs(r - r1) < abs(r - r2) ? adjust_bezier_z(v, z, eps, r, r1, undef, z1)
                                                           : adjust_bezier_z(v, z, eps, r, r2, undef, z2);

function bezier_join(path1, path2, d, d2 = undef) = let( //! Join two paths with a Bezier curve, control points are the path ends are `d` and `d2` from the ends in the same direction.
        d2 = is_undef(d2) ? d : d2,
        l = len(path1),
        p0 = path1[l - 1],
        p1 = p0 + unit(p0 - path1[l - 2]) * d,
        p3 = path2[0],
        p2 = p3 + unit(path2[0] - path2[1]) * d2,
        v = [p0, p1, p2, p3],
        segs = path_length(v) / $fs,
        path = [for(i = [1 : segs - 1], t = i / segs) bezier(t, v)],
        len = len(path)
    ) concat(path1, path, path2);
