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
include <../utils/core/core.scad>
use <../utils/thread.scad>

pitch = 2;
starts = 4;

profile = thread_profile(pitch / 2, pitch * 0.366, 30);

module threads()
    for(female = [false, true]) translate([0, female ? -20 : 0]) {
        length = female ? 8  : 40;
        dia = female ? 8 : 8 - pitch;
        colour = female ? brass : silver;

        thread(dia, starts * pitch, length, profile, starts = starts, top = 45, bot = 45, female = female, colour = colour);

        color(colour)
            translate([20, 0])
                thread(dia, starts * pitch, length, profile, starts = starts, top = 0, bot = 0, female = female);

        translate([40, 0])
            thread(dia, starts * pitch, length, profile, starts = starts, top = -1, bot = -1, female = female, colour = colour);

        color(colour)
            translate([60, 0])
                thread(dia, 2 * pitch, length, profile, starts = 2, top = -1, bot = -1, female = female);

        color(colour)
            translate([80, 0])
                thread(dia, pitch, length, profile, starts = 1, top = -1, bot = -1, female = female);
    }

let($show_threads = true)
    threads();
