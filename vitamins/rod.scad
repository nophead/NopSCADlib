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
//! Steel rods and studding with chamfered ends.
//
include <../core.scad>
use <../utils/sweep.scad>

rod_colour = grey80;
studding_colour = grey70;
leadscrew_colour = grey70;

module rod(d , l) { //! Draw a smooth rod with specified length and diameter
    vitamin(str("rod(", d, ", ", l, "): Smooth rod ", d, "mm x ", l, "mm"));

    chamfer = d / 10;
    color(rod_colour)
        hull() {
            cylinder(d = d, h = l - 2 * chamfer, center = true);

            cylinder(d = d - 2 * chamfer, h = l, center = true);
        }
}

module studding(d , l) { //! Draw a threaded rod with specified length and diameter
    vitamin(str("studding(", d, ", ", l,"): Threaded rod M", d, " x ", l, "mm"));

    chamfer = d / 20;
    color(studding_colour)
        hull() {
            cylinder(d = d, h = l - 2 * chamfer, center = true);

            cylinder(d = d - 2 * chamfer, h = l, center = true);
        }
}

module leadscrew(d, l, p) {//! Draw a leadscrew with the specified length, diameter and pitch
    assert(d >= 4, "Leadscrew diameter must be >= 4");
    diameter = d;
    length = l;
    pitch = p ? p : d > 10 ? 3 : 2;
    color(leadscrew_colour)
        translate_z(-length / 2 + pitch/4) { // additional pitch/4 elevation so thread does not protrude from bottom of rod
            minorDiameter = diameter <= 6 ? diameter - 1 : diameter <= 10 ? diameter - pitch - 0.5 : diameter - pitch - 0.75;
            // set up a square profile for the thread
            a = max(diameter - minorDiameter, 1) / 2;
            r = (diameter + minorDiameter + pitch) / 4;
            profile =[[-pitch/4, -(diameter /2 - a)/2, 0], [pitch /4 , -(diameter /2 - a)/2, 0], [pitch / 4, (diameter /2 - r)/2, 0], [-pitch/4, (diameter / 2 - r)/2, 0]];

            // create a spiral that is one turn of the thread, with one segment of overlap
            count = ceil(max(min(360 / $fa, d*PI / $fs)/2, 5));
            step = 360 / count;
            spiral = [for(i = [0 : step : 360 + step]) [r * sin(i), -r * cos(i), i * pitch / 360]];

            // do as many full turns as will fully fit in the length
            turnCount = floor((length - pitch / 2) / pitch);
            for(i = [0 : turnCount - 1])
                translate_z(i * pitch) {
                    sweep(spiral, profile, loop = false, twist = 30);
                }

            // add a partial turn at the end
            end = ((length-pitch/2) - turnCount * pitch) / pitch * 360 - 20;
            if(end > 20) {
                spiralTop = [for(i = [0 : step : end]) [r * sin(i), -r*cos(i), i * pitch /360]];
                translate_z(turnCount * pitch)
                    sweep(spiralTop, profile, loop = false, twist = 30 * end / 360);
            }
            translate_z(-pitch/4) cylinder(d = minorDiameter, h = length);
        }
}

