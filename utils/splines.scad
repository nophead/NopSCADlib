//
// NopSCADlib Copyright Chris Palmer 2024
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
//! Cubic splines that interpolate between a list of 2D points passing through all of them.
//! Translated from the Python version at <https://community.alteryx.com/t5/Engine-Works/Creating-a-Cubic-Spline-in-Python-and-Alteryx/ba-p/581173>.
//! Note the x values of the points must be strictly increasing.
//!
//! Catmull-Rom splines are well behaved but the ends points are control points and the curve only goes from the second point to the penultimate point.
//! Coded from <https://en.wikipedia.org/wiki/Centripetal_Catmull%E2%80%93Rom_spline#Code_example_in_Python>.
//! No restrictions on points and they can be 3D.
//
include <../utils/core/core.scad>

use <maths.scad>
use <sweep.scad>

function cubic_spline(points, N = 100) = let( //! Interpolate the list of points given to produce N points on a cubic spline that passes through points given.
        N = N - 1,
        n = len(points),
        ass1 = assert(n >= 3, "must be at least 3 points")0,

        dx = [for(i = [0 : n - 2]) points[i + 1].x - points[i].x], // x deltas
        ass2 = assert(min(dx) > 0, "X must strictly increase")0,

        //
        // A and C are diagonals above and below the main diagonal B, which is all 2's
        //
        A = [for(i = [0 : n - 3]) dx[i] / (dx[i] + dx[i + 1]), 0],
        C = [0, for(i = [0 : n - 3]) dx[i + 1] / (dx[i] + dx[i + 1]), 0],
        //
        // D are the target values on the right hand side of the equation
        //
        D = [0, for(i = [1 : n - 2]) 6 * ((points[i + 1].y - points[i].y) / dx[i] - (points[i].y - points[i - 1].y) / dx[i - 1]) / (dx[i] + dx[i - 1]), 0],
        //
        // Solve the tridiagonal equation using the Thomas algorithm
        //
        c = [for(i = 1, c = 0; i < n; c = C[i] / (2 - c * A[i - 1]), i = i + 1) c, 0],
        d = [for(i = 1, d = 0; i < n; d = (D[i] - d * A[i - 1]) / (2 - c[i - 1] * A[i - 1]), i = i + 1) d, 0],
        M = [for(i = n - 2, x = 0; i >= 0; x = d[i] - c[i] * x, i = i - 1) x, 0],
        //
        // Calculate the coefficients of each cubic curve
        //
        coefficients = [for(i = [0 : n - 2], dx2 = sqr(dx[i]), j = n - 1 - i)
                            [(M[j - 1] - M[j]) * dx2 / 6,
                             M[j] * dx2 / 2,
                             points[i + 1].y - points[i].y - (M[j - 1] + 2 * M[j]) * dx2 / 6,
                             points[i].y]
                       ],
        //
        // Use the coefficients to interpolate between the points
        //
        x0 = points[0].x,
        x1 = points[n - 1].x,
        spline = [for(i = 0, j = 0, z = 0, x = x0; i <= N + 1;
                      x = x0 + (x1 - x0) * i / N,
                      j = i < N - 1 && x > points[j + 1].x ? j + 1 : j,
                      z = (x - points[j].x) / dx[j],
                      i = i + 1,
                      C = coefficients[j]
                     ) if(i) [x, (((C[0] * z) + C[1]) * z + C[2]) * z + C[3]]
                 ]
    ) spline;

function tj(ti, pi, pj, alpha = 0.5) = ti + pow(norm(pi - pj), alpha);

function catmull_rom_segment(P0, P1, P2, P3, n, alpha = 0.5, last = false) = let(
        t0 = 0,
        t1 = tj(t0, P0, P1, alpha),
        t2 = tj(t1, P1, P2, alpha),
        t3 = tj(t2, P2, P3, alpha),
        end = last ? n : n - 1,
        points  = [for(i = [0 : end], t = t1 + (t2 - t1) * i / n) let(
            A1 = (t1 - t) / (t1 - t0) * P0 + (t - t0) / (t1 - t0) * P1,
            A2 = (t2 - t) / (t2 - t1) * P1 + (t - t1) / (t2 - t1) * P2,
            A3 = (t3 - t) / (t3 - t2) * P2 + (t - t2) / (t3 - t2) * P3,
            B1 = (t2 - t) / (t2 - t0) * A1 + (t - t0) / (t2 - t0) * A2,
            B2 = (t3 - t) / (t3 - t1) * A2 + (t - t1) / (t3 - t1) * A3
        ) (t2 - t) / (t2 - t1) * B1 + (t - t1) / (t2 - t1) * B2]
    ) points;


function catmull_rom_spline(points, n, alpha = 0.5) = let( //! Interpolate n new points between the specified points with a Catmull-Rom spline, alpha = 0.5 for centripetal, 0 for uniform and 1 for chordal.
        segs = len(points) - 3
    ) [for(i = [0 : segs - 1]) each catmull_rom_segment(points[i], points[i + 1], points[i + 2], points[i + 3], n, alpha, last = i == segs - 1)];
