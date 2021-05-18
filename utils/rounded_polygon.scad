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
use <../utils/maths.scad>

function circle_tangent(p1, p2) = //! Compute the clockwise tangent between two circles represented as [x,y,r]
    let(
        r1 = p1[2],
        r2 = p2[2],
        dx = p2.x - p1.x,
        dy = p2.y - p1.y,
        d = sqrt(dx * dx + dy * dy),
        theta = atan2(dy, dx) + acos((r1 - r2) / d),
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
            a = r < 0.001 ? 0 : let( aa = acos((v1 * v2) / sqr(r)) ) cross(v1, v2) * sign(sr) <= 0 ? aa : 360 - aa,
            l = PI * a * r / 180,
            v0 = [r, 0],
            v = let (
                vv = norm(v0 - v2) < 0.001 ? 0 : abs(v2.y) < 0.001 ? 180 :
                        let( aa = acos((v0 * v2) / sqr(r)) ) cross(v0, v2) * sign(sr) <= 0 ? aa : 360 - aa
            ) sr > 0 ? 360 - vv : vv - a
        ) [a, v, l]
    ];

function rounded_polygon_tangents(points) = //! Compute the straight sections between a point and the next point, for each section [start_point, end_point, length]
    let(len = len(points))
    [ for(i = [0 : len - 1])
        let(ends = circle_tangent(points[i], points[(i + 1) % len]))
            [ends[0], ends[1], norm(ends[0] - ends[1])]
    ];

// the cross product of 2D vectors is the area of the parallelogram between them. We use the sign of this to decide if the angle is bigger than 180.
function rounded_polygon_length(points, tangents) = //! Calculate the length given the point list and the list of tangents computed by ` rounded_polygon_tangents`
    let(
        arcs = rounded_polygon_arcs(points, tangents)
    ) sumv( map( concat(tangents, arcs), function(e) e[2] ) );

module rounded_polygon(points, _tangents = undef) { //! Draw the rounded polygon from the point list, can pass the tangent list to save it being calculated
    len = len(points);
    indices = [0 : len - 1];
    tangents = [ for (t = _tangents ? _tangents : rounded_polygon_tangents(points)) each [t.x, t.y] ];

    difference() {
        union() {
            for(i = indices)
                if(points[i][2] > 0)
                    hull() {
                        translate([points[i].x, points[i].y])
                            circle(points[i][2]);

                        polygon([tangents[(2 * i - 1 + 2 * len) % (2 * len)], tangents[2 * i], [points[i].x, points[i].y]]);
                    }

            polygon(tangents, convexity = points);
        }
        for(i = indices)
            if(points[i][2] < 0)
                hull() {
                    translate([points[i].x, points[i].y])
                        circle(-points[i][2]);

                    polygon([tangents[(2 * i - 1 + 2 * len) % (2 * len)], tangents[2 * i], [points[i].x, points[i].y]]);
                }
     }
}
