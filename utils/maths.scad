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
//! Maths utilities for manipulating vectors and matrices.
//
function sqr(x) = x * x;                        //! Square x
function radians(degrees) = degrees * PI / 180; //! Convert radians to degrees
function degrees(radians) = radians * 180 / PI; //! Convert degrees to radians

function sinh(x) = (exp(x) - exp(-x)) / 2;      //! hyperbolic sine
function cosh(x) = (exp(x) + exp(-x)) / 2;      //! hyperbolic cosine
function tanh(x) = sinh(x) / cosh(x);           //! hyperbolic tangent
function coth(x) = cosh(x) / sinh(x);           //! hyperbolic cotangent
function argsinh(x) = ln(x + sqrt(sqr(x) + 1)); //! inverse hyperbolic sine
function argcosh(x) = ln(x + sqrt(sqr(x) - 1)); //! inverse hyperbolic cosine
function argtanh(x) = ln((1 + x) / (1 - x)) / 2;//! inverse hyperbolic tangent
function argcoth(x) = ln((x + 1) / (x - 1)) / 2;//! inverse hyperbolic cotangent

function translate(v) = let(u = is_list(v) ? len(v) == 2 ? [v.x, v.y, 0] //! Generate a 4x4 translation matrix, `v` can be `[x, y]`, `[x, y, z]` or `z`
                                                         : v
                                           : [0, 0, v])
                          [ [1, 0, 0, u.x],
                            [0, 1, 0, u.y],
                            [0, 0, 1, u.z],
                            [0, 0, 0,   1] ];

