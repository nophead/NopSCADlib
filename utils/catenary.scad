//
// NopSCADlib Copyright Chris Palmer 2020
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
//! Catenary curve to model hanging wires, etc.
//!
//! Although the equation of the curve is simply `y = a cosh(x / a)` there is no explicit formula to calculate the constant `a` or the range of `x` given the
//! length of the cable and the end point coordinates. See <https://en.wikipedia.org/wiki/Catenary#Determining_parameters>. The Newton-Raphson method is used to find
//! `a` numerically, see <https://en.wikipedia.org/wiki/Newton%27s_method>.
//!
//! The coordinates of the lowest point on the curve can be retrieved by calling `catenary_points()` with `steps` equal to zero.
//
include <core/core.scad>
use <maths.scad>

function catenary(t, a) = let(u = argsinh(t)) a * [u, cosh(u)]; //! Parametric catenary function linear along the length of the curve.
function catenary_s(d, a) = 2 * a * sinh(d / a); //! Length of a symmetric catenary with width `2d`.
function catenary_ds_by_da(d, a) = 2 * sinh(d / a) - 2 * d / a * cosh(d / a); //! First derivative of the length with respect to `a`.

function catenary_find_a(d, l, a = 1, best_e = inf, best_a = 1) =  //! Find the catenary constant `a`, given half the horizontal span and the length.
     assert(l > 2 * d, "Not long enough to span the gap") assert(d) let(error = abs(catenary_s(d, a) - l))
     error >= best_e && error < 0.0001 ? best_a
                                       : catenary_find_a(d, l, max(a - (catenary_s(d, a) - l) / catenary_ds_by_da(d, a), d / argsinh(1e99)), error, a);

function catenary_points(l, x, y, steps = 100) = //! Returns a list of 2D points on the curve that goes from the origin to `(x,y)` and has length `l`.
    let(
        d = x / 2,
        a = catenary_find_a(d, sqrt(sqr(l) - sqr(y))),   // Find a to get the correct length
        offset = argsinh(y / catenary_s(d, a)),
        t0 = sinh(-d / a + offset),
        t1 = sinh( d / a + offset),
        h = a * cosh(-d / a + offset) - a,
        lowest = offset > d / a ? [0, 0] : offset < -d / a ? [x, y] : [d - offset * a, -h],
        p0 = catenary(t0, a)
    )
    steps ? [for(t = [t0 : (t1 - t0) / steps : t1]) catenary(t, a) - p0] : lowest;
