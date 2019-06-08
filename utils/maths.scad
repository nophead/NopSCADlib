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
//! Maths utilities for minapulating vectors and matrices.
//
function sqr(x) = x * x;

function translate(v) = let(u = is_list(v) ? len(v) == 2 ? [v.x, v.y, 0] //! Generate a 4x4 translation matrix, ```v``` can be ```[x, y]```, ```[x, y, z]``` or ```z```
                                                         : v
                                           : [0, 0, v])
                          [ [1, 0, 0, u.x],
                            [0, 1, 0, u.y],
                            [0, 0, 1, u.z],
                            [0, 0, 0,   1] ];

function rotate(a, v) = //! Generate a 4x4 rotation matrix, ```a``` can be a vector of three angles or a single angle around ```z```, or around axis ```v```
    is_undef(v) ? let(av = is_list(a) ? a : [0, 0, a],
                      cx = cos(av[0]),
                      cy = cos(av[1]),
                      cz = cos(av[2]),
                      sx = sin(av[0]),
                      sy = sin(av[1]),
                      sz = sin(av[2]))
                          [
                              [ cy * cz, cz * sx * sy - cx * sz, cx * cz * sy + sx * sz, 0],
                              [ cy * sz, cx * cz + sx * sy * sz,-cz * sx + cx * sy * sz, 0],
                              [-sy,      cy * sx,                cx * cy,                0],
                              [ 0,       0,                      0,                      1]
                          ]
                : let(s = sin(a),
                      c = cos(a),
                      C = 1 - c,
                      m = sqr(v.x) + sqr(v.y) + sqr(v.z), // m used instead of norm to avoid irrational roots as much as possible
                      u = v / sqrt(m))
                          [
                              [ C * v.x * v.x / m + c,       C * v.x * v.y / m - u.z * s, C * v.x * v.z / m + u.y * s, 0],
                              [ C * v.y * v.x / m + u.z * s, C * v.y * v.y / m + c,       C * v.y * v.z / m - u.x * s, 0],
                              [ C * v.z * v.x / m - u.y * s, C * v.z * v.y / m + u.x * s, C * v.z * v.z / m + c,       0],
                              [ 0,                           0,                           0,                           1]
                         ];

function scale(v) = let(s = is_list(v) ? v : [v, v, v]) //!  Generate a 4x4 matrix that scales by ```v```, which can be a vector of xyz factors or a scalar to scale all axes equally
                        [
                          [s.x, 0,   0,   0],
                          [0,   s.y, 0,   0],
                          [0,   0,   s.z, 0],
                          [0,   0,   0,   1]
                        ];

function vec3(v) = [v.x, v.y, v.z]; //! Return a 3 vector with the first three elements of ```v```
function transform(v, m) = vec3(m * [v.x, v.y, v.z, 1]); //! Apply 4x4 transform to a 3 vector by extending it and cropping it again
function transform_points(path, m) = [for(p = path) transform(p, m)]; //! Apply transform to a path
function unit(v) = let(n = norm(v)) n ? v / n : v; //! Convert ```v``` to a unit vector

function transpose(m) = [ for(j = [0 : len(m[0]) - 1]) [ for(i = [0 : len(m) - 1]) m[i][j] ] ]; //! Transpose an arbitrary size matrix

function identity(n, x = 1) = [for(i = [0 : n - 1]) [for(j = [0 : n - 1]) i == j ? x : 0] ]; //! Construct an arbitrary size identity matrix

function reverse(v) = let(n = len(v) - 1) n < 0 ? [] : [for(i = [0 : n]) v[n - i]]; //! Reverse a vector
