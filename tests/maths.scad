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
include <../core.scad>
use <../utils/maths.scad>
use <../utils/annotation.scad>

tip = [0, 0, 20];

module shape() {
    cylinder(d1 = 20, d2 = 0, h = tip.z);
}

t = [10, 20, 30];
r = [45, 20, 70];
s = [1, 0.5, 0.75];

module maths() {
    //
    // Translate, rotate and scale the shape
    //
    translate(t)
        rotate(r)
            scale(s)
                shape();
    //
    // Apply the same transformations to the vector position of the tip
    //
    p = transform(tip, translate(t) * rotate(r) * scale(s));
    //
    // Place an arrow where the tip ends up
    //
    translate(p)
        arrow();
    //
    // Unit vector pointing at p
    //
    u = unit(p);
    //
    // Point arrow in same direction
    //
    z = [0, 0, 1];
    v = cross(u, z);
    a = acos(u * z);


    l = 20;
    rotate(-a, v)
        translate_z(l)
            vflip()
                arrow(l);
}

rotate(45)
    maths();
