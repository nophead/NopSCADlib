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
//!
//! These items are sysmtrical, so by default the origin is in the centre but it can be changed to the bottom.
//
include <../utils/core/core.scad>
use <../utils/thread.scad>

rod_colour = grey(80);
studding_colour = grey(70);
leadscrew_colour = grey(70);

module rod(d , l, center = true) { //! Draw a smooth rod with specified diameter and length
    vitamin(str("rod(", d, ", ", l, "): Smooth rod ", d, "mm x ", l, "mm"));

    chamfer = d / 10;
    color(rod_colour)
        translate_z(center ? 0 : l / 2)
            hull() {
                cylinder(d = d, h = l - 2 * chamfer, center = true);

                cylinder(d = d - 2 * chamfer, h = l, center = true);
            }
}

module studding(d , l, center = true) { //! Draw a threaded rod with specified diameter and length
    vitamin(str("studding(", d, ", ", l,"): Threaded rod M", d, " x ", l, "mm"));

    chamfer = d / 20;
    pitch = metric_coarse_pitch(d);

    translate_z(center ? 0 : l / 2)
        if(show_threads && pitch)
            male_metric_thread(d, pitch, l, colour = rod_colour);
        else
            color(studding_colour)
                hull() {
                    cylinder(d = d, h = l - 2 * chamfer, center = true);

                    cylinder(d = d - 2 * chamfer, h = l, center = true);
                }
}

module leadscrew(d , l, lead, starts, center = true) { //! Draw a leadscrew with specified diameter, length, lead and number of starts
    vitamin(str("leadscrew(", d, ", ", l, ", ", lead, ", ", starts, "): Leadscrew ", d, " x ", l, "mm, ", lead, "mm lead, ", starts, " starts"));

    pitch = lead / starts;
    chamfer = pitch / 2;

    translate_z(center ? 0 : l / 2)
        if(show_threads && pitch)
            thread(d - pitch, lead, l, thread_profile(pitch / 2, pitch * 0.366, 30), top = 45, bot = 45, starts = starts, colour = rod_colour);
        else
            color(leadscrew_colour)
                hull() {
                    cylinder(d = d, h = l - 2 * chamfer, center = true);

                    cylinder(d = d - 2 * chamfer, h = l, center = true);
                }
}
