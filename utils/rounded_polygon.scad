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
//! Draw a polygon with rounded corners. Each element of the vector is the XY coordinate and a radius in clockwise order.
//! Radius can be negative for a concave corner.
//!
//! Because the tangents need to be calculated to find the length these can be calculated separately and re-used when drawing to save calculating them twice.
//
include <../utils/core/core.scad>
use <maths.scad>

function circle_tangent(p1, p2) = //! Compute the clockwise tangent between two circles represented as [x,y,r]
    let(
        r1 = p1[2],
        r2 = p2[2],
        dx = p2.x - p1.x,
        dy = p2.y - p1.y,
        d = sqrt(dx * dx + dy * dy),
        theta = assert(d, str("points conicident ", p1)) atan2(dy, dx) + acos((r1 - r2) / d),
        v = [cos(theta), sin(theta)]
    )[ p1 + r1 * v, p2 + r2 * v ];

function rounded_polygon_arcs(points, tangents) = //! Compute the arcs at the points, for each point [angle, rotate_angle, length]
    let(
        len = len(points)
    ) [ for (i = [0: len-1])
        let(
            p1 = vec2(tangents[(i - 1 + len) % len][1]),
            p2 = vec2(tangents[i][0]),
            p = vec2(points[i]),
            v1 = p1 - p,
            v2 = p2 - p,
            sr = points[i][2],
            r = abs(sr),
            a = r < 0.001 ? 0 : let( aa = acos(limit((v1 * v2) / sqr(r), -1, 1)) ) cross(v1, v2) * sign(sr) <= 0 ? aa : 360 - aa,
            l = PI * a * r / 180,
            v0 = [r, 0],
            v = let (
                vv = norm(v0 - v2) < 0.001 ? 0 : abs(v2.y) < 0.001 ? 180 :
                        let( aa = acos( limit((v0 * v2) / sqr(r), -1, 1)) ) cross(v0, v2) * sign(sr) <= 0 ? aa : 360 - aa
            ) sr > 0 ? 360 - vv : vv - a
        ) [a, v % 360, l]
    ];

function rounded_polygon_tangents(points) = //! Compute the straight sections between a point and the next point, for each section [start_point, end_point, length]
    let(len = len(points))
    [ for(i = [0 : len - 1])
        let(ends = circle_tangent(points[i], points[(i + 1) % len]))
            [ends[0], ends[1], norm(ends[0] - ends[1])]
    ];

// the cross product of 2D vectors is the area of the parallelogram between them. We use the sign of this to decide if the angle is bigger than 180.
function rounded_polygon_length(points, tangents) = //! Calculate the length given the point list and the list of tangents computed by `rounded_polygon_tangents`
    let(
        arcs = rounded_polygon_arcs(points, tangents)
    ) sumv( map( concat(tangents, arcs), function(e) e[2] ) );

function line_intersection(l0, l1) = //! Return the point where two 2D lines intersect or undef if they don't.
    assert(Len(l0) == 2 && Len(l1) == 2, "Two 2D vectors expected")
    let(
        p0 = l0[0], p1 = l0[1], p2 = l1[0], p3 = l1[1],
        v1 = p1 - p0,
        v2 = p3 - p2,
        v3 = p0 - p2,
        det = v1.x * v2.y - v2.x * v1.y,
        s = det ? (-v1.y * v3.x + v1.x * v3.y) / det : inf,
        t = det ? ( v2.x * v3.y - v2.y * v3.x) / det : inf
    ) s >= 0 && s <= 1 && t >= 0 && t <= 1 ? p0 + t * v1 : undef;

function rounded_polygon(points, _tangents = undef) = //! Return the rounded polygon from the point list, can pass the tangent list to save it being calculated
    let(
        len = len(points),
        tangents = _tangents ? _tangents : rounded_polygon_tangents(points),
        arcs = rounded_polygon_arcs(points, tangents)
    ) [for(i = [0 : len - 1], last = (i - 1 + len) % len)
        let(
            t0 = vec2(tangents[last]),
            t1 = vec2(tangents[i]),
            p = line_intersection(t0, t1),                              // Do the tangents cross?
            R = points[i][2]
        )
        if(!is_undef(p))                                                // Tangents intersect, so just add the intersection point
            p
        else
            each [                                                      // Else link the two tangent ends with an arc
                t0[1],                                                  // End of last tangent
                if(R)                                                   // If rounded
                    let(r = abs(R),                                     // Get radius
                        n = r2sides4n(r),                               // Decide number of vertices
                        step = 360 / n,                                 // Angular step
                        arc = arcs[i],                                  // Get corner arc details
                        start = ceil(arc[1] / step + eps),              // Starting index
                        end = floor((arc[0] + arc[1]) / step - eps),    // Ending index
                        c = vec2(points[i])                             // Centre of arc
                    ) for(j = R > 0 ? [end : -1 : start] : [start : 1 : end], a = j * step)
                        c + r * [cos(a), sin(a)],                       // Points on the arc
                if(R)
                    t1[0],                                              // Start of next tangent
            ]
       ];

function offset(points, offset) =                                       //! Offset a 2D polygon, breaks for concave shapes and negative offsets if the offset is more than half the smallest feature size.
    rounded_polygon([for(p = points) [p.x, p.y, offset]]);

module rounded_polygon(points, _tangents = undef) //! Draw the rounded polygon from the point list, can pass the tangent list to save it being calculated
    polygon(rounded_polygon(points, _tangents), convexity = len(points));