function rotate(a, v) = //! Generate a 4x4 rotation matrix, `a` can be a vector of three angles or a single angle around `z`, or around axis `v`
    is_undef(v) ? let(av = is_list(a) ? a : [0, 0, a],
                      cx = cos(av[0]),
                      cy = cos(av[1]),
                      cz = cos(av[2]),
                      sx = sin(av[0]),
                      sy = sin(av[1]),
                      sz = sin(av[2]))
                          [
                              [ cy * cz, sx * sy * cz - cx * sz, cx * sy * cz + sx * sz, 0],
                              [ cy * sz, sx * sy * sz + cx * cz, cx * sy * sz - sx * cz, 0],
                              [-sy,      sx * cy,                cx * cy,                0],
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

function rot3_z(a) = //! Generate a 3x3 matrix to rotate around z
    let(c = cos(a),
        s = sin(a))
        [ [ c, -s,  0],
          [ s,  c,  0],
          [ 0,  0,  1] ];

function rot2_z(a) = //! Generate a 2x2 matrix to rotate around z
    let(c = cos(a),
        s = sin(a))
        [ [ c, -s],
          [ s,  c] ];

function scale(v) = let(s = is_list(v) ? v : [v, v, v]) //!  Generate a 4x4 matrix that scales by `v`, which can be a vector of xyz factors or a scalar to scale all axes equally
                        [
                          [s.x, 0,   0,   0],
                          [0,   s.y, 0,   0],
                          [0,   0,   s.z, 0],
                          [0,   0,   0,   1]
                        ];

function vec2(v) = [v.x, v.y]; //! Return a 2 vector with the first two elements of `v`
function vec3(v) = [v.x, v.y, v.z]; //! Return a 3 vector with the first three elements of `v`
function vec4(v) = [v.x, v.y, v.z, 1]; //! Return a 4 vector with the first three elements of `v`
function transform(v, m) = vec3(m * [v.x, v.y, v.z, 1]); //! Apply 4x4 transform to a 3 vector by extending it and cropping it again
function transform_points(path, m) = [for(p = path) transform(p, m)]; //! Apply transform to a path
function unit(v) = let(n = norm(v)) n ? v / n : v; //! Convert `v` to a unit vector

function transpose(m) = [ for(j = [0 : len(m[0]) - 1]) [ for(i = [0 : len(m) - 1]) m[i][j] ] ]; //! Transpose an arbitrary size matrix

function identity(n, x = 1) = [for(i = [0 : n - 1]) [for(j = [0 : n - 1]) i == j ? x : 0] ]; //! Construct an arbitrary size identity matrix

function reverse(v) = let(n = len(v) - 1) n < 0 ? [] : [for(i = [0 : n]) v[n - i]]; //! Reverse a vector

function angle_between(v1, v2) = acos(v1 * v2 / (norm(v1) * norm(v2))); //! Return the angle between two vectors

// https://www.gregslabaugh.net/publications/euler.pdf
function euler(R) = let(ay = asin(-R[2][0]), cy = cos(ay)) //! Convert a rotation matrix to a Euler rotation vector.
    cy ? [ atan2(R[2][1] / cy, R[2][2] / cy), ay, atan2(R[1][0] / cy, R[0][0] / cy) ]
       : R[2][0] < 0 ? [atan2( R[0][1],  R[0][2]),  180, 0]
                     : [atan2(-R[0][1], -R[0][2]), -180, 0];

module position_children(list, t) //! Position children if they are on the Z = 0 plane when transformed by t
    for(p = list)
        let(q = t * p)
            if(abs(transform([0, 0, 0], q).z) < 0.01)
                multmatrix(q)
                    children();

// Matrix inversion: https://www.mathsisfun.com/algebra/matrix-inverse-row-operations-gauss-jordan.html

function augment(m) = let(l = len(m), n = identity(l)) [ //! Augment a matrix by adding an identity matrix to the right
    for(i = [0 : l - 1])
        concat(m[i], n[i])
];

function rowswap(m, i, j) = [ //! Swap two rows of a matrix
    for(k = [0 : len(m) - 1])
        k == i ? m[j] : k == j ? m[i] : m[k]
];

function solve_row(m, i) = let(diag = m[i][i]) [ //! Make diagonal one by dividing the row by it and subtract from other rows to make column zero
    for(j = [0 : len(m) - 1])
        i == j ? m[j] / diag : m[j] - m[i] * m[j][i] / diag
];

function nearly_zero(x) = abs(x) < 1e-5; //! True if x is close to zero

function solve(m, i = 0, j = 0) = //! Solve each row ensuring diagonal is not zero
    i < len(m) ?
        assert(i + j < len(m), "matrix is singular")
         solve(!nearly_zero(m[i + j][i]) ? solve_row(j ? rowswap(m, i, i + j) : m, i) : solve(m, i, j + 1), i + 1)
        : m;

function invert(m) = let(n =len(m), m = solve(augment(m))) [ //! Invert a matrix
    for(i = [0 : n - 1]) [
        for(j = [n : 2 * n - 1])
             each m[i][j]
    ]
];

function circle_intersect(c1, r1, c2, r2) =     //! Calculate one point where two circles in the X-Z plane intersect, clockwise around c1
    let(
        v = c1 - c2,                            // Line between centres
        d = norm(v),                            // Distance between centres
        a = atan2(v.z, v.x) - acos((sqr(d) + sqr(r2) - sqr(r1)) / (2 * d * r2)) // Cosine rule to find angle from c2
     ) c2 + r2 * [cos(a), 0, sin(a)];           // Point on second circle

function map(v, func) = [ for (e = v) func(e) ]; //! make a new vector where the func function argument is applied to each element of the vector v
function mapi(v, func) = [ for (i = [0:len(v)-1]) func(i,v[i]) ]; //! make a new vector where the func function argument is applied to each element of the vector v. The func will get the index number as first argument, and the element as second argument.
function reduce(v, func, unity) = let ( r = function(i,val) i == len(v) ? val : r(i + 1, func(val, v[i])) ) r(0, unity); //! reduce a vector v to a single entity by applying the func function recursively to the reduced value so far and the next element, starting with unity as the initial reduced value
function sumv(v) = reduce(v, function(a, b) a + b, 0); //! sum a vector of values that can be added with "+"

function xor(a,b) = (a && !b) || (!a && b);     //! Logical exclusive OR
function cuberoot(x)= sign(x)*abs(x)^(1/3);

function quadratic_real_roots(a, b, c) =        //! Returns real roots of a quadratic equation, biggest first. Returns empty list if no real roots
    let(2a = 2 * a,
        2c = 2 * c,
        det = b^2 - 2a * 2c
    ) det < 0 ? [] :
        let(r = sqrt(det),
            x1 = b < 0 ? 2c / (-b + r) : (-b - r) / 2a,
            x2 = b < 0 ? (-b + r) / 2a : 2c / (-b - r)
        ) [x2, x1];

function cubic_real_roots(a, b, c, d) = //! Returns real roots of cubic equation
    let(b = b / a,
        c = c / a,
        d = d / a,
        inflection = -b / 3,
        p = c - b^2 / 3,
        q = 2 * b^3 / 27 - b * c / 3 + d,
        det = q^2 / 4 + p^3 / 27,
        roots = !p && !q ? 1 : nearly_zero(det) ? 2 :  det < 0 ? 3 : 1,
        r = sqrt(det),
        x = cuberoot(-q / 2 - r) + cuberoot(-q / 2 + r)
    ) roots == 1 ? [x] :
      roots == 2 ? [3 * q /p + inflection, -3 * q / p / 2 + inflection] :
      [for(i = [0 : roots - 1]) 2 * sqrt(-p / 3) * cos(acos(3 * q * sqrt(-3 / p) / p / 2) - i * 120) + inflection];
