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
//! Utilities for making involute gears.
//!
//! Formulas from <https://khkgears.net/new/gear_knowledge/gear_technical_reference/involute_gear_profile.html>
//! and <https://www.tec-science.com/mechanical-power-transmission/involute-gear/calculation-of-involute-gears/>
//!
//! ```involute_gear_profile()``` returns a polygon that can have the bore and spokes, etc, subtracted from it before linear extruding it to 3D.
//! Helical gears can be made using ```twist``` and bevel gears using ```scale``` parameters of ```linear_extrude()```.
//!
//! Gears with less than 19 teeth (when pressure angle is 20) are profile shifted to avoid undercutting the tooth root. 7 teeth is considered
//! the practical minimum.
//!
//! The clearance between tip and root defaults to module / 6, but can be overridden by setting the ```clearance``` parameter.
//
include <core/core.scad>
use <maths.scad>

function involute(r, u) = let(a = degrees(u), c = cos(a), s = sin(a)) r * [c + u * s, s - u * c]; //! Involute of circle radius r at angle u in radians

function profile_shift(z, pa) = max(1 - z * sqr(sin(pa)) / 2, 0); //! Calculate profile shift for small gears

function centre_distance(m, z1, z2, pa) = //! Calculate distance between centres taking profile shift into account
    let(x1 = profile_shift(z1, pa), x2 = profile_shift(z2, pa)) m * (z1/2 + z2/2 + x1 + x2);

module involute_gear_profile(m, z, pa = 20, clearance = undef, steps = 20) { //! Calculate profile given module, number of teeth and pressure angle
    assert(z >= 7, "Gears must have at least 7 teeth.");
    d = m * z;                                                  // Reference pitch circle diameter
    x = profile_shift(z, pa);                                   // Profile shift
    c = is_undef(clearance) ? m / 6 : clearance;                // Clearance from tip to root

    base_d = d * cos(pa);                                       // Base diameter
    root_r = d / 2 + m * (x - 1) - c;                           // Root radius (dedendum circle radius)
    tip_d = d + 2 * m * (1 + x);                                // Tip diameter (addendum circle diameter)
    tpa = acos(base_d / tip_d);                                 // Tip pressure angle
    inva = tan(pa) - radians(pa);                               // Involute alpha
    invaa = tan(tpa) - radians(tpa);                            // Involute alphaa
    ta =  PI / (2 * z) + 2 * x * tan(pa) / z + inva - invaa;    // Tooth tip thickness angle, radians
    crest_w = ta * tip_d;                                       // Crest width
    umax = sqrt(sqr(tip_d / base_d) - 1);                       // Max value of the involute parameter

    base_r = base_d / 2;
    p1 = involute(base_r, 0);
    p2 = involute(base_r, umax);
    dist = norm(p2 - p1);                                        // distance between beginning and end of the involute curve

    base_angle = 2 * acos((sqr(base_r) + sqr(tip_d / 2) - sqr(dist)) / base_r / tip_d) + degrees(2 * ta);
    root_angle = 360 / z - base_angle;
    root_circle_r = base_r * sin(root_angle / 2);

    if(!is_undef($show_numbers) && $show_numbers) {
        echo(d=d);
        echo(base_d=base_d);
        echo(tip_d=tip_d);
        echo(tpa = tpa);
        echo(inva=inva);
        echo(invaa=invaa);
        echo(x=x);
        echo(ta=ta);
        echo(crest_w=crest_w);
        echo(umax = umax);
        echo(base_angle=base_angle);
        echo(root_angle=root_angle);
    }
    involute = [for(i = [0 : steps], u = umax * i / steps) involute(base_r, u)]; // involute for the bottom side of the tooth
    truncated = [for(p = involute) if((rot2_z(-base_angle / 2) * p).y <= 0) p];  // removed any above the centreline to prevent overlap
    reflection = reverse([for(p = truncated) rot2_z(base_angle) * [p.x, -p.y] ]); // reflect and rotate to make the top edge

    root = reverse([for(a = [90 : 180 / steps : 270]) rot2_z(base_angle + root_angle / 2) * ([base_r, 0] + root_circle_r * [cos(a), sin(a)]) ]);
    tooth = concat(truncated, reflection, root);
    gear = concat([for(i = [0 : z - 1], p = tooth) rot2_z(i * 360 / z) * p]);
    rotate(-base_angle / 2)
        union() {
            polygon(gear);

            circle(root_r);
        }
}
